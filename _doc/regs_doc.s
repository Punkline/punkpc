# --- Register and Property Names
# Uses 'xem' module to generate basic register names in a re-usable macro


# --- Updates:

# version 0.0.1
# - added to punkpc module library


# --- Example use of the regs module:

.include "punkpc.s"
punkpc myModule
# Use the 'punkpc' statement to load this module, or include the module file directly

# --- REGISTER NAMES ---
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




# --- REBUILDING NAMES ---

r3 = 500
# If you mess up the symbol names for some reason, you can rebuild them with 'regs.rebuild'

regs.rebuild
.long r3
# >>> 00000003


# --- Module attributes:

# --- Class Properties ---
# ---  lt, gt, eq, so     - cr bit names                 0 ... 3
# --- cr0.lt ... cr7.so   - cr bit names (full)          0 ... 31
# ---     r0 ... r31      - gpr index names              0 ... 31
# ---     f0 ... f31      - fpr index names              0 ... 31
# ---     b0 ... b31      - bit index names              0 ... 31
# ---     m0 ... m31      - mask index names    0x80000000 >>> 0x00000001

# --- Class Methods ---
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




