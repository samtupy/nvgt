#pragma once

#include <string>
#include <vector>
#include <atomic>
#include <memory>
#include <Poco/Pipe.h>
#include <Poco/Process.h>
#include <angelscript.h>

#include "datastreams.h"

class CScriptArray;
class CScriptDictionary;

class process {
public:
	process(const std::string& command, const std::string& args_line);
	~process();

	void add_ref();
	void release();

	bool is_running() const;
	void close();
	void write(const std::string& data);
	int exit_code() const;
	int pid() const;
	void kill_process();

	datastream* get_stdin_stream();
	datastream* get_stdout_stream();
	datastream* get_stderr_stream();

private:
	static std::vector<std::string> split_args(const std::string& command_line);
	void cleanup_datastreams_and_pipes();
	void close_one_datastream(datastream*& ds);

	struct InGuard {
		process* owner;
		datastream*& dsMember;
		Poco::Pipe& pipe;

		InGuard(process* p, datastream*& d, Poco::Pipe& pp);
		~InGuard();
	};

	Poco::Pipe _in_pipe;
	Poco::Pipe _out_pipe;
	Poco::Pipe _err_pipe;

	datastream* ds_stdin_ = nullptr;
	datastream* ds_stdout_ = nullptr;
	datastream* ds_stderr_ = nullptr;

	std::unique_ptr<Poco::ProcessHandle> _ph;

	std::atomic<int> _exit_code_val{-1};
	std::atomic<bool> _launched{false};
	std::atomic<bool> _waited_for_exit{false};
	std::atomic<bool> _closed_or_killed{false};
	std::atomic<int> _ref_count{1};

	process(const process&) = delete;
	process& operator=(const process&) = delete;
};

process* process_factory(const std::string& command, const std::string& args);
void RegisterProcess(asIScriptEngine* engine);
