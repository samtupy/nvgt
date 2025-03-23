/* encryption_filter.cpp - ChaCha encryption sound service filter implementation.
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
#include "encryption_filter.h"
#include "chacha_stream.h"
const sound_service::filter *encryption_filter::get_instance()
{
    return &instance;
}
encryption_filter::encryption_filter()
{
}
std::istream *encryption_filter::wrap(std::istream &source, const directive_t directive) const
{

    // Key is expected to have been passed in through the directive interface.
    const std::shared_ptr<const std::string> key = std::static_pointer_cast<const std::string>(directive);
    if (key == nullptr)
    {

        return &source;
    }

    try
    {
        return new chacha_istream(source, *key);
    }
    catch (std::exception &)
    {
        // Not encrypted or not valid.
        return nullptr;
    }
}
encryption_filter encryption_filter::instance;