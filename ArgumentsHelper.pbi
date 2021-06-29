;{- Code Header
; ==- Basic Info -================================
;         Name: ArgumentsHelper.pbi
;      Version: 0.0.4
;       Author: Herwin Bozet
;
; ==- Compatibility -=============================
;  Compiler version: PureBasic 5.70 (x86/x64)
;  Operating system: Windows 10 21H1 (Previous versions untested)
; 
; ==- Links & License -===========================
;  License: Unlicense
;  GitHub: ???
;}

;- Compiler Directives

EnableExplicit
XIncludeFile "./Arguments.pbi"


;- Module declaration

DeclareModule ArgumentsHelper
	;-> Semver Data
	
	#Version_Major = 0
	#Version_Minor = 0
	#Version_Patch = 4
	#Version_Label$ = ""
	#Version$ = "0.0.4";+"-"+#Version_Label$
	
	
	;-> Procedure Declaration
	
	Declare.s GetSimpleHelpText(*RootVerb.Arguments::Verb)
	
	Declare.b RegisterOption(Token.c, Name.s, Description.s = #Null$, Flags.i = 0, *ParentVerb.Arguments::Verb = #Null)
	
	Declare.b WasOptionUsed(Token.c = #Null, Name.s = #Null$, *ParentVerb.Arguments::Verb = #Null)
EndDeclareModule


;- Module

Module ArgumentsHelper
	;-> Compiler Directives
	
	EnableExplicit
	
	
	;-> Procedure Definition
	
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

	Procedure.b RegisterOption(Token.c, Name.s, Description.s = #Null$, Flags.i = 0, *ParentVerb.Arguments::Verb = #Null)
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
