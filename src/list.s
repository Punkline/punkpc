.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module list, 0x200
.if module.included == 0; punkpc stack

# --- Constructor:
 .macro list, self, varg:vararg
# Construct each given list object, if name hasn't already been defined
  stack \self
  \self\().step = 1
  .irp ppt,i,iter;\self\().\ppt=0;.endr
  ifdef \self\().is_list; .if ndef; \self\().is_list = 0; .endif
  .if \self\().is_list == 0; \self\().is_list = \self\().is_stack
    .macro \self\().s, idx=\self\().ss, va:vararg
      mut.call \self, s, default, stack,,, \idx, \va
    .endm; .macro \self\().ss, idx=\self\().ss, va:vararg
      mut.call \self, ss, default, stack,,, \idx, \va
    .endm; .macro \self\().q, idx=\self\().qq, va:vararg
      mut.call \self, q, default, stack,,, \idx, \va
    .endm; .macro \self\().i, va:vararg=0
      mut.call \self, i, default, stack,,, \va
    .endm; .macro \self\().get, idx=\self\().i, sym=\self, va:vararg
      mut.call \self, get, default, stack,,, \idx, \sym, \va
    .endm; .macro \self\().set, idx=\self\().i, val=\self, va:vararg
      mut.call \self, set, default, stack,,, \idx, \val, \va
    .endm; .macro \self\().new, size=1, fill=\self\().fill, va:vararg
      mut.call \self, new, default, stack,,, \size, \fill, \va
    .endm; .macro \self\().iter, va:vararg=\self
      mut.call \self, iter, default, stack,,, \va
    .endm
    # end of method definitions
  .endif

  stack.purge_hook \self, i, get, set, iter, oob_iter, oob_i, idx_i
  # Default modes handle the object methods in an overridable way

.ifnb \varg; list \varg; .else; .irp ppt,fill,size,;stack.\ppt = 0; .endr; .endif
# reset constructor argument properties after constructing all varargs

.endm;


# --- static methods:
  stack.meth, i, get, set, iter
  # these class-level methods can handle object pointers


# --- Static mutable behaviors
 .macro stack.mut.i.default, self, va:vararg=0;
  mut.call \self, idx_i, range, stack,,, \va
# i is a mutable index method that can be invoked with the '.iter' method
# - the .i index property can is also modified by the '.get' and '.set' methods

.endm; .macro stack.mut.get.default, self, idx, sym, va:vararg
  .ifb \sym\va; stack.mut.get.default \self, \idx, \self
  .else; .ifb \idx; \self\().i = \self\().i - 1
    .else; \self\().i = \idx - 1; .endif
    .irp x, \sym, \va
      \self\().i = \self\().i + 1
      .ifnb \x
        sidx.get \self, \self\().i
        \x = sidx
      .endif; .endr
  .endif
.endm; .macro stack.mut.set.default, self, idx, val, va:vararg
\self\().i = \idx - 1
.irp x, \val, \va
  \self\().i = \self\().i + 1
  .ifnb \x
    sidx = \x
    sidx.set \self, \self\().i
  .endif; .endr
  # get/set create an I/O for interfacing with iter index, in list

.endm; .macro stack.mut.iter.default, self, va:vararg
  .ifb \va; stack.mut.iter.default \self, \self
  .else; .irp sym,\va
    .ifnb \sym;
      stack.idx = \self\().i + \self\().step
      .if stack.idx >= \self\().s; stack.oob=1
      .elseif stack.idx < \self\().q; self.oob=1; .endif
      .if stack.oob; mut.call \self, oob_iter, rot, stack,,, \va; .endif
      .if stack.oob==0; \self\().i = stack.idx
      \self\().iter = \self; \sym = \self; stack.get \self; .endif
    .endif; stack.oob=0
  .endr; stack.oob=0; .endif
  # iter is a special iterator method that invokes the .i and the .get methods
  # - this in turn will trigger any custom callbacks plugged into .i and .get




# --- Default Modes
# - these create the various 'modes' for I/O methods



# --- NOP - Read/Write
.endm; .macro stack.mut.oob_iter.nop, self, va:vararg; stack.oob=0
# 'nop' mode keywords, for no action on both read and write OOB




# --- ROT - Read/Write
.endm; .macro stack.mut.oob_iter.rot, self, sym, va:vararg
  stack.idx = stack.idx - \self\().q; stack.oob=0
  .if stack.idx; stack.idx = stack.idx % (\self\().s - \self\().q);.endif
  .if stack.idx < 0; stack.idx = \self\().s + stack.idx
  .else; stack.idx = stack.idx + \self\().q; .endif;
# 'rot' mode keyword, for continuing out-of-bounds by rotating back to opposite side of memory range



# --- NULL - Read-only
.endm; .macro stack.mut.oob_iter.null, self, sym, va:vararg
  \sym = \self; \self = \self\().fill
# 'null' mode keywords, for producing a fill value when reading OOB
# - this will use the .fill property (0 by default) to give you a 'null' instead of a memory value




# --- CAP - Read-only
.endm; .macro stack.mut.oob_iter.cap, self, va:vararg
  \self\().i = \self\().s-\self\().step; stack.oob=0

# 'cap' mode keywords, for undoing the iteration of a count that reads OOB
# - this will subtract index step that was just made so that the final element is re-read




# --- i INDEX MODES - i index methods handle how input is interpreted before checking for oob
.endm; .macro stack.mut.idx_i.range, self, idx, va:vararg;
  stack.call_mut \self, oob_i, rot, (\idx + \self\().q)
.endm; .macro stack.mut.idx_i.rel, self, idx, va:vararg;
  stack.call_mut \self, oob_i, rot, (\idx + \self\().i)
.endm; .macro stack.mut.idx_i.abs, self, idx, va:vararg;
  stack.call_mut \self, oob_i, rot, \idx




# --- i OOB CHECKS
.endm; .macro stack.mut.oob_i.nop, self, idx, va:vararg;  \self\().i = \idx
.endm; .macro stack.mut.oob_i.rot, self, idx, va:vararg
  \self\().i = \idx - \self\().q
  .if \self\().i; \self\().i = \self\().i % (\self\().s - \self\().q);.endif
  .if \self\().i < 0; \self\().i = \self\().s + \self\().i
  .else; \self\().i = \self\().i + \self\().q; .endif
.endm; .macro stack.mut.oob_i.cap, self, idx, va:vararg
  \self\().i = \idx; .if \self\().i >= \self\().s; \self\().i = \self\().s - 1; .endif
  .if \self\().i < \self\().q; \self\().i = \self\().q; .endif
.endm
.endif
/**/
