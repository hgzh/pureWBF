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

EndModule