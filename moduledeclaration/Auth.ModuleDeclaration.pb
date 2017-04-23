; -----------------------
; Auth module declaration
; -----------------------

DeclareModule Auth
  
  Declare.i loginUser (pzUsername.s, pzPassword.s)
  Declare   logoutUser()
    
EndDeclareModule