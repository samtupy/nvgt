/*
	dbgtools - platform independent wrapping of "nice to have" debug functions.

	https://github.com/wc-duck/dbgtools

	version 0.1, october, 2013

	Copyright (C) 2013- Fredrik Kihlander

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.
	2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.
	3. This notice may not be removed or altered from any source distribution.

	Fredrik Kihlander
 */

#ifndef DBGTOOLS_H_INCLUDED
#define DBGTOOLS_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

/**
 * Return non-zero if a debugger is currently attached to this process.
 *
 * @note this might on some platforms be quite slow.
 */
int debugger_present();
typedef struct
{
	const char*  function; ///< name of function containing address of function.
	const char*  file;     ///< file where symbol is defined, might not work on all platforms.
	unsigned int line;     ///< line in file where symbol is defined, might not work on all platforms.
	unsigned int offset;   ///< offset from start of function where call was made.
} callstack_symbol_t;

/**
 * Generate a callstack from the current location in the code.
 * @param skip_frames number of frames to skip in output to addresses.
 * @param addresses is a pointer to a buffer where to store addresses in callstack.
 * @param num_addresses size of addresses.
 * @return number of addresses in callstack.
 */
int callstack( int skip_frames, void** addresses, int num_addresses );

/**
 * Translate addresses from, for example, callstack to symbol-names.
 * @param addresses list of pointers to translate.
 * @param out_syms list of callstack_symbol_t to fill with translated data, need to fit as many strings as there are ptrs in addresses.
 * @param num_addresses number of addresses in addresses
 * @param memory memory used to allocate strings stored in out_syms.
 * @param mem_size size of addresses.
 * @return number of addresses translated.
 *
 * @note On windows this will load dbghelp.dll dynamically from the following paths:
 *       1) same path as the current module (.exe)
 *       2) current working directory.
 *       3) the usual search-paths ( PATH etc ).
 *
 *       Some thing to be wary of is that if you are using symbol-server functionality symsrv.dll MUST reside together with
 *       the dbghelp.dll that is loaded as dbghelp.dll will only load that from the same path as where it self lives.
 *
 * @note On windows .pdb search paths will be set in the same way as dbghelp-defaults + the current module (.exe) dir, i.e.:
 *       1) same path as the current module (.exe)
 *       2) current working directory.
 *       3) The _NT_SYMBOL_PATH environment variable.
 *       4) The _NT_ALTERNATE_SYMBOL_PATH environment variable.
 *
 * @note On platforms that support it debug-output can be enabled by defining the environment variable DBGTOOLS_SYMBOL_DEBUG_OUTPUT.
 */
int callstack_symbols( void** addresses, callstack_symbol_t* out_syms, int num_addresses, char* memory, int mem_size );

#ifdef __cplusplus
}
#endif  // __cplusplus

#endif // DBGTOOLS_H_INCLUDED


#ifdef DBGTOOLS_IMPLEMENTATION
#undef DBGTOOLS_IMPLEMENTATION

#if defined( __linux )

	int debugger_present()
	{
		FILE* f = fopen( "/proc/self/status", "r" );
		if( f == 0x0 )
			return 0;

		int trace_pid = 0;

		char buffer[1024];
		while(fgets(buffer, 1024, f) != 0x0)
		{
			if (strncmp(buffer, "TracerPid:", 10) == 0)
			{
				trace_pid = atoi(buffer + 10);
				break;
			}
		}

		fclose( f );

		return trace_pid != 0;
	}

#elif defined( _MSC_VER )

	#include <Windows.h>

	int debugger_present()
	{
		return IsDebuggerPresent();
	}

#elif defined( __APPLE__ )

#include <sys/sysctl.h>
#include <unistd.h>

	int debugger_present()
	{
		int mib[4];
		struct kinfo_proc info;
		size_t size;

		info.kp_proc.p_flag = 0;
		mib[0] = CTL_KERN;
		mib[1] = KERN_PROC;
		mib[2] = KERN_PROC_PID;
		mib[3] = getpid();

		size = sizeof(info);
		sysctl( mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0) ;

		return (info.kp_proc.p_flag & P_TRACED) != 0;
	}
#else

	int debugger_present()
	{
		return 0;
	}

#endif
#if !defined(__ANDROID__) && (defined( __unix__ ) || defined(unix) || defined(__unix) || ( defined(__APPLE__) && defined(__MACH__) ))
#  define DBG_TOOLS_CALLSTACK_UNIX
#endif

#if defined( DBG_TOOLS_CALLSTACK_UNIX ) || defined(_MSC_VER)
typedef struct
{
	char* out_ptr;
	const char* end_ptr;
} callstack_string_buffer_t;

static const char* alloc_string( callstack_string_buffer_t* buf, const char* str, size_t str_len )
{
	char* res;

	if( (size_t)(buf->end_ptr - buf->out_ptr) < str_len + 1 )
		return "<callstack buffer out of space!>";

	res = buf->out_ptr;
	buf->out_ptr += str_len + 1;
	memcpy( res, str, str_len );
	res[str_len] = '\0';
	return res;
}
#endif

#if defined( DBG_TOOLS_CALLSTACK_UNIX )
	#include <execinfo.h>
	#include <unistd.h>
	#include <cxxabi.h>

	int callstack( int skip_frames, void** addresses, int num_addresses )
	{
		++skip_frames;
		void* trace[256];
		int fetched = backtrace( trace, num_addresses + skip_frames ) - skip_frames;
		memcpy( addresses, trace + skip_frames, (size_t)fetched * sizeof(void*) );
		return fetched;
	}

#if defined(__linux)
	#include <stdint.h>

	static uint16_t read_elf_type_from_self()
	{
		uint16_t type = 0;

		// lets check our own elf-type, first open our own exe!
		FILE* f = fopen("/proc/self/exe", "r");
		if(f)
		{
			// we only need header-data at the start of the exe.
			// more to the point, 2 bytes at offset 0x10 that is
			// the elf-type.
			// https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#File_header
			char elf_header[0x10 + 2] = {0};
			size_t read = fread(elf_header, sizeof(elf_header), 1, f);
			fclose(f);

			if(read == 1)
				memcpy(&type, elf_header + 0x10, sizeof(type));
		}

		return type;
	}

	// detect if the current running exe is compiled as PIE.
	// https://en.wikipedia.org/wiki/Position-independent_code
	// if it does we need to translate all addresses that we are going to
	// lookup with the help of the address-maps in /proc/self/maps, if not
	// we should not do that.
	static int is_using_pie()
	{
		// elf-type for shared object/PIE-executable
		const uint16_t ET_DYN = 0x03;
		return read_elf_type_from_self() == ET_DYN;
	}

	typedef struct mmap_entry_t {
		struct mmap_entry_t *next;

		unsigned long range_start;
		unsigned long range_end;
		unsigned long file_offset;
	} mmap_entry_t;

	static mmap_entry_t *parse_mmaps(const char *maps_file)
	{
		FILE* maps = fopen(maps_file, "r");
		if(!maps){
			perror("fopen");
			fprintf(stderr, "failed to open %s\n", maps_file);
			return NULL;
		}

		mmap_entry_t *first = NULL;
		mmap_entry_t *cur = NULL;

		while(!feof(maps)){
			char buf[4096];
			char *ret = fgets(buf, 4096, maps);
			if(!ret)
				break;

			mmap_entry_t *next = (mmap_entry_t*) malloc(sizeof(mmap_entry_t));
			next->next = NULL;

			// from man `proc`:
			// address perms offset dev inode pathname
			sscanf(buf, "%lx-%lx %*s %lx",
				&next->range_start,
				&next->range_end,
				&next->file_offset
			);

			if(!first){
				first = next;
				cur   = next;
			} else {
				cur->next = next;
				cur       = next;
			}
		}

		fclose(maps);

		return first;
	}

	static void mmap_free(mmap_entry_t *mmap)
	{
		while(mmap){
			mmap_entry_t *tmp = mmap->next;
			free(mmap);
			mmap = tmp;
		}
	}

	static void *mmap_translate(mmap_entry_t *mmap, void *addr)
	{
		for(; mmap != NULL; mmap = mmap->next){
			unsigned long addr_i = (unsigned long)addr;
			if(addr_i >= mmap->range_start && addr_i <= mmap->range_end)
				return (void*) (addr_i - mmap->range_start + mmap->file_offset);
		}

		return addr;
	}

	static FILE* run_addr2line( void** addresses, int num_addresses, char* tmp_buffer, size_t tmp_buf_len )
	{
		mmap_entry_t* list = is_using_pie() 
								? parse_mmaps("/proc/self/maps")
								: 0x0;

		size_t start = (size_t)snprintf( tmp_buffer, tmp_buf_len, "addr2line -e /proc/%u/exe", getpid() );
		for( int i = 0; i < num_addresses; ++i ){
			// Translate addresses out of potentially ASLR'd VMA space
			void *addr = mmap_translate(list, addresses[i]);

			start += (size_t)snprintf( tmp_buffer + start, tmp_buf_len - start, " %p", addr );
		}

		mmap_free(list);

		return popen( tmp_buffer, "r" );
	}
#elif defined(__APPLE__) && defined(__MACH__)
	static FILE* run_addr2line( void** addresses, int num_addresses, char* tmp_buffer, size_t tmp_buf_len )
	{
		size_t start = (size_t)snprintf( tmp_buffer, tmp_buf_len, "xcrun atos -p %u -l", getpid() );
		for( int i = 0; i < num_addresses; ++i )
			start += (size_t)snprintf( tmp_buffer + start, tmp_buf_len - start, " %p", addresses[i] );

		return popen( tmp_buffer, "r" );
	}
#else
#   error "Unhandled platform"
#endif


	static char* demangle_symbol( char* symbol, char* buffer, size_t buffer_size )
	{
		int status;
		char* demangled_symbol = abi::__cxa_demangle( symbol, buffer, &buffer_size, &status );
		return status != 0 ? symbol : demangled_symbol;
	}

	int callstack_symbols( void** addresses, callstack_symbol_t* out_syms, int num_addresses, char* memory, int mem_size )
	{
		int num_translated = 0;
		callstack_string_buffer_t outbuf = { memory, memory + mem_size };
		memset( out_syms, 0x0, (size_t)num_addresses * sizeof(callstack_symbol_t) );

		char** syms = backtrace_symbols( addresses, num_addresses );
		size_t tmp_buf_len = 1024 * 32;
		char*  tmp_buffer  = (char*)malloc( tmp_buf_len );

		FILE* addr2line = run_addr2line( addresses, num_addresses, tmp_buffer, tmp_buf_len );

		for( int i = 0; i < num_addresses; ++i )
		{
			char* symbol = syms[i];
			unsigned int offset = 0;

			// find function name and offset
		#if defined(__linux)
			char* name_start   = strchr( symbol, '(' );
			char* offset_start = name_start ? strchr( name_start, '+' ) : 0x0;

			if( name_start && offset_start )
			{
				// zero terminate all strings
				++name_start;
				*offset_start = '\0'; ++offset_start;
			}
		#elif defined(__APPLE__) && defined(__MACH__)
			char* name_start   = 0x0;
			char* offset_start = strrchr( symbol, '+' );
			if( offset_start )
			{
				offset_start[-1] = '\0'; ++offset_start;
				name_start = strrchr( symbol, ' ' );
				if( name_start )
					++name_start;
			}
		#else
		#  error "Unhandled platform"
		#endif

			if( name_start && offset_start )
			{
				offset = (unsigned int)strtoll( offset_start, 0x0, 16 );
				symbol = demangle_symbol( name_start, tmp_buffer, tmp_buf_len );
			}

			out_syms[i].function = alloc_string( &outbuf, symbol, strlen( symbol ) );
			out_syms[i].offset   = offset;
			out_syms[i].file = "failed to lookup file";
			out_syms[i].line = 0;

			if( addr2line != 0x0 )
			{
				if( fgets( tmp_buffer, (int)tmp_buf_len, addr2line ) != 0x0 )
				{
				#if defined(__linux)
					char* line_start = strchr( tmp_buffer, ':' );
					*line_start = '\0';

					if( tmp_buffer[0] != '?' && tmp_buffer[1] != '?' )
						out_syms[i].file = alloc_string( &outbuf, tmp_buffer, strlen( tmp_buffer ) );
					out_syms[i].line = (unsigned int)strtoll( line_start + 1, 0x0, 10 );
				#elif defined(__APPLE__) && defined(__MACH__)
					char* file_start = strrchr( tmp_buffer, '(');
					if( file_start )
					{
						++file_start;
						char* line_start = strchr( file_start, ':' );
						if( line_start )
						{
							*line_start = '\0';
							++line_start;

							out_syms[i].file = alloc_string( &outbuf, file_start, strlen( file_start ) );
							out_syms[i].line = (unsigned int)strtoll( line_start, 0x0, 10 );
						}
					}
				#else
				#  error "Unhandled platform"
				#endif
				}
			}

			++num_translated;
		}
		free( syms );
		free( tmp_buffer );
		fclose( addr2line );
		return num_translated;
	}

#elif defined(_MSC_VER)
#  if defined(__clang__)
	// when compiling with clang on windows, silence warnings from windows-code
#    pragma clang diagnostic push
#    pragma clang diagnostic ignored "-Wunknown-pragmas"
#    pragma clang diagnostic ignored "-Wignored-pragma-intrinsic"
#  endif
#  include <Windows.h>
#  if defined(__clang__)
#    pragma clang diagnostic pop
#  endif
	#include <Dbghelp.h>

	int callstack( int skip_frames, void** addresses, int num_addresses )
	{
		return RtlCaptureStackBackTrace( skip_frames + 1, num_addresses, addresses, 0 );
	}

	typedef BOOL  (__stdcall *SymInitialize_f)( _In_ HANDLE hProcess, _In_opt_ PCSTR UserSearchPath, _In_ BOOL fInvadeProcess );
	typedef BOOL  (__stdcall *SymFromAddr_f)( _In_ HANDLE hProcess, _In_ DWORD64 Address, _Out_opt_ PDWORD64 Displacement, _Inout_ PSYMBOL_INFO Symbol );
	typedef BOOL  (__stdcall *SymGetLineFromAddr64_f)( _In_ HANDLE hProcess, _In_ DWORD64 qwAddr, _Out_ PDWORD pdwDisplacement, _Out_ PIMAGEHLP_LINE64 Line64 );
	typedef DWORD (__stdcall *SymSetOptions_f)( _In_ DWORD SymOptions );

	static struct
	{
		int initialized;
		int init_ok;
		SymInitialize_f        SymInitialize;
		SymFromAddr_f          SymFromAddr;
		SymGetLineFromAddr64_f SymGetLineFromAddr64;
		SymSetOptions_f        SymSetOptions;
	}
	dbghelp = { 0, 0, 0, 0, 0, 0 };

	static HMODULE callstack_symbols_find_dbghelp()
	{
		// ... try to find dbghelp.dll in the same directory as the executable ... 
		HMODULE mod;
		DWORD module_path_len;
		char module_path[4096];

		module_path_len = GetModuleFileNameA((HMODULE)0, module_path, sizeof(module_path));
		if (module_path_len > 0)
		{
			char* slash = strrchr(module_path, '\\');
			if (slash)
				*(slash + 1) = '\0';
			strncat(module_path, "dbghelp.dll", sizeof(module_path) - strlen(module_path) - 1);

			mod = LoadLibraryA(module_path);
			if (mod)
				return mod;
		}

		// ... try to find dbghelp.dll in the current working directory ... 
		module_path_len = GetCurrentDirectoryA( sizeof(module_path), module_path );
		if (module_path_len > 0)
		{
			strncat(module_path, "\\dbghelp.dll", sizeof(module_path) - strlen(module_path) - 1);

			mod = LoadLibraryA(module_path);
			if (mod)
				return mod;
		}

		// ... fallback to the "normal" search-paths ...
		return LoadLibraryA("dbghelp.dll");
	}

	static void callstack_symbols_build_search_path(char* search_path, int length)
	{
		// by default dbghelp will build a search-path by concatenating:
		// - The current working directory of the application
		// - The _NT_SYMBOL_PATH environment variable
		// - The _NT_ALTERNATE_SYMBOL_PATH environment variable
		//
		// let's do the same thing but also add the directory where the running
		// module lives.
		DWORD mod;
		char env_var[4096];

		search_path[0] = '\0';

		mod = GetModuleFileNameA((HMODULE)0, search_path, length);
		if (mod > 0)
		{
			char* slash = strrchr(search_path, '\\');
			if(slash)
				*slash = '\0';
		}
		else
		{
			search_path[0] = '\0';
		}

		if (length > 2)
		{
			if (search_path[0] != '\0')
				strncat(search_path, ";", length);
			strncat(search_path, ".", length);
		}

		mod = GetEnvironmentVariableA("_NT_SYMBOL_PATH", env_var, sizeof(env_var));
		if (mod > 0 && mod < sizeof(env_var))
		{
			if (search_path[0] != '\0')
				strncat(search_path, ";", length);
			strncat(search_path, env_var, length);
		}

		mod = GetEnvironmentVariableA("_NT_ALTERNATE_SYMBOL_PATH", env_var, sizeof(env_var));
		if (mod > 0 && mod < sizeof(env_var))
		{
			if (search_path[0] != '\0')
				strncat(search_path, ";", length);
			strncat(search_path, env_var, length);
		}
	}

	static int callstack_symbols_initialize()
	{
		HANDLE  process;
		HMODULE mod;
		BOOL    res;
		DWORD   err;

		if(!dbghelp.initialized)
		{
			mod = callstack_symbols_find_dbghelp();
			if (mod)
			{
				dbghelp.SymInitialize        = (SymInitialize_f)GetProcAddress(mod, "SymInitialize");
				dbghelp.SymFromAddr          = (SymFromAddr_f)GetProcAddress(mod, "SymFromAddr");
				dbghelp.SymGetLineFromAddr64 = (SymGetLineFromAddr64_f)GetProcAddress(mod, "SymGetLineFromAddr64");
				dbghelp.SymSetOptions        = (SymSetOptions_f)GetProcAddress(mod, "SymSetOptions");
			}

			// ... symbols fetched ok ...
			if( dbghelp.SymInitialize &&
				dbghelp.SymFromAddr &&
				dbghelp.SymGetLineFromAddr64 &&
				dbghelp.SymSetOptions)
			{
				// ... enable debug-output if needed ...
				if (GetEnvironmentVariableA("DBGTOOLS_SYMBOL_DEBUG_OUTPUT", 0, 0) > 0)
					dbghelp.SymSetOptions(SYMOPT_DEBUG);

				// ... generate the same search-paths for pdbs as default, just add our executable directory as well ...
				char search_path[4096];
				callstack_symbols_build_search_path(search_path, sizeof(search_path)-1);

				// ... initialize sym system ...
				process = GetCurrentProcess();
				res = dbghelp.SymInitialize(process, search_path, TRUE);

				dbghelp.init_ok = 1;
				if (res == 0)
				{
					err = GetLastError();
					// ERROR_INVALID_PARAMETER seems to be returned IF symbols for a specific module could not be loaded.
					// However the lookup will still work for all other symbols so let us ignore this error!
					if (err != ERROR_INVALID_PARAMETER)
						dbghelp.init_ok = 0;
				}
			}
		}

		dbghelp.initialized = 1;
		return dbghelp.init_ok;
	}

	int callstack_symbols( void** addresses, callstack_symbol_t* out_syms, int num_addresses, char* memory, int mem_size )
	{
		HANDLE          process;
		DWORD64         offset;
		DWORD           line_dis;
		BOOL            res;
		IMAGEHLP_LINE64 line;
		PSYMBOL_INFO    sym_info;
		char buffer[sizeof(SYMBOL_INFO) + MAX_SYM_NAME * sizeof(TCHAR)];
		int num_translated = 0;
		callstack_string_buffer_t outbuf = { memory, memory + mem_size };

		memset( out_syms, 0x0, (size_t)num_addresses * sizeof(callstack_symbol_t) );



		if( !callstack_symbols_initialize() )
		{
			out_syms[0].function = "failed to initialize dbghelp.dll";
			out_syms[0].offset   = 0;
			out_syms[0].file     = "";
			out_syms[0].line     = 0;
			return 1;
		}

		process = GetCurrentProcess();
		sym_info  = (PSYMBOL_INFO)buffer;
		sym_info->SizeOfStruct = sizeof(SYMBOL_INFO);
		sym_info->MaxNameLen   = MAX_SYM_NAME;

		line.SizeOfStruct = sizeof(IMAGEHLP_LINE64);

		for( int i = 0; i < num_addresses; ++i )
		{
			res = dbghelp.SymFromAddr( process, (DWORD64)addresses[i], &offset, sym_info );
			if( res == 0 )
				out_syms[i].function = "failed to lookup symbol";
			else
				out_syms[i].function = alloc_string( &outbuf, sym_info->Name, sym_info->NameLen );

			res = dbghelp.SymGetLineFromAddr64( process, (DWORD64)addresses[i], &line_dis, &line );
			if( res == 0 )
			{
				out_syms[i].offset = 0;
				out_syms[i].file   = "failed to lookup file";
				out_syms[i].line   = 0;
			}
			else
			{
				out_syms[i].offset = (unsigned int)line_dis;
				out_syms[i].file   = alloc_string( &outbuf, line.FileName, strlen( line.FileName ) );
				out_syms[i].line   = (unsigned int)line.LineNumber;
			}

			++num_translated;
		}
		return num_translated;
	}

#else

	int callstack( int skip_frames, void** addresses, int num_addresses )
	{
		(void)skip_frames; (void)addresses; (void)num_addresses;
		return 0;
	}

	int callstack_symbols( void** addresses, callstack_symbol_t* out_syms, int num_addresses, char* memory, int mem_size )
	{
		(void)addresses; (void)out_syms; (void)num_addresses; (void)memory; (void)mem_size;
		return 0;
	}

#endif

#if defined( DBG_TOOLS_CALLSTACK_UNIX )
#  undef DBG_TOOLS_CALLSTACK_UNIX
#endif

#endif
