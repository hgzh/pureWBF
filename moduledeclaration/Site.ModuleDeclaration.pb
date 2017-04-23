; -----------------------
; Site module declaration
; -----------------------

DeclareModule Site
  
  Declare.i add         (pzName.s, pzURL.s)
  Declare.i change      (pzName.s)
  Declare.i refreshToken(pzType.s = "csrf", piForced.i = 0)
  Declare.s getToken    (pzType.s = "csrf")
  
  Structure SITE
    zName.s
    zURL.s
    Map mTokens.s()
  EndStructure
  
  Global *Current.SITE
  
EndDeclareModule