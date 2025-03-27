/* memory_protocol.c - memory buffer sound service protocol implementation code
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
#include "memory_protocol.h"
#include "pack2.h"
#include <poco/NumberFormatter.h>
#include <Poco/MemoryStream.h>
static std::atomic<uint64_t> next_memory_id = 0;
struct memory_args
{
    const void *data;
    size_t size;
    uint64_t id; // Prevents caching by resource manager.
};

std::istream *memory_protocol::open_uri(const char *uri, const directive_t directive) const
{
    // This proto doesn't care about the URI itself.
    std::shared_ptr<const memory_args> args = std::static_pointer_cast<const memory_args>(directive);
    if (args == nullptr)
    {
        return nullptr;
    }
    return new Poco::MemoryInputStream((const char *)args->data, args->size);
}
const std::string memory_protocol::get_suffix(const directive_t &directive) const
{
    std::shared_ptr<const memory_args> args = std::static_pointer_cast<const memory_args>(directive);
    return Poco::NumberFormatter::format(args->id);
}
directive_t memory_protocol::directive(const void *data, size_t size)
{
    std::shared_ptr<memory_args> args = std::make_shared<memory_args>();
    args->data = data;
    args->size = size;
    args->id = next_memory_id++;
    return args;
}
const memory_protocol memory_protocol::instance;
const sound_service::protocol *memory_protocol::get_instance()
{
    return &instance;
}
