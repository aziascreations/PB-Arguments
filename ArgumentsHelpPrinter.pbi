;{- Code Header
; ==- Basic Info -================================
;         Name: ArgumentsHelpPrinter.pbi
;      Version: 0.0.6
;       Author: Herwin Bozet
;
; ==- Compatibility -=============================
;  Compiler version: PureBasic 5.70 (x86/x64)
;  Operating system: Windows 10 21H1 (Previous versions untested)
; 
; ==- Links & License -===========================
;  License: Unlicense
;  GitHub: https://github.com/aziascreations/PB-Arguments
;}

;- DocMaker Statements

;@chapter Arguments Help Text Printer
;@ Intro text...<br>
;@ <b>Module Namespace</b>: ArgumentsHelpPrinter


;- Compiler Directives

EnableExplicit
XIncludeFile "./Arguments.pbi"


;- Module declaration

DeclareModule ArgumentsHelpPrinter
	;-> Semver Data
	
	#Version_Major = 0
	#Version_Minor = 0
	#Version_Patch = 6
	#Version_Label$ = ""
	#Version$ = "0.0.6"
	
	
	;-> Constants
	
	#MinTerminalWidth = 80
	
	
	;-> Procedure Declaration
	
	Declare.s GetOptionUsageTextSnippet(*Option.Arguments::Option)
	Declare.s GetUsageText(*Verb.Arguments::Verb, ProgramName$ = #Null$, TerminalWidth.i = #MinTerminalWidth,
	                       PrintVerbPlaceholder.b = #False)
	Declare.s GetVerbsDescription(*Verb.Arguments::Verb, MarginSpacing.i = 2, InterSpacing.i = 4,
	                              TerminalWidth.i = #MinTerminalWidth, PrintDescriptionSpacing.b = #True)
EndDeclareModule


;- Module

Module ArgumentsHelpPrinter
	;-> Compiler Directives
	
	EnableExplicit
	
	
	;-> Procedure Definition
	
	Procedure.s GetOptionValueSnippet(*Option.Arguments::Option)
		If *Option\Flags & Arguments::#Option_HasMultipleValue
			ProcedureReturn " <value...>"
		ElseIf *Option\Flags & Arguments::#Option_HasValue
			ProcedureReturn " <value>"
		EndIf
		
		ProcedureReturn #Null$
	EndProcedure
	
	Procedure.s GetOptionUsageTextSnippet(*Option.Arguments::Option)
		Protected UsageTextSnippet$
		
		If *Option\Flags & Arguments::#Option_Default
			UsageTextSnippet$ = "<"
		Else
			UsageTextSnippet$ = "["
		EndIf
		
		Protected UsageTextValueSnippet$ = GetOptionValueSnippet(*Option)
		
		If *Option\Token <> #Null
			UsageTextSnippet$ = UsageTextSnippet$ + "-" + Chr(*Option\Token) + UsageTextValueSnippet$
			
			If *Option\Name <> #Null$
				UsageTextSnippet$ = UsageTextSnippet$ + "|--" + *Option\Name + UsageTextValueSnippet$
			EndIf
		Else
			UsageTextSnippet$ = UsageTextSnippet$ + "--" + *Option\Name + UsageTextValueSnippet$
		EndIf
		
		If *Option\Flags & Arguments::#Option_Default
			ProcedureReturn UsageTextSnippet$ + ">"
		Else
			ProcedureReturn UsageTextSnippet$ + "]"
		EndIf
	EndProcedure
	
	Procedure.s GetUsageText(*Verb.Arguments::Verb, ProgramName$ = #Null$, TerminalWidth.i = #MinTerminalWidth,
	                         PrintVerbPlaceholder.b = #False)
		If ProgramName$ = #Null$
			ProgramName$ = GetFilePart(ProgramFilename(), #PB_FileSystem_NoExtension) + " "
		EndIf
		
		If *Verb\ParentVerb <> #Null
			ProgramName$ = ProgramName$ + *Verb\Verb + " "
		ElseIf PrintVerbPlaceholder And ListSize(*Verb\Verbs()) > 0
			ProgramName$ = ProgramName$ + "[verb] "
		EndIf
		
		If TerminalWidth < #MinTerminalWidth
			TerminalWidth = #MinTerminalWidth
		EndIf
		
		Protected UsageText$ = ProgramName$
		Protected UsageTextLine$ = ""
		
		Protected ProgramNameLength.i = Len(ProgramName$) + 1
		Protected UsageTextLineLength.i = 0
		
		ForEach *Verb\Options()
			If *Verb\Options()\Flags & Arguments::#Option_Hidden
				Continue
			EndIf
			
			Protected UsageTextSnippet$ = GetOptionUsageTextSnippet(*Verb\Options())
			Protected UsageTextSnippetLength.i = Len(UsageTextSnippet$)
			
			If ProgramNameLength + UsageTextLineLength + UsageTextSnippetLength + 1 > TerminalWidth
				UsageText$ = UsageText$ + UsageTextLine$ + #CRLF$
				UsageTextLine$ = Space(ProgramNameLength) + UsageTextSnippet$
				UsageTextLineLength = ProgramNameLength + UsageTextSnippetLength
			Else
				UsageTextLine$ = UsageTextLine$ + " " + UsageTextSnippet$
				UsageTextLineLength = UsageTextLineLength + UsageTextSnippetLength + 1
			EndIf
		Next
		
		ProcedureReturn UsageText$ + UsageTextLine$
	EndProcedure
	
	Procedure.s GetVerbsDescription(*Verb.Arguments::Verb, MarginSpacing.i = 2, InterSpacing.i = 4,
	                                TerminalWidth.i = #MinTerminalWidth, PrintDescriptionSpacing.b = #True)
		Protected VerbDescription$ = ""
		
		If TerminalWidth < #MinTerminalWidth
			TerminalWidth = #MinTerminalWidth
		EndIf
		
		Protected MaxVerbLength.i = 0
		
		ForEach	*Verb\Verbs()
			Protected VerbLength.i = Len(*Verb\Verbs())
			
			If VerbLength > MaxVerbLength
				MaxVerbLength = VerbLength
			EndIf
		Next
		
		If MaxVerbLength + 2 + MarginSpacing + InterSpacing > TerminalWidth
			Debug "Forcefully disabling the automatic verb description spacing !"
			PrintDescriptionSpacing = #False
		EndIf
		
		ForEach	*Verb\Verbs()
			; Fuck
		Next
		
		ProcedureReturn VerbDescription$
	EndProcedure
EndModule
