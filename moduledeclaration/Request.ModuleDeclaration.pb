; -----------------------
; Request module declaration
; -----------------------

DeclareModule Request
  
  ; //
  ; handle for static libcurl access
  ; //
  Global.i giCurlHandle = -1
  
  Declare.i init         ()
  Declare   close        ()
  Declare.i getStatusCode()
  Declare.s urlencodeText(pzText.s, piEncoding = #PB_UTF8)
  Declare.s mwApi        (Map pmRequest.s(), piPOST.i = 0, piFormatVersion = 1)
  
EndDeclareModule