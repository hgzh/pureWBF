; -----------------------
; Request module
; -----------------------

DeclareModule Request
  
  ; //
  ; handle for static libcurl access
  ; //
  Global.i giCurlHandle = -1
  
  Declare.i init()
  Declare   close()
  Declare.i getStatusCode()
  Declare.s urlencodeText(pzText.s, piEncoding = #PB_UTF8)
  Declare.s mwApi(Map pmRequest.s(), piPOST.i = 0)
  
EndDeclareModule

Module Request
EnableExplicit

Structure _REQUEST_LAST
  zURL.s
  zResult.s
  iHttpCode.i
EndStructure  
  
Global _giLastRequest._REQUEST_LAST
  
Procedure.i init()
; -----------------------------------------
; #desc    initializes static libcurl
; #param   none
; #returns 0 - error, 1 - success
; -----------------------------------------  
  Protected.s zCookieFile,
              zUserAgent,
              zHeader,
              zEncoding
  Protected   *Header,
              *Headers
; -----------------------------------------
  
  If giCurlHandle <> -1
    ProcedureReturn 0
  EndIf
  
  zCookieFile = GetTemporaryDirectory() + "pbwb-cookies.txt"
  zUserAgent  = curl::str2curl("pbwb2 - de:user:hgzh")
  zHeader     = curl::str2curl("Cache-Control: no-cache")
  zEncoding   = curl::str2curl("UTF-8")
  
  giCurlHandle = curl::curl_easy_init()
  If giCurlHandle
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_IPRESOLVE, curl::#CURL_IPRESOLVE_V4)
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_COOKIEJAR, @zCookieFile)
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_COOKIEFILE, @zCookieFile)
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_USERAGENT, @zUserAgent)
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_ENCODING, @zEncoding)
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_TIMEOUT, 40) 
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_FOLLOWLOCATION, 1)
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_MAXREDIRS, 10) 
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_WRITEFUNCTION, curl::@curlWriteData())
    *Header = curl::curl_slist_append(*Headers, curl::str2curl("Cache-Control: no-cache"))
    *Header = curl::curl_slist_append(*Headers, curl::str2curl("Accept-Charset: utf-8"))
    curl::curl_easy_setopt(giCurlHandle, curl::#CURLOPT_HTTPHEADER, *Header)
    
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
  
EndProcedure

Procedure close()
; -----------------------------------------
; #desc    closes libcurl connection
; #param   none
; #returns nothing
; -----------------------------------------

  curl::curl_easy_cleanup(giCurlHandle)
  
  giCurlHandle = -1
  
EndProcedure

Procedure.i getStatusCode()
; -----------------------------------------
; #desc    returns status code of last request
; #param   none
; #returns status code
; -----------------------------------------
  
  ProcedureReturn _giLastRequest\iHttpCode
  
EndProcedure

Procedure.s urlencodeText(pzText.s, piEncoding = #PB_UTF8)
; -----------------------------------------
; #desc    encodes all special url characters properly to percent-encoding
; #param   pzText     : text to encode
;          piEncoding : encoding of pzText
; #returns encoded text
; -----------------------------------------
  Protected   *Memory
  Protected   *UTF8.Ascii
  Protected.s zEncodedURL
; -----------------------------------------
 
  Select piEncoding
    Case #PB_UTF8, #PB_Ascii
      *Memory = AllocateMemory(Len(pzText) * 4 + 1)
      *UTF8 = *Memory
     
      If *UTF8
        PokeS(*UTF8, pzText, -1, piEncoding)
       
        While *UTF8\a
          Select *UTF8\a
            Case 'A' To 'Z', 'a' To 'z', '0' To '9', '-', '_', '.', '~'
              zEncodedURL + Chr(*UTF8\a)
           
            Default
              zEncodedURL + "%" + RSet(Hex(*UTF8\a, #PB_Ascii), 2, "0")
           
          EndSelect
          *UTF8 + 1
        Wend
       
        FreeMemory(*Memory)
      EndIf
  EndSelect
 
  ProcedureReturn zEncodedURL
EndProcedure

Procedure.s mwApi(Map pmRequest.s(), piPOST.i = 0)
; -----------------------------------------
; #desc    performs request to MediaWiki API
; #param   pmRequest : map with url arguments
;          piPOST    : use POST (1) or GET (0)
; #returns result of request
; -----------------------------------------
  Protected.s zArgsURL,
              zBaseURL,
              zPostFields
; -----------------------------------------
  
  ; //
  ; build url
  ; //
  zBaseURL = "https://de.wikipedia.org/w/api.php"
  zArgsURL = "format=json"
  ForEach pmRequest()
    zArgsURL + "&" + MapKey(pmRequest()) + "=" + pmRequest()
  Next
  _giLastRequest\zURL = zBaseURL + "?" + zArgsURL
  
  If piPOST = 0
    zBaseURL = curl::str2curl(zBaseURL + "?" + zArgsURL)
  Else
    zPostFields = curl::str2curl(zArgsURL)
    zBaseURL    = curl::str2curl(zBaseURL)
  EndIf
    
  ; //
  ; if it is a POST request, set this to 1 by parameter
  ; //
  curl::curl_easy_setopt(Request::giCurlHandle, curl::#CURLOPT_POST, piPOST)
  
  ; //
  ; pass URL to curl
  ; //
  curl::curl_easy_setopt(Request::giCurlHandle, curl::#CURLOPT_URL, @zBaseURL)
  
  ; //
  ; if POST request, pass POST fields
  ; //
  If piPOST
    curl::curl_easy_setopt(Request::giCurlHandle, curl::#CURLOPT_POSTFIELDS, @zPostFields)
  EndIf
  
  ; // 
  ; perform curl request
  ; //
  curl::curl_easy_perform(Request::giCurlHandle)
  
  ; //
  ; get result
  ; //
  _giLastRequest\zResult = curl::curlGetData()
  
  ; //
  ; get http status code
  ; //
  curl::curl_easy_getinfo(Request::giCurlHandle, curl::#CURLINFO_RESPONSE_CODE, @_giLastRequest\iHttpCode)
  
  ProcedureReturn _giLastRequest\zResult
  
EndProcedure
  
EndModule
; IDE Options = PureBasic 5.42 Beta 1 LTS (Windows - x86)
; CursorPosition = 21
; Folding = --
; EnableUnicode
; EnableXP
; CompileSourceDirectory