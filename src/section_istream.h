/* section_istream.h - Seekable section istream implementation header
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
/**
 * Section input stream.
 * This is an implementation of an istream that reads from a designated section of a source stream.
 * Stream positions and seek offsets are all relative to the beginning of the section.
 * This class is used by the pack class to return handles to individual files within the pack.
 * This stream takes ownership of its source stream and will delete it automatically.
 */
#include <Poco/BufferedStreamBuf.h>
#include <istream>
class section_istreambuf : public Poco::BasicBufferedStreamBuf<char, std::char_traits<char>>
{
	std::istream *source;
	std::streamoff start;
	std::streamsize size;

public:
	section_istreambuf(std::istream &source, std::streamoff start, std::streamsize size);
	~section_istreambuf();
	int readFromDevice(char *buffer, std::streamsize length);
	std::streampos seekoff(std::streamoff off, std::ios_base::seekdir dir, std::ios_base::openmode which = std::ios_base::in);
	std::streampos seekpos(std::streampos pos, std::ios_base::openmode which = std::ios_base::in);
};
class section_istream : public std::istream
{
public:
	section_istream(std::istream &source, std::streamoff start, std::streamsize size);
	~section_istream();
};
