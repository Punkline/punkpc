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

# --- sp   - a stack that holds the state of unfinished frames when nesting a new one internally
# - mutated push and pop methods are used to manage the sp object environment

# The only extra user-level property 'sp' has is a frame size value:
# --- sp.frame  - the final size of this stack frame



# The following are are all enumerators:
# --- sp.temp     - can be called to define temporary space inside a stack frame
# --- sp.gprs     - can be called to define named backed-up registers for this stack frame
# --- sp.fprs     - like gprs, but for floats
# --- sp.main     - invoked by the mutated 'sp' stack push method

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


# Multiple copies of these and other enumerator properties can be backed up in scalar 'sp' memory
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

# --- regs ...
# May be used to define volatile registers that are not backed up by the stack frame, or 'sp'
# - gets reset by 'sp.pop'

# --- sp.pop
# Finalizes all generatted errata expressions by defining the missing vars for all enumerations
# - this generates the '.base' and '.total' values referenced by enumerators
# - popping a nested frame will return to the old frame context

# 'lmf' and 'spr' modules are available for multiple float/spr loads/stores external from the stack

##*/
/*## Examples:
.include "punkpc.s"
punkpc sp
# Use the 'punkpc' statement to load this module, or include the module file directly


##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module sp, 1
.if module.included == 0; punkpc regs, enc, lmf, spr, items, dbg

# --- temporary constructor - purged at end of class definition

.macro sp_obj, self, align=0, va:vararg
  enum.new \self, \va
  .ifnc \self, sp.main; \self\().mode literal, \self; .endif
  \self\().mode count, sp_obj
  \self\().mode restart, sp_obj
  \self\().byte_align = \align
  \self\().restart


# --- stack pointer push/pop

.endm; .macro sp.push, va:vararg
  sp.prolog = 0; sp.epilog = 0
  sp.mem.push sp.mem_ID, sp.lr.__has_items, sp.main.__items, sp.frame
  # save old memory ID, lr state, and items list for sprs

  sp.mem_ID$ = sp.mem_ID$ + 1; sp.mem_ID = sp.mem_ID$
  # increment memory ID, for generating new errata

  sidx.noalt "<sp.frame = sp.frame>", sp.mem_ID
  # generate errata for frame size

  .irp enum, fprs, gprs, main, temp
    .irp ppt, .count, .step, .bytes, .low, .high, .__has_items
      sp.mem.push sp.\enum\ppt
      # memorize enum properties

    .endr; .irp ppt, .total, .base
      sp.mem.push sp.\enum\ppt
      sidx.noalt "<sp.\enum\ppt = sp.\enum\ppt>", sp.mem_ID
      # generate errata for final enum properties

    .endr; .irp method, .restart; sp.\enum\method; .endr
  .endr # push all enumerator properties needed for frame environment

  sp.main \va  # handle input args with main enumerator
  sp.prolog = sp.mem_ID # set prolog state flag

.endm; .macro sp.pop, va:vararg
  sp.__main_epilog
  sp.frame_build = 0x10
  .irp enum, temp, main, gprs, fprs
    sp.pop.__build sp.\enum
    .irp ppt, .__has_items, .high, .low, .bytes, .step, .count; sp.mem.popm sp.\enum\ppt; .endr
  .endr; sidx.noalt "<sp.frame>", sp.mem_ID, "< = sp.frame_build>"
  sp.mem.popm sp.frame, sp.main.__items, sp.lr.__has_items, sp.mem_ID

.endm; .macro prolog, va:vararg=r28; sp.push lr, \va
.endm; .macro epilog, va:vararg; sp.pop \va
# convenience macros imply 'lr' and have default 'r28' for blank arguments


# --- mutators for enum hooks

.endm; .macro enum.mut.count.sp_obj, self, va:vararg
  enum.mut.count.default \self, \va
  .if \self\().count < \self\().low; \self\().low = \self\().count
  .elseif \self\().count > \self\().high; \self\().high = \self\().count; .endif
  \self\().bytes = (\self\().high - \self\().low) << \self\().byte_align

.endm; .macro enum.mut.restart.sp_obj, self, va:vararg
  enum.mut.restart.default \self, \va
  \self\().bytes = 0
  \self\().low = \self\().count
  \self\().high = \self\().count
  \self\().__has_items = 0

.endm; .macro enum.mut.enum_parse.sp.main, self, va:vararg
  .irp arg, \va; .ifnb \arg
      sp.chars.reset
      sp.chars.enc \arg
      # sample the first 2 chars of each arg

      num = sp.chars$0
      .if num == 'r; sp.__check_main_r \arg
      .elseif num == 'f; sp.__check_main_f \arg
      .elseif num == 'x; sp.__check_main_x \arg
      .else; sp.__check_main_else \arg; .endif
      # dispatch to a handler according to case

  .endif; .endr; sp.__main_prolog
  # after all args are checked, commit to prolog

.endm; .macro enum.mut.literal.sp_obj, self, arg, va:vararg
  sidx.noalt "<\arg = \self\().count + \self\().base>", sp.mem_ID
  enum.mut.count.sp_obj \self, \self\().count + \self\().step
  \self\().steps = \self\().steps + 1

.endm; .macro enum.mut.literal.sp.gprs, self, va:vararg
  .if sp.gprs.__has_items == 0; sp.__stmw;  .endif; sp.gprs.__has_items = 1
  enum.mut.literal.default sp.gprs, \va

.endm; .macro enum.mut.literal.sp.fprs, self, arg, va:vararg
  .if sp.prolog
    stfd \arg, sp.fprs.base + sp.fprs.bytes(sp)
  .endif; sp.fprs.__has_items = 1
  enum.mut.literal.default sp.fprs, \arg, \va


# --- hidden layer

.endm; .macro sp.__check_main_r, arg
  .if sp.chars$1 >= 0x41; sp.gprs \arg
  # if char from index [1] is >= 'A', then it is considered upper-case

  .elseif (sp.chars$1 >= 0x30) && (sp.chars$1 <=0x33); sp.gprs (\arg+sp.gprs.step)
  # if it's thed decimal number 0, 1, 2, or 3; then it's considered a register number

  .else; sp.__main_else \arg; .exitm; .endif; sp.gprs.__has_items = 1
  # else, check to see if it's a valid spr keyword

.endm; .macro sp.__check_main_f, arg
  .if sp.chars$1 >= 0x41; sp.fprs \arg
  .elseif (sp.chars$1 >= 0x30) && (sp.chars$1 <=0x33);  sp.fprs (\arg+sp.fprs.step)
  .else; sp.__main_else \arg; .exitm; .endif; sp.fprs.__has_items = 1
  # do the same checks if 'f' is found instead of 'r'

.endm; .macro sp.__check_main_x, arg;
  ifdef spr.\arg
  .if def; enum.mut.literal.sp_obj sp.main, sp.main.__count
    sp.main.__items, \arg
    sp.main.__has_items = 1
  .elseif sp.chars$1 >= 0x41; sp.temp \arg
  .else; sp.__main_else \arg; .exitm; .endif; sp.temp.__has_items = 1
  # do similar if 'x' is found instead of 'r'

.endm; .macro sp.__check_main_else, arg
  .ifc \arg, lr; sp.lr.__has_items = 1; .exitm; .endif
  .ifc \arg, LR; sp.lr.__has_items = 1; .exitm; .endif
  # catch 'lr' keyword as a special case, instead of as part of sprs

  ifnum.check_ascii
  # 'num' is evaluated as numerical or not
  # - we currently have 'num' loaded with 'sp.chars$0'

  .if num; sp.temp \arg
  # if it is, then we send it to 'sp.temp' to help define temporary memory

  .else; ifdef spr.\arg
    .if def; enum.mut.literal.sp_obj sp.main, sp.main.__count
      sp.main.__items, \arg
      sp.main.__has_items = 1
      # If it's a valid spr dictionary keyword, then use that

    .else; sp.temp \arg; .endif
  .endif # Else, just assume it's an input for 'sp.temp'

.endm; .macro sp.__main_prolog
  .if sp.lr.__has_items;   mflr r0; .endif;  sidx.noalt "<stwu sp, -sp.frame>", sp.mem_ID,"<(sp)>"
  .if sp.lr.__has_items;   stw r0, sp.frame+4(sp); .endif
  .if sp.main.__has_items; sp.main.__items sp.__stmspr; .endif
  .if sp.gprs.__has_items; sp.__stmw; .endif
  .if sp.fprs.__has_items; stmfd 32-(sp.fprs.low+1), sp.fprs.base(sp); .endif

.endm; .macro sp.__main_epilog
  .if sp.fprs.__has_items; lmfd 32-(low+1), sp.fprs.base(sp); .endif
  .if sp.gprs.__has_items; sp.__lmw; .endif
  .if sp.main.__has_items; sp.main.__items sp.__lmspr; .endif
  .if sp.lr.__has_items;   lwz r0, sp.frame+4(sp); .endif; addi sp, sp, sp.frame
  .if sp.lr.__has_items;   mtlr r0; .endif

.endm; .macro sp.pop.__build, enum
  sidx.noalt "<\enum\().total>", sp.mem_ID, "< = \enum\().bytes >"
  sidx.noalt "<\enum\().base>", sp.mem_ID, "< = sp.frame_build>"
  sp.frame_build = (sp.frame_build + \enum\().bytes + 0xF) & ~0xF
  sp.mem.popm \enum\().base, \enum\().total

.endm; .macro sp.__stmspr, va:vararg;
  sidx.noalt "<stmspr r0, sp.main.base>", sp.mem_ID, "<(sp), \va >"
.endm; .macro sp.__lmspr, va:vararg;
  sidx.noalt "<lmspr r0, sp.main.base>", sp.mem_ID, "<(sp), \va >"
.endm; .macro sp.__stmw
  sidx.noalt2 "<sp.__mw_ev stmw, sp.main.base>", sp.mem_ID, "<, sp.main.total>", sp.mem_ID
.endm; .macro sp.__lmw
  sidx.noalt "<sp.__mw_ev lmw, sp.main.base>", sp.mem_ID, "<, sp.main.bytes>"
.endm; .macro sp.__mw_ev, ins, base, total; \ins 32 - (\total >> sp.gprs.byte_align), \base (sp)
.endm

# --- end of method definitions

stack sp.mem
# this is a stack for storing memory of nested frame vars in enumerators

enc.new sp.chars, 0, 1
# this is an encoder stack for sampling the first 2 chars of inputs

items.method sp.main.__items
# this is an items buffer, method for extracting spr keywords

sp.mem_ID$ = 0
sp.mem_ID = sp.mem_ID$
# memory ID is a unique ID given to each frame for generating errata

sp.lr.__has_items = 0
# initial state of a flag not defined by the enumerators

sp.frame = 0
sp.prolog = 0
sp.epilog = 0
# state memory, for some changing the behavior of sp.fprs in frame body vs frame prolog

sp_obj sp.main,2,,,+1,(0)
sp_obj sp.temp,0,sp.,,+4,(0)
sp_obj sp.gprs,2,,,-1,(31)
sp_obj sp.fprs,3,,,-1,(31)
sp.main.mode enum_parse, sp.main
sp.temp.mode literal, sp_obj
# create mutated enumerators

# --- sp.push and sp.pop are now ready to use

.purgem sp_obj
# temporary constructor has been purged

.endif




































# temporary constructor:
.macro sp.__new_sp_obj, self, stride, va:vararg
  enum.new sp.\self, \va
  sp.\self\().mode enum_parse, \self
  sp.\self\().mode count, sp_obj
  sp.\self\().mode reset, sp_obj
  sp.\self\().byte_stride = \stride
  sp.\self\().items = 0
  sp.\self\().restart























.macro enum.__new_sp_obj, self, varg:vararg
  enum.new sp.\self, \varg

  \self\().mode restart, sp_obj
  \self\().mode count, sp_obj
  # mutate new enumerator to make an 'sp_obj'

  sp.__new_items \self\().items
  # generate a new blank string

  stack \self\().__mem
  \self\().__mem.mode push_post, sp_obj
  # generate a new stack, for memory
  # - uses mutator for stacking enumerator and string memory

  .macro \self\().items, va:vararg
    .ifb \va; str.lit \self\().items, \self
    .else; str.concitems \self\().items, \va; .endif
  .endm; # method for building/using items

.endm; .macro sp.push, va:vararg

.irp x, sp, sprs, gprs, fprs, temp


.endm; .macro sp.__push, self

.endm; .macro sp.pop, va:vararg

.endm; .macro sp.__pop, self

.endm; .macro sp.__new_items, self=sp.items
.if sp.__items.s == sp.__items.q
  sp.items_ID$ = sp.items_ID$ + 1
  sidx.noalt "<str sp.__items>", sp.mem_ID
  \self = str$
.else; sp.__items.pop; \self = sp.__items; .endif

.endm; .macro sp.__free_items, self=sp.items
  str.pointer \self
  sp.__items.push str.pointer

.endm; .macro enum.mut.restart.sp, self, va:vararg

.endm; .macro enum.mut.count.sp, self, sym, va:vararg

.endm; .macro enum.mut.enum_parse.sp, self, pfx, sfx, va:vararg

.endm; .macro enum.mut.enum_parse.sprs, self, pfx, sfx, va:vararg

.endm; .macro enum.mut.enum_parse.gprs, self, va:vararg

.endm; .macro enum.mut.enum_parse.fprs, self, va:vararg

.endm




sp.mem_ID$ = 0
sp.items_ID$ = 0
sp.mem_state = 0
stack sp.mem_ID, sp.mem_lrsp.__items
sp.__new_sp_obj sp.sp
sp.__new_sp_obj sp.sprs
sp.__new_sp_obj sp.gprs
sp.__new_sp_obj sp.fprs
sp.__new_sp_obj sp.temp

enc sp.sampler, [0], [2]  # only sample chars 0, 1, and 2 when sampling register names













.macro sp.push, va:vararg
  sp.mem_stack.push
  # flush current buffer

  sp.mem_stack.push sp.mem_ID, sp.mem_gprs, sp.mem_fprs, sp.mem_sprs, sp.mem_lr
  sp.mem_ID$ = sp.mem_ID$ + 1
  sp.mem_ID = sp.mem_ID$
  # increment unique memory frame ID counter

  .irp self, sp.fprs, sp.gprs, sp.sprs, sp.temp; sp.__gen \self; .endr
  # generate new enumerator variables, for flushing on sp.pop

  sp.mem_lr = 0
  sp.mem_gprs = 0
  sp.mem_fprs = 0
  sp.mem_sprs = 0
  sp.mem_sprs.init = 1
  .ifnb \va; sp.sprs.items \va; .endif
  sp.sprs \va
  # initial args go to sprs enumerator

  sp.mem_stack.pop
  # discard top of stack, and buffer top of memory instead


.endm; .macro sp.pop
  sp.frame_size = 0x10
  .if sp.temp.low < 0;  sp.frame_size = 0x10 -(sp.temp.low + 1); .endif
  sp.temp.size = (sp.temp.high + 0xF) & ~0xF
  sp.frame_size = sp.frame_size & ~0xF
  # if negative temp offsets were given, then offset the base of temp offsets to include them

  sp.sprs.size = sp.sprs.size << 2
  sp.gprs.size = sp.gprs.size << 2
  sp.fprs.size = sp.fprs.size << 3
  # finalize size of register lists

  .if sp.fprs.size; lmfd 31, sp.fprs.base(sp), 31-sp.fprs.size;.endif
  .if sp.gprs.size; lmw 31-sp.gprs.size, sp.gprs.base(sp);.endif
  .if sp.sprs.size;str.litq sp.sprs.items_ex, lmspr r0, sp.sprs.base(sp); .endif
  # write epilog restores

  .if sp.mem_lr; sidx.noalt "<lwz r0, sp.frame_size>", sp.mem_ID, "<+4(sp)>"; .endif
  sidx.noalt "<addi sp, sp, sp.frame_size>", sp.mem_ID
  .if sp.mem_lr; mtlr r0; .endif
  # write epilog

  .irp self, sp.temp, sp.sprs, sp.gprs, sp.fprs; sp.__flush \self; .endr
  # flush pending enumerator values


  sp.frame_size = (sp.frame_size + 0x17) & ~0xF
  sidx.noalt "<sp.frame_size>", sp.mem_ID, "< = sp.frame_size>"
  sp.mem_stack.pop sp.mem_lr, sp.mem_sprs, sp.mem_fprs, sp.mem_gprs, sp.mem_ID
  # restore old mem_ID to return to previous nested frame (or initial frame state, which is blank)


.endm; .macro enum.new_sp_obj, self, va:vararg
  enum.new sp.\self, \va
  sp.\self\().mode restart, sp
  sp.\self\().mode enum_parse, sp
  sp.\self\().mode count, sp
  # mutate new enumerator to make an 'sp_obj'

  sp.items_gen sp.\self
  # generate a new blank string

  .irp x, .base, .lowest, .highest, .total, .low, .high, .size; sp.\self\x = 0;.endr
  sp.\self\().restart
  # set default properties

  .macro sp.\self\().items, varg:vararg
    .ifb \varg;
      .if sp.\self\().size; sp.\self\().restart; str.lit sp.\self\().items, sp.\self; .endif
    .else; str.concitems sp.\self\().items, \varg
    .endif
  .endm # '.items' method restores past recored input arguments, or concatenates new items to list

.endm; .macro sp.items_gen, self
  sp.items_ID$ = sp.items_ID$ + 1
  \self\().items = str$ + 1
  sidx.noalt "<str \self\().items>", sp.items_ID$

.endm; .macro sp.__gen, self
  sp.mem_stack.push \self\().items
  sp.items_gen \self
  # push items list, and generate a new one

  .irp x, .base, .lowest, .highest, .total;
    sp.mem_stack.push \self\x
    sidx.noalt "<\self\x = \self\x>", sp.mem_ID
  .endr  # push all delayed descriptor variables, and generate new ones

  \self\().restart
  # restart enumerator

.endm; .macro sp.__flush, self
  sidx.noalt "<\self\().total>", sp.mem_ID, "< = \self\().size>"
  sidx.noalt "<\self\().highest>", sp.mem_ID, "< = \self\().high>"
  sidx.noalt "<\self\().lowest>", sp.mem_ID, "< = \self\().low>"
  sidx.noalt "<\self\().base>", sp.mem_ID, "< = sp.frame_size>"
  sp.frame_size = sp.frame_size + (\self\().size + 0xF) & ~0xF
  # flush delayed assignments to finalize prolog/epilog information

  .irp x, .total, .highest, .lowest, .base
    sp.mem_stack.pop \self\x
  .endr # restore old values from stack

  sp.mem_stack.pop \self\().items
  # restore old items from stacked items strings

  \self\().items

.endm



# --- enum mutators:
.macro enum.mut.restart.sp, self, va:vararg
  enum.mut.restart.default \self
  \self\().low = \self\().count
  \self\().high = \self\().count
  \self\().size = 0
  # extend default restart event

.endm; .macro enum.mut.count.sp, self, sym, va:vararg
  enum.mut.count.default \self, \sym, \va
  .if \self\().count < \self\().low; \self\().low = \self\().count; .endif
  .if \self\().count > \self\().high; \self\().high = \self\().count; .endif
  # update highs and lows on count


.endm; .macro enum.mut.enum_parse.sp, self, pfx, sfx, va:vararg
  enum.mut.enum_parse.default \self, \pfx, \sfx, \va
  \self\().size = \self\().high - \self\().low
  \self\().items \va
  # update size, and append items

.endm; .macro enum.mut.enum_parse.sprs, self, pfx, sfx, va:vararg
  str sp.sprs.items_ex
  # generate/clear temporary items string for loop to collect spr register names/numbers in

  sp.mem_lr = 0
  .irp arg, \va
    .ifnb \arg
      sp.sampler.s[0]
      sp.sampler.enc "\arg"
      .if sp.sampler.s >= 2
        .if (sp.sampler$1 >= 0x30) && (sp.sampler$1 <=0x39)    # decimal number
          .if (sp.sampler$0 == 0x72) || (sp.sampler$0 == 0x52) # r or R
            .if \arg <= sp.gprs.low; sp.gprs.low = \arg-1; .endif; sp.sampler.s = 0
            # if 'rN' then update lowest GPRs

          .elseif (sp.sampler$0 == 0x66) || (sp.sampler$0 == 0x46) # f or F
            .if \arg <= sp.fprs.low; sp.fprs.low = \arg-1; .endif; sp.sampler.s = 0
            # if 'fN' then update lowest FPRs

          .endif
        .endif
      .endif
      .if sp.sampler.s >= 2
        .ifc "\arg", "lr"; sp.mem_lr = 1
        .else; .ifc "\arg", "LR"; sp.mem_lr = 1
        # if 'lr' then save flag

          .else; sp.sprs.items_ex.concitems \arg; sp.sprs.size = sp.sprs.size + 1;
        .endif; .endif; # else, save argument for passing to spr macro
      .endif
    .endif
  .endr
  sp.gprs.size = sp.gprs.high - sp.gprs.low
  sp.fprs.size = sp.fprs.high - sp.fprs.low
  # update sizes from parse to compare against memory values

  .if sp.mem_sprs.init
   .if sp.mem_lr; mflr r0; .endif
    sidx.noalt "<stwu sp, -sp.frame_size>", sp.mem_ID, "<(sp)>"
    .if sp.mem_lr; sidx.noalt "<stw r0, sp.frame_size>", sp.mem_ID, "<+4(sp)>"; .endif
    # prolog

  .endif


  .if (sp.mem_gprs == 0) && sp.gprs.size
    sidx.noalt "<stmw sp.gprs.lowest>", sp.mem_ID, "<+1, sp.gprs.base(sp)>"
    sp.mem_gprs = sp.gprs.size
    sp.gprs.count = sp.gprs.low
    # gpr storage (for gprs detected in sprs line)

  .endif
  .if sp.mem_fprs != sp.fprs.size
    stmfd 31-sp.mem_fprs, (sp.mem_fprs<<3)+sp.fprs.base(sp), sp.fprs.low+1
    sp.mem_fprs = sp.fprs.size
    sp.fprs.count = sp.fprs.low
    # fpr storage (partial, for fprs detected in sprs line)

  .endif
  .if sp.mem_sprs.init && sp.sprs.size
    sp.sprs.items_ex.litq stmspr, r0, sp.sprs.base(sp)
    spr.mem_sprs = sp.sprs.size
  .endif
  sp.mem_sprs.init = 0

.endm; .macro enum.mut.enum_parse.gprs, self, va:vararg
  enum.mut.enum_parse.sp \self, \va
  .if (sp.mem_gprs == 0) && \self\().size
    stmw \self\().lowest+1, \self\().base(sp)
  .endif;  sp.mem_gprs = \self\().size
  # update sp.gprs.size, and write late stmw if not already written for this frame


.endm; .macro enum.mut.enum_parse.fprs, self, va:vararg
  enum.mut.enum_parse.sp \self, \va
  .if sp.mem_fprs != \self\().size
    stmfd 31-sp.mem_fprs, (sp.mem_fprs<<3)+\self\().base(sp), \self\().low+1
  .endif;  sp.mem_fprs = \self\().size
  # update sp.fprs.size, and write new stfds if necessary

.endm

enum.new_sp_obj gprs, , , (31), -1
sp.gprs.mode enum_parse, gprs

enum.new_sp_obj sprs
sp.sprs.mode enum_parse, sprs

enum.new_sp_obj fprs, , , (31), -1
sp.fprs.mode enum_parse, fprs

enum.new_sp_obj temp, "sp.", , (0), +4
.endif
