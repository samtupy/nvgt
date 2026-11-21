# set_access_mask
Choose which of NVGT's functions and classes the module's code may use.

`uint script_module::set_access_mask(uint mask);`

## Arguments:
* uint mask: the subsystems to allow, as a combination of the NVGT_SUBSYSTEM flags from the nvgt_subsystems.nvgt include joined with |, or 0xffffffff for everything.

## Returns:
uint: the previous access mask.

## Remarks:
This must be called before build(). A new module only has access to the general subsystem, 1, so code using anything else, such as files, sound or the network, fails to compile until it is allowed. NVGT_SUBSYSTEM_SCRIPTING_SANDBOX is a reasonable choice for code from untrusted sources, as it allows no access to files, the network or the operating system.
