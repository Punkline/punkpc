/*## Header:
# --- Branch (Link) Absolute translation
# Methods override default PPC 'bla' and 'ba' instructions with a gecko-compatible replacement
#   gecko <- mgekko
# - MCM overrides macro, making gecko-version assemble only outside of MCM
#   - if optional register is provided as first argument -- MCM syntax can be overridden
#   - 'branch' and 'branchl' alias may also be used to override MCM syntax

##*/
/*## Attributes:
# --- Class methods ---

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

##*/
/*## Examples:
.include "./punkpc/blaba.s"

bla 0x8037a120
# MCM will create a placeholder for this -- Gecko will use macro without issue
# - if MCM makes use of this placeholder in the future, it may offer a useful form of polymorphism

bla r0, 0x8037a120
# MCM will not catch this optional syntax, allowing the macro to be used in MCM

branch r0, 0x8037a120
branchl r0, 0x8037a120
# aliases will also be safe for use in MCM if they use the optional syntax

##*/

.ifndef bla.included; bla.included=1
  .macro bla, a, b
    .ifb \b;lis r0, \a @h;ori r0, r0, \a @l;mtlr r0;blrl
    .else;  lis \a, \b @h;ori \a, \a, \b @l;mtlr \a;blrl;.endif;.endm;.macro ba, a, b;
    .ifb \b;lis r0, \a @h;ori r0, r0, \a @l;mtctr r0;bctr
    .else;  lis \a, \b @h;ori \a, \a, \b @l;mtctr \a;bctr;.endif;
  .endm;.irp l,l,,;.macro branch\l,va:vararg;b\l\()a \va;.endm;.endr
.endif
/**/
