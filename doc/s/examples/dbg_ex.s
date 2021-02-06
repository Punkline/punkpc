# --- Debug Tool
#>toc library
# - a simple evaluation tool, for debugging symbol values

# --- Example use of the dbg module:

.include "punkpc.s"
punkpc dbg
# Use the 'punkpc' statement to load this module, or include the module file directly

i = 0x1337; dbg i
# >>> Warning: i = 4919

# --- Example Results:

## 5: Warning: i = 4919
