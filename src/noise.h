#pragma once
#undef IN
#include <algorithm>
#include <array>
#include <concepts>
#include <cstddef>
#include <cstdint>
#include <deque>
#include <iterator>
#include <limits>
#include <optional>
#include <ranges>
#include <span>
#include <stack>
#include <stdexcept>
#include <tuple>
#include <type_traits>
#include <vector>

namespace noise {
template <typename T>
concept STLContainer = requires(T container) {
  typename T::iterator;
  { container.data() } -> std::same_as<typename T::value_type *>;
  { container.size() } -> std::same_as<std::size_t>;
};

enum class PatternToken : std::uint8_t { E, S, Ee, Es, Se, Ss };

enum class HandshakePattern : std::uint8_t {
  IK,
  IN,
  IX,
  K,
  KK,
  KN,
  KX,
  N,
  NK,
  NN,
  NX,
  XK,
  XN,
  XX,
  NK1,
  NX1,
  X,
  X1K,
  XK1,
  X1K1,
  X1N,
  X1X,
  XX1,
  X1X1,
  K1N,
  K1K,
  KK1,
  K1K1,
  K1X,
  KX1,
  K1X1,
  I1N,
  I1K,
  IK1,
  I1K1,
  I1X,
  IX1,
  I1X1,
};

std::tuple<std::array<std::uint8_t, 32>, std::array<std::uint8_t, 32>>
generate_keypair();

class CipherState {
private:
  std::array<std::uint8_t, 32> k;
  std::uint64_t n;

public:
  CipherState() = default;
  ~CipherState();
  void initialize_key(const std::array<std::uint8_t, 32> &key);
  bool has_key() const;
  void set_nonce(const std::uint64_t &nonce);
  template <STLContainer T> void encrypt_with_ad(T &ad, T &plaintext);
  void encrypt_with_ad(std::vector<std::uint8_t> &plaintext);
  template <STLContainer T> void decrypt_with_ad(T &ad, T &ciphertext);
  void decrypt_with_ad(std::vector<std::uint8_t> &ciphertext);
};

class SymmetricState {
private:
  CipherState cs;
  std::array<std::uint8_t, 64> ck;
  std::array<std::uint8_t, 64> h;

public:
  SymmetricState() = default;
  ~SymmetricState();
  void initialize_symmetric(const std::vector<std::uint8_t> &protocol_name);
  template <STLContainer T> void mix_key(T &input_key_material);
  template <STLContainer T> void mix_hash(const T &data);
  std::array<std::uint8_t, 64> get_handshake_hash() const;
  template <STLContainer T> void encrypt_and_hash(T &plaintext);
  template <STLContainer T> void decrypt_and_hash(T &ciphertext);
  std::tuple<CipherState, CipherState> split();
  bool cs_has_key() const;
};

class HandshakeState {
private:
  SymmetricState ss;
  // We deviate from the specification here so that the key pairs (as defined
  // in 5.3) are separate objects we can manipulate rather than having to work
  // with a tuple object
  std::array<std::uint8_t, 32> spk;
  std::array<std::uint8_t, 32> ssk;
  std::array<std::uint8_t, 32> epk;
  std::array<std::uint8_t, 32> esk;
  std::array<std::uint8_t, 32> rspk;
  std::array<std::uint8_t, 32> repk;
  bool initiator, my_turn, completed;
  std::deque<std::vector<PatternToken>> message_patterns;
  std::vector<PatternToken> initiator_pre_message_pattern,
      responder_pre_message_pattern;

public:
  HandshakeState() = default;
  ~HandshakeState();
  void
  initialize(const HandshakePattern &handshake_pattern, const bool &initiator,
             const std::vector<std::uint8_t> prologue = {},
             std::optional<std::tuple<std::array<std::uint8_t, 32>,
                                      std::array<std::uint8_t, 32>>>
                 s = std::nullopt,
             std::optional<std::tuple<std::array<std::uint8_t, 32>,
                                      std::array<std::uint8_t, 32>>>
                 e = std::nullopt,
             std::optional<std::array<std::uint8_t, 32>> rs = std::nullopt,
             std::optional<std::array<std::uint8_t, 32>> re = std::nullopt);
  void write_message(std::vector<std::uint8_t> &payload,
                     std::vector<std::uint8_t> &message_buffer);
  void write_message(std::vector<std::uint8_t> &message_buffer);
  void read_message(std::vector<std::uint8_t> &message,
                    std::vector<std::uint8_t> &payload_buffer);
  std::array<std::uint8_t, 64> get_handshake_hash();
  std::array<std::uint8_t, 32> get_local_static_public_key();
  std::array<std::uint8_t, 32> get_local_ephemeral_public_key();
  std::array<std::uint8_t, 32> get_remote_ephemeral_public_key();
  std::array<std::uint8_t, 32> get_remote_static_public_key();
  bool is_initiator();
  bool is_handshake_finished();
  bool is_my_turn();
  std::tuple<CipherState, CipherState> finalize();
};
} // namespace noise
