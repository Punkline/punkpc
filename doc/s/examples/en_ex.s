# --- Enumerator (quick)
#>toc library
# - a fast enumeration tool for naming offset and register symbols
# - intended to work similarly to default `enum` objects, but with no class/object features
#   - this makes loading this module a lighter alternative to the `enum` module

# --- Example use of the en module:

.include "punkpc.s"
punkpc en
# Use the 'punkpc' statement to load this module, or include the module file directly

# 'en' can do most of what the generic 'enum' object is capable of
# It will however require that its properties be manually set, with assignments
# - no inline property opdate syntaxes


en A, B, C, D  # enumerate given symbols with a count; starting with 0, and incrementing by +1
en E, F, G, H  # ... next call will continue previous enumerations...
# >>>  A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7

en (31), -4, I, +1, J, K, L
# >>>  I=31, J=27, K=28, L=29
# re-orient enumeration value so that count will start at 31, using ( ) parentheses
# set enumeration to increment/decrement by a specific amount with +/-

en (31), -1, rPlayer,rGObj,rIndex,rCallback,rBools,rCount
# enumerate register names ...

sp.xWorkspace=0x220
en (sp.xWorkspace), +4, VelX,VelY,RotX,RotY,RGBA
# enumerate offset names ...
# etc..

.long A, B, C, D, E, F, G, H, I, J, K, L
.long rPlayer, rGObj, rIndex, rCallback, rBools, rCount
.long VelX, VelY, RotX, RotY, RGBA
# These are all valid index symbols, after 'en' assignments

# --- Example Results:

## 00000000 00000001
## 00000002 00000003
## 00000004 00000005
## 00000006 00000007
## 0000001F 0000001B
## 0000001C 0000001D
## 0000001F 0000001E
## 0000001D 0000001C
## 0000001B 0000001A
## 00000220 00000224
## 00000228 0000022C
## 00000230
