;{
; * ArgumentsHelper.pbi
; Version: 0.0.1
; Author: Herwin Bozet
; 
; A basic arguments parser.
;
; License: Unlicense (Public Domain)
;}

;- Compiler Directives

EnableExplicit
XIncludeFile "./Arguments.pbi"


;- Module declaration

DeclareModule ArgumentsHelper
	Declare.s GetSimpleHelpText(*RootVerb.Arguments::Verb)
	
	Declare.b RegisterOption(Token.c, Name.s, Description.s = #Null$, Flags.i = 0,
	                         *ParentVerb.Arguments::Verb = #Null)
	; SimpleRegisterVerb/Option
	
	Declare.b WasOptionUsed(Token.c = #Null, Name.s = #Null$, *ParentVerb.Arguments::Verb = #Null)
EndDeclareModule


;- Module

Module ArgumentsHelper
	EnableExplicit
	
	Procedure.s GetSimpleHelpText(*RootVerb.Arguments::Verb)
		Protected HelpText$ = #Null$
		Protected LongestOption.i = 0
		
		If *RootVerb
			ForEach *RootVerb\Options()
				If *RootVerb\Options()\Name <> #Null$
					If Len(*RootVerb\Options()\Name) > LongestOption
						LongestOption = Len(*RootVerb\Options()\Name)
					EndIf
				EndIf
			Next
			
			HelpText$ = "> "+"tmp.exe"+#CRLF$
			
			ForEach *RootVerb\Options()
				HelpText$+Space(4)
				
				If *RootVerb\Options()\Token <> #Null
					HelpText$+"-"+Chr(*RootVerb\Options()\Token)
				Else
					HelpText$+"  "
				EndIf
				
				If *RootVerb\Options()\Name <> #Null$
					HelpText$+", --"+*RootVerb\Options()\Name
				Else
					HelpText$+Space(2+2+LongestOption)
				EndIf
				
				If LongestOption <> 0
					HelpText$+Space(4)
				Else
					HelpText$+Space(2)
				EndIf
				
				HelpText$+Space(4)+*RootVerb\Options()\Description+#CRLF$
			Next
		EndIf
		
		ProcedureReturn HelpText$
	EndProcedure

	Procedure.b RegisterOption(Token.c, Name.s, Description.s = #Null$, Flags.i = 0,
	                           *ParentVerb.Arguments::Verb = #Null)
		Protected Option = Arguments::CreateOption(Token, Name, Description, Flags)
		
		If Option
			If Arguments::RegisterOption(Option, *ParentVerb)
				ProcedureReturn #True
			Else
				Arguments::FreeOption(Option)
			EndIf
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b WasOptionUsed(Token.c = #Null, Name.s = #Null$, *ParentVerb.Arguments::Verb = #Null)
		If *ParentVerb = #Null
			*ParentVerb = Arguments::GetRootVerb()
		EndIf
		
		If *ParentVerb
			ForEach *ParentVerb\Options()
				If *ParentVerb\Options()\Token <> #Null And Token <> #Null
					Debug *ParentVerb\Options()\Token
					If *ParentVerb\Options()\Token = Token
						ProcedureReturn *ParentVerb\Options()\WasUsed
					EndIf
				EndIf
				
				If *ParentVerb\Options()\Name <> #Null$ And Name <> #Null$
					Debug *ParentVerb\Options()\Name
					If *ParentVerb\Options()\Name = Name
						ProcedureReturn *ParentVerb\Options()\WasUsed
					EndIf
				EndIf
			Next
		EndIf
		
		ProcedureReturn #False
	EndProcedure
EndModule
