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
/*## Attributes:

# --- Class Properties ---

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
.include "./punkpc/sp.s"


##*/

.ifndef sp.included; sp.included=0; .endif; .ifeq sp.included; sp.included = 1

.include "./punkpc/enum.s"   # - enum will help us create register/offset inputs for stack to count
.include "./punkpc/stacks.s" # - stacks module will help us handle nested runtime stack frames
.include "./punkpc/lmf.s"    # - for handling float backups with lmfd and stmfd
.include "./punkpc/spr.s"    # - for handling spr backups with stmspr and lmspr
.include "./punkpc/str.s"    # - for remembering argument literals in purgable buffers

str sp.err.reminder "\n\nTo disable these warnings,"

sp.mem_ID$ = 0
sp.base = 0
.macro sp.obj, self, alignment, va:vararg
  enum.new sp.\self\().enum, \va
  stack sp.\self\().items
  stack sp.\self\().bytes
  stack sp.\self\().size
  stack sp.\self\().base
  sp.\self\().updating = 1
  .macro sp.\self, va:vararg; sp.\self\().enum \va
  .endm; .macro sp.\self\().push
    sp.\self\().items.push
    sp.\self\().bytes.push
    sp.\self\().size.push
    sp.\self\().base.push
    sidx.noalt "<str sp.\self\().items_mem>", sp.mem_ID,
    sidx.noalt "<sp.\self\().items = sp.\self\().items_mem>", sp.mem_ID,"<.isStr>"
    sidx.noalt "<sp.\self\().size = sp.\self\().size_mem>", sp.mem_ID
    sidx.noalt "<sp.\self\().base = sp.\self\().base_mem>", sp.mem_ID
    \self\().bytes = 0
  .endm; .macro sp.\self\().pop
    sidx = (sp.\self\().bytes + (\alignment - 1)) & ~(\alignment - 1)
    sidx.set sp.\self\().size, sp.mem_ID
    sidx = sp.base
    sidx.set sp.\self\().base, sp.mem_ID
    sp.base = sp.base + sp.\self\().size
    sp.\self\().items.pop
    sp.\self\().bytes.pop
    sp.\self\().size.pop
    sp.\self\().base.pop
  .endm
.endm

sp.obj gprs, 0x4, "", -1, (r31)
sp.obj fprs, 0x8, "", -1, (f31)
sp.obj sprs, 0x4, "sp.", +4, (0)
sp.obj temp, 0x4, "sp.", +4, (0)
.irp x, gprs, fprs, sprs, temp, .purgem sp.\x\().enum.enum_callback; .endr
.macro sp.gprs.enum.enum_callback, self, sym, pfx, sfx
  .if \self\().updating

  .endif
.endm; .macro sp.fprs.enum.enum_callback, self, sym, pfx, sfx
  .if \self\().updating

  .endif
.endm; .macro sp.sprs.enum.enum_callback, self, sym, pfx, sfx
  .if \self\().updating

  .endif
.endm; .macro sp.temp.enum.enum_callback, self, sym, pfx, sfx
  .if \self\().updating

  .endif
.endm;














sp.mem_ID$ = 0
stack sp.mem_temp, sp.mem_gprs, sp.mem_fprs, sp.mem_sprs, sp.mem_lr, sp.mem_ID, sp.spr_items
enum.new sp.gprs, "", -1, (r31)  # saved GPRs to back up in stack frame
enum.new sp.fprs, "", -1, (f31)  # saved FPRs to back up in stack frame
enum.new sp.temp, "sp.", +4      # temporary memory allocation in stack frame
enum.new sp.regs, "", +1, (r3)   # - not saved to stack frame, but resets on pop
# create high-level objects for helping us manage the runtime stack frame in PPC functions
# - these are all both stacks and enumerators, simultaneously

.purgem sp.gprs.enum_callback
.macro  sp.gprs.enum_callback, self, sym, pfx, sfx
  .if \sym < sp.mem_gprs; sp.mem_gprs = \sym; .endif
.endm
.purgem sp.fprs.enum_callback
.macro  sp.fprs.enum_callback, self, sym, pfx, sfx
  .if \sym < sp.mem_fprs;
  i = ((32-\sym)<<3)
    sidx.noalt "<stfd \sym, i + sp.xFPR_base>", sp.mem_ID, (sp)

  sp.mem_fprs = \sym +1; .endif
.endm
# mutators help keep saved register counts intact


.macro sp.push, va:vararg
  sp.mem_ID$ = sp.mem_ID$ + 1
  sp.mem_ID.push
  sp.mem_lr.push
  sp.mem_gprs.push
  sp.mem_fprs.push
  sp.mem_sprs.push
  sp.mem_temp.push
  sp.spr_items.push
  # all old values have been saved, in case frame is being nested

  sp.mem_ID = sp.mem_ID$ # this is a unique ID generated by sp.push
  # - we use this to uniquely identify each new frame in the assembly

  sp.mem_gprs = 32
  sp.mem_fprs = 32
  # 32 - 32 = 0 -- which is how many default registers are backed up for each type

  sidx.noalt "<str sp.sprs_buffer>", sp.mem_ID
  # creates a uniquely named string buffer for storing spr arguments

  sidx.noalt "<str.point.get sp.sprs_buffer>", sp.mem_ID
  sp.spr_items = str.point
  # list pointer has been saved to scalar stack value sp.spr_items
  # - this lets us use the string buffer through a pointer kept in 'sp.spr_items'
  # - we can change this pointer as the stack is pushed, to nest multiple frames

  sp.mem_lr = 1
  # assume by default that frame will use lr
  # - only skip lr if 'nolr' option is found in arguments

  .irp a, \va; i = 0 # we use i to catch certain inputs in case selection below
    .irp  x, nolr, NOLR, noLR;       .ifc \x, \a; i = 5; .exitm; .endif; .endr
    .irp  x, noblr, NOBLR, nobLR;    .ifc \x, \a; i = 6; .exitm; .endif; .endr
    .irp  x, gprs,GPRs,GPRS,gpr,GPR; .ifc \x, \a; i = 7; .exitm; .endif; .endr
    .irpc c, \a;
      .if i == 0;   .irpc p, Rr;     .ifc \p, \c; i = 1; .exitm; .endif; .endr
        .if i == 0; .irpc p, Ff;     .ifc \p, \c; i = 3; .exitm; .endif; .endr; .endif
        .if i == 0; .exitm; .endif
      .else; .irpc n, 012345679;     .ifc \c, \n; i=i+1; .endif; .endr;  .exitm; .endif
    .endr
    .if     i == 0; # ... then this arg is for lmspr and stmspr
      .if sp.spr_items; str.conc sp.spr_items, ", \a"
      .else;            str.conc sp.spr_items, "\a"; .endif
      sp.mem_sprs = sp.mem_sprs + 4
      # - add arg to comma-separated sp_items buffer

    .elseif i == 2; # ... then this is an anonymous register backup
      sp.mem_gprs = \a
    .elseif i == 4; # ... then this is an anonymous float register backup
      sp.mem_fprs = \a;
    .elseif i == 5; # ... then this is a no-lr statement for the prolog/epilog
      sp.mem_lr = 0
    .elseif i == 6; # ... then this is a no-blr statement for the epilog
      sp.mem_lr = 2
    .elseif i == 7; # ... then this is a promise to include named GPRs later in the frame
      .if sp.mem_gprs == 32; sp.mem_gprs = 33; .endif
    .endif
  .endr

  .if sp.mem_fprs < 32; sp.fprs (sp.mem_fprs-1); .endif


  .if sp.mem_lr; mflr r0; .endif
  sidx.noalt "<stwu sp, sp.frame_size>", sp.mem_ID, (sp)
  .if sp.mem_lr; sidx.noalt "<stw r0, 4+sp.frame_size>", sp.mem_ID, (sp); .endif
  .if sp.mem_gprs < 32
    sidx.noalt2 "<stmw sp.gprs>",  sp.mem_ID, "<, sp.xGPR_base>", sp.mem_ID, (sp); .endif
  .if sp.mem_fprs < 32
    sidx.noalt "<stmfd sp.mem_fprs, sp.xFPR_base>", sp.mem_ID, (sp); .endif
  .if sp.mem_sprs
    str.litq sp.spr_items, sidx.noalt, "<stmspr r0, sp.xSPR_base>", sp.mem_ID,(sp); .endif
    # frame prolog instructions have been written, but not committed
    # - the space taken up (number of instructions) can't be modified beyond this point
    #   - however, the contents of each instruction will only be committed to once sp.pop is called

.endm; .macro sp.pop
  .if sp.mem_ID == 0; .exitm; .endif
  # don't attempt to pop dummy frame at bottom of stack

  sidx = 0x10;  sidx.set sp.xSPR_base, sp.mem_ID
  # sprs are committed
  sidx = sp.mem_sprs+sidx;  sidx.set sp.xGPR_base, sp.mem_ID
  # gprs are committed
  sidx = (((32-sp.mem_gprs)<<2)+sidx+7)&~7;  sidx.set sp.xFPR_base, sp.mem_ID
  # fprs are committed
  sidx = ((32-sp.mem_fprs)<<3)+sidx; sidx.set sp.xTemp_base, sp.mem_ID
  # temp sapce is committed
  sidx = (sp.temp.count+sidx+0x1F)&~0x1F;  sidx.set sp.frame_size, sp.mem_ID
  # frame size is committed
  sidx = sp.mem_gprs;  sidx.set sp.gprs, sp.mem_ID # registers are finalized
  sidx.noalt "<sp.fprs>", sp.mem_ID, "<=sp.mem_fprs-1>"
  # - the bases are summed up as they are each committed, using the previous value (sidx) as a base
  # - the total frame size is now calculated and aligned to a 0x20 byte ceiling

  .if sp.mem_sprs;
    str.litq sp.spr_items, sidx.noalt, "<lmspr r0, sp.xSPR_base>", sp.mem_ID,(sp); .endif
  .if sp.mem_fprs < 32
    sidx.noalt2 "<lmfd sp.fprs>", sp.mem_ID, "<, sp.xFPR_base>", sp.mem_ID, (sp); .endif
  .if sp.mem_gprs < 32
    sidx.noalt2 "<lmw sp.gprs>",  sp.mem_ID, "<, sp.xGPR_base>", sp.mem_ID, (sp); .endif
  .if sp.mem_lr; sidx.noalt "<lwz r0, 4+sp.frame_size>", sp.mem_ID, (sp); .endif
  sidx.noalt "<addi sp, sp, sp.frame_size>", sp.mem_ID
  .if sp.mem_lr; mtlr r0; .if sp.mem_lr != 2; blr; .endif; .endif
  # epilog has been written

  sp.gprs.restart
  sp.fprs.restart
  sp.temp.restart
  sp.mem_ID.pop
  sp.mem_lr.pop
  sp.mem_gprs.pop
  sp.mem_fprs.pop
  sp.mem_sprs.pop
  sp.mem_temp.pop
  sp.spr_items.pop
  # previous frame memory has been restored

.endm






.endif
