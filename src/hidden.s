# --- Hidden Symbol Names
#>toc library
# - a tool for creating hidden symbol names
#   - exploits support of the `\001` char in LOCAL labels in symbol names
# - (intended for use without a linker)

# --- Updates:
# version 0.0.1
# - added to punkpc module library

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
