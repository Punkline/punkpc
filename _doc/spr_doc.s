# --- SPR utilities
# Provides a symbols dictionary of SPR keywords, and instruction macros for backing up/restoring
#   the state of multiple special purpose registers.


# --- Example use of the spr module:

.include "./punkpc/spr.s"

stmspr r0, 0x10(sp), cr, ctr, lr, qr7, srr0, srr1, msr, tbu, tbl
lmspr  r0, 0x10(sp), cr, ctr, lr, qr7, srr0, srr1, msr, tbu, tbl
# identical syntaxes may be used for loading/storing from the same offsets

# These produce the following:
# >>> mfcr r0      ;  stw r0,16(r1)
# >>> mfctr r0     ;  stw r0,20(r1)
# >>> mflr r0      ;  stw r0,24(r1)
# >>> mfspr r0,919 ;  stw r0,28(r1)
# >>> mfsrr0 r0    ;  stw r0,32(r1)
# >>> mfsrr1 r0    ;  stw r0,36(r1)
# >>> mfmsr r0     ;  stw r0,40(r1)
# >>> mfspr r0,269 ;  stw r0,44(r1)
# >>> mfspr r0,268 ;  stw r0,48(r1)
# - backing up the state of registers

# >>> lwz r0,16(sp);  mtcr r0
# >>> lwz r0,20(sp);  mtctr r0
# >>> lwz r0,24(sp);  mtlr r0
# >>> lwz r0,28(sp);  mtspr 919,r0
# >>> lwz r0,32(sp);  mtsrr0 r0
# >>> lwz r0,36(sp);  mtsrr1 r0
# >>> lwz r0,40(sp);  mtmsr r0
# >>> lwz r0,44(sp);  mtspr 269,r0
# >>> lwz r0,48(sp);  mtspr 268,r0
# - restoring the state of registers


# --- Module attributes:
# --- Class Properties:
# - see the SPR IDS below

# --- Class Methods:

# --- lmspr   a, idx(r), spr, ...
# These can be used to load/store multiple special purpose registers using working register
# - any number of SPR IDs, or keywords may be provided as a sequence of comma-separated 'spr' args
# - in addition to SPRs -- CR, SR, and MSR are supported as special keywords

