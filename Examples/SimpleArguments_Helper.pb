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

XIncludeFile "../Arguments.pbi"
XIncludeFile "../ArgumentsHelper.pbi"


;-> Initialization (Unchanged)

Arguments::Init()


;-> Argument declaration

; NOTE: The ArgumentsHelper::RegisterOption also takes care of clearing the pointers if an error occurs.

If Not (ArgumentsHelper::RegisterOption('h', "help", "Help text !") And
        ArgumentsHelper::RegisterOption('a', #Null$, "All stuff") And
        ArgumentsHelper::RegisterOption(#Null, "test", "test flag") And
        ArgumentsHelper::RegisterOption('d', "data", "Data input", Arguments::#Option_HasValue))
	Debug "Failed to create and register one or more options !"
	End 1
EndIf


;-> Argument parsing (Unchanged)

Define LastParserError = Arguments::ParseArguments()

If LastParserError <> Arguments::#Error_None
	Debug "An error occured while parsing the arguments !"
	Debug LastParserError
	End 3
EndIf


;-> Taking actions

If ArgumentsHelper::WasOptionUsed('h', "help")
	; Only 'h' or "help" can be given to the procedure and it would work perfectly fine.
	Debug "Printing the help text..."
EndIf

If ArgumentsHelper::WasOptionUsed(#Null, "data")
	Debug "Data was given !"
	
	; For-loop technically not required if the option is not declared with Arguments::#Option_HasMultipleValue
	;  since an error will be thrown when multiple values are given to an option with only Arguments::#Option_HasValue.
	
	; FIXME: Create something to make it easier
	Define *OptionByToken.Arguments::Option = Arguments::GetOptionByToken(Arguments::*RootVerb, 'd')
	If *OptionByToken
		ForEach *OptionByToken\Arguments()
			Debug "> " + *OptionByToken\Arguments()
		Next
	EndIf
	
	Define *OptionByName.Arguments::Option = Arguments::GetOptionByName(Arguments::*RootVerb, "data")
	If *OptionByName
		ForEach *OptionByName\Arguments()
			Debug "> " + *OptionByName\Arguments()
		Next
	EndIf
EndIf


;-> Cleaning up

Arguments::Finish()
