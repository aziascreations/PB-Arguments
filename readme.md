# PB-Arguments

A simple launch args parser

## Summary


## Core Module

This module provides the core functions of [aaa].

NameSpace: Arguments

CANNOT HAVE MULTIPLE ROOT VERBS !!!


### Functions

`Init().b`<br>
Initializes some internal variables and allocates memory for the root verb structure.<br>
Returns `#True` if the `malloc()` worked.

`Finish().b`<br>
Frees the memory allocated for the verb structures.<br>
Returns `#True` if the root verb was not yet cleaned and was cleared properly.

### 


## Helpers Module


## License

[Unlicense](LICENSE)
