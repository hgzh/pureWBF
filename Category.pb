; -----------------------
; Category module
; -----------------------

Module Category
  EnableExplicit

Procedure.i getMembers(List pllOutput.s(), pzTitle.s, Map pmArgs.s(), pzNamespace.s = "", pzType.s = "", piDepth.i = 0, piNoDupes.i = 0)
; -----------------------------------------
; #desc    get members of category page
; #param   pllOutput   : output list
;          pzTitle     : title of the category page including prefix
;          pmArgs      : additional query fields
;          pzNamespace : nr of namespace
;          pzType      : entry type (page, file, subcat)
;          piDepth     : recursion depth
;          piNoDupes   : remove duplicated items
; #returns -1 - error, else nr of items in category
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
  
  ; //
  ; loop through
  ; //
  Repeat
    zResult = Request::mwApi(mP())
    iJSON = ParseJSON(#PB_Any, zResult)
    If iJSON
      zContinue      = JSON::Get(iJSON, "continue\continue")
      zContinuePoint = JSON::Get(iJSON, "continue\cmcontinue")
        
      mP("cmcontinue") = zContinuePoint
      
      For i = JSONArraySize(Val(JSON::Get(iJSON, "query\categorymembers"))) - 1 To 0 Step -1
        zTitle = JSON::Get(iJSON, "query\categorymembers\[" + i + "]" + "\title")
        
        ; //
        ; step into categorytree if recursion is enabled
        ; //
        If piDepth
          If JSON::Get(iJSON, "query\categorymembers\[" + i + "]" + "\type") = "subcat"
            getMembers(pllOutput(), zTitle, pmArgs(), pzNamespace, pzType, piDepth - 1)
          EndIf
        EndIf
        
        ; //
        ; check if page is in given namespace
        ; //
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
    Else
      ProcedureReturn -1
    EndIf
  Until zContinue = ""
  
  ; //
  ; sort list
  ; //
  SortList(pllOutput(), #PB_Sort_Ascending)
  
  ; //
  ; remove duplicated items
  ; //
  If piNoDupes
    ForEach pllOutput()
      zTitle = pllOutput()
      PushListPosition(pllOutput())
      Repeat
        If NextElement(pllOutput())
          If zTitle = pllOutput()
            DeleteElement(pllOutput())
          Else
            Break
          EndIf
        Else
          Break
        EndIf
      ForEver
      PopListPosition(pllOutput())
    Next
  EndIf
  
  ProcedureReturn ListSize(pllOutput())
  
EndProcedure

EndModule
; IDE Options = PureBasic 5.50 (Windows - x86)
; CursorPosition = 5
; Folding = -
; EnableXP
; CompileSourceDirectory