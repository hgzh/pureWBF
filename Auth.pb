; -----------------------
; Authentication module
; -----------------------

Module Auth
  EnableExplicit

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
  
  zLgToken = Site::getToken("login")
  
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
; IDE Options = PureBasic 5.50 (Windows - x86)
; CursorPosition = 10
; Folding = -
; EnableXP
; CompileSourceDirectory
; EnableUnicode