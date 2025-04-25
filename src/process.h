#pragma once

#include <string>
#include <atomic>
#include <mutex>
#include <thread>

#include <Poco/Pipe.h>
#include <Poco/PipeStream.h>
#include <Poco/Process.h>
#include <angelscript.h>

class process {
public:
	enum class conversion_mode { none = 0, oem, acp };

	process(const std::string& command, const std::string& args);
	~process();

	void add_ref();
	void release();

	void set_conversion_mode(conversion_mode mode);
	bool is_running() const;
	std::string peek_output() const;
	std::string consume_output();
	void close();
	void write(const std::string& data);
	int exit_code() const;
	int pid() const;

private:
	void read_loop();
	static std::vector<std::string> split_args(const std::string& command_line);
	std::string convert(const std::string& text);

	conversion_mode _conv_mode = conversion_mode::none;

	Poco::Pipe _in_pipe;
	Poco::Pipe _out_pipe;
	Poco::PipeInputStream _out_stream;
	Poco::PipeOutputStream _in_stream;
	Poco::ProcessHandle _ph;
	std::thread _reader;

	int _exit_code = -1;
	std::atomic<bool> _running{false};
	std::atomic<bool> _finished{false};
	mutable std::mutex _mutex;
	std::string _buffer;
	std::atomic<int> _ref_count{1};

	process(const process&) = delete;
	process& operator=(const process&) = delete;
};

process* process_factory(const std::string& command, const std::string& args);
void RegisterProcess(asIScriptEngine* engine);