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
#include "section_istream.h"

section_istreambuf::section_istreambuf(std::istream &source, std::streamoff start, std::streamsize size)
	: BasicBufferedStreamBuf(4096, std::ios_base::in)
{

	this->source = &source;
	if (!source.good())
	{
		throw std::invalid_argument("Stream is invalid.");
	}
	source.seekg(start + size);
	if (source.tellg() != start + size)
	{
		throw std::range_error("End is beyond end of file.");
	}
	source.seekg(start);
	if (source.tellg() != start)
	{
		throw std::runtime_error("Failed to seek to start offset.");
	}
	this->start = start;
	this->size = size;
}
section_istreambuf::~section_istreambuf()
{
	delete source;
}
int section_istreambuf::readFromDevice(char *buffer, std::streamsize length)
{

	std::streampos pos = source->tellg();
	if (pos < start || pos >= start + size)
	{
		return -1;
	}
	length = std::min(length, (start + size - pos));

	source->read(buffer, length);

	return (int)length;
}
std::streampos section_istreambuf::seekoff(std::streamoff off, std::ios_base::seekdir dir, std::ios_base::openmode which)
{
	source->clear();
	if (!source->good())
	{
		return -1;
	}

	switch (dir)
	{
	case std::ios_base::beg:
		return seekpos(off);
	case std::ios_base::end:
		return seekpos(size + off);
	case std::ios_base::cur:
		// Istream uses 0 cur to implement tell, so just report the current position without moving anything.
		if (off == 0)
		{
			return source->tellg() - start - in_avail();
		}
		return seekpos(source->tellg() - start - in_avail() + off);
	}
	return -1; // Can't get here.
}
std::streampos section_istreambuf::seekpos(std::streampos pos, std::ios_base::openmode which)
{
	source->clear();

	if (!source->good())
	{
		return -1;
	}
	std::streampos true_pos = pos + start;
	if (true_pos > start + size)
	{
		return -1;
	}

	source->seekg(true_pos);
	this->setg(nullptr, nullptr, nullptr);
	return pos;
}

section_istream::section_istream(std::istream &source, std::streamoff start, std::streamsize size)
	: basic_istream(new section_istreambuf(source, start, size))
{
}
section_istream::~section_istream()
{
	delete rdbuf();
}