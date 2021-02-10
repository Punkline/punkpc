# --- Inline Data Tables
#>toc ppc
# - creates macroinstructions that exploit the link register in `bl` and `blrl` to make data tables
#   - resulting instructions are capable of referencing data local to the runtime program counter
# - also includes some utilities for creating binary data structs

# --- Updates:
# version 0.0.3
# - added 'hex' to dependencies, replacing 'align' (which is included in 'hex')
# version 0.0.2
# - added 'align' to dependencies, to help prevent issues with '.align' label expressions
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- _data.start  - label variable that updates to store the location of data.start calls
# --- _data.end    - label variable that updates to store the location of data.end calls
# --- _data.struct - label variable that updates to store the location of data.struct calls
# --- _data.table  - label variable of the currently selected table base; == _data.start on init
# - also serves as a dictionary namespace for keeping named table object labels

# --- data.start.inline   - flag for turning off the branching feature for inline data tables
# --- data.start.use_blrl - flag for turning off the blrl feature of inline data tables
# --- data.base_reg - a register number between 0...31 for referencing a local base address
# - base_reg gets set automatically with data.end and data.get (when using one argument)



# --- Constructor Methods

# --- data.table  name, loc
# Start of a new local data table, which will be the base of any structs made following it
# Sets the current table label to 'name', and creates a dictionary entry if 'name' doesn't exist
# - data table objects are just glorified labels for plugging into the _data.table property
# - label properties are variable, allowing them to be edited by the optional 'loc' argument
#   - loc is automatically set to the label's current memory, and initial memory uses current loc
# Tables can be referenced by 'data.get'

# --- data.start  name, loc
# Begin an in-line data table, using the blrl exploit and a branch to '_data.end'
# The end of the table must be generated with the 'data.end' method
# - if it isn't, then the branch instruction that branches over it will point to itself
#   - if the linker is enabled, it may also just throw an error|
# An optional name can be given to create a new table associated with _data.start
# - if no name is given, a table by the name of 'start' is used
# If a 'loc' argument is given, then the start address will be updated with a new location
# - this updates the current _data.table, _data.start, and dictionary memory labels
# A blrl/branch will not be instantiated when a 'loc' argument is given

# --- data.end    base_reg
# End of local data table(s)
# - if _data.start exists, then this is used as the end of an in-line data block
# - if a register is provided, it is passed to 'data.get' for retrieving the base of _data.start

# --- data.foot   name
# A version of data.start that can be used without the inline branch-over
# - if a blrl has not been generated by the module, it will make one
# - else, it will try to use the previously generated one

# --- data.struct  offset_name
# Create an offset name using the current place in the assembly
# - this offset will be relative to the last created data.table, data.start, or data.foot

# --- data.struct  index, prefix, offset_names
# This version lets you specify many offset names with a common prefix, using idx ... count
# - each index is a temp label made from a number between given idx base and the number of names
#   - ex, 3 names from an idx of '4' would select '4:, 5:, 6:' using '4b, 5b, 6b'
#   - each label is a BACKWARDS reference, so the labels must already be defined
# - if prefix is left blank, none is used
# - prefix must include any desired delimitter chars



  # --- Object Properties
  # All of these create dictionary entries using '_data.table$'

  # --- _data.table$* - the name of this label, as part of the '_data.table$' dictionary
  # - for example, '_data.table$start' is an entry used by the data.start method




# --- Static Methods

# --- data.get    reg, keyword, base_reg
# Returns the address of a local part of your current _data.table label
#  If no base_reg is provided, memory of old base_reg will be used
#  If no keyword is provided, _data.start-4 is branched to, and returned using 'mflr reg'
#   - this gets the start address of the current _data.start label inside of PowerPC
#  Else, if keyword is a decimal number, a forward or backward label is used depending on
#   - this gets the specified temporary label from current _data.table label
#  Else, if a valid temporary, variable, or constant label name is given, it will be used
#   - A variable can only be referenced if it has been defined already, so a backwards reference
#  Else, if undefined -- it's assumed that the keyword is the name of a future table
#   - you can make forward references this way

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module data, 3
.if module.included == 0; punkpc if, sidx, hex

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
