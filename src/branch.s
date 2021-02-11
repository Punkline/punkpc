# --- Branch (absolute)
#>toc ppc
# - absolute branch macroinstructions that replace the `bla` and `ba` instructions
#   - these create long-form 4-instruction absolute calls/branches via `blrl` or `bctr`

# --- Updates:
# version 0.0.3
# - renamed '.purge' property to '.purgem' in order to match name of GAS directive of the same name
# - '.purgem' values are marked true once macros are defined (and purgable)
# version 0.0.2
# - renamed to 'branch' module, to avoid confusion
# - added 'branchl.purge' property, for preempting a purge of existing 'branch/branchl'' macros
#   - provides compatability with commonly used macros when including blaba
# version 0.0.1
# - added to punkpc module library

# --- Class Properties

# --- branchl.purgem - if this is set to a non-0 value before loading blaba, macros will be purged




# --- Class methods

# --- branch  target
# create a long-form bctr; branch to a target absolute address

# --- branch  reg, target
# - an optional variation that lets you specify a register other than r0 to build address in

# --- branchl
# a branch link version of 'branch'
# - these use a blrl instead of a bctr


# Class methods override the following instructions in the -mgekko machine architecture:
# --- bla - branch link absolute
# --- ba - branch absolute

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module branch, 3
.if module.included == 0
.ifndef branchl.purgem; branchl.purgem = 0; .endif
.if branchl.purgem; branchl.purgem = 0; .purgem branch; .purgem branchl; .endif
.irp x, branchl, branch, bla, ba; .irp y, .purgem; \x\y = 1; .endr; .endr
# provides compatibility with other macros that do not use this class module system

  .macro bla, a, b
    .ifb \b;lis r0, \a @h;ori r0, r0, \a @l;mtlr r0;blrl
    .else;  lis \a, \b @h;ori \a, \a, \b @l;mtlr \a;blrl;.endif;.endm;.macro ba, a, b;
    .ifb \b;lis r0, \a @h;ori r0, r0, \a @l;mtctr r0;bctr
    .else;  lis \a, \b @h;ori \a, \a, \b @l;mtctr \a;bctr;.endif;
  .endm;.irp l,l,,;
  .macro branch\l,va:vararg;b\l\()a \va;.endm;.endr
.endif
/**/
