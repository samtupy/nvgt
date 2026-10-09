<?php
require "auth.php";
// This moves files such as windev.zip, macosdev.zip etc from the ftp upload location to the webroot and updates their timestamp files.
echo system("mv -f ../../ci/*dev.zip* ..");
foreach(glob("../*dev.zip") as $l) file_put_contents($l . ".timestamp", filemtime($l));
?>
