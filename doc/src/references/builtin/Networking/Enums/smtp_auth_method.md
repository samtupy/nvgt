# smtp_auth_method
The ways smtp_client::login() can authenticate with a server.

* SMTP_AUTH_NONE: don't authenticate.
* SMTP_AUTH_LOGIN: the LOGIN method, which sends the username and password base64 encoded. This is the default and is widely supported, but should only be used over an encrypted connection.
* SMTP_AUTH_PLAIN: the PLAIN method, which also sends the username and password, and should only be used over an encrypted connection.
* SMTP_AUTH_CRAM_MD5: the CRAM-MD5 challenge response method, which doesn't send the password itself.
* SMTP_AUTH_CRAM_SHA1: the CRAM-SHA1 challenge response method.
* SMTP_AUTH_XOAUTH2: OAuth2, with an access token in place of the password. smtp_client::login_oauth2() uses this.
* SMTP_AUTH_NTLM: NTLM, used by some Microsoft servers.
