;{- Code Header
; ==- Basic Info -================================
;         Name: Arguments.pbi
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

; TODO: Add a way to make references to options, the references should not be freed !
; |_> Share options between verbs basically.


;- Compiler Directives

EnableExplicit


;- Module declaration

DeclareModule Arguments
	;-> Semver Data
	
	#Version_Major = 0
	#Version_Minor = 0
	#Version_Patch = 5
	#Version_Label$ = ""
	#Version$ = "0.0.5"
	
	
	;-> Enumarations
	
	EnumerationBinary OptionFlags
		#Option_Default
		#Option_HasValue
		#Option_HasMultipleValue
		#Option_Repeatable
		#Option_Hidden
	EndEnumeration
	
	Enumeration ParserErrors
		#Error_None = #False
		
		;#Error_AlreadyExists
		;#Error_ParentIsNull
		;#Error_InsertionFailure
		;#Error_MallocFailure
		#Error_NullPointer
		
		#Error_Parser_UnknownOption
		#Error_Parser_NoDefaultFound
		#Error_Parser_DualEndOfOptions
		#Error_Parser_SingleOptionReused
		#Error_Parser_NoArgumentsLeft
		#Error_Parser_ExpectedArgument
		#Error_Parser_NoVerbOrDefaultFound
		#Error_Parser_OptionDoesNotHaveArgs
		#Error_Parser_OptionHasValueAndMoreShorts
	EndEnumeration
	
	
	;-> Constants
	
	#Error_Parser_NullPointer = #Error_NullPointer
	
	
	;-> Structures
	
	Structure Option
		Token.c
		Name.s
		Description.s
		List Arguments.s()
		Flags.i
		WasUsed.b
		Occurences.i
	EndStructure
	
	Structure Verb
		Verb.s
		Description.s
		List *Options.Option()
		List *Verbs.Verb()
		WasUsed.b
		*ParentVerb.Verb
	EndStructure
	
	
	;-> Globals
	
	Global *RootVerb.Verb = #Null
	
	
	;-> Procedure Declaration
	
	;-> > Basics
	Declare.b Init()
	Declare.b Finish()
	Declare.b FreeVerb(*Verb.Verb)
	Declare.b FreeOption(*Option.Option)
	
	;-> > Checkers
	Declare.b WereVerbsUsed(*Verb.Verb)
	Declare.b IsVerbAlreadyRegistered(*Verb.Verb, *ParentVerb.Verb)
	Declare.b IsOptionAlreadyRegistered(*Option.Option, *ParentVerb.Verb)
	Declare.b IsRootVerb(*Verb.Verb)
	
	Macro DoesOptionHaveValue(Option)
		Bool(Option\Flags & (Arguments::#Option_HasValue | Arguments::#Option_HasMultipleValue))
	EndMacro
	
	Macro DoesOptionHaveSingleValue(Option)
		Bool(Option\Flags & (Arguments::#Option_HasValue))
	EndMacro
	
	Macro DoesOptionHaveMultipleValue(Option)
		Bool(Option\Flags & (Arguments::#Option_HasMultipleValue))
	EndMacro
	
	;-> > Creators
	Declare.i CreateVerb(Verb.s, Description.s)
	Declare.i CreateOption(Token.c, Name.s, Description.s = #Null$, Flags.i = 0)
	Declare.b RegisterVerb(*Verb.Verb, *ParentVerb.Verb = #Null)
	Declare.b RegisterOption(*Option.Option, *ParentVerb.Verb = #Null)
	
	;-> > Getters
	Declare.i GetParentVerb(*Verb.Verb)
	Declare.i GetDefaultOption(*Verb.Verb)
	Declare.i GetOptionByToken(*Verb.Verb, DesiredToken.c)
	Declare.i GetOptionByName(*Verb.Verb, OptionName.s)
	Declare.i GetVerbByName(*ContainerVerb.Verb, VerbName.s)
	
	Macro GetRootVerb()
		Arguments::*RootVerb
	EndMacro
	
	;-> > Parser
	; Should not be used from outside of the module !
	;Declare.i ParseArgument(Argument.s, CurrentArgIndex.i, ArgsLeftCount.i)
	Declare.i ParseArguments(StartIndex.i = 0, EndIndex.i = -1)
EndDeclareModule


;- Module

Module Arguments
	;-> Compiler Directives
	
	EnableExplicit
	
	
	;-> Globals
	
	Global HasReachedEndOfOptions = #False
	Global HasFinishedParsingVerbs = #False
	Global LastParserError = #Error_None
	Global *CurrentParserVerb.Verb = *RootVerb
	
	
	;-> Procedure Definition
	
	;-> > Basics
	
	Procedure.b Init()
		*RootVerb = CreateVerb("root", #Null$)
		HasReachedEndOfOptions = #False
		HasFinishedParsingVerbs = #False
		LastParserError = #Error_None
		*CurrentParserVerb.Verb = *RootVerb
		ProcedureReturn Bool(*RootVerb <> #Null)
	EndProcedure
	
	Procedure.b Finish()
		If *RootVerb
			If FreeVerb(*RootVerb)
				*RootVerb = #Null
				ProcedureReturn #True
			EndIf
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b FreeVerb(*Verb.Verb)
		If *Verb
			ForEach *Verb\Verbs()
				FreeVerb(*Verb\Verbs())
			Next
			
			ForEach *Verb\Options()
				FreeOption(*Verb\Options())
			Next
			
			FreeStructure(*Verb)
			
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b FreeOption(*Option.Option)
		If *Option
			FreeStructure(*Option)
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	
	;-> > Checkers
	
	Procedure.b WereVerbsUsed(*Verb.Verb)
		If *Verb
			ForEach *Verb\Verbs()
				If *Verb\Verbs()\WasUsed
					ProcedureReturn #True
				EndIf
			Next
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b IsVerbAlreadyRegistered(*Verb.Verb, *ParentVerb.Verb)
		ForEach *ParentVerb\Verbs()
			If *ParentVerb\Verbs()\Verb = *Verb\Verb
				ProcedureReturn #True
			EndIf
		Next
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b IsOptionAlreadyRegistered(*Option.Option, *ParentVerb.Verb)
		ForEach *ParentVerb\Options()
			If *Option\Token <> #Null
				If *ParentVerb\Options()\Token = *Option\Token
					ProcedureReturn #True
				EndIf
			EndIf
			
			If *Option\Name <> #Null$
				If *ParentVerb\Options()\Name = *Option\Name
					ProcedureReturn #True
				EndIf
			EndIf
		Next
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b IsRootVerb(*Verb.Verb)
		If *Verb
			ProcedureReturn Bool(*Verb\ParentVerb = #Null)
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	
	;-> > Creators
	
	Procedure.i CreateVerb(Verb.s, Description.s)
		Protected *Verb.Verb = AllocateStructure(Verb)
		
		If *Verb And Verb <> #Null$
			*Verb\Verb = Verb
			*Verb\Description = Description
		EndIf
		
		ProcedureReturn *Verb
	EndProcedure
	
	Procedure.i CreateOption(Token.c, Name.s, Description.s = #Null$, Flags.i = 0)
		Protected *Option.Option = #Null
		
		If Token <> #Null Or Name <> #Null$
			*Option = AllocateStructure(Option)
			
			If *Option
				*Option\Token = Token
				*Option\Name = Name
				*Option\Description = Description
				*Option\Flags = Flags
				*Option\Occurences = 0
			EndIf
		EndIf
		
		ProcedureReturn *Option
	EndProcedure
	
	
	;-> > Registerers
	
	Procedure.b RegisterVerb(*Verb.Verb, *ParentVerb.Verb = #Null)
		If *Verb
			If *ParentVerb = #Null
				*ParentVerb = *RootVerb
			EndIf
			
			If *ParentVerb
				If Not IsVerbAlreadyRegistered(*Verb, *ParentVerb)
					AddElement(*ParentVerb\Verbs())
					*ParentVerb\Verbs() = *Verb
					*Verb\ParentVerb = *ParentVerb
					ProcedureReturn #True
				EndIf
			EndIf
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	Procedure.b RegisterOption(*Option.Option, *ParentVerb.Verb = #Null)
		If *Option
			If *ParentVerb = #Null
				*ParentVerb = *RootVerb
			EndIf
			
			If *ParentVerb
				If Not IsOptionAlreadyRegistered(*Option, *ParentVerb)
					AddElement(*ParentVerb\Options())
					*ParentVerb\Options() = *Option
					ProcedureReturn #True
				EndIf
			EndIf
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	
	
	;-> > Getters
	
	Procedure.i GetParentVerb(*Verb.Verb)
		If *Verb
			ProcedureReturn *Verb\ParentVerb
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure.i GetDefaultOption(*Verb.Verb)
		If *Verb
			ForEach *Verb\Options()
				If *Verb\Options()\Flags & #Option_Default
					ProcedureReturn *Verb\Options()
				EndIf
			Next
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure.i GetOptionByToken(*Verb.Verb, DesiredToken.c)
		If *Verb
			Debug "s> Verb given is not null"
			ForEach *Verb\Options()
				Debug "s> Checking "+Chr(*Verb\Options()\Token)
				If *Verb\Options()\Token = DesiredToken
					Debug "s> Found !"
					ProcedureReturn *Verb\Options()
				EndIf
			Next
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure.i GetOptionByName(*Verb.Verb, OptionName.s)
		If *Verb
			Debug "s> Verb given is not null"
			ForEach *Verb\Options()
				Debug "s> Checking "+*Verb\Options()\Name
				If *Verb\Options()\Name = OptionName
					Debug "s> Found !"
					ProcedureReturn *Verb\Options()
				EndIf
			Next
		EndIf
		
		ProcedureReturn #Null
	EndProcedure
	
	Procedure.i GetVerbByName(*ContainerVerb.Verb, VerbName.s)
		Protected *DesiredVerb.Verb = #Null
		
		If *ContainerVerb
			ForEach *ContainerVerb\Verbs()
				If *ContainerVerb\Verbs()\Verb = VerbName
					*DesiredVerb = *ContainerVerb\Verbs()
					Break
				EndIf
			Next
		EndIf
		
		ProcedureReturn *DesiredVerb
	EndProcedure
	
	
	;-> > Parser
	
	Procedure.i ParseArgument(Argument.s, CurrentArgIndex.i, ArgsLeftCount.i)
		Protected *RelevantOption.Option = #Null
		Protected *RelevantVerb.Verb = #Null
		
		Protected NumberOfArgumentsParsed.i = 1
		
		Debug "Parsing: "+Argument
		
		If Left(Argument, 2) = "--"
			Debug " > Long option"
			If Len(Argument) = 2
				Debug " > End of options symbol"
				If HasReachedEndOfOptions
					LastParserError = #Error_Parser_DualEndOfOptions
					ProcedureReturn #False
				Else
					HasReachedEndOfOptions = #True
				EndIf
			ElseIf HasReachedEndOfOptions
				Debug " > Default option"
				Protected *DefaultOption.Option = GetDefaultOption(*CurrentParserVerb)
				
				If *DefaultOption
					AddElement(*DefaultOption\Arguments())
					*DefaultOption\Arguments() = Argument
				Else
					LastParserError = #Error_Parser_NoDefaultFound
					ProcedureReturn #False
				EndIf
			Else
				Debug " > Generic option"
				Protected OptionName.s = Right(Argument, Len(Argument) - 2)
				
				*RelevantOption = GetOptionByName(*CurrentParserVerb, OptionName)
				Debug "$> "+OptionName
				
				If *RelevantOption
					Debug " > Found it !"
					If *RelevantOption\WasUsed
						If Not *RelevantOption\Flags & #Option_Repeatable
							LastParserError = #Error_Parser_SingleOptionReused
							ProcedureReturn #False
						EndIf
						*RelevantOption\Occurences = *RelevantOption\Occurences + 1
					Else
						*RelevantOption\WasUsed = #True
						*RelevantOption\Occurences = 1
					EndIf
					
					If DoesOptionHaveValue(*RelevantOption)
						Debug " > Option must have value"
						If DoesOptionHaveMultipleValue(*RelevantOption)
							Debug " > Multiple values"
							
							; FIXME: Fix it FFS !
							; #Error_Parser_NoArgumentsForOption
							Debug "!> Not implemented, IGNORED !"
						Else
							Debug " > Single value"
							If ArgsLeftCount > 0
								Debug "?> 1+ Launch arg left to read as potential value"
								Protected OptionArg.s = ProgramParameter(CurrentArgIndex + 1)
								
								If Left(OptionArg, 1) = "-"
									Debug "!> Received another option as a value !"
									LastParserError = #Error_Parser_ExpectedArgument
									ProcedureReturn #False
								EndIf
								
								Debug " > Value read successfully !"
								AddElement(*RelevantOption\Arguments())
								*RelevantOption\Arguments() = OptionArg
								
								NumberOfArgumentsParsed = NumberOfArgumentsParsed + 1
							Else
								Debug "!> No launch args left to be read as value !"
								LastParserError = #Error_Parser_NoArgumentsLeft
								ProcedureReturn #False
							EndIf
						EndIf
					EndIf
				Else
					Debug " > Option not found in the current verb !"
					LastParserError = #Error_Parser_UnknownOption
					ProcedureReturn #False
				EndIf
			EndIf
			
			HasFinishedParsingVerbs = #True
		ElseIf Left(Argument, 1) = "-"
			Debug " > Short option"
			
			Protected i.i
			For i = 2 To Len(Argument)
				Protected ShortOptionName.s = Mid(Argument, i, 1)
				
				Debug "?> Processing '"+ShortOptionName+"'"
				
				Protected ShortOptionToken.c = Asc(ShortOptionName)
				*RelevantOption = GetOptionByToken(*CurrentParserVerb, ShortOptionToken)
				
				If *RelevantOption
					Debug " > Found !"
					If *RelevantOption\WasUsed
						If Not *RelevantOption\Flags & #Option_Repeatable
							LastParserError = #Error_Parser_SingleOptionReused
							ProcedureReturn #False
						EndIf
						*RelevantOption\Occurences = *RelevantOption\Occurences + 1
					Else
						*RelevantOption\WasUsed = #True
						*RelevantOption\Occurences = 1
					EndIf
					
					If DoesOptionHaveValue(*RelevantOption)
						Debug " > Has a value"
						
						If i <> Len(Argument)
							Debug "!> Used too early (more short args...)"
							LastParserError = #Error_Parser_OptionHasValueAndMoreShorts
							ProcedureReturn #False
						EndIf
						
						If DoesOptionHaveMultipleValue(*RelevantOption)
							Debug " > Has multiple values"
							
							; FIXME: Fix it FFS !
							; #Error_Parser_NoArgumentsForOption
							Debug "!> Not implemented, IGNORED !"
						Else
							Debug " > Has one value"
							If ArgsLeftCount > 0
								Debug "?> 1+ Launch arg left to read as potential value"
								Protected ShortOptionArg.s = ProgramParameter(CurrentArgIndex + 1)
								
								If Left(ShortOptionArg, 1) = "-"
									Debug "!> Received another option as a value !"
									LastParserError = #Error_Parser_ExpectedArgument
									ProcedureReturn #False
								EndIf
								
								Debug " > Value read successfully !"
								AddElement(*RelevantOption\Arguments())
								*RelevantOption\Arguments() = ShortOptionArg
								
								NumberOfArgumentsParsed = NumberOfArgumentsParsed + 1
							Else
								Debug "!> No launch args left to be read as value !"
								LastParserError = #Error_Parser_NoArgumentsLeft
								ProcedureReturn #False
							EndIf
						EndIf
					EndIf
					
				Else
					Debug "!> Option not found in the current verb !"
					LastParserError = #Error_Parser_UnknownOption
					ProcedureReturn #False
				EndIf
			Next
			
			HasFinishedParsingVerbs = #True
		Else
			Debug " > Verb or default argument"
			; Verb or default argument
			If HasFinishedParsingVerbs
				Debug "?> Already finished parsing verbs"
				; We are sure we are parsing option arguments
				*RelevantOption = GetDefaultOption(*CurrentParserVerb)
				
				If Not *RelevantOption
					Debug " > No default option in the current verb !"
					LastParserError = #Error_Parser_NoDefaultFound
					ProcedureReturn #False
				EndIf
			Else
				Debug "?> Unknown type, determining..."
				; We will have find out it it is a verb or an option's argument
				; We should still be at the end of the arguments.
				
				; We check for the verb first.
				*RelevantVerb = GetVerbByName(*CurrentParserVerb, Argument)
				
				If Not *RelevantVerb
					Debug "?> No appropriate verb found, could be option"
					; We did not find a verb, we will now search for the default option
					*RelevantOption = GetDefaultOption(*CurrentParserVerb)
					
					If Not *RelevantOption
						Debug "!> Not an option or a verb !"
						LastParserError = #Error_Parser_NoVerbOrDefaultFound
						ProcedureReturn #False
					EndIf
				EndIf
			EndIf
			
			; We now set the variables before finishing.
			If *RelevantVerb
				Debug " > Treating as verb, changing current verb to: "+*RelevantVerb\Verb
				*RelevantVerb\WasUsed = #True
				*CurrentParserVerb = *RelevantVerb
			ElseIf *RelevantOption
				Debug " > Treating as option"
				If Not DoesOptionHaveValue(*RelevantOption)
					LastParserError = #Error_Parser_OptionDoesNotHaveArgs
					ProcedureReturn #False
				EndIf
				
				If DoesOptionHaveMultipleValue(*RelevantOption)
					; Multiple values
					Debug " > Has multiple values"
					AddElement(*RelevantOption\Arguments())
					*RelevantOption\Arguments() = Argument
				Else
					; Single value
					Debug " > Has one value"
					If ListSize(*RelevantOption\Arguments()) > 0
						LastParserError = #Error_Parser_SingleOptionReused
						ProcedureReturn #False
					Else
						AddElement(*RelevantOption\Arguments())
						*RelevantOption\Arguments() = Argument
					EndIf
				EndIf
				
				HasFinishedParsingVerbs = #True
			Else
				Debug "!> Fatal error, this should not be hapenning !"
				; This should not happen since there is a condition for it before,
				;  but we might as well be sure we don't miss anything.
				LastParserError = #Error_Parser_NoVerbOrDefaultFound
				ProcedureReturn #False
			EndIf
		EndIf
		
		; TODO: make default case ???
		;If Len(Argument) ; to check if it is >=2
		
		*CurrentParserVerb\WasUsed = #True
		
		ProcedureReturn NumberOfArgumentsParsed
	EndProcedure
	
	Procedure.i ParseArguments(StartIndex.i = 0, EndIndex.i = -1)
		Protected i.i = StartIndex
		
		If EndIndex = -1
			EndIndex = CountProgramParameters()
		EndIf
		
		While i < EndIndex
			i = i + ParseArgument(ProgramParameter(i), i, CountProgramParameters() - i)
			If LastParserError <> #Error_None
				Break
			EndIf
		Wend
		
		ProcedureReturn LastParserError
	EndProcedure
EndModule


;- Tests

CompilerIf #PB_Compiler_IsMainFile
	Debug "start"
	
	If Not Arguments::Init()
		Debug "Failed to init Arguments"
		End 1
	EndIf
	
	Define HelpOption = Arguments::CreateOption('h', "help", "Display the help text")
	If Not Arguments::RegisterOption(HelpOption)
		Debug "Failed to register HelpOption !"
		Arguments::FreeOption(HelpOption)
	EndIf
	
	Define SingleValueOption = Arguments::CreateOption('t', "test", "Single value test.",
	                                                   Arguments::#Option_HasValue)
	If Not Arguments::RegisterOption(SingleValueOption)
		Debug "Failed to register SingleValueOption !"
		Arguments::FreeOption(SingleValueOption)
	EndIf
	
	Define VerbAdd = Arguments::CreateVerb("add", "desc...")
	If Not Arguments::RegisterVerb(VerbAdd)
		Debug "Failed to register VerbAdd !"
		Arguments::FreeVerb(VerbAdd)
	EndIf
	
	; TODO: Add a way to make references to options, the references should not be freed !
	;If Not Arguments::RegisterOption(SingleValueOption, VerbAdd)
	;	Debug "Failed to register SingleValueOption a second time !"
	;EndIf
	
	Define VerbSub = Arguments::CreateVerb("sub", "desc...")
	If Not Arguments::RegisterVerb(VerbSub)
		Debug "Failed to register VerbSub !"
		Arguments::FreeVerb(VerbSub)
	EndIf
	
	
	Procedure PrintVerb(*Verb.Arguments::Verb, Depth.i = 0)
		If *Verb
			Debug Space(4*Depth)+"$"+*Verb\Verb
			Debug Space(4*Depth)+"WasUsed: "+*Verb\WasUsed
			
			Debug Space(4*Depth)+"Options"
			ForEach *Verb\Options()
				Debug Space(4*Depth)+">"+Chr(*Verb\Options()\Token)+" | "+*Verb\Options()\Name
				Debug Space(4*Depth+1)+"WasUsed: "+*Verb\Options()\WasUsed
				Debug Space(4*Depth+1)+"Arguments: -> ("+ListSize(*Verb\Options()\Arguments())+")"
				ForEach *Verb\Options()\Arguments()
					Debug Space(4*Depth+2)+*Verb\Options()\Arguments()
				Next
			Next
			
			Debug Space(4*Depth)+"Verbs"
			ForEach *Verb\Verbs()
				PrintVerb(*Verb\Verbs(), Depth+1)
			Next
		EndIf
	EndProcedure
	
	If Arguments::ParseArguments(0, CountProgramParameters())
		Debug "Failed to parse !"
	EndIf
	Debug ""
	
	PrintVerb(Arguments::*RootVerb)
	
	Arguments::Finish()
CompilerEndIf
