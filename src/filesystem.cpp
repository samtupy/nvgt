/* filesystem.cpp - filesystem functions code
 * Originally these consisted of Angelscript's filesystem addon but with the class removed, however are in the process of being replaced with Poco::File.
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
#if defined(_WIN32)
	#include <direct.h> // _getcwd
	#include <Windows.h> // FindFirstFile, GetFileAttributes
	#include <shlwapi.h>

	#undef DeleteFile
	#undef CopyFile

#else
	#include <unistd.h> // getcwd
	#include <dirent.h> // opendir, readdir, closedir
	#include <fnmatch.h> // fnmatch
	#include <sys/stat.h> // stat
#endif
#include <assert.h> // assert
#include <angelscript.h>
#include <scriptarray.h>
#include <datetime.h>
#include <Poco/Exception.h>
#include <Poco/File.h>
#include <Poco/UnicodeConverter.h>

using namespace std;

#include <string.h>

bool FileHardLink(const std::string& source, const std::string& target) {
	try {
		Poco::File(source).linkTo(target, Poco::File::LINK_HARD);
	} catch (Poco::Exception) {
		return false;
	}
	/*try
	{
	filesystem::create_hard_link(source, target);
	return true;
	}
	catch(filesystem::filesystem_error)
	{
	return false;
	}*/
	return false;
}
int FileHardLinkCount(const std::string& path) {
	/*try
	{
	return filesystem::hard_link_count(path);
	}
	catch(filesystem::filesystem_error)
	{
	return 0;
	}*/
	return 0;
}

CScriptArray* FindFiles(const string& path) {
	// Obtain a pointer to the engine
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();

	// TODO: This should only be done once
	// TODO: This assumes that CScriptArray was already registered
	asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");

	// Create the array object
	CScriptArray* array = CScriptArray::Create(arrayType);

	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	WIN32_FIND_DATAW ffd;
	HANDLE hFind = FindFirstFileW(bufUTF16, &ffd);
	if (INVALID_HANDLE_VALUE == hFind)
		return array;

	do {
		// Skip directories
		if ((ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			continue;

		// Convert the file name back to UTF8
		char bufUTF8[1024];
		WideCharToMultiByte(CP_UTF8, 0, ffd.cFileName, -1, bufUTF8, 1024, 0, 0);

		// Add the file to the array
		array->Resize(array->GetSize() + 1);
		((string*)(array->At(array->GetSize() - 1)))->assign(bufUTF8);
	} while (FindNextFileW(hFind, &ffd) != 0);

	FindClose(hFind);
	#else
	int wildcard = path.rfind("/");
	if (wildcard == std::string::npos) wildcard = path.rfind("\\");
	string currentPath = path;
	string Wildcard = "*";
	if (wildcard != std::string::npos) {
		currentPath = path.substr(0, wildcard);
		Wildcard = path.substr(wildcard + 1);
	}
	dirent* ent = 0;
	DIR* dir = opendir(currentPath.c_str());
	if (!dir) return array;
	while ((ent = readdir(dir)) != NULL) {
		const string filename = ent->d_name;

		// Skip . and ..
		if (filename[0] == '.')
			continue;

		// Skip sub directories
		const string fullname = currentPath + "/" + filename;
		struct stat st;
		if (stat(fullname.c_str(), &st) == -1)
			continue;
		if ((st.st_mode & S_IFDIR) != 0)
			continue;

		// wildcard matching
		if (fnmatch(Wildcard.c_str(), filename.c_str(), 0) != 0)
			continue;

		// Add the file to the array
		array->Resize(array->GetSize() + 1);
		((string*)(array->At(array->GetSize() - 1)))->assign(filename);
	}
	closedir(dir);
	#endif

	return array;
}

CScriptArray* FindDirectories(const string& path) {
	// Obtain a pointer to the engine
	asIScriptContext* ctx = asGetActiveContext();
	asIScriptEngine* engine = ctx->GetEngine();

	// TODO: This should only be done once
	// TODO: This assumes that CScriptArray was already registered
	asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<string>");

	// Create the array object
	CScriptArray* array = CScriptArray::Create(arrayType);

	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	WIN32_FIND_DATAW ffd;
	HANDLE hFind = FindFirstFileW(bufUTF16, &ffd);
	if (INVALID_HANDLE_VALUE == hFind)
		return array;

	do {
		// Skip files
		if (!(ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
			continue;

		// Convert the file name back to UTF8
		char bufUTF8[1024];
		WideCharToMultiByte(CP_UTF8, 0, ffd.cFileName, -1, bufUTF8, 1024, 0, 0);

		if (strcmp(bufUTF8, ".") == 0 || strcmp(bufUTF8, "..") == 0)
			continue;

		// Add the dir to the array
		array->Resize(array->GetSize() + 1);
		((string*)(array->At(array->GetSize() - 1)))->assign(bufUTF8);
	} while (FindNextFileW(hFind, &ffd) != 0);

	FindClose(hFind);
	#else
	int wildcard = path.rfind("/");
	if (wildcard == std::string::npos) wildcard = path.rfind("\\");
	string currentPath = path;
	string Wildcard = "*";
	if (wildcard != std::string::npos) {
		currentPath = path.substr(0, wildcard);
		Wildcard = path.substr(wildcard + 1);
	}
	dirent* ent = 0;
	DIR* dir = opendir(currentPath.c_str());
	if (!dir) return array;
	while ((ent = readdir(dir)) != NULL) {
		const string filename = ent->d_name;

		// Skip . and ..
		if (filename[0] == '.')
			continue;

		// Skip files
		const string fullname = currentPath + "/" + filename;
		struct stat st;
		if (stat(fullname.c_str(), &st) == -1)
			continue;
		if ((st.st_mode & S_IFDIR) == 0)
			continue;

		// wildcard matching
		if (fnmatch(Wildcard.c_str(), filename.c_str(), 0) != 0)
			continue;

		// Add the dir to the array
		array->Resize(array->GetSize() + 1);
		((string*)(array->At(array->GetSize() - 1)))->assign(filename);
	}
	closedir(dir);
	#endif

	return array;
}

bool DirectoryExists(const string& path) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	// Check if the path exists and is a directory
	DWORD attrib = GetFileAttributesW(bufUTF16);
	if (attrib == INVALID_FILE_ATTRIBUTES || !(attrib & FILE_ATTRIBUTE_DIRECTORY))
		return false;
	#else
	// Check if the path exists and is a directory
	struct stat st;
	if (stat(path.c_str(), &st) == -1)
		return false;
	if ((st.st_mode & S_IFDIR) == 0)
		return false;
	#endif

	return true;
}

bool FileExists(const string& path) {
	#ifdef _WIN32
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	// Check if the path exists and is a directory
	DWORD attrib = GetFileAttributesW(bufUTF16);
	if (attrib == INVALID_FILE_ATTRIBUTES || (attrib & FILE_ATTRIBUTE_DIRECTORY))
		return false;
	return true;
	#else
	// Check if the path exists and is a file
	struct stat st;
	if (stat(path.c_str(), &st) == -1)
		return false;
	if ((st.st_mode & S_IFDIR) != 0)
		return false;
	return true;
	#endif
	return false;
}

asINT64 FileGetSize(const string& path) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	// Get the size of the file
	WIN32_FILE_ATTRIBUTE_DATA attrs;
	if (!GetFileAttributesExW(bufUTF16, GetFileExInfoStandard, &attrs))
		return -1;
	LARGE_INTEGER size;
	size.HighPart = attrs.nFileSizeHigh;
	size.LowPart = attrs.nFileSizeLow;
	return size.QuadPart;
	#else
	// Get the size of the file
	struct stat st;
	if (stat(path.c_str(), &st) == -1)
		return -1;
	return asINT64(st.st_size);
	#endif
}

bool DirectoryCreate(const string& path) {
	try {
		Poco::File(path).createDirectories();
	} catch (Poco::Exception& e) {
		return false;
	}
	return true;
}

bool DirectoryDelete(const string& path) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	// Remove the directory
	BOOL success = RemoveDirectoryW(bufUTF16);
	return success;
	#else
	// Remove the directory
	int failure = rmdir(path.c_str());
	return !failure ? true : false;
	#endif
}

bool FileDelete(const string& path) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	// Remove the file
	BOOL success = DeleteFileW(bufUTF16);
	return success;
	#else
	// Remove the file
	int failure = unlink(path.c_str());
	return !failure ? true : false;
	#endif
}

bool FileCopy(const string& source, const string& target, bool overwrite) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16_1[1024];
	MultiByteToWideChar(CP_UTF8, 0, source.c_str(), -1, bufUTF16_1, 1024);

	wchar_t bufUTF16_2[1024];
	MultiByteToWideChar(CP_UTF8, 0, target.c_str(), -1, bufUTF16_2, 1024);

	// Copy the file
	BOOL success = CopyFileW(bufUTF16_1, bufUTF16_2, (overwrite ? FALSE : TRUE));
	return success;
	#else
	// Copy the file manually as there is no posix function for this
	bool failure = !FileExists(source);
	if (failure) return false;
	FILE* src = 0, * tgt = 0;
	src = fopen(source.c_str(), "r");
	if (src == 0) failure = true;
	failure = !overwrite && FileExists(target);
	if (!failure) tgt = fopen(target.c_str(), "w");
	if (tgt == 0) failure = true;
	char buf[1024];
	size_t n;
	while (!failure && (n = fread(buf, sizeof(char), sizeof(buf), src)) > 0) {
		if (fwrite(buf, sizeof(char), n, tgt) != n)
			failure = true;
	}
	if (src) fclose(src);
	if (tgt) fclose(tgt);
	return !failure ? true : false;
	#endif
}

bool FileMove(const string& source, const string& target) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16_1[1024];
	MultiByteToWideChar(CP_UTF8, 0, source.c_str(), -1, bufUTF16_1, 1024);

	wchar_t bufUTF16_2[1024];
	MultiByteToWideChar(CP_UTF8, 0, target.c_str(), -1, bufUTF16_2, 1024);

	// Move the file or directory
	BOOL success = MoveFileW(bufUTF16_1, bufUTF16_2);
	return success;
	#else
	// Move the file or directory
	int failure = rename(source.c_str(), target.c_str());
	return !failure ? true : false;
	#endif
}

CDateTime FileGetCreated(const string& path) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);

	// Get the create date/time of the file
	FILETIME createTm;
	HANDLE file = CreateFileW(bufUTF16, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
	BOOL success = GetFileTime(file, &createTm, 0, 0);
	CloseHandle(file);
	if (!success) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx)
			ctx->SetException("Failed to get file creation date/time");
		return CDateTime();
	}
	SYSTEMTIME tm;
	FileTimeToSystemTime(&createTm, &tm);
	return CDateTime(tm.wYear, tm.wMonth, tm.wDay, tm.wHour, tm.wMinute, tm.wSecond);
	#else
	// Get the create date/time of the file
	struct stat st;
	if (stat(path.c_str(), &st) == -1) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx)
			ctx->SetException("Failed to get file creation date/time");
		return CDateTime();
	}
	tm* t = localtime(&st.st_ctime);
	return CDateTime(t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
	#endif
}

CDateTime FileGetModified(const string& path) {
	#if defined(_WIN32)
	// Windows uses UTF16 so it is necessary to convert the string
	wchar_t bufUTF16[1024];
	MultiByteToWideChar(CP_UTF8, 0, path.c_str(), -1, bufUTF16, 1024);
	FILETIME modifyTm;
	// Get the last modify date/time of the file
	HANDLE file = CreateFileW(bufUTF16, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
	BOOL success = GetFileTime(file, 0, 0, &modifyTm);
	CloseHandle(file);
	if (!success) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx)
			ctx->SetException("Failed to get file modify date/time");
		return CDateTime();
	}
	SYSTEMTIME tm;
	FileTimeToSystemTime(&modifyTm, &tm);
	return CDateTime(tm.wYear, tm.wMonth, tm.wDay, tm.wHour, tm.wMinute, tm.wSecond);
	#else
	// Get the last modify date/time of the file
	struct stat st;
	if (stat(path.c_str(), &st) == -1) {
		asIScriptContext* ctx = asGetActiveContext();
		if (ctx)
			ctx->SetException("Failed to get file modify date/time");
		return CDateTime();
	}
	tm* t = localtime(&st.st_mtime);
	return CDateTime(t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
	#endif
}
bool FNMatch(const std::string& file, const std::string& pattern) {
	#ifdef _WIN32
	std::wstring file_u, pattern_u;
	Poco::UnicodeConverter::convert(file, file_u);
	Poco::UnicodeConverter::convert(pattern, pattern_u);
	return PathMatchSpec(file_u.c_str(), pattern_u.c_str());
	#else
	return fnmatch(pattern.c_str(), file.c_str(), 0) == 0;
	#endif
}


void RegisterScriptFileSystemFunctions(asIScriptEngine* engine) {
	assert(engine->GetTypeInfoByName("string"));
	assert(engine->GetTypeInfoByDecl("array<string>"));
	assert(engine->GetTypeInfoByName("datetime"));
	engine->RegisterGlobalFunction("bool directory_exists(const string& in)", asFUNCTION(DirectoryExists), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool directory_create(const string& in)", asFUNCTION(DirectoryCreate), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool directory_delete(const string& in)", asFUNCTION(DirectoryDelete), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_exists(const string& in)", asFUNCTION(FileExists), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_delete(const string& in)", asFUNCTION(FileDelete), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_copy(const string& in, const string& in, bool)", asFUNCTION(FileCopy), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_hard_link(const string& in, const string&in)", asFUNCTION(FileHardLink), asCALL_CDECL);
	engine->RegisterGlobalFunction("int file_hard_link_count(const string& in)", asFUNCTION(FileHardLinkCount), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool file_move(const string& in, const string& in)", asFUNCTION(FileMove), asCALL_CDECL);
	engine->RegisterGlobalFunction("string[]@ find_directories(const string& in)", asFUNCTION(FindDirectories), asCALL_CDECL);
	engine->RegisterGlobalFunction("string[]@ find_files(const string& in)", asFUNCTION(FindFiles), asCALL_CDECL);
	engine->RegisterGlobalFunction("int64 file_get_size(const string& in)", asFUNCTION(FileGetSize), asCALL_CDECL);
	engine->RegisterGlobalFunction("datetime file_get_date_created(const string& in)", asFUNCTION(FileGetCreated), asCALL_CDECL);
	engine->RegisterGlobalFunction("datetime file_get_date_modified(const string& in)", asFUNCTION(FileGetModified), asCALL_CDECL);
	engine->RegisterGlobalFunction("bool fnmatch(const string& in, const string& in)", asFUNCTION(FNMatch), asCALL_CDECL);
}
