/* network.cpp - enet implementation code
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#include <chrono>
#include <obfuscate.h>
#include "nvgt_angelscript.h" // get_array_type
#include "network.h"

// Milliseconds on a steady clock, for the keeper thread's idea of how long the script has gone without calling request().
static uint64_t network_now_ms() {
	return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
}

bool g_enet_initialized = false;
network_event g_enet_none_event; // The none event is static and never changes, why reallocate it every time network::request() doesn't come up with an event?
ENetPeer* network::get_peer(asQWORD peer_id) {
	std::unordered_map<asQWORD, ENetPeer*>::iterator i = peers.find(peer_id);
	if (i == peers.end())
		return NULL;
	return i->second;
}

network::network() : keeper_stop(false), keep_alive_ms(1000), last_service(0) {
	if (!g_enet_initialized) {
		enet_initialize();
		g_enet_initialized = true;
	}
	host = NULL;
	next_peer = 1;
	channel_count = 0;
	is_client = receive_timeout_event = IPv6enabled = false;
	send_immediately = true;
	RefCount = 1;
	reset_totals();
}
void network::addRef() {
	asAtomicInc(RefCount);
}
void network::release() {
	if (asAtomicDec(RefCount) < 1) {
		destroy();
		delete this;
	}
}

void network::start_keeper() {
	if (keeper.joinable()) return; // still running from before: it finds the new host itself (setup_* holds the lock, so it can't be joined here)
	last_service = network_now_ms();
	keeper_stop = false;
	keeper = std::thread(&network::keeper_loop, this);
}
void network::stop_keeper() {
	if (!keeper.joinable()) return;
	keeper_stop = true;
	keeper.join();
}
void network::keeper_loop() {
	while (!keeper_stop) {
		std::this_thread::sleep_for(std::chrono::milliseconds(20));
		unsigned int after = keep_alive_ms;
		uint64_t last = last_service, now = network_now_ms(); // last first: request() may set it later than this now
		if (!after || now < last || now - last < after) continue;
		host_lock lock(mutex);
		if (!host) continue;
		ENetEvent event;
		while (enet_host_service(host, &event, 0) > 0) held_events.push_back(take_event(event));
	}
}
void network::clear_held_events() {
	for (network_pending_event& e : held_events) {
		if (e.packet) enet_packet_destroy(e.packet);
	}
	held_events.clear();
}

void network::destroy(bool flush) {
	stop_keeper();
	host_lock lock(mutex);
	clear_held_events();
	if (host) {
		if (flush) {
			for (const auto& it : peers) enet_peer_disconnect(it.second, 0);
			enet_host_flush(host);
		}
		enet_host_destroy(host);
		host = NULL;
	}
	peers.clear();
	next_peer = 1;
	channel_count = 0;
	is_client = false;
	reset_totals();
}

bool network::setup_client(unsigned char max_channels, unsigned short max_peers) {
	host_lock lock(mutex);
	if (host) return false;
	host = enet_host_create(IPv6enabled? ENET_ADDRESS_TYPE_ANY : ENET_ADDRESS_TYPE_IPV4, NULL, max_peers, max_channels, 0, 0);
	if (!host) return false;
	is_client = true;
	channel_count = max_channels;
	start_keeper();
	return true;
}

bool network::setup_server(unsigned short port, unsigned char max_channels, unsigned short max_peers) {
	host_lock lock(mutex);
	if (host) return false;
	ENetAddress address;
	enet_address_build_any(&address, IPv6enabled? ENET_ADDRESS_TYPE_IPV6 : ENET_ADDRESS_TYPE_IPV4);
	address.port = port;
	host = enet_host_create(IPv6enabled? ENET_ADDRESS_TYPE_ANY : ENET_ADDRESS_TYPE_IPV4, &address, max_peers, max_channels, 0, 0);
	if (!host) return false;
	channel_count = max_channels;
	start_keeper();
	return true;
}

bool network::setup_local_server(unsigned short port, unsigned char max_channels, unsigned short max_peers) {
	host_lock lock(mutex);
	if (host) return false;
	ENetAddress address;
	enet_address_build_loopback(&address, IPv6enabled? ENET_ADDRESS_TYPE_IPV6 : ENET_ADDRESS_TYPE_IPV4);
	address.port = port;
	host = enet_host_create(IPv6enabled? ENET_ADDRESS_TYPE_ANY : ENET_ADDRESS_TYPE_IPV4, &address, max_peers, max_channels, 0, 0);
	if (!host) return false;
	channel_count = max_channels;
	start_keeper();
	return true;
}

asQWORD network::connect(const std::string& hostname, unsigned short port) {
	host_lock lock(mutex);
	if (!host || !is_client) return 0;
	ENetAddress addr;
	if (enet_address_set_host(&addr, IPv6enabled? ENET_ADDRESS_TYPE_ANY : ENET_ADDRESS_TYPE_IPV4, hostname.c_str()) < 0) return false;
	addr.port = port;
	ENetPeer* svr = enet_host_connect(host, &addr, channel_count, 0);
	if (!svr) return 0;
	peers[next_peer] = svr;
	svr->data = reinterpret_cast<void*>(next_peer);
	next_peer += 1;
	return next_peer - 1;
}

// Does what an event from the host means for its peer at once (as the host gives it), whether request() or the keeper thread got it.
network_pending_event network::take_event(ENetEvent& event) {
	network_pending_event p;
	p.type = event.type;
	p.channel = event.channelID;
	p.packet = nullptr;
	p.peer_id = 0;
	if (event.type == ENET_EVENT_TYPE_CONNECT) {
		enet_peer_timeout(event.peer, 128, 10000, 35000);
		if (!is_client) {
			event.peer->data = reinterpret_cast<void*>(next_peer);
			peers[next_peer] = event.peer;
			p.peer_id = next_peer;
			next_peer++;
		} else
			p.peer_id = (asQWORD)event.peer->data;
	} else if (event.type == ENET_EVENT_TYPE_DISCONNECT || event.type == ENET_EVENT_TYPE_DISCONNECT_TIMEOUT) {
		asQWORD peer_id = (asQWORD)event.peer->data;
		event.peer->data = NULL;
		if (peer_id > 0)
			peers.erase(peer_id);
		p.peer_id = peer_id;
	} else if (event.type == ENET_EVENT_TYPE_RECEIVE) {
		p.peer_id = (asQWORD)event.peer->data;
		p.packet = event.packet;
	}
	return p;
}
network_event* network::make_event(network_pending_event& p) {
	update_totals(); // total_sent, total_received...
	network_event* e = new network_event();
	e->type = p.type;
	e->channel = p.channel;
	e->peer_id = p.peer_id;
	if (!receive_timeout_event && e->type == ENET_EVENT_TYPE_DISCONNECT_TIMEOUT) e->type = ENET_EVENT_TYPE_DISCONNECT;
	if (p.packet) {
		e->message.append((char*)p.packet->data, p.packet->dataLength);
		enet_packet_destroy(p.packet);
		p.packet = nullptr;
	}
	return e;
}
const network_event* network::request(uint32_t timeout) {
	host_lock lock(mutex);
	last_service = network_now_ms();
	if (!host) {
		g_enet_none_event.addRef();
		return &g_enet_none_event;
	}
	network_pending_event p;
	if (!held_events.empty()) {
		// What came while the script was held up, before anything newer.
		p = held_events.front();
		held_events.pop_front();
	} else {
		ENetEvent event;
		int r = enet_host_service(host, &event, timeout);
		if (r < 1) {
			g_enet_none_event.addRef();
			return &g_enet_none_event;
		}
		p = take_event(event);
	}
	return make_event(p);
}

std::string network::get_peer_address(asQWORD peer_id) {
	host_lock lock(mutex);
	ENetPeer* peer = get_peer(peer_id);
	if (!peer) return "";
	std::string tmp(32, '\0');
	if (enet_address_get_host_ip(&peer->address, &tmp[0], 32) < 0) return "";
	tmp.resize(strlen(&tmp[0]));
	return tmp;
}
unsigned int network::get_peer_average_round_trip_time(asQWORD peer_id) {
	host_lock lock(mutex);
	if (!host) return -1;
	ENetPeer* peer = get_peer(peer_id);
	if (!peer) return -1;
	return peer->roundTripTime;
}

bool network::send(asQWORD peer_id, const std::string& message, unsigned char channel, bool reliable) {
	host_lock lock(mutex);
	if (!host || channel > channel_count) return false;
	ENetPeer* peer = get_peer(peer_id);
	if (peer_id && !peer) return false;
	ENetPacket* packet = enet_packet_create(message.c_str(), message.size(), (reliable ? ENET_PACKET_FLAG_RELIABLE : 0));
	if (!packet) return false;
	bool r = true;
	if (peer_id) r = enet_peer_send(peer, channel, packet) == 0;
	else enet_host_broadcast(host, channel, packet);
	if (!r) enet_packet_destroy(packet);
	if (send_immediately) flush();
	return r;
}
bool network::send_peer(asQWORD peer, const std::string& message, unsigned char channel, bool reliable) {
	host_lock lock(mutex);
	if (!host || channel > channel_count) return false;
	ENetPeer* peer_obj = reinterpret_cast<ENetPeer*>(peer);
	if (peer < asQWORD(host->peers) || peer >= asQWORD(host->peers + host->peerCount) || (peer - asQWORD(host->peers)) % sizeof(ENetPeer) != 0) return false;
	ENetPacket* packet = enet_packet_create(message.c_str(), message.size(), (reliable ? ENET_PACKET_FLAG_RELIABLE : 0));
	if (!packet) return false;
	bool r = enet_peer_send(peer_obj, channel, packet) == 0;
	if (!r) enet_packet_destroy(packet);
	if (send_immediately) flush();
	return r;
}

bool network::flush() {
	host_lock lock(mutex);
	if (!host) return false;
	enet_host_flush(host);
	return true;
}

bool network::disconnect_peer_softly(asQWORD peer_id) {
	host_lock lock(mutex);
	if (!host) return false;
	ENetPeer* peer = get_peer(peer_id);
	if (!peer) return false;
	enet_peer_disconnect_later(peer, 0);
	peers.erase(peer_id);
	return true;
}
bool network::disconnect_peer(asQWORD peer_id) {
	host_lock lock(mutex);
	if (!host) return false;
	ENetPeer* peer = get_peer(peer_id);
	if (!peer) return false;
	enet_peer_disconnect(peer, 0);
	peers.erase(peer_id);
	return true;
}
bool network::disconnect_peer_forcefully(asQWORD peer_id) {
	host_lock lock(mutex);
	if (!host) return false;
	ENetPeer* peer = get_peer(peer_id);
	if (!peer) return false;
	enet_peer_disconnect_now(peer, 0);
	peers.erase(peer_id);
	return true;
}

CScriptArray* network::list_peers() {
	host_lock lock(mutex);
	asITypeInfo* arrayType = get_array_type("uint64[]");
	CScriptArray* array = CScriptArray::Create(arrayType);
	if (!host) return array;
	array->Reserve(peers.size());
	for (std::unordered_map<asQWORD, ENetPeer*>::iterator it = peers.begin(); it != peers.end(); it++) {
		asQWORD peer = it->first;
		array->InsertLast(&peer);
	}
	return array;
}

bool network::set_bandwidth_limits(unsigned int incoming, unsigned int outgoing) {
	host_lock lock(mutex);
	if (!host) return false;
	enet_host_bandwidth_limit(host, incoming, outgoing);
	return true;
}
void network::set_packet_compression(bool flag) {
	host_lock lock(mutex);
	if (!host) return;
	if (flag) enet_host_compress_with_range_coder(host);
	else enet_host_compress(host, nullptr);
}


network_event::network_event() {
	type = 0;
	peer_id = 0;
	channel = 0;
	message = "";
	RefCount = 1;
}
void network_event::addRef() {
	asAtomicInc(RefCount);
}
void network_event::release() {
	if (asAtomicDec(RefCount) < 1)
		delete this;
}
network_event& network_event::operator=(const network_event& e) {
	type = e.type;
	peer_id = e.peer_id;
	channel = e.channel;
	message = e.message;
	return *this;
}


network* ScriptNetwork_Factory() {
	return new network();
}
network_event* ScriptNetwork_event_Factory() {
	return new network_event();
}

void RegisterScriptNetwork(asIScriptEngine* engine) {
	engine->RegisterEnum("network_event_type");
	engine->RegisterEnumValue("network_event_type", "event_none", ENET_EVENT_TYPE_NONE);
	engine->RegisterEnumValue("network_event_type", "event_connect", ENET_EVENT_TYPE_CONNECT);
	engine->RegisterEnumValue("network_event_type", "event_disconnect", ENET_EVENT_TYPE_DISCONNECT);
	engine->RegisterEnumValue("network_event_type", "event_disconnect_timeout", ENET_EVENT_TYPE_DISCONNECT_TIMEOUT);
	engine->RegisterEnumValue("network_event_type", "event_receive", ENET_EVENT_TYPE_RECEIVE);
	engine->RegisterObjectType(_O("network_event"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("network_event"), asBEHAVE_FACTORY, _O("network_event @e()"), asFUNCTION(ScriptNetwork_event_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("network_event"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(network_event, addRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("network_event"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(network_event, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network_event"), _O("network_event& opAssign(const network_event &in other)"), asMETHOD(network_event, operator=), asCALL_THISCALL);
	engine->RegisterObjectProperty(_O("network_event"), _O("const network_event_type type"), asOFFSET(network_event, type));
	engine->RegisterObjectProperty(_O("network_event"), _O("const uint64 peer_id"), asOFFSET(network_event, peer_id));
	engine->RegisterObjectProperty(_O("network_event"), _O("const uint channel"), asOFFSET(network_event, channel));
	engine->RegisterObjectProperty(_O("network_event"), _O("const string message"), asOFFSET(network_event, message));
	engine->RegisterObjectType(_O("network"), 0, asOBJ_REF);
	engine->RegisterObjectBehaviour(_O("network"), asBEHAVE_FACTORY, _O("network @n()"), asFUNCTION(ScriptNetwork_Factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour(_O("network"), asBEHAVE_ADDREF, _O("void f()"), asMETHOD(network, addRef), asCALL_THISCALL);
	engine->RegisterObjectBehaviour(_O("network"), asBEHAVE_RELEASE, _O("void f()"), asMETHOD(network, release), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("void destroy(bool flush = true)"), asMETHOD(network, destroy), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool setup_client(uint8 max_channels, uint16 max_peers)"), asMETHOD(network, setup_client), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool setup_server(uint16 port, uint8 max_channels, uint16 max_peers)"), asMETHOD(network, setup_server), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool setup_local_server(uint16 port, uint8 max_channels, uint16 max_peers)"), asMETHOD(network, setup_local_server), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint64 connect(const string& in host, uint16 port)"), asMETHOD(network, connect), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("const network_event@ request(uint timeout = 0)"), asMETHOD(network, request), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("string get_peer_address(uint64 peer_id) const"), asMETHOD(network, get_peer_address), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint get_peer_average_round_trip_time(uint64 peer_id) const"), asMETHOD(network, get_peer_average_round_trip_time), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool send(uint64 peer_id, const string& in message, uint8 channel, bool reliable = true)"), asMETHOD(network, send), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool send_reliable(uint64 peer_id, const string& in message, uint8 channel)"), asMETHOD(network, send_reliable), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool send_unreliable(uint64 peer_id, const string& in message, uint8 channel)"), asMETHOD(network, send_unreliable), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool send_peer(uint64 peer_pointer, const string& in message, uint8 channel, bool reliable = true)"), asMETHOD(network, send_peer), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool send_reliable_peer(uint64 peer_pointer, const string& in message, uint8 channel)"), asMETHOD(network, send_reliable_peer), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool send_unreliable_peer(uint64 peer_pointer, const string& in message, uint8 channel)"), asMETHOD(network, send_unreliable_peer), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool flush()"), asMETHOD(network, flush), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool disconnect_peer_softly(uint64 peer_id)"), asMETHOD(network, disconnect_peer_softly), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool disconnect_peer(uint64 peer_id)"), asMETHOD(network, disconnect_peer), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool disconnect_peer_forcefully(uint64 peer_id)"), asMETHOD(network, disconnect_peer_forcefully), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint64[]@ get_peer_list() const"), asMETHOD(network, list_peers), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint64 get_connected_peers() const property"), asMETHOD(network, get_connected_peers), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool get_packet_compression() const property"), asMETHOD(network, get_packet_compression), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("void set_packet_compression(bool compressed) property"), asMETHOD(network, set_packet_compression), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint get_duplicate_peers() const property"), asMETHOD(network, get_duplicate_peers), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("void set_duplicate_peers(uint max_duplicates) property"), asMETHOD(network, set_duplicate_peers), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint get_bytes_received() const property"), asMETHOD(network, get_bytes_received), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint get_bytes_sent() const property"), asMETHOD(network, get_bytes_sent), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint get_packets_received() const property"), asMETHOD(network, get_packets_received), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint get_packets_sent() const property"), asMETHOD(network, get_packets_sent), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("void set_bandwidth_limits(uint max_incoming_bytes_per_second, uint max_outgoing_bytes_per_second)"), asMETHOD(network, set_bandwidth_limits), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("bool get_active() const property"), asMETHOD(network, active), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("uint get_keep_alive_time() const property"), asMETHOD(network, get_keep_alive_time), asCALL_THISCALL);
	engine->RegisterObjectMethod(_O("network"), _O("void set_keep_alive_time(uint milliseconds) property"), asMETHOD(network, set_keep_alive_time), asCALL_THISCALL);
	engine->RegisterObjectProperty(_O("network"), _O("bool IPV6enabled"), asOFFSET(network, IPv6enabled));
	engine->RegisterObjectProperty(_O("network"), _O("bool receive_timeout_event"), asOFFSET(network, receive_timeout_event));
	engine->RegisterObjectProperty(_O("network"), _O("bool send_immediately"), asOFFSET(network, send_immediately));
}
