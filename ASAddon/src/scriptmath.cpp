#include <assert.h>
#include <math.h>
#include <float.h>
#include <string.h>
#include "scriptmath.h"
#include <cmath>
#include <numbers>
#include <numeric>
#include <version>
#include <bit>
#include <version>
#include <algorithm>
#include <cstdint>

BEGIN_AS_NAMESPACE

// As AngelScript doesn't allow bitwise manipulation of float types we'll provide a couple of
// functions for converting float values to IEEE 754 formatted values etc. This also allow us to 
// provide a platform agnostic representation to the script so the scripts don't have to worry
// about whether the CPU uses IEEE 754 floats or some other representation
float fpFromIEEE(asUINT raw)
{
	// TODO: Identify CPU family to provide proper conversion
	//        if the CPU doesn't natively use IEEE style floats
	return std::bit_cast<float>(raw);
}
asUINT fpToIEEE(float fp)
{
	return std::bit_cast<asUINT>(fp);
}
double fpFromIEEE(asQWORD raw)
{
	return std::bit_cast<double>(raw);
}
asQWORD fpToIEEE(double fp)
{
	return std::bit_cast<asQWORD>(fp);
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

void RegisterScriptMath_Native(asIScriptEngine *engine)
{
	using int8 = std::int8_t;
	using int16 = std::int16_t;
	using int32 = std::int32_t;
	using int64 = std::int64_t;
	using uint8 = std::uint8_t;
	using uint16 = std::uint16_t;
	using uint32 = std::uint32_t;
	using uint64 = std::uint64_t;
	int r;

	// Conversion between floating point and IEEE bits representations
	r = engine->RegisterGlobalFunction("float fp_from_IEEE(uint)", asFUNCTIONPR(fpFromIEEE, (asUINT), float), asCALL_CDECL); assert( r >= 0 );
	r = engine->RegisterGlobalFunction("uint fp_to_IEEE(float)", asFUNCTIONPR(fpToIEEE, (float), asUINT), asCALL_CDECL); assert( r >= 0 );
	r = engine->RegisterGlobalFunction("double fpFromIEEE(uint64)", asFUNCTIONPR(fpFromIEEE, (asQWORD), double), asCALL_CDECL); assert( r >= 0 );
	r = engine->RegisterGlobalFunction("uint64 fpToIEEE(double)", asFUNCTIONPR(fpToIEEE, (double), asQWORD), asCALL_CDECL); assert( r >= 0 );

	// Close to comparison with epsilon 
	r = engine->RegisterGlobalFunction("bool close_to(float, float, float = 0.00001f)", asFUNCTIONPR(closeTo, (float, float, float), bool), asCALL_CDECL); assert( r >= 0 );
	r = engine->RegisterGlobalFunction("bool close_to(double, double, double = 0.0000000001)", asFUNCTIONPR(closeTo, (double, double, double), bool), asCALL_CDECL); assert( r >= 0 );

	// Mathematical functions
	r = engine->RegisterGlobalFunction("float abs(float v)", asFUNCTIONPR(std::abs, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float fmod(float a, float b)", asFUNCTIONPR(std::fmod, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float remainder(float a, float b)", asFUNCTIONPR(std::remainder, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float remquo(float a, float b, int@ quo)", asFUNCTIONPR(std::remquo, (float, float, int*), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float fma(float a, float b, float c)", asFUNCTIONPR(std::fma, (float, float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float max(float a, float b)", asFUNCTIONPR(std::fmax, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float min(float a, float b)", asFUNCTIONPR(std::fmin, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float fdim(float a, float b)", asFUNCTIONPR(std::fdim, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float lerp(float a, float b, float c)", asFUNCTIONPR(std::lerp, (float, float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float exp(float a)", asFUNCTIONPR(std::exp, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float exp2(float a)", asFUNCTIONPR(std::exp2, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float expm1(float a)", asFUNCTIONPR(std::expm1, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float log(float a)", asFUNCTIONPR(std::log, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float log10(float a)", asFUNCTIONPR(std::log10, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float log2(float a)", asFUNCTIONPR(std::log2, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float log1p(float a)", asFUNCTIONPR(std::log1p, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float pow(float a, float b)", asFUNCTIONPR(std::pow, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float sqrt(float a)", asFUNCTIONPR(std::sqrt, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float cbrt(float a)", asFUNCTIONPR(std::cbrt, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float hypot(float a, float b)", asFUNCTIONPR(std::hypot, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float hypot(float a, float b, float c)", asFUNCTIONPR(std::hypot, (float, float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float sin(float x)", asFUNCTIONPR(std::sin, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float cos(float x)", asFUNCTIONPR(std::cos, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float tan(float x)", asFUNCTIONPR(std::tan, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float asin(float x)", asFUNCTIONPR(std::asin, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float acos(float x)", asFUNCTIONPR(std::acos, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float atan(float x)", asFUNCTIONPR(std::atan, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float atan2(float y, float x)", asFUNCTIONPR(std::atan2, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float sinh(float x)", asFUNCTIONPR(std::sinh, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float cosh(float x)", asFUNCTIONPR(std::cosh, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float tanh(float x)", asFUNCTIONPR(std::tanh, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float asinh(float x)", asFUNCTIONPR(std::asinh, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float acosh(float x)", asFUNCTIONPR(std::acosh, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float atanh(float x)", asFUNCTIONPR(std::atanh, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float erf(float x)", asFUNCTIONPR(std::erf, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float erfc(float x)", asFUNCTIONPR(std::erfc, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float tgamma(float x)", asFUNCTIONPR(std::tgamma, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float lgamma(float x)", asFUNCTIONPR(std::lgamma, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float ceil(float x)", asFUNCTIONPR(std::ceil, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float floor(float x)", asFUNCTIONPR(std::floor, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float trunc(float x)", asFUNCTIONPR(std::trunc, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float nearbyint(float x)", asFUNCTIONPR(std::nearbyint, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float rint(float x)", asFUNCTIONPR(std::rint, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float frexp(float x, int@ exp)", asFUNCTIONPR(std::frexp, (float, int*), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float ldexp(float x, int exp,)", asFUNCTIONPR(std::ldexp, (float, int), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float modf(float num, float@ iptr)", asFUNCTIONPR(std::modf, (float, float*), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float scalbn(float x, int exp)", asFUNCTIONPR(std::scalbn, (float, int), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float scalbn(float x, int64 exp)", asFUNCTIONPR(std::scalbln, (float, long), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int ilogb(float x)", asFUNCTIONPR(std::ilogb, (float), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float logb(float x)", asFUNCTIONPR(std::logb, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float nextafter(float from, float to)", asFUNCTIONPR(std::nextafter, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float nexttoward(float from, double to)", asFUNCTIONPR(std::nexttoward, (float, long double), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float copysign(float mag, float sgn)", asFUNCTIONPR(std::copysign, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int fpclassify(float x)", asFUNCTIONPR(std::fpclassify, (float), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_finite(float x)", asFUNCTIONPR(std::isfinite, (float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_inf(float x)", asFUNCTIONPR(std::isinf, (float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_nan(float x)", asFUNCTIONPR(std::isnan, (float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_normal(float x)", asFUNCTIONPR(std::isnormal, (float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_negative(float x)", asFUNCTIONPR(std::signbit, (float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_greater(float x, float y)", asFUNCTIONPR(std::isgreater, (float, float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_greater_equal(float x, float y)", asFUNCTIONPR(std::isgreaterequal, (float, float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_less(float x, float y)", asFUNCTIONPR(std::isless, (float, float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_less_equal(float x, float y)", asFUNCTIONPR(std::islessequal, (float, float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_less_greater(float x, float y)", asFUNCTIONPR(std::islessgreater, (float, float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_unordered(float x, float y)", asFUNCTIONPR(std::isunordered, (float, float), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float assoc_laguerre(uint n, uint m, float x)", asFUNCTIONPR(std::assoc_laguerre, (unsigned int, unsigned int, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float assoc_legendre(uint n, uint m, float x)", asFUNCTIONPR(std::assoc_legendre, (unsigned int, unsigned int, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float beta(float x, float y)", asFUNCTIONPR(std::beta, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float comp_ellint_1(float k)", asFUNCTIONPR(std::comp_ellint_1, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float comp_ellint_2(float k)", asFUNCTIONPR(std::comp_ellint_2, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float comp_ellint_3(float k, float nu)", asFUNCTIONPR(std::comp_ellint_3, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float cyl_bessel_i(float nu, float x)", asFUNCTIONPR(std::cyl_bessel_i, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float cyl_bessel_j(float nu, float x)", asFUNCTIONPR(std::cyl_bessel_j, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float cyl_bessel_k(float nu, float x)", asFUNCTIONPR(std::cyl_bessel_k, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float cyl_neumann(float nu, float x)", asFUNCTIONPR(std::cyl_neumann, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float ellint_1(float k, float phi)", asFUNCTIONPR(std::ellint_1, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float ellint_2(float k, float phi)", asFUNCTIONPR(std::ellint_2, (float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float ellint_3(float k, float nu, float phi)", asFUNCTIONPR(std::ellint_3, (float, float, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float expint(float num)", asFUNCTIONPR(std::expint, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float hermite(uint n, float x)", asFUNCTIONPR(std::hermite, (unsigned int, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float legendre(uint n, float x)", asFUNCTIONPR(std::legendre, (unsigned int, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float laguerre(uint n, float x)", asFUNCTIONPR(std::laguerre, (unsigned int, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float riemann_zeta(float num)", asFUNCTIONPR(std::riemann_zeta, (float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float sph_bessel(uint n, float x)", asFUNCTIONPR(std::sph_bessel, (unsigned int, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float sph_legendre(uint l, uint m, float theta)", asFUNCTIONPR(std::sph_legendre, (unsigned int, unsigned int, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("float sph_neumann(uint n, float x)", asFUNCTIONPR(std::sph_neumann, (unsigned int, float), float), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double abs(double v)", asFUNCTIONPR(std::abs, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double fmod(double a, double b)", asFUNCTIONPR(std::fmod, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double remainder(double a, double b)", asFUNCTIONPR(std::remainder, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double remquo(double a, double b, int@ quo)", asFUNCTIONPR(std::remquo, (double, double, int*), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double fma(double a, double b, double c)", asFUNCTIONPR(std::fma, (double, double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double max(double a, double b)", asFUNCTIONPR(std::fmax, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double min(double a, double b)", asFUNCTIONPR(std::fmin, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double fdim(double a, double b)", asFUNCTIONPR(std::fdim, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double lerp(double a, double b, double c)", asFUNCTIONPR(std::lerp, (double, double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double exp(double a)", asFUNCTIONPR(std::exp, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double exp2(double a)", asFUNCTIONPR(std::exp2, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double expm1(double a)", asFUNCTIONPR(std::expm1, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double log(double a)", asFUNCTIONPR(std::log, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double log10(double a)", asFUNCTIONPR(std::log10, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double log2(double a)", asFUNCTIONPR(std::log2, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double log1p(double a)", asFUNCTIONPR(std::log1p, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double pow(double a, double b)", asFUNCTIONPR(std::pow, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double sqrt(double a)", asFUNCTIONPR(std::sqrt, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double cbrt(double a)", asFUNCTIONPR(std::cbrt, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double hypot(double a, double b)", asFUNCTIONPR(std::hypot, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double hypot(double a, double b, double c)", asFUNCTIONPR(std::hypot, (double, double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double sin(double x)", asFUNCTIONPR(std::sin, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double cos(double x)", asFUNCTIONPR(std::cos, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double tan(double x)", asFUNCTIONPR(std::tan, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double asin(double x)", asFUNCTIONPR(std::asin, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double acos(double x)", asFUNCTIONPR(std::acos, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double atan(double x)", asFUNCTIONPR(std::atan, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double atan2(double y, double x)", asFUNCTIONPR(std::atan2, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double sinh(double x)", asFUNCTIONPR(std::sinh, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double cosh(double x)", asFUNCTIONPR(std::cosh, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double tanh(double x)", asFUNCTIONPR(std::tanh, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double asinh(double x)", asFUNCTIONPR(std::asinh, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double acosh(double x)", asFUNCTIONPR(std::acosh, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double atanh(double x)", asFUNCTIONPR(std::atanh, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double erf(double x)", asFUNCTIONPR(std::erf, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double erfc(double x)", asFUNCTIONPR(std::erfc, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double tgamma(double x)", asFUNCTIONPR(std::tgamma, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double lgamma(double x)", asFUNCTIONPR(std::lgamma, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double ceil(double x)", asFUNCTIONPR(std::ceil, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double floor(double x)", asFUNCTIONPR(std::floor, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double trunc(double x)", asFUNCTIONPR(std::trunc, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double nearbyint(double x)", asFUNCTIONPR(std::nearbyint, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double rint(double x)", asFUNCTIONPR(std::rint, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double frexp(double x, int@ exp)", asFUNCTIONPR(std::frexp, (double, int*), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double ldexp(double x, int exp,)", asFUNCTIONPR(std::ldexp, (double, int), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double modf(double num, double@ iptr)", asFUNCTIONPR(std::modf, (double, double*), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double scalbn(double x, int exp)", asFUNCTIONPR(std::scalbn, (double, int), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double scalbn(double x, int64 exp)", asFUNCTIONPR(std::scalbln, (double, long), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int ilogb(double x)", asFUNCTIONPR(std::ilogb, (double), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double logb(double x)", asFUNCTIONPR(std::logb, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double nextafter(double from, double to)", asFUNCTIONPR(std::nextafter, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double nexttoward(double from, double to)", asFUNCTIONPR(std::nexttoward, (double, long double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double copysign(double mag, double sgn)", asFUNCTIONPR(std::copysign, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int fpclassify(double x)", asFUNCTIONPR(std::fpclassify, (double), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_finite(double x)", asFUNCTIONPR(std::isfinite, (double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_inf(double x)", asFUNCTIONPR(std::isinf, (double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_nan(double x)", asFUNCTIONPR(std::isnan, (double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_normal(double x)", asFUNCTIONPR(std::isnormal, (double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_negative(double x)", asFUNCTIONPR(std::signbit, (double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_greater(double x, double y)", asFUNCTIONPR(std::isgreater, (double, double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_greater_equal(double x, double y)", asFUNCTIONPR(std::isgreaterequal, (double, double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_less(double x, double y)", asFUNCTIONPR(std::isless, (double, double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_less_equal(double x, double y)", asFUNCTIONPR(std::islessequal, (double, double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_less_greater(double x, double y)", asFUNCTIONPR(std::islessgreater, (double, double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_unordered(double x, double y)", asFUNCTIONPR(std::isunordered, (double, double), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double assoc_laguerre(uint n, uint m, double x)", asFUNCTIONPR(std::assoc_laguerre, (unsigned int, unsigned int, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double assoc_legendre(uint n, uint m, double x)", asFUNCTIONPR(std::assoc_legendre, (unsigned int, unsigned int, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double beta(double x, double y)", asFUNCTIONPR(std::beta, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double comp_ellint_1(double k)", asFUNCTIONPR(std::comp_ellint_1, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double comp_ellint_2(double k)", asFUNCTIONPR(std::comp_ellint_2, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double comp_ellint_3(double k, double nu)", asFUNCTIONPR(std::comp_ellint_3, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double cyl_bessel_i(double nu, double x)", asFUNCTIONPR(std::cyl_bessel_i, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double cyl_bessel_j(double nu, double x)", asFUNCTIONPR(std::cyl_bessel_j, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double cyl_bessel_k(double nu, double x)", asFUNCTIONPR(std::cyl_bessel_k, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double cyl_neumann(double nu, double x)", asFUNCTIONPR(std::cyl_neumann, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double ellint_1(double k, double phi)", asFUNCTIONPR(std::ellint_1, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double ellint_2(double k, double phi)", asFUNCTIONPR(std::ellint_2, (double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double ellint_3(double k, double nu, double phi)", asFUNCTIONPR(std::ellint_3, (double, double, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double expint(double num)", asFUNCTIONPR(std::expint, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double hermite(uint n, double x)", asFUNCTIONPR(std::hermite, (unsigned int, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double legendre(uint n, double x)", asFUNCTIONPR(std::legendre, (unsigned int, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double laguerre(uint n, double x)", asFUNCTIONPR(std::laguerre, (unsigned int, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double riemann_zeta(double num)", asFUNCTIONPR(std::riemann_zeta, (double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double sph_bessel(uint n, double x)", asFUNCTIONPR(std::sph_bessel, (unsigned int, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double sph_legendre(uint l, uint m, double theta)", asFUNCTIONPR(std::sph_legendre, (unsigned int, unsigned int, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("double sph_neumann(uint n, double x)", asFUNCTIONPR(std::sph_neumann, (unsigned int, double), double), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_power_of_2(const uint8 v)", asFUNCTIONPR(std::has_single_bit<uint8>, (uint8), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint8 ceil(const uint8 x)", asFUNCTIONPR(std::bit_ceil<uint8>, (uint8), uint8), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint8 floor(const uint8 x)", asFUNCTIONPR(std::bit_floor<uint8>, (uint8), uint8), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int bit_width(const uint8 x)", asFUNCTIONPR(std::bit_width<uint8>, (uint8), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint8 rotl(uint8 x, int s)", asFUNCTIONPR(std::rotl<uint8>, (uint8, int), uint8), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint8 rotr(uint8 x, int s)", asFUNCTIONPR(std::rotr<uint8>, (uint8, int), uint8), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_leading_zeroes(uint8 x)", asFUNCTIONPR(std::countl_zero<uint8>, (uint8), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_trailing_zeroes(uint8 x)", asFUNCTIONPR(std::countr_zero<uint8>, (uint8), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_leading_ones(uint8 x)", asFUNCTIONPR(std::countl_one<uint8>, (uint8), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_trailing_ones(uint8 x)", asFUNCTIONPR(std::countr_one<uint8>, (uint8), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int popcount(uint8 x)", asFUNCTIONPR(std::popcount<uint8>, (uint8), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_power_of_2(const uint16 v)", asFUNCTIONPR(std::has_single_bit<uint16>, (uint16), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint16 ceil(const uint16 x)", asFUNCTIONPR(std::bit_ceil<uint16>, (uint16), uint16), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint16 floor(const uint16 x)", asFUNCTIONPR(std::bit_floor<uint16>, (uint16), uint16), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int bit_width(const uint16 x)", asFUNCTIONPR(std::bit_width<uint16>, (uint16), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint16 rotl(uint16 x, int s)", asFUNCTIONPR(std::rotl<uint16>, (uint16, int), uint16), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint16 rotr(uint16 x, int s)", asFUNCTIONPR(std::rotr<uint16>, (uint16, int), uint16), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_leading_zeroes(uint16 x)", asFUNCTIONPR(std::countl_zero<uint16>, (uint16), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_trailing_zeroes(uint16 x)", asFUNCTIONPR(std::countr_zero<uint16>, (uint16), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_leading_ones(uint16 x)", asFUNCTIONPR(std::countl_one<uint16>, (uint16), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_trailing_ones(uint16 x)", asFUNCTIONPR(std::countr_one<uint16>, (uint16), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int popcount(uint16 x)", asFUNCTIONPR(std::popcount<uint16>, (uint16), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_power_of_2(const uint32 v)", asFUNCTIONPR(std::has_single_bit<uint32>, (uint32), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint32 ceil(const uint32 x)", asFUNCTIONPR(std::bit_ceil<uint32>, (uint32), uint32), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint32 floor(const uint32 x)", asFUNCTIONPR(std::bit_floor<uint32>, (uint32), uint32), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int bit_width(const uint32 x)", asFUNCTIONPR(std::bit_width<uint32>, (uint32), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint32 rotl(uint32 x, int s)", asFUNCTIONPR(std::rotl<uint32>, (uint32, int), uint32), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint32 rotr(uint32 x, int s)", asFUNCTIONPR(std::rotr<uint32>, (uint32, int), uint32), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_leading_zeroes(uint32 x)", asFUNCTIONPR(std::countl_zero<uint32>, (uint32), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_trailing_zeroes(uint32 x)", asFUNCTIONPR(std::countr_zero<uint32>, (uint32), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_leading_ones(uint32 x)", asFUNCTIONPR(std::countl_one<uint32>, (uint32), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_trailing_ones(uint32 x)", asFUNCTIONPR(std::countr_one<uint32>, (uint32), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int popcount(uint32 x)", asFUNCTIONPR(std::popcount<uint32>, (uint32), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("bool is_power_of_2(const uint64 v)", asFUNCTIONPR(std::has_single_bit<uint64>, (uint64), bool), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint64 ceil(const uint64 x)", asFUNCTIONPR(std::bit_ceil<uint64>, (uint64), uint64), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint64 floor(const uint64 x)", asFUNCTIONPR(std::bit_floor<uint64>, (uint64), uint64), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int bit_width(const uint64 x)", asFUNCTIONPR(std::bit_width<uint64>, (uint64), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint64 rotl(uint64 x, int s)", asFUNCTIONPR(std::rotl<uint64>, (uint64, int), uint64), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("uint64 rotr(uint64 x, int s)", asFUNCTIONPR(std::rotr<uint64>, (uint64, int), uint64), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_leading_zeroes(uint64 x)", asFUNCTIONPR(std::countl_zero<uint64>, (uint64), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_trailing_zeroes(uint64 x)", asFUNCTIONPR(std::countr_zero<uint64>, (uint64), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_leading_ones(uint64 x)", asFUNCTIONPR(std::countl_one<uint64>, (uint64), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int count_trailing_ones(uint64 x)", asFUNCTIONPR(std::countr_one<uint64>, (uint64), int), asCALL_CDECL); assert(r > 0);
	r = engine->RegisterGlobalFunction("int popcount(uint64 x)", asFUNCTIONPR(std::popcount<uint64>, (uint64), int), asCALL_CDECL); assert(r > 0);
}


void RegisterScriptMath(asIScriptEngine *engine)
{
	RegisterScriptMath_Native(engine);
}

END_AS_NAMESPACE


