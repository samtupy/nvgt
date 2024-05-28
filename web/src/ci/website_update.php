<?php
require "auth.php";
// Remove some common directories that we know will be contained in _site.tar.gz to account for any deletes/renames in the extracted archive. If we find we keep updating this, we can consider looping through directories and deleting the ones that contain a specific file.
echo `rm -r ../blog`;
echo `rm -r ../docs`;
echo `rm -r !(static)`; // We even delete ourself!
// Now load the updated site and undo anything we just deleted.
echo `tar -xzf ../../ci/public_html.tar.gz -C ..`;
?>
