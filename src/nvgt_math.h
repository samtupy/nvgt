/* nvgt_math.h - shared lightweight math types
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

#pragma once

#include <cmath>
#include <string>

// Plain 3-float vector type used as the AngelScript "vector" type throughout NVGT.
// Kept as a simple POD struct to avoid physics-library dependencies in subsystems that only need 3D math.
struct nvgt_vec3 {
	float x, y, z;
	nvgt_vec3() : x(0), y(0), z(0) {}
	nvgt_vec3(float x, float y, float z) : x(x), y(y), z(z) {}
	void setAllValues(float nx, float ny, float nz) { x = nx; y = ny; z = nz; }
	nvgt_vec3 operator+(const nvgt_vec3& o) const { return nvgt_vec3(x + o.x, y + o.y, z + o.z); }
	nvgt_vec3 operator-(const nvgt_vec3& o) const { return nvgt_vec3(x - o.x, y - o.y, z - o.z); }
	nvgt_vec3 operator*(const nvgt_vec3& o) const { return nvgt_vec3(x * o.x, y * o.y, z * o.z); }
	nvgt_vec3 operator*(float s) const { return nvgt_vec3(x * s, y * s, z * s); }
	nvgt_vec3 operator/(float s) const { return nvgt_vec3(x / s, y / s, z / s); }
	nvgt_vec3 operator-() const { return nvgt_vec3(-x, -y, -z); }
	nvgt_vec3& operator+=(const nvgt_vec3& o) { x += o.x; y += o.y; z += o.z; return *this; }
	nvgt_vec3& operator-=(const nvgt_vec3& o) { x -= o.x; y -= o.y; z -= o.z; return *this; }
	nvgt_vec3& operator*=(float s) { x *= s; y *= s; z *= s; return *this; }
	nvgt_vec3& operator/=(float s) { x /= s; y /= s; z /= s; return *this; }
	bool operator==(const nvgt_vec3& o) const { return x == o.x && y == o.y && z == o.z; }
	bool operator!=(const nvgt_vec3& o) const { return !(*this == o); }
	float length() const { return std::sqrt(x * x + y * y + z * z); }
	float length_sq() const { return x * x + y * y + z * z; }
	float dot(const nvgt_vec3& o) const { return x * o.x + y * o.y + z * o.z; }
	nvgt_vec3 cross(const nvgt_vec3& o) const { return nvgt_vec3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x); }
	nvgt_vec3 normalized() const { float l = length(); return l > 0 ? *this / l : nvgt_vec3(); }
	bool is_normalized(float tol = 1e-6f) const { return std::abs(length_sq() - 1.0f) <= tol; }
	bool is_near_zero(float tol = 1e-6f) const { return length_sq() <= tol * tol; }
	nvgt_vec3 abs() const { return nvgt_vec3(std::abs(x), std::abs(y), std::abs(z)); }
	float reduce_min() const { return x < y ? (x < z ? x : z) : (y < z ? y : z); }
	float reduce_max() const { return x > y ? (x > z ? x : z) : (y > z ? y : z); }
	void set(float nx, float ny, float nz) { x = nx; y = ny; z = nz; }
	std::string to_string() const { return "vector(" + std::to_string(x) + ", " + std::to_string(y) + ", " + std::to_string(z) + ")"; }
	static nvgt_vec3 zero() { return nvgt_vec3(0, 0, 0); }
	static nvgt_vec3 one() { return nvgt_vec3(1, 1, 1); }
	static nvgt_vec3 axis_x() { return nvgt_vec3(1, 0, 0); }
	static nvgt_vec3 axis_y() { return nvgt_vec3(0, 1, 0); }
	static nvgt_vec3 axis_z() { return nvgt_vec3(0, 0, 1); }
};
