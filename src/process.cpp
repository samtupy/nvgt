#include "process.h"
#include <vector>
#include <cctype>
#include <algorithm>
#include <Poco/Thread.h>

#ifdef _WIN32
	#include <windows.h>
#endif

std::vector<std::string> process::split_args(const std::string& command_line) {
	std::vector<std::string> arguments;
	std::string current_arg;
	bool inside_quotes = false;
	char current_quote = '\0';

	for (char c : command_line) {
		if (!inside_quotes && (c == '"' || c == '\'')) {
			inside_quotes = true;
			current_quote = c;
		} else if (inside_quotes && c == current_quote)
			inside_quotes = false;
		else if (!inside_quotes && std::isspace(static_cast<unsigned char>(c))) {
			if (!current_arg.empty()) {
				arguments.push_back(current_arg);
				current_arg.clear();
			}
		} else
			current_arg += c;
	}

	if (!current_arg.empty())
		arguments.push_back(current_arg);

	return arguments;
}

#ifdef _WIN32
static std::string from_code_page(const std::string& in, UINT cp) {
	int wlen = MultiByteToWideChar(cp, 0, in.data(), static_cast<int>(in.size()), nullptr, 0);
	if (wlen <= 0) return in;
	std::wstring wbuf(wlen, L'\0');
	MultiByteToWideChar(cp, 0, in.data(), static_cast<int>(in.size()), &wbuf[0], wlen);
	int ulen = WideCharToMultiByte(CP_UTF8, 0, wbuf.data(), wlen, nullptr, 0, nullptr, nullptr);
	if (ulen <= 0) return in;
	std::string out(ulen, '\0');
	WideCharToMultiByte(CP_UTF8, 0, wbuf.data(), wlen, &out[0], ulen, nullptr, nullptr);
	return out;
}
#endif

process::process(const std::string& command, const std::string& args)
	: _out_stream(_out_pipe)
	, _in_stream(_in_pipe)
	, _ph(Poco::Process::launch(command, process::split_args(args), &_in_pipe, &_out_pipe, nullptr))
	, _running(true)
	, _finished(false) {
	_reader = std::thread(&process::read_loop, this);
}

process::~process() {
	close();
}

void process::set_conversion_mode(conversion_mode mode) {
	_conv_mode = mode;
}

int process::exit_code() const {
	return _exit_code;
}
int process::pid() const {
	return _ph.id();
}

void process::write(const std::string& data) {
	_in_stream.write(data.data(), data.size());
	_in_stream.flush();
}

std::string process::convert(const std::string& text) {
#ifdef _WIN32
	switch (_conv_mode) {
		case conversion_mode::oem:
			return from_code_page(text, CP_OEMCP);
		case conversion_mode::acp:
			return from_code_page(text, CP_ACP);
		default:
			return text;
	}
#else
	return text;
#endif
}

void process::read_loop() {
	std::string line;

	while (std::getline(_out_stream, line)) {
		std::string converted = convert(line + "\n");
		std::lock_guard<std::mutex> lock(_mutex);
		_buffer.append(converted);
	}

	try {
		_exit_code = Poco::Process::wait(_ph);
	} catch (...) {
		_exit_code = -1;
	}
	_running.store(false);
	_finished.store(true);
}

bool process::is_running() const {
	return Poco::Process::isRunning(_ph.id()) || !_finished.load();
}

std::string process::peek_output() const {
	std::lock_guard<std::mutex> lock(_mutex);
	return _buffer;
}

std::string process::consume_output() {
	std::lock_guard<std::mutex> lock(_mutex);
	std::string tmp = _buffer;
	_buffer.clear();
	return tmp;
}

void process::close() {
	try {
		_in_stream.close();
	} catch (...) { }
	for (int i = 0; i < 5; ++i) {
		if (!Poco::Process::isRunning(_ph.id())) break;
		Poco::Thread::sleep(200);
	}
	if (Poco::Process::isRunning(_ph.id())) {
		try {
			Poco::Process::kill(_ph.id());
		} catch (...) { }
	}
	try {
		_exit_code = Poco::Process::wait(_ph);
	} catch (...) {
		_exit_code = -1;
	}
		_running.store(false);
	if (_reader.joinable()) _reader.join();
}

void process::add_ref() {
	_ref_count.fetch_add(1, std::memory_order_relaxed);
}

void process::release() {
	if (_ref_count.fetch_sub(1, std::memory_order_acq_rel) == 1)
		delete this;
}

process* process_factory(const std::string& command, const std::string& args) {
	return new process(command, args);
}

void RegisterProcess(asIScriptEngine* e) {
	e->RegisterEnum("conversion_mode");
	e->RegisterEnumValue("conversion_mode", "conversion_mode_none", static_cast<int>(process::conversion_mode::none));
	e->RegisterEnumValue("conversion_mode", "conversion_mode_oem", static_cast<int>(process::conversion_mode::oem));
	e->RegisterEnumValue("conversion_mode", "conversion_mode_acp", static_cast<int>(process::conversion_mode::acp));

	e->RegisterObjectType("process", 0, asOBJ_REF);
	e->RegisterObjectBehaviour("process", asBEHAVE_FACTORY, "process@ f(const string &in, const string &in)", asFUNCTION(process_factory), asCALL_CDECL);
	e->RegisterObjectBehaviour("process", asBEHAVE_ADDREF, "void f()", asMETHOD(process, add_ref), asCALL_THISCALL);
	e->RegisterObjectBehaviour("process", asBEHAVE_RELEASE, "void f()", asMETHOD(process, release), asCALL_THISCALL);

	e->RegisterObjectMethod("process", "int get_exit_code() const property", asMETHOD(process, exit_code), asCALL_THISCALL);
	e->RegisterObjectMethod("process", "int get_pid() const property", asMETHOD(process, pid), asCALL_THISCALL);
	e->RegisterObjectMethod("process", "bool is_running() const", asMETHOD(process, is_running), asCALL_THISCALL);
	e->RegisterObjectMethod("process", "string peek_output() const", asMETHOD(process, peek_output), asCALL_THISCALL);
	e->RegisterObjectMethod("process", "string consume_output()", asMETHOD(process, consume_output), asCALL_THISCALL);
	e->RegisterObjectMethod("process", "void close()", asMETHOD(process, close), asCALL_THISCALL);
	e->RegisterObjectMethod("process", "void write(const string &in)", asMETHOD(process, write), asCALL_THISCALL);
	e->RegisterObjectMethod("process", "void set_conversion_mode(conversion_mode)", asMETHOD(process, set_conversion_mode), asCALL_THISCALL);
}