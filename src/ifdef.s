# --- If Symbol is Defined
#>toc if
# - an if tool that circumvents the need for `\` chars in .ifdef checks
#   - this is needed to prevent errors when testing argument names in macro definitions
# - used to provide most protections for object and class namespaces

# --- Updates:
# version 0.0.3
# - ifalt is now used to correct the altmacro mode after calling ifdef, automatically
#   - it is no longer required to use ifalt externally to maintain altmacro state with ifdef
# version 0.0.2
# - added varargs support, for serial concatenation before committing to name
# - added 'def_value' return property, for copying symbol value with a static property name
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- def  - bool is True if given name has been defined
# --- ndef - not def -- inverse of def
# these globals can be used as evaluable properties in .if statements

# --- def_value - the value of last checked defined symbol -- or 0 if was not defined
# this can be used to reach a copy of values that are difficult to reference inside of expressions



# --- Class Methods

# --- ifdef  name, ...
# Checks if name exists by passing it to altmacro mode, and resetting back to noaltmacro mode
# name : a name that contains '\'
# - altmacro mode does not require '\' when escaping arguments
#   - the parsing bug is bypassed by reading the name as an argument and escaping it internally
# If a symbol name requires concatenating many escapes, you may provide them as '...'
# - for example:  ifdef \myClass, ., \myProperty

.ifndef punkpc.library.included;
.include "punkpc.s"; .endif
punkpc.module ifdef, 3
.if module.included == 0
  punkpc ifalt
  ifdef.alt = 0
  .macro ifdef, va:vararg
    ifdef.alt = alt
    ifalt
    .noaltmacro
    ifdef.__recurse \va
    ifalt.reset
    alt = ifdef.alt
  .endm; .macro ifdef.__recurse, sym,conc,varargs:vararg
    .ifnb \conc; ifdef "\sym\conc", \varargs
    .else; .altmacro;ifdef.alt \sym;.endif
  .endm;  .macro ifdef.alt,sym;def=0;def_value=0
  .ifdef sym;def=1;def_value=\sym;.endif;ndef=def^1;.endm;
.endif
/**/
