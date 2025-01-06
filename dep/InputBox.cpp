// Logic and much/most code from the SG_InputBox code project article, though modified quite a bit at this point. Currently multiple concurrent input boxes are not supported.
#define UNICODE
#define _UNICODE

#include <windows.h>
#include <RichEdit.h>
#include <textserv.h>
#include <tchar.h>
#include "InputBox.h"

#define ASPECT_RATIO_X	2
#define ASPECT_RATIO_Y	2
#define TOP_EDGE		10 * ASPECT_RATIO_Y
#define INPUTBOX_WIDTH	500 * ASPECT_RATIO_X
#define INPUTBOX_HEIGHT 150 * ASPECT_RATIO_Y
#define TEXTEDIT_HEIGHT	30 * ASPECT_RATIO_Y
#define BUTTON_HEIGHT	25 * ASPECT_RATIO_Y
#define BUTTON_WIDTH	120 * ASPECT_RATIO_X
#define FONT_HEIGHT		20 * ASPECT_RATIO_Y

#define CLASSNAME					_T("NVGTTextbox")
#define PUSH_BUTTON					_T("Button")
#define FONT_NAME					_T("Times")
#define SetFontToControl(n)			SendMessage((n), WM_SETFONT, (WPARAM)m_hFont, 0);
#define SOFT_BLUE RGB(206,214,240)
void setTextAlignment(HWND hwnd, int textalignment);
#define REPORTERROR ReportError(__FUNCTION__)
void ReportError(const char *CallingFunction);

HFONT m_hFont=NULL;
HMODULE m_hRicheditModule = NULL;
HWND  m_hWndInputBox=NULL;
HWND  m_hWndParent=NULL;
HWND  m_hWndEdit=NULL;
HWND  m_hWndOK=NULL;
HWND  m_hWndCancel=NULL;
HWND  m_hWndPrompt=NULL;
bool infobox=false;
static HBRUSH hbrBkgnd=NULL;

// This function makes richedit controls stop making a sound if you try to scroll past their borders, imported into NVGT from pipe2textbox. Thanks to https://stackoverflow.com/questions/55884687/how-to-eliminate-the-messagebeep-from-the-richedit-control
void disable_richedit_beeps(HMODULE richedit_module, HWND richedit_control) {
		IUnknown* unknown;
		ITextServices* ts;
		IID* ITextservicesId = (IID*)GetProcAddress(richedit_module, "IID_ITextServices");
		if(!ITextservicesId) return;
		if(!SendMessage(richedit_control, EM_GETOLEINTERFACE, 0, (LPARAM)&unknown)) return;
		HRESULT hr = unknown->QueryInterface(*ITextservicesId, (void**)&ts);
		unknown->Release();
		if(hr) return;
		ts->OnTxPropertyBitsChange(TXTBIT_ALLOWBEEP, 0);
		ts->Release();
}

LRESULT CALLBACK InputBoxWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
LOGFONT lfont;
HINSTANCE m_hInst = NULL;
switch (message)
{
case WM_CTLCOLORSTATIC:
{
HDC hdcStatic = (HDC)wParam;
if (hbrBkgnd == NULL)
{
hbrBkgnd = CreateSolidBrush(SOFT_BLUE);
}
SetTextColor(hdcStatic, RGB(0, 0, 0));
SetBkColor(hdcStatic, SOFT_BLUE);
return (INT_PTR)hbrBkgnd;
}
break;
case WM_CREATE:
// Define out font
memset(&lfont, 0, sizeof(lfont));
lstrcpy(lfont.lfFaceName, FONT_NAME);
lfont.lfHeight = FONT_HEIGHT;
lfont.lfWeight = FW_NORMAL;//FW_BOLD;
lfont.lfItalic = FALSE;
lfont.lfCharSet = DEFAULT_CHARSET;
lfont.lfOutPrecision = OUT_DEFAULT_PRECIS;
lfont.lfClipPrecision = CLIP_DEFAULT_PRECIS;
lfont.lfQuality = DEFAULT_QUALITY;
lfont.lfPitchAndFamily = DEFAULT_PITCH;
m_hFont = CreateFontIndirect(&lfont);
m_hInst = GetModuleHandle(NULL);
// The SG_InputBox Caption Static text
m_hWndPrompt = CreateWindowEx(WS_EX_STATICEDGE, _T("static"), _T(""), WS_VISIBLE | WS_CHILD, 5, TOP_EDGE, INPUTBOX_WIDTH - BUTTON_WIDTH - 50, BUTTON_HEIGHT * 2 + TOP_EDGE, hWnd, NULL, m_hInst, NULL);
if (m_hWndPrompt == NULL)
{
REPORTERROR;
return NULL;
}
// setting font
SetFontToControl(m_hWndPrompt);
// The TextEdit Control - For the text to be input
m_hWndEdit = CreateWindowEx(WS_EX_STATICEDGE, m_hRicheditModule? RICHEDIT_CLASS : L"edit", _T(""), WS_VISIBLE | WS_CHILD | WS_TABSTOP | (infobox ? WS_VSCROLL | ES_WANTRETURN | ES_MULTILINE : 0), 5, TOP_EDGE + BUTTON_HEIGHT * 2+30, INPUTBOX_WIDTH - 30, TEXTEDIT_HEIGHT, hWnd, NULL, m_hInst, NULL);
if (m_hWndEdit == NULL)
{
REPORTERROR;
return NULL;
}
if (m_hRicheditModule) disable_richedit_beeps(m_hRicheditModule, m_hWndEdit);
SetFontToControl(m_hWndEdit);
// The Confirm button
if (!infobox)
{
m_hWndOK = CreateWindowEx(WS_EX_STATICEDGE, PUSH_BUTTON, _T("OK"), WS_VISIBLE | WS_CHILD | WS_TABSTOP, INPUTBOX_WIDTH - BUTTON_WIDTH - 30, TOP_EDGE, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, NULL, m_hInst, NULL);
if (m_hWndOK == NULL)
{
REPORTERROR;
return NULL;
}
// setting font
SetFontToControl(m_hWndOK);
}
// The Cancel button
m_hWndCancel = CreateWindowEx(WS_EX_STATICEDGE, PUSH_BUTTON, infobox ? _T("Close") : _T("Cancel"), WS_VISIBLE | WS_CHILD | WS_TABSTOP, INPUTBOX_WIDTH - BUTTON_WIDTH - 30, TOP_EDGE + BUTTON_HEIGHT + 15, BUTTON_WIDTH, BUTTON_HEIGHT, hWnd, NULL, m_hInst, NULL);
if (m_hWndCancel == NULL)
{
REPORTERROR;
return NULL;
}
// setting font
SetFontToControl(m_hWndCancel);
SetFocus(m_hWndEdit);
break;
case WM_DESTROY:
DeleteObject(m_hFont);
//EnableWindow(m_hWndParent, TRUE);
//SetForegroundWindow(m_hWndParent);
DestroyWindow(hWnd);
PostQuitMessage(0);
break;
case WM_COMMAND:
switch (HIWORD(wParam))
{
case BN_CLICKED:
if (!infobox&&(HWND)lParam == m_hWndOK)
PostMessage(m_hWndInputBox, WM_KEYDOWN, VK_RETURN, 0);
if ((HWND)lParam == m_hWndCancel)
PostMessage(m_hWndInputBox, WM_KEYDOWN, VK_ESCAPE, 0);
break;
}
break;
default:
return DefWindowProc(hWnd, message, wParam, lParam);
}
return 0;
}

void InputBoxReset()
{
m_hFont=NULL;
m_hWndInputBox=NULL;
m_hWndParent=NULL;
m_hWndEdit=NULL;
m_hWndOK=NULL;
m_hWndCancel=NULL;
m_hWndPrompt=NULL;
hbrBkgnd=NULL;
}
HWND InputBoxCreateWindow(const std::wstring& szCaption, const std::wstring& szPrompt, const std::wstring& szText, HWND hWnd)
{
InputBoxReset();
if (!m_hRicheditModule) m_hRicheditModule = LoadLibrary(L"Riched20.dll");
RECT r;
if(!hWnd)
hWnd = GetDesktopWindow();
GetWindowRect(hWnd, &r);
HINSTANCE hInst = GetModuleHandle(NULL);
WNDCLASSEX wcex;
if (!GetClassInfoEx(hInst, CLASSNAME, &wcex))
{
wcex.cbSize = sizeof(WNDCLASSEX);
wcex.style = CS_HREDRAW | CS_VREDRAW;
wcex.lpfnWndProc = (WNDPROC)InputBoxWndProc;
wcex.cbClsExtra = 0;
wcex.cbWndExtra = 0;
wcex.hInstance = hInst;
wcex.hIcon = NULL;//LoadIcon(hInst, (LPCTSTR)IDI_MYINPUTBOX);
wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW);
wcex.lpszMenuName = NULL;
wcex.lpszClassName = CLASSNAME;
wcex.hIconSm = NULL;
if (RegisterClassEx(&wcex) == 0)
REPORTERROR;
}
m_hWndParent = hWnd;
/*WS_EX_TOOLWINDOW*/
m_hWndInputBox = CreateWindowEx(WS_EX_DLGMODALFRAME, CLASSNAME, szCaption.c_str(), WS_OVERLAPPEDWINDOW | WS_CAPTION, (r.right - INPUTBOX_WIDTH) / 2, (r.bottom - INPUTBOX_HEIGHT) / 2, INPUTBOX_WIDTH, INPUTBOX_HEIGHT, m_hWndParent, NULL, NULL, NULL);
if (m_hWndInputBox == NULL)
{
REPORTERROR;
return NULL;
}
setTextAlignment(m_hWndPrompt, SS_CENTER);
//SetWindowTitle(m_hWndEdit, szPrompt);
SetWindowText(m_hWndPrompt, szPrompt.c_str());
setTextAlignment(m_hWndEdit, SS_CENTER);
SetForegroundWindow(m_hWndInputBox);
// Set default button
SendMessage((HWND)m_hWndOK, BM_SETSTYLE, (WPARAM)LOWORD(BS_DEFPUSHBUTTON), MAKELPARAM(TRUE, 0));
SendMessage((HWND)m_hWndCancel, BM_SETSTYLE, (WPARAM)LOWORD(BS_PUSHBUTTON), MAKELPARAM(TRUE, 0));
// Set default text
SendMessage(m_hWndEdit, EM_SETSEL, 0, -1);
SendMessage(m_hWndEdit, EM_REPLACESEL, 0, (LPARAM)szText.c_str());
SendMessage(m_hWndEdit, EM_SETSEL, 0, -1);
if(infobox)
{
SendMessage(m_hWndEdit, EM_SETREADONLY, ES_READONLY, 0);
SendMessage(m_hWndEdit, EM_SETSEL, 0, 0);
}
SetFocus(m_hWndEdit);
EnableWindow(m_hWndParent, FALSE);
ShowWindow(m_hWndInputBox, SW_SHOW);
UpdateWindow(m_hWndInputBox);
return m_hWndInputBox;
}
std::wstring InputBoxMessageLoop()
{
std::wstring result=_T("");
MSG msg;
while (GetMessage(&msg, NULL, 0, 0))
{
if (msg.message == WM_KEYDOWN)
{
if(msg.wParam==VK_TAB)
{
HWND hWndFocused=GetFocus();
BOOL prev=GetAsyncKeyState(VK_SHIFT);
SetFocus(GetNextDlgTabItem(m_hWndInputBox, hWndFocused, prev));
}
if (msg.wParam == VK_ESCAPE)
{
SendMessage(m_hWndInputBox, WM_DESTROY, 0, 0);
result=_T("\xff");
}
if (msg.wParam == VK_RETURN)
{
int nCount = GetWindowTextLength(m_hWndEdit);
nCount++;
result.resize(nCount);
GetWindowText(m_hWndEdit, &result.front(), nCount);
result.resize(nCount-1);
SendMessage(m_hWndInputBox, WM_DESTROY, 0, 0);
}
}
if(!IsDialogMessage(m_hWndInputBox, &msg))
{
TranslateMessage(&msg);
DispatchMessage(&msg);
}
}
return result;
}

void setTextAlignment(HWND hwnd,int intTextAlignment)
{
	LONG_PTR s;
	LONG_PTR textalignment = GetWindowLongPtr(hwnd, GWL_STYLE);
	if (textalignment != intTextAlignment)
	{
		//delete the last text alignment
		if (intTextAlignment == 0)
		{
			s = GetWindowLongPtr(hwnd, GWL_STYLE);
			s = s & ~(SS_LEFT);
			SetWindowLongPtr(hwnd, GWL_STYLE, (LONG_PTR)s);
		}
		else if (intTextAlignment == 1)
		{
			s = GetWindowLongPtr(hwnd, GWL_STYLE);
			s = s & ~(SS_CENTER);
			SetWindowLongPtr(hwnd, GWL_STYLE, (LONG_PTR)s);
		}
		else if (intTextAlignment == 2)
		{
			s = GetWindowLongPtr(hwnd, GWL_STYLE);
			s = s & ~(SS_RIGHT);
			SetWindowLongPtr(hwnd, GWL_STYLE, (LONG_PTR)s);
		}

		textalignment = intTextAlignment;

		//put the new text alignment
		if (textalignment == 0)
		{
			s = GetWindowLongPtr(hwnd, GWL_STYLE);
			s = s | (SS_LEFT);
			SetWindowLongPtr(hwnd, GWL_STYLE, (LONG_PTR)s);
		}
		else if (textalignment == 1)
		{
			s = GetWindowLongPtr(hwnd, GWL_STYLE);
			s = s | (SS_CENTER);
			SetWindowLongPtr(hwnd, GWL_STYLE, (LONG_PTR)s);
		}
		else if (textalignment == 2)
		{
			s = GetWindowLongPtr(hwnd, GWL_STYLE);
			s = s | (SS_RIGHT);
			SetWindowLongPtr(hwnd, GWL_STYLE, (LONG_PTR)s);
		}
		SetWindowPos(hwnd, 0, 0, 0, 0, 0,
			SWP_NOZORDER | SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOCOPYBITS | SWP_DRAWFRAME);
	}
}
void ReportError(const char *CallingFunction)
{
	DWORD error = GetLastError();
	LPVOID lpMsgBuf;
	DWORD bufLen = FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM |
		FORMAT_MESSAGE_IGNORE_INSERTS,
		NULL,
		error,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR)&lpMsgBuf,
		0, NULL);
	wprintf(L"%S: Error '%s'\n", CallingFunction,(wchar_t *)lpMsgBuf);
}


std::wstring InputBox(const std::wstring& szCaption, const std::wstring& szPrompt, const std::wstring& szDefaultText, HWND hWnd)
{
infobox=false;
if(!InputBoxCreateWindow(szCaption, szPrompt, szDefaultText, hWnd))
return _T("");
std::wstring result=InputBoxMessageLoop();
return result;
}
BOOL InfoBox(const std::wstring& szCaption, const std::wstring& szPrompt, const std::wstring& szText, HWND hWnd)
{
infobox=true;
if(!InputBoxCreateWindow(szCaption, szPrompt, szText, hWnd))
return FALSE;
InputBoxMessageLoop();
return TRUE;
}
