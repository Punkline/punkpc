/*## Header:
# --- Stack Pointer module
# Utility for automating pushing and popping stack frames and setting up registers/space for funcs

# This uses many high-level structures made by other modules, like strings, stacks, and enumerators
# The various constructs form pointer relations that build a scalar set of frame parameters
# The user may use these parameters when referencing stack offsets, or registers in instructions
# - these parameters stack as needed to accomodate as many frames as necessary in the assembler
#   - if frames are nested within one another, each frame's parameters will be restore on pop
# - uniquely named, undefined symbols are used to 'look ahead' to the .pop of each frame...
#   - this makes it possible to adjust the size and the number of saved GPRs mid-frame
#   - floats and special registers like CR/CTR must still be specified in prolog/epilog, if needed

##*/
##/* Updates:
# version 0.0.1
# - added to punkpc module library

##*/
/*## Attributes:

# --- Class Properties

# un-finalized properties for this frame:
# - un-finalized properties for a given frame only become finalized after sp.pop is called
#   - until then, they don't have a committed value, and may change as more stuff gets assembled
#   - they are safe to read from in most instructions while un-finalized
#     - regardless of when the instruction was written; the finalized value will be inserted
#     - they are however not safe to use in things like '.if' directives, which require evaluation

# --- sp.frame.size  - size of the whole frame

# --- sp.fprs.size   - size of saved FPRs
# --- sp.fprs.base   - base offset of saved special registers
# --- sp.fprs.lowest - lowest numbered saved FPR (in range n ... 31)

# --- sp.gprs.size   - size of saved GPRs
# --- sp.gprs.base   - base offset of saved GPRs
# --- sp.gprs.lowest - lowest numeber of saved GPR (in range n ... 31)

# --- sp.sprs.size   - size of saved SPRs
# --- sp.sprs.base   - base offset of saved SPRs

# --- sp.temp.size   - size of temporary data partition in stack frame
# --- sp.temp.base   - base offset of temporary data partition in stack frame
# - these are offsets that can be used in idx(sp) loads/stores

# --- sp.(named offset) - these are stack offsets for temporary data, and are un-finalized
# - these are all contained within sp.temp -- and influence the total size
# - they can be defined anywhere in the frame with 'sp.temp' using the enumerator syntax


# finalized properties:
# - these properties are updated in real-time, and can be used in absolute expressions like normal

# --- (named register)  - these are enumerations between 0 and 31 that are final, absolute
# - these are register names given to 'sp.gprs' 'sp.fprs' or 'sp.regs'

# --- sp.fprs.bytes
# --- sp.gprs.bytes
# --- sp.sprs.bytes
# --- sp.temp.bytes
# These variables counts the eventual value of sp.*.size properties
# - you can sample the current un-aligned sizes this way

# --- sp.fprs.items
# --- sp.gprs.items
# --- sp.sprs.items
# --- sp.temp.items
# These are actually the main properties of scalar stacks holding pointers to strings of args
# - these remember the inputs you made for the current frame, so they can be restored on .pop



# --- Class Methods ---

# --- sp.push  arg, ...
# sp.push is the begining of a prolog for a new stack frame
# - a number of special purpose register names are accepted as arguments, for extra backup options
  # --- cr  --  condition register - backing up allows all 32 bits to be used freely inside of frame
  # --- ctr --  counter register   - backing up preserves counts from the previous frame
  # --- qr0...7 -- Graphical Quantization Register - for packing/unpacking fixed/floating points
  # --- qr, gqr -- an alias for QR7
  # --- r0...31 -- anonymous saved GPRs - unnamed
  # --- f0...31 -- anonymous saved FPRs - unnamed
  # --- nolr    -- special keyword that tells the frame not to bother backing up/restoring lr
  # --- other   -- will be converted into an SPR ID for mtspr/mfspr instructions


# --- sp.temp  arg, ...
# sp.temp can be used to establish sized sections of a temporary allocation in the stack frame
# it can be called any number of times at any point within the frame, after sp.push is called
# - the arguments use the 'enum' syntax:
  # --- +n  -- change step size to 'n'
  # --- other --- becomes a named stack offset
# ex:  sp.temp  +0x20, xBlockA, xBlockB, xBlockC,  +8, xParamA,  +4, xParamB, xParamC
  ##   sp.xBlockA = (sp.xTemp_base + 0)
  ##   sp.xBlockB = (sp.xTemp_base + 0x20)
  ##   sp.xBlockC = (sp.xTemp_base + 0x40)
  ##   sp.xParamA = (sp.xTemp_base + 0x60)
  ##   sp.xParamB = (sp.xTemp_base + 0x68)
  ##   sp.xParamC = (sp.xTemp_base + 0x6C)


# --- sp.gprs  name, ...
# like sp.temp, sp.gprs can be called after sp.push to specify a list of saved register names
#   if no anonymous GPRs are defined in sp.push arguments, then this must be called at prolog
#   if it is not called, then no named GPRs will be saved to the stack frame
#   if it is called multiple times within the frame, the total count is still used in prolog/epilog
# - each given name will become a symbol that you can use in place of a register
# ex:  sp.gprs  rGObj, rData, rJObj, rDObj
  ##   automatically back up 5 saved registers, in addition to any anonymous GPRs


# --- sp.fprs  name, ...
# like sp.gprs, but it must be specified all at once in the prolog
# - this is due to the fact that we are not able to utilize linker sections with just the assembler
# - you may call sp.fprs multiple times in a contiguous sequence, if needed


# --- sp.regs  arg, ...
# unlike sp.gprs or sp.fprs -- sp.regs does not count towards the size of the stack frame
# - it can be used as needed to specify a set of register names for r3...r12, or f0...f16
# - arguments use the 'enum' syntax, and can use it fully without issues:
  # --- +n  -- change step to increment by 'n'
  # --- -n  -- change step to decrement by 'n'
  # --- (n) -- set counter to absolute value of 'n'
  # --- other -- becomes a volatile named register
# popping the stack frame will automatically restart the counter memory
# - to manually restart the counter memory, use the 'sp.regs.restart' method


# --- sp.pop
# uses the calls made to specify all of the above about a frame to collapse it in the epilog
# after popping, if the frame was nested within another frame, then the old frame memory is restored
# - if 'nolr' option was provided, then this frame does not provide a 'blr' instruction


##*/
/*## Examples:
.include "punkpc.s"
punkpc sp
# Use the 'punkpc' statement to load this module, or include the module file directly


##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module sp, 1
.if module.included == 0; punkpc enum, enc, lmf, spr, str, dbg

stack sp, sp.__items
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
