// Code contributed by Silak with the intent to monitor jhookldr.exe such that the JAWS keyhook can maintain stability across screen reader restarts.

#ifdef _WIN32
#include "windows_process_watcher.h"
#include <windows.h>
#include <tlhelp32.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <fstream>
#include <chrono>
#include <ctime>
#include <iomanip>
ProcessWatcher::ProcessWatcher(const std::string& process_name) 
	: process_name_(process_name), snapshot_(nullptr), process_handle_(nullptr) {
	// Convert process name to lowercase for case-insensitive comparison
	std::transform(process_name_.begin(), process_name_.end(), process_name_.begin(), ::tolower);
}

ProcessWatcher::~ProcessWatcher() {
	close_handles();
}

void ProcessWatcher::close_handles() {
	if (snapshot_) {
		CloseHandle(snapshot_);
		snapshot_ = nullptr;
	}
	if (process_handle_) {
		CloseHandle(process_handle_);
		process_handle_ = nullptr;
	}
}

bool ProcessWatcher::find() {
	close_handles();
	snapshot_ = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (snapshot_ == INVALID_HANDLE_VALUE) {
		return false;
	}
	
	PROCESSENTRY32W entry;
	entry.dwSize = sizeof(PROCESSENTRY32W);
	
	if (!Process32FirstW(snapshot_, &entry)) {
		return false;
	}
	
	do {
		// Convert wide string to regular string
		int size_needed = WideCharToMultiByte(CP_UTF8, 0, entry.szExeFile, -1, NULL, 0, NULL, NULL);
		std::string current_process_name(size_needed - 1, 0);
		WideCharToMultiByte(CP_UTF8, 0, entry.szExeFile, -1, &current_process_name[0], size_needed, NULL, NULL);
		std::transform(current_process_name.begin(), current_process_name.end(), current_process_name.begin(), ::tolower);
		if (current_process_name == process_name_) {
			process_handle_ = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, entry.th32ProcessID);
			if (process_handle_) {
				return true;
			}
		}
	} while (Process32NextW(snapshot_, &entry));
	return false;
}

bool ProcessWatcher::monitor() const {
	if (!process_handle_) {
		return false;
	}
	
	DWORD exit_code = 0;
	if (!GetExitCodeProcess(process_handle_, &exit_code)) {
		return false;
	}
	
	return (exit_code == STILL_ACTIVE);
}

bool ProcessWatcher::is_valid() const {
	return process_handle_ != nullptr;
} 
#endif // _WIN32 