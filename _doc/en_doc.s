# --- Enumerator (fast)
# Counter assigns count value to list of given symbol identifiers

# This is a minimal version of the 'enum' module that has no object or parsing features
# - only class-level properties and a method are provided
# - this is included as a part of the full 'enum' module, but can be loaded by itself for speed





# --- Example use of the en module:

.include "punkpc.s"
punkpc en
# Use the 'punkpc' statement to load this module, or include the module file directly


# --- Module attributes:

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
# Restart the counter/step using saved 'en.*.restart' properties




