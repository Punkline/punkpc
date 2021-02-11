# --- Runtime Stack Pointer (prolog/epilog block generators)
#>toc ppc
# - dramatically simplifies function writing
#   - use `prolog` and `epilog` to create a block context
# - makes it very easy to create and use named registers, quickly
#   - use `sp.gprs` and `sp.fprs` to create any register names you like
#     - alternatively, give `prolog` arguments starting with `rName` or `fName` camel-case names
# - comes with enumerators mutated to handle definition of all temporary memory in stack frame
#   - includes anonymous and named register backups/restores
#     - give `prolog` any normal register names, like `r30` or `f30` to back up a range
#   - includes anonymous and named temporary memory allocation offset names
#     - give `prolog` an expression, or an `xName` camel-case name
#   - includes support for all special-purpose register names
# - includes support for nested and/or serial frame definitions

# --- Example use of the sp module:

.include "punkpc.s"
punkpc sp
# Use the 'punkpc' statement to load this module, or include the module file directly





# --- CREATING A SIMPLE STACK FRAME ---

# Writing a function in PowerPC requires that you 'push a frame onto the runtime stack'
# - this means adding N bytes to a pointer index describing a place in 'temporary memory'
#   - temporarilly allocated memory like this can be used by a function for backing up registers


mflr r0
stwu sp, -0x20(sp)
stw r0, 0x24(sp)
stmw r30, 0x10(sp)

# ... a function that makes calls, and uses saved registers r30 and r31 goes here ...

lmw r30, 0x10(sp)
lwz r0, 0x24(sp)
addi sp, sp, 0x20
mtlr r0


# The 8 instructions above 'push' and 'pop' create a block context for defining function on PowerPC

# The purpose of this block is to manage the 'stack pointer' register (sp) with 'stwu' and 'addi'
#   - these atomic stores/loads of the stack pointer help inform the callstack, when debugging
# The 'stmw' and 'lmw' instructions back up (store) and recover (load) r30 and r31
#   - this allows the function to then use these saved registers during the middle part, in-between
# The backing up and restoring of 'lr' with 'mflr' and 'mtlr' provides a return point for execution
#   - this is necessary if the function is to make any calls, internally
#     - backing up the lr may not be necessary in 'leaf' functions, which make no calls





# The 'sp' module provides macro-instructions that handle this with fewer inputs:

sp.push lr, r30

# ...

sp.pop

# These 2 macro-instructions will emit the exact same instructions as shown above

# Arguments for 'sp.push' allow you to configure the stack frame as needed, with input keywords
# - 'lr' will cause the frame to back up and recover 'lr' to make it call-safe
# - 'r30' is recognized as a register count to put in 'stmw' and 'lmw'






# If you prefer, the convenience macros 'prolog' and 'epilog' are also available, and imply 'lr'

prolog r30

# ...

epilog
# This block is identical to the above 'sp.push' and 'sp.pop' block
# - it does not need to specify 'lr', though it will accept it






# --- SIMPLIFYING COMPLEX FRAME DEFINITIONS---

# As the requirements of a function increase, so too will the complexity of 'pushing' and 'popping':

mflr r0
stwu sp, -0x40(sp)
stw r0, 0x44(sp)
mfctr r0
stw r0, 0x20(sp)
stmw r29, 0x24(sp)
stfd f31, 0x30(sp)
stfd f30, 0x38(sp)

# ... a function that makes calls, uses 0x10 bytes, r29, r30, r31, f30, f31, and ctr goes here ...

lfd f31, 0x30(sp)
lfd f30, 0x38(sp)
lmw r29, 0x24(sp)
lwz r0, 0x20(sp)
mtctr r0
lwz r0, 0x44(sp)
addi sp, sp, 0x40
mtlr r0





# The 2-macro equivalent uses the following keywords:

prolog 0x10, r29, f30, ctr

# ...

epilog

# In this case, we use 'prolog' to invoke the 'lr' keyword automatically, and specify the rest:

# '0x10' - a literal expression like this will define a number of bytes in temporary memory
# 'r29'  - specifies that we back up r29, r30, and r31 with the singular 'stmw' instruction
# 'f30'  - specifies that we back up f30, and f31 with individual 'stfd' instructions





# Stack frames are organized within the module using the following layers:

# [ PAD   ] - 0x10 bytes of padding are always given to the beginning of a frame, for stacking
# [ TEMP  ] - temporary memory allocations always begin at 0x10(sp)
# [ SPRS  ] - special purpose registers are backed up after end of user memory definitions
# [ GPRS  ] - general purpose registers are backed up after end of SPRS
# [ FPRS  ] - floating point registers are backed up after end of GPRS


# The 'temp' space is meant to be easilly accessibly by the user, so it always starts at the top
# - this is where the '0x10' bytes of memory get allocated to
# - it will always start after the 'padding', which is there to give some room for stack params
#   - these params get defined by other frames called by your frame, so they need to be left alone

# The 'sprs' space is where non-gpr and non-spr (or lr) registers are stored, when backing up
# - this is where 'ctr' goes -- adjacent to the user's temporary memory in case it needs referencing

# The 'gprs' and 'fprs' spaces are then stuffed into space added onto the end
# - multiple 'gprs' can be backed up with the cost of only 1 instruction in the prolog/epilog
#   - while this is only 1 instruction in size -- it is slow; and slower for each added register
# - multiple 'fprs' will require an extra instruction in the prolog/epilog for each register




# Frames can be safely nested without losing information about parent prologs:

prolog r16, ctr, cr, msr, qr7, xer

  _recurse:
  prolog ctr, r28

    # ...

    cmpwi cr1, r0, 0
    bnel+ cr1, _recurse

  epilog
  beqlr+ cr1

epilog
blr
# The epilog will remember your inputs in the prolog, even when nesting stack frames
# - this may be useful for extending saved registers, recursion, or for defining callbacks






# --- NAMING SAVED REGISTERS ---

# We've seen how saved registers can be defined in the prolog args:

prolog r29

  lwz r31, 0x0(r3)
  lwz r30, 0x4(r3)
  lwz r29, 0x0(r4)

  # ...

epilog
# When backing up registers with a number like this, they are anonymous
# You may still reference them by index number, but no special names are given to the registers





# You may instead specify saved registers by naming them 1 by 1
# Each name must start with a lowercase 'r' and then an uppercase alphabetical char, like 'rName'

prolog rIndex, rBase, rString

  lwz rIndex,  0x0(r3)
  lwz rBase,   0x4(r3)
  lwz rString, 0x0(r4)

  # ...

epilog
# This is identical to the above function, but is easier to read by humans






# If you would prefer to give your registers more flexible names, you can use the 'sp.gprs' instead
# 'sp.gprs' may be called anywhere in the function to influence the emitted 'stmw' instruction:

prolog

  sp.gprs reg_index, reg_base
  # the first gpr must always be specified close to the prolog
  # - otherwise, the 'stmw' instruction will appear in the middle of the function~

  lwz reg_index,  0x0(r3)
  lwz reg_base,   0x4(r3)
  lwz reg_str,    0x0(r4)

  sp.gprs reg_str
  # (defining AFTER use is ok with this method if at least one other register is already defined)

  # ...

epilog






# The same is true of 'sp.fprs' for floats:

prolog fX, fY, fZ

  regs rVec
  sp.fprs pair_xy
  lfs fX, 0x0(rVec)
  lfs fY, 0x4(rVec)
  lfs fZ, 0x8(rVec)
  ps_merge00 pair_xy, fX, fY

  # ...

epilog
# Unlike gprs, fprs will require extra instructions in the prolog and epilog for each register
# - gprs only ever need 1 instruction to account for all registers
# - fprs need N instructions for N registers

# 'sp.sprs' has a similar limitation, but requires 2 instructions per register
# - you should always define these immediately after the prolog since they always emit instructions





# If you would like to specify register names for UNSAVED registers, you can use 'regs' instead:

prolog rIndex, rBase, rString

  regs rParams, rStruct, rVec
  # 'regs' always starts at r3 and counts up; resetting after each 'sp.pop' or 'epilog' call

  regs (0), +1, fXY, fZ
  # you can manage the index with the standard 'enum' syntax, using '+' '-' and '()' expressions
  #   (number) sets the register count to a new index, directly
  #   +/-number sets the iteration step, for incrementing or decrementing

  lwz rIndex,  0x0(rParams)
  lwz rBase,   0x4(rParams)
  lwz rString, 0x0(rStruct)
  lwz rVec,    0x4(rStruct)
  psq_l fXY,   0x0(rVec), 0, 0
  lfs fZ,      0x8(rVec)

  # ...

epilog
# By naming all of your registers, you can hint at what your arguments/returns/working values are
# Any registers named by 'regs' will not influence the size of the stack frame
# - because of this, 'regs' works for both volatile gprs and fprs






# --- ALLOCATING AND NAMING TEMPORARY MEMORY ---

# When working with a stack frame, you have the opportunity to create a small amount of workspace

# Giving 'sp.push' or 'prolog' an expression as an input will add that many bytes to the workspace:

prolog 0x18

  addi r9, sp, 0x10
  # 0x10 bytes of padding always comes before the workspace

  stswi r3, r9, 0x18
  # store 0x18 bytes of arguments into our workspace, declared in the prolog

epilog






# You may also create indices in-between allocations by using a lowercase 'x' in an 'xName' syntax:

Args   = 0x18
String = 0x13
# sizes of workspace sections...

prolog xArgs, (Args), xString, (String)
# 'prolog' and 'sp.push' pass these values to the 'sp.temp' enumerator
# - the default step is '0', causing each 'xName' symbol to index the current count and not iterate
#   - each (expression) in parentheses then explicitly defines a size for the last created index

  regs rString, (r9), rTemp
  # r3 ... r8 contain 'Args' that we will store in the workspace

  addi rTemp, sp, sp.xArgs
  stswi r3, rTemp, Args
  # This is our created 'temp' memory
  # 'sp.*' is used to protect the offset names
  # - we reference the start of our temporary memory as 'sp.xArgs'

  addi rTemp, sp, sp.xString
  lswi r4, rString, String
  stswi r4, rTemp, String
  # - the same is true for 'sp.xString'

  # ...

epilog
# When misaligned like this (0x3B byte frame) - padding is introduced to the frame size
# - frame is ultimately aligned to 0x10 bytes, with smaller alignments in-between each section






# --- All temporary memory offsets are given 'sp.*' as a prefix
# You may make * anything you like by using 'sp.temp' instead of inputs in the prolog:

sp.push

  sp.temp +2, rg, ba
  # '+' and '-' can still be used to change the step size
  # - this makes it not-0, so we can just make a sequence of assignments without defining each size

  psq_st f1, sp.rg(sp), 0, 7
  psq_st f2, sp.ba(sp), 0, 7
  lwz r3, sp.rg(sp)
  # load 'rgba' from quantized store of f1(r,g) f2(b,a)

sp.pop
# Remember that 'sp.push' and 'sp.pop' are just more explicit versions of 'prolog' and 'epilog'

# When naming offsets without the 'xName' syntax, be careful not to override any 'sp.*' attributes
# - (... unless that's what you're trying to do)

# --- Example Results:

## 7C0802A6 9421FFE0
## 90010024 BFC10010
## BBC10010 80010024
## 38210020 7C0803A6
## 7C0802A6 9421FFE0
## 90010024 BFC10010
## BBC10010 80010024
## 38210020 7C0803A6
## 7C0802A6 9421FFE0
## 90010024 BFC10010
## BBC10010 80010024
## 38210020 7C0803A6
## 7C0802A6 9421FFC0
## 90010044 7C0902A6
## 90010020 BFA10024
## DBE10030 DBC10038
## CBE10030 CBC10038
## BBA10024 80010020
## 7C0903A6 80010044
## 38210040 7C0803A6
## 7C0802A6 9421FFC0
## 90010044 7C0902A6
## 90010020 BFA10024
## DBE10030 DBC10038
## CBE10030 CBC10038
## BBA10024 80010020
## 7C0903A6 80010044
## 38210040 7C0803A6
## 7C0802A6 9421FF90
## 90010074 7C0902A6
## 90010010 7C000026
## 90010014 7C0000A6
## 90010018 7C17E2A6
## 9001001C 7C0102A6
## 90010020 BE010024
## 7C0802A6 9421FFD0
## 90010034 7C0902A6
## 90010010 BF810014
## 2C800000 4086FFE5
## BB810014 80010010
## 7C0903A6 80010034
## 38210030 7C0803A6
## 4DA60020 BA010024
## 80010010 7C0903A6
## 80010014 7C0FF120
## 80010018 7C000124
## 8001001C 7C17E3A6
## 80010020 7C0103A6
## 80010074 38210070
## 7C0803A6 4E800020
## 7C0802A6 9421FFE0
## 90010024 BFA10010
## 83E30000 83C30004
## 83A40000 BBA10010
## 80010024 38210020
## 7C0803A6 7C0802A6
## 9421FFE0 90010024
## BFA10010 83E30000
## 83C30004 83A40000
## BBA10010 80010024
## 38210020 7C0803A6
## 7C0802A6 9421FFE0
## 90010024 BFA10010
## 83E30000 83C30004
## 83A40000 BBA10010
## 80010024 38210020
## 7C0803A6 7C0802A6
## 9421FFD0 90010034
## DBE10010 DBC10018
## DBA10020 DB810028
## C3E30000 C3C30004
## C3A30008 139FF420
## CBE10010 CBC10018
## CBA10020 CB810028
## 80010034 38210030
## 7C0803A6 7C0802A6
## 9421FFE0 90010024
## BFA10010 83E30000
## 83C30004 83A40000
## 80A40004 E0050000
## C0250008 BBA10010
## 80010024 38210020
## 7C0803A6 7C0802A6
## 9421FFD0 90010034
## 39210010 7C69C5AA
## 80010034 38210030
## 7C0803A6 7C0802A6
## 9421FFC0 90010044
## 39210010 7C69C5AA
## 39210028 7C839CAA
## 7C899DAA 80010044
## 38210040 7C0803A6
## 9421FFE0 F0217010
## F0417012 80610010
## 38210020
