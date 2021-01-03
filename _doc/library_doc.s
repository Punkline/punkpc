# --- Module Library Objects
# Provides a more efficient way of handling prerequisites than solely using the .include statement
# Creates an object representing a library of importable modules
# - creates a protocol for checking for the existence of modules using version numbers
#   - the file doesn't need to be loaded just to check for the existence of the modules this way
#   - this potentially prevents a lot of unnecessary parsing over ignored if-blocks
# - creates a path string variable dedicated to a library
#   - the library objects double as class methods that can load modules
#     - each comma-separated module name given to a library object will be loaded if not defined


# --- Updates:

# version 0.0.1
# - added to punkpc module library


# --- Example use of the library module:

.include "punkpc.s"
# You can load this file automatically with the 'punkpc' library file, which has no extension
# Alternatively, you can use 'punkpc.s', which 'punkpc' invokes
# ... or you can load the file directly, from 'punkpc/module.s' by default



# --- DEFINING A MODULE LIBRARY ---
# Modules use a directory to store all of their module files in
# A Library object can be created to keep track of one of these directories, like with punkpc
# A Library object can be defined within a dedicated file, and then loaded with .include

.ifndef myLib.library.included
  module.library myLib
  # This creates a library object called 'myLib', but only if it doesn't already exist
  # - the '.ifndef' block protects the library name from being defined multiple times
  #   - this could happen in the very likely case of this file being loaded multiple times

.endif

myLib.subdir ".include/_myLib/", ".s"
# This will redirect the path used by myLib to use the relative path /.include/myLib/*
# The second argument is a file extension that will be used with all of our module name inputs
# - if the extension is blank, then you will need to specify the file extension with each input
# - using '.s' allows us to import /.include/myLib/*.s files


# --- These lines could go in a file called 'myLib' or 'myLib.s'
# Note that if you have a library file that is the same name as the dir, you need a file extension




# --- DEFINING A CLASS MODULE ---
# Modules for 'myLib' can now be defined in the specified subdirectory  '.include/_myLib/*.s'
# A Module is kept track of with a non-0 version value, given to a predictably named symbol property
# - this symbol property can be checked for in order to test if the module is currently loaded

.ifndef myLib.library.included; .include "myLib"; .endif
# This will invoke the 'myLib' file we created the library object inside of
# Wrapping .ifndef around this is optional, but possibly more efficient
# - now we have access to the 'myLib' object inside our module file

myLib.module myModule, 0x1337
# This creates a new module called 'myModule' in the 'myLib' library
# '0x1337' will generate a version number for this module if one doesn't already exist
# - any non-0 number can be used as a version number, defaulting to '1' if an argument isn't given

.if module.included == 0

  # <--- define class(es) here

.endif

# The class property 'module.included' can be checked after a library object invokes '.module'
# If it is True, then the module has already been included and doesn't need to be defined
# - this is important for protecting the class definitions, to prevent errors


# --- These lines could go in a file called 'myModule.s' in the '.include/_myLib/' subdir
# This defines our class module file, for the library object to reach




# --- USING A CLASS MODULE ---
# Modules set up like 'myModule' can be included easily in other files or injection codes

.include "myLib"
# This will invoke the 'myLib' file we created the library object inside of
# - now we have access to the 'myLib' object

myLib myModule
# Passing the name 'myModule' to 'myLib' will ensure that that module is loaded in this environmnet
# It uses the subdirectory and file extension defined by the library object, from our '.subdir' call
# - this effectively loads ".include/_myLib/myModule.s" -- and only if the module isn't installed


# By filling out the class definition with methods and properties, you can create useful objects
# 'punkpc' has several examples of importable modules like this:

punkpc list, str, ifdef, ifnum, bcount
# 'myLib' uses 'punkpc' to access 'module.s', so we also have access to the 'punkpc' library obj
# You can provide multiple arguments like this to load many class modules at once from a library

str hello, "hello world"
list l
l.push 1, 2, 3, 4, hello
# - examples of statements from modules imported from the 'punkpc' library




# --- RAW BINARY FILES ---
# While not useful for creating more classes, binary files can also be imported with libraries
# These can contain pre-assembled machine-code or data that you want to include with your assembly

myLib.raw myImage.bmp, mySound.wav, myCode.bin
# The file extension from the '.subdir' call made in 'myLib' does not affect the args in '.raw'
# This means that you must specify the extension of each loaded file
# - loaded files will emit binary at the current assembly position, at time of calling '.raw'

myLib.raw "GALE01/ItCo.usd, 0xF4A40, 0x1000", "GALE01/ItCo.usd, 0xF5A40, 0x200"
# By using 3 comma-separated args inside of a quoted string, you can emit only partial files
# - this is useful for reaching data inside of archive files


# --- Module attributes:

# --- Class Properties
# --- module.included - a return variable that can be checked for creating if-block definitions
# - for use when defining new modules
# - used internally by library objects

# --- punkpc.library.version - the version property of the 'library.s' module
# - this comes from the 'punkpc' library, and stores the version of this class module
#   - other similarly named properties will be created for instantiated libraries and class modules




# --- Constructor Method
# --- module.library  name, ext
# This creates a library object of the given name, like the 'punkpc' object
# - it can be used to store a path to your module files, and called in order to feed it module names
# - any given module name will then be .included if the module version doesn't exist, or is null
# - if 'ext' is blank, the default extension will be '.s'

# Library names must be checked literally before passing them to the module.library call
# - use a .ifdef block and a literal name to do this easily
# - you may use altmacro mode to avoid '\' chars, if escaping the library name



  # --- Object Properties
  # --- .library.included - this can be used to check for the existence of this library object



  # --- Object Methods
  # --- (self)  module, ...
  # Load each module name given from the currently specified subdirectory, and file extension
  # - files are loaded as source literals for this assembler envronemnt

  # --- .raw    file.ext, ...
  # Load each file name given from the currently specified subdirectory
  # Given file names must include the extension of the file, unlike module importer method
  # - files loaded this way are emitted as raw binary, instead of source literals
  #   - data is emitted at the point this is called from
  # - useful for including pre-compiled assembly or data in this assembly

  # --- .raw    "file.ext, offset, size", ...
  # This alternative argument format for '.raw' can also be used to load a partial file
  # - tuple of 3 args must be comma-separated and inside of a pair of "double quotes"

  # --- .module  module, version
  # This can be used to start the definition of a class module
  # If the module doesn't exist yet, then the given version number will be used to create it
  # If no version number is given, 1 is assumed (versions must be non-0)
  # The property 'module.included' will return False (0) if the module isn't included
  # - you may use 'module.included' to create a .if block that protects your class definition

  # --- .subdir  path
  # This can be used to change the current subdirectory used to reach module or raw files
  # - path must end with a '/'
  # - doubled '\\' backslashes can be used in place of '/' forward slashes
  # Path is relative to the paths provided to as.exe with the -i command
  # - if no paths were provided, the working directory is used



# --- Class Methods
# --- module.included  prefix, mid, suffix
# This checks for the existence of a given version property, constructed from the 3 given args
# If suffix is blank, '.version' will be assumed
# Not really meant for user-level access, but can be useful
# - module uses this internally to standardize '\library.\module.version' as the property name
# - the property 'module.included' will be returned with true or false
#   - if the symbol name is defined but null, then it will be considered as not included




