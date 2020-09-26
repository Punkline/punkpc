# --- Hidden Symbols
# Alternative 'hidden' symbol definitions for assembler without a linker
# Simple class-level method allows you to pass a special un-typable character as an escapable arg
# - this lets you construct handler macros that can concatenate the characater to symbol names
#   - these literal strings can then be escaped within another handler, for using hidden symbols


# --- Example use of the hidden module:

.include "punkpc/hidden.s"

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


# --- Module attributes:
# --- Class Properties ----------------------------------------------------------------------------
# --- hidden.count - a number counting the times 'hidden' has been called
# --- hidden - an argument/return property for interacting with hidden.get and hidden.set

# --- Class Methods -------------------------------------------------------------------------------
# --- hidden     pfx, sfx, macro, ...
# Pass the literal string '\pfx\()\001\sfx' as the first argument for a call to \macro
# - \001 is a valid symbol naming character, but can't be typed by normal means
#   - if used within the macro to refer to macro or symbol names, they will be virtually hidden

# --- hidden.str  pfx, sfx, macro, ...
# Quoted version of hidden, passes <\pfx\()\001\sfx> instead of as literals

# --- hidden.alt  pfx, sfx, macro, ...
# Altmacro version of hidden, passes <\pfx\()\001\sfx> instead of quoted string

# --- hidden.get  pfx, sym
# Copies a hidden symbol's value to non-hidden symbol 'sym'
# - if 'sym' is blank, the default symbol used is 'hidden'

# --- hidden.set  pfx, val
# Assigns a hidden symbol's value using an input expression, or symbol
# - if 'val' is blank, the default value used is == 'hidden'
#   - if 'hidden' hasn't been assigned yet, then it will default to '0'

# --- hidden.set.sfx  pfx, sfx, val
# Allows you to apply a suffix to the hidden char, if needed

