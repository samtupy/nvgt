/* cppmath.cpp - wrappers for math functions from the c++ standard library
 * This originally started as the stock scriptmath addon from Angelscript before it was significantly added to and improved upon by Ethin P.
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

#include <assert.h>
#include <math.h>
#include <float.h>
#include <string.h>
#include <cmath>
#include <numeric>
#include <version>
#include <bit>
#include <version>
#include <algorithm>
#include <cstdint>
#include <memory>
#include <limits>
#include "cppmath.h"
template< class T >
constexpr int bit_width( T x ) noexcept {
	return std::numeric_limits<T>::digits - std::countl_zero(x);
}

struct floating_point_characteristics;

static std::unique_ptr<floating_point_characteristics> fp_characteristics = nullptr;

struct floating_point_characteristics {
	struct {
		int ibeta;
		int it;
		int machep;
		float eps;
		int negep;
		float epsneg;
		int iexp;
		int minexp;
		float xmin;
		int maxexp;
		float xmax;
		int irnd;
		int ngrd;
	} flt;
	struct {
		int ibeta;
		int it;
		int machep;
		double eps;
		int negep;
		double epsneg;
		int iexp;
		int minexp;
		double xmin;
		int maxexp;
		double xmax;
		int irnd;
		int ngrd;
	} dbl;
};

void compute_fp_characteristics() {
	if (fp_characteristics) return;
	fp_characteristics = std::make_unique<floating_point_characteristics>();
	{ // float
		int i, itemp, iz, j, k, mx, nxres;
		float a, b, beta, betah, betain, t, temp, temp1, tempa, zero, one, two, y, z;
		one = 1.0f;
		two = one + one;
		zero = one - one;
		a = one;
		do {
			a += a;
			temp = a + one;
			temp1 = temp - a;
		} while (temp1 - one == zero);
		b = one;
		do {
			b += b;
			temp = a + b;
			itemp = static_cast<int>(temp - a);
		} while (itemp == 0);
		fp_characteristics->flt.ibeta = itemp;
		beta = fp_characteristics->flt.ibeta;
		fp_characteristics->flt.it = 0;
		b = one;
		do {
			fp_characteristics->flt.it++;
			b *= beta;
			temp = b + one;
			temp1 = temp - b;
		} while (temp1 - one == zero);
		fp_characteristics->flt.irnd = 0;
		betah = beta / two;
		temp = a + betah;
		if (temp - a != zero) {
			fp_characteristics->flt.irnd = 1;
		}
		tempa = a + beta;
		temp = tempa + betah;
		if (fp_characteristics->flt.irnd == 0 && temp - tempa != zero) {
			fp_characteristics->flt.irnd = 2;
		}
		fp_characteristics->flt.negep = fp_characteristics->flt.it + 3;
		betain = one / beta;
		a = one;
		for (i = 1; i <= fp_characteristics->flt.negep; i++) {
			a *= betain;
		}
		b = a;
		while (true) {
			temp = one - a;
			if (temp - one != zero) {
				break;
			}
			a *= beta;
			fp_characteristics->flt.negep--;
		}
		fp_characteristics->flt.negep = -fp_characteristics->flt.negep;
		fp_characteristics->flt.epsneg = a;
		fp_characteristics->flt.machep = -fp_characteristics->flt.it - 3;
		a = b;
		while (true) {
			temp = one + a;
			if (temp - one != zero) {
				break;
			}
			a *= beta;
			fp_characteristics->flt.machep++;
		}
		fp_characteristics->flt.eps = a;
		fp_characteristics->flt.ngrd = 0;
		temp = one + fp_characteristics->flt.eps;
		if (fp_characteristics->flt.irnd == 0 && temp * one - one != zero) {
			fp_characteristics->flt.ngrd = 1;
		}
		i = 0;
		k = 1;
		z = betain;
		t = one + fp_characteristics->flt.eps;
		nxres = 0;
		while (true) {
			y = z;
			z = y * y;
			a = z * one;
			temp = z * t;
			if (a + a == zero || std::abs(z) >= y) {
				break;
			}
			temp1 = temp * betain;
			if (temp1 * beta == z) {
				break;
			}
			i++;
			k += k;
		}
		if (fp_characteristics->flt.ibeta != 10) {
			fp_characteristics->flt.iexp = i + 1;
			mx = k + k;
		} else {
			fp_characteristics->flt.iexp = 2;
			iz = fp_characteristics->flt.ibeta;
			while (k >= iz) {
				iz *= fp_characteristics->flt.ibeta;
				fp_characteristics->flt.iexp++;
			}
			mx = iz + iz - 1;
		}
		while (true) {
			fp_characteristics->flt.xmin = y;
			y = y * betain;
			a = y * one;
			temp = y * t;
			if (a + a != zero && std::abs(y) < fp_characteristics->flt.xmin) {
				k++;
				temp1 = temp * betain;
				if (temp1 * beta == y && temp != y) {
					nxres = 3;
					fp_characteristics->flt.xmin = y;
					break;
				}
			} else {
				break;
			}
		}
		fp_characteristics->flt.minexp = -k;
		if (mx <= k + k - 3 && fp_characteristics->flt.ibeta != 10) {
			mx = mx + mx;
			fp_characteristics->flt.iexp++;
		}
		fp_characteristics->flt.maxexp = mx + fp_characteristics->flt.minexp;
		fp_characteristics->flt.irnd = fp_characteristics->flt.irnd + nxres;
		if (fp_characteristics->flt.irnd >= 2) {
			fp_characteristics->flt.maxexp = fp_characteristics->flt.maxexp - 2;
		}
		i = fp_characteristics->flt.maxexp + fp_characteristics->flt.minexp;
		if (fp_characteristics->flt.ibeta == 2 && i == 0) {
			fp_characteristics->flt.maxexp = fp_characteristics->flt.maxexp - 1;
		}
		if (i > 20) {
			fp_characteristics->flt.maxexp = fp_characteristics->flt.maxexp - 1;
		}
		if (a != y) {
			fp_characteristics->flt.maxexp = fp_characteristics->flt.maxexp - 2;
		}
		fp_characteristics->flt.xmax = one - fp_characteristics->flt.epsneg;
		if (fp_characteristics->flt.xmax * one != fp_characteristics->flt.xmax) {
			fp_characteristics->flt.xmax = one - beta * fp_characteristics->flt.epsneg;
		}
		fp_characteristics->flt.xmax /= fp_characteristics->flt.xmin * beta * beta * beta;
		i = fp_characteristics->flt.maxexp + fp_characteristics->flt.minexp + 3;
		for (j = 1; j <= i; j++) {
			if (fp_characteristics->flt.ibeta == 2) {
				fp_characteristics->flt.xmax += fp_characteristics->flt.xmax;
			} else {
				fp_characteristics->flt.xmax *= beta;
			}
		}
	}
	{ // double
		int i, itemp, iz, j, k, mx, nxres;
		double a, b, beta, betah, betain, t, temp, temp1, tempa, zero, one, two, y, z;
		one = 1.0f;
		two = one + one;
		zero = one - one;
		a = one;
		do {
			a += a;
			temp = a + one;
			temp1 = temp - a;
		} while (temp1 - one == zero);
		b = one;
		do {
			b += b;
			temp = a + b;
			itemp = static_cast<int>(temp - a);
		} while (itemp == 0);
		fp_characteristics->dbl.ibeta = itemp;
		beta = fp_characteristics->dbl.ibeta;
		fp_characteristics->dbl.it = 0;
		b = one;
		do {
			fp_characteristics->dbl.it++;
			b *= beta;
			temp = b + one;
			temp1 = temp - b;
		} while (temp1 - one == zero);
		fp_characteristics->dbl.irnd = 0;
		betah = beta / two;
		temp = a + betah;
		if (temp - a != zero) {
			fp_characteristics->dbl.irnd = 1;
		}
		tempa = a + beta;
		temp = tempa + betah;
		if (fp_characteristics->dbl.irnd == 0 && temp - tempa != zero) {
			fp_characteristics->dbl.irnd = 2;
		}
		fp_characteristics->dbl.negep = fp_characteristics->dbl.it + 3;
		betain = one / beta;
		a = one;
		for (i = 1; i <= fp_characteristics->dbl.negep; i++) {
			a *= betain;
		}
		b = a;
		while (true) {
			temp = one - a;
			if (temp - one != zero) {
				break;
			}
			a *= beta;
			fp_characteristics->dbl.negep--;
		}
		fp_characteristics->dbl.negep = -fp_characteristics->dbl.negep;
		fp_characteristics->dbl.epsneg = a;
		fp_characteristics->dbl.machep = -fp_characteristics->dbl.it - 3;
		a = b;
		while (true) {
			temp = one + a;
			if (temp - one != zero) {
				break;
			}
			a *= beta;
			fp_characteristics->dbl.machep++;
		}
		fp_characteristics->dbl.eps = a;
		fp_characteristics->dbl.ngrd = 0;
		temp = one + fp_characteristics->dbl.eps;
		if (fp_characteristics->dbl.irnd == 0 && temp * one - one != zero) {
			fp_characteristics->dbl.ngrd = 1;
		}
		i = 0;
		k = 1;
		z = betain;
		t = one + fp_characteristics->dbl.eps;
		nxres = 0;
		while (true) {
			y = z;
			z = y * y;
			a = z * one;
			temp = z * t;
			if (a + a == zero || std::abs(z) >= y) {
				break;
			}
			temp1 = temp * betain;
			if (temp1 * beta == z) {
				break;
			}
			i++;
			k += k;
		}
		if (fp_characteristics->dbl.ibeta != 10) {
			fp_characteristics->dbl.iexp = i + 1;
			mx = k + k;
		} else {
			fp_characteristics->dbl.iexp = 2;
			iz = fp_characteristics->dbl.ibeta;
			while (k >= iz) {
				iz *= fp_characteristics->dbl.ibeta;
				fp_characteristics->dbl.iexp++;
			}
			mx = iz + iz - 1;
		}
		while (true) {
			fp_characteristics->dbl.xmin = y;
			y = y * betain;
			a = y * one;
			temp = y * t;
			if (a + a != zero && std::abs(y) < fp_characteristics->dbl.xmin) {
				k++;
				temp1 = temp * betain;
				if (temp1 * beta == y && temp != y) {
					nxres = 3;
					fp_characteristics->dbl.xmin = y;
					break;
				}
			} else {
				break;
			}
		}
		fp_characteristics->dbl.minexp = -k;
		if (mx <= k + k - 3 && fp_characteristics->dbl.ibeta != 10) {
			mx = mx + mx;
			fp_characteristics->dbl.iexp++;
		}
		fp_characteristics->dbl.maxexp = mx + fp_characteristics->dbl.minexp;
		fp_characteristics->dbl.irnd = fp_characteristics->dbl.irnd + nxres;
		if (fp_characteristics->dbl.irnd >= 2) {
			fp_characteristics->dbl.maxexp = fp_characteristics->dbl.maxexp - 2;
		}
		i = fp_characteristics->dbl.maxexp + fp_characteristics->dbl.minexp;
		if (fp_characteristics->dbl.ibeta == 2 && i == 0) {
			fp_characteristics->dbl.maxexp = fp_characteristics->dbl.maxexp - 1;
		}
		if (i > 20) {
			fp_characteristics->dbl.maxexp = fp_characteristics->dbl.maxexp - 1;
		}
		if (a != y) {
			fp_characteristics->dbl.maxexp = fp_characteristics->dbl.maxexp - 2;
		}
		fp_characteristics->dbl.xmax = one - fp_characteristics->dbl.epsneg;
		if (fp_characteristics->dbl.xmax * one != fp_characteristics->dbl.xmax) {
			fp_characteristics->dbl.xmax = one - beta * fp_characteristics->dbl.epsneg;
		}
		fp_characteristics->dbl.xmax /= fp_characteristics->dbl.xmin * beta * beta * beta;
		i = fp_characteristics->dbl.maxexp + fp_characteristics->dbl.minexp + 3;
		for (j = 1; j <= i; j++) {
			if (fp_characteristics->dbl.ibeta == 2) {
				fp_characteristics->dbl.xmax += fp_characteristics->dbl.xmax;
			} else {
				fp_characteristics->dbl.xmax *= beta;
			}
		}
	}
}

// As AngelScript doesn't allow bitwise manipulation of float types we'll provide a couple of
// functions for converting float values to IEEE 754 formatted values etc. This also allow us to 
// provide a platform agnostic representation to the script so the scripts don't have to worry
// about whether the CPU uses IEEE 754 floats or some other representation
float fpFromIEEE(asUINT raw)
{
	// TODO: Identify CPU family to provide proper conversion
	//        if the CPU doesn't natively use IEEE style floats
	return *(reinterpret_cast<float*>(&raw));
}
asUINT fpToIEEE(float fp)
{
	return *(reinterpret_cast<asUINT*>(&fp));
}
double fpFromIEEE(asQWORD raw)
{
	return *(reinterpret_cast<double*>(&raw));
}
asQWORD fpToIEEE(double fp)
{
	return *(reinterpret_cast<asQWORD*>(&fp));
}

// closeTo() is used to determine if the binary representation of two numbers are 
// relatively close to each other. Numerical errors due to rounding errors build
// up over many operations, so it is almost impossible to get exact numbers and
// this is where closeTo() comes in.
//
// It shouldn't be used to determine if two numbers are mathematically close to 
// each other.
//
// ref: http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm
// ref: http://www.gamedev.net/topic/653449-scriptmath-and-closeto/
bool closeTo(float a, float b, float epsilon)
{
	// Equal numbers and infinity will return immediately
	if( a == b ) return true;

	// When very close to 0, we can use the absolute comparison
	float diff = std::abs(a - b);
	if( (a == 0 || b == 0) && (diff < epsilon) )
		return true;
	
	// Otherwise we need to use relative comparison to account for precision
	return diff / (std::abs(a) + std::abs(b)) < epsilon;
}

bool closeTo(double a, double b, double epsilon)
{
	if( a == b ) return true;

	double diff = std::abs(a - b);
	if( (a == 0 || b == 0) && (diff < epsilon) )
		return true;
	
	return diff / (std::abs(a) + std::abs(b)) < epsilon;
}

void RegisterScriptMath(asIScriptEngine *engine)
{
	compute_fp_characteristics();
	using int8 = std::int8_t;
	using int16 = std::int16_t;
	using int32 = std::int32_t;
	using int64 = std::int64_t;
	using uint8 = std::uint8_t;
	using uint16 = std::uint16_t;
	using uint32 = std::uint32_t;
	using uint64 = std::uint64_t;
	// Conversion between floating point and IEEE bits representations
	engine->RegisterGlobalFunction("float fp_from_IEEE(uint)", asFUNCTIONPR(fpFromIEEE, (asUINT), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint fp_to_IEEE(float)", asFUNCTIONPR(fpToIEEE, (float), asUINT), asCALL_CDECL);
	engine->RegisterGlobalFunction("double fpFromIEEE(uint64)", asFUNCTIONPR(fpFromIEEE, (asQWORD), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("uint64 fpToIEEE(double)", asFUNCTIONPR(fpToIEEE, (double), asQWORD), asCALL_CDECL);

	// Close to comparison with epsilon 
	engine->RegisterGlobalFunction("bool close_to(float, float, float = 0.00001f)", asFUNCTIONPR(closeTo, (float, float, float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool close_to(double, double, double = 0.0000000001)", asFUNCTIONPR(closeTo, (double, double, double), bool), asCALL_CDECL);

	// Mathematical functions
	engine->RegisterGlobalFunction("float absf(float v)", asFUNCTIONPR(std::abs, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float fmod(float a, float b)", asFUNCTIONPR(std::fmod, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float remainder(float a, float b)", asFUNCTIONPR(std::remainder, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float remquo(float a, float b, int& out quo)", asFUNCTIONPR(std::remquo, (float, float, int*), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float fma(float a, float b, float c)", asFUNCTIONPR(std::fma, (float, float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float fmax(float a, float b)", asFUNCTIONPR(std::fmax, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float fmin(float a, float b)", asFUNCTIONPR(std::fmin, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float fdim(float a, float b)", asFUNCTIONPR(std::fdim, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float lerp(float a, float b, float c)", asFUNCTIONPR(std::lerp, (float, float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float exp(float a)", asFUNCTIONPR(std::exp, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float exp2(float a)", asFUNCTIONPR(std::exp2, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float expm1(float a)", asFUNCTIONPR(std::expm1, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float logf(float a)", asFUNCTIONPR(std::log, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float log10(float a)", asFUNCTIONPR(std::log10, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float log2(float a)", asFUNCTIONPR(std::log2, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float log1p(float a)", asFUNCTIONPR(std::log1p, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float powf(float a, float b)", asFUNCTIONPR(std::pow, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float sqrtf(float a)", asFUNCTIONPR(std::sqrt, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float cbrt(float a)", asFUNCTIONPR(std::cbrt, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float hypot(float a, float b)", asFUNCTIONPR(std::hypot, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float hypot(float a, float b, float c)", asFUNCTIONPR(std::hypot, (float, float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float sinf(float x)", asFUNCTIONPR(std::sin, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float cosf(float x)", asFUNCTIONPR(std::cos, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float tanf(float x)", asFUNCTIONPR(std::tan, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float asinf(float x)", asFUNCTIONPR(std::asin, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float acosf(float x)", asFUNCTIONPR(std::acos, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float atanf(float x)", asFUNCTIONPR(std::atan, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float atan2f(float y, float x)", asFUNCTIONPR(std::atan2, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float sinh(float x)", asFUNCTIONPR(std::sinh, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float cosh(float x)", asFUNCTIONPR(std::cosh, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float tanh(float x)", asFUNCTIONPR(std::tanh, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float asinh(float x)", asFUNCTIONPR(std::asinh, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float acosh(float x)", asFUNCTIONPR(std::acosh, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float atanh(float x)", asFUNCTIONPR(std::atanh, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float erf(float x)", asFUNCTIONPR(std::erf, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float erfc(float x)", asFUNCTIONPR(std::erfc, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float calculate_gamma(float x)", asFUNCTIONPR(std::tgamma, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float calculate_lgamma(float x)", asFUNCTIONPR(std::lgamma, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float ceilf(float x)", asFUNCTIONPR(std::ceil, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float floorf(float x)", asFUNCTIONPR(std::floor, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float trunc(float x)", asFUNCTIONPR(std::trunc, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float nearbyint(float x)", asFUNCTIONPR(std::nearbyint, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float rint(float x)", asFUNCTIONPR(std::rint, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float frexp(float x, int& out exp)", asFUNCTIONPR(std::frexp, (float, int*), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float ldexp(float x, int exp)", asFUNCTIONPR(std::ldexp, (float, int), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float modf(float num, float& out iptr)", asFUNCTIONPR(std::modf, (float, float*), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float scalbn(float x, int exp)", asFUNCTIONPR(std::scalbn, (float, int), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float scalbn(float x, int64 exp)", asFUNCTIONPR(std::scalbln, (float, long), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("int ilogb(float x)", asFUNCTIONPR(std::ilogb, (float), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("float logb(float x)", asFUNCTIONPR(std::logb, (float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float nextafter(float from, float to)", asFUNCTIONPR(std::nextafter, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float nexttoward(float from, double to)", asFUNCTIONPR(std::nexttoward, (float, long double), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("float copysign(float mag, float sgn)", asFUNCTIONPR(std::copysign, (float, float), float), asCALL_CDECL);
	engine->RegisterGlobalFunction("int fpclassify(float x)", asFUNCTIONPR(std::fpclassify, (float), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_finite(float x)", asFUNCTIONPR(std::isfinite, (float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_inf(float x)", asFUNCTIONPR(std::isinf, (float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_nan(float x)", asFUNCTIONPR(std::isnan, (float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_normal(float x)", asFUNCTIONPR(std::isnormal, (float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_negative(float x)", asFUNCTIONPR(std::signbit, (float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_greater(float x, float y)", asFUNCTIONPR(std::isgreater, (float, float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_greater_equal(float x, float y)", asFUNCTIONPR(std::isgreaterequal, (float, float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_less(float x, float y)", asFUNCTIONPR(std::isless, (float, float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_less_equal(float x, float y)", asFUNCTIONPR(std::islessequal, (float, float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_less_greater(float x, float y)", asFUNCTIONPR(std::islessgreater, (float, float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_unordered(float x, float y)", asFUNCTIONPR(std::isunordered, (float, float), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("double abs(double v)", asFUNCTIONPR(std::abs, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double fmod(double a, double b)", asFUNCTIONPR(std::fmod, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double remainder(double a, double b)", asFUNCTIONPR(std::remainder, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double remquo(double a, double b, int& out quo)", asFUNCTIONPR(std::remquo, (double, double, int*), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double fma(double a, double b, double c)", asFUNCTIONPR(std::fma, (double, double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double dmax(double a, double b)", asFUNCTIONPR(std::fmax, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double dmin(double a, double b)", asFUNCTIONPR(std::fmin, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double fdim(double a, double b)", asFUNCTIONPR(std::fdim, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double lerp(double a, double b, double c)", asFUNCTIONPR(std::lerp, (double, double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double exp(double a)", asFUNCTIONPR(std::exp, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double exp2(double a)", asFUNCTIONPR(std::exp2, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double expm1(double a)", asFUNCTIONPR(std::expm1, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double log(double a)", asFUNCTIONPR(std::log, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double log10(double a)", asFUNCTIONPR(std::log10, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double log2(double a)", asFUNCTIONPR(std::log2, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double log1p(double a)", asFUNCTIONPR(std::log1p, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double pow(double a, double b)", asFUNCTIONPR(std::pow, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double sqrt(double a)", asFUNCTIONPR(std::sqrt, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double cbrt(double a)", asFUNCTIONPR(std::cbrt, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double hypot(double a, double b)", asFUNCTIONPR(std::hypot, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double hypot(double a, double b, double c)", asFUNCTIONPR(std::hypot, (double, double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double sin(double x)", asFUNCTIONPR(std::sin, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double cos(double x)", asFUNCTIONPR(std::cos, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double tan(double x)", asFUNCTIONPR(std::tan, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double asin(double x)", asFUNCTIONPR(std::asin, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double acos(double x)", asFUNCTIONPR(std::acos, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double atan(double x)", asFUNCTIONPR(std::atan, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double atan2(double y, double x)", asFUNCTIONPR(std::atan2, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double sinh(double x)", asFUNCTIONPR(std::sinh, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double cosh(double x)", asFUNCTIONPR(std::cosh, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double tanh(double x)", asFUNCTIONPR(std::tanh, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double asinh(double x)", asFUNCTIONPR(std::asinh, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double acosh(double x)", asFUNCTIONPR(std::acosh, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double atanh(double x)", asFUNCTIONPR(std::atanh, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double erf(double x)", asFUNCTIONPR(std::erf, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double erfc(double x)", asFUNCTIONPR(std::erfc, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double calculate_gamma(double x)", asFUNCTIONPR(std::tgamma, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double calculate_lgamma(double x)", asFUNCTIONPR(std::lgamma, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double ceil(double x)", asFUNCTIONPR(std::ceil, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double floor(double x)", asFUNCTIONPR(std::floor, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double trunc(double x)", asFUNCTIONPR(std::trunc, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double nearbyint(double x)", asFUNCTIONPR(std::nearbyint, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double rint(double x)", asFUNCTIONPR(std::rint, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double frexp(double x, int& out exp)", asFUNCTIONPR(std::frexp, (double, int*), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double ldexp(double x, int exp)", asFUNCTIONPR(std::ldexp, (double, int), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double modf(double num, double& out iptr)", asFUNCTIONPR(std::modf, (double, double*), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double scalbn(double x, int exp)", asFUNCTIONPR(std::scalbn, (double, int), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double scalbn(double x, int64 exp)", asFUNCTIONPR(std::scalbln, (double, long), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("int ilogb(double x)", asFUNCTIONPR(std::ilogb, (double), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("double logb(double x)", asFUNCTIONPR(std::logb, (double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double nextafter(double from, double to)", asFUNCTIONPR(std::nextafter, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double nexttoward(double from, double to)", asFUNCTIONPR(std::nexttoward, (double, long double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("double copysign(double mag, double sgn)", asFUNCTIONPR(std::copysign, (double, double), double), asCALL_CDECL);
	engine->RegisterGlobalFunction("int fpclassify(double x)", asFUNCTIONPR(std::fpclassify, (double), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_finite(double x)", asFUNCTIONPR(std::isfinite, (double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_inf(double x)", asFUNCTIONPR(std::isinf, (double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_nan(double x)", asFUNCTIONPR(std::isnan, (double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_normal(double x)", asFUNCTIONPR(std::isnormal, (double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_negative(double x)", asFUNCTIONPR(std::signbit, (double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_greater(double x, double y)", asFUNCTIONPR(std::isgreater, (double, double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_greater_equal(double x, double y)", asFUNCTIONPR(std::isgreaterequal, (double, double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_less(double x, double y)", asFUNCTIONPR(std::isless, (double, double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_less_equal(double x, double y)", asFUNCTIONPR(std::islessequal, (double, double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_less_greater(double x, double y)", asFUNCTIONPR(std::islessgreater, (double, double), bool), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool is_unordered(double x, double y)", asFUNCTIONPR(std::isunordered, (double, double), bool), asCALL_CDECL);
	//engine->RegisterGlobalFunction("bool is_power_of_2(const uint8 v)", asFUNCTIONPR(std::has_single_bit<uint8>, (uint8), bool), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint8 bit_ceil(const uint8 x)", asFUNCTIONPR(std::bit_ceil<uint8>, (uint8), uint8), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint8 bit_floor(const uint8 x)", asFUNCTIONPR(std::bit_floor<uint8>, (uint8), uint8), asCALL_CDECL);
	engine->RegisterGlobalFunction("int bit_width(const uint8 x)", asFUNCTIONPR(bit_width<uint8>, (uint8), int), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint8 rotl(uint8 x, int s)", asFUNCTIONPR(std::rotl<uint8>, (uint8, int), uint8), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint8 rotr(uint8 x, int s)", asFUNCTIONPR(std::rotr<uint8>, (uint8, int), uint8), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_leading_zeroes(uint8 x)", asFUNCTIONPR(std::countl_zero<uint8>, (uint8), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_trailing_zeroes(uint8 x)", asFUNCTIONPR(std::countr_zero<uint8>, (uint8), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_leading_ones(uint8 x)", asFUNCTIONPR(std::countl_one<uint8>, (uint8), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_trailing_ones(uint8 x)", asFUNCTIONPR(std::countr_one<uint8>, (uint8), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int popcount(uint8 x)", asFUNCTIONPR(std::popcount<uint8>, (uint8), int), asCALL_CDECL);
	//engine->RegisterGlobalFunction("bool is_power_of_2(const uint16 v)", asFUNCTIONPR(std::has_single_bit<uint16>, (uint16), bool), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint16 bit_ceil(const uint16 x)", asFUNCTIONPR(std::bit_ceil<uint16>, (uint16), uint16), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint16 bit_floor(const uint16 x)", asFUNCTIONPR(std::bit_floor<uint16>, (uint16), uint16), asCALL_CDECL);
	engine->RegisterGlobalFunction("int bit_width(const uint16 x)", asFUNCTIONPR(bit_width<uint16>, (uint16), int), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint16 rotl(uint16 x, int s)", asFUNCTIONPR(std::rotl<uint16>, (uint16, int), uint16), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint16 rotr(uint16 x, int s)", asFUNCTIONPR(std::rotr<uint16>, (uint16, int), uint16), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_leading_zeroes(uint16 x)", asFUNCTIONPR(std::countl_zero<uint16>, (uint16), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_trailing_zeroes(uint16 x)", asFUNCTIONPR(std::countr_zero<uint16>, (uint16), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_leading_ones(uint16 x)", asFUNCTIONPR(std::countl_one<uint16>, (uint16), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_trailing_ones(uint16 x)", asFUNCTIONPR(std::countr_one<uint16>, (uint16), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int popcount(uint16 x)", asFUNCTIONPR(std::popcount<uint16>, (uint16), int), asCALL_CDECL);
	//engine->RegisterGlobalFunction("bool is_power_of_2(const uint32 v)", asFUNCTIONPR(std::has_single_bit<uint32>, (uint32), bool), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint32 bit_ceil(const uint32 x)", asFUNCTIONPR(std::bit_ceil<uint32>, (uint32), uint32), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint32 bit_floor(const uint32 x)", asFUNCTIONPR(std::bit_floor<uint32>, (uint32), uint32), asCALL_CDECL);
	engine->RegisterGlobalFunction("int bit_width(const uint32 x)", asFUNCTIONPR(bit_width<uint32>, (uint32), int), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint32 rotl(uint32 x, int s)", asFUNCTIONPR(std::rotl<uint32>, (uint32, int), uint32), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint32 rotr(uint32 x, int s)", asFUNCTIONPR(std::rotr<uint32>, (uint32, int), uint32), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_leading_zeroes(uint32 x)", asFUNCTIONPR(std::countl_zero<uint32>, (uint32), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_trailing_zeroes(uint32 x)", asFUNCTIONPR(std::countr_zero<uint32>, (uint32), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_leading_ones(uint32 x)", asFUNCTIONPR(std::countl_one<uint32>, (uint32), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_trailing_ones(uint32 x)", asFUNCTIONPR(std::countr_one<uint32>, (uint32), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int popcount(uint32 x)", asFUNCTIONPR(std::popcount<uint32>, (uint32), int), asCALL_CDECL);
	//engine->RegisterGlobalFunction("bool is_power_of_2(const uint64 v)", asFUNCTIONPR(std::has_single_bit<uint64>, (uint64), bool), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint64 bit_ceil(const uint64 x)", asFUNCTIONPR(std::bit_ceil<uint64>, (uint64), uint64), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint64 bit_floor(const uint64 x)", asFUNCTIONPR(std::bit_floor<uint64>, (uint64), uint64), asCALL_CDECL);
	engine->RegisterGlobalFunction("int bit_width(const uint64 x)", asFUNCTIONPR(bit_width<uint64>, (uint64), int), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint64 rotl(uint64 x, int s)", asFUNCTIONPR(std::rotl<uint64>, (uint64, int), uint64), asCALL_CDECL);
	//engine->RegisterGlobalFunction("uint64 rotr(uint64 x, int s)", asFUNCTIONPR(std::rotr<uint64>, (uint64, int), uint64), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_leading_zeroes(uint64 x)", asFUNCTIONPR(std::countl_zero<uint64>, (uint64), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_trailing_zeroes(uint64 x)", asFUNCTIONPR(std::countr_zero<uint64>, (uint64), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_leading_ones(uint64 x)", asFUNCTIONPR(std::countl_one<uint64>, (uint64), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int count_trailing_ones(uint64 x)", asFUNCTIONPR(std::countr_one<uint64>, (uint64), int), asCALL_CDECL);
	engine->RegisterGlobalFunction("int popcount(uint64 x)", asFUNCTIONPR(std::popcount<uint64>, (uint64), int), asCALL_CDECL);
	engine->RegisterEnum("floating_point_classification");
	engine->RegisterEnumValue("floating_point_classification", "FP_NORMAL", FP_NORMAL);
	engine->RegisterEnumValue("floating_point_classification", "FP_SUBNORMAL", FP_SUBNORMAL);
	engine->RegisterEnumValue("floating_point_classification", "FP_ZERO", FP_ZERO);
	engine->RegisterEnumValue("floating_point_classification", "FP_INFINITE", FP_INFINITE);
	engine->RegisterEnumValue("floating_point_classification", "FP_NAN", FP_NAN);
	engine->RegisterGlobalProperty("const int FLOAT_RADIX", &fp_characteristics->flt.ibeta);
	engine->RegisterGlobalProperty("const int FLOAT_MANTISSA_DIGITS", &fp_characteristics->flt.it);
	engine->RegisterGlobalProperty("const int FLOAT_EPSILON_EXPONENT", &fp_characteristics->flt.machep);
	engine->RegisterGlobalProperty("const float FLOAT_EPSILON", &fp_characteristics->flt.eps);
	engine->RegisterGlobalProperty("const int FLOAT_NEG_EPSILON_EXPONENT", &fp_characteristics->flt.negep);
	engine->RegisterGlobalProperty("const float FLOAT_NEG_EPSILON", &fp_characteristics->flt.epsneg);
	engine->RegisterGlobalProperty("const int FLOAT_EXPONENT_BITS", &fp_characteristics->flt.iexp);
	engine->RegisterGlobalProperty("const int FLOAT_MIN_EXPONENT", &fp_characteristics->flt.minexp);
	engine->RegisterGlobalProperty("const float FLOAT_MIN_NORMALIZED", &fp_characteristics->flt.xmin);
	engine->RegisterGlobalProperty("const int FLOAT_MAX_EXPONENT", &fp_characteristics->flt.maxexp);
	engine->RegisterGlobalProperty("const float FLOAT_MAX", &fp_characteristics->flt.xmax);
	engine->RegisterGlobalProperty("const int FLOAT_ROUNDING_MODE", &fp_characteristics->flt.irnd);
	engine->RegisterGlobalProperty("const int FLOAT_GUARD_DIGITS", &fp_characteristics->flt.ngrd);
	engine->RegisterGlobalProperty("const int DOUBLE_RADIX", &fp_characteristics->dbl.ibeta);
	engine->RegisterGlobalProperty("const int DOUBLE_MANTISSA_DIGITS", &fp_characteristics->dbl.it);
	engine->RegisterGlobalProperty("const int DOUBLE_EPSILON_EXPONENT", &fp_characteristics->dbl.machep);
	engine->RegisterGlobalProperty("const double DOUBLE_EPSILON", &fp_characteristics->dbl.eps);
	engine->RegisterGlobalProperty("const int DOUBLE_NEG_EPSILON_EXPONENT", &fp_characteristics->dbl.negep);
	engine->RegisterGlobalProperty("const double DOUBLE_NEG_EPSILON", &fp_characteristics->dbl.epsneg);
	engine->RegisterGlobalProperty("const int DOUBLE_EXPONENT_BITS", &fp_characteristics->dbl.iexp);
	engine->RegisterGlobalProperty("const int DOUBLE_MIN_EXPONENT", &fp_characteristics->dbl.minexp);
	engine->RegisterGlobalProperty("const double DOUBLE_MIN_NORMALIZED", &fp_characteristics->dbl.xmin);
	engine->RegisterGlobalProperty("const int DOUBLE_MAX_EXPONENT", &fp_characteristics->dbl.maxexp);
	engine->RegisterGlobalProperty("const double DOUBLE_MAX", &fp_characteristics->dbl.xmax);
	engine->RegisterGlobalProperty("const int DOUBLE_ROUNDING_MODE", &fp_characteristics->dbl.irnd);
	engine->RegisterGlobalProperty("const int DOUBLE_GUARD_DIGITS", &fp_characteristics->dbl.ngrd);
}
