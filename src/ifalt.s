# --- If in Altmacro Mode
#>toc if
# - an if tool that can be used to check the current altmacro environment state
# - used to preserve the altmacro mode, and avoid ruining string interpretations

# --- Updates:
# version 0.0.2:
# - rewrote ifalt to not use a bogus argument, and in a way that won't conflict with other symbols
# - added 'ifalt.reset' to easily implement a reset method using generated 'alt' bool
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- alt  - bool is True if altmacro mode is detected, else False
# --- nalt - not alt -- inverse of alt
# these globals can be used as evaluable properties in .if statements



# --- Class Methods

# --- ifalt
# Checks altmacro mode, and updates 'alt', 'nalt' properties accordingly

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module ifalt, 2
.if module.included == 0
  .macro ifalt;.irp alt_check,%1;alt=0;.ifc \alt_check,1;alt=1;.endif;nalt=alt^1;.endr;.endm
  .macro ifalt.reset, reset_alt=alt; .if \reset_alt;.altmacro;.else;.noaltmacro;.endif;ifalt;.endm
.endif
