# --- Register Symbols
#>toc ppc
# - a module that defines normal register indices like `r3`, `r4`, `r5` as global symbols
# - useful for enabling registers for use like indices as part of counters
# - also includes names for `cr` bits and fields

# --- Updates:
# version 0.0.2
# - re-added initial call to regs.rebuild
# - now includes 'enum' module to provide a default 'regs' enumerator, for volatile register names
# version 0.0.1
# - added to punkpc module library

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
# Emit an evaluated expression as decimal literals, with optional literal prefix/suffix.ifndef punkpc.library.included; .include "punkpc.s"; .endif
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
