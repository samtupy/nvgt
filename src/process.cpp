#include "process.h"
#include <vector>
#include <cctype>
#include <algorithm>
#include <Poco/Thread.h>
#include <Poco/PipeStream.h>
#include <iostream>
#include <cassert>

#ifdef _WIN32
	#include <windows.h>
#endif

#ifndef p_streamargs_default
	#define p_streamargs_default "", Poco::BinaryReader::NATIVE_BYTE_ORDER
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

process::InGuard::InGuard(process* p, datastream*& d, Poco::Pipe& pp)
	: owner(p), dsMember(d), pipe(pp)
{}

process::InGuard::~InGuard() {
	if (dsMember)
		owner->close_one_datastream(dsMember);
	else {
		try {
			pipe.close(Poco::Pipe::CLOSE_WRITE);
		} catch (...) {
		}
	}
}

process::process(const std::string& command, const std::string& args_line) {
	cleanup_datastreams_and_pipes();
	_exit_code_val.store(-1);
	_launched.store(false);
	_waited_for_exit.store(false);
	_closed_or_killed.store(false);
	std::vector<std::string> args_vec = process::split_args(args_line);
	_in_pipe = Poco::Pipe();
	_out_pipe = Poco::Pipe();
	_err_pipe = Poco::Pipe();
	Poco::PipeOutputStream* raw_stdin_pstr = nullptr;
	Poco::PipeInputStream* raw_stdout_pstr = nullptr;
	Poco::PipeInputStream* raw_stderr_pstr = nullptr;
	try {
		auto handle = Poco::Process::launch(command, args_vec, &_in_pipe, &_out_pipe, &_err_pipe);
		_ph = std::make_unique<Poco::ProcessHandle>(std::move(handle));
		_launched.store(true);
		raw_stdin_pstr = new Poco::PipeOutputStream(_in_pipe);
		raw_stdout_pstr = new Poco::PipeInputStream(_out_pipe);
		raw_stderr_pstr = new Poco::PipeInputStream(_err_pipe);
		ds_stdin_ = new datastream(nullptr, raw_stdin_pstr, p_streamargs_default, nullptr);
		ds_stdout_ = new datastream(raw_stdout_pstr, nullptr, p_streamargs_default, nullptr);
		ds_stderr_ = new datastream(raw_stderr_pstr, nullptr, p_streamargs_default, nullptr);
		ds_stdin_->binary = true;
		ds_stdout_->binary = true;
		ds_stderr_->binary = true;
	} catch (const Poco::Exception& e) {
		std::cerr << "Process: Failed to launch '" << command << "': " << e.displayText() << std::endl;
		delete raw_stdin_pstr;
		delete raw_stdout_pstr;
		delete raw_stderr_pstr;
		cleanup_datastreams_and_pipes();
		_launched.store(false);
		throw;
	}
}

process::~process() {
	if (_launched.load() && !_waited_for_exit.load() && !_closed_or_killed.load()) {
		if (_ph && _ph->id()) {
			std::cerr << "Process: WARNING: Process " << (_ph->id())
			          << " being destroyed without explicit close() or kill(). Attempting cleanup." << std::endl;
		} else
			std::cerr << "Process: WARNING: objeto destruído sem close()/kill(), sem PID válido." << std::endl;
		close();
	}
	cleanup_datastreams_and_pipes();
}

void process::close_one_datastream(datastream*& ds) {
	if (ds) {
		ds->close();
		ds->release();
		ds = nullptr;
	}
}

void process::cleanup_datastreams_and_pipes() {
	try {
		close_one_datastream(ds_stdin_);
	} catch (...) {}
	try {
		close_one_datastream(ds_stdout_);
	} catch (...) {}
	try {
		close_one_datastream(ds_stderr_);
	} catch (...) {}
	_in_pipe.close(Poco::Pipe::CLOSE_BOTH);
	_out_pipe.close(Poco::Pipe::CLOSE_BOTH);
	_err_pipe.close(Poco::Pipe::CLOSE_BOTH);
}

int process::exit_code() const {
	if (!_waited_for_exit.load() && _ph && _ph->id() && !Poco::Process::isRunning(*_ph)) {
		try {
			int code = Poco::Process::wait(*_ph);
			const_cast<process*>(this)->_exit_code_val.store(code);
		} catch (...) {
			const_cast<process*>(this)->_exit_code_val.store(-1);
		}
		const_cast<process*>(this)->_waited_for_exit.store(true);
	}
	return _exit_code_val.load();
}

int process::pid() const {
	if (!_launched.load() || !_ph) return 0;
	return static_cast<int>(_ph->id());
}

void process::write(const std::string& data) {
	if (ds_stdin_ && ds_stdin_->active())
		ds_stdin_->write(data);
	else
		std::cerr << "Process: Cannot write, stdin stream is not available." << std::endl;
}

bool process::is_running() const {
	if (!_launched.load() || _waited_for_exit.load() || _closed_or_killed.load())
		return false;
	if (!_ph || !_ph->id()) return false;
	return Poco::Process::isRunning(*_ph);
}


void process::close() {
	cleanup_datastreams_and_pipes();
	InGuard guard(this, ds_stdin_, _in_pipe);
	try {
		if (ds_stdin_)
			close_one_datastream(ds_stdin_);
		else
			_in_pipe.close(Poco::Pipe::CLOSE_WRITE);
	} catch (...) {}
	try {
		if (ds_stdout_)
			close_one_datastream(ds_stdout_);
	} catch (...) {}
	try {
		if (ds_stderr_)
			close_one_datastream(ds_stderr_);
	} catch (...) {}
	if (_ph && _ph->id()) {
		for (int i = 0; i < 5; ++i) {
			if (!Poco::Process::isRunning(_ph->id())) break;
			Poco::Thread::sleep(200);
		}
	}
	if (_ph && _ph->id() && Poco::Process::isRunning(_ph->id())) {
		try {
			Poco::Process::kill(_ph->id());
		} catch (...) {}
	}
	try {
		if (_ph && _ph->id()) {
			int code = Poco::Process::wait(*_ph);
			_exit_code_val.store(code);
		} else
			_exit_code_val.store(-1);
	} catch (...) {
		_exit_code_val.store(-1);
	}
	_waited_for_exit.store(true);
	_closed_or_killed.store(true);
}

void process::kill_process() {
	if (!_launched.load() || _waited_for_exit.load() || _closed_or_killed.load() || !_ph || !_ph->id())
		return;
	try {
		Poco::Process::kill(*_ph);
		try {
			_exit_code_val.store(Poco::Process::wait(*_ph));
		} catch (...) {
			_exit_code_val.store(-9);
		}
		_waited_for_exit.store(true);
	} catch (const Poco::Exception& e) {
		std::cerr << "Process: Exception killing process " << pid()
		          << ": " << e.displayText() << std::endl;
		_exit_code_val.store(-1);
		_waited_for_exit.store(true);
	}
	_closed_or_killed.store(true);
}

void process::add_ref() {
	_ref_count.fetch_add(1, std::memory_order_relaxed);
}

void process::release() {
	if (_ref_count.fetch_sub(1, std::memory_order_acq_rel) == 1)
		delete this;
}

datastream* process::get_stdin_stream() {
	if (!ds_stdin_) return nullptr;
	ds_stdin_->duplicate();
	return ds_stdin_;
}

datastream* process::get_stdout_stream() {
	if (!ds_stdout_) return nullptr;
	ds_stdout_->duplicate();
	return ds_stdout_;
}

datastream* process::get_stderr_stream() {
	if (!ds_stderr_) return nullptr;
	ds_stderr_->duplicate();
	return ds_stderr_;
}

process* process_factory(const std::string& command, const std::string& args) {
	try {
		return new process(command, args);
	} catch (const Poco::Exception&) {
		return nullptr;
	} catch (const std::exception& e) {
		std::cerr << "Process Factory: Failed to create process for command '"
		          << command << "' (std exc): " << e.what() << std::endl;
		return nullptr;
	}
}

void RegisterProcess(asIScriptEngine* e) {
	int r;
	r = e->RegisterObjectType("process", 0, asOBJ_REF);
	assert(r >= 0);
	r = e->RegisterObjectBehaviour("process", asBEHAVE_FACTORY,
	                               "process@ f(const string &in command, const string &in args = \"\")",
	                               asFUNCTION(process_factory), asCALL_CDECL);
	assert(r >= 0);
	r = e->RegisterObjectBehaviour("process", asBEHAVE_ADDREF,
	                               "void f()", asMETHOD(process, add_ref), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectBehaviour("process", asBEHAVE_RELEASE,
	                               "void f()", asMETHOD(process, release), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "int get_exit_code() const property",
	                            asMETHOD(process, exit_code), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "int get_pid() const property",
	                            asMETHOD(process, pid), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "bool is_running() const",
	                            asMETHOD(process, is_running), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "void close()",
	                            asMETHOD(process, close), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "void kill()",
	                            asMETHOD(process, kill_process), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "void write(const string &in)",
	                            asMETHOD(process, write), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "datastream@ get_stdin_stream()",
	                            asMETHOD(process, get_stdin_stream), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "datastream@ get_stdout_stream()",
	                            asMETHOD(process, get_stdout_stream), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "datastream@ get_stderr_stream()",
	                            asMETHOD(process, get_stderr_stream), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "datastream@ get_stdout() property",
	                            asMETHOD(process, get_stdout_stream), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "datastream@ get_stdin() property",
	                            asMETHOD(process, get_stdin_stream), asCALL_THISCALL);
	assert(r >= 0);
	r = e->RegisterObjectMethod("process", "datastream@ get_stderr() property",
	                            asMETHOD(process, get_stderr_stream), asCALL_THISCALL);
	assert(r >= 0);
}