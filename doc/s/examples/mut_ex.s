# --- Object Method Mutator Hooks
#>toc obj
# - a core module for defining mutable behavior hooks
# - useful for making your class/objects customizable
# - extended by the `obj` module

# --- Example use of the mut module:

.include "punkpc.s"
punkpc mut
# Use the 'punkpc' statement to load this module, or include the module file directly



# --- MUTABLE BEHAVIOR HOOKS ---


mut.class myClass
# This makes it possible to use class-level mutator constructors when building object constructors
# - these constructors help facilitate the implementation of mutator hooks


# Let's make the class constructor use a mutable behavior:

.macro myClass, self
  # this is an example of a constructor macro will make objects of the class 'myClass'
  # - it's just a macro definition containing initializations for the object 'self'

  \self = 0
  # This is an example of a property belonging to this object, 'self'
  # - it is given the initial value of 0

  .macro \self; \self\().hook.myBehavior; .endm
  # This is an example of a method belonging to this object
  #   it has been given its own object name, so we can just treat the object like a method
  # - it's a nested macro definition that calls a 'hook' named 'myBehavior'
  # - the argument of \self is passed to the behavior as an argument
  #   - this lets the behavior reference the object namespace, and access its attributes

  myClass.mut \self
  # 'myClass' was given this method when we called 'mut.class' earlier
  # --- we call this to make \self a 'mutable object', making it easier to mutate 'myBehavior'
  # - this will add  '.hook', '.mut',  and  '.mode'  methods to this object that we can use later

  \self\().hook myBehavior
  # we can use the '.hook' method this creates to initialize the hook for 'myBehavior'
  # - calling this will cause the default behavior 'myClass.mut.myBehavior' to be mapped to it
  # --- we can mutate this at any time after the object is constructed

.endm
# now the constructor definition is finished
#   by calling 'myClass' we can construct new objects of the name given as 'self'
#   - calling them as methods will invoke the 'myBehavior' hook we just set up in the constructor


# Now let's make a default behavior, for our hook:

.macro myClass.mut.myBehavior.default, self;  \self = \self + 1; .endm
# This is an example of a class-level default behavior
# - it simply adds 1 to the property given to this object
# - this is what will be invoked by the hook in our generated objects
# --- The naming convention is as follows:
# --- myClass    - this is the name of the class we gave to 'mut.class'
# --- mut        - this is a default namespace that gets used if we don't specify it in 'mut.class'
# --- myBehavior - this is a keyword used to refer to this hook in the object
# By following this naming mechanism, you can define any number of default 'hook' behaviors
# - this is useful, because it is done at the class level and only needs to be initialized in objs


# Finally, lets test the behavior:

myClass x
myClass y
# Create a pair of objects called 'x' and 'y'
# - a method and property are generated for each of these, by the constructor macro we invoked

.long x, y
# >>> 00000000 00000000
# the property of x and y can be referenced like any other symbol

x; y
# we can call 'x' and 'y' like statements to invoke our programmed behavior

.long x, y
# >>> 00000001 00000001
# the behavior had this effect on the property: self = self + 1



# --- BEHAVIOR MUTATORS ---


# Now, let's change the behavior of 'x'

.macro myMutation, self; \self = 0x1337; .endm
# this mutation will change the behavior of 'myBehavior' if we apply it as a mutator to that hook

x.mut myMutation, myBehavior
# this causes the default behavior we assigned to 'myBehavior' to be replaced with 'myMutation'


# 'x' is now a mutant, with a mutated behavior:

x; y
.long x, y
# >>> 00001337 00000002
# --- x invoked its mutation - but y maintained its old behavior

# With mutators, it's possible to change the behavior of an object AFTER it is constructed
# - this lets you play with polymorphism in your class object designs


x.hook myBehavior
# by invoking the '.hook' mutator method, you can reset 'myBehavior' back to its default behavior

x; y
.long x, y
# >>> 00001338 00000003
# x is now back to its old self


x.mut, myBehavior
# by mutating with a blank name, you can cause the behavior to turn into a NO-OP

x; y
.long x, y
# >>> 00001338 00000004
# Now the x method does nothing at all



# --- MUTATOR MODES ---


# You can make a set of mutators designed as part of a class module with mutator modes
# This is almost just like setting up a default behavior, except that you can add many behaviors

.macro myClass.mut.myBehavior.shift,    self; \self = \self << 1; .endm
.macro myClass.mut.myBehavior.negate,   self; \self = -\self; .endm
.macro myClass.mut.myBehavior.subtract, self; \self = \self - 1; .endm
# these are 3 example mutation modes that we can apply to myBehavior
# - each can be identified using just the last keyword in their object namespace
#   - 'shift', 'negate', and 'subtract'

x.mode myBehavior, shift, negate, subtract
# By using '.mode' at the object level, we can register multiple modes in a single call
# - now, each of these modes have been mapped to 'myBehavior' and can be referenced by keywords

.irp kw, shift, negate, subtract; .long myClass.mut.myBehavior.\kw; .endr
# >>> 1, 2, 3
# These are the mode IDs assigned to the keywords you have registered

.long x.hook.myBehavior.mode
# >>> 3
# This is the currently selected mode. It corresponds with 'subtract' -- the last applied keyword

x; y
.long x, y
# >>> 00001337 00000005
# - subtraction mode subtracted from x

x.mode myBehavior, shift
x; y
.long x, y
# >>> 0000266E 00000006

x.mode myBehavior, negate
x; y
.long x, y
# >>> FFFFD992 00000007




# --- EMPTY HOOK CALLS ---

# You may implement hooks at the class-level inside of object methods
# - this helps reduce the number of hook instances necessary in objects configured to be 'default'

mut.class otherClass
.macro otherClass, self

  \self = 0
  .macro \self; otherClass.call_hook \self, myBehavior; .endm
  otherClass.mut \self
  otherClass.purge_hook \self, myBehavior
  # We have initialized the 'myBehavior' hook, but we have not instantiated its method
  # - this causes it to be flagged in a way that '.call_hook' will recognize
  # - the default mode will be used to catch this case, even though a hook method doesn't exist

.endm

.macro otherClass.mut.myBehavior.default, self;  \self = \self - 1; .endm
# This is the default mode that otherClass objects will default to when no hook is available

otherClass z
# 'i' is an instance of 'otherClass' that we can use like 'x' and 'y'

z = 10
z; z; z
.long z
# >>> 00000007
# The default hook behavior is used despite there being no hook method!




# --- ALTERNATIVE NAMESPACES ---

mut.class int, cb
# --- the second argument 'cb' - creates the namespace 'int.cb' instead of 'int.mut'

.macro int, self;
  int.mut \self, op
  # --- the second arg 'op' - creates the namespace 'self.op' instead of 'self.hook'
  # - now, any objects constructed at the \self (object) level will use this namespace

  \self = 0
  \self\().hook incr, decr
  .macro \self, va:vararg
    .ifnb \va
      .ifc \va, ++; \self\().op.incr; .exitm; .endif
      .ifc \va, --; \self\().op.decr; .exitm; .endif
      \self = \self \va
    .endif # if ++ or --, then trigger 'op' hooks;  else, just apply args to end of assignment
  .endm
.endm
# This constructs 'int' objects, which are easy to increment or decrement with a shorthand syntax

.macro int.cb.incr.default, self; \self = \self + 1; .endm
.macro int.cb.incr.word, self; \self = \self + 4; .endm
.macro int.cb.incr.double, self; \self = \self << 1; .endm
.macro int.cb.decr.default, self; \self = \self - 1; .endm
.macro int.cb.decr.word, self; \self = \self - 4; .endm
.macro int.cb.decr.double, self; \self = \self >> 1; .endm
# Some default behaviors, with alternative modes 'word' and 'double'

int i
i = 0x100
.long i
# >>> 00000100
# A normal symbol assignment

i++
.long i
# >>> 00000101
# ... but it's an object that we can invoke like a statement, too!
# - the '++' invokes the special 'incr' behavior we set up, which adds 1 to the value

i--
.long i
# >>> 00000100

i.mode incr, double
i++
.long i
# >>> 00000200
# Now 'i' will increment by doubling

i.mode decr, word
.rept 32; i--; .endr
.long i
# >>> 00000180

# --- Example Results:

## 00000000 00000000
## 00000001 00000001
## 00001337 00000002
## 00001338 00000003
## 00001338 00000004
## 00000001 00000002
## 00000003 00000003
## 00001337 00000005
## 0000266E 00000006
## FFFFD992 00000007
## 00000007 00000100
## 00000101 00000100
## 00000200 00000180
