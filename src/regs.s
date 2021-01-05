/*## Header:
# --- Register and Property Names
# Uses 'xem' module to generate basic register names in a re-usable macro

##*/
##/* Updates:
# version 0.0.2
# - re-added initial call to regs.rebuild
# - now includes 'enum' module to provide a default 'regs' enumerator, for volatile register names
# version 0.0.1
# - added to punkpc module library
##*/
/*## Attributes:

# --- Class Properties ---
# ---  lt, gt, eq, so     - cr bit names                 0 ... 3
# --- cr0.lt ... cr7.so   - cr bit names (full)          0 ... 31
# ---     r0 ... r31      - gpr index names              0 ... 31
# ---     f0 ... f31      - fpr index names              0 ... 31
# ---     b0 ... b31      - bit index names              0 ... 31
# ---     m0 ... m31      - mask index names    0x80000000 >>> 0x00000001

# --- Class Methods ---
# --- regs ...
# List comma-separated names for registers, starting at r3, r4, r5, ...
# - use parentheses (x) to set the count to a new index 'x'
# - use +i or -i to change the count step to 'i'
# ex:   regs rTo, rFrom, rSize                # rTo = 3;  rFrom = 4;  rSize = 5
# ex:   regs (12), -1, rCallback, rCounter    # rCallback = 12;  rCounter = 11

# --- regs.rebuild
# Call this to re-define all register symbols

# --- regs.enumerate  pfx, sfx, start, "op", count
# Create symbols out of an iterating expression, using \pfx%ID\sfx names
# 'pfx' must start with an alphabetical char, or one of the following chars  ._$
# 'op' is part of a quoted expression that each iteration uses to update the iterated ID
#  - it includes an operator like '+', and an operand like '1'
#  - ex:   "+ 1",    ">> 1",   "* 12",   "+ (my_step * my_stride)"

# --- xem  pfx, expr, sfx
# Emit an evaluated expression as decimal literals, with optional literal prefix/suffix



## Binary from examples:

## 0000001F 0000001F
## 0000001F 00000000
## 00000007 00000001
## 80000000 40B5000C
## 419A0008 38000000
## 4FD5FB82
##*/
/*## Examples:
.include "punkpc.s"
punkpc regs
# Use the 'punkpc' statement to load this module, or include the module file directly

# --- REGISTER INDEX NAMES ---
# Default register names r0...r3, f0...f3, etc have been provided as usable symbols
# - normally these names can only be used inside of their corresponding instructions
#   - having them as symbols allows them to be used in expressions

.long r31, f31, b31, b0, cr7, m31, m0
# >>>0000001F 0000001F 0000001F 00000000 0000001C 00000001 80000000

bMyBool = cr5.gt
bMyOtherBool = b31
# named bool indices can be made from the generated cr and bool enumerations

bf+ bMyBool, _my_label   # branch to _my_label if bMyBool is False
  bt- cr6.eq, _my_label   # else, branch to _my_label if cr6 comparison was equal
    li r0, 0
_my_label:
cror b30, bMyBool, bMyOtherBool
# named bools and numbered bools are marked as boolean indices with the b- prefix




# --- CUSTOM REGISTER NAMES ---
# 'regs' is an enumerator object that you can use and control from a simple input syntax

regs rA, rB, rC
# >>> rA = r3;  rB = r4;  rC = r5
# This assigns the given names to an incrementing count that starts at r3

regs rD, rE, rF
# >>> rD = r6;  rE = r7;  rF = r8
# ... sequential calls will continue the previous count


regs (0), fX, fY, fZ
# >>> fX = f0;  fY = f1;  fZ = f2
# ... (n) allows you to set the index counter to a new base

regs (12), -1, rCallback, rCounter    # rCallback = 12;  rCounter = 11
# >>> rCallback = r12;  rCounter = r11
# ... -n and +n allow you to change the index counter step size, with support for decrementing

regs.restart
# You can restart the index count back to the default 'r3' with '.restart'

.long fX, fY, fZ, rA, rB, rC, rD, rF, rCallback, rCounter
# >>> 0, 1, 2, 3, 4, 5, 6, 7, 8, 12, 11
# - as you can see, this does not affect any generated register names



# You may use this to make code that's easier to read by naming the indices used in instructions:
xNext     = 1                        # - byte index
bFinished = cr0.eq                   # - condition set by 'subic.' instruction
regs rTo, rFrom, rSize, (0), rByte   # - register names
# >>> rTo = r3;  rFrom = r4;  rSize = r5;  rByte = r0

_while_not_finished:
  lbzu rByte, xNext(rFrom)        # - load next byte from 'rFrom' into 'rByte'
  stbu rByte, xNext(rTo)          # - store 'rByte' into next byte in 'rTo'
  subic. rSize, rSize, 1          # - subtract 1 from rSize and check for 'bFinished'
  bf+ bFinished, _while_not_finished

# do '_while_not_finished' while 'bFinished' is false





# --- REBUILDING NAMES ---

r3 = 500
# If you mess up the symbol names for some reason, you can rebuild them with 'regs.rebuild'

regs.rebuild
.long r3
# >>> 00000003



##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module regs, 1; .if module.included == 0; punkpc xem, enum
.macro regs.enumerate, pfx, sfx, start=0, op="+1", cstart, cop, count=32
  .ifb \cop; regs.enumerate \pfx, \sfx, \start, \op, \cstart, \op, \count; .exitm; .endif
  .ifb \cstart; regs.__c = \start; .else; regs.__c = \cstart; .endif;regs.__i=\start; .rept \count
    xem \pfx,regs.__i,"<\sfx=regs.__c>";regs.__i = regs.__i\op;regs.__c = regs.__c\cop;.endr
.endm; .macro regs.rebuild
  .irpc c, rfb; regs.enumerate \c; .endr
  regs.enumerate pfx=m, cstart=0x80000000, cop=">>1"
  regs.enumerate pfx=cr, count=8
  sp=r1; rtoc=r2; lt=0; gt=1; eq=2; so=3; xem = 0
  .rept 8; .irp s, lt,gt,eq,so; xem cr,xem,"<.\s=(xem*4)+\s>"; .endr
    xem = xem + 1; .endr
.endm; regs.rebuild
enum.new regs,,, (3), +1

.endif
