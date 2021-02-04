# --- Register Symbols
#>toc ppc
# - a module that defines normal register indices like `r3`, `r4`, `r5` as global symbols
# - useful for enabling registers for use like indices as part of counters
# - also includes names for cr bits and fields

# --- Example use of the regs module:

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

# --- Example Results:

## 0000001F 0000001F
## 0000001F 00000000
## 00000007 00000001
## 80000000 40B5000C
## 419A0008 38000000
## 4FD5FB82 00000000
## 00000001 00000002
## 00000003 00000004
## 00000005 00000006
## 00000008 0000000C
## 0000000B 8C040001
## 9C030001 34A5FFFF
## 4082FFF4 00000003
