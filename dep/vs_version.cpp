//
// Code for VS_VERSION resource
//
#define _UNICODE
#define UNICODE
#include <stdlib.h>
#include <string.h>
#include <strsafe.h>
#include <tchar.h>
#include "vs_version.h"

/// Make a version resource from file_ver_data_s
BOOL makeVersionResource( __in file_ver_data_s const * fvd, __out PUCHAR *retp )
{
	PUCHAR palloc = (PUCHAR)calloc(_MAX_VERS_SIZE_CB, 1);
	yybuf vbuf( palloc, _MAX_VERS_SIZE_CB );
	unsigned cbWritten = 0;
	BOOL ok = FALSE;
	WCHAR temps[_MAX_VER_STRING_LEN_CCH + 1];

	try {

		// Fill the res header
//		struct VS_VERSIONINFO { 
//		WORD  wLength; 
//		WORD  wValueLength; 
//		WORD  wType; 
//		WCHAR szKey[]; 
//		WORD  Padding1[]; 
//		VS_FIXEDFILEINFO Value; 
//		WORD  Padding2[]; 
//		WORD  Children[]; 
//		};

		PWORD pTotalLen = vbuf.marksize();
		vbuf.pushw(~0); // wLength <-FIXUP LATER
		vbuf.pushw( sizeof(VS_FIXEDFILEINFO) ); //wValueLength=0x34
		vbuf.pushw( 0 ); //wType
		vbuf.pushstr( L"VS_VERSION_INFO" ); // szKey, Padding1

		// Fixed info
		VS_FIXEDFILEINFO *fxi = (VS_FIXEDFILEINFO *)vbuf.getptr();
		fxi->dwSignature = 0xfeef04bd; // magic
		fxi->dwStrucVersion = VS_FFI_STRUCVERSION; //0x00010000
		fxi->dwFileVersionMS = MAKELONG( fvd->v_2, fvd->v_1 );
		fxi->dwFileVersionLS = MAKELONG( fvd->v_4, fvd->v_3 );
		fxi->dwProductVersionMS = MAKELONG( fvd->pv_2, fvd->pv_1 );
		fxi->dwProductVersionLS = MAKELONG( fvd->pv_4, fvd->pv_3 );
		fxi->dwFileFlagsMask = VS_FFI_FILEFLAGSMASK; //0x3F;
		fxi->dwFileFlags = fvd->dwFileFlags;
		fxi->dwFileOS = VOS_NT_WINDOWS32;
		fxi->dwFileType = fvd->dwFileType;
		fxi->dwFileSubtype = fvd->dwFileSubType;
		if ( 0 == fxi->dwFileType && 0 != fxi->dwFileSubtype )
			fxi->dwFileType = VFT_DRV;
		fxi->dwFileDateLS = 0; //unused?
		fxi->dwFileDateMS = 0; //
		vbuf.incptr( sizeof(VS_FIXEDFILEINFO) );
		vbuf.align4(); // Padding2

		// String File Info

		PWORD stringStart = vbuf.marksize();
		vbuf.pushw(~0); //wLength FIXUP LATER
		vbuf.pushw(0); //wValueLength
		vbuf.pushw(1); //wType
		vbuf.pushstr( L"StringFileInfo" );

        PWORD stringTableStart = vbuf.marksize();
		vbuf.pushw(~0); //wLength FIXUP LATER
		vbuf.pushw(0); // ?
		vbuf.pushw(1); //wType
        HRESULT hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%4.4X04B0", fvd->langid );  /* "040904B0" = LANG_ENGLISH/SUBLANG_ENGLISH_US, Unicode CP */
        ASSERT( SUCCEEDED(hr) );
		vbuf.pushstr( temps );

		// File version as string. Not shown by Vista, Win7.
        switch ( fvd->nFileVerParts ) {
            case 1:
                hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%u", fvd->v_1 );
                break;
            case 2:
                hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%u.%u", fvd->v_1, fvd->v_2 );
                break;
            case 3:
                hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%u.%u.%u",
                    fvd->v_1, fvd->v_2, fvd->v_3 );
                break;
            default:
		        hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%u.%u.%u.%u",
			        fvd->v_1, fvd->v_2, fvd->v_3, fvd->v_4 );
        }

		if ( !SUCCEEDED(hr) ) temps[0] = 0;
        
		if ( fvd->sFileVerTail ) {
            if ( fvd->cFileVerTailSeparator ) {
                WCHAR tailsep[2] = {(wchar_t)fvd->cFileVerTailSeparator, 0};
			    hr = ::StringCbCatW(&temps[0], sizeof(temps), tailsep);
            }
			hr = ::StringCbCatW(&temps[0], sizeof(temps), fvd->sFileVerTail);
			if ( !SUCCEEDED(hr) ) temps[0] = 0;
		}
		vbuf.push_twostr( L"FileVersion", &temps[0] );

        switch ( fvd->nProductVerParts ) {
            case 1:
                hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%u", fvd->pv_1 );
                break;
            case 2:
                hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%u.%u", fvd->pv_1, fvd->pv_2 );
                break;
            case 3:
                hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%u.%u.%u",
                    fvd->pv_1, fvd->pv_2, fvd->pv_3);
                break;
            default:
		        hr = ::StringCbPrintfW( &temps[0], sizeof(temps), L"%u.%u.%u.%u",
			        fvd->pv_1, fvd->pv_2, fvd->pv_3, fvd->pv_4 );
        }

		if ( !SUCCEEDED(hr) ) temps[0] = 0;
		if ( fvd->sProductVerTail ) {
            if ( fvd->cProductVerTailSeparator ) {
                WCHAR tailsep[2] = {(wchar_t)fvd->cProductVerTailSeparator, 0};
			    hr = ::StringCbCatW(&temps[0], sizeof(temps), tailsep);
            }
			hr = ::StringCbCatW(&temps[0], sizeof(temps), fvd->sProductVerTail);
			if ( !SUCCEEDED(hr) ) temps[0] = 0;
		}

		if (fvd->sProductVerOverride)
		{
			d2print("Overriding Product version:[%ws]\n", (PCWSTR)fvd->sProductVerOverride);
			vbuf.push_twostr(L"ProductVersion", fvd->sProductVerOverride);
		}
		else
		{
			vbuf.push_twostr(L"ProductVersion", &temps[0]);
		}
	
		// Strings
		for ( int k = 0; k < ARRAYSIZE(fvd->CustomStrNames); k++ ) {
			if ( fvd->CustomStrNames[k] != NULL ) {

				vbuf.push_twostr( fvd->CustomStrNames[k], fvd->CustomStrVals[k] );

				if ( 0 == _wcsicmp( L"SpecialBuild", fvd->CustomStrNames[k] ) )
					fxi->dwFileFlags |= VS_FF_SPECIALBUILD;
				if ( 0 == _wcsicmp( L"PrivateBuild",fvd->CustomStrNames[k] ) )
					fxi->dwFileFlags |= VS_FF_PRIVATEBUILD;
			}
		}

		vbuf.patchsize( stringTableStart );
		vbuf.patchsize( stringStart );
		vbuf.align4();

		// Var info
//struct VarFileInfo { 
//  WORD  wLength; 
//  WORD  wValueLength; 
//  WORD  wType; 
//  WCHAR szKey[]; 
//  WORD  Padding[]; 
//  Var   Children[]; 
		PWORD varStart = vbuf.marksize();
		vbuf.pushw(~0); // size, patch
		vbuf.pushw(0);
		vbuf.pushw(1);
		vbuf.pushstr( L"VarFileInfo" );

		vbuf.pushw(0x24);
		vbuf.pushw(0x04);
		vbuf.pushw(0x00);
		vbuf.pushstr( L"Translation" );
		vbuf.pushw( fvd->langid );
		vbuf.pushw( 0x04B0 );   // 0x04B0 = 1200 = Unicode CP

		vbuf.patchsize( varStart );
		/////////////////////////////
		vbuf.patchsize(pTotalLen);
		vbuf.checkspace(); 

		ok = TRUE;
	} catch(...) {
		ok = FALSE;
	}

	if (ok) {
		d3print("ver size= %d\n", vbuf.cbwritten() );
		*retp = palloc;
	} else {
		dprint("error in %s\n", __FUNCTION__);
		free( palloc );
	}

	return ok;
}

LPWSTR stralloc( __in PCSTR s )
{
	ASSERT(s);
	size_t n = strlen(s);
	ASSERT( n < (256));
	LPWSTR p = (LPWSTR)malloc( (n + 1) * sizeof(WCHAR) );
	ASSERT( p );
	for ( size_t i = 0; i <= n; i++ )
		p[i] = s[i];
	return p;
}

LPWSTR stralloc( __in PCWSTR s )
{
	ASSERT(s);
	PWSTR p = _wcsdup(s);
	ASSERT(p);
	return p;
}

// return byte offset to name and .ext parts of filename
BOOL fileGetNameExtFromPath( __in PCTSTR path, __out PUINT pname, __out PUINT pext )
{
	ASSERT(path);
	PTSTR name = (PTSTR)calloc( 2*MAX_PATH, sizeof(TCHAR));
	ASSERT(name);
	PTSTR ext = name + MAX_PATH;

	errno_t e;
	e = _tsplitpath_s(path, NULL, 0 , NULL, 0, name, MAX_PATH, ext, 10);
	if ( e == ERROR_SUCCESS ) {
		size_t lname = _tcslen(name);
		size_t lext = _tcslen(ext);
		*pname = (UINT)(_tcslen(path) - lname - lext) * sizeof(TCHAR);
		*pext = *pname + (lname * sizeof(TCHAR));
	} else {
		dtprint(_T("Error parsing filename: err=%d path=[%s]\n"), e, path);
	}

	if ( name ) free( name );

	return e == ERROR_SUCCESS;
}
