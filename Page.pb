; -----------------------
; Page module
; -----------------------

Module Page
  EnableExplicit

Procedure.i _setWikitext(pzTitle.s, pzText.s, pzSummary.s, piBot.i, piMode.i, Map pmArgs.s())
; -----------------------------------------
; #desc    edit the page's wikitext
; #param   pzTitle   : page title
;          pzText    : new wikitext
;          pzSummary : edit summary
;          piBot     : mark as bot edit
;          piMode    : full text replacement (0), append text (1), prepend text (2)
;          pmArgs    : map with further query parameters
; #returns 
; -----------------------------------------
  Protected.i iJSON
  Protected.s zResult
  Protected NewMap mP.s()
; -----------------------------------------  
  
  mP("action")  = "edit"
  mP("title")   = Request::urlencodeText(pzTitle)
  mP("summary") = pzSummary
  mP("token")   = Site::getToken()
  If piBot = 1
    mP("bot")   = ""
  EndIf
  If piMode = 0
    mP("text")  = Request::urlencodeText(pzText)
  ElseIf piMode = 1
    mP("appendtext") = Request::urlencodeText(pzText)
  ElseIf piMode = 2
    mP("prependtext") = Request::urlencodeText(pzText)
  EndIf
  ForEach pmArgs()
    mP(MapKey(pmArgs())) = pmArgs()
  Next
  zResult = Request::mwApi(mP(), 1)
    
  iJSON = ParseJSON(#PB_Any, zResult)
  If iJSON
    FreeJSON(iJSON)
  EndIf

EndProcedure

Procedure.s getWikitext(pzTitle.s)
; -----------------------------------------
; #desc    receive the page's content in wikitext
; #param   pzTitle  : Page title
; #returns page content in wikitext
; -----------------------------------------  
  Protected.i iJSON
  Protected.s zResult,
              zText
  Protected NewMap mP.s()
; -----------------------------------------

  mP("action") = "parse"
  mP("prop")   = "wikitext"
  mP("page")   = Request::urlencodeText(pzTitle)
  zResult = Request::mwApi(mP())
    
  iJSON = ParseJSON(#PB_Any, zResult)
  If iJSON
    zText = JSON::Get(iJSON, "parse\wikitext\*")
    FreeJSON(iJSON)
  EndIf
  
  ProcedureReturn zText

EndProcedure

Procedure.i replaceWikitext(pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
; -----------------------------------------
; #desc    replace the page's wikitext with new text
; #param   pzTitle   : page title
;          pzText    : new wikitext
;          pzSummary : edit summary
;          piBot     : mark as bot edit
;          pmArgs    : map with further query parameters
; #returns 
; -----------------------------------------

  ProcedureReturn _setWikitext(pzTitle, pzNewText, pzSummary, piBot, 0, pmArgs())
  
EndProcedure

Procedure.i appendWikitext(pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
; -----------------------------------------
; #desc    add wikitext to the end of the given page
; #param   pzTitle   : page title
;          pzText    : new wikitext
;          pzSummary : edit summary
;          piBot     : mark as bot edit
;          pmArgs    : map with further query parameters
; #returns 
; -----------------------------------------

  ProcedureReturn _setWikitext(pzTitle, pzNewText, pzSummary, piBot, 1, pmArgs())
  
EndProcedure

Procedure.i prependWikitext(pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
; -----------------------------------------
; #desc    add wikitext to the beginning of the given page
; #param   pzTitle   : page title
;          pzText    : new wikitext
;          pzSummary : edit summary
;          piBot     : mark as bot edit
;          pmArgs    : map with further query parameters
; #returns 
; -----------------------------------------

  ProcedureReturn _setWikitext(pzTitle, pzNewText, pzSummary, piBot, 2, pmArgs())
  
EndProcedure

Procedure.s getLanguagelinkTarget(pzTitle.s, pzLangCode.s)
; -----------------------------------------
; #desc    get the page title of a languagelink connected with the given title in the given lang code.
; #param   pzTitle     : source page title
;          pzTLangCode : target language code
; #returns page title
; -----------------------------------------
  Protected.i iJSON
  Protected.s zResult,
              zText
  Protected NewMap mP.s()
; -----------------------------------------
  
  mP("action") = "query"
  mP("prop")   = "langlinks"
  mP("titles") = URLEncoder(pzTitle)
  mP("lllang") = pzLangCode
  zResult = Request::mwApi(mP(), 0, 2)
  
  iJSON = ParseJSON(#PB_Any, zResult)
  If iJSON
    zText = JSON::Get(iJSON, "query\pages\[0]\langlinks\[0]\title")
    FreeJSON(iJSON)
  EndIf
  
  ProcedureReturn zText

EndProcedure

Procedure.s getInterwikilinkTarget(pzTitle.s, pzPrefix.s)
; -----------------------------------------
; #desc    get the page title of an interwikilink connected with the given title in the project with the given prefix.
; #param   pzTitle   : source page title
;          pzPrefix  : target project prefix
; #returns page title
; -----------------------------------------
  Protected.i iJSON
  Protected.s zResult,
              zText
  Protected NewMap mP.s()
; -----------------------------------------
  
  mP("action") = "query"
  mP("prop")   = "iwlinks"
  mP("titles") = URLEncoder(pzTitle)
  mP("iwprefix") = pzPrefix
  zResult = Request::mwApi(mP(), 0, 2)
  
  iJSON = ParseJSON(#PB_Any, zResult)
  If iJSON
    zText = JSON::Get(iJSON, "query\pages\[0]\iwlinks\[0]\title")
    FreeJSON(iJSON)
  EndIf
  
  ProcedureReturn zText

EndProcedure

Procedure.i getEmbeddedIn(List pllOutput.s(), pzTitle.s, piID.i, pzNamespace.s, Map pmArgs.s())
; -----------------------------------------
; #desc    get the page's embeddings in other pages
; #param   pllOutput   : output list
;          pzTitle     : page title
;          piID        : or page id
;          pzNamespace : nr of namespace
;          pmArgs      : map with further query parameters
; #returns embeddings count
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
  mP("list")     = "embeddedin"
  If piID > -1
    mP("eipageid") = Str(piID)
  Else
    mP("eititle")  = Request::urlencodeText(pzTitle)
  EndIf
  mP("ceilimit")  = "max"
  mP("continue") = ""
  If pzNamespace
    mP("einamespace") = pzNamespace
  EndIf
  ForEach pmArgs()
    mP(MapKey(pmArgs())) = pmArgs()
  Next
  
  ; //
  ; loop through
  ; //
  Repeat
    zResult = Request::mwApi(mP())
    iJSON = ParseJSON(#PB_Any, zResult)
    If iJSON
      zContinue      = JSON::Get(iJSON, "continue\continue")
      zContinuePoint = JSON::Get(iJSON, "continue\eicontinue")
        
      mP("eicontinue") = zContinuePoint
      
      For i = JSONArraySize(Val(JSON::Get(iJSON, "query\embeddedin"))) - 1 To 0 Step -1
        zTitle = JSON::Get(iJSON, "query\embeddedin\[" + i + "]" + "\title")
        
        ; //
        ; check if page is in given namespace
        ; //
        iMatch = 0
        For j = 1 To CountString(pzNamespace, "|") + 1
          If JSON::Get(iJSON, "query\embeddedin\[" + i + "]" + "\ns") = StringField(pzNamespace, j, "|")
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
  
  ProcedureReturn ListSize(pllOutput())
    
EndProcedure

EndModule