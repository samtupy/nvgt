/* mail.cpp - SMTP mail wrapper implementation for NVGT
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include "mail.h"

#include <Poco/Exception.h>
#include <Poco/Net/FilePartSource.h>
#include <Poco/Net/MailMessage.h>
#include <Poco/Net/MailRecipient.h>
#include <Poco/Net/NetException.h>
#include <Poco/Net/SMTPClientSession.h>
#include <Poco/Net/SecureSMTPClientSession.h>
#include <Poco/Net/StringPartSource.h>
#include <Poco/Path.h>
#include <Poco/RegularExpression.h>
#include <angelscript.h>
#include <scriptarray.h>

#include <sstream>
#include <vector>

using namespace Poco;
using namespace Poco::Net;

// Note: Not using poco_shared here because these objects are meant to be
// used as value types that get composed into messages, not long-lived shared objects.
// The mail_message class manages its own Poco objects internally.

// Wrapper for mail recipient
class mail_recipient {
private:
	int m_refcount;

public:
	MailRecipient::RecipientType type;
	std::string address;
	std::string real_name;

	mail_recipient() : m_refcount(1), type(MailRecipient::PRIMARY_RECIPIENT) {}
	mail_recipient(int recipient_type, const std::string& addr, const std::string& name = "")
		: m_refcount(1), type(static_cast<MailRecipient::RecipientType>(recipient_type)), address(addr), real_name(name) {}

	void add_ref() {
		asAtomicInc(m_refcount);
	}
	void release() {
		if (asAtomicDec(m_refcount) < 1) delete this;
	}
};

// Wrapper for mail message
class mail_message {
private:
	int m_refcount;
	MailMessage m_message;
	std::string m_last_error;
	bool m_has_html_content;
	std::string m_html_content;
	std::string m_plain_content;

	friend class smtp_client;

public:
	mail_message() : m_refcount(1), m_has_html_content(false) {}

	void add_ref() {
		asAtomicInc(m_refcount);
	}
	void release() {
		if (asAtomicDec(m_refcount) < 1) delete this;
	}

	void set_sender(const std::string& address) {
		try {
			m_message.setSender(address);
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	std::string get_sender() const {
		return m_message.getSender();
	}

	void add_recipient(const mail_recipient& recipient) {
		try {
			m_message.addRecipient(MailRecipient(recipient.type, recipient.address, recipient.real_name));
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	void add_recipient_simple(const std::string& address, int type = MailRecipient::PRIMARY_RECIPIENT) {
		try {
			m_message.addRecipient(MailRecipient(static_cast<MailRecipient::RecipientType>(type), address));
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	CScriptArray* get_recipients() const {
		asIScriptContext* ctx = asGetActiveContext();
		asIScriptEngine* engine = ctx->GetEngine();
		asITypeInfo* arrayType = engine->GetTypeInfoByDecl("array<mail_recipient@>");
		CScriptArray* arr = CScriptArray::Create(arrayType);
		const MailMessage::Recipients& recipients = m_message.recipients();
		for (const auto& r : recipients) {
			mail_recipient* mr = new mail_recipient(r.getType(), r.getAddress(), r.getRealName());
			arr->InsertLast(&mr);
		}
		return arr;
	}

	void set_subject(const std::string& subject) {
		m_message.setSubject(subject);
	}

	std::string get_subject() const {
		return m_message.getSubject();
	}

	void set_content(const std::string& content, const std::string& content_type = "text/plain") {
		// For messages with attachments, we need to use addContent instead of setContent
		// to properly create a multipart message
		try {
			m_message.addContent(new StringPartSource(content, content_type));
			m_last_error.clear();
		} catch (const Exception& e) {
			// If addContent fails (e.g., content already set), fall back to setContent
			m_message.setContentType(content_type);
			m_message.setContent(content);
			m_last_error.clear();
		}
	}

	std::string get_content() const {
		return m_message.getContent();
	}

	void set_html_content(const std::string& html, const std::string& plain_alternative = "") {
		m_has_html_content = true;
		m_html_content = html;
		m_plain_content = plain_alternative.empty() ? "This message requires HTML support to view." : plain_alternative;
		m_last_error.clear();
	}

	void set_priority(int priority) {
		try {
			// Set X-Priority header (1=Highest, 5=Lowest)
			m_message.set("X-Priority", std::to_string(priority));
			// Also set Importance header for better compatibility
			std::string importance;
			switch (priority) {
				case 1:
				case 2:
					importance = "High";
					break;
				case 4:
				case 5:
					importance = "Low";
					break;
				default:
					importance = "Normal";
					break;
			}
			m_message.set("Importance", importance);
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	int get_priority() const {
		std::string priority_str = m_message.get("X-Priority", "3");
		try {
			return std::stoi(priority_str);
		} catch (...) {
			return 3;  // Default to normal priority
		}
	}

	void add_header(const std::string& name, const std::string& value) {
		try {
			m_message.add(name, value);
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	std::string get_header(const std::string& name) const {
		return m_message.get(name, "");
	}

	void set_reply_to(const std::string& address) {
		add_header("Reply-To", address);
	}

	std::string get_reply_to() const {
		return get_header("Reply-To");
	}

	void set_read_receipt(const std::string& address) {
		add_header("Disposition-Notification-To", address);
		add_header("Return-Receipt-To", address);
	}

	std::string get_message_id() const {
		return m_message.get("Message-ID", "");
	}

	void set_message_id(const std::string& id) {
		try {
			m_message.set("Message-ID", id);
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	void set_in_reply_to(const std::string& message_id) {
		try {
			m_message.set("In-Reply-To", message_id);
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	std::string get_in_reply_to() const {
		return m_message.get("In-Reply-To", "");
	}

	void set_references(const std::string& references) {
		try {
			m_message.set("References", references);
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	std::string get_references() const {
		return m_message.get("References", "");
	}

	void set_return_receipt_to(const std::string& address) {
		try {
			m_message.set("Return-Receipt-To", address);
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	std::string get_return_receipt_to() const {
		return m_message.get("Return-Receipt-To", "");
	}

	void set_disposition_notification_to(const std::string& address) {
		try {
			m_message.set("Disposition-Notification-To", address);
			m_last_error.clear();
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	std::string get_disposition_notification_to() const {
		return m_message.get("Disposition-Notification-To", "");
	}

	bool add_attachment_file(const std::string& name, const std::string& path) {
		try {
			m_message.addAttachment(name, new FilePartSource(path));
			m_last_error.clear();
			return true;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return false;
		}
	}

	bool add_attachment_string(const std::string& name, const std::string& content, const std::string& media_type = "application/octet-stream") {
		try {
			m_message.addAttachment(name, new StringPartSource(content, media_type));
			m_last_error.clear();
			return true;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return false;
		}
	}

	void set_date(const Timestamp& ts) {
		m_message.setDate(ts);
	}

	std::string add_inline_attachment_file(const std::string& path, const std::string& content_id = "") {
		try {
			std::string cid = content_id.empty() ? Path(path).getFileName() + "@nvgt.mail" : content_id;
			FilePartSource* fps = new FilePartSource(path);
			// For inline attachments, we use addPart with CONTENT_INLINE disposition
			// and set the Content-ID header via the part name
			m_message.addPart("cid:" + cid, fps, MailMessage::CONTENT_INLINE, MailMessage::ENCODING_BASE64);
			m_last_error.clear();
			return cid;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return "";
		}
	}

	std::string add_inline_attachment_string(const std::string& content, const std::string& media_type, const std::string& content_id) {
		try {
			std::string cid = content_id.empty() ? "inline@nvgt.mail" : content_id;
			StringPartSource* sps = new StringPartSource(content, media_type);
			// For inline attachments, we use addPart with CONTENT_INLINE disposition
			// and set the Content-ID header via the part name
			m_message.addPart("cid:" + cid, sps, MailMessage::CONTENT_INLINE, MailMessage::ENCODING_BASE64);
			m_last_error.clear();
			return cid;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return "";
		}
	}

	// Finalize HTML content for sending
	void finalize_html_content() {
		if (!m_has_html_content) return;
		try {
			// Create multipart/alternative for HTML and plain text
			m_message.setContentType("multipart/alternative");
			// Add plain text part
			if (!m_plain_content.empty())
				m_message.addContent(new StringPartSource(m_plain_content, "text/plain"));
			// Add HTML part
			m_message.addContent(new StringPartSource(m_html_content, "text/html"));
			m_has_html_content = false;  // Prevent double processing
		} catch (const Exception& e) {
			m_last_error = e.displayText();
		}
	}

	std::string get_last_error() const {
		return m_last_error;
	}

	const MailMessage& get_message() const {
		return m_message;
	}
};

// SMTP client wrapper
class smtp_client {
private:
	int m_refcount;
	SMTPClientSession* m_session;
	std::string m_host;
	int m_port;
	bool m_use_ssl;
	std::string m_last_error;
	int m_timeout;
	std::string m_server_capabilities;
	bool m_is_authenticated;

public:
	smtp_client() : m_refcount(1), m_session(nullptr), m_port(25), m_use_ssl(false), m_timeout(30000), m_is_authenticated(false) {}
	~smtp_client() {
		close();
	}

	void add_ref() {
		asAtomicInc(m_refcount);
	}
	void release() {
		if (asAtomicDec(m_refcount) < 1) delete this;
	}

	void set_host(const std::string& host) {
		m_host = host;
	}
	std::string get_host() const {
		return m_host;
	}

	void set_port(int port) {
		m_port = port;
	}
	int get_port() const {
		return m_port;
	}

	void set_use_ssl(bool use_ssl) {
		m_use_ssl = use_ssl;
	}
	bool get_use_ssl() const {
		return m_use_ssl;
	}

	bool connect() {
		try {
			close();  // Close any existing connection
			if (m_use_ssl)
				m_session = new SecureSMTPClientSession(m_host, m_port);
			else
				m_session = new SMTPClientSession(m_host, m_port);
			m_session->login(m_host);
			m_session->setTimeout(Poco::Timespan(m_timeout * 1000));  // Convert ms to microseconds
			m_last_error.clear();
			return true;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			close();
			return false;
		}
	}

	bool login(const std::string& username, const std::string& password, int auth_method = SMTPClientSession::AUTH_LOGIN) {
		if (!m_session) {
			m_last_error = "Not connected";
			return false;
		}
		try {
			// For SSL connections, we might need to start TLS
			if (m_use_ssl && m_port == 587) {
				SecureSMTPClientSession* secure = dynamic_cast<SecureSMTPClientSession*>(m_session);
				if (secure)
					secure->startTLS();
			}
			m_session->login(static_cast<SMTPClientSession::LoginMethod>(auth_method), username, password);
			m_is_authenticated = true;
			m_last_error.clear();
			return true;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return false;
		}
	}

	// OAuth2 login
	bool login_oauth2(const std::string& username, const std::string& access_token) {
		if (!m_session) {
			m_last_error = "Not connected";
			return false;
		}
		try {
			// For SSL connections, we might need to start TLS
			if (m_use_ssl && m_port == 587) {
				SecureSMTPClientSession* secure = dynamic_cast<SecureSMTPClientSession*>(m_session);
				if (secure)
					secure->startTLS();
			}
			// OAuth2 uses XOAUTH2 method
			m_session->login(SMTPClientSession::AUTH_XOAUTH2, username, access_token);
			m_is_authenticated = true;
			m_last_error.clear();
			return true;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return false;
		}
	}

	// Note: Authentication method detection is not supported by Poco's SMTP implementation.
	// The library expects you to know the server's authentication requirements in advance.
	// You can try different auth methods (LOGIN, PLAIN, CRAM_MD5, etc.) until one succeeds.

	bool send_message(mail_message* msg) {
		if (!m_session) {
			m_last_error = "Not connected";
			return false;
		}
		if (!msg) {
			m_last_error = "Invalid message";
			return false;
		}
		try {
			// Handle HTML content if set
			if (msg->m_has_html_content)
				msg->finalize_html_content();
			m_session->sendMessage(msg->get_message());
			m_last_error.clear();
			return true;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return false;
		}
	}

	void close() {
		if (m_session) {
			try {
				m_session->close();
			} catch (...) {
			}
			delete m_session;
			m_session = nullptr;
			m_is_authenticated = false;
			m_server_capabilities.clear();
		}
	}

	bool is_connected() const {
		return m_session != nullptr;
	}

	bool is_authenticated() const {
		return m_is_authenticated;
	}

	std::string get_last_error() const {
		return m_last_error;
	}

	void set_timeout(int timeout_ms) {
		m_timeout = timeout_ms;
	}
	int get_timeout() const {
		return m_timeout;
	}

	std::string query_server_capabilities() {
		if (!m_session) {
			m_last_error = "Not connected";
			return "";
		}
		try {
			std::string response;
			m_session->sendCommand("EHLO " + m_host, response);
			m_server_capabilities = response;
			m_last_error.clear();
			return response;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return "";
		}
	}

	std::string get_server_capabilities() const {
		return m_server_capabilities;
	}

	bool send_messages(CScriptArray* messages) {
		if (!m_session) {
			m_last_error = "Not connected";
			return false;
		}
		if (!messages) {
			m_last_error = "Invalid message array";
			return false;
		}
		try {
			for (asUINT i = 0; i < messages->GetSize(); i++) {
				mail_message* msg = *(mail_message**)messages->At(i);
				if (msg) {
					// Handle HTML content if set
					if (msg->m_has_html_content)
						msg->finalize_html_content();
					m_session->sendMessage(msg->get_message());
				}
			}
			m_last_error.clear();
			return true;
		} catch (const Exception& e) {
			m_last_error = e.displayText();
			return false;
		}
	}
};

bool validate_email_address(const std::string& email) {
	// Basic email validation regex pattern
	// This pattern covers most common email formats, but is most certainly not fully aligned with what is/is not legal
	static const std::string pattern =
	    "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]"
	    "(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
	    "(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
	try {
		Poco::RegularExpression regex(pattern);
		return regex.match(email);
	} catch (...) {
		return false;
	}
}

mail_message* parse_email_message(const std::string& raw_message) {
	// This is very much incomplete
	// Should probably find a library for this?
	mail_message* msg = new mail_message();
	try {
		std::istringstream iss(raw_message);
		MailMessage pocoMsg;
		pocoMsg.read(iss);
		msg->set_sender(pocoMsg.getSender());
		msg->set_subject(pocoMsg.getSubject());
		msg->set_content(pocoMsg.getContent(), pocoMsg.getContentType());
		const MailMessage::Recipients& recipients = pocoMsg.recipients();
		for (const auto& r : recipients) {
			mail_recipient recipient(r.getType(), r.getAddress(), r.getRealName());
			msg->add_recipient(recipient);
		}
		if (pocoMsg.has("Message-ID"))
			msg->set_message_id(pocoMsg.get("Message-ID"));
		if (pocoMsg.has("In-Reply-To"))
			msg->set_in_reply_to(pocoMsg.get("In-Reply-To"));
		if (pocoMsg.has("References"))
			msg->set_references(pocoMsg.get("References"));
		if (pocoMsg.has("Reply-To"))
			msg->set_reply_to(pocoMsg.get("Reply-To"));
	} catch (const Exception& e) {
		msg->set_subject("");
		// Note: We can't set the error directly, so the message will have empty fields on parse error
		// Not great, hence needing a library
		// But seeing as we can't even receive Email right now, it'll do.
	}
	return msg;
}

mail_recipient* mail_recipient_factory() {
	return new mail_recipient();
}

mail_recipient* mail_recipient_factory_full(int type, const std::string& address, const std::string& real_name) {
	return new mail_recipient(type, address, real_name);
}

mail_message* mail_message_factory() {
	return new mail_message();
}

smtp_client* smtp_client_factory() {
	return new smtp_client();
}

void RegisterMail(asIScriptEngine* engine) {
	engine->RegisterEnum("mail_recipient_type");
	engine->RegisterEnumValue("mail_recipient_type", "RECIPIENT_TO", MailRecipient::PRIMARY_RECIPIENT);
	engine->RegisterEnumValue("mail_recipient_type", "RECIPIENT_CC", MailRecipient::CC_RECIPIENT);
	engine->RegisterEnumValue("mail_recipient_type", "RECIPIENT_BCC", MailRecipient::BCC_RECIPIENT);
	engine->RegisterEnum("smtp_auth_method");
	engine->RegisterEnumValue("smtp_auth_method", "SMTP_AUTH_NONE", SMTPClientSession::AUTH_NONE);
	engine->RegisterEnumValue("smtp_auth_method", "SMTP_AUTH_LOGIN", SMTPClientSession::AUTH_LOGIN);
	engine->RegisterEnumValue("smtp_auth_method", "SMTP_AUTH_PLAIN", SMTPClientSession::AUTH_PLAIN);
	engine->RegisterEnumValue("smtp_auth_method", "SMTP_AUTH_CRAM_MD5", SMTPClientSession::AUTH_CRAM_MD5);
	engine->RegisterEnumValue("smtp_auth_method", "SMTP_AUTH_CRAM_SHA1", SMTPClientSession::AUTH_CRAM_SHA1);
	engine->RegisterEnumValue("smtp_auth_method", "SMTP_AUTH_XOAUTH2", SMTPClientSession::AUTH_XOAUTH2);
	engine->RegisterEnumValue("smtp_auth_method", "SMTP_AUTH_NTLM", SMTPClientSession::AUTH_NTLM);
	engine->RegisterEnum("mail_priority");
	engine->RegisterEnumValue("mail_priority", "MAIL_PRIORITY_HIGHEST", 1);
	engine->RegisterEnumValue("mail_priority", "MAIL_PRIORITY_HIGH", 2);
	engine->RegisterEnumValue("mail_priority", "MAIL_PRIORITY_NORMAL", 3);
	engine->RegisterEnumValue("mail_priority", "MAIL_PRIORITY_LOW", 4);
	engine->RegisterEnumValue("mail_priority", "MAIL_PRIORITY_LOWEST", 5);
	engine->RegisterObjectType("mail_recipient", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("mail_recipient", asBEHAVE_FACTORY, "mail_recipient@ f()", asFUNCTION(mail_recipient_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("mail_recipient", asBEHAVE_FACTORY, "mail_recipient@ f(mail_recipient_type, const string &in, const string &in = \"\")", asFUNCTION(mail_recipient_factory_full), asCALL_CDECL);
	engine->RegisterObjectBehaviour("mail_recipient", asBEHAVE_ADDREF, "void f()", asMETHOD(mail_recipient, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("mail_recipient", asBEHAVE_RELEASE, "void f()", asMETHOD(mail_recipient, release), asCALL_THISCALL);
	engine->RegisterObjectProperty("mail_recipient", "mail_recipient_type type", asOFFSET(mail_recipient, type));
	engine->RegisterObjectProperty("mail_recipient", "string address", asOFFSET(mail_recipient, address));
	engine->RegisterObjectProperty("mail_recipient", "string real_name", asOFFSET(mail_recipient, real_name));
	engine->RegisterObjectType("mail_message", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("mail_message", asBEHAVE_FACTORY, "mail_message@ f()", asFUNCTION(mail_message_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("mail_message", asBEHAVE_ADDREF, "void f()", asMETHOD(mail_message, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("mail_message", asBEHAVE_RELEASE, "void f()", asMETHOD(mail_message, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_sender(const string &in)", asMETHOD(mail_message, set_sender), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_sender() const property", asMETHOD(mail_message, get_sender), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void add_recipient(const mail_recipient &in)", asMETHOD(mail_message, add_recipient), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void add_recipient(const string &in, mail_recipient_type = RECIPIENT_TO)", asMETHOD(mail_message, add_recipient_simple), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "array<mail_recipient@>@ get_recipients() const", asMETHOD(mail_message, get_recipients), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_subject(const string &in)", asMETHOD(mail_message, set_subject), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_subject() const property", asMETHOD(mail_message, get_subject), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_content(const string &in, const string &in = \"text/plain\")", asMETHOD(mail_message, set_content), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_content() const property", asMETHOD(mail_message, get_content), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "bool add_attachment_file(const string &in, const string &in)", asMETHOD(mail_message, add_attachment_file), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "bool add_attachment_string(const string &in, const string &in, const string &in = \"application/octet-stream\")", asMETHOD(mail_message, add_attachment_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_html_content(const string &in, const string &in = \"\")", asMETHOD(mail_message, set_html_content), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_priority(mail_priority)", asMETHOD(mail_message, set_priority), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "int get_priority() const property", asMETHOD(mail_message, get_priority), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void add_header(const string &in, const string &in)", asMETHOD(mail_message, add_header), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_header(const string &in) const", asMETHOD(mail_message, get_header), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_reply_to(const string &in) property", asMETHOD(mail_message, set_reply_to), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_reply_to() const property", asMETHOD(mail_message, get_reply_to), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_read_receipt(const string &in)", asMETHOD(mail_message, set_read_receipt), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_message_id() const property", asMETHOD(mail_message, get_message_id), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_message_id(const string &in) property", asMETHOD(mail_message, set_message_id), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string add_inline_attachment_file(const string &in, const string &in = \"\")", asMETHOD(mail_message, add_inline_attachment_file), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string add_inline_attachment_string(const string &in, const string &in, const string &in)", asMETHOD(mail_message, add_inline_attachment_string), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_last_error() const property", asMETHOD(mail_message, get_last_error), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_in_reply_to(const string &in) property", asMETHOD(mail_message, set_in_reply_to), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_in_reply_to() const property", asMETHOD(mail_message, get_in_reply_to), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_references(const string &in) property", asMETHOD(mail_message, set_references), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_references() const property", asMETHOD(mail_message, get_references), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_return_receipt_to(const string &in) property", asMETHOD(mail_message, set_return_receipt_to), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_return_receipt_to() const property", asMETHOD(mail_message, get_return_receipt_to), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "void set_disposition_notification_to(const string &in) property", asMETHOD(mail_message, set_disposition_notification_to), asCALL_THISCALL);
	engine->RegisterObjectMethod("mail_message", "string get_disposition_notification_to() const property", asMETHOD(mail_message, get_disposition_notification_to), asCALL_THISCALL);
	engine->RegisterObjectType("smtp_client", 0, asOBJ_REF);
	engine->RegisterObjectBehaviour("smtp_client", asBEHAVE_FACTORY, "smtp_client@ f()", asFUNCTION(smtp_client_factory), asCALL_CDECL);
	engine->RegisterObjectBehaviour("smtp_client", asBEHAVE_ADDREF, "void f()", asMETHOD(smtp_client, add_ref), asCALL_THISCALL);
	engine->RegisterObjectBehaviour("smtp_client", asBEHAVE_RELEASE, "void f()", asMETHOD(smtp_client, release), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "void set_host(const string &in) property", asMETHOD(smtp_client, set_host), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "string get_host() const property", asMETHOD(smtp_client, get_host), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "void set_port(int) property", asMETHOD(smtp_client, set_port), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "int get_port() const property", asMETHOD(smtp_client, get_port), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "void set_use_ssl(bool) property", asMETHOD(smtp_client, set_use_ssl), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "bool get_use_ssl() const property", asMETHOD(smtp_client, get_use_ssl), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "bool connect()", asMETHOD(smtp_client, connect), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "bool login(const string &in, const string &in, smtp_auth_method = SMTP_AUTH_LOGIN)", asMETHOD(smtp_client, login), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "bool login_oauth2(const string &in, const string &in)", asMETHOD(smtp_client, login_oauth2), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "bool send_message(mail_message@)", asMETHOD(smtp_client, send_message), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "void close()", asMETHOD(smtp_client, close), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "bool get_is_connected() const property", asMETHOD(smtp_client, is_connected), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "bool get_is_authenticated() const property", asMETHOD(smtp_client, is_authenticated), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "string get_last_error() const property", asMETHOD(smtp_client, get_last_error), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "void set_timeout(int) property", asMETHOD(smtp_client, set_timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "int get_timeout() const property", asMETHOD(smtp_client, get_timeout), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "string query_server_capabilities()", asMETHOD(smtp_client, query_server_capabilities), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "string get_server_capabilities() const property", asMETHOD(smtp_client, get_server_capabilities), asCALL_THISCALL);
	engine->RegisterObjectMethod("smtp_client", "bool send_messages(array<mail_message@>@)", asMETHOD(smtp_client, send_messages), asCALL_THISCALL);
	engine->RegisterGlobalFunction("bool validate_email_address(const string &in)", asFUNCTION(validate_email_address), asCALL_CDECL);
	engine->RegisterGlobalFunction("mail_message@ parse_email_message(const string &in)", asFUNCTION(parse_email_message), asCALL_CDECL);
}