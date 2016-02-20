; -----------------------
; Category module
; -----------------------

DeclareModule Category
  
  Declare.i getMembers(List pllOutput.s(), pzTitle.s, Map pmArgs.s(), pzNamespace.s = "", pzType.s = "", piDepth.i = 0)
  
EndDeclareModule

Module Category
EnableExplicit

Procedure.i getMembers(List pllOutput.s(), pzTitle.s, Map pmArgs.s(), pzNamespace.s = "", pzType.s = "", piDepth.i = 0)
; -----------------------------------------
; #desc    get members of category page
; #param   pllOutput   : output list
;          pzTitle     : title of the category page including prefix
;          pmArgs      : additional query fields
;          pzNamespace : nr of namespace
;          pzType      : entry type (page, file, subcat)
;          piDepth     : recursion depth
; #returns 0 - error, 1 - success
; -----------------------------------------
  Protected.i iJSON,
              iMatch,
              i,
              j
  Protected.s zResult,
              zContinue,
              zContinuePoint,
              zTitle
  Protected NewMap mP.s()
; -----------------------------------------
  
  ; //
  ; build initial query
  ; //
  mP("action")   = "query"
  mP("list")     = "categorymembers"
  mP("cmtitle")  = Request::urlencodeText(pzTitle)
  mP("cmlimit")  = "500"
  mP("continue") = ""
  If pzNamespace
    mP("cmnamespace") = pzNamespace
  EndIf
  ForEach pmArgs()
    mP(MapKey(pmArgs())) = pmArgs()
  Next
  
  ; //
  ; if recursive, include subcats and entry type in query
  ; //
  If piDepth
    If Not FindString(pzType, "subcat")
      pzType = Trim(pzType + "|subcat", "|")
    EndIf
    
    If Not FindString(mP("cmnamespace"), "14")
      mP("cmnamespace") = Trim(mP("cmnamespace") + "|14", "|")
    EndIf
    
    If pzType
      mP("cmtype") = pzType
    EndIf
    
    If Not FindString(mP("cmprop"), "type")
      mP("cmprop") = Trim(mP("cmprop") + "|title|type", "|")
    EndIf
  EndIf
  
  Repeat
    zResult = Request::mwApi(mP())
    iJSON = ParseJSON(#PB_Any, zResult)
    If iJSON
      zContinue      = JSON::Get(iJSON, "continue\continue")
      zContinuePoint = JSON::Get(iJSON, "continue\cmcontinue")
        
      mP("cmcontinue") = zContinuePoint
      
      For i = JSONArraySize(Val(JSON::Get(iJSON, "query\categorymembers"))) - 1 To 0 Step -1
        zTitle = JSON::Get(iJSON, "query\categorymembers\[" + i + "]" + "\title")
        If piDepth
          If JSON::Get(iJSON, "query\categorymembers\[" + i + "]" + "\type") = "subcat"
            getMembers(pllOutput(), zTitle, pmArgs(), pzNamespace, pzType, piDepth - 1)
          EndIf
        EndIf
        iMatch = 0
        For j = 1 To CountString(pzNamespace, "|") + 1
          If JSON::Get(iJSON, "query\categorymembers\[" + i + "]" + "\ns") = StringField(pzNamespace, j, "|")
            iMatch = 1
            Break
          EndIf
        Next j
        If iMatch
          AddElement(pllOutput())
          pllOutput() = zTitle
        EndIf
      Next i
      
      FreeJSON(iJSON)
    EndIf
  Until zContinue = ""
  
EndProcedure

EndModule
; IDE Options = PureBasic 5.42 Beta 1 LTS (Windows - x86)
; CursorPosition = 41
; FirstLine = 27
; Folding = -
; EnableXP
; CompileSourceDirectory