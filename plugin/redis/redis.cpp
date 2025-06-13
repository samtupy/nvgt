/* redis.cpp - Redis client wrapper implementation using Poco::Redis
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

#include "../../src/nvgt_plugin.h"
#include "redis.h"

#include <Poco/Event.h>
#include <Poco/Net/NetException.h>
#include <Poco/Net/SocketAddress.h>
#include <Poco/NumberFormatter.h>
#include <Poco/Redis/Array.h>
#include <Poco/Redis/AsyncReader.h>
#include <Poco/Redis/Client.h>
#include <Poco/Redis/Command.h>
#include <Poco/Redis/Error.h>
#include <Poco/Redis/Exception.h>
#include <Poco/Redis/Type.h>
#include <Poco/Thread.h>
#include <Poco/Timespan.h>
#include <scriptarray.h>
#include <scriptdictionary.h>

#include <memory>
#include <sstream>
#include <unordered_map>

int g_StringTypeid = 0;  // Local copy for plugin use

// Don't want to enforce that pocostuff stays the same since this is a plugin.
// We'll roll our own
template <class T>
class plugin_refcounted {
private:
	int m_refcount;

public:
	Poco::SharedPtr<T> shared;
	T* ptr;

	plugin_refcounted(Poco::SharedPtr<T> s) : m_refcount(1), shared(s), ptr(s.get()) {}
	virtual ~plugin_refcounted() {}

	void add_ref() { asAtomicInc(m_refcount); }
	void release() {
		if (asAtomicDec(m_refcount) < 1)
			delete this;
	}
};

using namespace Poco;
using namespace Poco::Redis;

// Redis value wrapper
class redis_value : public plugin_refcounted<RedisType> {
public:
	redis_value(RedisType::Ptr value) : plugin_refcounted(value) {}
	redis_value(redis_value* other) : plugin_refcounted(other->shared) {}

	redis_value& operator=(redis_value* other) {
		shared = other->shared;
		ptr = shared.get();
		return *this;
	}

	bool is_string() const {
		return ptr && (ptr->isBulkString() || ptr->isSimpleString());
	}
	bool is_error() const { return ptr && ptr->isError(); }
	bool is_integer() const { return ptr && ptr->isInteger(); }
	bool is_array() const { return ptr && ptr->isArray(); }
	bool is_nil() const {
		if (!ptr) return true;
		if (ptr->isBulkString()) {
			const Type<BulkString>* bs = dynamic_cast<const Type<BulkString>*>(ptr);
			return bs && bs->value().isNull();
		}
		return false;
	}

	std::string get_string() const {
		if (!ptr) return "";
		if (ptr->isSimpleString()) {
			const Type<std::string>* str = dynamic_cast<const Type<std::string>*>(ptr);
			return str ? str->value() : "";
		} else if (ptr->isBulkString()) {
			const Type<BulkString>* bs = dynamic_cast<const Type<BulkString>*>(ptr);
			return (bs && !bs->value().isNull()) ? bs->value().value() : "";
		} else if (ptr->isError()) {
			const Type<Error>* err = dynamic_cast<const Type<Error>*>(ptr);
			return err ? err->value().getMessage() : "";
		} else if (ptr->isInteger()) {
			const Type<Int64>* i = dynamic_cast<const Type<Int64>*>(ptr);
			return i ? NumberFormatter::format(i->value()) : "0";
		}
		return "";
	}

	int64_t get_integer() const {
		if (!ptr) return 0;
		if (ptr->isInteger()) {
			const Type<Int64>* i = dynamic_cast<const Type<Int64>*>(ptr);
			return i ? i->value() : 0;
		}
		return 0;
	}

	CScriptArray* get_array() const {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<redis_value@>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (ptr && ptr->isArray()) {
			const Type<Array>* arr = dynamic_cast<const Type<Array>*>(ptr);
			if (arr) {
				const Array& redisArray = arr->value();
				for (auto it = redisArray.begin(); it != redisArray.end(); ++it) {
					redis_value* val = new redis_value(*it);
					result->InsertLast(&val);
					val->release();  // CScriptArray takes ownership
				}
			}
		}
		return result;
	}
};

// Redis client wrapper
class redis_client : public plugin_refcounted<Client> {
private:
	std::string m_host;
	int m_port;
	std::string m_password;
	int m_database;
	std::string m_last_error;
	int m_timeout_ms;
	bool m_pipeline_mode = false;
	std::vector<Array> m_pipeline_commands;

	// Helper to create Poco Redis Array from parameters
	template <typename... Args>
	Array make_command(const std::string& cmd, Args&&... args) {
		Array arr;
		arr.add(cmd);
		add_to_array(arr, std::forward<Args>(args)...);
		return arr;
	}

	void add_to_array(Array& arr) {}

	template <typename T, typename... Args>
	void add_to_array(Array& arr, T&& first, Args&&... args) {
		add_value_to_array(arr, std::forward<T>(first));
		add_to_array(arr, std::forward<Args>(args)...);
	}

	// Helper to convert numeric types to strings
	template <typename T>
	void add_value_to_array(Array& arr, T&& value) {
		if constexpr(std::is_same_v<std::decay_t<T>, int> ||
		             std::is_same_v<std::decay_t<T>, int64_t> ||
		             std::is_same_v<std::decay_t<T>, double>)
			arr.add(NumberFormatter::format(value));
		else
			arr.add(std::forward<T>(value));
	}

	// Execute command and handle errors
	template <typename T>
	bool execute_command(const Array& cmd, T& result) {
		try {
			result = ptr->execute<T>(cmd);
			m_last_error.clear();
			return true;
		} catch (const RedisException& e) {
			m_last_error = e.message();
			return false;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return false;
		} catch (...) {
			m_last_error = "Unknown error";
			return false;
		}
	}

	redis_value* execute_command_value(const Array& cmd) {
		try {
			RedisType::Ptr reply = ptr->sendCommand(cmd);
			m_last_error.clear();
			return new redis_value(reply);
		} catch (const RedisException& e) {
			m_last_error = e.message();
			return nullptr;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return nullptr;
		} catch (...) {
			m_last_error = "Unknown error";
			return nullptr;
		}
	}

public:
	redis_client() : plugin_refcounted(new Client()), m_host("localhost"), m_port(6379), m_database(0), m_timeout_ms(5000) {}
	redis_client(redis_client* other) : plugin_refcounted(other->shared),
		m_host(other->m_host),
		m_port(other->m_port),
		m_password(other->m_password),
		m_database(other->m_database),
		m_timeout_ms(other->m_timeout_ms) {}

	redis_client& operator=(redis_client* other) {
		shared = other->shared;
		ptr = shared.get();
		m_host = other->m_host;
		m_port = other->m_port;
		m_password = other->m_password;
		m_database = other->m_database;
		m_timeout_ms = other->m_timeout_ms;
		return *this;
	}

	std::string get_host() const { return m_host; }
	void set_host(const std::string& host) { m_host = host; }

	int get_port() const { return m_port; }
	void set_port(int port) { m_port = port; }

	std::string get_password() const { return m_password; }
	void set_password(const std::string& pwd) { m_password = pwd; }

	int get_database() const { return m_database; }
	void set_database(int db) { m_database = db; }

	int get_timeout() const { return m_timeout_ms; }
	void set_timeout(int ms) { m_timeout_ms = ms; }

	std::string get_last_error() const { return m_last_error; }

	bool is_connected() const {
		return ptr && ptr->isConnected();
	}

	bool connect() {
		try {
			Timespan timeout(m_timeout_ms * 1000);  // microseconds
			ptr->connect(m_host, m_port, timeout);
			// Authenticate if password is set
			if (!m_password.empty()) {
				Array cmd;
				cmd.add("AUTH").add(m_password);
				std::string reply;
				if (!execute_command(cmd, reply)) {
					ptr->disconnect();
					return false;
				}
			}
			// Select database if not default
			if (m_database != 0) {
				Array cmd;
				cmd.add("SELECT").add(NumberFormatter::format(m_database));
				std::string reply;
				if (!execute_command(cmd, reply)) {
					ptr->disconnect();
					return false;
				}
			}
			m_last_error.clear();
			return true;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return false;
		} catch (...) {
			m_last_error = "Failed to connect";
			return false;
		}
	}

	bool connect_ex(const std::string& host, int port, const std::string& password = "", int database = 0) {
		m_host = host;
		m_port = port;
		m_password = password;
		m_database = database;
		return connect();
	}

	void disconnect() {
		if (ptr && ptr->isConnected())
			ptr->disconnect();
	}

	std::string ping(const std::string& message = "") {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		Array cmd;
		cmd.add("PING");
		if (!message.empty()) cmd.add(message);
		if (message.empty()) {
			std::string reply;
			execute_command(cmd, reply);
			return reply;
		} else {
			BulkString reply;
			if (execute_command(cmd, reply) && !reply.isNull())
				return reply.value();
			return "";
		}
	}

	bool set(const std::string& key, const std::string& value, int64_t expire_seconds = 0) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Array cmd;
		cmd.add("SET").add(key).add(value);
		if (expire_seconds > 0)
			cmd.add("EX").add(NumberFormatter::format(expire_seconds));
		std::string reply;
		return execute_command(cmd, reply) && reply == "OK";
	}

	std::string get(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("GET", key), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	int64_t incr(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("INCR", key), result);
		return result;
	}

	int64_t decr(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("DECR", key), result);
		return result;
	}

	int64_t incrby(const std::string& key, int64_t increment) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("INCRBY", key, increment), result);
		return result;
	}

	int64_t decrby(const std::string& key, int64_t decrement) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("DECRBY", key, decrement), result);
		return result;
	}

	int64_t append(const std::string& key, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("APPEND", key, value), result);
		return result;
	}

	int64_t strlen(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("STRLEN", key), result);
		return result;
	}

	std::string getrange(const std::string& key, int64_t start, int64_t end) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("GETRANGE", key, start, end), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	int64_t setrange(const std::string& key, int64_t offset, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("SETRANGE", key, offset, value), result);
		return result;
	}

	bool setnx(const std::string& key, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("SETNX", key, value), result);
		return result > 0;
	}

	bool setex(const std::string& key, int64_t seconds, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("SETEX", key, seconds, value), reply) && reply == "OK";
	}

	bool psetex(const std::string& key, int64_t milliseconds, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("PSETEX", key, milliseconds, value), reply) && reply == "OK";
	}

	CScriptArray* mget(CScriptArray* keys) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		if (!keys || keys->GetSize() == 0)
			return result;
		Array cmd;
		cmd.add("MGET");
		for (uint32_t i = 0; i < keys->GetSize(); ++i) {
			std::string* key = static_cast<std::string*>(keys->At(i));
			cmd.add(*key);
		}
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				std::string str = bs.isNull() ? "" : bs.value();
				result->InsertLast(&str);
			}
		}
		return result;
	}

	bool mset(CScriptArray* key_value_pairs) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		if (!key_value_pairs || key_value_pairs->GetSize() % 2 != 0) {
			m_last_error = "Key-value pairs must be even number of elements";
			return false;
		}
		Array cmd;
		cmd.add("MSET");
		for (uint32_t i = 0; i < key_value_pairs->GetSize(); ++i) {
			std::string* str = static_cast<std::string*>(key_value_pairs->At(i));
			cmd.add(*str);
		}
		std::string reply;
		return execute_command(cmd, reply) && reply == "OK";
	}

	bool mset(CScriptDictionary* key_value_dict) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		if (!key_value_dict) {
			m_last_error = "Dictionary is null";
			return false;
		}
		Array cmd;
		cmd.add("MSET");
		CScriptDictionary::CIterator it = key_value_dict->begin();
		while (it != key_value_dict->end()) {
			const std::string& key = it.GetKey();
			const void* value_ptr = it.GetAddressOfValue();
			int type_id = it.GetTypeId();
			cmd.add(key);
			if (type_id == asTYPEID_OBJHANDLE) {
				std::string* str_ptr = static_cast<std::string*>(const_cast<void*>(value_ptr));
				if (str_ptr)
					cmd.add(*str_ptr);
				else
					cmd.add("");
			} else {
				// For other types, try to convert to string
				// Gross and likely not reliable - need to look up how to check implcasts?
				asIScriptContext* ctx = asGetActiveContext();
				asIScriptEngine* engine = ctx->GetEngine();
				asITypeInfo* type_info = engine->GetTypeInfoById(type_id);
				if (type_info && std::string(type_info->GetName()) == "string") {
					std::string* str_ptr = static_cast<std::string*>(const_cast<void*>(value_ptr));
					cmd.add(str_ptr ? *str_ptr : "");
				} else
					cmd.add("");
			}
			++it;
		}
		std::string reply;
		return execute_command(cmd, reply) && reply == "OK";
	}

	bool exists(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("EXISTS", key), result);
		return result > 0;
	}

	bool del(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("DEL", key), result);
		return result > 0;
	}

	bool expire(const std::string& key, int64_t seconds) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("EXPIRE", key, seconds), result);
		return result > 0;
	}

	int64_t ttl(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return -2;
		}
		Int64 result;
		execute_command(make_command("TTL", key), result);
		return result;
	}

	CScriptArray* keys(const std::string& pattern) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Poco::Redis::Array reply;
		if (execute_command(make_command("KEYS", pattern), reply)) {
			try {
				for (size_t i = 0; i < reply.size(); ++i) {
					Poco::Redis::BulkString bs = reply.get<Poco::Redis::BulkString>(i);
					std::string str = bs.isNull() ? "" : bs.value();
					result->InsertLast(&str);
				}
			} catch (const std::exception& e) {
				m_last_error = std::string("Error processing KEYS reply: ") + e.what();
			} catch (...) {
				m_last_error = "Unknown error processing KEYS reply";
			}
		}
		return result;
	}

	std::string type(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		std::string result;
		execute_command(make_command("TYPE", key), result);
		return result;
	}

	int64_t lpush(const std::string& key, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("LPUSH", key, value), result);
		return result;
	}

	int64_t rpush(const std::string& key, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("RPUSH", key, value), result);
		return result;
	}

	std::string lpop(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("LPOP", key), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	std::string rpop(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("RPOP", key), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	int64_t llen(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("LLEN", key), result);
		return result;
	}

	CScriptArray* lrange(const std::string& key, int64_t start, int64_t stop) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array reply;
		if (execute_command(make_command("LRANGE", key, start, stop), reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	std::string lindex(const std::string& key, int64_t index) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("LINDEX", key, index), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	bool lset(const std::string& key, int64_t index, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("LSET", key, index, value), reply) && reply == "OK";
	}

	int64_t lrem(const std::string& key, int64_t count, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("LREM", key, count, value), result);
		return result;
	}

	bool ltrim(const std::string& key, int64_t start, int64_t stop) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("LTRIM", key, start, stop), reply) && reply == "OK";
	}

	int64_t linsert(const std::string& key, const std::string& before_after, const std::string& pivot, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("LINSERT", key, before_after, pivot, value), result);
		return result;
	}

	bool hset(const std::string& key, const std::string& field, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("HSET", key, field, value), result);
		return true;
	}

	std::string hget(const std::string& key, const std::string& field) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("HGET", key, field), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	bool hexists(const std::string& key, const std::string& field) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("HEXISTS", key, field), result);
		return result > 0;
	}

	int64_t hdel(const std::string& key, const std::string& field) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("HDEL", key, field), result);
		return result;
	}

	int64_t hlen(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("HLEN", key), result);
		return result;
	}

	CScriptDictionary* hgetall(const std::string& key) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		CScriptDictionary* dict = CScriptDictionary::Create(engine);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return dict;
		}
		Array reply;
		if (execute_command(make_command("HGETALL", key), reply)) {
			// HGETALL returns field,value,field,value...
			for (size_t i = 0; i + 1 < reply.size(); i += 2) {
				BulkString field = reply.get<BulkString>(i);
				BulkString value = reply.get<BulkString>(i + 1);
				if (!field.isNull() && !value.isNull()) {
					std::string val = value.value();
					dict->Set(field.value(), &val, g_StringTypeid);
				}
			}
		}
		return dict;
	}

	CScriptArray* hkeys(const std::string& key) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array reply;
		if (execute_command(make_command("HKEYS", key), reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	CScriptArray* hvals(const std::string& key) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array reply;
		if (execute_command(make_command("HVALS", key), reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	int64_t hincrby(const std::string& key, const std::string& field, int64_t increment) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("HINCRBY", key, field, increment), result);
		return result;
	}

	double hincrbyfloat(const std::string& key, const std::string& field, double increment) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0.0;
		}
		BulkString result;
		if (execute_command(make_command("HINCRBYFLOAT", key, field, increment), result) && !result.isNull())
			return std::stod(result.value());
		return 0.0;
	}

	bool hsetnx(const std::string& key, const std::string& field, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("HSETNX", key, field, value), result);
		return result > 0;
	}

	int64_t sadd(const std::string& key, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("SADD", key, member), result);
		return result;
	}

	int64_t sadd(const std::string& key, CScriptArray* members) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		if (!members || members->GetSize() == 0)
			return 0;
		Array cmd;
		cmd.add("SADD").add(key);
		for (uint32_t i = 0; i < members->GetSize(); ++i) {
			std::string* member = static_cast<std::string*>(members->At(i));
			cmd.add(*member);
		}
		Int64 result;
		execute_command(cmd, result);
		return result;
	}

	int64_t scard(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("SCARD", key), result);
		return result;
	}

	bool sismember(const std::string& key, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("SISMEMBER", key, member), result);
		return result > 0;
	}

	CScriptArray* smembers(const std::string& key) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array reply;
		if (execute_command(make_command("SMEMBERS", key), reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	int64_t srem(const std::string& key, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("SREM", key, member), result);
		return result;
	}

	std::string spop(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("SPOP", key), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	std::string srandmember(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("SRANDMEMBER", key), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	CScriptArray* srandmember_count(const std::string& key, int64_t count) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array reply;
		if (execute_command(make_command("SRANDMEMBER", key, count), reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	CScriptArray* sunion(CScriptArray* keys) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		if (!keys || keys->GetSize() == 0)
			return result;
		Array cmd;
		cmd.add("SUNION");
		for (uint32_t i = 0; i < keys->GetSize(); ++i) {
			std::string* key = static_cast<std::string*>(keys->At(i));
			cmd.add(*key);
		}
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	CScriptArray* sinter(CScriptArray* keys) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		if (!keys || keys->GetSize() == 0)
			return result;
		Array cmd;
		cmd.add("SINTER");
		for (uint32_t i = 0; i < keys->GetSize(); ++i) {
			std::string* key = static_cast<std::string*>(keys->At(i));
			cmd.add(*key);
		}
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	CScriptArray* sdiff(CScriptArray* keys) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		if (!keys || keys->GetSize() == 0)
			return result;
		Array cmd;
		cmd.add("SDIFF");
		for (uint32_t i = 0; i < keys->GetSize(); ++i) {
			std::string* key = static_cast<std::string*>(keys->At(i));
			cmd.add(*key);
		}
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	bool smove(const std::string& source, const std::string& destination, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("SMOVE", source, destination, member), result);
		return result > 0;
	}

	int64_t publish(const std::string& channel, const std::string& message) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("PUBLISH", channel, message), result);
		return result;
	}

	int64_t zadd(const std::string& key, double score, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("ZADD", key, score, member), result);
		return result;
	}

	int64_t zcard(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("ZCARD", key), result);
		return result;
	}

	int64_t zcount(const std::string& key, double min, double max) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("ZCOUNT", key, min, max), result);
		return result;
	}

	double zincrby(const std::string& key, double increment, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0.0;
		}
		BulkString result;
		if (execute_command(make_command("ZINCRBY", key, increment, member), result) && !result.isNull())
			return std::stod(result.value());
		return 0.0;
	}

	CScriptArray* zrange(const std::string& key, int64_t start, int64_t stop, bool withscores = false) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array cmd = make_command("ZRANGE", key, start, stop);
		if (withscores)
			cmd.add("WITHSCORES");
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	CScriptArray* zrevrange(const std::string& key, int64_t start, int64_t stop, bool withscores = false) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array cmd = make_command("ZREVRANGE", key, start, stop);
		if (withscores)
			cmd.add("WITHSCORES");
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	int64_t zrank(const std::string& key, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return -1;
		}
		Int64 result;
		if (execute_command(make_command("ZRANK", key, member), result))
			return result;
		return -1;
	}

	int64_t zrevrank(const std::string& key, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return -1;
		}
		Int64 result;
		if (execute_command(make_command("ZREVRANK", key, member), result))
			return result;
		return -1;
	}

	int64_t zrem(const std::string& key, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("ZREM", key, member), result);
		return result;
	}

	double zscore(const std::string& key, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0.0;
		}
		BulkString result;
		if (execute_command(make_command("ZSCORE", key, member), result) && !result.isNull())
			return std::stod(result.value());
		return 0.0;
	}

	CScriptArray* zrangebyscore(const std::string& key, double min, double max, bool withscores = false, int64_t offset = -1, int64_t count = -1) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array cmd = make_command("ZRANGEBYSCORE", key, min, max);
		if (withscores)
			cmd.add("WITHSCORES");
		if (offset >= 0 && count >= 0)
			cmd.add("LIMIT").add(NumberFormatter::format(offset)).add(NumberFormatter::format(count));
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString bs = reply.get<BulkString>(i);
				if (!bs.isNull()) {
					std::string str = bs.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	int64_t zremrangebyrank(const std::string& key, int64_t start, int64_t stop) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("ZREMRANGEBYRANK", key, start, stop), result);
		return result;
	}

	int64_t zremrangebyscore(const std::string& key, double min, double max) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("ZREMRANGEBYSCORE", key, min, max), result);
		return result;
	}

	bool setbit(const std::string& key, int64_t offset, bool value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("SETBIT", key, offset, value ? 1 : 0), result);
		return result > 0;
	}

	bool getbit(const std::string& key, int64_t offset) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("GETBIT", key, offset), result);
		return result > 0;
	}

	int64_t bitcount(const std::string& key, int64_t start = -1, int64_t end = -1) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		if (start == -1 || end == -1)
			execute_command(make_command("BITCOUNT", key), result);
		else
			execute_command(make_command("BITCOUNT", key, start, end), result);
		return result;
	}

	int64_t bitop(const std::string& operation, const std::string& destkey, CScriptArray* keys) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		if (!keys || keys->GetSize() == 0) {
			m_last_error = "No keys provided";
			return 0;
		}
		Array cmd;
		cmd.add("BITOP").add(operation).add(destkey);
		for (uint32_t i = 0; i < keys->GetSize(); ++i) {
			std::string* key = static_cast<std::string*>(keys->At(i));
			cmd.add(*key);
		}
		Int64 result;
		execute_command(cmd, result);
		return result;
	}

	int64_t bitpos(const std::string& key, bool bit, int64_t start = -1, int64_t end = -1) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return -1;
		}
		Int64 result;
		if (start == -1 || end == -1)
			execute_command(make_command("BITPOS", key, bit ? 1 : 0), result);
		else
			execute_command(make_command("BITPOS", key, bit ? 1 : 0, start, end), result);
		return result;
	}

	std::string info(const std::string& section = "") {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (section.empty()) {
			if (execute_command(make_command("INFO"), reply) && !reply.isNull())
				return reply.value();
		} else {
			if (execute_command(make_command("INFO", section), reply) && !reply.isNull())
				return reply.value();
		}
		return "";
	}

	int64_t dbsize() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("DBSIZE"), result);
		return result;
	}

	bool select(int64_t index) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		if (execute_command(make_command("SELECT", index), reply) && reply == "OK") {
			m_database = index;
			return true;
		}
		return false;
	}

	bool flushdb() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("FLUSHDB"), reply) && reply == "OK";
	}

	bool flushall() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("FLUSHALL"), reply) && reply == "OK";
	}

	int64_t lastsave() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("LASTSAVE"), result);
		return result;
	}

	bool save() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("SAVE"), reply) && reply == "OK";
	}

	bool bgsave() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		if (execute_command(make_command("BGSAVE"), reply))
			return reply.find("Background saving started") != std::string::npos || reply == "OK";
		return false;
	}

	bool bgrewriteaof() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		if (execute_command(make_command("BGREWRITEAOF"), reply))
			return reply.find("Background append only file rewriting started") != std::string::npos || reply == "OK";
		return false;
	}

	bool multi() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("MULTI"), reply) && reply == "OK";
	}

	redis_value* exec() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return nullptr;
		}
		return execute_command_value(make_command("EXEC"));
	}

	bool discard() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("DISCARD"), reply) && reply == "OK";
	}

	bool watch(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("WATCH", key), reply) && reply == "OK";
	}

	bool watch(CScriptArray* keys) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		if (!keys || keys->GetSize() == 0) {
			m_last_error = "No keys to watch";
			return false;
		}
		Array cmd;
		cmd.add("WATCH");
		for (uint32_t i = 0; i < keys->GetSize(); ++i) {
			std::string* key = static_cast<std::string*>(keys->At(i));
			cmd.add(*key);
		}
		std::string reply;
		return execute_command(cmd, reply) && reply == "OK";
	}

	bool unwatch() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("UNWATCH"), reply) && reply == "OK";
	}

	redis_value* eval(const std::string& script, CScriptArray* keys = nullptr, CScriptArray* args = nullptr) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return nullptr;
		}
		Array cmd;
		cmd.add("EVAL");
		cmd.add(script);
		cmd.add(NumberFormatter::format(keys ? keys->GetSize() : 0));
		// Add keys
		if (keys) {
			for (uint32_t i = 0; i < keys->GetSize(); ++i) {
				std::string* key = static_cast<std::string*>(keys->At(i));
				cmd.add(*key);
			}
		}
		// Add args
		if (args) {
			for (uint32_t i = 0; i < args->GetSize(); ++i) {
				std::string* arg = static_cast<std::string*>(args->At(i));
				cmd.add(*arg);
			}
		}
		return execute_command_value(cmd);
	}

	redis_value* evalsha(const std::string& sha1, CScriptArray* keys = nullptr, CScriptArray* args = nullptr) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return nullptr;
		}
		Array cmd;
		cmd.add("EVALSHA");
		cmd.add(sha1);
		cmd.add(NumberFormatter::format(keys ? keys->GetSize() : 0));
		// Add keys
		if (keys) {
			for (uint32_t i = 0; i < keys->GetSize(); ++i) {
				std::string* key = static_cast<std::string*>(keys->At(i));
				cmd.add(*key);
			}
		}
		// Add args
		if (args) {
			for (uint32_t i = 0; i < args->GetSize(); ++i) {
				std::string* arg = static_cast<std::string*>(args->At(i));
				cmd.add(*arg);
			}
		}
		return execute_command_value(cmd);
	}

	std::string script_load(const std::string& script) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("SCRIPT", "LOAD", script), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	bool script_exists(const std::string& sha1) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Array reply;
		if (execute_command(make_command("SCRIPT", "EXISTS", sha1), reply) && reply.size() > 0) {
			Int64 exists = reply.get<Int64>(0);
			return exists > 0;
		}
		return false;
	}

	bool script_flush() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("SCRIPT", "FLUSH"), reply) && reply == "OK";
	}

	int64_t geoadd(const std::string& key, double longitude, double latitude, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("GEOADD", key, longitude, latitude, member), result);
		return result;
	}

	CScriptArray* geopos(const std::string& key, CScriptArray* members) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<array<double>@>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		if (!members || members->GetSize() == 0)
			return result;
		Array cmd;
		cmd.add("GEOPOS").add(key);
		for (uint32_t i = 0; i < members->GetSize(); ++i) {
			std::string* member = static_cast<std::string*>(members->At(i));
			cmd.add(*member);
		}
		Array reply;
		if (execute_command(cmd, reply)) {
			asITypeInfo* doubleArrayType = engine->GetTypeInfoByDecl("array<double>");
			for (size_t i = 0; i < reply.size(); ++i) {
				CScriptArray* coords = CScriptArray::Create(doubleArrayType);
				try {
					Array pos = reply.get<Array>(i);
					if (pos.size() >= 2) {
						BulkString lon = pos.get<BulkString>(0);
						BulkString lat = pos.get<BulkString>(1);
						if (!lon.isNull() && !lat.isNull()) {
							double lon_val = std::stod(lon.value());
							double lat_val = std::stod(lat.value());
							coords->InsertLast(&lon_val);
							coords->InsertLast(&lat_val);
						}
					}
				} catch (...) {
					// Member not found or null, add empty array
				}
				result->InsertLast(&coords);
				coords->Release();
			}
		}
		return result;
	}

	double geodist(const std::string& key, const std::string& member1, const std::string& member2, const std::string& unit = "m") {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return -1.0;
		}
		BulkString reply;
		if (execute_command(make_command("GEODIST", key, member1, member2, unit), reply) && !reply.isNull())
			return std::stod(reply.value());
		return -1.0;
	}

	CScriptArray* georadius(const std::string& key, double longitude, double latitude, double radius, const std::string& unit, bool withcoord = false, bool withdist = false, bool withhash = false, int64_t count = -1) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array cmd = make_command("GEORADIUS", key, longitude, latitude, radius, unit);
		if (withcoord) cmd.add("WITHCOORD");
		if (withdist) cmd.add("WITHDIST");
		if (withhash) cmd.add("WITHHASH");
		if (count > 0) cmd.add("COUNT").add(NumberFormatter::format(count));
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				if (withcoord || withdist || withhash) {
					// Complex response, return as JSON-like string
					Array item = reply.get<Array>(i);
					BulkString name = item.get<BulkString>(0);
					if (!name.isNull()) {
						std::string str = name.value();
						result->InsertLast(&str);
					}
				} else {
					// Simple response, just member names
					BulkString member = reply.get<BulkString>(i);
					if (!member.isNull()) {
						std::string str = member.value();
						result->InsertLast(&str);
					}
				}
			}
		}
		return result;
	}

	CScriptArray* georadiusbymember(const std::string& key, const std::string& member, double radius, const std::string& unit, bool withcoord = false, bool withdist = false, bool withhash = false, int64_t count = -1) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array cmd = make_command("GEORADIUSBYMEMBER", key, member, radius, unit);
		if (withcoord) cmd.add("WITHCOORD");
		if (withdist) cmd.add("WITHDIST");
		if (withhash) cmd.add("WITHHASH");
		if (count > 0) cmd.add("COUNT").add(NumberFormatter::format(count));
		Array reply;
		if (execute_command(cmd, reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				if (withcoord || withdist || withhash) {
					Array item = reply.get<Array>(i);
					BulkString name = item.get<BulkString>(0);
					if (!name.isNull()) {
						std::string str = name.value();
						result->InsertLast(&str);
					}
				} else {
					BulkString member = reply.get<BulkString>(i);
					if (!member.isNull()) {
						std::string str = member.value();
						result->InsertLast(&str);
					}
				}
			}
		}
		return result;
	}

	std::string geohash(const std::string& key, const std::string& member) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		Array reply;
		if (execute_command(make_command("GEOHASH", key, member), reply) && reply.size() > 0) {
			BulkString hash = reply.get<BulkString>(0);
			if (!hash.isNull())
				return hash.value();
		}
		return "";
	}

	bool pfadd(const std::string& key, const std::string& element) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("PFADD", key, element), result);
		return result > 0;
	}

	bool pfadd(const std::string& key, CScriptArray* elements) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		if (!elements || elements->GetSize() == 0)
			return false;
		Array cmd;
		cmd.add("PFADD").add(key);
		for (uint32_t i = 0; i < elements->GetSize(); ++i) {
			std::string* element = static_cast<std::string*>(elements->At(i));
			cmd.add(*element);
		}
		Int64 result;
		execute_command(cmd, result);
		return result > 0;
	}

	int64_t pfcount(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Int64 result;
		execute_command(make_command("PFCOUNT", key), result);
		return result;
	}

	int64_t pfcount(CScriptArray* keys) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		if (!keys || keys->GetSize() == 0)
			return 0;
		Array cmd;
		cmd.add("PFCOUNT");
		for (uint32_t i = 0; i < keys->GetSize(); ++i) {
			std::string* key = static_cast<std::string*>(keys->At(i));
			cmd.add(*key);
		}
		Int64 result;
		execute_command(cmd, result);
		return result;
	}

	bool pfmerge(const std::string& destkey, CScriptArray* sourcekeys) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		if (!sourcekeys || sourcekeys->GetSize() == 0) {
			m_last_error = "No source keys provided";
			return false;
		}
		Array cmd;
		cmd.add("PFMERGE").add(destkey);
		for (uint32_t i = 0; i < sourcekeys->GetSize(); ++i) {
			std::string* key = static_cast<std::string*>(sourcekeys->At(i));
			cmd.add(*key);
		}
		std::string reply;
		return execute_command(cmd, reply) && reply == "OK";
	}

	CScriptArray* scan(int64_t cursor, const std::string& match = "", int64_t count = -1) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		// Build the SCAN command manually with proper string conversion
		// I think this is because poco doesn't have a dedicated type for scan and so the templates crash the program
		Array cmd;
		cmd.add("SCAN");
		cmd.add(NumberFormatter::format(cursor));  // Convert cursor to string
		if (!match.empty()) {
			cmd.add("MATCH");
			cmd.add(match);
		}
		if (count > 0) {
			cmd.add("COUNT");
			cmd.add(NumberFormatter::format(count));  // Convert count to string
		}
		try {
			// Try using sendCommand directly to get the raw response
			RedisType::Ptr reply = ptr->sendCommand(cmd);
			if (!reply) {
				m_last_error = "Null reply from SCAN";
				return result;
			}
			if (reply->type() == RedisType::REDIS_ARRAY) {
				Type<Array>* arr = dynamic_cast<Type<Array>*>(reply.get());
				if (arr && arr->value().size() >= 2) {
					const Array& redisArray = arr->value();
					// First element should be the cursor (as bulk string)
					// Use at() instead of get() to avoid template issues
					if (redisArray.size() > 0) {
						try {
							BulkString cursor_bs = redisArray.get<BulkString>(0);
							if (!cursor_bs.isNull()) {
								std::string cursor_str = cursor_bs.value();
								result->InsertLast(&cursor_str);
							}
						} catch (...) {
							// Cursor might not be a bulk string
							// Figure out if it happens?
						}
					}
					if (redisArray.size() > 1) {
						try {
							Array keys = redisArray.get<Array>(1);
							for (size_t i = 0; i < keys.size(); ++i) {
								try {
									BulkString key_bs = keys.get<BulkString>(i);
									if (!key_bs.isNull()) {
										std::string key_str = key_bs.value();
										result->InsertLast(&key_str);
									}
								} catch (...) {
									// Skip non-string keys
									// Hmm I don't think this happens but to be safe...
								}
							}
						} catch (...) {
							// Second element might not be an array
							// Figure out if it happens?
						}
					}
				}
			} else if (reply->type() == RedisType::REDIS_ERROR) {
				Type<Error>* err = dynamic_cast<Type<Error>*>(reply.get());
				if (err)
					m_last_error = "SCAN error: " + err->value().getMessage();
			}
		} catch (const RedisException& e) {
			m_last_error = e.message();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		} catch (...) {
			m_last_error = "Unknown error in SCAN";
		}
		return result;
	}

	std::string dump(const std::string& key) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("DUMP", key), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	bool restore(const std::string& key, int64_t ttl, const std::string& serialized, bool replace = false) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Array cmd = make_command("RESTORE", key, ttl, serialized);
		if (replace)
			cmd.add("REPLACE");
		std::string reply;
		return execute_command(cmd, reply) && reply == "OK";
	}

	bool migrate(const std::string& host, int port, const std::string& key, int destination_db, int timeout_ms, bool copy = false, bool replace = false) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Array cmd = make_command("MIGRATE", host, NumberFormatter::format(port), key, NumberFormatter::format(destination_db), NumberFormatter::format(timeout_ms));
		if (copy) cmd.add("COPY");
		if (replace) cmd.add("REPLACE");
		std::string reply;
		return execute_command(cmd, reply) && reply == "OK";
	}

	CScriptDictionary* object(const std::string& subcommand, const std::string& key) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		CScriptDictionary* dict = CScriptDictionary::Create(engine);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return dict;
		}
		if (subcommand == "encoding" || subcommand == "idletime" || subcommand == "refcount") {
			if (subcommand == "encoding") {
				BulkString reply;
				if (execute_command(make_command("OBJECT", "ENCODING", key), reply) && !reply.isNull()) {
					std::string val = reply.value();
					dict->Set("encoding", &val, g_StringTypeid);
				}
			} else {
				Int64 reply;
				if (execute_command(make_command("OBJECT", subcommand, key), reply))
					dict->Set(subcommand, &reply, asTYPEID_INT64);
			}
		} else if (subcommand == "freq") {
			Int64 reply;
			if (execute_command(make_command("OBJECT", "FREQ", key), reply))
				dict->Set("freq", &reply, asTYPEID_INT64);
		}
		return dict;
	}

	int64_t memory_usage(const std::string& key, int samples = -1) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return 0;
		}
		Array cmd = make_command("MEMORY", "USAGE", key);
		if (samples > 0)
			cmd.add("SAMPLES").add(NumberFormatter::format(samples));
		Int64 result;
		execute_command(cmd, result);
		return result;
	}

	std::string memory_doctor() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString result;
		if (execute_command(make_command("MEMORY", "DOCTOR"), result) && !result.isNull())
			return result.value();
		return "";
	}

	CScriptDictionary* memory_stats() {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		CScriptDictionary* dict = CScriptDictionary::Create(engine);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return dict;
		}
		redis_value* reply = execute_command_value(make_command("MEMORY", "STATS"));
		if (reply && reply->is_array()) {
			CScriptArray* arr = reply->get_array();
			if (arr) {
				for (uint32_t i = 0; i < arr->GetSize(); i += 2) {
					if (i + 1 < arr->GetSize()) {
						redis_value* key_val = *static_cast<redis_value**>(arr->At(i));
						redis_value* val_val = *static_cast<redis_value**>(arr->At(i + 1));
						if (key_val && val_val) {
							std::string key = key_val->get_string();
							if (val_val->is_integer()) {
								int64_t val = val_val->get_integer();
								dict->Set(key, &val, asTYPEID_INT64);
							} else if (val_val->is_string()) {
								std::string val = val_val->get_string();
								dict->Set(key, &val, g_StringTypeid);
							}
						}
					}
				}
				arr->Release();
			}
			reply->release();
		}
		return dict;
	}

	CScriptDictionary* config_get(const std::string& parameter) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		CScriptDictionary* dict = CScriptDictionary::Create(engine);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return dict;
		}
		Array reply;
		if (execute_command(make_command("CONFIG", "GET", parameter), reply)) {
			// CONFIG GET returns array of [param1, value1, param2, value2, ...]
			for (size_t i = 0; i + 1 < reply.size(); i += 2) {
				BulkString param = reply.get<BulkString>(i);
				BulkString value = reply.get<BulkString>(i + 1);
				if (!param.isNull() && !value.isNull()) {
					std::string val = value.value();
					dict->Set(param.value(), &val, g_StringTypeid);
				}
			}
		}
		return dict;
	}

	bool config_set(const std::string& parameter, const std::string& value) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("CONFIG", "SET", parameter, value), reply) && reply == "OK";
	}

	bool config_rewrite() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("CONFIG", "REWRITE"), reply) && reply == "OK";
	}

	bool config_resetstat() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("CONFIG", "RESETSTAT"), reply) && reply == "OK";
	}

	CScriptArray* client_list() {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		BulkString reply;
		if (execute_command(make_command("CLIENT", "LIST"), reply) && !reply.isNull()) {
			std::string clients = reply.value();
			// Split by newline
			size_t pos = 0;
			while (pos < clients.length()) {
				size_t newline = clients.find('\n', pos);
				if (newline == std::string::npos)
					newline = clients.length();
				std::string client = clients.substr(pos, newline - pos);
				if (!client.empty())
					result->InsertLast(&client);
				pos = newline + 1;
			}
		}
		return result;
	}

	int64_t client_id() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return -1;
		}
		Int64 result;
		execute_command(make_command("CLIENT", "ID"), result);
		return result;
	}

	bool client_setname(const std::string& name) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("CLIENT", "SETNAME", name), reply) && reply == "OK";
	}

	std::string client_getname() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("CLIENT", "GETNAME"), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	bool client_pause(int64_t timeout_ms) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("CLIENT", "PAUSE", timeout_ms), reply) && reply == "OK";
	}

	CScriptArray* acl_list() {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array reply;
		if (execute_command(make_command("ACL", "LIST"), reply)) {
			for (size_t i = 0; i < reply.size(); ++i) {
				BulkString user = reply.get<BulkString>(i);
				if (!user.isNull()) {
					std::string str = user.value();
					result->InsertLast(&str);
				}
			}
		}
		return result;
	}

	std::string acl_whoami() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return "";
		}
		BulkString reply;
		if (execute_command(make_command("ACL", "WHOAMI"), reply) && !reply.isNull())
			return reply.value();
		return "";
	}

	bool acl_setuser(const std::string& username, const std::string& rules) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		std::string reply;
		return execute_command(make_command("ACL", "SETUSER", username, rules), reply) && reply == "OK";
	}

	bool acl_deluser(const std::string& username) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		Int64 result;
		execute_command(make_command("ACL", "DELUSER", username), result);
		return result > 0;
	}

	CScriptArray* acl_getuser(const std::string& username) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!is_connected()) {
			m_last_error = "Not connected";
			return result;
		}
		Array reply;
		if (execute_command(make_command("ACL", "GETUSER", username), reply)) {
			// ACL GETUSER returns an array with field names and values
			for (size_t i = 0; i < reply.size(); ++i) {
				try {
					// Try to get as array first
					Array arr = reply.get<Array>(i);
					std::string combined;
					for (size_t j = 0; j < arr.size(); ++j) {
						BulkString item = arr.get<BulkString>(j);
						if (!item.isNull()) {
							if (j > 0) combined += ",";
							combined += item.value();
						}
					}
					result->InsertLast(&combined);
				} catch (...) {
					// Not an array, try as bulk string
					// Can this happen?
					try {
						BulkString field = reply.get<BulkString>(i);
						if (!field.isNull()) {
							std::string str = field.value();
							result->InsertLast(&str);
						}
					} catch (...) {
						// Skip if neither array nor bulk string
						// Can this happen?
					}
				}
			}
		}
		return result;
	}

	bool pipeline_begin() {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return false;
		}
		m_pipeline_mode = true;
		m_pipeline_commands.clear();
		return true;
	}

	bool pipeline_add(CScriptArray* args) {
		if (!m_pipeline_mode) {
			m_last_error = "Not in pipeline mode";
			return false;
		}
		if (!args || args->GetSize() == 0) {
			m_last_error = "Empty command";
			return false;
		}
		Array cmd;
		for (uint32_t i = 0; i < args->GetSize(); ++i) {
			std::string* str = static_cast<std::string*>(args->At(i));
			cmd.add(*str);
		}
		m_pipeline_commands.push_back(cmd);
		return true;
	}

	CScriptArray* pipeline_execute() {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<redis_value@>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		if (!m_pipeline_mode) {
			m_last_error = "Not in pipeline mode";
			return result;
		}
		if (!is_connected()) {
			m_last_error = "Not connected";
			m_pipeline_mode = false;
			m_pipeline_commands.clear();
			return result;
		}
		try {
			// Execute each command and collect results
			// Note: Poco Redis doesn't have true pipelining support, so we simulate it
			// by executing commands in sequence but collecting all results before returning.
			// This seems redundant, so we'll probably remove if we can't figure out a meaningful difference between this and transactions
			for (const auto& cmd : m_pipeline_commands) {
				try {
					RedisType::Ptr reply = ptr->sendCommand(cmd);
					redis_value* val = new redis_value(reply);
					result->InsertLast(&val);
					val->release();
				} catch (const RedisException& e) {
					RedisType::Ptr errorReply = new Type<Error>(Error(e.message()));
					redis_value* val = new redis_value(errorReply);
					result->InsertLast(&val);
					val->release();
				}
			}
			m_pipeline_mode = false;
			m_pipeline_commands.clear();
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			m_pipeline_mode = false;
			m_pipeline_commands.clear();
		}
		return result;
	}

	redis_value* execute(CScriptArray* args) {
		if (!is_connected()) {
			m_last_error = "Not connected";
			return nullptr;
		}
		if (!args || args->GetSize() == 0) {
			m_last_error = "Empty command";
			return nullptr;
		}
		Array cmd;
		for (uint32_t i = 0; i < args->GetSize(); ++i) {
			std::string* str = static_cast<std::string*>(args->At(i));
			cmd.add(*str);
		}
		return execute_command_value(cmd);
	}
};

// Blocking subscriber implementation
class blocking_redis_subscriber : public plugin_refcounted<Client>, public Runnable {
private:
	Thread m_thread;
	Event m_stop_event;
	std::string m_host;
	int m_port;
	std::string m_password;
	std::string m_last_error;
	std::vector<std::string> m_channels;
	std::unordered_map<std::string, std::vector<std::string>> m_messages;
	Mutex m_messages_mutex;
	bool m_running;

public:
	blocking_redis_subscriber() : plugin_refcounted(new Client()), m_host("localhost"), m_port(6379), m_running(false) {}
	blocking_redis_subscriber(blocking_redis_subscriber* other) : plugin_refcounted(other->shared),
		m_host(other->m_host),
		m_port(other->m_port),
		m_password(other->m_password),
		m_running(false) {}

	blocking_redis_subscriber& operator = (blocking_redis_subscriber* other) {
		shared = other->shared;
		ptr = shared.get();
		m_host = other->m_host;
		m_port = other->m_port;
		m_password = other->m_password;
		return *this;
	}

	~blocking_redis_subscriber() {
		stop();
	}

	// Reference counting is handled by plugin_refcounted base class

	std::string get_host() const { return m_host; }
	void set_host(const std::string& host) { m_host = host; }

	int get_port() const { return m_port; }
	void set_port(int port) { m_port = port; }

	std::string get_password() const { return m_password; }
	void set_password(const std::string& pwd) { m_password = pwd; }

	std::string get_last_error() const { return m_last_error; }

	bool is_running() const { return m_running; }

	bool subscribe(CScriptArray* channels) {
		if (!channels || channels->GetSize() == 0) {
			m_last_error = "No channels specified";
			return false;
		}
		if (m_running) {
			m_last_error = "Already running";
			return false;
		}
		m_channels.clear();
		for (uint32_t i = 0; i < channels->GetSize(); ++i) {
			std::string* channel = static_cast<std::string*>(channels->At(i));
			m_channels.push_back(*channel);
		}
		m_running = true;
		m_thread.start(*this);
		return true;
	}

	void stop() {
		if (m_running) {
			m_stop_event.set();
			m_thread.join();
			m_running = false;
		}
	}

	CScriptArray* get_messages(const std::string& channel) {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");
		CScriptArray* result = CScriptArray::Create(arrayType);
		Mutex::ScopedLock lock(m_messages_mutex);
		auto it = m_messages.find(channel);
		if (it != m_messages.end()) {
			for (const auto& msg : it->second) {
				std::string copy = msg;
				result->InsertLast(&copy);
			}
			it->second.clear();
		}
		return result;
	}

	bool has_messages(const std::string& channel) {
		Mutex::ScopedLock lock(m_messages_mutex);
		auto it = m_messages.find(channel);
		return it != m_messages.end() && !it->second.empty();
	}

	void run() {
		try {
			Timespan connect_timeout(5 * 1000 * 1000);  // 5 seconds in microseconds
			ptr->connect(m_host, m_port, connect_timeout);
			Timespan receive_timeout(500 * 1000);  // 500ms in microseconds
			ptr->setReceiveTimeout(receive_timeout);
			if (!m_password.empty()) {
				Array cmd;
				cmd.add("AUTH").add(m_password);
				ptr->execute<std::string>(cmd);
			}
			Array cmd;
			cmd.add("SUBSCRIBE");
			for (const auto& channel : m_channels)
				cmd.add(channel);
			ptr->sendCommand(cmd);
			for (size_t i = 0; i < m_channels.size(); ++i) {
				try {
					RedisType::Ptr reply = ptr->readReply();
					// Each subscription confirmation is an array: ["subscribe", channel_name, subscription_count]
					// We don't need to process it, just consume it
				} catch (const Exception& e) {
					m_last_error = "Failed to subscribe: " + e.displayText();
					throw;
				}
			}
			// Read messages with timeout handling
			while (!m_stop_event.tryWait(1)) {
				try {
					RedisType::Ptr reply = ptr->readReply();
					if (reply && reply->isArray()) {
						const Type<Array>* arr = dynamic_cast<const Type<Array>*>(reply.get());
						if (arr && arr->value().size() >= 3) {
							const Array& msg_array = arr->value();
							BulkString type = msg_array.get<BulkString>(0);
							BulkString channel = msg_array.get<BulkString>(1);
							BulkString message = msg_array.get<BulkString>(2);
							if (!type.isNull() && type.value() == "message" &&
							    !channel.isNull() && !message.isNull()) {
								Mutex::ScopedLock lock(m_messages_mutex);
								m_messages[channel.value()].push_back(message.value());
							}
						}
					}
				} catch (const Poco::TimeoutException&) {
					// This is expected - readReply timed out after 500ms
					// Just continue the loop to check stop event
				} catch (const Poco::Net::ConnectionResetException&) {
					// Connection was reset, exit gracefully
					m_last_error = "Connection reset by server";
					break;
				} catch (const Exception& e) {
					// Log error but continue trying
					m_last_error = e.displayText();
				}
			}
			// Clean disconnect only if still connected
			if (ptr->isConnected()) {
				try {
					Array unsub_cmd;
					unsub_cmd.add("UNSUBSCRIBE");
					ptr->execute<void>(unsub_cmd);
					ptr->disconnect();
				} catch (...) {
					// Ignore errors during cleanup
				}
			}
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		} catch (...) {
			m_last_error = "Unknown error in subscriber thread";
		}
	}
};

redis_value* redis_value_factory() {
	return new redis_value(RedisType::Ptr());
}

redis_client* redis_client_factory() {
	return new redis_client();
}

blocking_redis_subscriber* blocking_redis_subscriber_factory() {
	return new blocking_redis_subscriber();
}

void RegisterRedis(asIScriptEngine* engine) {
	engine->RegisterEnum("redis_type");
	engine->RegisterEnumValue("redis_type", "REDIS_TYPE_NONE", 0);
	engine->RegisterEnumValue("redis_type", "REDIS_TYPE_STRING", 1);
	engine->RegisterEnumValue("redis_type", "REDIS_TYPE_LIST", 2);
	engine->RegisterEnumValue("redis_type", "REDIS_TYPE_SET", 3);
	engine->RegisterEnumValue("redis_type", "REDIS_TYPE_ZSET", 4);
	engine->RegisterEnumValue("redis_type", "REDIS_TYPE_HASH", 5);
	engine->RegisterObjectType("redis_value", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("redis_value", asBEHAVE_FACTORY, "redis_value@ f()", asFUNCTION(redis_value_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("redis_value", asBEHAVE_ADDREF, "void f()", asMETHOD(redis_value, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("redis_value", asBEHAVE_RELEASE, "void f()", asMETHOD(redis_value, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_value", "bool get_is_string() const property", asMETHOD(redis_value, is_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_value", "bool get_is_error() const property", asMETHOD(redis_value, is_error), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_value", "bool get_is_integer() const property", asMETHOD(redis_value, is_integer), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_value", "bool get_is_array() const property", asMETHOD(redis_value, is_array), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_value", "bool get_is_nil() const property", asMETHOD(redis_value, is_nil), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_value", "string get_string() const", asMETHOD(redis_value, get_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_value", "int64 get_integer() const", asMETHOD(redis_value, get_integer), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_value", "array<redis_value@>@ get_array() const", asMETHOD(redis_value, get_array), asCALL_THISCALL);
	engine->RegisterObjectType("redis_client", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("redis_client", asBEHAVE_FACTORY, "redis_client@ f()", asFUNCTION(redis_client_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("redis_client", asBEHAVE_ADDREF, "void f()", asMETHOD(redis_client, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("redis_client", asBEHAVE_RELEASE, "void f()", asMETHOD(redis_client, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string get_host() const property", asMETHOD(redis_client, get_host), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "void set_host(const string&in) property", asMETHOD(redis_client, set_host), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int get_port() const property", asMETHOD(redis_client, get_port), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "void set_port(int) property", asMETHOD(redis_client, set_port), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string get_password() const property", asMETHOD(redis_client, get_password), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "void set_password(const string&in) property", asMETHOD(redis_client, set_password), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int get_database() const property", asMETHOD(redis_client, get_database), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "void set_database(int) property", asMETHOD(redis_client, set_database), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int get_timeout() const property", asMETHOD(redis_client, get_timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "void set_timeout(int) property", asMETHOD(redis_client, set_timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string get_last_error() const property", asMETHOD(redis_client, get_last_error), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool get_is_connected() const property", asMETHOD(redis_client, is_connected), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool connect()", asMETHOD(redis_client, connect), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool connect(const string&in, int, const string&in = \"\", int = 0)", asMETHOD(redis_client, connect_ex), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "void disconnect()", asMETHOD(redis_client, disconnect), asCALL_THISCALL);
	// Basic commands
	engine->RegisterObjectMethod("redis_client", "string ping(const string&in = \"\")", asMETHOD(redis_client, ping), asCALL_THISCALL);
	// String operations
	engine->RegisterObjectMethod("redis_client", "bool set(const string&in, const string&in, int64 = 0)", asMETHOD(redis_client, set), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string get(const string&in)", asMETHOD(redis_client, get), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 incr(const string&in)", asMETHOD(redis_client, incr), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 decr(const string&in)", asMETHOD(redis_client, decr), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 incrby(const string&in, int64)", asMETHOD(redis_client, incrby), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 decrby(const string&in, int64)", asMETHOD(redis_client, decrby), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 append(const string&in, const string&in)", asMETHOD(redis_client, append), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 strlen(const string&in)", asMETHOD(redis_client, strlen), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string getrange(const string&in, int64, int64)", asMETHOD(redis_client, getrange), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 setrange(const string&in, int64, const string&in)", asMETHOD(redis_client, setrange), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool setnx(const string&in, const string&in)", asMETHOD(redis_client, setnx), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool setex(const string&in, int64, const string&in)", asMETHOD(redis_client, setex), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool psetex(const string&in, int64, const string&in)", asMETHOD(redis_client, psetex), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ mget(array<string>@)", asMETHOD(redis_client, mget), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool mset(array<string>@)", asMETHODPR(redis_client, mset, (CScriptArray*), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool mset(dictionary@)", asMETHODPR(redis_client, mset, (CScriptDictionary*), bool), asCALL_THISCALL);
	// Key operations
	engine->RegisterObjectMethod("redis_client", "bool exists(const string&in)", asMETHOD(redis_client, exists), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool del(const string&in)", asMETHOD(redis_client, del), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool expire(const string&in, int64)", asMETHOD(redis_client, expire), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 ttl(const string&in)", asMETHOD(redis_client, ttl), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ keys(const string&in)", asMETHOD(redis_client, keys), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string type(const string&in)", asMETHOD(redis_client, type), asCALL_THISCALL);
	// List operations
	engine->RegisterObjectMethod("redis_client", "int64 lpush(const string&in, const string&in)", asMETHOD(redis_client, lpush), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 rpush(const string&in, const string&in)", asMETHOD(redis_client, rpush), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string lpop(const string&in)", asMETHOD(redis_client, lpop), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string rpop(const string&in)", asMETHOD(redis_client, rpop), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 llen(const string&in)", asMETHOD(redis_client, llen), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ lrange(const string&in, int64, int64)", asMETHOD(redis_client, lrange), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string lindex(const string&in, int64)", asMETHOD(redis_client, lindex), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool lset(const string&in, int64, const string&in)", asMETHOD(redis_client, lset), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 lrem(const string&in, int64, const string&in)", asMETHOD(redis_client, lrem), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool ltrim(const string&in, int64, int64)", asMETHOD(redis_client, ltrim), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 linsert(const string&in, const string&in, const string&in, const string&in)", asMETHOD(redis_client, linsert), asCALL_THISCALL);
	// Hash operations
	engine->RegisterObjectMethod("redis_client", "bool hset(const string&in, const string&in, const string&in)", asMETHOD(redis_client, hset), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string hget(const string&in, const string&in)", asMETHOD(redis_client, hget), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool hexists(const string&in, const string&in)", asMETHOD(redis_client, hexists), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 hdel(const string&in, const string&in)", asMETHOD(redis_client, hdel), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 hlen(const string&in)", asMETHOD(redis_client, hlen), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "dictionary@ hgetall(const string&in)", asMETHOD(redis_client, hgetall), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ hkeys(const string&in)", asMETHOD(redis_client, hkeys), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ hvals(const string&in)", asMETHOD(redis_client, hvals), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 hincrby(const string&in, const string&in, int64)", asMETHOD(redis_client, hincrby), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "double hincrbyfloat(const string&in, const string&in, double)", asMETHOD(redis_client, hincrbyfloat), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool hsetnx(const string&in, const string&in, const string&in)", asMETHOD(redis_client, hsetnx), asCALL_THISCALL);
	// Set operations
	engine->RegisterObjectMethod("redis_client", "int64 sadd(const string&in, const string&in)", asMETHODPR(redis_client, sadd, (const std::string&, const std::string&), int64_t), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 sadd(const string&in, array<string>@)", asMETHODPR(redis_client, sadd, (const std::string&, CScriptArray*), int64_t), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 scard(const string&in)", asMETHOD(redis_client, scard), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool sismember(const string&in, const string&in)", asMETHOD(redis_client, sismember), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ smembers(const string&in)", asMETHOD(redis_client, smembers), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 srem(const string&in, const string&in)", asMETHOD(redis_client, srem), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string spop(const string&in)", asMETHOD(redis_client, spop), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string srandmember(const string&in)", asMETHOD(redis_client, srandmember), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ srandmember_count(const string&in, int64)", asMETHOD(redis_client, srandmember_count), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ sunion(array<string>@)", asMETHOD(redis_client, sunion), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ sinter(array<string>@)", asMETHOD(redis_client, sinter), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ sdiff(array<string>@)", asMETHOD(redis_client, sdiff), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool smove(const string&in, const string&in, const string&in)", asMETHOD(redis_client, smove), asCALL_THISCALL);
	// Sorted set operations
	engine->RegisterObjectMethod("redis_client", "int64 zadd(const string&in, double, const string&in)", asMETHOD(redis_client, zadd), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 zcard(const string&in)", asMETHOD(redis_client, zcard), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 zcount(const string&in, double, double)", asMETHOD(redis_client, zcount), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "double zincrby(const string&in, double, const string&in)", asMETHOD(redis_client, zincrby), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ zrange(const string&in, int64, int64, bool = false)", asMETHOD(redis_client, zrange), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ zrevrange(const string&in, int64, int64, bool = false)", asMETHOD(redis_client, zrevrange), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 zrank(const string&in, const string&in)", asMETHOD(redis_client, zrank), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 zrevrank(const string&in, const string&in)", asMETHOD(redis_client, zrevrank), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 zrem(const string&in, const string&in)", asMETHOD(redis_client, zrem), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "double zscore(const string&in, const string&in)", asMETHOD(redis_client, zscore), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ zrangebyscore(const string&in, double, double, bool = false, int64 = -1, int64 = -1)", asMETHOD(redis_client, zrangebyscore), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 zremrangebyrank(const string&in, int64, int64)", asMETHOD(redis_client, zremrangebyrank), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 zremrangebyscore(const string&in, double, double)", asMETHOD(redis_client, zremrangebyscore), asCALL_THISCALL);
	// Bitmap operations
	engine->RegisterObjectMethod("redis_client", "bool setbit(const string&in, int64, bool)", asMETHOD(redis_client, setbit), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool getbit(const string&in, int64)", asMETHOD(redis_client, getbit), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 bitcount(const string&in, int64 = -1, int64 = -1)", asMETHOD(redis_client, bitcount), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 bitop(const string&in, const string&in, array<string>@)", asMETHOD(redis_client, bitop), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 bitpos(const string&in, bool, int64 = -1, int64 = -1)", asMETHOD(redis_client, bitpos), asCALL_THISCALL);
	// Server operations
	engine->RegisterObjectMethod("redis_client", "string info(const string&in = \"\")", asMETHOD(redis_client, info), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 dbsize()", asMETHOD(redis_client, dbsize), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool select(int64)", asMETHOD(redis_client, select), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool flushdb()", asMETHOD(redis_client, flushdb), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool flushall()", asMETHOD(redis_client, flushall), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 lastsave()", asMETHOD(redis_client, lastsave), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool save()", asMETHOD(redis_client, save), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool bgsave()", asMETHOD(redis_client, bgsave), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool bgrewriteaof()", asMETHOD(redis_client, bgrewriteaof), asCALL_THISCALL);
	// Pub/Sub operations
	engine->RegisterObjectMethod("redis_client", "int64 publish(const string&in, const string&in)", asMETHOD(redis_client, publish), asCALL_THISCALL);
	// Transaction operations
	engine->RegisterObjectMethod("redis_client", "bool multi()", asMETHOD(redis_client, multi), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "redis_value@ exec()", asMETHOD(redis_client, exec), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool discard()", asMETHOD(redis_client, discard), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool watch(const string&in)", asMETHODPR(redis_client, watch, (const std::string&), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool watch(array<string>@)", asMETHODPR(redis_client, watch, (CScriptArray*), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool unwatch()", asMETHOD(redis_client, unwatch), asCALL_THISCALL);
	// Lua scripting
	engine->RegisterObjectMethod("redis_client", "redis_value@ eval(const string&in, array<string>@ = null, array<string>@ = null)", asMETHOD(redis_client, eval), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "redis_value@ evalsha(const string&in, array<string>@ = null, array<string>@ = null)", asMETHOD(redis_client, evalsha), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string script_load(const string&in)", asMETHOD(redis_client, script_load), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool script_exists(const string&in)", asMETHOD(redis_client, script_exists), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool script_flush()", asMETHOD(redis_client, script_flush), asCALL_THISCALL);
	// Geospatial commands
	engine->RegisterObjectMethod("redis_client", "int64 geoadd(const string&in, double, double, const string&in)", asMETHOD(redis_client, geoadd), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<array<double>@>@ geopos(const string&in, array<string>@)", asMETHOD(redis_client, geopos), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "double geodist(const string&in, const string&in, const string&in, const string&in = \"m\")", asMETHOD(redis_client, geodist), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ georadius(const string&in, double, double, double, const string&in, bool = false, bool = false, bool = false, int64 = -1)", asMETHOD(redis_client, georadius), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ georadiusbymember(const string&in, const string&in, double, const string&in, bool = false, bool = false, bool = false, int64 = -1)", asMETHOD(redis_client, georadiusbymember), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string geohash(const string&in, const string&in)", asMETHOD(redis_client, geohash), asCALL_THISCALL);
	// HyperLogLog commands
	engine->RegisterObjectMethod("redis_client", "bool pfadd(const string&in, const string&in)", asMETHODPR(redis_client, pfadd, (const std::string&, const std::string&), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool pfadd(const string&in, array<string>@)", asMETHODPR(redis_client, pfadd, (const std::string&, CScriptArray*), bool), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 pfcount(const string&in)", asMETHODPR(redis_client, pfcount, (const std::string&), int64_t), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 pfcount(array<string>@)", asMETHODPR(redis_client, pfcount, (CScriptArray*), int64_t), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool pfmerge(const string&in, array<string>@)", asMETHOD(redis_client, pfmerge), asCALL_THISCALL);
	// Advanced Key Operations
	engine->RegisterObjectMethod("redis_client", "array<string>@ scan(int64, const string&in = \"\", int64 = -1)", asMETHOD(redis_client, scan), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string dump(const string&in)", asMETHOD(redis_client, dump), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool restore(const string&in, int64, const string&in, bool = false)", asMETHOD(redis_client, restore), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool migrate(const string&in, int, const string&in, int, int, bool = false, bool = false)", asMETHOD(redis_client, migrate), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "dictionary@ object(const string&in, const string&in)", asMETHOD(redis_client, object), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 memory_usage(const string&in, int = -1)", asMETHOD(redis_client, memory_usage), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string memory_doctor()", asMETHOD(redis_client, memory_doctor), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "dictionary@ memory_stats()", asMETHOD(redis_client, memory_stats), asCALL_THISCALL);
	// Configuration and connection management
	engine->RegisterObjectMethod("redis_client", "dictionary@ config_get(const string&in)", asMETHOD(redis_client, config_get), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool config_set(const string&in, const string&in)", asMETHOD(redis_client, config_set), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool config_rewrite()", asMETHOD(redis_client, config_rewrite), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool config_resetstat()", asMETHOD(redis_client, config_resetstat), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ client_list()", asMETHOD(redis_client, client_list), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "int64 client_id()", asMETHOD(redis_client, client_id), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool client_setname(const string&in)", asMETHOD(redis_client, client_setname), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string client_getname()", asMETHOD(redis_client, client_getname), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool client_pause(int64)", asMETHOD(redis_client, client_pause), asCALL_THISCALL);
	// ACL commands (Redis 6+)
	engine->RegisterObjectMethod("redis_client", "array<string>@ acl_list()", asMETHOD(redis_client, acl_list), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "string acl_whoami()", asMETHOD(redis_client, acl_whoami), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool acl_setuser(const string&in, const string&in)", asMETHOD(redis_client, acl_setuser), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool acl_deluser(const string&in)", asMETHOD(redis_client, acl_deluser), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<string>@ acl_getuser(const string&in)", asMETHOD(redis_client, acl_getuser), asCALL_THISCALL);
	// Pipelining support
	engine->RegisterObjectMethod("redis_client", "bool pipeline_begin()", asMETHOD(redis_client, pipeline_begin), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "bool pipeline_add(array<string>@)", asMETHOD(redis_client, pipeline_add), asCALL_THISCALL);
	engine->RegisterObjectMethod("redis_client", "array<redis_value@>@ pipeline_execute()", asMETHOD(redis_client, pipeline_execute), asCALL_THISCALL);
	// Generic command execution
	engine->RegisterObjectMethod("redis_client", "redis_value@ execute(array<string>@)", asMETHOD(redis_client, execute), asCALL_THISCALL);
	engine->RegisterObjectType("blocking_redis_subscriber", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("blocking_redis_subscriber", asBEHAVE_FACTORY, "blocking_redis_subscriber@ f()", asFUNCTION(blocking_redis_subscriber_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("blocking_redis_subscriber", asBEHAVE_ADDREF, "void f()", asMETHOD(blocking_redis_subscriber, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("blocking_redis_subscriber", asBEHAVE_RELEASE, "void f()", asMETHOD(blocking_redis_subscriber, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "string get_host() const property", asMETHOD(blocking_redis_subscriber, get_host), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "void set_host(const string&in) property", asMETHOD(blocking_redis_subscriber, set_host), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "int get_port() const property", asMETHOD(blocking_redis_subscriber, get_port), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "void set_port(int) property", asMETHOD(blocking_redis_subscriber, set_port), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "string get_password() const property", asMETHOD(blocking_redis_subscriber, get_password), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "void set_password(const string&in) property", asMETHOD(blocking_redis_subscriber, set_password), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "string get_last_error() const property", asMETHOD(blocking_redis_subscriber, get_last_error), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "bool get_is_running() const property", asMETHOD(blocking_redis_subscriber, is_running), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "bool subscribe(array<string>@)", asMETHOD(blocking_redis_subscriber, subscribe), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "void stop()", asMETHOD(blocking_redis_subscriber, stop), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "array<string>@ get_messages(const string&in)", asMETHOD(blocking_redis_subscriber, get_messages), asCALL_THISCALL);
	engine->RegisterObjectMethod("blocking_redis_subscriber", "bool has_messages(const string&in)", asMETHOD(blocking_redis_subscriber, has_messages), asCALL_THISCALL);
}

plugin_main(nvgt_plugin_shared* shared) {
	if (!shared || !shared->script_engine)
		return false;
	if (!prepare_plugin(shared))
		return false;
	CScriptArray::SetMemoryFunctions(std::malloc, std::free);
	asITypeInfo* stringType = shared->script_engine->GetTypeInfoByDecl("string");
	if (stringType)
		g_StringTypeid = stringType->GetTypeId();
	RegisterRedis(shared->script_engine);
	return true;
}