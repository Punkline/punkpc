/*## Header:
# --- subtitle
#>toc library
# - detail

##*/
/*## Updates:
# version 0.0.1
# - added to punkpc module library
##*/
/*## Attributes:

# --- Class Properties ---

# --- Constructor Method ---

  # --- Object Properties ---

  # --- Object Methods ---

# --- Class Methods ---

##*/
/*## Examples:
.include "punkpc.s"
punkpc myModule
# Use the 'punkpc' statement to load this module, or include the module file directly


##*/
/*## Results:
##*/

.ifndef punkpc.library.included; .include "punkpc.s"; .endif
punkpc.module myModule, 1
.if module.included == 0

  # --- Class module

.endif
