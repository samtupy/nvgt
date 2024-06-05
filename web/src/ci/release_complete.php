<?php
require "auth.php";
// This copies a couple of release artifacts into the downloads directory.
if (!isset($_GET["ver"])) die("missing version");
file_put_contents("../downloads/latest_version", $_GET["ver"]);
echo system("mv -f ../../ci/nvgt_" . $_GET["ver"] . "* ../downloads");
?>
