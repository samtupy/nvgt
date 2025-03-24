/* checksum_stream.h - Checksum wrapping istream implementation code
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
#include "checksum_stream.h"
checksum_ostreambuf::checksum_ostreambuf(std::ostream &sink)
	: BasicBufferedStreamBuf(4096, std::ios_base::out),
	  check(Poco::Checksum::TYPE_CRC32)
{
	this->sink = &sink;
}
checksum_ostreambuf::~checksum_ostreambuf()
{
}
int checksum_ostreambuf::writeToDevice(const char *buffer, std::streamsize length)
{
	check.update(buffer, (uint32_t)length);
	sink->write(buffer, length);
	return (int)length;
}
uint32_t checksum_ostreambuf::get_checksum()
{
	return check.checksum();
}
checksum_ostream::checksum_ostream(std::ostream &sink)
	: basic_ostream(new checksum_ostreambuf(sink))
{
}
checksum_ostream::~checksum_ostream()
{
	delete rdbuf();
}
uint32_t checksum_ostream ::get_checksum()
{
	checksum_ostreambuf *buf = static_cast<checksum_ostreambuf *>(rdbuf());
	if (buf == NULL)
	{
		return 0;
	}
	return buf->get_checksum();
}
checksum_istreambuf::checksum_istreambuf(std::istream &source)
	: BasicBufferedStreamBuf(4096, std::ios_base::in),
	  check(Poco::Checksum::TYPE_CRC32)
{
	this->source = &source;
}
checksum_istreambuf::~checksum_istreambuf()
{
}
int checksum_istreambuf::readFromDevice(char *buffer, std::streamsize length)
{
	if (!source->good())
	{
		return -1;
	}
	source->read(buffer, length);
	int result = (int)source->gcount();
	check.update(buffer, result);
	return result;
}
uint32_t checksum_istreambuf::get_checksum()
{
	return check.checksum();
}
checksum_istream::checksum_istream(std::istream &source)
	: basic_istream(new checksum_istreambuf(source))
{
	this->source = &source;
}
checksum_istream::~checksum_istream()
{
	delete rdbuf();
}
std::streampos checksum_istream::tellg()
{
	if (!good())
	{
		return -1;
	}
	source->clear();
	return source->tellg() - rdbuf()->in_avail();
}
uint32_t checksum_istream::get_checksum()
{
	checksum_istreambuf *buf = static_cast<checksum_istreambuf *>(rdbuf());
	if (buf == NULL)
	{
		return 0;
	}
	return buf->get_checksum();
}