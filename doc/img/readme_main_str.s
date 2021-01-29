.include "punkpc.s"
punkpc str

str  my_str, "Hell"
str  my_other_str
# These are both str objects
# - they have string memory buffers

my_other_str.conc  "d!"
my_other_str.pfx   "worl"
# concatenation methods can append string memory

A = my_str
B = my_other_str
# str objects use 'self' as a copyable object pointer

str.conc  A, "o "
# str class methods can use pointers to invoke object methods

my_other_str.strq  my_str.conc
my_str.str .error
# >>> Error: Hello world!
# '.str' emits str as a starting arg for a macro or directive
# '.strq' queues str as the last arg in a list of other arg items

str.count.chars my_str
count = str.count
# other class methods are available for convenience

my_str.clear
my_str.conc "Hello"
# buffers may be cleared and re-written


str.emit .error "The phrase \042", [A], [B], /*
*/ "\042 contains", %count, "characters..."
# >>> Error: The phrase " Hello world! " contains 12 characters...


