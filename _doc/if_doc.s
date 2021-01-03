# --- if
# A collection of small modules that create specialized 'if' statements
# - each specialized if statement tests its input internally, and returns an evaluable bool
# - the returned bool can then be evaluated by a normal if statement


# --- Updates:

# version 0.0.1
# - added to punkpc module library


# --- Example use of the if module:

.include "punkpc.s"
punkpc if
# Use the 'punkpc' statement to load this module, or include the module file directly

.macro myStringMacro, str;  .asciz "\str"; .align 2;  .endm
# this is an example of a macro that takes an input string argument
# - it simply displays the string by emitting ascii, with an aligned zero-terminator

.macro myMacro, sym
# this macro will help us test the if module


# --- ifnum - lets you check if arguments start with decimal number characters
# - this can be used to identify literal number arguments, since symbols can't start with numbers

  ifnum \sym
  # calling ifnum updates 2 properties:
  #  num : argument is a number
  # nnum : argument is not a number (not num)

  .if num # - this checks the result of ifnum

    .long \sym
    # if the argument is just a number, then emit it as an integer

    .exitm  # ... end exit the macro
  .endif


# --- ifdef - lets you check if argument names exist as symbols

  ifdef \sym
  # calling ifdef updates 2 properties:
  #  def : symbol has been defined
  # ndef : symbol has not been defined (not def)

  .if def   # - this checks the result of ifdef

  # since the argument '\sym' has to be passed with a backslash '\' -- it needs to go through ifdef
  # - where you have only valid symbol chars in your argument, a regular .ifdef directive is fine

  # the following block only runs if the given \sym is already a defined symbol


# --- ifalt - lets you check if you're in altmacro or noaltmacro mode

    .altmacro
    # switch the macro calling environment to altmacro mode
    # - altmacro mode changes how strings are passed

    ifalt
    # calling ifalt updates 2 properties:
    #  alt : environment is in altmacro mode
    # nalt : environment is in noaltmacro mode ('not alt')

    .if alt # - this checks the result of ifalt

      myStringMacro <Altmacro Mode is Enabled>
    # if the assembler is in altmacro mode, it will pass an alt-string

    .elseif nalt;
      myStringMacro "Altmacro Mode is Disabled"
    # else if the assembler is in noaltmacro mode, it will pass a normal string

    .endif;
    # >>> "Altmacro Mode is Enabled"
    # - we get the alt-string, because altmacro mode was detected by ifalt
    #   - the alt-string is passed using brackets < > instead of double-quotes " "

    .noaltmacro
    # return back to noaltmacro mode, to re-enable parsing of double-quoted strings

    ifalt  # re-sample altmacro mode
    .if alt;      myStringMacro <Altmacro Mode is Enabled>
    .elseif nalt; myStringMacro "Altmacro Mode is Disabled"
    .endif
    # >>> "Altmacro Mode is Disabled"
    # - we get the noalt string, this time

  .else

    .long -1
    # if the symbol was not defined, and was not a number, then -1 is emitted

  .endif
.endm

myMacro 0x12345678
# >>> 12345678
# - this emits a number, because it myMacro recognizes the starting '0' with 'ifnum'

myMacro mySymbol
# >>> FFFFFFFF
# - this emits '-1' because the name 'mySymbol' is not yet defined

mySymbol = 0
myMacro mySymbol
# >>> "Altmacro Mode is Enabled"
# >>> "Altmacro Mode is Disabled"
# - the altmacro test runs because it detects that mySymbol has been defined


# --- Module attributes:

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


## Binary from examples:

## 12345678 FFFFFFFF
## 416C746D 6163726F
## 204D6F64 65206973
## 20456E61 626C6564
## 00000000 416C746D
## 6163726F 204D6F64
## 65206973 20446973
## 61626C65 64000000




