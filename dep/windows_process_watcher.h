#pragma once

#ifdef _WIN32
#include <string>
#include <windows.h>

/**
 * ProcessWatcher class for monitoring Windows processes
 * Similar to the Rust implementation but adapted for C++
 */
class ProcessWatcher {
public:
	/**
	 * Constructor
	 * @param process_name Name of the process to monitor (e.g., "notepad.exe")
	 */
	explicit ProcessWatcher(const std::string& process_name);
	
	/**
	 * Destructor - automatically closes handles
	 */
	~ProcessWatcher();
	
	/**
	 * Find the process by name and obtain a handle for monitoring
	 * @return true if process was found and handle obtained, false otherwise
	 */
	bool find();
	
	/**
	 * Monitor the process to check if it's still running
	 * @return true if process is still active, false if it has exited or handle is invalid
	 */
	bool monitor() const;
	
	/**
	 * Check if the watcher has a valid process handle
	 * @return true if handle is valid, false otherwise
	 */
	bool is_valid() const;

private:
	std::string process_name_;
	HANDLE snapshot_;
	HANDLE process_handle_;
	
	/**
	 * Close all open handles
	 */
	void close_handles();
	
	// Disable copy constructor and assignment operator
	ProcessWatcher(const ProcessWatcher&) = delete;
	ProcessWatcher& operator=(const ProcessWatcher&) = delete;
}; 
#endif // _WIN32 