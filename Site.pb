; -----------------------
; Site module
; -----------------------

Module Site
  EnableExplicit
  
  Global NewList _gllSites.SITE()
  
Procedure.i add(pzName.s, pzURL.s)
; -----------------------------------------
; #desc    add a new site
; #param   pzName   : site identifier
;          pzURL    : site url
; #returns 0 - error
;          1 - success
; -----------------------------------------

  ForEach _gllSites()
    If _gllSites()\zName = pzName
      ProcedureReturn 0
    EndIf
  Next
  
  AddElement(_gllSites())
  _gllSites()\zName = pzName
  _gllSites()\zURL  = pzURL
  
  *Current = @_gllSites()
  
  ProcedureReturn 1
  
EndProcedure

Procedure.i change(pzName.s)
; -----------------------------------------
; #desc    changes the currently active site
; #param   pzName   : site name
; #returns 0 - error
;          1 - success
; -----------------------------------------  

  ForEach _gllSites()
    If _gllSites()\zName = pzName
      *Current = @_gllSites()
      ProcedureReturn 1
    EndIf
  Next
  
  ProcedureReturn 0
  
EndProcedure

Procedure.i refreshToken(pzType.s = "csrf", piForced.i = 0)
; -----------------------------------------
; #desc    refresh the token with the given type
; #param   pzType   : type of token
;          piForced : get new token even there is already one
; #returns 1 if token refreshed, 0 if not
; -----------------------------------------  
  Protected.i iJSON
  Protected.s zResult,
              zText
  Protected NewMap mP.s()
; -----------------------------------------  
  
  If _gllSites()\mTokens(pzType) <> "" And piForced = 0
    ProcedureReturn 0
  EndIf
  
  mP("action") = "query"
  mP("meta")   = "tokens"
  mP("type")   = pzType
  zResult = Request::mwApi(mP())
    
  iJSON = ParseJSON(#PB_Any, zResult)
  If iJSON
    zText = JSON::Get(iJSON, "query\tokens\" + pzType + "token")
    FreeJSON(iJSON)
  EndIf
  
  If zText
    _gllSites()\mTokens(pzType) = URLEncoder(zText)
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
  
EndProcedure

Procedure.s getToken(pzType.s = "csrf")
; -----------------------------------------
; #desc    get the current token with the given type
; #param   pzType   : type of token
; #returns token value
; -----------------------------------------  

  If _gllSites()\mTokens(pzType) = ""
    refreshToken(pzType)
  EndIf
  
  ProcedureReturn _gllSites()\mTokens(pzType)
  
EndProcedure
  
EndModule