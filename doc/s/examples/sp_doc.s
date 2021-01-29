# --- Stack Pointer module
# Macroinstructions for pushing and popping the PowerPC runtime stack frame
# - 'sp.push' and 'sp.pop' create a nestable block context for defining functions in PowerPC
# - 'sp.gprs', 'sp.fprs', and 'sp.temp' may be used to allocate backup registers and temp memory
# - includes and manages the 'regs' enumerator, from 'regs' punkpc module


# --- Updates:

# version 0.0.1
# - added to punkpc module library


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


# --- Module attributes:

# --- Class Properties
# --- sp.frame  - the final size of this stack frame


# The following are are all enumerators:
# --- sp.temp     - can be called to define temporary space inside a stack frame
# --- sp.gprs     - can be called to define named backed-up registers for this stack frame
# --- sp.fprs     - like gprs, but for floats
# --- sp.sprs     - invoked by the mutated 'sp' stack push method

# Each has the following extended properties:
# --- sp.*.byte_align
# - this is assigned on initialization, and stays constant to inform the '.bytes' update

# --- sp.*.low    - keeps track of the lowest counted enumeration
# --- sp.*.high   - keeps track of the highest counted enumeration
# --- sp.*.bytes  - counts the number of bytes these enumerations have claimed so far
# - these 3 are updated immediately through method calls
#   - they are safe for things like .if evaluations in the assembler before a frame is done

# --- sp.*.total  - the final byte count for these enumerations in this frame
# --- sp.*.base   - the base offset in the stack frame that these bytes begin at
# - these are only updated after 'sp.pop' is called
#   - attempting to use them before 'sp.pop' will create errata that is resolved at end of assembly
#     - attempts at immediate evaluation will create errors complaining about 'non-constants'

# --- sp.*.__has_items - a read-only property updated by the module
# - this may be checked for as a 0 or not-0 to determine whether the stack contains a type of item



# Multiple copies of these and other enumerator properties are backed up in scalar 'sp.mem'
# - this allows you to nest frames within frames, for creating complex recursive functions


# Errata is purposefully utilized to delay '.total' and '.base' updates
# - all inputs will generate offsets that create errata on references in the body
#   - offsets cannot be immediately evaluated unless 'sp.pop' has already finalized their values
# - this allows the user to define parts of the frame anywhere in the body without errors


# The 'sp.temp' enumerator will create properties in the 'sp' namespace defining temporary memory

# --- sp.*  - generated from 'sp.temp'
# example:  sp.temp   xRGBA, +0x40, xString, +4, xCast, xFloat,
#
# outputs:  sp.xRGBA   = sp.temp.base + 0x00
#           sp.xString = sp.temp.base + 0x04
#           sp.xCast   = sp.temp.base + 0x44
#           sp.xFloat  = sp.temp.base + 0x48




# --- Class Methods ---

# --- sp.push  ...
# This begining of a prolog for a new stack frame
# Must be paired with an ending 'sp.pop' when finishing a function using this frame

# '...' allows for spr keywords to be used for backing up registers and
# Some example keywords for populating a '...' argument list:

# ... (expression) -- numerical expression
# ... xName -- a temporary memory offset - where 'Name' starts in upper-case
#     - these are fed

# ... rName -- a named saved GPR -- where 'Name' starts in upper-case
# ... fName -- a named saved FPR -- where 'Name' starts in upper-case
#     - these are fed into 'sp.gprs' and 'sp.fprs'
#     - 'Name' can be anything that starts with a capital alphabetical char, or an underscore '_'

# ... rN -- anonymous saved GPRs -- where 'N' is a decimal number
# ... fN -- anonymous saved FPRs -- where 'N' is a decimal number
#     - all registers between your specification and 'r31' are backed up, without names
#     - specifying 'r16' for example will back up 'r16 ... r31'
#     - only 1 instruction is needed for gprs, but fprs require 1 instruction per register

# ... lr -- link register
#     - backing this up is necessary to make your function call-safe
#     - if ommitted, the prolog and epilog will only be for a 'leaf' in the call stack

# ... cr  --  condition/comparison register/fields
#     - backing this up allows you to safely use all 32 bits in cr

# ... ctr --  counter register
#     - backing this up lets your function be safely called from within another ctr loop

# ... qr0...7 -- Graphical Quantization Register
# ... qr, gqr -- (alias for qr1)
#     - backing any of these up lets you define scales for working with compressed floating points

# ... (other spr) -- see 'spr' punkpc module for a complete list of valid spr keywords


# --- sp.temp ...
# May be called anywhere in-between 'sp.push' and 'sp.pop' to allocate temporary memory in the frame
# - the number of bytes allocated does not change the number of instructions in the prolog/epilog
# - can be invoked by 'sp.push' by feeding it 'xName' and expressions arguments

# --- sp.gprs ...
# May be called anywhere in-between 'sp.push' and 'sp.pop' to allocate saved GPRs used by a function
# - the number of GPRs allocated does not change the number of instructions in the prolog/epilog
#   - only 1 is needed for any amount of GPR backups, and another for restores
# - can be invoked by 'sp.push' by feeding it 'rName' arguments

# --- sp.fprs ...
# May be called shortly after 'sp.push' to back up floating point registers
# - can be invoked by 'sp.push' by feeding it 'fName' arguments

# --- sp.sprs ...
# May be called shortly after 'sp.push' to back up special purpose registers

# --- regs ...
# May be used to define volatile registers that are not backed up by the stack frame, or 'sp'
# - starts at r3, increments by +1
# - gets restarted by 'sp.pop'

# --- sp.commit
# May be used to finalize a frame's parameters before calling sp.pop, for immediate evaluations

# --- sp.pop
# Finalizes all generatted errata expressions by defining the missing vars for all enumerations
# - this generates the '.base' and '.total' values referenced by enumerators
# - popping a nested frame will return to the old frame context



# --- prolog ...
# An alternative to 'sp.push' that implies use of the 'lr' keyword

# --- epilog
# An alias for 'sp.pop' that matches the 'prolog' naming convention



# 'lmf' and 'spr' modules are available for multiple float/spr loads/stores external from the stack

## Binary from examples:

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
## 7C0802A6 9421FFA0
## 90010064 7C0902A6
## 90010010 7C000026
## 90010014 7C0000A6
## 90010018 7C17E2A6
## 9001001C BE010020
## 7C0802A6 9421FFD0
## 90010034 7C0902A6
## 90010010 BF810014
## 2C800000 4086FFE5
## BB810014 80010010
## 7C0903A6 80010034
## 38210030 7C0803A6
## 4DA60020 BA010020
## 80010010 7C0903A6
## 80010014 7C0FF120
## 80010018 7C000124
## 8001001C 7C17E3A6
## 80010064 38210060
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




