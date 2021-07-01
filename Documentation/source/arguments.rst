Arguments
*********

Intro text

**Namespace**:: ``Arguments``

.. raw:: html

   <hr>

Enumerations & Constants
========================

OptionFlags
-----------
Binary enumeration representing the different functionalities an options can have.

These flags are contained within the ``Flags`` field of the ``Option`` structure.

#Option_Default
^^^^^^^^^^^^^^^
    Indicates that the option is the default one and that any value given after an option that doesn't take a value or after the ``--`` keyword will be attributed to this option.

    Has to be used with ``#Option_HasValue`` and cannot have more than one in a *Verb* !


#Option_HasValue
^^^^^^^^^^^^^^^^
    Indicates that the option can have a value.

    | If an option with this functionality is encountered during the parsing process, the next launch argument will be considered as its value.
    | Unless it starts with ``-``, in which case, an error will be raised.
    
    Required by ``#Option_Default`` !

#Option_HasMultipleValue
^^^^^^^^^^^^^^^^^^^^^^^^

#Option_Repeatable
^^^^^^^^^^^^^^^^^^
    Indicates that the option can be repeated. (May not be fully implemented)

    | The amount of occurences can be found in the ``Arguments::Option.Occurences`` structure field.
    | If ``#Option_HasMultipleValue`` is used, a value will need to be given for each occurences.

#Option_Hidden
^^^^^^^^^^^^^^
    Indicates that the option should be hidden from any help text.

.. raw:: html

   <br>

ParserErrors
------------
Enumeration representing the different errors than can be returned by the parser.

#Error_None
^^^^^^^^^^^
    Indicates that the procedures succedded.

#Error_NullPointer
^^^^^^^^^^^^^^^^^^
    Indicates that the procedures was given a pointer equal to ``#Null`` and that it couldn't handle it properly.

#Error_Parser_UnknownOption
^^^^^^^^^^^^^^^^^^^^^^^^^^^
    Indicates that an unknown option was given as a launch argument.

#Error_Parser_NoDefaultFound
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    | Indicates that an option with the ``#Option_Default`` flag was needed but couldn't be found.
    | Most likely due to improperly formatted launch arguments.

#Error_Parser_DualEndOfOptions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    Indicates that the ``--`` keyword was encountered more than once.

#Error_Parser_SingleOptionReused
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    Indicates that an option without the ``#Option_Repeatable`` flag was found more than once in the launch arguments.

#Error_Parser_NoArgumentsLeft
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    ???

#Error_Parser_ExpectedArgument
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    ???

#Error_Parser_NoVerbOrDefaultFound
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    ???

#Error_Parser_OptionDoesNotHaveArgs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    ???

#Error_Parser_OptionHasValueAndMoreShorts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    ???

.. raw:: html

   <br>

Others
------

#Error_Parser_NullPointer
^^^^^^^^^^^^^^^^^^^^^^^^^
    Alias of the ``#Error_NullPointer`` enumeration constant.

.. raw:: html

   <hr>

Structures
==========

Option
------
|   **Token**
|      **Type**: Character (c)
|      Represents the option token/short argument.
|   **Name**
|      **Type**: String (s)
|      Represents the option name/long argument.
|   **Description**
|      **Type**: String (s)
|      Represents the option's description as shown in the help text.
|   **Arguments**
|      **Type**: List of Strings (List.s)
|      Contains the option's values.
|      Only used if the flags ``#Option_HasMultipleValue`` or ``#Option_HasValue`` were used.
|   **Flags**
|      **Type**: Integer (i)
|      [Bitfield] representing the option's flags.
|   **WasUsed**
|      **Type**: Byte (b)
|      Represents whether or not the options was used.
|   **Occurences**
|      **Type**: Integer (i)
|      Represents the amount of time the option was used.
|      Requires the ``#Option_Repeatable`` flag.

Verb
----
|   **Verb**
|      **Type**: String (s)
|      Represents the verb's name.
|   **Description**
|      **Type**: String (s)
|      Represents the verb's description as shown in the help text.
|   **\*Options**
|      **Type**: List of Pointer of *Option* (List.\*.Option)
|      List of the registered options' pointers.
|   **\*Verbs**
|      **Type**: List of Pointer of *Verb* (List.\*.Verb)
|      List of the registered sub-verbs' pointers.
|   **WasUsed**
|      **Type**: Byte (b)
|      Represents whether or not the verb was used.
|      May be set to ``#True`` on the root verb. (Not sure)
|   **\*ParentVerb**
|      **Type**: Pointer of *Verb* (\*.Verb)
|      Pointer to the verb that contains this one.
|      Set to ``#Null`` if this is the root verb or if the verb is not registered.

.. raw:: html

   <hr>

Globals
========

\*RootVerb
----------
|   **Type**: Pointer of *Verb* (\*.Verb)
|   Contains the pointer to the root verb.
|   It is usable after successfully calling ``Init()``, and is set to ``#Null`` by default and when calling ``Finish()``.

.. raw:: html

   <hr>

Procedures
==========

Init()
------
|   **Parameters**: None
|   **Returns**: Byte (b)
|      ``#True`` if the initialization worked, ``#False`` otherwise.

|   Initializes the modules and prepares the ``\*RootVerb`` global variable.

Finish()
--------
|   **Parameters**: None
|   **Returns**: Byte (b)
|      ``#True`` if the memory clearing process succeeded, ``#False`` otherwise.

|   Clears [internal memory].
|   ``\*RootVerb`` is set to ``#Null`` and no procedure except for ``Init()`` should be used afterward global variable.
|   The argument parser can be re-initialized afterward.lobal variable.

FreeVerb()
----------
|   **Parameters**: 
|       *Verb*: Pointer of Verb (\*.Verb)
|           Pointer to a verb that needs to be freed.
|   **Returns**: Byte (b)
|      ``#True`` if the memory clearing process succeeded, ``#False`` otherwise.

|   Clears [internal memory].
|   ``\*RootVerb`` is set to ``#Null`` and no procedure except for ``Init()`` should be used afterward global variable.
|   The argument parser can be re-initialized afterward.

FreeOption()
------------
|   **Parameters**: 
|       *Verb*: Pointer of Option (\*.Option)
|           Pointer to an option that needs to be freed.
|   **Returns**: Byte (b)
|      ``#True`` if the memory clearing process succeeded, ``#False`` otherwise.


