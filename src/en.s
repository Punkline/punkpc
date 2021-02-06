# --- Enumerator (quick)
#>toc library
# - a fast, featureless enumeration tool for naming offset and register symbols
# - intended to be as small and quick as possible

# --- Updates:
# version 0.0.1
# - added to punkpc module library

# --- Class Properties ---

# These must be updated manually with assignments:
# --- en.count - the enumerator count index (0 by default)
# --- en.step  - the iteration step (1 by default)
# --- en.count.restart
# --- en.step.restart  - these can be modified to change the 'restart' defaults


# --- Class Methods ---
# --- en ...
# Enumerate args in '...' with 'en.count' index, using 'en.step' increments

# --- en.restart
# Restart the counter/step using saved 'en.*.restart' properties.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module en, 1
.if module.included == 0

  .macro en, va:vararg;
    .irp sym,\va; .ifnb \sym;\sym=en.count;en.count=en.count+en.step;.endif; .endr; .endm
  .macro en.restart;en.count = en.count.restart; en.step = en.step.restart; .endm
  en.count.restart = 0; en.step.restart = 1; en.restart

.endif
