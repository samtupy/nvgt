/* text_validation.h - text validation implementation code
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
#include <string>
#include <Poco/TextConverter.h>
#include <Poco/UTF8Encoding.h>
#include <Poco/TextIterator.h>

/**
 * Checks whether a string is valid UTF-8.
 * Can also prohibit strings containing ASCII special characters.
 * Used internally by pack file, sound service.
 */
bool is_valid_utf8(const std::string &text, bool ban_ascii_special = true)
{
    Poco::UTF8Encoding encoding;
    Poco::TextIterator i(text, encoding);
    Poco::TextIterator end(text);
    while (i != end)
    {
        // Reject entirely invalid characters:
        if (*i == -1)
        {
            return false;
        }
        // Also reject ASCII 0 - 31 and 127 as these are not printable characters:
        if ((*i < 32 || *i == 127) && ban_ascii_special)
        {
            return false;
        }
        i++;
    }
    return true;
}