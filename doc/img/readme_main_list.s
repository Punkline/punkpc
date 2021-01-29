.include "punkpc.s"
punkpc list

list ints
# create a list object called 'ints'
# - lists are extended 'stack' objects, and can do everything stacks can

ints = 100
# stack objects use 'self' as a buffer for read/writing the top of the stack

ints.push  # - the value '100' has been pushed to stack memory
ints.push 5, 6, 4, 8, 1, 3, -10  # - values can be pushed as varargs, too
# after pushing, the buffer is reset to its fill value (0 by default)

ints.pop
# 'popping' will cause the topmost value to be assigned to the buffer
# - this decrements the stack index counter, and the range of the total set

ints.s [1]
# '.s' is both a method and a property representing the current stack index
# - '.ss' is a copy of the largest reached '.s' index, so we may revert to it

.rept ints.ss - 1 # - for each value in buffered memory...
  ints.get [ints.s], sort
  ints.get [ints.s-1]
  # 'sort' will be our value to be sorted in range q ... ss-1

  .if ints > sort        # - if not sorted...
    ints.get [ints.q]
    .rept ints.s         # - then for each value in stack range...
      .if ints > sort
        ints = sort
        ints.get, sort   # - insert sort in place of larger values in memory
        ints.set
      .endif; ints.iter
    .endr
  .endif; ints.push sort # - and place largest value at end of line
.endr

stack.rept ints, .byte
# >>> -10, 1, 3, 4, 5, 6, 8, 100
# - sort is emitted using the '.byte' directive through the '.rept' method
