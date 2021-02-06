# --- SPR utilities
#>toc ppc
# - creates macroinstructions for loading and storing multiple special purpose registers
#   - each load or store costs 2 sintructions (a 'move' and a 'read/write')
# - includes a dictionary of spr keywords, unified by the `spr.*` namespace
# - also includes support for some non-spr keywords, like `msr` and `sr`

# --- Example use of the spr module:

.include "punkpc.s"
punkpc spr
# Use the 'punkpc' statement to load this module, or include the module file directly

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

# --- Example Results:

## 7C000026 90010010
## 7C0902A6 90010014
## 7C0802A6 90010018
## 7C17E2A6 9001001C
## 7C1A02A6 90010020
## 7C1B02A6 90010024
## 7C0000A6 90010028
## 7C0D42A6 9001002C
## 7C0C42A6 90010030
## 80010010 7C0FF120
## 80010014 7C0903A6
## 80010018 7C0803A6
## 8001001C 7C17E3A6
## 80010020 7C1A03A6
## 80010024 7C1B03A6
## 80010028 7C000124
## 8001002C 7C0D43A6
## 80010030 7C0C43A6
