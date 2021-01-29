.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module data, 1
.if module.included == 0; punkpc if, sidx

# --- data - user layer
data.start.inline = 1    # this will cause data.start to create a branch over inline tables
data.start.use_blrl = 1  # this is a flag that will cause inline tables to create a blrl
# - you may bypass the need to use these by using 'data.table' instead of 'data.start'

data.base_reg = 12  # this can be set by 'data.end' and 'data.get' if given a single register arg
# - if set manually, the user may override the current 'base_reg' arg default for data.get

.ifndef punkpc.data.custom_namespace
# you can set the symbol 'punkpc.data.custom_namespace' to any value before including this file
# - if you do this, then these default module-level method names will not be generated

.macro data.table, name, loc; punkpc.data.table \name, \loc
.endm; .macro data.start, name, loc; punkpc.data.start \name, \loc
.endm; .macro data.end, reg; punkpc.data.end \reg;
.endm; .macro data.get, reg, keyword, base_reg; punkpc.data.get \reg, \keyword, \base_reg
.endm; .macro data.foot, va:vararg; punkpc.data.foot \va
.endm; .macro data.struct, idx, struct_pfx, names:vararg
  punkpc.data.struct \idx, \struct_pfx, \names; .endm
  # these hooks can be overwritten manually with .purgem
  # - these macro names might be in use by something else, so you can build them in another way

.endif



# --- punkpc.data - a less intrusive namespace, for hidden layer
punkpc.data.loc = .   # this is a temporary label variable
punkpc.data.idx = 0   # this is the initial index to start with by default for data.struct
punkpc.data.endlabels$   = 0 # keeps track of the number of stacked labels using only sidx

.macro punkpc.data.loc, label; punkpc.data.loc = \label; .endm
.macro punkpc.data.loc.update, loc; punkpc.data.loc.type = 0
    .ifc \loc, .; punkpc.data.loc = .; .exitm; .endif
    # if '.' was given, then use '.' directly to get current location with no blrl trigger

    ifnum \loc; .if num; punkpc.data.loc.type = 1
    # else if loc starts with a number...

      .irpc c,\loc;num=1;.ifc \c,f;num=0;.endif;.ifc \c,b;num=0;.endif;.endr
      .if num; punkpc.data.loc.type = 2 # ... but isn't a temp label...

        .if punkpc.data.endlabels$; punkpc.data.loc \loc\()f
        # use 'forward' table hasn't ended

        .else; punkpc.data.loc.type = 3; punkpc.data.loc \loc\()b; .endif
        # else use 'backward' label if blrl exists

      .else; punkpc.data.loc.type = 4' punkpc.data.loc = \loc; .endif
      # or just use the label that was found

    .else; # ... else, if loc doesn't start with a number...

    ifdef _data.table$\loc; .if def; punkpc.data.loc.type = 5; punkpc.data.loc = _data.table$\loc
    # ... if dictionary entry of that name exists, then use it

    .else; ifdef \loc
      .if def; punkpc.data.loc.type = 6; punkpc.data.loc = \loc
      # ... else, if loc is defined, consider it as a label

      .else;   punkpc.data.loc.type = 7; punkpc.data.loc = _data.table$\loc
      # else assume it's an unbuilt data table

      .endif;
    .endif

  .endif
.endm; .macro punkpc.data.table, name, loc
  .ifb \loc;# if loc argument is blank...

    punkpc.data.loc.update \name
    .if punkpc.data.loc.type == 7; punkpc.data.loc = .; .endif
    # then use dictionary name to reference stored label memory
    # - if no memory is stored, this will resolve to '.'

  .else; punkpc.data.loc.update \loc; .endif
  # else, update using loc argument ...

  .ifb \name; _data.table = punkpc.data.loc
  # if name was blank, then just set the global data table to label to the updated location

  .else; punkpc.data.table.update \name; .endif
  # else pass updated location over to the table update method

.endm; .macro punkpc.data.table.update, name=start
  ifdef _data.table$\name; .if ndef; _data.table$\name = .; .endif # initial value = '.'
  _data.table$\name = punkpc.data.loc  # if loc arg was blank, it resolves to old value
  _data.table = _data.table$\name  # copy assignment over to global label property

.endm; .macro punkpc.data.start, name=start, loc
  .ifb \loc

    .if data.start.inline;
      sidx.get _data.end, punkpc.data.endlabels$ + 1
      _data.end = sidx
      # assign _data.end to a pending, unassigned symbol name
      # - this will make it difficult to evaluate the size before data.end is called

      b _data.end
    .endif; .if data.start.use_blrl; blrl; .endif
    _data.table$start = .
    punkpc.data.table start
    # if blrl flag is true, set it to false and generate a blrl
    # - this only gets checked if a location isn't given

    # update dictionary entry

  .endif;
  # branch over data block if loc isn't given

  punkpc.data.table \name, \loc
  _data.start = _data.table
  # update data table, copy update over to _data.start

.endm; .macro punkpc.data.end, reg;
  punkpc.data.endlabels$ = punkpc.data.endlabels$ + 1; sidx = .
  sidx.set _data.end, punkpc.data.endlabels$;.ifnb \reg; punkpc.data.get \reg; .endif
  # closes data block, and optionally passes register to get method

.endm; .macro punkpc.data.foot, name=foot, loc; data.start.inline = 0
  .if punkpc.data.endlabels$; data.start.use_blrl = 0; .endif; punkpc.data.start \name, \loc
  # variation of .start allows a blrl table to be created at the end of a function
  # - this prevents the need to branch over anything, but can't be used in injection mods

.endm; .macro punkpc.data.get, reg, keyword, base_reg=data.base_reg
  .ifb \keyword; bl _data.start - 4;
    .ifnb \reg
      data.base_reg = \reg
      mflr \reg
    .endif
  .else; punkpc.data.loc.update \keyword; addi \reg, \base_reg, punkpc.data.loc - _data.start;.endif

.endm; .macro punkpc.data.struct, idx=punkpc.data.idx, pfx, names:vararg
  .ifnb \pfx\names
    punkpc.data.idx = \idx - 1; punkpc.data.altm = alt; ifalt; punkpc.data.alt = alt; .altmacro
    .irp name, \names; .ifnb \name; punkpc.data.idx = punkpc.data.idx + 1
      .if punkpc.data.idx == \idx; _data.struct = .; .endif
      punkpc.data.struct.eval %punkpc.data.idx, \pfx\name; .endif
    .endr; ifalt.reset punkpc.data.alt; alt = punkpc.data.altm
  .else; _data.struct = .; \idx = _data.struct - _data.table; .endif
.endm; .macro punkpc.data.struct.eval, i, s; punkpc.data.struct.assign \s, \i\()b - _data.table
.endm; .macro punkpc.data.struct.assign, s, e; \s = \e; .endm

.endif
