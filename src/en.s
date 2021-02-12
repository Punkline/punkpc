# --- Enumerator (quick)
#>toc library
# - a fast enumeration tool for naming offset and register symbols
# - intended to work similarly to default `enum` objects, but with no class/object features
#   - this makes loading this module a lighter alternative to the `enum` module

# --- Updates:
# --- version 0.1.0
# - decided to build default 'enum' features into 'en', for compatability
#   - still does not have any object features, and loads very quickly
# version 0.0.1
# - added to punkpc module library

# --- Class Properties ---

# These can be updated manually with assignments, or syntactically with expression args:
# --- en.count - the enumerator count index (0 by default)
# - use a pair of (parentheses) in an argument to set the count to a new index value syntactically
# --- en.step  - the iteration step (1 by default)
# - use a leading '+' or '-' char in an argument to set the step to a new index value syntactically
# --- en.count.restart
# --- en.step.restart  - these can be modified to change the 'restart' defaults


# --- Class Methods ---
# --- en ...
# Enumerate args in '...' with 'en.count' index, using 'en.step' increments
# - args in (parentheses) will set the '.count' property to a new value
# - args that start with + or - will set the '.step' property to a new value
# - other args will be treated like symbols that are ready to receive value assignments, from count

# --- en.restart
# Restart the counter/step using saved 'en.*.restart' properties

# --- en.save  dict
# Save the current '.count' and '.step' values to a namespace provided by 'dict'

# --- en.load  dict
# Replace the current '.count' and '.step' values to a namespace used by '.save'
# - property names will also match valid 'enum' object properties, for copying

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module en, 0x100
.if module.included == 0

  .macro en, va:vararg;
    .irp sym,\va;
      .ifnb \sym;
        .irpc c, \sym;
          .ifc \c, (; en.count=\sym; .exitm; .endif  # case of (parentheses)
          .ifc \c, +; en.step=\sym; .exitm; .endif    # case of +
          .ifc \c, -; en.step=\sym; .exitm; .endif    # case of -
          \sym=en.count;en.count=en.count+en.step;.exitm  # else
        .endr # all '.exitm' directives exit the char parse
      .endif # exiting the char parse doesn't skip time taken to allocate resources for loop iters
    .endr # long symbols or expressions may be slower than shorter ones

  .endm; .macro en.restart;en.count = en.count.restart; en.step = en.step.restart;
  .endm; .macro en.save, dict; \dict\().count = en.count; \dict\().step = en.step
  .endm; .macro en.load, dict; en.count = \dict\().count; en.step = \dict\().step
  # save and load can be used to create wrapper prologs/epilogs
  # - this helps to get around lack of object features

  .endm; en.count.restart = 0; en.step.restart = 1; en.restart
  # initialize global 'en' macroinstruction

.endif
