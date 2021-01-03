/*## Header:
# --- Hidden Symbols
# Alternative 'hidden' symbol definitions for assembler without a linker
# Simple class-level method allows you to pass a special un-typable character as an escapable arg
# - this lets you construct handler macros that can concatenate the characater to symbol names
#   - these literal strings can then be escaped within another handler, for using hidden symbols

##*/
##/* Updates:
# version 0.0.1
# - added to punkpc module library



##*/
/*## Attributes:

# --- Class Properties
# --- hidden.count - a number counting the times 'hidden' has been called
# --- hidden - an argument/return property for interacting with hidden.get and hidden.set



# --- Class Methods
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

# --- hidden.get.sfx  pfx, sfx, sym
# --- hidden.set.sfx  pfx, sfx, val
# Allows you to apply a suffix to the hidden char, if needed




## Binary from examples:

## 00000000 00000064
## 00000064

##*/
/*## Examples:
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

##*/
.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module hidden, 1
.if module.included == 0;

  hidden = 0
  hidden.count = 0
  .macro hidden, pfx, sfx, m, va:vararg; hidden.count = hidden.count + 1
    .ifnb \va; \m \pfx\()\sfx, \va
    .else;     \m \pfx\()\sfx;    .endif
  .endm; .macro hidden.str, pfx, sfx, m, va:vararg; hidden.count = hidden.count + 1
    .ifnb \va; \m "\pfx\()\sfx", \va
    .else;     \m "\pfx\()\sfx";  .endif
  .endm; .macro hidden.alt, pfx, sfx, m, va:vararg; hidden.count = hidden.count + 1
    .ifnb \va; \m <\pfx\()\sfx>, \va
    .else;     \m <\pfx\()\sfx>;  .endif
  .endm; .macro hidden.get, pfx, sym; hidden.get.sfx \pfx,, \sym
  .endm; .macro hidden.set, pfx, val; hidden.set.sfx \pfx,, \val
  .endm; .macro hidden.get.sfx, pfx, sfx, sym=hidden; hidden \pfx, \sfx, hidden.get.handler \sym
  .endm; .macro hidden.set.sfx, pfx, sfx, val=hidden; hidden \pfx, \sfx, hidden.set.handler \val
  .endm; .macro hidden.get.handler, val, sym; \sym = \val
  .endm; .macro hidden.set.handler, sym, val; \sym = \val
  .endm
.endif
