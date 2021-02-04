# --- Branch (absolute)
#>toc ppc
# - absolute branch macroinstructions that replace the `bla` and `ba` instructions
#   - these create long-form 4-instruction absolute calls/branches via `blrl` or `bctr`

# --- Example use of the branch module:

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

# --- Example Results:

## bla 0x8037a120
## 3C008037 6000A120
## 7C0803A6 4E800021
## 3C008037 6000A120
## 7C0903A6 4E800420
## 3C008037 6000A120
## 7C0803A6 4E800021
