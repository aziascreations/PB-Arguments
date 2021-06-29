;{- Code Header
; ==- Basic Info -================================
;         Name: SimpleArguments_Manual.pb
;      Version: N/A
;       Author: Herwin Bozet
;
; ==- Description -===============================
;   This example will show you how to manually declare, register, parse and read arguments.
;   The following args are available: [-h|--help] [-a] [--test] [-d|--data <TEXT>]
;
;   Recommend arguments: -h -a -d "Hello World !"
;
;}

;-> Compiler Directives

EnableExplicit

XIncludeFile "../Arguments.pbi"


;-> Initialization

Arguments::Init()


;-> Argument declaration

Define *OptHelp.Arguments::Option = Arguments::CreateOption('h', "help", "Help text !")
Define *OptAll.Arguments::Option  = Arguments::CreateOption('a', #Null$, "All stuff")
Define *OptTest.Arguments::Option = Arguments::CreateOption(#Null, "test", "test flag")
Define *OptData.Arguments::Option = Arguments::CreateOption('d', "data", "Data input", Arguments::#Option_HasValue)

If (Not *OptHelp) Or (Not *OptAll) Or (Not *OptTest) Or (Not *OptData)
	Debug "Failed to create one or more options !"
	End 1
EndIf

If (Not Arguments::RegisterOption(*OptHelp)) Or
   (Not Arguments::RegisterOption(*OptAll)) Or
   (Not Arguments::RegisterOption(*OptTest)) Or
   (Not Arguments::RegisterOption(*OptData))
	Debug "Failed to register one or more options !"
	End 2
EndIf


;-> Argument parsing

Define LastParserError = Arguments::ParseArguments()

If LastParserError <> Arguments::#Error_None
	Debug "An error occured while parsing the arguments !"
	Debug LastParserError
	End 3
EndIf


;-> Taking actions

If *OptHelp\WasUsed
	; Does not care if -h or --help was used
	Debug "Printing the help text..."
EndIf

If *OptData\WasUsed
	Debug "Data was given !"
	
	; For-loop technically not required if the option is not declared with Arguments::#Option_HasMultipleValue
	;  since an error will be thrown when multiple values are given to an option with only Arguments::#Option_HasValue.
	ForEach *OptData\Arguments()
		Debug "> " + *OptData\Arguments()
	Next
EndIf


;-> Cleaning up

Arguments::Finish()
