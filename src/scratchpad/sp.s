/*## Header:
# --- Stack Pointer module
# Macroinstructions for pushing and popping the PowerPC runtime stack frame
# - 'sp.push' and 'sp.pop' create a nestable block context for defining functions in PowerPC
# - 'sp.gprs', 'sp.fprs', and 'sp.temp' may be used to allocate backup registers and temp memory
# - includes and manages the 'regs' enumerator, from 'regs' punkpc module

##*/
##/* Updates:
# version 0.0.1
# - added to punkpc module library

##*/
/*## Attributes:

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

# --- sp.pop
# Finalizes all generatted errata expressions by defining the missing vars for all enumerations
# - this generates the '.base' and '.total' values referenced by enumerators
# - popping a nested frame will return to the old frame context



# --- prolog ...
# An alternative to 'sp.push' that implies use of the 'lr' keyword

# --- epilog
# An alias for 'sp.pop' that matches the 'prolog' naming convention



# 'lmf' and 'spr' modules are available for multiple float/spr loads/stores external from the stack

##*/
/*## Examples:
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




# --- CREATING A MORE COMPLEX STACK FRAME ---

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

lfd f30, 0x38(sp)
lfd f31, 0x30(sp)
lmw r29, 0x24(sp)
lwz r0, 0x20(sp)
mtctr r0
lwz r0, 0x44(sp)
addi sp, sp, 0x44
mtlr r0


# The 2-macro equivalent uses the following keywords:

prolog 0x10, r29, f30, ctr

# ...

epilog

# In this case, we use 'prolog' to invoke the 'lr' keyword automatically, and specify the rest:

# '0x10' - a literal expression like this will define a number of bytes in temporary memory
# 'r29'  - specifies that we back up r29, r30, and r31 with the singular 'stmw' instruction
# 'f31'  - specifies that we back up f30, and f31 with individual 'stfd' instructions


# Stack frames are organized within the module using the following layers:

# [ PAD   ] - 0x10 bytes of padding are always given to beginning of a frame, for stacking
# [ TEMP  ] - temporary memory allocations always beginnin at 0x10(sp)
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

##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module sp, 1
.if module.included == 0; punkpc regs, enc, lmf, spr, items

.macro sp_obj.init
  .purgem sp_obj.init
  # we call this after defining class module, and burn it after use

  sp.frame = 0
  sp.mem_ID = 0
  sp.mem_ID$ = 0
  sp.lr.__has_items = 0
  # initial params not created by objects

  stack sp.mem
  enc.new sp.chars, 0, 1
  # memory buffers for parsing and remembering contexts

  .macro sp_obj, self, align, va:vararg
    enum.new \self, \va
    .irp x, .mode; .irp y, count, restart; \self\x \y, sp_obj; .endr; .endr
    .irp x, .byte_align; \self\x = \align; .endr
    .irp x, .__items; items.method \self\x; .endr
    .irp x, .restart; \self\x; .endr
  .endm # temp constructor

  sp_obj sp.sprs, 2, , ,  (0), +1
  sp_obj sp.gprs, 2, , , (31), -1
  sp_obj sp.fprs, 3, , , (31), -1
  sp_obj sp.temp, 0, sp., , (0), +4
  .purgem sp_obj # done with temp constructor
  # mutators common to these objects were applied in constructor

  sp.sprs.mode enum_parse_iter, sp.sprs
  sp.gprs.mode enum_parse, sp.gprs
  sp.fprs.mode enum_parse, sp.fprs
  sp.temp.mode enum_parse, sp.temp
  # mutators unique to each object

# all 'mutators' that come with the module are presented as 'modes'
# - every enabled mode generates a hook method that overrides internally called enum object methods
# - hooks are applied on a per-object basis


# they are defined below as specilly named macros

.endm; .macro enum.mut.count.sp_obj, self, va:vararg
  enum.mut.count.default \self, \va
  .if \self\().count > \self\().high; \self\().high = \self\().count;
  .elseif \self\().count < \self\().low; \self\().low = \self\().count; .endif
  \self\().bytes = (\self\().high - \self\().low) << \self\().byte_align
  # mutated count keeps track of low/high range, and number of bytes required in frame

.endm; .macro enum.mut.restart.sp_obj, self, va:vararg
  enum.mut.restart.default \self, \va
  \self\().bytes = 0
  \self\().low = \self\().count
  \self\().high = \self\().count
  \self\().__has_items = 0
  # mutated restart affects new params as part of the restart

.endm; .macro enum.mut.enum_parse.sp.temp, va:vararg
  enum.mut.enum_parse.default \va
  .if sp.temp.bytes > 0; sp.temp.__has_items = 1; .endif
  # sp.temp flag is not used by module, but can be read by the user

.endm; .macro enum.mut.enum_parse.sp.gprs, va:vararg
  .ifnb \va
    enum.mut.enum_parse.default \va
    .if sp.gprs.__has_items == 0; .if sp.gprs.bytes; sp.gprs.__has_items = 1
        sidx.noalt2 "<stmw sp.gprs.lowest>", sp.mem_ID, /*
        */"<, sp.gprs.base>", sp.mem_ID, "<(sp)>"
    .endif; .endif
  .endif
  # sp.gprs flag is used by the module to detect if 'stmw' is already written

.endm; .macro enum.mut.enum_parse.sp.fprs, va:vararg
  .ifnb \va
    enum.mut.enum_parse.default \va
  .endif
  .if (sp.fprs.high - sp.fprs.low) > sp.fprs.__has_items
    .rept (sp.fprs.high - sp.fprs.low) - sp.fprs.__has_items sidx.noalt /*
*/ "<stfd 32-(sp.fprs.__has_items+1), (sp.fprs.__has_items!<!<sp.fprs.byte_align) + sp.fprs.base>"/*
*/, sp.mem_ID, "<(sp)>"
    sp.fprs.__has_items = sp.fprs.__has_items + 1;
    .endr
  .endif
  # sp.fprs flag is also a count of the current number of fpr stores that have been written
  # for each missing store compared to the enum count -- a new instruction is written

.endm; .macro enum.mut.enum_parse_iter.sp.sprs, self, spr, va:vararg;
  enum.mut.count.sp_obj \self, sp.sprs.count + sp.sprs.step
  .rept 1
    .ifc \spr, cr;  mfcr  r0; .exitm; .endif
    .ifc \spr, CR;  mfcr  r0; .exitm; .endif
    .ifc \spr, sr;  mfsr  r0; .exitm; .endif
    .ifc \spr, SR;  mfsr  r0; .exitm; .endif
    .ifc \spr, msr; mfmsr r0; .exitm; .endif
    .ifc \spr, MSR; mfmsr r0; .exitm; .endif
    ifdef spr.\spr; .if ndef;  mfspr r0, \spr
    .else; mfspr r0, spr.\spr; .endif
  .endr; sidx.noalt "<stw r0, (sp.sprs.__has_items !<!< sp.sprs.byte_align) + sp.sprs.base>"/*
  */, sp.mem_ID, "<(sp)>"; sp.sprs.__has_items = sp.sprs.__has_items + 1
  .if sp.prolog; sp.sprs.__items, \spr; .endif
  # sp.sprs flag is also a count of the current number of spr stores that have been written
  # each input made after the prolog is added to the items buffer, for mimicking on epilog
  # for each missing store compared to the enum count -- a move and a store are written

.endm; .macro sp.push, va:vararg
  sp.mem.push /*
  */  sp.sprs.__items, sp.prolog, sp.frame, sp.mem_ID, sp.lr.__has_items /*
  */, sp.fprs.count,        sp.gprs.count,        sp.sprs.count,        sp.temp.count /*
  */, sp.fprs.step,         sp.gprs.step,         sp.sprs.step,         sp.temp.step /*
  */, sp.fprs.bytes,        sp.gprs.bytes,        sp.sprs.bytes,        sp.temp.bytes /*
  */, sp.fprs.low,          sp.gprs.low,          sp.sprs.low,          sp.temp.low /*
  */, sp.fprs.high,         sp.gprs.high,         sp.sprs.high,         sp.temp.high /*
  */, sp.fprs.total,        sp.gprs.total,        sp.sprs.total,        sp.temp.total /*
  */, sp.fprs.base,         sp.gprs.base,         sp.sprs.base,         sp.temp.base /*
  */, sp.fprs.__has_items,  sp.gprs.__has_items,  sp.sprs.__has_items,  sp.temp.__has_items
  # Back up old context symobls

  sp.prolog = 0
  sp.epilog = 0
  sp.fprs.restart
  sp.gprs.restart
  sp.sprs.restart
  sp.temp.restart
  items.alloc sp.sprs.__items
  sp.mem_ID$ = sp.mem_ID$ + 1
  sp.mem_ID = sp.mem_ID$
  sp.temp.low = 0
  sp.temp.high = 16
  sp.temp.bytes = 16
  sp.temp.count = 16
  sp.lr.__has_items = 0
  sp.__errata
  # Start new context with a unique 'mem_ID'


  .irp arg, \va; .ifnb \arg
    sp.chars.reset
    sp.chars.enc \arg
    # sample first 2 chars of each arg

    num = sp.chars$0
    .if num == 'r; sp.__checkreg \arg, sp.gprs
    .elseif num == 'f; sp.__checkreg \arg, sp.fprs
    .elseif num == 'x; sp.__checkx \arg, sp.temp.__items
    .else; sp.__checkelse \arg; .endif
    # dispatch args to special handlers if they begin with certain characters

  .endif; .endr
  # loop separates special inputs from spr inputs using '.__items' buffers

  .if sp.lr.__has_items; mflr r0; .endif; sidx.noalt "<stwu sp, -sp.frame>", sp.mem_ID, "<(sp)>"
  .if sp.lr.__has_items; sidx.noalt "<stw r0, sp.frame>", sp.mem_ID, "< + 4 (sp)>"; .endif
  sp.temp.__items sp.temp
  sp.sprs.__items sp.sprs
  sp.gprs.__items sp.gprs
  sp.fprs.__items sp.fprs
  # pass items to corresponding enumerators

  sp.prolog = sp.mem_ID
  # mark end of prolog initialization with a non-0 prolog ID

  sp.fprs.__items
  sp.gprs.__items
  sp.temp.__items
  # reset all but sprs buffer
  # - we keep sprs as part of context, for referencing the keywords on restore

.endm; .macro sp.commit
  .if sp.epilog == 0
    sp.epilog = sp.mem_ID
    sidx.noalt "<sp.temp.base>", sp.mem_ID, "< = sp.temp.base>"
    sidx.noalt "<sp.temp.total>", sp.mem_ID, "< = (sp.temp.bytes + 3) !& ~3>"
    sidx.noalt "<sp.temp.total = sp.temp.total>", sp.mem_ID

    sidx.noalt3 "<sp.sprs.base>", sp.mem_ID, "< = sp.temp.total>" /*
    */, sp.mem_ID, "< + sp.temp.base>", sp.mem_ID
    sidx.noalt "<sp.sprs.total>", sp.mem_ID, "< = (sp.sprs.bytes + 3) !& ~3>"
    sidx.noalt "<sp.sprs.total = sp.sprs.total>", sp.mem_ID

    sidx.noalt3 "<sp.gprs.base>", sp.mem_ID, "< = sp.sprs.total>" /*
    */, sp.mem_ID, "< + sp.sprs.base>", sp.mem_ID
    sidx.noalt "<sp.gprs.total>", sp.mem_ID, "< = (sp.gprs.bytes + 7) !& ~7>"
    sidx.noalt "<sp.gprs.total = sp.gprs.total>", sp.mem_ID
    sidx.noalt "<sp.gprs.lowest>", sp.mem_ID, "< = sp.gprs.low+1>"
    sp.gprs.lowest = sp.gprs.low+1

    sidx.noalt3 "<sp.fprs.base>", sp.mem_ID, "< = sp.gprs.total>" /*
    */, sp.mem_ID, "< + sp.gprs.base>", sp.mem_ID
    sidx.noalt "<sp.fprs.total>", sp.mem_ID, "< = (sp.fprs.bytes + 7) !& ~7>"
    sidx.noalt "<sp.fprs.total = sp.fprs.total>", sp.mem_ID
    sidx.noalt "<sp.fprs.lowest>", sp.mem_ID, "< = sp.fprs.low+1>"
    sp.fprs.lowest = sp.fprs.low+1

    sidx.noalt3 "<sp.frame>", sp.mem_ID, "< = (sp.fprs.base>" /*
    */, sp.mem_ID, "< + sp.fprs.total>", sp.mem_ID, "< + 15) !& ~15>"
    sidx.noalt "<sp.frame = sp.frame>", sp.mem_ID
  .endif # call this early to make all frame params evaluable before pop
  # - else, pop will call this commit automatically

.endm; .macro sp.pop, va:vararg
  regs.restart
  sp.commit
  # .frame and all *.base and *.total values are final now

  .if sp.fprs.__has_items; lmfd 31, sp.fprs.base(sp), sp.fprs.lowest; .endif
  .if sp.gprs.__has_items; lmw sp.gprs.lowest, sp.gprs.base(sp); .endif
  .if sp.sprs.__has_items; sp.sprs.__items sp.__lmspr; .endif
  .if sp.lr.__has_items; lwz r0, sp.frame+4(sp); .endif; addi sp, sp, sp.frame
  .if sp.lr.__has_items; mtlr r0; .endif
  # emit epilog

  sp.epilog = 0
  items.free sp.sprs.__items
  # clear items buffer and reset epilog flag

  sp.mem.popm /*
  */, sp.temp.__has_items,   sp.sprs.__has_items,  sp.gprs.__has_items,   sp.fprs.__has_items /*
  */, sp.temp.base,          sp.sprs.base,         sp.gprs.base,          sp.fprs.base /*
  */, sp.temp.total,         sp.sprs.total,        sp.gprs.total,         sp.fprs.total /*
  */, sp.temp.high,          sp.sprs.high,         sp.gprs.high,          sp.fprs.high /*
  */, sp.temp.low,           sp.sprs.low,          sp.gprs.low,           sp.fprs.low /*
  */, sp.temp.bytes,         sp.sprs.bytes,        sp.gprs.bytes,         sp.fprs.bytes /*
  */, sp.temp.step,          sp.sprs.step,         sp.gprs.step,          sp.fprs.step /*
  */  sp.temp.count,         sp.sprs.count,        sp.gprs.count,         sp.fprs.count /*
  */, sp.lr.__has_items, sp.mem_ID, sp.frame, sp.prolog, sp.sprs.__items
  # recover old state properies for enumerators

  sp.__errata

.endm; .macro prolog, va:vararg; sp.push lr, \va
.endm; .macro epilog, va:vararg; sp.pop

# --- hidden layer

.endm; .macro sp.__errata
  .if sp.mem_ID
    sp.temp.base = 0
    sidx.noalt "<sp.frame = sp.frame>", sp.mem_ID
    sidx.noalt "<sp.temp.total = sp.temp.total>", sp.mem_ID
    sidx.noalt "<sp.sprs.total = sp.sprs.total>", sp.mem_ID
    sidx.noalt "<sp.gprs.total = sp.gprs.total>", sp.mem_ID
    sidx.noalt "<sp.fprs.total = sp.fprs.total>", sp.mem_ID
    sidx.noalt "<sp.sprs.base =  sp.temp.total>", sp.mem_ID
    sidx.noalt "<sp.gprs.base = sp.sprs.base + sp.sprs.total>", sp.mem_ID
    sidx.noalt "<sp.fprs.base = sp.gprs.base + sp.gprs.total>", sp.mem_ID
    sidx.noalt "<sp.gprs.lowest = sp.gprs.lowest>", sp.mem_ID
    sidx.noalt "<sp.fprs.lowest = sp.fprs.lowest>", sp.mem_ID
  .endif  # Generate new errata for this context
  # - 'sidx' will create assignments using scalar names generated from the 'sp.mem_ID' index
  # - all of this will be resolved in a corresponding 'sp.pop' call that ends this context

.endm; .macro sp.__lmspr, va:vararg
  lmspr r0, sp.sprs.base(sp), \va

.endm; .macro sp.__checkreg, arg, enum
  .if (sp.chars$1 >= 0x30) && (sp.chars$1 <=0x33);
    enum.mut.count.sp_obj \enum, \arg - \enum\().step
    enum.mut.count.sp_obj \enum, \arg
  .else; sp.__checkx \arg, \enum\().__items; .endif
  # catches 'rN' and 'rName', if 'N' is a number between 0...3, or 'Name' starts in upper case
  # works for names starting with 'r' or 'f'

.endm; .macro sp.__checkx, arg, items
  .if sp.chars$1 >= 0x41; \items, \arg
  .else; sp.__checkelse \arg; .endif

.endm; .macro sp.__checkelse, arg
  .ifc \arg, lr; sp.lr.__has_items = 1; .exitm; .endif
  .ifc \arg, LR; sp.lr.__has_items = 1; .exitm; .endif
  # catch 'lr' keyword as a special case, instead of as part of sprs

  ifnum.check_ascii
  .if num; enum.mut.count.sp_obj sp.temp, sp.temp.count + \arg
  # if it's an expression, then consider it a size for adding as padding in temp memory

  .else; ifdef spr., \arg
    .if def; sp.sprs.__items, \arg
    # if it's a valid spr keyword, append spr items

    .else; sp.temp.__items, \arg; .endif; .endif
    # otherwise, just assume it's meant to be a temp offset name

.endm; sp_obj.init  # ready to go
.endif
