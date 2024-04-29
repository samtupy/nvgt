<?php
// Authorization script for nvgt's CI backend, this should be the first thing included in any of the scripts in this folder.
// Copyright (c) 2022 - 2024 Sam Tupy
// License: ZLIB

function bad_auth() {
	header("HTTP/1.1 403 Forbidden");
	die("forbidden");
}

// Don't allow authentication if this script is accessed in a browser directly.
if (strpos($_SERVER["PHP_SELF"], basename(__FILE__)) !== false) bad_auth();
// Don't even attempt authentication if the proper header isn't even set, just to avoid php warnings.
if (!isset($_SERVER["HTTP_X_AUTH"])) bad_auth();
// Prevent authentication if the wrong secret value was supplied.
if (hash("sha512", $_SERVER["HTTP_X_AUTH"]) != file_get_contents("../../auth/CIPHP.sha512")) bad_auth();
// Authentication succeeded, from here the script that included this one will execute.
?>
