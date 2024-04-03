#pragma once

#include <windows.h>
#include <string>

std::wstring InputBox(const std::wstring& szCaption, const std::wstring& szPrompt, const std::wstring& szDefaultText = L"", HWND hWnd = NULL);
BOOL InfoBox(const std::wstring& szCaption, const std::wstring& szPrompt, const std::wstring& szText, HWND hWnd=NULL);
