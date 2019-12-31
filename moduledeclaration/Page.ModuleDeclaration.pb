; -----------------------
; Page module declaration
; -----------------------

DeclareModule Page
  
  Declare.s getWikitext    (pzTitle.s)
  Declare.i replaceWikitext(pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
  Declare.i appendWikitext (pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
  Declare.i prependWikitext(pzTitle.s, pzNewText.s, pzSummary.s, piBot.i, Map pmArgs.s())
  Declare.s getLanguagelinkTarget(pzTitle.s, pzLangCode.s)
  Declare.s getInterwikilinkTarget(pzTitle.s, pzPrefix.s)
  Declare.i getEmbeddedIn(List pllOutput.s(), pzTitle.s, piID.i, pzNamespace.s, Map pmArgs.s())
  
EndDeclareModule