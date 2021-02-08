# --- Special If Statements
#>toc library : special if blocks
# - a collection of various checks that may be used with `.if` block directives
# - intended for making useful checks of difficult to compare things in GAS

# --- Updates:
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- alt  - bool is True if altmacro mode is detected, else False
# --- nalt - not alt -- inverse of alt
# these globals can be used as evaluable properties in .if statements

# --- def  - bool is True if given name has been defined
# --- ndef - not def -- inverse of def
# these globals can be used as evaluable properties in .if statements

# --- num  - bool is True if a number is detected in first character of arg, else False
# --- nnum - not num -- inverse of num
# these globals can be used as evaluable properties in .if statements




# --- Class Methods

# --- ifalt
# Checks altmacro mode, and updates 'alt', 'nalt' properties accordingly

# --- ifdef  name
# Checks if name exists by passing it to altmacro mode, and resetting back to noaltmacro mode
# name : a name that contains '\'
# - altmacro mode does not require '\' when escaping arguments
#   - the parsing bug is bypassed by reading the name as an argument and escaping it internally

# --- ifnum  arg
# checks if given arg is a literal number, or an arg that starts with a non-number

# --- ifnum_ascii  arg
# A version of ifnum that returns the ascii value of positive matches, instead of just a bool value

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module if, 1
.if module.included == 0; punkpc ifalt, ifdef, ifnum
.endif
/**/
