# --- Expression Emitter Tool
#>toc library
# - a tiny utility that provides less-featured decimal literal evaluations, similar to `sidx`
#   - input strings are not concatenated with special delimiter `$`
# - used in the `regs` module to create register names

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

# --- Example Results:

## 28322B32 293D3400
## 00000067 00000066
## 00000065 00000064
