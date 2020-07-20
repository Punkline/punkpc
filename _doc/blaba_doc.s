# --- Branch (Link) Absolute translation
# Methods override default PPC 'bla' and 'ba' instructions with a gecko-compatible replacement
#   gecko <- mgekko
# - MCM overrides macro, making gecko-version assemble only outside of MCM
#   - if optional register is provided as first argument -- MCM syntax can be overridden
#   - 'branch' and 'branchl' alias may also be used to override MCM syntax


# --- Example use of the blaba module:

.include "./punkpc/blaba.s"

bla 0x8037a120
# MCM will create a placeholder for this -- Gecko will use macro without issue
# - if MCM makes use of this placeholder in the future, it may offer a useful form of polymorphism

bla r0, 0x8037a120
# MCM will not catch this optional syntax, allowing the macro to be used in MCM

branch r0, 0x8037a120
branchl r0, 0x8037a120
# aliases will also be safe for use in MCM if they use the optional syntax


# --- Module attributes:
# --- Class methods -------------------------------------------------------------------------------

# --- branch  target
# create a long-form bctr; branch to a target absolute address

# --- branch  reg, target
# - an optional variation that lets you specify a register other than r0 to build address in

# --- branchl
# a branch link version of 'branch'
# - these use a blrl instead of a bctr

# Class methods override the following instructions in the -mgekko machine architecture:

# --- ba - branch absolute

