;{- Code Header
; ==- Basic Info -================================
;         Name: ArgumentsHelper.pbi
;      Version: 0.0.5
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

;- Notes

; The main goal of this include is to add a layer of abstraction between the "Arguments" module and the application.
;  by providing wrappers and more complex procedures that handle the complex, boring and repetitive tasks.


;- Compiler Directives

EnableExplicit
XIncludeFile "./Arguments.pbi"


;- Module declaration

DeclareModule ArgumentsHelper
	;-> Semver Data
	
	#Version_Major = 0
	#Version_Minor = 0
	#Version_Patch = 5
	#Version_Label$ = ""
	#Version$ = "0.0.5"
	
	
	;-> Procedure Declaration
	
	Declare.i RegisterVerb(Verb.s, Description.s = #Null$, *ParentVerb.Arguments::Verb = #Null)
	Declare.i RegisterOption(Token.c, Name.s, Description.s = #Null$, Flags.i = 0, *ParentVerb.Arguments::Verb = #Null)
	
	Declare.b IsVerbUsed(*Verb.Arguments::Verb = #Null)
	Declare.b IsOptionUsed(*Option.Arguments::Option)
	Declare.b SearchOptionsIfUsed(Token.c = #Null, Name.s = #Null$, *ParentVerb.Arguments::Verb = #Null)
	
	; Small wrappers for the optional verb argument.
	; This check is kept outside of the main procedure for performance reasons.
	Declare.i GetDefaultOption(*Verb.Arguments::Verb = #Null)
	Declare.i GetOptionByToken(DesiredToken.c, *Verb.Arguments::Verb = #Null)
	Declare.i GetOptionByName(OptionName.s, *Verb.Arguments::Verb = #Null)
	Declare.i GetVerbByName(VerbName.s, *ContainerVerb.Arguments::Verb = #Null)
	
	Declare.s GetOptionValueByIndex(*Option.Arguments::Option, ValueIndex.i = 0)
	Declare.i GetOptionValues(*Option.Arguments::Option, List Values())
	Declare.i GetOptionValueCount(*Option.Arguments::Option)
	
	
	;-> Macros
	
	Macro Init() : Arguments::Init() : EndMacro
	Macro Finish() : Arguments::Finish() : EndMacro
	Macro GetParentVerb(ParentVerb) : Arguments::GetParentVerb(ParentVerb) : EndMacro
	Macro ParseAllArguments() : Arguments::ParseArguments() : EndMacro
EndDeclareModule


;- Module

Module ArgumentsHelper
	;-> Compiler Directives
	
	EnableExplicit
	
	
	;-> Procedure Definition
	
	Procedure.i RegisterVerb(Verb.s, Description.s = #Null$, *ParentVerb.Arguments::Verb = #Null)
		Protected NewVerb = Arguments::CreateVerb(Verb, Description)
		
		If NewVerb
			If Arguments::RegisterVerb(NewVerb, *ParentVerb)
				ProcedureReturn NewVerb
			Else
				Arguments::FreeVerb(NewVerb)
			EndIf
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure.i RegisterOption(Token.c, Name.s, Description.s = #Null$, Flags.i = 0, *ParentVerb.Arguments::Verb = #Null)
		Protected Option = Arguments::CreateOption(Token, Name, Description, Flags)
		
		If Option
			If Arguments::RegisterOption(Option, *ParentVerb)
				ProcedureReturn Option
			Else
				Arguments::FreeOption(Option)
			EndIf
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure.b IsVerbUsed(*Verb.Arguments::Verb = #Null)
		If Not *Verb
			*Verb = Arguments::*RootVerb
		EndIf
		
		ProcedureReturn *Verb\WasUsed
	EndProcedure
	
	Procedure.b IsOptionUsed(*Option.Arguments::Option)
		If *Option
			ProcedureReturn *Option\WasUsed
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b SearchOptionsIfUsed(Token.c = #Null, Name.s = #Null$, *ParentVerb.Arguments::Verb = #Null)
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
	
	Procedure.i GetDefaultOption(*Verb.Arguments::Verb = #Null)
		If Not *Verb
			*Verb = Arguments::*RootVerb
		EndIf
		
		ProcedureReturn Arguments::GetDefaultOption(*Verb)
	EndProcedure
	
	Procedure.i GetOptionByToken(DesiredToken.c, *Verb.Arguments::Verb = #Null)
		If Not *Verb
			*Verb = Arguments::*RootVerb
		EndIf
		
		ProcedureReturn Arguments::GetOptionByToken(*Verb, DesiredToken)
	EndProcedure
	
	Procedure.i GetOptionByName(OptionName.s, *Verb.Arguments::Verb = #Null)
		If Not *Verb
			*Verb = Arguments::*RootVerb
		EndIf
		
		ProcedureReturn Arguments::GetOptionByName(*Verb, OptionName)
	EndProcedure
	
	Procedure.i GetVerbByName(VerbName.s, *ContainerVerb.Arguments::Verb = #Null)
		If Not *ContainerVerb
			*ContainerVerb = Arguments::*RootVerb
		EndIf
		
		ProcedureReturn Arguments::GetVerbByName(*ContainerVerb, VerbName)
	EndProcedure
	
	Procedure.s GetOptionValueByIndex(*Option.Arguments::Option, ValueIndex.i = 0)
		If *Option
			If SelectElement(*Option\Arguments(), ValueIndex)
				ProcedureReturn *Option\Arguments()
			EndIf
		EndIf
		
		ProcedureReturn #Null$
	EndProcedure
	
	Procedure.i GetOptionValues(*Option.Arguments::Option, List Values())
		If *Option
			CopyList(*Option\Arguments(), Values())
		EndIf
		
		ProcedureReturn
	EndProcedure
	
	Procedure.i GetOptionValueCount(*Option.Arguments::Option)
		If *Option
			ProcedureReturn ListSize(*Option\Arguments())
		EndIf
		
		ProcedureReturn 0
	EndProcedure
EndModule
