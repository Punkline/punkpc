/*## Header:
# --- ifalt - altmacro mode checker
# A method for checking if calls are in .altmacro mode 'alt' or .noaltmacro mode 'nalt'

##*/
##/* Updates:
# version 0.0.2:
# - rewrote ifalt to not use a bogus argument, and in a way that won't conflict with other symbols
# - added 'ifalt.reset' to easily implement a reset method using generated 'alt' bool
# version 0.0.1
# - added to punkpc module library



##*/
/*## Attributes:
# --- Class Properties

# --- alt  - bool is True if altmacro mode is detected, else False
# --- nalt - not alt -- inverse of alt
# these globals can be used as evaluable properties in .if statements



# --- Class Methods

# --- ifalt
# Checks altmacro mode, and updates 'alt', 'nalt' properties accordingly



## Messages from examples:

## Error: Altmacro Mode is Enabled
## Error: 0
## Error: 8
## Error: 16
## Error: 24
## Error: 32
## Error: Altmacro Mode is Disabled
## Error: Altmacro Mode is Disabled

##*/
/*## Examples:
.include "punkpc.s"
punkpc ifalt
# Use the 'punkpc' statement to load this module, or include the module file directly

.macro myStringMacro, str;  .error "\str";  .endm
# this is an example of a macro that takes an input string argument
# - it simply displays the string in an error messag

.altmacro
# switch the macro calling environment to altmacro mode
# - altmacro mode changes how strings are passed

ifalt
# calling ifalt updates 2 properties:
#  alt : environment is in altmacro mode
# nalt : environment is in noaltmacro mode ('not alt')

# with these properties, we can determine what type of string to pass with an if block:
.if alt;
  myStringMacro <Altmacro Mode is Enabled>
# if the assembler is in altmacro mode, it will pass an alt-string

.elseif nalt;
  myStringMacro "Altmacro Mode is Disabled"
# else if the assembler is in noaltmacro mode, it will pass a normal string

.endif;
# >>> Error: Altmacro Mode is Enabled
# - we get the alt-string, because altmacro mode was detected by ifalt
#   - the alt-string is passed using brackets < > instead of double-quotes " "

.noaltmacro
# return back to noaltmacro mode, to re-enable parsing of double-quoted strings


# Altmacro mode has a different way of parsing strings, and can evaluate passing expression args
# If you need to switch to altmacro mode, but don't want to interrupt the current mode...
#   then you may use  'ifalt.reset' to undo your state change:

ifalt
# update the 'alt' bool with memory of the state before switching

.altmacro
# switch to altmacro mode

i=0
.rept 5
  myStringMacro %i  # argument 'i' will be evaluated as it is passed to myStringMacro
  i = i + 8
.endr
# >>> Error : 0
# >>> Error : 8
# >>> Error : 16
# >>> Error : 24
# >>> Error : 32
# - Evaluations can be passed as macro arguments in altmacro mode by using a '%' prefix
#   - a macro recieving an evaluation argument will express it as a decimal number internally
#   - this can only be done in altmacro mode

ifalt.reset
# reset to last memorized mode


.if alt;
  myStringMacro <Altmacro Mode is Enabled>
.elseif nalt;
  myStringMacro "Altmacro Mode is Disabled"
.endif;
# >>> Error: Altmacro Mode is Disabled
# - the state was remembered, from before the switch to altmacro mode, and restored on 'ifalt.reset'
# - this is a normal string, parsed using double quotes " " instead of brackets < >

myAltMemory = alt
.altmacro
ifalt
# 'alt' now detects altmacro mode, so 'ifalt.reset' will not work
# if you need to set the alt bool to a memorized value, you can also use 'ifalt.reset' with an arg

ifalt.reset myAltMemory
# this uses the value of user symbol 'myAltMemory' instead of the temporary class property 'alt'


.if alt;
  myStringMacro <Altmacro Mode is Enabled>
.elseif nalt;
  myStringMacro "Altmacro Mode is Disabled"
.endif;
# >>> Error: Altmacro Mode is Disabled


##*/


.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module ifalt, 2
.if module.included == 0
  .macro ifalt;.irp alt_check,%1;alt=0;.ifc \alt_check,1;alt=1;.endif;nalt=alt^1;.endr;.endm
  .macro ifalt.reset, reset_alt=alt; .if \reset_alt;.altmacro;.else;.noaltmacro;.endif;ifalt;.endm
.endif
