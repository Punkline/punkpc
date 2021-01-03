# --- xem prefix,  expression,  suffix
# eXpression EMitter
# combine literals with evaluated numbers in a string
#   may require quoting in both "<quotes and brackets>"


# --- Updates:

# version 0.0.1
# - added to punkpc module library


# --- Example use of the xem module:

.include "punkpc.s"
punkpc xem
# Use the 'punkpc' statement to load this module, or include the module file directly

.macro string, str; .string "str"; .endm
# this simple macro creates string ascii without a quoted input
# - we can call it using 'xem'

xem "<string (2+2)=>",  (2+2)
# >>> 28322B32 293D3400
# >>> "(2+2)=4"
# - the expression given in the 2nd argument become an evaluated decimal number
# - the literals in the first argument are quoted in double quotes " ", then again in brackets < >
# - statements can be made only if the literals do not require a trailing space char,  or quotes

.macro x, va:vararg
  .ifb \va
    .if x>0
      xem "<.long x$>", x
      x = x-1
    .endif
  .else
    .irp a,\va
      .ifnb \a
        x = x + 1
        xem "<x$>", x, "<=\a>"
.endif; .endr; .endif; .endm; x=0
# this macro 'x' uses 'xem' to push and pop values to and from a static stack-like object

x 100, 101, 102, 103
# push 4 values

x; x; x; x
# pop 4 values
# >>> 00000067 00000066 00000065 00000064


# --- Module attributes:

# --- Class Properties

# --- xem  pfx, expr, sfx
# Emit an evaluated expression as decimal literals, with optional literal prefix/suffix
#   pfx  : literals to concatenate to the front of the evaluated expression
#   expr : an expression that can be evaluated into a 32-bit signed integer, as decimal literals
#   sfx  : literals to concatenate to the end of the evaluated expression
# - pfx and sfx must be enclosed in "< double-quoted brackets >" to be protected from interpretation
#   - leading and trailing spaces for pfx and sfx will be trimmed when passed to altmacro mode
# - expr must be an absolute expression; no undefined values

# --- xema  pfx, %(expr), sfx
# An altmacro mode alternative that requires the expression argument be given a '%' prefix


## Binary from examples:

## 28322B32 293D3400
## 00000067 00000066
## 00000065 00000064




