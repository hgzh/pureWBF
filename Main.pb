; //
; force variable declaration
; //
EnableExplicit

; //
; include files
; //
IncludePath "includes"
XIncludeFile "libcurl.pb"
XIncludeFile "JSON.pb"

; //
; include module declarations
; //
IncludePath "moduledeclaration"
XIncludeFile "Auth.ModuleDeclaration.pb"
XIncludeFile "Category.ModuleDeclaration.pb"
XIncludeFile "Page.ModuleDeclaration.pb"
XIncludeFile "Request.ModuleDeclaration.pb"
XIncludeFile "Site.ModuleDeclaration.pb"

; //
; include modules
; //
IncludePath ""
XIncludeFile "Auth.pb"
XIncludeFile "Category.pb"
XIncludeFile "Page.pb"
XIncludeFile "Request.pb"
XIncludeFile "Site.pb"