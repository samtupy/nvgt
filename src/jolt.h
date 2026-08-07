/* jolt.h - JoltPhysics wrapper header
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

#define JPH_OBJECT_STREAM
#define JPH_FLOATING_POINT_EXCEPTIONS_ENABLED
#include <Jolt/Jolt.h>
#include <Jolt/Math/Vec3.h>
#include <phonon.h>

// JPH::Vec3 is used as the AngelScript "vector" type throughout NVGT.
// Internal C++ code can use Vec3 by value; only values crossing the AngelScript boundary need new_vec3().
using vector3 = JPH::Vec3;
JPH::Vec3* new_vec3(float x = 0.0f, float y = 0.0f, float z = 0.0f);
inline JPH::Vec3* new_vec3(JPH::Vec3Arg v) { return new_vec3(v.GetX(), v.GetY(), v.GetZ()); }

// Steam Audio custom scene callbacks backed by the Jolt physics world.
// Pass a jolt_physics_world* as the userData when creating an IPL_SCENETYPE_CUSTOM scene.
void IPLCALL jolt_ipl_closest_hit(const IPLRay* ray, IPLfloat32 min_dist, IPLfloat32 max_dist, IPLHit* hit, void* user_data);
void IPLCALL jolt_ipl_any_hit(const IPLRay* ray, IPLfloat32 min_dist, IPLfloat32 max_dist, IPLuint8* occluded, void* user_data);
void IPLCALL jolt_ipl_batched_closest_hit(IPLint32 num_rays, const IPLRay* rays, const IPLfloat32* min_dists, const IPLfloat32* max_dists, IPLHit* hits, void* user_data);
void IPLCALL jolt_ipl_batched_any_hit(IPLint32 num_rays, const IPLRay* rays, const IPLfloat32* min_dists, const IPLfloat32* max_dists, IPLuint8* occluded, void* user_data);

class asIScriptEngine;
void RegisterJolt(asIScriptEngine* engine);
