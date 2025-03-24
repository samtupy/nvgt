/* pack_protocol.h - pack file sound service protocol implementation code
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
#include "pack_protocol.h"
#include "pack2.h"
std::istream *pack_protocol::open_uri(const char *uri, const directive_t directive) const
{

    std::shared_ptr<const new_pack::pack> obj = std::static_pointer_cast<const new_pack::pack>(directive);
    if (obj == nullptr)
    {
        return nullptr;
    }
    std::istream *item = obj->get_file(uri);

    return item;
}
const std::string pack_protocol::get_suffix(const directive_t &directive) const
{
    std::shared_ptr<const new_pack::pack> obj = std::static_pointer_cast<const new_pack::pack>(directive);
    if (obj == nullptr)
    {
        return "error";
    }
    return obj->get_pack_name();
}
const pack_protocol pack_protocol::instance;
const sound_service::protocol *pack_protocol::get_instance()
{
    return &instance;
}
