/* uuid.h - Poco UUID wrapper for NVGT
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

#include <Poco/SharedPtr.h>
#include <Poco/UUID.h>
#include <Poco/UUIDGenerator.h>
#include <angelscript.h>

#include <string>

// Wrapper class for Poco::UUID using SharedPtr
// Note: We use manual reference counting rather than inheriting from poco_shared<Poco::UUID>
// because UUID objects are lightweight value types that are typically copied rather than shared.
class uuid {
private:
	int m_refcount;

public:
	Poco::SharedPtr<Poco::UUID> m_uuid;

public:
	uuid();
	uuid(Poco::SharedPtr<Poco::UUID> u);
	uuid(const std::string& str);
	uuid(const uuid& other);

	void add_ref();
	void release();

	uuid& operator=(const uuid& other);

	std::string to_string() const;
	std::string str() const {
		return to_string();
	}

	void parse(const std::string& str);
	bool try_parse(const std::string& str);

	int get_version() const;
	int get_variant() const;
	bool is_null() const;

	bool operator==(const uuid& other) const;
	bool operator!=(const uuid& other) const;
	bool operator<(const uuid& other) const;
	bool operator<=(const uuid& other) const;
	bool operator>(const uuid& other) const;
	bool operator>=(const uuid& other) const;

	std::string get_bytes() const;
	void set_bytes(const std::string& bytes);
};

uuid* uuid_factory();
uuid* uuid_factory_string(const std::string& str);

std::string uuid_generate();
std::string uuid_generate_random();
std::string uuid_generate_time();
uuid* uuid_create();
uuid* uuid_create_random();
uuid* uuid_create_time();
uuid* uuid_create_from_name(const uuid& namespace_id, const std::string& name);

uuid* uuid_namespace_dns();
uuid* uuid_namespace_url();
uuid* uuid_namespace_oid();
uuid* uuid_namespace_x500();

void RegisterUUID(asIScriptEngine* engine);