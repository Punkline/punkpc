.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module items, 2
.if module.included == 0
items.__free$ = 0
items.__mem$ = 0
items.alloc = 0
items.free = 0
items = 0


# some argument names have been obscured to prevent naming issues in altmacro escapes
#  __ prefixes have been added to some escape keywords


.macro items.method, self, __ppt
# protected argnames for altmacro usage

  .ifb \__ppt; items.method \self, \self; .exitm; .endif  # default property is self
  items.__altm # save state and enter altmacro mode

  .irp __slf, \self\().is_items_method
  # escape self property for ndef without any backslashes

    .ifndef __slf; \__slf = 0; .endif
    # catch undefined with ndef and a dummy macro, for purge step

    .ifndef __ppt; \__ppt = 0; .endif
    # free existing pointer

  .endr; .noaltmacro
  .if \__ppt; items.free \__ppt; .endif
  .if \self\().is_items_method == 0
    items.alloc \__ppt # allocate a fresh buffer for this pointer property
    \self\().is_items_method = \__ppt; .macro \self;.endm;
  .endif  # set obj id, if it doesn't already exist
  .purgem \self # purge old method (or dummy on first use)
  .macro \self, va:vararg; items.mut.method.default \self, \__ppt, \va; .endm
  items.__altm_reset # recover state
# -- This is a high level method constructor
# - it creates a small method object with a pointer property that can be changed to a new buffer

.endm; .macro items.mut.method.default, self, ppt, m, va:vararg;
  .if \ppt >= 0
    .ifb \m\va; items.mut.blank.default \self, \ppt
    .elseif \ppt==0; items.mut.null.default \self, \ppt
    .endif; .ifb \m; items.append \ppt, \va
    .else; items.emit \ppt, \m, \va
    .endif
  .endif

.endm; .macro items.mut.blank.default, self, ppt
    .if \self\().is_items_method == \ppt; items.free \self\().is_items_method; \ppt = 0
    .else; \ppt = \self\().is_items_method; .endif # handle case of blank args

.endm; .macro items.mut.null.default, self, ppt
  items.free \self\().is_items_method
  items.alloc \ppt
  \self\().is_items_method = \ppt # handle case of null pointer

.endm; .macro items.alloc, __va:vararg=items
  items.__altm
  .irp __obj, \__va
    .if items.__free$ <= 0; items.__new; .endif
    items.__em <items.__alloc \__obj, items.__free>, %items.__free$
  .endr
  items.__altm_reset
# -- This is a high level allocator method for making buffers that can be pointed to by method objs
# - you may create many pointers at a very low memory cost, and keep them separately from the objs
# - the objs may then be used to cycle between pointers by changing the pointer property



.endm; .macro items.free, __va:vararg=items
  items.__altm
  .irp __pntr, \__va
    .ifnb \__pntr
      .if (\__pntr > 0)
        items.__em <items.__free items.__mem> %\__pntr
        \__pntr = 0
      .endif
    .endif
  .endr
  items.__altm_reset
# -- This is buffer freer -- not a method object freer
# - use this to collapse the memory used by a previous buffer and recycle it for a new purpose
# - implementing this is only important if you expect to make a lot of (or very large) buffers



.endm; .macro items.append, __pntr=items, __va:vararg
  .if \__pntr > 0; items.__altm; .ifb \__va;
      items.__em2 <items.__mem>, %\__pntr, <.buf items.__append, items.__mem>, %\__pntr; .else;
      items.__em2 <items.__mem>, %\__pntr, <.buf items.__append, items.__mem>, %\__pntr, <,,\__va>
    .endif; items.__altm_reset
  .endif
# -- This is a high level class method that can be used without instantiating a method object

.endm; .macro items.emit, __pntr=items, __mcro=items.__statement, __va:vararg
  .if \__pntr > 0;
    items.__altm
    items.__em <items.__mem>, %\__pntr, <.buf \__mcro,, \__va>
  .endif
# -- This is a high level class method that can be used without instantiating a method object

.endm; .macro items.irp, __pntr=items, __mcro, __va:vararg
  .if \__pntr > 0;
    items.__altm
    items.__em <items.__mem>, %\__pntr, <.buf items.__irp, \__mcro, \__va>
  .endif

.endm; .macro items.irpc, __pntr=items, __mcro, __va:vararg
  .if \__pntr > 0;
    items.__altm
    items.__em <items.__mem>, %\__pntr, <.buf items.__irpc, \__mcro, \__va>
  .endif
.endm; .macro items.__irp, __mcro, __va:vararg
  .irp __itm, \__va; .ifnb \__itm; \__mcro \__itm; .endif; .endr

.endm; .macro items.__irpc, __mcro, __va:vararg
  .irpc __itm, \__va; .ifnb \__itm; \__mcro \__itm; .endif; .endr




# --- hidden methods
.endm; .macro items.__statement, m, va:vararg; \m \va
# for defaulting to handle a list of items using the first item as a macro statement

# --- altmacro methods:

.endm; .macro items.__new
  items.__mem$ = items.__mem$ + 1
  items.__em <items.__mem>, %items.__mem$, <= items.__mem$>
  items.__em <items.__mem>, %items.__mem$, <.purgem = 0>
  items.__em <items.__build items.__mem>, %items.__mem$
  items.__em <items.__free items.__mem>, %items.__mem$
  # for creating new memory buffers

.endm; .macro items.__alloc, __obj, __pntr
  \__obj = \__pntr
  items.__em <items.__build items.__mem>, %\__pntr
  items.__free$ = items.__free$ - 1
  items.__update
  # for allocating a memory buffer from the free stack; generating new buffers if out of free ones

.endm; .macro items.__build, __self
  .if \__self\().purgem; .purgem \__self\().buf; .endif
  \__self\().purgem = 1
  .noaltmacro
  .macro \__self\().buf, m, arg, va:vararg;items.__altm_reset;\m \arg \va;.endm
  .altmacro
  # for building the first iteration of an items list
  # - can be used to clear while in altmacro mode

.endm; .macro items.__free, __self
  .if \__self\().purgem
    .purgem \__self\().buf
    \__self\().purgem = 0
    items.__free$ = items.__free$ + 1
    items.__em <items.__free>, %items.__free$, < = \__self>
    items.__update
  .endif
  # for purging buffers and updating the freestack metadata

.endm; .macro items.__append, __self, __varg:vararg
  \__self\().purgem = \__self\().purgem + 1
  .purgem \__self\().buf
  .noaltmacro
  .macro \__self\().buf, m, arg, va:vararg;items.__altm_reset;\m \arg \__varg \va;.endm
  .altmacro
  # for building post-initial iterations of an items list
  # - must be called with

.endm; .macro items.__update
  items.free = items.__free$; items.alloc = items.__mem$ - items.__free$
  # for updating the user level measures of allocated/free items buffers


.endm; .macro items.__em,p,i,s,va:vararg;\p\()$\i\s\va
.endm; .macro items.__em2,p,i,s,i2,s2,va:vararg;\p\()$\i\s\()$\i2\s2\va
# mimics parts of 'sidx' without the high-level stuff

.endm; .macro items.__altm
  .irp _altm,%1;items.__altm=0;.ifc \_altm,1;items.__altm=1;.endif;.endr; .altmacro
.endm; .macro items.__altm_reset
  .if items.__altm;.altmacro;.else;.noaltmacro;.endif;
  # mimics parts of 'ifalt' with independent memory

.endm
items.method items
.endif
