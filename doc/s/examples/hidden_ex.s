# --- Hidden Symbol Names
#>toc library
# - a tool for creating hidden symbol names
#   - exploits support of the `\001` char in temp labels
# - intended for use without a linker

# --- Example use of the hidden module:

.include "punkpc.s"
punkpc hidden
# Use the 'punkpc' statement to load this module, or include the module file directly

myHiddenSymbol = 0

hidden.set myHiddenSymbol, 100
.long myHiddenSymbol
# >>> 0
# - myHiddenSymbol is different from \001\()myHiddenSymbol

hidden.get myHiddenSymbol
.long hidden
# >>> 100
# - hidden symbol name can be read from using hidden.get

hidden.get myHiddenSymbol, myHiddenSymbol
.long myHiddenSymbol
# >>> 100
# - this assigns the value of hidden version to non-hidden version of symbol name

# --- Example Results:

## 00000000 00000064
## 00000064
