//
// Code for VS_VERSION resource
//

#pragma once
#include <cassert>
#include <stdio.h>
#include <windows.h>
// Defs for Windows version resource
// http://msdn.microsoft.com/en-us/library/ms646997(VS.85).aspx
#define _MAX_VERS_SIZE_CB 4096
#define _MAX_VER_STRING_LEN_CCH 255
#define _MAX_VER_CUSTOM_STRINGS 16
#define _A_MAX_N_RES 8
#define _A_MAX_RES_CB (500*1024)

#if ( 1 && !defined(DEF_COMPANY_NAME) )
#define DEF_COMPANY_NAME	_T(" ")
#define DEF_COPYRGT			_T("Copyright (c) 2016")
#define DEF_PRODUCT_NAME	_T(" ")
#endif

#define dprint(fmt, ...) printf(fmt, __VA_ARGS__)
#define dtprint(tfmt, ...) _tprintf(tfmt, __VA_ARGS__)

#define ASSERT assert

#ifndef _A_NOISE_DBG
#define _A_NOISE_DBG 1
#endif

#if _A_NOISE_DBG
#define d2print(fmt, ...) dprint(fmt, __VA_ARGS__)
#define d2tprint(tfmt, ...) dtprint(tfmt,  __VA_ARGS__)
#else
#define d2print(fmt, ...) __noop(fmt, __VA_ARGS__)
#define d2tprint(tfmt, ...) __noop(tfmt, __VA_ARGS__)
#endif //_A_NOISE_DBG

#if ( _A_NOISE_DBG > 1 )
#define d3print d2print
#define d3tprint d2tprint
#else
#define d3print(fmt, ...) __noop(fmt, __VA_ARGS__)
#define d3tprint(tfmt, ...) __noop(tfmt, __VA_ARGS__)
#endif //_A_NOISE_DBG
// strdup likes: 
LPWSTR stralloc( __in PCSTR s );
LPWSTR stralloc( __in PCWSTR s );

// Stupid helper classes for the version struct
class yybuf 
{
	PUCHAR m_startptr;
	PUCHAR m_curptr;
	int m_inisize;

	public:
	yybuf( PUCHAR start, unsigned size )
		: m_startptr(start), m_inisize(size), m_curptr(start)
	{
		ASSERT(((ULONG_PTR)start & 3) == 0); // must be aligned on 4
	}

	void align4() { 
		PULONG_PTR x = (PULONG_PTR)&m_curptr;
		*x += 3;
		*x &= ~(ULONG_PTR)3;
	}

	int cbwritten(void) { return m_curptr - m_startptr; }

	void checkspace( int n = 8 ) { 
        if ( cbwritten() + n > m_inisize ) {
#		ifndef NDEBUG
		__debugbreak();
#		endif
		throw ":checkspace";
        }
	}

	void pushw( WORD v ) {
		*(PWORD)m_curptr = v;
		m_curptr += sizeof(WORD);
	}

	void pushd( DWORD v ) {
		*(PDWORD)m_curptr = v;
		m_curptr += sizeof(DWORD);
	}

	void pushstr( __in LPCWSTR ws, bool b_align = TRUE ) {
		if ( !ws ) return;
		WORD n = wcslen( ws );
		ASSERT( n < _MAX_VER_STRING_LEN_CCH );
		n = (n + 1) * sizeof(WCHAR);
		checkspace(n + sizeof(DWORD));
		memcpy( m_curptr, ws, n );
		m_curptr += n;
		if (b_align)
			align4();
	}

	PUCHAR getptr() { return m_curptr;}

	void incptr( int n ) { checkspace(n); m_curptr += n; }

	PWORD marksize() { return (PWORD)m_curptr; }

	void patchsize ( PWORD mp ) { 
		WORD cb = getptr() - (PUCHAR)mp;
		*mp = cb;
	};

	void push_twostr( const wchar_t* name, const wchar_t* value )
	{
	//struct String { 
	//  WORD   wLength; 
	//  WORD   wValueLength; 
	//  WORD   wType; 
	//  WCHAR  szKey[]; 
	//  WORD   Padding[]; 
	//  WORD   Value[]; 
	//};
		WORD wValueLength = value ? (WORD)wcslen(value) : 0;
        WORD wValueSize = (WORD)( wValueLength ? (wValueLength + 1) * sizeof(WCHAR) : 0 );
		WORD wNameSize = (WORD)((wcslen(name) + 1 ) * sizeof(WCHAR));
		ASSERT(wNameSize > sizeof(WCHAR));

		checkspace( wValueSize + wNameSize + 5*sizeof(WORD));

		PWORD porig = marksize();
		pushw(-1); //length, patch
        //Add extra null wchar to value to compensate for VerQueryValueA behavior
		pushw( wValueLength + 1);
		pushw( 1 ); //type
		pushstr( name ); // with align
		if ( wValueLength )
			pushstr( value, false ); // don't align yet
        *m_curptr++ = 0; // add 2 zero bytes
        *m_curptr++ = 0;
		patchsize(porig);
		align4();
	}

}; // class

class xybuf 
{
	PUCHAR m_startptr;
	PUCHAR m_curptr;
	int m_inisize;

	public:
	xybuf( PUCHAR start, unsigned size )
		: m_startptr(start), m_inisize(size), m_curptr(start)
	{ 
		ASSERT(((ULONG_PTR)start & 3) == 0); // must be aligned on 4
	}

	void align4() { 
		PULONG_PTR x = (PULONG_PTR)&m_curptr;
		*x += 3;
		*x &= ~(ULONG_PTR)3;
	}

	int cbread(void) { return m_curptr - m_startptr; }

	void checkspace( int n = 8 ) { 
		if ( cbread() + n > m_inisize )
			throw ":overrun read";
	}

	PUCHAR getptr() { return m_curptr;}

	void incptr( int n ) { checkspace(n); m_curptr += n; }

	PWORD marksize() { PWORD p = (PWORD)m_curptr; m_curptr += sizeof(WORD); return p; }

	BOOL chksize( PWORD mp, bool b_nothrow = false ) { 
		// check size of block is correct
		WORD cb = getptr() - (PUCHAR)mp;
		if (*mp != cb ) {
			if ( !b_nothrow ) throw ":chksize";
			return FALSE;
		}
		return TRUE;
	};

	void chkword( WORD v ) {
		if (*(PWORD)m_curptr != v)
			throw ":chkword";
		m_curptr += sizeof(WORD);
	}

    // Added for compatibility with Borland (Embarcadero) C++ Builder
    // Check version word of certain structures, which can be 0 with BC++.
    void chkword_opt( WORD v ) {
        if ((*(PWORD)m_curptr != v) && (*(PWORD)m_curptr != 0))
            throw ":chkword";
        m_curptr += sizeof(WORD);
    }

	void chkdword( DWORD v ) {
		if (*(PDWORD)m_curptr != v)
			throw ":chkdword";
		m_curptr += sizeof(DWORD);
	}

	void chkstr( __in LPCWSTR ws, bool b_align = TRUE ) {
		WORD n = wcslen( ws );
		ASSERT ( n );
		ASSERT( n < _MAX_VER_STRING_LEN_CCH );
		checkspace((n + 1) * sizeof(WCHAR) + sizeof(DWORD));

		for (int i = 0; i <= n; i++ ) { // incl. term. 0
			if ( *(PWCHAR)m_curptr != *ws &&
				 *(PWCHAR)m_curptr != (*ws ^ 0x20) )
				throw ":chkstr";
			m_curptr += sizeof(WCHAR);
			ws++;
		}

		if (b_align)
			align4();
	}

	void pullTwoStr( __out LPCWSTR *wsname, __out LPCWSTR *wsval )
	{
		//struct String { 
		//  WORD   wLength; 
		//  WORD   wValueLength; 
		//  WORD   wType; 
		//  WCHAR  szKey[]; 
		//  WORD   Padding[]; 
		//  WORD   Value[]; 
		//};
		checkspace(5*sizeof(WORD));
		PWORD porig = marksize();

		WORD wLength = *porig;
		if ( wLength > 1024 || wLength < 5*sizeof(WORD))
			throw ":string desc size bad";
		checkspace(5*sizeof(WORD) + wLength);
		WORD wValueLength = *((PWORD)m_curptr);
		incptr(2);
		chkword(1); //type

		size_t nLength = wcsnlen( (LPWSTR)( getptr() ), wLength/sizeof(WCHAR) );
		if (nLength == 0 || nLength == (wLength/sizeof(WCHAR)) )
			throw ":string name len bad";
		*wsname = (LPCWSTR)getptr(); //should point to name
		unsigned bLength = (nLength + 1)*sizeof(WCHAR);
		incptr( bLength );
		align4(); //padding

		if ( getptr() >= (PUCHAR)porig + *porig ) {
			// null value
			*wsval = L"";
			return;
		}

		wLength -= bLength;
		nLength = wcsnlen( LPWSTR( getptr() ), wLength/sizeof(WCHAR) );
		if ( nLength == (wLength/sizeof(WCHAR)) )
			throw ":string val name len bad";
		
		if ( nLength == 0) {
			// Empty value
			*wsval = L"";
		} else {
			*wsval = (LPCWSTR)getptr(); //should point to value
		}

        bLength = (nLength + 1)*sizeof(WCHAR);
		// can be padded after 0 term

		m_curptr = (PUCHAR)porig + *porig;
		align4(); //padding
	}

}; //class

#if 1
// a stupid string helper class.
// this doesn't run 24*7, so allow memory leaks...
class _xpwstr {
	PWSTR m_str;

	public:
	void operator = (PCWSTR s ) {
		if ( m_str )
			free( m_str );
		m_str = NULL;
		if (s)
			m_str = stralloc( s );
	}

	operator PCWSTR() const { return (PCWSTR)m_str; } 

	_xpwstr() : m_str(NULL) { }
	~_xpwstr() { if (m_str) free( m_str ); }
};

typedef _xpwstr ASTR;
#else
typedef CString ASTR;
#endif

// Data for a vs_version resource
struct file_ver_data_s {
	USHORT v_1, v_2, v_3, v_4;		// Version components 1-4
	USHORT pv_1, pv_2, pv_3, pv_4;  // Product Version components 1-4
	UINT32 dwFileType, dwFileSubType;
	UINT32 dwFileFlags;
	WORD langid;			// language
	ASTR sFileVerTail;		// suffix after file version numbers
	ASTR sProductVerTail;	// same for product ver.
	ASTR sProductVerOverride;	// product ver. string override
	char cFileVerTailSeparator; // separator of version suffix: '-+' or space or 0 (none)
    char cProductVerTailSeparator; // same for product ver.
    UINT nFileVerParts, nProductVerParts; // number of significant parts in version. use with /high

	// Strings
	ASTR CustomStrNames[_MAX_VER_CUSTOM_STRINGS];
	ASTR CustomStrVals[_MAX_VER_CUSTOM_STRINGS];

	bool addTwostr( __in_opt PCWSTR name, __in_opt PCWSTR val ) 
	{
		if ( !name )
			return false;

		int index = -1;
		for (int i = 0; i < ARRAYSIZE(CustomStrNames); i++) {
			if ( !CustomStrNames[i] ) {
				if (index == -1) index = i;
				continue;
			}
			if ( 0 == _wcsicmp( name, CustomStrNames[i] ) ) {
				index = i;
				d3print("replacing dup string in ver resource: %ws\n", (PCWSTR)name);
				break;
			}
		}

		if ( index != -1 ) {
			CustomStrNames[index] = name;
			CustomStrVals[index] = val; // can be 0
			return true;
		}

		dprint("Too many strings in ver resource! not added %ws\n", name);
		return false;
	}

	PCWSTR getValStr( __in PCWSTR name )
	{
		for (int i = 0; i < ARRAYSIZE(CustomStrNames); i++) {
			PCWSTR s = CustomStrNames[i];
			if ( s && (0 == _wcsicmp(name, s) ) )
				return CustomStrVals[i];
		}
		return NULL;
	}
};

BOOL makeVersionResource( __in file_ver_data_s const * fvd, __out PUCHAR *retp );
