#ifndef RNG_GET_BYTES_H
#define RNG_GET_BYTES_H

/* LibTomCrypt, modular cryptographic library -- Tom St Denis
 *
 * LibTomCrypt is a library that provides various cryptographic
 * algorithms in a highly modular and flexible manner.
 *
 * The library is free for all purposes without any express
 * guarantee it works.
 */

/**
   @file rng_get_bytes.h
   portable way to get secure random bits to feed a PRNG (Tom St Denis)
*/

#ifdef __cplusplus
extern "C" {
#endif
/**
  Read the system RNG
  @param out       Destination
  @param outlen    Length desired (octets)
  @return Number of octets read
*/
unsigned long rng_get_bytes ( unsigned char* out, unsigned long outlen );

#ifdef __cplusplus
}
#endif
#endif
