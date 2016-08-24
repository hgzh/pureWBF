; -----------------------
; Page module declaration
; -----------------------

DeclareModule Page
  
  Declare.s getWikitext    (pzTitle.s)
  Declare.i replaceWikitext(pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
  Declare.i appendWikitext (pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
  Declare.i prependWikitext(pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
  
EndDeclareModule
; IDE Options = PureBasic 5.50 (Windows - x86)
; CursorPosition = 11
; Folding = -
; EnableXP
; CompileSourceDirectory