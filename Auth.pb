; -----------------------
; Authentication module
; -----------------------

DeclareModule Auth
  
  Declare.i refreshToken(pzType.s = "csrf", piForced.i = 0)
  Declare.s getToken(pzType.s = "csrf")
  Declare.i loginUser(pzUsername.s, pzPassword.s)
  Declare   logoutUser()
    
EndDeclareModule

Module Auth
EnableExplicit

; //
; map with all saved tokens
; //
Global NewMap _gmTokens.s()

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
  
  If _gmTokens(pzType) <> "" And piForced = 0
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
    _gmTokens(pzType) = URLEncoder(zText)
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

  If _gmTokens(pzType) = ""
    refreshToken(pzType)
  EndIf
  
  ProcedureReturn _gmTokens(pzType)
  
EndProcedure

Procedure.i loginUser(pzUsername.s, pzPassword.s)
; -----------------------------------------
; #desc    authenticate a user by username and password
; #param   pzUsername  : username
;          pzPassword  : password
; #returns 0 - error, 1 - success
; -----------------------------------------  
  Protected.i iJSON
  Protected.s zResult,
              zLgToken
  Protected NewMap mP.s()
; -----------------------------------------  
  
  mP("action")     = "login"
  mP("lgname")     = pzUsername
  mP("lgpassword") = pzPassword
  zResult = Request::mwApi(mP(), 1)
  
  iJSON = ParseJSON(#PB_Any, zResult)
  If iJSON
    zResult  = JSON::Get(iJSON, "login\result")
    zLgToken = JSON::Get(iJSON, "login\token")
    FreeJSON(iJSON)
  EndIf
  
  If zResult = "Success"
    ProcedureReturn 1
  ElseIf zResult = "NeedToken"
    ClearMap(mP())
    mP("action")     = "login"
    mP("lgname")     = pzUsername
    mP("lgpassword") = pzPassword
    mP("lgtoken")    = zLgToken
    zResult = Request::mwApi(mP(), 1)
  
    iJSON = ParseJSON(#PB_Any, zResult)
    If iJSON
      zResult = JSON::Get(iJSON, "login\result")    
      FreeJSON(iJSON)
    EndIf
    
    If zResult = "Success"
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
  EndIf
  
EndProcedure

Procedure logoutUser()
; -----------------------------------------
; #desc    logout the current user
; #param   none
; #returns nothing
; -----------------------------------------  
  Protected NewMap mP.s()
; -----------------------------------------  
  
  mP("action") = "logout"
  Request::mwApi(mP(), 1)
  
EndProcedure
  
EndModule
; IDE Options = PureBasic 5.42 Beta 1 LTS (Windows - x86)
; CursorPosition = 14
; Folding = --
; EnableUnicode
; EnableXP
; CompileSourceDirectory