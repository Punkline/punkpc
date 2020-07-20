# --- Debug expression
# simply prints an error "[expression] = (evaluation)" -- useful for debugging without a debugger


# --- Example use of the dbg module:

.include "./punkpc/dbg.s"

i = 0x1337; dbg i
# >>> Error: i = 4919


# --- Module attributes:
# --- dbg  expression
# create an error message that evaluates the given expression, if possible

