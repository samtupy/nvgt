# Networking
This section contains the references for communicating over networks and the internet.

Which part to use depends on what is being talked to:
* For multiplayer games, where NVGT programs talk to each other, the network class handles connections, peers, channels and reliable or unreliable messages.
* For web requests, such as checking for updates, downloading files or using a web API, the http class is the best choice for almost everything. It makes HTTP and HTTPS requests in the background, follows redirects and handles authentication, and url_get() and url_post() make simple requests in one line.
* For full control over HTTP, http_client and https_client send http_request objects and receive http_response objects over a connection that the script manages.
* For services that use WebSockets, such as many chat and real time web services, see web_socket.
* For other protocols over TCP, stream_socket sends and receives raw bytes.
* For sending email, see smtp_client and mail_message.

spec::uri, spec::ip_address, socket_address and the DNS functions describe and look up addresses for all of these.
