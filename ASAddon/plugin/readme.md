# What is this?
During NVGT plugin development, particularly when making a shared rather than a static plugin, the following lines should exist at the top of any compilation unit that uses `<angelscript.h>` to insure that it uses the manually imported Angelscript symbols that were sent to the plugin from NVGT:

```
#define NVGT_PLUGIN_INCLUDE
#include "../../src/nvgt_plugin.h"
```

This directory contains shims that set this up for the common Angelscript addons, making them easier to include in a shared plugin (see ../plugin/curl, ../plugin/git etc).
