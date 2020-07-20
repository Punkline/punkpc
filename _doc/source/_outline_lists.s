/*## Header:
# --- Lists
# Create lists that you can easily iterate through, or select an index of
# List objects use 'self' like a normal symbol that can be treated like a scalar variable
# - this scalar variable interacts with the list using object methods that can be called
# - 'lists' are an extension of 'stacks'
##*/
/*## Attributes:
# --- Class Properties ---

# --- list.fill - default fill value
# --- list.size - default size of new lists
# --- list.temp - temporary value used when swapping indexed memory values
# --- list$     - list object ID counter


# --- Constructor Method ---

# --- list   name, ...
# List objects are extended Stack objects with more sophisticated indexing and piping methods
# - if multiple names are given, then multiple lists are created
# - you may modify list.fill or list.size to change the initial state of each list
#   - these arguments will return back to their defaults for the next call to the constructor
#   - multiple lists made with a single call will share the same properties
# - lists are also stacks

# --- Object Properties:

  # --- (stack properties)  - All stack properties are inherited
  # --- .isList    - unique non-0 list ID
  # --- .i         - list index -- the current index
  # --- .bias      - bias index -- the bias applied to the current index (like a base index)
  # --- .step      - the size and direction of the next iteration in a pipe operation
  # --- .stride    - a unit size for using a stride argument in .step, .rotstep, and .bias methods
  # --- .prev      - outpipe memory of previous value in step operation

# --- Object Methods:

  # --- .i      idx, stride, q, s
  # Set index .i to target  q + (idx + self.bias) + (stride * self.stride)
  # - if idx is blank, (idx + self.bias) is replaced with (self.i + self.step)
  # - if stride is blank, 0 is assumed
  # - if target is out of bounds of range q ... s, property is resolved with a callback
  #   - callback mode can be set with the 'self.i.q.mode' amd 'self.i.s.mode' methods
  # - if target is a negative index, property is resolved with a callback
  #   - callback mode can be set with the 'self.i.neg.mode' method
  # - if q, s are blank, then self stack boundaries are used
  #   - 'self.q' and 'self.s' stack methods can set boundaries within bounds of written mem
  #     - 'self.new' stack method can be used to write new memory bounds by pushing blank elements
  # - using a range that's out of bounds of stack range is possible, if used with caution
  #   - OOB indices are safe to write to, but not safe to read from unless previously written to

  # --- .i.q.mode     mode
  # --- .i.s.mode     mode
  # These modes change the way the indexer behaves when an index is out of its given bounds
  #    q : mode behavior for handling out of queue bounds
  #    s : mode behavior for handling out of stack bounds
  #        mode : cap : DEFAULT - set index to limit of crossed boundary
  #        mode : nop : aborts index change, leaving it at self
  #        mode : rot : rotate index by using a modulo operation

  # --- .i.neg.mode   mode
  # This mode changes the way the indexer behaves when given a negative index
  #        mode : wrap : DEFAULT - add neg to stack index, and perform modulo operation
  #        mode : useq : handle negatives as though it were a queue boundary exception

  # --- .get     idx, sym, ...
  # --- .set     idx, val
  # Set a new target .i, and use index to get/set a value from/to list memory
  # The more restrictive altmacro versions (below) may be faster if used in a loop, or a sequence
  # - getting from an undefined memory value will trigger a callback behavior
  #   - callback mode can be set with 'self.get.mode'
  # - idx is given a bias using 'self.bias' and q arguments passed to the 'self.i' method
  # - if idx is blank, 'self.i' is used without changing current index
  # - if sym/value is blank, self is used
  # --- .geta  idx, sym
  # --- .seta  idx, val
  # Altmacro get/set uses an unbiased, uncorrected idx arg, for faster gets and sets (in loops)
  # - getting from an out of bounds index is unsafe if gotten memory has not been written to first

  # --- .copy   idx, list, r
  # --- .paste  idx, list, w
  # --- .swap   idx, list, i
  # Without modifying .i index, perform assignment operations between this and a target list:
  # Copy  :  self[idx]  -> list[r]  Read an indexed value from another list into this list
  # Paste :  self[idx] <-  list[w]  Write an indexed value from this list to another list
  # Swap  :  self[idx] <-> list[i]  Swap an indexed value from this list to another list
  # - if idx is blank, 'self.i' is used
  # - if list is blank, static list 'list.temp' is used
  # - if r, w, or i is blank, 'list.i' is used

  # --- .copya   idx, list, r
  # --- .pastea  idx, list, w
  # --- .swapa   idx, list, i
  # Altmacro versions use unbiased, uncorrected idx arg, for faster operations (in loops)
  # - these are invoked by the following -run methods to handle ranges:
  # --- .copyrun   list, rq, rs
  # --- .pasterun  list, wq, ws
  # --- .swaprun   list, iq, is


  # --- .bias  idx, stride, q
  # Adjust the bias of the list indexer using an absolute (unbiased) input
  # By default, the bias is always 0
  # - if idx is blank, 0 is assumed
  # - if stride is blank, 0 is assumed;  else, given value is multiplied by the 'self.stride' unit
  # - this bias does not get corrected for out of bounds until used by the .i indexer method

  # --- .stride  base, add, ...
  # Adjust the unit size of the stride used by the list indexer
  # By default, the stride is always 1
  # - when designing an array of structs, stride may be used to describe a struct size
  # - if base is blank, the current 'self.stride' is used
  # - for each add argument, 'self.stride' = 'self.stride' + add
  #   - when designing an array of structs, add args may be used to define sections in a struct

  # --- .step  step, stride, q, s
  # Update memory of current index with self, and update the step property 'self.step' = step
  # Step to relative location with indexer 'self.i , stride, q, s'
  # Update self with memory at newly selected index
  # - if step is blank, 'self.step' is used
  # - if stride is blank, 0 is assumed
  # - if q, s are blank, 'self.q' and 'self.s' are used

# --- Static Methods ---

# --- list.rota i, q, s
# Altmacro signed index rotation modulo operation, with a floor value
# - range q ... s is inclusive
# - q must be <= s
# - return property 'list.rot' will be between range q ... s

##*/
/*## Examples:

.include "punkpc/lists.s"

##*/

.ifndef list.included; list.included=0; .endif; .ifeq list.included; list.included = 1

# Static Properties:
list.fill = 0 # default fill value
list.size = 0 # default size of new lists
list.temp = 0 # temporary value used when swapping indexed memory values
list$ = 0
.include "./punkpc/stacks.s"
