/* encryption_filter.h - ChaCha encryption sound service filter implementation header.
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
#include "sound_service.h"
#include <mutex>
class encryption_filter : public sound_service::filter
{

public:
    static const sound_service::filter *get_instance();
    encryption_filter();
    virtual std::istream *wrap(std::istream &source, const directive_t directive) const;
    static encryption_filter instance;
};
