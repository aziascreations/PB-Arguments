;{- Code Header
; ==- Basic Info -================================
;         Name: SimpleArguments_Helper.pb
;      Version: N/A
;       Author: Herwin Bozet
;
; ==- Description -===============================
;   This example will show you how to declare, register, parse and read arguments with the helper.
;   The following args are available: [-h|--help] [-a] [--test] [-d|--data <TEXT>]
;
;   Recommend arguments: -h -a -d "Hello World !"
;
;}

;-> Compiler Directives

EnableExplicit

XIncludeFile "../ArgumentsHelper.pbi"


;-> Initialization

ArgumentsHelper::Init()


;-> Argument declaration

; NOTE: The ArgumentsHelper::RegisterOption also takes care of clearing the pointers if an error occurs.

If Not (ArgumentsHelper::RegisterOption('h', "help", "Help text !") And
        ArgumentsHelper::RegisterOption('a', #Null$, "All stuff") And
        ArgumentsHelper::RegisterOption(#Null, "test", "test flag") And
        ArgumentsHelper::RegisterOption('d', "data", "Data input", Arguments::#Option_HasValue))
	Debug "Failed to create and register one or more options !"
	End 1
EndIf


;-> Argument parsing

If ArgumentsHelper::ParseAllArguments() <> Arguments::#Error_None
	Debug "An error occured while parsing the arguments !"
	End 3
EndIf


;-> Taking actions

If ArgumentsHelper::SearchOptionsIfUsed('h', "help")
	; Only 'h' or "help" can be given to the procedure and it would work perfectly fine.
	Debug "Printing the help text..."
EndIf

If ArgumentsHelper::SearchOptionsIfUsed(#Null, "data")
	Debug "Data was given !"
	
	; This exemple is especially short since there is a single value.
	; However, it could be shorter if we kept a copy of the value returned by ArgumentsHelper::RegisterOption().
	Debug "> "+ArgumentsHelper::GetOptionValueByIndex(ArgumentsHelper::GetOptionByToken('d'))
	Debug "> "+ArgumentsHelper::GetOptionValueByIndex(ArgumentsHelper::GetOptionByName("data"))
EndIf


;-> Cleaning up

ArgumentsHelper::Finish()
