# --- xem prefix,  expression,  suffix
# eXpression EMitter
# combine literals with evaluated numbers in a string
#   may require quoting in both "<quotes and brackets>"


# --- Example use of the xem module:

.include "./punkpc/xem.s"

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
.endif; .endr; .endif; .endm
# this macro 'x' uses 'xem' to push and pop values to and from a static stack-like object

x 100, 101, 102, 103
# push 4 values

x; x; x; x
# pop 4 values
# >>> 00000067 00000066 00000065 00000064

# 'xem' also includes helpful enumerations for r-, f-, cr- registers, m- mask bits, and b- bools
.long r31, f31, b31, b0, cr7, m31, m0
# >>>0000001F 0000001F 0000001F 00000000 00000007 00000001 80000000

bMyBool = cr5.gt
bMyOtherBool = b31
# named bool indices can be made from the generated cr and bool enumerations

bf+ bMyBool, _my_label   # branch to _my_label if bMyBool is False
  bt- cr6.eq, _my_label   # else, branch to _my_label if cr6 comparison was equal
    li r0, 0
_my_label:
cror b30, bMyBool, bMyOtherBool
# named bools and numbered bools are marked as boolean indices with the b- prefix


# --- Module attributes:
# --- Class Properties ----------------------------------------------------------------------------

# --- [r0, ... r31]  = [0, ... 31]  -- General Purpose Registers
# --- [f0, ... f31]  = [0, ... 31]  -- Floating Point Registers
# --- [p0, ... p31]  = [0, ... 31]  -- Paired Singles Registers (or pair index [p0, p1])
# --- [cr0, ... cr7] = [0, ... 28]  -- Condition Register comparison partition index bases
# --- [b0, ... b31]  = [0, ... 31]  -- CR boolean indices  (big-endian)
# --- [m0, ... m31]  = [sign>>0 ... sign>>31] -- Mask bits (big-endian)

#  for crN in [cr0 ... cr7]:
#  --- crN.lt = crN + 0  -- 'less than' bool for this condition register partition
#  --- crN.gt = crN + 1  -- 'greater than' -- these comparison results are for compare instructions
#  --- crN.eq = crN + 2  -- 'equal to'
#  --- crN.so = crN + 3  -- 'summary overflow' -- for other instructions


# --- Class Methods -------------------------------------------------------------------------------

# --- xema  pfx, %(expr), sfx
# An altmacro mode alternative that requires the expression argument be given a '%' prefix

