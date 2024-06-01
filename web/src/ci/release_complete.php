<?php
require "auth.php";
// This copies a couple of release artifacts into the downloads directory.
if (!isset($_GET["ver"])) die("missing version");
echo system("cp ../../ci/nvgt_" . $_GET["ver"] . "* ../downloads");
?>
