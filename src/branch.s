/*## Header:
# --- Branch (Link) Absolute translation
# Methods override default PPC 'bla' and 'ba' instructions with a gecko-compatible replacement
#   gecko <- mgekko
# - MCM overrides macro, making gecko-version assemble only outside of MCM
#   - if optional register is provided as first argument -- MCM syntax can be overridden
#   - 'branch' and 'branchl' alias may also be used to override MCM syntax

##*/
##/* Updates:
# version 0.0.2
# - renamed to 'branch' module, to avoid confusion
# - added 'branchl.purge' property, for preempting a purge of existing 'branch/branchl'' macros
#   - provides compatability with commonly used macros when including blaba
# version 0.0.1
# - added to punkpc module library


## Binary from examples:

## bla 0x8037a120
## 3C008037 6000A120
## 7C0803A6 4E800021
## 3C008037 6000A120
## 7C0903A6 4E800420
## 3C008037 6000A120
## 7C0803A6 4E800021

##*/
/*## Attributes:
# --- Class Properties

# --- branchl.purge - if this is set to a non-0 value before loading blaba, macros will be purged




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

##*/
/*## Examples:
.include "punkpc.s"
punkpc branch
# Use the 'punkpc' statement to load this module, or include the module file directly

bla 0x8037a120
# >>> bla 0x8037a120
# MCM will create a placeholder for this -- Gecko will use macro without issue
# - if MCM makes use of this placeholder in the future, it may offer a useful form of polymorphism

bla r0, 0x8037a120
# >>>3C008037 6000A120 7C0803A6 4E800021
# Optional register argument prevents the placeholder syntax

branch r0, 0x8037a120
# >>> 3C008037 6000A120 7C0903A6 4E800420

branchl r0, 0x8037a120
# >>> 3C008037 6000A120 7C0803A6 4E800021
# aliases will also be safe for use in MCM if they use the optional syntax



##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module branch, 2
.if module.included == 0
.ifndef branchl.purge; branchl.purge = 0; .endif
.if branchl.purge; branchl.purge = 0; .purgem branch; .purgem; branchl; .endif
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
