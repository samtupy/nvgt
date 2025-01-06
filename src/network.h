/* network.h - enet implementation header
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#pragma once

#include <enet6/enet.h>
#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#include <windows.h>
#else
	#include <cstring>
#endif
#include <map>
#include <unordered_map>
#include <string>
#include <angelscript.h>
#include <scriptarray.h>

extern bool g_enet_initialized;
class network_event;
class network {
	int RefCount;
	ENetHost* host;
	std::unordered_map<asQWORD, ENetPeer*> peers;
	asQWORD next_peer;
	unsigned char channel_count;
	ENetPeer* get_peer(asQWORD peer_id);
	// Enet's total_sent/received counters are 32 bit integers that can overflow, work around that
	asQWORD total_sent_data, total_sent_packets, total_received_data, total_received_packets;
	void update_totals() {
		if (!host) return;
		total_sent_data += host->totalSentData; host->totalSentData = 0;
		total_sent_packets += host->totalSentPackets; host->totalSentPackets = 0;
		total_received_data += host->totalReceivedData; host->totalReceivedData = 0;
		total_received_packets += host->totalReceivedPackets; host->totalReceivedPackets = 0;
	}
	void reset_totals() {
		total_sent_data = total_sent_packets = total_received_data = total_received_packets = 0;
	}
public:
	bool is_client;
	bool IPv6enabled;
	bool receive_timeout_event;
	network();
	void addRef();
	void release();
	void destroy(bool flush = true);
	bool setup_client(unsigned char max_channels, unsigned short max_peers);
	bool setup_server(unsigned short port, unsigned char max_channels, unsigned short max_peers);
	bool setup_local_server(unsigned short port, unsigned char max_channels, unsigned short max_peers);
	asQWORD connect(const std::string& hostname, unsigned short port);
	const network_event* request(uint32_t timeout = 0);
	std::string get_peer_address(asQWORD peer_id);
	unsigned int get_peer_average_round_trip_time(asQWORD peer_id);
	bool send(asQWORD peer_id, const std::string& message, unsigned char channel, bool reliable = true);
	bool send_reliable(asQWORD peer_id, const std::string& message, unsigned char channel) {
		return send(peer_id, message, channel);
	}
	bool send_unreliable(asQWORD peer_id, const std::string& message, unsigned char channel) {
		return send(peer_id, message, channel, false);
	}
	bool send_peer(asQWORD peer, const std::string& message, unsigned char channel, bool reliable = true);
	bool send_reliable_peer(asQWORD peer, const std::string& message, unsigned char channel) {
		return send_peer(peer, message, channel);
	}
	bool send_unreliable_peer(asQWORD peer, const std::string& message, unsigned char channel) {
		return send(peer, message, channel, false);
	}
	bool disconnect_peer_softly(asQWORD peer_id);
	bool disconnect_peer(asQWORD peer_id);
	bool disconnect_peer_forcefully(asQWORD peer_id);
	CScriptArray* list_peers();
	bool set_bandwidth_limits(unsigned int incoming, unsigned int outgoing);
	void set_packet_compression(bool flag);
	bool get_packet_compression() {
		return host && host->compressor.context;
	}
	size_t get_connected_peers() {
		return host ? host->connectedPeers : -1;
	}
	size_t get_bytes_received() {
		update_totals();
		return host ? total_received_data : -1;
	}
	size_t get_bytes_sent() {
		update_totals();
		return host ? total_sent_data : -1;
	}
	size_t get_packets_received() {
		update_totals();
		return host ? total_received_packets : -1;
	}
	size_t get_packets_sent() {
		update_totals();
		return host ? total_sent_packets : -1;
	}
	size_t get_duplicate_peers() {
		return host ? host->duplicatePeers : -1;
	}
	void set_duplicate_peers(size_t peers) {
		if (host) host->duplicatePeers = peers;
	}
	bool active() {
		return host != NULL;
	}
};
class network_event {
public:
	int type;
	asQWORD peer;
	asQWORD peer_id;
	unsigned int channel;
	std::string message;
	int RefCount;
	network_event();
	network_event& operator=(const network_event& e);
	void addRef();
	void release();
};

void RegisterScriptNetwork(asIScriptEngine* engine);
