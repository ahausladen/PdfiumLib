// Use DLLs (x64, x86) from https://github.com/bblanchon/pdfium-binaries
//
// DLL Version: chromium/6043

unit PdfiumLib;
{$IFDEF FPC}
  {$MODE DelphiUnicode}
{$ENDIF FPC}

{$IFNDEF FPC}
  {$A8,B-,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,T-,U-,V+,X+,Z1}
  {$STRINGCHECKS OFF} // It only slows down Delphi strings in Delphi 2009 and 2010
{$ENDIF ~FPC}
{$SCOPEDENUMS ON}

{.$DEFINE DLLEXPORT} // stdcall in WIN32 instead of CDECL in WIN32 (The library switches between those from release to release)

{$DEFINE _SKIA_SUPPORT_}
{$DEFINE PDF_ENABLE_XFA}
{$DEFINE PDF_ENABLE_V8}

interface

uses
  {$IFDEF FPC}
    {$IFDEF MSWINDOWS}
  Windows;
    {$ELSE}
  dynlibs;
    {$ENDIF MSWINDOWS}
  {$ELSE}
    {$IF CompilerVersion >= 23.0} // XE2+
  WinApi.Windows;
    {$ELSE}
  Windows;
    {$IFEND}
  {$ENDIF FPC}

type
  // Delphi/FPC version compatibility types
  {$IF not declared(SIZE_T)}
  SIZE_T = LongWord;
  {$IFEND}
  {$IF not declared(DWORD)}
  DWORD = UInt32;
  {$IFEND}
  {$IF not declared(UINT)}
  UINT = LongWord;
  {$IFEND}
  {$IF not declared(PUINT)}
  PUINT = ^UINT;
  {$IFEND}
  TIME_T = Longint;
  PTIME_T = ^TIME_T;

// Returns True if the pdfium.dll supports Skia.
function PDF_IsSkiaAvailable: Boolean;


// *** _FPDFVIEW_H_ ***

{.$IFDEF PDF_ENABLE_XFA}
// PDF_USE_XFA is set in confirmation that this version of PDFium can support
// XFA forms as requested by the PDF_ENABLE_XFA setting.
function PDF_USE_XFA: Boolean;
{.$ENDIF PDF_ENABLE_XFA}

const
  // PDF object types
  FPDF_OBJECT_UNKNOWN = 0;
  FPDF_OBJECT_BOOLEAN = 1;
  FPDF_OBJECT_NUMBER = 2;
  FPDF_OBJECT_STRING = 3;
  FPDF_OBJECT_NAME = 4;
  FPDF_OBJECT_ARRAY = 5;
  FPDF_OBJECT_DICTIONARY = 6;
  FPDF_OBJECT_STREAM = 7;
  FPDF_OBJECT_NULLOBJ = 8;
  FPDF_OBJECT_REFERENCE = 9;

// PDF text rendering modes
type
  FPDF_TEXT_RENDERMODE = Integer;
const
  FPDF_TEXTRENDERMODE_UNKNOWN = -1;
  FPDF_TEXTRENDERMODE_FILL = 0;
  FPDF_TEXTRENDERMODE_STROKE = 1;
  FPDF_TEXTRENDERMODE_FILL_STROKE = 2;
  FPDF_TEXTRENDERMODE_INVISIBLE = 3;
  FPDF_TEXTRENDERMODE_FILL_CLIP = 4;
  FPDF_TEXTRENDERMODE_STROKE_CLIP = 5;
  FPDF_TEXTRENDERMODE_FILL_STROKE_CLIP = 6;
  FPDF_TEXTRENDERMODE_CLIP = 7;
  FPDF_TEXTRENDERMODE_LAST = FPDF_TEXTRENDERMODE_CLIP;

type
  // Helper data type for type safety.
  __FPDF_PTRREC = record end;
  __PFPDF_PTRREC = ^__FPDF_PTRREC;
  PFPDF_LINK = ^FPDF_LINK; // array
  PFPDF_PAGE = ^FPDF_PAGE; // array

  // PDF types - use incomplete types (never completed) to force API type safety.
  FPDF_ACTION             = type __PFPDF_PTRREC;
  FPDF_ANNOTATION         = type __PFPDF_PTRREC;
  FPDF_ATTACHMENT         = type __PFPDF_PTRREC;
  FPDF_AVAIL              = type __PFPDF_PTRREC;
  FPDF_BITMAP             = type __PFPDF_PTRREC;
  FPDF_BOOKMARK           = type __PFPDF_PTRREC;
  FPDF_CLIPPATH           = type __PFPDF_PTRREC;
  FPDF_DEST               = type __PFPDF_PTRREC;
  FPDF_DOCUMENT           = type __PFPDF_PTRREC;
  FPDF_FONT               = type __PFPDF_PTRREC;
  FPDF_FORMHANDLE         = type __PFPDF_PTRREC;
  FPDF_GLYPHPATH          = type __PFPDF_PTRREC;
  FPDF_JAVASCRIPT_ACTION  = type __PFPDF_PTRREC;
  FPDF_LINK               = type __PFPDF_PTRREC;
  FPDF_PAGE               = type __PFPDF_PTRREC;
  FPDF_PAGELINK           = type __PFPDF_PTRREC;
  FPDF_PAGEOBJECT         = type __PFPDF_PTRREC;  // (text, path, etc.)
  FPDF_PAGEOBJECTMARK     = type __PFPDF_PTRREC;
  FPDF_PAGERANGE          = type __PFPDF_PTRREC;
  FPDF_PATHSEGMENT        = type __PFPDF_PTRREC;
  FPDF_SCHHANDLE          = type __PFPDF_PTRREC;
  FPDF_SIGNATURE          = type __PFPDF_PTRREC;
  FPDF_SKIA_CANVAS        = type Pointer;  // Passed into Skia as an SkCanvas.
  FPDF_STRUCTELEMENT      = type __PFPDF_PTRREC;
  FPDF_STRUCTELEMENT_ATTR = type __PFPDF_PTRREC;
  FPDF_STRUCTTREE         = type __PFPDF_PTRREC;
  FPDF_TEXTPAGE           = type __PFPDF_PTRREC;
  FPDF_WIDGET             = type __PFPDF_PTRREC;
  FPDF_XOBJECT            = type __PFPDF_PTRREC;

  // Basic data types
  FPDF_BOOL  = Integer;
  FPDF_RESULT = Integer;
  FPDF_DWORD = LongWord;
  FS_FLOAT = Single;
  PFS_FLOAT = ^FS_FLOAT;

  // Duplex types
  FPDF_DUPLEXTYPE = (
    DuplexUndefined = 0,
    Simplex,
    DuplexFlipShortEdge,
    DuplexFlipLongEdge
  );

  // String types
  PFPDF_WCHAR = PWideChar;
  FPDF_WCHAR = WideChar;

  // The public PDFium API uses three types of strings: byte string, wide string
  // (UTF-16LE encoded), and platform dependent string.

  // Public PDFium API type for byte strings.
  FPDF_BYTESTRING = PAnsiChar;

  // The public PDFium API always uses UTF-16LE encoded wide strings, each
  // character uses 2 bytes (except surrogation), with the low byte first.
  FPDF_WIDESTRING = PFPDF_WCHAR;

  // Structure for persisting a string beyond the duration of a callback.
  // Note: although represented as a char*, string may be interpreted as
  // a UTF-16LE formated string. Used only by XFA callbacks.
  PFPDF_BSTR = ^FPDF_BSTR;
  FPDF_BSTR = record
    str: PAnsiChar; // String buffer, manipulate only with FPDF_BStr_* methods.
    len: Integer;   // Length of the string, in bytes.
  end;
  PFPdfBStr = ^TFPdfBStr;
  TFPdfBStr = FPDF_BSTR;

  // For Windows programmers: In most cases it's OK to treat FPDF_WIDESTRING as a
  // Windows unicode string, however, special care needs to be taken if you
  // expect to process Unicode larger than 0xffff.
  //
  // For Linux/Unix programmers: most compiler/library environments use 4 bytes
  // for a Unicode character, and you have to convert between FPDF_WIDESTRING and
  // system wide string by yourself.
  FPDF_STRING = PAnsiChar;

  // Matrix for transformation, in the form [a b c d e f], equivalent to:
  // | a  b  0 |
  // | c  d  0 |
  // | e  f  1 |
  //
  // Translation is performed with [1 0 0 1 tx ty].
  // Scaling is performed with [sx 0 0 sy 0 0].
  // See PDF Reference 1.7, 4.2.2 Common Transformations for more.
  PFS_MATRIX = ^FS_MATRIX;
  FS_MATRIX = record
    a: Single;
    b: Single;
    c: Single;
    d: Single;
    e: Single;
    f: Single;
  end;
  PFSMatrix = ^TFSMatrix;
  TFSMatrix = FS_MATRIX;

  // Rectangle area(float) in device or page coordinate system.
  PFS_RECTF = ^FS_RECTF;
  FS_RECTF = record
    // The x-coordinate of the left-top corner.
    left: Single;
    // The y-coordinate of the left-top corner.
    top: Single;
    // The x-coordinate of the right-bottom corner.
    right: Single;
    // The y-coordinate of the right-bottom corner.
    bottom: Single;
  end;
  // Const Pointer to FS_RECTF structure.
  FS_LPCRECTF = ^FS_RECTF;
  PFSRectF = ^TFSRectF;
  TFSRectF = FS_RECTF;

  // Rectangle size. Coordinate system agnostic.
  PFS_SIZEF = ^FS_SIZEF;
  FS_SIZEF = record
    width: Single;
    height: Single;
  end;
  PFSSizeF = ^TFSSizeF;
  TFSSizeF = FS_SIZEF;

  // Const Pointer to FS_SIZEF structure.
  PFS_POINTF = ^FS_POINTF;
  FS_POINTF = record
    x: Single;
    y: Single;
  end;
  PFSPointF = ^TFSPointF;
  TFSPointF = FS_POINTF;

  // Const Pointer to FS_POINTF structure.
  FS_LPCPOINTF = ^FS_POINTF;

  PFS_QUADPOINTSF = ^FS_QUADPOINTSF;
  FS_QUADPOINTSF = record
    x1: FS_FLOAT;
    y1: FS_FLOAT;
    x2: FS_FLOAT;
    y2: FS_FLOAT;
    x3: FS_FLOAT;
    y3: FS_FLOAT;
    x4: FS_FLOAT;
    y4: FS_FLOAT;
  end;
  PFSQuadPointsF = ^TFSQuadPointsF;
  TFSQuadPointsF = FS_QUADPOINTSF;

  // Annotation enums.
  FPDF_ANNOTATION_SUBTYPE = Integer;
  PFPDF_ANNOTATION_SUBTYPE = ^FPDF_ANNOTATION_SUBTYPE;
  FPDF_ANNOT_APPEARANCEMODE = Integer;

  // Dictionary value types.
  FPDF_OBJECT_TYPE = Integer;

// PDF renderer types - Experimental.
// Selection of 2D graphics library to use for rendering to FPDF_BITMAPs.
type
  FPDF_RENDERER_TYPE = Integer;
const
  // Anti-Grain Geometry - https://sourceforge.net/projects/agg/
  FPDF_RENDERERTYPE_AGG = 0;
  // Skia - https://skia.org/
  FPDF_RENDERERTYPE_SKIA = 1;

type
  // Process-wide options for initializing the library.
  PFPDF_LIBRARY_CONFIG = ^FPDF_LIBRARY_CONFIG;
  FPDF_LIBRARY_CONFIG = record
    // Version number of the interface. Currently must be 2.
    // Support for version 1 will be deprecated in the future.
    version: Integer;

    // Array of paths to scan in place of the defaults when using built-in
    // FXGE font loading code. The array is terminated by a NULL pointer.
    // The Array may be NULL itself to use the default paths. May be ignored
    // entirely depending upon the platform.
    m_pUserFontPaths: PPAnsiChar;

    // Version 2.

    // Pointer to the v8::Isolate to use, or NULL to force PDFium to create one.
    m_pIsolate: Pointer;

    // The embedder data slot to use in the v8::Isolate to store PDFium's
    // per-isolate data. The value needs to be in the range
    // [0, |v8::Internals::kNumIsolateDataLots|). Note that 0 is fine for most
    // embedders.
    m_v8EmbedderSlot: Cardinal;

    // Version 3 - Experimental.

    // Pointer to the V8::Platform to use.
    m_pPlatform: Pointer;

    // Version 4 - Experimental.

    // Explicit specification of core renderer to use. |m_RendererType| must be
    // a valid value for |FPDF_LIBRARY_CONFIG| versions of this level or higher,
    // or else the initialization will fail with an immediate crash.
    // Note that use of a specified |FPDF_RENDERER_TYPE| value for which the
    // corresponding render library is not included in the build will similarly
    // fail with an immediate crash.
    m_RendererType: FPDF_RENDERER_TYPE;
  end;
  PFPdfLibraryConfig = ^TFPdfLibraryConfig;
  TFPdfLibraryConfig = FPDF_LIBRARY_CONFIG;

// Function: FPDF_InitLibraryWithConfig
//          Initialize the PDFium library and allocate global resources for it.
// Parameters:
//          config - configuration information as above.
// Return value:
//          None.
// Comments:
//          You have to call this function before you can call any PDF
//          processing functions.
var
  FPDF_InitLibraryWithConfig: procedure(config: PFPDF_LIBRARY_CONFIG); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_InitLibrary
//          Initialize the PDFium library (alternative form).
// Parameters:
//          None
// Return value:
//          None.
// Comments:
//          Convenience function to call FPDF_InitLibraryWithConfig() with a
//          default configuration for backwards compatibility purposes. New
//          code should call FPDF_InitLibraryWithConfig() instead. This will
//          be deprecated in the future.
var
  FPDF_InitLibrary: procedure(); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_DestroyLibary
//          Release global resources allocated to the PDFium library by
//          FPDF_InitLibrary() or FPDF_InitLibraryWithConfig().
// Parameters:
//          None.
// Return value:
//          None.
// Comments:
//          After this function is called, you must not call any PDF
//          processing functions.
//
//          Calling this function does not automatically close other
//          objects. It is recommended to close other objects before
//          closing the library with this function.
var
  FPDF_DestroyLibrary: procedure(); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Policy for accessing the local machine time.
const
  FPDF_POLICY_MACHINETIME_ACCESS = 0;

// Function: FPDF_SetSandBoxPolicy
//          Set the policy for the sandbox environment.
// Parameters:
//          policy -   The specified policy for setting, for example:
//                     FPDF_POLICY_MACHINETIME_ACCESS.
//          enable -   True to enable, false to disable the policy.
// Return value:
//          None.
var
  FPDF_SetSandBoxPolicy: procedure(policy: FPDF_DWORD; enable: FPDF_BOOL); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

{$IFDEF MSWINDOWS}
// Experimental API.
// Function: FPDF_SetPrintMode
//          Set printing mode when printing on Windows.
// Parameters:
//          mode - FPDF_PRINTMODE_EMF to output EMF (default)
//                 FPDF_PRINTMODE_TEXTONLY to output text only (for charstream
//                 devices)
//                 FPDF_PRINTMODE_POSTSCRIPT2 to output level 2 PostScript into
//                 EMF as a series of GDI comments.
//                 FPDF_PRINTMODE_POSTSCRIPT3 to output level 3 PostScript into
//                 EMF as a series of GDI comments.
//                 FPDF_PRINTMODE_POSTSCRIPT2_PASSTHROUGH to output level 2
//                 PostScript via ExtEscape() in PASSTHROUGH mode.
//                 FPDF_PRINTMODE_POSTSCRIPT3_PASSTHROUGH to output level 3
//                 PostScript via ExtEscape() in PASSTHROUGH mode.
//                 FPDF_PRINTMODE_EMF_IMAGE_MASKS to output EMF, with more
//                 efficient processing of documents containing image masks.
//                 FPDF_PRINTMODE_POSTSCRIPT3_TYPE42 to output level 3
//                 PostScript with embedded Type 42 fonts, when applicable, into
//                 EMF as a series of GDI comments.
//                 FPDF_PRINTMODE_POSTSCRIPT3_TYPE42_PASSTHROUGH to output level
//                 3 PostScript with embedded Type 42 fonts, when applicable,
//                 via ExtEscape() in PASSTHROUGH mode.
// Return value:
//          True if successful, false if unsuccessful (typically invalid input).
var
  FPDF_SetPrintMode: function(mode: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
{$ENDIF MSWINDOWS}

// Function: FPDF_LoadDocument
//          Open and load a PDF document.
// Parameters:
//          file_path -  Path to the PDF file (including extension).
//          password  -  A string used as the password for the PDF file.
//                       If no password is needed, empty or NULL can be used.
//                       See comments below regarding the encoding.
// Return value:
//          A handle to the loaded document, or NULL on failure.
// Comments:
//          Loaded document can be closed by FPDF_CloseDocument().
//          If this function fails, you can use FPDF_GetLastError() to retrieve
//          the reason why it failed.
//
//          The encoding for |file_path| is UTF-8.
//
//          The encoding for |password| can be either UTF-8 or Latin-1. PDFs,
//          depending on the security handler revision, will only accept one or
//          the other encoding. If |password|'s encoding and the PDF's expected
//          encoding do not match, FPDF_LoadDocument() will automatically
//          convert |password| to the other encoding.
var
  FPDF_LoadDocument: function(file_path: FPDF_STRING; password: FPDF_BYTESTRING): FPDF_DOCUMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_LoadMemDocument
//          Open and load a PDF document from memory.
// Parameters:
//          data_buf    -   Pointer to a buffer containing the PDF document.
//          size        -   Number of bytes in the PDF document.
//          password    -   A string used as the password for the PDF file.
//                          If no password is needed, empty or NULL can be used.
// Return value:
//          A handle to the loaded document, or NULL on failure.
// Comments:
//          The memory buffer must remain valid when the document is open.
//          The loaded document can be closed by FPDF_CloseDocument.
//          If this function fails, you can use FPDF_GetLastError() to retrieve
//          the reason why it failed.
//
//          See the comments for FPDF_LoadDocument() regarding the encoding for
//          |password|.
// Notes:
//          If PDFium is built with the XFA module, the application should call
//          FPDF_LoadXFA() function after the PDF document loaded to support XFA
//          fields defined in the fpdfformfill.h file.
var
  FPDF_LoadMemDocument: function(data_buf: Pointer; size: Integer; password: FPDF_BYTESTRING): FPDF_DOCUMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_LoadMemDocument64
//          Open and load a PDF document from memory.
// Parameters:
//          data_buf    -   Pointer to a buffer containing the PDF document.
//          size        -   Number of bytes in the PDF document.
//          password    -   A string used as the password for the PDF file.
//                          If no password is needed, empty or NULL can be used.
// Return value:
//          A handle to the loaded document, or NULL on failure.
// Comments:
//          The memory buffer must remain valid when the document is open.
//          The loaded document can be closed by FPDF_CloseDocument.
//          If this function fails, you can use FPDF_GetLastError() to retrieve
//          the reason why it failed.
//
//          See the comments for FPDF_LoadDocument() regarding the encoding for
//          |password|.
// Notes:
//          If PDFium is built with the XFA module, the application should call
//          FPDF_LoadXFA() function after the PDF document loaded to support XFA
//          fields defined in the fpdfformfill.h file.
var
  FPDF_LoadMemDocument64: function(data_buf: Pointer; size: SIZE_T; password: FPDF_BYTESTRING): FPDF_DOCUMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Structure for custom file access.
type
  PFPDF_FILEACCESS = ^FPDF_FILEACCESS;
  FPDF_FILEACCESS = record
    // File length, in bytes.
    m_FileLen: LongWord;

    // A function pointer for getting a block of data from a specific position.
    // Position is specified by byte offset from the beginning of the file.
    // The pointer to the buffer is never NULL and the size is never 0.
    // The position and size will never go out of range of the file length.
    // It may be possible for PDFium to call this function multiple times for
    // the same position.
    // Return value: should be non-zero if successful, zero for error.
    m_GetBlock: function(param: Pointer; position: LongWord; pBuf: PByte; size: LongWord): Integer; cdecl;

    // A custom pointer for all implementation specific data.  This pointer will
    // be used as the first parameter to the m_GetBlock callback.
    m_Param: Pointer;
  end;
  PFPdfFileAccess = ^TFPdfFileAccess;
  TFPdfFileAccess = FPDF_FILEACCESS;

  //*
  //* Structure for file reading or writing (I/O).
  //*
  //* Note: This is a handler and should be implemented by callers,
  //*
  PFPDF_FILEHANDLER = ^FPDF_FILEHANDLER;
  FPDF_FILEHANDLER = record
    //*
    //* User-defined data.
    //* Node: Callers can use this field to track controls.
    //*
    clientData: Pointer;
    //*
    //* Callback function to release the current file stream object.
    //*
    //* Parameters:
    //*       clientData   -  Pointer to user-defined data.
    //* Returns:
    //*       None.
    //*
    Release: procedure(clientData: Pointer); cdecl;
    //*
    //* Callback function to retrieve the current file stream size.
    //*
    //* Parameters:
    //*       clientData   -  Pointer to user-defined data.
    //* Returns:
    //*       Size of file stream.
    //*
    GetSize: function(clientData: Pointer): FPDF_DWORD; cdecl;
    //*
    //* Callback function to read data from the current file stream.
    //*
    //* Parameters:
    //*       clientData   -  Pointer to user-defined data.
    //*       offset       -  Offset position starts from the beginning of file
    //*                       stream. This parameter indicates reading position.
    //*       buffer       -  Memory buffer to store data which are read from
    //*                       file stream. This parameter should not be NULL.
    //*       size         -  Size of data which should be read from file stream,
    //*                       in bytes. The buffer indicated by |buffer| must be
    //*                       large enough to store specified data.
    //* Returns:
    //*       0 for success, other value for failure.
    //*
    ReadBlock: function(clientData: Pointer; offset: FPDF_DWORD; buffer: Pointer; size: FPDF_DWORD): FPDF_RESULT; cdecl;
    //*
    //* Callback function to write data into the current file stream.
    //*
    //* Parameters:
    //*       clientData   -  Pointer to user-defined data.
    //*       offset       -  Offset position starts from the beginning of file
    //*                       stream. This parameter indicates writing position.
    //*       buffer       -  Memory buffer contains data which is written into
    //*                       file stream. This parameter should not be NULL.
    //*       size         -  Size of data which should be written into file
    //*                       stream, in bytes.
    //* Returns:
    //*       0 for success, other value for failure.
    //*
    WriteBlock: function(clientData: Pointer; offset: FPDF_DWORD; const buffer: Pointer; size: FPDF_DWORD): FPDF_RESULT; cdecl;
    //**
    //* Callback function to flush all internal accessing buffers.
    //*
    //* Parameters:
    //*       clientData   -  Pointer to user-defined data.
    //* Returns:
    //*       0 for success, other value for failure.
    //*
    Flush: function(clientData: Pointer): FPDF_RESULT; cdecl;
    //**
    //* Callback function to change file size.
    //*
    //* Description:
    //*       This function is called under writing mode usually. Implementer
    //*       can determine whether to realize it based on application requests.
    //* Parameters:
    //*       clientData   -  Pointer to user-defined data.
    //*       size         -  New size of file stream, in bytes.
    //* Returns:
    //*       0 for success, other value for failure.
    //*
    Truncate: function(clientData: Pointer; size: FPDF_DWORD): FPDF_RESULT; cdecl;
  end;
  PFPdfFileHandler = ^TFPdfFileHandler;
  TFPdfFileHandler = FPDF_FILEHANDLER;

// Function: FPDF_LoadCustomDocument
//          Load PDF document from a custom access descriptor.
// Parameters:
//          pFileAccess -   A structure for accessing the file.
//          password    -   Optional password for decrypting the PDF file.
// Return value:
//          A handle to the loaded document, or NULL on failure.
// Comments:
//          The application must keep the file resources |pFileAccess| points to
//          valid until the returned FPDF_DOCUMENT is closed. |pFileAccess|
//          itself does not need to outlive the FPDF_DOCUMENT.
//
//          The loaded document can be closed with FPDF_CloseDocument().
//
//          See the comments for FPDF_LoadDocument() regarding the encoding for
//          |password|.
// Notes:
//          If PDFium is built with the XFA module, the application should call
//          FPDF_LoadXFA() function after the PDF document loaded to support XFA
//          fields defined in the fpdfformfill.h file.
var
  FPDF_LoadCustomDocument: function(pFileAccess: PFPDF_FILEACCESS; password: FPDF_BYTESTRING): FPDF_DOCUMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetFileVersion
//          Get the file version of the given PDF document.
// Parameters:
//          doc         -   Handle to a document.
//          fileVersion -   The PDF file version. File version: 14 for 1.4, 15 for 1.5, ...
// Return value:
//          True if succeeds, false otherwise.
// Comments:
//          If the document was created by FPDF_CreateNewDocument,
//          then this function will always fail.
var
  FPDF_GetFileVersion: function(doc: FPDF_DOCUMENT; var fileVersion: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

const
  FPDF_ERR_SUCCESS   = 0;    // No error.
  FPDF_ERR_UNKNOWN   = 1;    // Unknown error.
  FPDF_ERR_FILE      = 2;    // File not found or could not be opened.
  FPDF_ERR_FORMAT    = 3;    // File not in PDF format or corrupted.
  FPDF_ERR_PASSWORD  = 4;    // Password required or incorrect password.
  FPDF_ERR_SECURITY  = 5;    // Unsupported security scheme.
  FPDF_ERR_PAGE      = 6;    // Page not found or content error.
{$IFDEF PDF_ENABLE_XFA}
  FPDF_ERR_XFALOAD   = 7;    // Load XFA error.
  FPDF_ERR_XFALAYOUT = 8;    // Layout XFA error.
{$ENDIF PDF_ENABLE_XFA}

// Function: FPDF_GetLastError
//          Get last error code when a function fails.
// Parameters:
//          None.
// Return value:
//          A 32-bit integer indicating error code as defined above.
// Comments:
//          If the previous SDK call succeeded, the return value of this
//          function is not defined. This function only works in conjunction
//          with APIs that mention FPDF_GetLastError() in their documentation.
var
  FPDF_GetLastError: function(): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_DocumentHasValidCrossReferenceTable
//          Whether the document's cross reference table is valid or not.
// Parameters:
//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
// Return value:
//          True if the PDF parser did not encounter problems parsing the cross
//          reference table. False if the parser could not parse the cross
//          reference table and the table had to be rebuild from other data
//          within the document.
// Comments:
//          The return value can change over time as the PDF parser evolves.
var
  FPDF_DocumentHasValidCrossReferenceTable: function(document: FPDF_DOCUMENT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_GetTrailerEnds
//          Get the byte offsets of trailer ends.
// Parameters:
//          document    -   Handle to document. Returned by FPDF_LoadDocument().
//          buffer      -   The address of a buffer that receives the
//                          byte offsets.
//          length      -   The size, in ints, of |buffer|.
// Return value:
//          Returns the number of ints in the buffer on success, 0 on error.
//
// |buffer| is an array of integers that describes the exact byte offsets of the
// trailer ends in the document. If |length| is less than the returned length,
// or |document| or |buffer| is NULL, |buffer| will not be modified.
var
  FPDF_GetTrailerEnds: function(document: FPDF_DOCUMENT; buffer: PUINT; length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetDocPermissions
//          Get file permission flags of the document.
// Parameters:
//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
// Return value:
//          A 32-bit integer indicating permission flags. Please refer to the
//          PDF Reference for detailed descriptions. If the document is not
//          protected or was unlocked by the owner, 0xffffffff will be returned.
var
  FPDF_GetDocPermissions: function(document: FPDF_DOCUMENT): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetDocUserPermissions
//          Get user file permission flags of the document.
// Parameters:
//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
// Return value:
//          A 32-bit integer indicating permission flags. Please refer to the
//          PDF Reference for detailed descriptions. If the document is not
//          protected, 0xffffffff will be returned. Always returns user
//          permissions, even if the document was unlocked by the owner.
var
  FPDF_GetDocUserPermissions: function(document: FPDF_DOCUMENT): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetSecurityHandlerRevision
//          Get the revision for the security handler.
// Parameters:
//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
// Return value:
//          The security handler revision number. Please refer to the PDF
//          Reference for a detailed description. If the document is not
//          protected, -1 will be returned.
var
  FPDF_GetSecurityHandlerRevision: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetPageCount
//          Get total number of pages in the document.
// Parameters:
//          document    -   Handle to document. Returned by FPDF_LoadDocument.
// Return value:
//          Total number of pages in the document.
var
  FPDF_GetPageCount: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_LoadPage
//          Load a page inside the document.
// Parameters:
//          document    -   Handle to document. Returned by FPDF_LoadDocument
//          page_index  -   Index number of the page. 0 for the first page.
// Return value:
//          A handle to the loaded page, or NULL if page load fails.
// Comments:
//          The loaded page can be rendered to devices using FPDF_RenderPage.
//          The loaded page can be closed using FPDF_ClosePage.
var
  FPDF_LoadPage: function(document: FPDF_DOCUMENT; page_index: Integer): FPDF_PAGE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API
// Function: FPDF_GetPageWidthF
//          Get page width.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage().
// Return value:
//          Page width (excluding non-displayable area) measured in points.
//          One point is 1/72 inch (around 0.3528 mm).
var
  FPDF_GetPageWidthF: function(page: FPDF_PAGE): Single; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// Function: FPDF_GetPageWidth
//          Get page width.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
// Return value:
//          Page width (excluding non-displayable area) measured in points.
//          One point is 1/72 inch (around 0.3528 mm).
// Note:
//          Prefer FPDF_GetPageWidthF() above. This will be deprecated in the
//          future.
var
  FPDF_GetPageWidth: function(page: FPDF_PAGE): Double; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API
// Function: FPDF_GetPageHeightF
//          Get page height.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage().
// Return value:
//          Page height (excluding non-displayable area) measured in points.
//          One point is 1/72 inch (around 0.3528 mm)
var
  FPDF_GetPageHeightF: function(page: FPDF_PAGE): Single; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetPageHeight
//          Get page height.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
// Return value:
//          Page height (excluding non-displayable area) measured in points.
//          One point is 1/72 inch (around 0.3528 mm)
// Note:
//          Prefer FPDF_GetPageHeightF() above. This will be deprecated in the
//          future.
var
  FPDF_GetPageHeight: function(page: FPDF_PAGE): Double; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_GetPageBoundingBox
//          Get the bounding box of the page. This is the intersection between
//          its media box and its crop box.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
//          rect        -   Pointer to a rect to receive the page bounding box.
//                          On an error, |rect| won't be filled.
// Return value:
//          True for success.
var
  FPDF_GetPageBoundingBox: function(page: FPDF_PAGE; rect: PFS_RECTF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_GetPageSizeByIndexF
//          Get the size of the page at the given index.
// Parameters:
//          document    -   Handle to document. Returned by FPDF_LoadDocument().
//          page_index  -   Page index, zero for the first page.
//          size        -   Pointer to a FS_SIZEF to receive the page size.
//                          (in points).
// Return value:
//          Non-zero for success. 0 for error (document or page not found).
var
  FPDF_GetPageSizeByIndexF: function(document: FPDF_DOCUMENT; page_index: Integer; size: PFS_SIZEF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetPageSizeByIndex
//          Get the size of the page at the given index.
// Parameters:
//          document    -   Handle to document. Returned by FPDF_LoadDocument.
//          page_index  -   Page index, zero for the first page.
//          width       -   Pointer to a double to receive the page width
//                          (in points).
//          height      -   Pointer to a double to receive the page height
//                          (in points).
// Return value:
//          Non-zero for success. 0 for error (document or page not found).
// Note:
//          Prefer FPDF_GetPageSizeByIndexF() above. This will be deprecated in
//          the future.
var
  FPDF_GetPageSizeByIndex: function(document: FPDF_DOCUMENT; page_index: Integer; var width, height: Double): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Page rendering flags. They can be combined with bit-wise OR.
const
  FPDF_ANNOT                    = $01;   // Set if annotations are to be rendered.
  FPDF_LCD_TEXT                 = $02;   // Set if using text rendering optimized for LCD display. This flag will only take effect if anti-aliasing is enabled for text.
  FPDF_NO_NATIVETEXT            = $04;   // Don't use the native text output available on some platforms
  FPDF_GRAYSCALE                = $08 deprecated; // Obsolete, has no effect, retained for compatibility.
  FPDF_DEBUG_INFO               = $80 deprecated; // Obsolete, has no effect, retained for compatibility.
  FPDF_NO_CATCH                 = $100;  // Set if you don't want to catch exceptions.
  FPDF_RENDER_LIMITEDIMAGECACHE = $200;  // Limit image cache size.
  FPDF_RENDER_FORCEHALFTONE     = $400;  // Always use halftone for image stretching.
  FPDF_PRINTING                 = $800;  // Render for printing.
  FPDF_RENDER_NO_SMOOTHTEXT     = $1000; // Set to disable anti-aliasing on text. This flag will also disable LCD optimization for text rendering.
  FPDF_RENDER_NO_SMOOTHIMAGE    = $2000; // Set to disable anti-aliasing on images.
  FPDF_RENDER_NO_SMOOTHPATH     = $4000; // Set to disable anti-aliasing on paths.
  // Set whether to render in a reverse Byte order, this flag is only used when
  // rendering to a bitmap.
  FPDF_REVERSE_BYTE_ORDER       = $10;
  // Set whether fill paths need to be stroked. This flag is only used when
  // FPDF_COLORSCHEME is passed in, since with a single fill color for paths the
  // boundaries of adjacent fill paths are less visible.
  FPDF_CONVERT_FILL_TO_STROKE   = $20;

type
  // Struct for color scheme.
  // Each should be a 32-bit value specifying the color, in 8888 ARGB format.

  PFPDF_COLORSCHEME = ^FPDF_COLORSCHEME;
  FPDF_COLORSCHEME = record
    path_fill_color: FPDF_DWORD;
    path_stroke_color: FPDF_DWORD;
    text_fill_color: FPDF_DWORD;
    text_stroke_color: FPDF_DWORD;
  end;
  PFPdfColorScheme = ^TFPdfColorScheme;
  TFPdfColorScheme = FPDF_COLORSCHEME;

{$IFDEF MSWINDOWS}
// Function: FPDF_RenderPage
//          Render contents of a page to a device (screen, bitmap, or printer).
//          This function is only supported on Windows.
// Parameters:
//          dc          -   Handle to the device context.
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
//          start_x     -   Left pixel position of the display area in
//                          device coordinates.
//          start_y     -   Top pixel position of the display area in device
//                          coordinates.
//          size_x      -   Horizontal size (in pixels) for displaying the page.
//          size_y      -   Vertical size (in pixels) for displaying the page.
//          rotate      -   Page orientation:
//                            0 (normal)
//                            1 (rotated 90 degrees clockwise)
//                            2 (rotated 180 degrees)
//                            3 (rotated 90 degrees counter-clockwise)
//          flags       -   0 for normal display, or combination of flags
//                          defined above.
// Return value:
//          None.
var
  FPDF_RenderPage: procedure(DC: HDC; page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer;
    rotate: Integer; flags: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
{$ENDIF MSWINDOWS}

// Function: FPDF_RenderPageBitmap
//          Render contents of a page to a device independent bitmap.
// Parameters:
//          bitmap      -   Handle to the device independent bitmap (as the
//                          output buffer). The bitmap handle can be created
//                          by FPDFBitmap_Create or retrieved from an image
//                          object by FPDFImageObj_GetBitmap.
//          page        -   Handle to the page. Returned by FPDF_LoadPage
//          start_x     -   Left pixel position of the display area in
//                          bitmap coordinates.
//          start_y     -   Top pixel position of the display area in bitmap
//                          coordinates.
//          size_x      -   Horizontal size (in pixels) for displaying the page.
//          size_y      -   Vertical size (in pixels) for displaying the page.
//          rotate      -   Page orientation:
//                            0 (normal)
//                            1 (rotated 90 degrees clockwise)
//                            2 (rotated 180 degrees)
//                            3 (rotated 90 degrees counter-clockwise)
//          flags       -   0 for normal display, or combination of the Page
//                          Rendering flags defined above. With the FPDF_ANNOT
//                          flag, it renders all annotations that do not require
//                          user-interaction, which are all annotations except
//                          widget and popup annotations.
// Return value:
//          None.
var
  FPDF_RenderPageBitmap: procedure(bitmap: FPDF_BITMAP; page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer;
    rotate: Integer; flags: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_RenderPageBitmapWithMatrix
//          Render contents of a page to a device independent bitmap.
// Parameters:
//          bitmap      -   Handle to the device independent bitmap (as the
//                          output buffer). The bitmap handle can be created
//                          by FPDFBitmap_Create or retrieved by
//                          FPDFImageObj_GetBitmap.
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
//          matrix      -   The transform matrix, which must be invertible.
//                          See PDF Reference 1.7, 4.2.2 Common Transformations.
//          clipping    -   The rect to clip to in device coords.
//          flags       -   0 for normal display, or combination of the Page
//                          Rendering flags defined above. With the FPDF_ANNOT
//                          flag, it renders all annotations that do not require
//                          user-interaction, which are all annotations except
//                          widget and popup annotations.
// Return value:
//          None. Note that behavior is undefined if det of |matrix| is 0.
var
  FPDF_RenderPageBitmapWithMatrix: procedure(bitmap: FPDF_BITMAP; page: FPDF_PAGE; matrix: PFS_MATRIX;
    clipping: PFS_RECTF; flags: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

{$IFDEF _SKIA_SUPPORT_}
// Function: FPDF_RenderPageSkia
//          Render contents of a page to a Skia SkCanvas.
// Parameters:
//          canvas      -   SkCanvas to render to.
//          page        -   Handle to the page.
//          size_x      -   Horizontal size (in pixels) for displaying the page.
//          size_y      -   Vertical size (in pixels) for displaying the page.
// Return value:
//          None.
var
  FPDF_RenderPageSkia: procedure(canvas: FPDF_SKIA_CANVAS; page: FPDF_PAGE; size_x, size_y: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
{$ENDIF _SKIA_SUPPORT_}

// Function: FPDF_ClosePage
//          Close a loaded PDF page.
// Parameters:
//          page        -   Handle to the loaded page.
// Return value:
//          None.
var
  FPDF_ClosePage: procedure(page: FPDF_PAGE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_CloseDocument
//          Close a loaded PDF document.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          None.
var
  FPDF_CloseDocument: procedure(document: FPDF_DOCUMENT); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_DeviceToPage
//          Convert the screen coordinates of a point to page coordinates.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
//          start_x     -   Left pixel position of the display area in
//                          device coordinates.
//          start_y     -   Top pixel position of the display area in device
//                          coordinates.
//          size_x      -   Horizontal size (in pixels) for displaying the page.
//          size_y      -   Vertical size (in pixels) for displaying the page.
//          rotate      -   Page orientation:
//                            0 (normal)
//                            1 (rotated 90 degrees clockwise)
//                            2 (rotated 180 degrees)
//                            3 (rotated 90 degrees counter-clockwise)
//          device_x    -   X value in device coordinates to be converted.
//          device_y    -   Y value in device coordinates to be converted.
//          page_x      -   A pointer to a double receiving the converted X
//                          value in page coordinates.
//          page_y      -   A pointer to a double receiving the converted Y
//                          value in page coordinates.
// Return value:
//          Returns true if the conversion succeeds, and |page_x| and |page_y|
//          successfully receives the converted coordinates.
// Comments:
//          The page coordinate system has its origin at the left-bottom corner
//          of the page, with the X-axis on the bottom going to the right, and
//          the Y-axis on the left side going up.
//
//          NOTE: this coordinate system can be altered when you zoom, scroll,
//          or rotate a page, however, a point on the page should always have
//          the same coordinate values in the page coordinate system.
//
//          The device coordinate system is device dependent. For screen device,
//          its origin is at the left-top corner of the window. However this
//          origin can be altered by the Windows coordinate transformation
//          utilities.
//
//          You must make sure the start_x, start_y, size_x, size_y
//          and rotate parameters have exactly same values as you used in
//          the FPDF_RenderPage() function call.
var
  FPDF_DeviceToPage: procedure(page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer;
    rotate: Integer; device_x, device_y: Integer; var page_x, page_y: Double); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_PageToDevice
//          Convert the page coordinates of a point to screen coordinates.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
//          start_x     -   Left pixel position of the display area in
//                          device coordinates.
//          start_y     -   Top pixel position of the display area in device
//                          coordinates.
//          size_x      -   Horizontal size (in pixels) for displaying the page.
//          size_y      -   Vertical size (in pixels) for displaying the page.
//          rotate      -   Page orientation:
//                            0 (normal)
//                            1 (rotated 90 degrees clockwise)
//                            2 (rotated 180 degrees)
//                            3 (rotated 90 degrees counter-clockwise)
//          page_x      -   X value in page coordinates.
//          page_y      -   Y value in page coordinate.
//          device_x    -   A pointer to an integer receiving the result X
//                          value in device coordinates.
//          device_y    -   A pointer to an integer receiving the result Y
//                          value in device coordinates.
// Return value:
//          Returns true if the conversion succeeds, and |device_x| and
//          |device_y| successfully receives the converted coordinates.
// Comments:
//          See comments for FPDF_DeviceToPage().
var
  FPDF_PageToDevice: procedure(page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer;
    rotate: Integer; page_x, page_y: Double; var device_x, device_y: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFBitmap_Create
//          Create a device independent bitmap (FXDIB).
// Parameters:
//          width       -   The number of pixels in width for the bitmap.
//                          Must be greater than 0.
//          height      -   The number of pixels in height for the bitmap.
//                          Must be greater than 0.
//          alpha       -   A flag indicating whether the alpha channel is used.
//                          Non-zero for using alpha, zero for not using.
// Return value:
//          The created bitmap handle, or NULL if a parameter error or out of
//          memory.
// Comments:
//          The bitmap always uses 4 bytes per pixel. The first byte is always
//          double word aligned.
//
//          The byte order is BGRx (the last byte unused if no alpha channel) or
//          BGRA.
//
//          The pixels in a horizontal line are stored side by side, with the
//          left most pixel stored first (with lower memory address).
//          Each line uses width * 4 bytes.
//
//          Lines are stored one after another, with the top most line stored
//          first. There is no gap between adjacent lines.
//
//          This function allocates enough memory for holding all pixels in the
//          bitmap, but it doesn't initialize the buffer. Applications can use
//          FPDFBitmap_FillRect() to fill the bitmap using any color. If the OS
//          allows it, this function can allocate up to 4 GB of memory.
  FPDFBitmap_Create: function(width, height: Integer; alpha: Integer): FPDF_BITMAP; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


const
  // More DIB formats
  FPDFBitmap_Unknown = 0; // Unknown or unsupported format.
  FPDFBitmap_Gray    = 1; // Gray scale bitmap, one byte per pixel.
  FPDFBitmap_BGR     = 2; // 3 bytes per pixel, byte order: blue, green, red.
  FPDFBitmap_BGRx    = 3; // 4 bytes per pixel, byte order: blue, green, red, unused.
  FPDFBitmap_BGRA    = 4; // 4 bytes per pixel, byte order: blue, green, red, alpha.

// Function: FPDFBitmap_CreateEx
//          Create a device independent bitmap (FXDIB)
// Parameters:
//          width       -   The number of pixels in width for the bitmap.
//                          Must be greater than 0.
//          height      -   The number of pixels in height for the bitmap.
//                          Must be greater than 0.
//          format      -   A number indicating for bitmap format, as defined
//                          above.
//          first_scan  -   A pointer to the first byte of the first line if
//                          using an external buffer. If this parameter is NULL,
//                          then the a new buffer will be created.
//                          then a new buffer will be created.
//          stride      -   Number of bytes for each scan line. The value must
//                          be 0 or greater. When the value is 0,
//                          FPDFBitmap_CreateEx() will automatically calculate
//                          the appropriate value using |width| and |format|.
//                          When using an external buffer, it is recommended for
//                          the caller to pass in the value.
//                          When not using an external buffer, it is recommended
//                          for the caller to pass in 0.
// Return value:
//          The bitmap handle, or NULL if parameter error or out of memory.
// Comments:
//          Similar to FPDFBitmap_Create function, but allows for more formats
//          and an external buffer is supported. The bitmap created by this
//          function can be used in any place that a FPDF_BITMAP handle is
//          required.
//
//          If an external buffer is used, then the caller should destroy the
//          buffer. FPDFBitmap_Destroy() will not destroy the buffer.
//
//          It is recommended to use FPDFBitmap_GetStride() to get the stride
//          value.
var
  FPDFBitmap_CreateEx: function(width, height: Integer; format: Integer; first_scan: Pointer;
    stride: Integer): FPDF_BITMAP; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFBitmap_GetFormat
//          Get the format of the bitmap.
// Parameters:
//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
//                          or FPDFImageObj_GetBitmap.
// Return value:
//          The format of the bitmap.
// Comments:
//          Only formats supported by FPDFBitmap_CreateEx are supported by this
//          function; see the list of such formats above.
var
  FPDFBitmap_GetFormat: function(bitmap: FPDF_BITMAP): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFBitmap_FillRect
//          Fill a rectangle in a bitmap.
// Parameters:
//          bitmap      -   The handle to the bitmap. Returned by
//                          FPDFBitmap_Create.
//          left        -   The left position. Starting from 0 at the
//                          left-most pixel.
//          top         -   The top position. Starting from 0 at the
//                          top-most line.
//          width       -   Width in pixels to be filled.
//          height      -   Height in pixels to be filled.
//          color       -   A 32-bit value specifing the color, in 8888 ARGB
//                          format.
// Return value:
//          None.
// Comments:
//          This function sets the color and (optionally) alpha value in the
//          specified region of the bitmap.
//
//          NOTE: If the alpha channel is used, this function does NOT
//          composite the background with the source color, instead the
//          background will be replaced by the source color and the alpha.
//
//          If the alpha channel is not used, the alpha parameter is ignored.
var
  FPDFBitmap_FillRect: procedure(bitmap: FPDF_BITMAP; left, top, width, height: Integer; color: FPDF_DWORD); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFBitmap_GetBuffer
//          Get data buffer of a bitmap.
// Parameters:
//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
//                          or FPDFImageObj_GetBitmap.
// Return value:
//          The pointer to the first byte of the bitmap buffer.
// Comments:
//          The stride may be more than width * number of bytes per pixel
//
//          Applications can use this function to get the bitmap buffer pointer,
//          then manipulate any color and/or alpha values for any pixels in the
//          bitmap.
//
//          Use FPDFBitmap_GetFormat() to find out the format of the data.
var
  FPDFBitmap_GetBuffer: function(bitmap: FPDF_BITMAP): Pointer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFBitmap_GetWidth
//          Get width of a bitmap.
// Parameters:
//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
//                          or FPDFImageObj_GetBitmap.
// Return value:
//          The width of the bitmap in pixels.
var
  FPDFBitmap_GetWidth: function(bitmap: FPDF_BITMAP): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFBitmap_GetHeight
//          Get height of a bitmap.
// Parameters:
//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
//                          or FPDFImageObj_GetBitmap.
// Return value:
//          The height of the bitmap in pixels.
var
  FPDFBitmap_GetHeight: function(bitmap: FPDF_BITMAP): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFBitmap_GetStride
//          Get number of bytes for each line in the bitmap buffer.
// Parameters:
//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
//                          or FPDFImageObj_GetBitmap.
// Return value:
//          The number of bytes for each line in the bitmap buffer.
// Comments:
//          The stride may be more than width * number of bytes per pixel.
var
  FPDFBitmap_GetStride: function(bitmap: FPDF_BITMAP): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFBitmap_Destroy
//          Destroy a bitmap and release all related buffers.
// Parameters:
//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
//                          or FPDFImageObj_GetBitmap.
// Return value:
//          None.
// Comments:
//          This function will not destroy any external buffers provided when
//          the bitmap was created.
var
  FPDFBitmap_Destroy: procedure(bitmap: FPDF_BITMAP); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_VIEWERREF_GetPrintScaling
//          Whether the PDF document prefers to be scaled or not.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          None.
var
  FPDF_VIEWERREF_GetPrintScaling: function(document: FPDF_DOCUMENT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_VIEWERREF_GetNumCopies
//          Returns the number of copies to be printed.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          The number of copies to be printed.
var
  FPDF_VIEWERREF_GetNumCopies: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_VIEWERREF_GetPrintPageRange
//          Page numbers to initialize print dialog box when file is printed.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          The print page range to be used for printing.
var
  FPDF_VIEWERREF_GetPrintPageRange: function(document: FPDF_DOCUMENT): FPDF_PAGERANGE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_VIEWERREF_GetPrintPageRangeCount
//          Returns the number of elements in a FPDF_PAGERANGE.
// Parameters:
//          pagerange   -   Handle to the page range.
// Return value:
//          The number of elements in the page range. Returns 0 on error.
var
  FPDF_VIEWERREF_GetPrintPageRangeCount: function(pagerange: FPDF_PAGERANGE): SIZE_T; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_VIEWERREF_GetPrintPageRangeElement
//          Returns an element from a FPDF_PAGERANGE.
// Parameters:
//          pagerange   -   Handle to the page range.
//          index       -   Index of the element.
// Return value:
//          The value of the element in the page range at a given index.
//          Returns -1 on error.
var
  FPDF_VIEWERREF_GetPrintPageRangeElement: function(pagerange: FPDF_PAGERANGE; index: SIZE_T): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_VIEWERREF_GetDuplex
//          Returns the paper handling option to be used when printing from
//          the print dialog.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          The paper handling option to be used when printing.
var
  FPDF_VIEWERREF_GetDuplex: function(document: FPDF_DOCUMENT): FPDF_DUPLEXTYPE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_VIEWERREF_GetName
//          Gets the contents for a viewer ref, with a given key. The value must
//          be of type "name".
// Parameters:
//          document    -   Handle to the loaded document.
//          key         -   Name of the key in the viewer pref dictionary,
//                          encoded in UTF-8.
//          buffer      -   A string to write the contents of the key to.
//          length      -   Length of the buffer.
// Return value:
//          The number of bytes in the contents, including the NULL terminator.
//          Thus if the return value is 0, then that indicates an error, such
//          as when |document| is invalid or |buffer| is NULL. If |length| is
//          less than the returned length, or |buffer| is NULL, |buffer| will
//          not be modified.
var
  FPDF_VIEWERREF_GetName: function(document: FPDF_DOCUMENT; key: FPDF_BYTESTRING; buffer: PAnsiChar;
    length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_CountNamedDests
//          Get the count of named destinations in the PDF document.
// Parameters:
//          document    -   Handle to a document
// Return value:
//          The count of named destinations.
var
  FPDF_CountNamedDests: function(document: FPDF_DOCUMENT): FPDF_DWORD; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetNamedDestByName
//          Get a the destination handle for the given name.
// Parameters:
//          document    -   Handle to the loaded document.
//          name        -   The name of a destination.
// Return value:
//          The handle to the destination.
var
  FPDF_GetNamedDestByName: function(document: FPDF_DOCUMENT; name: FPDF_BYTESTRING): FPDF_DEST; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_GetNamedDest
//          Get the named destination by index.
// Parameters:
//          document        -   Handle to a document
//          index           -   The index of a named destination.
//          buffer          -   The buffer to store the destination name,
//                              used as wchar_t*.
//          buflen [in/out] -   Size of the buffer in bytes on input,
//                              length of the result in bytes on output
//                              or -1 if the buffer is too small.
// Return value:
//          The destination handle for a given index, or NULL if there is no
//          named destination corresponding to |index|.
// Comments:
//          Call this function twice to get the name of the named destination:
//            1) First time pass in |buffer| as NULL and get buflen.
//            2) Second time pass in allocated |buffer| and buflen to retrieve
//               |buffer|, which should be used as wchar_t*.
//
//         If buflen is not sufficiently large, it will be set to -1 upon
//         return.
var
  FPDF_GetNamedDest: function(document: FPDF_DOCUMENT; index: Integer; buffer: Pointer; var buflen: LongWord): FPDF_DEST; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_GetXFAPacketCount
//          Get the number of valid packets in the XFA entry.
// Parameters:
//          document - Handle to the document.
// Return value:
//          The number of valid packets, or -1 on error.
var
  FPDF_GetXFAPacketCount: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_GetXFAPacketName
//          Get the name of a packet in the XFA array.
// Parameters:
//          document - Handle to the document.
//          index    - Index number of the packet. 0 for the first packet.
//          buffer   - Buffer for holding the name of the XFA packet.
//          buflen   - Length of |buffer| in bytes.
// Return value:
//          The length of the packet name in bytes, or 0 on error.
//
// |document| must be valid and |index| must be in the range [0, N), where N is
// the value returned by FPDF_GetXFAPacketCount().
// |buffer| is only modified if it is non-NULL and |buflen| is greater than or
// equal to the length of the packet name. The packet name includes a
// terminating NUL character. |buffer| is unmodified on error.
var
  FPDF_GetXFAPacketName: function(document: FPDF_DOCUMENT; index: Integer; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_GetXFAPacketContent
//          Get the content of a packet in the XFA array.
// Parameters:
//          document   - Handle to the document.
//          index      - Index number of the packet. 0 for the first packet.
//          buffer     - Buffer for holding the content of the XFA packet.
//          buflen     - Length of |buffer| in bytes.
//          out_buflen - Pointer to the variable that will receive the minimum
//                       buffer size needed to contain the content of the XFA
//                       packet.
// Return value:
//          Whether the operation succeeded or not.
//
// |document| must be valid and |index| must be in the range [0, N), where N is
// the value returned by FPDF_GetXFAPacketCount(). |out_buflen| must not be
// NULL. When the aforementioned arguments are valid, the operation succeeds,
// and |out_buflen| receives the content size. |buffer| is only modified if
// |buffer| is non-null and long enough to contain the content. Callers must
// check both the return value and the input |buflen| is no less than the
// returned |out_buflen| before using the data in |buffer|.
var
  FPDF_GetXFAPacketContent: function(document: FPDF_DOCUMENT; index: Integer; buffer: Pointer;
    buflen: LongWord; var out_buflen: LongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

{$IFDEF PDF_ENABLE_V8}
// Function: FPDF_GetRecommendedV8Flags
//          Returns a space-separated string of command line flags that are
//          recommended to be passed into V8 via V8::SetFlagsFromString()
//          prior to initializing the PDFium library.
// Parameters:
//          None.
// Return value:
//          NUL-terminated string of the form "--flag1 --flag2".
//          The caller must not attempt to modify or free the result.
var
  FPDF_GetRecommendedV8Flags: function: PAnsiChar; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_GetArrayBufferAllocatorSharedInstance()
//          Helper function for initializing V8 isolates that will
//          use PDFium's internal memory management.
// Parameters:
//          None.
// Return Value:
//          Pointer to a suitable v8::ArrayBuffer::Allocator, returned
//          as void for C compatibility.
// Notes:
//          Use is optional, but allows external creation of isolates
//          matching the ones PDFium will make when none is provided
//          via |FPDF_LIBRARY_CONFIG::m_pIsolate|.
var
  FPDF_GetArrayBufferAllocatorSharedInstance: function: Pointer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
{$ENDIF PDF_ENABLE_V8}

{$IFDEF PDF_ENABLE_XFA}
// Function: FPDF_BStr_Init
//          Helper function to initialize a FPDF_BSTR.
var
  FPDF_BStr_Init: function(bstr: PFPDF_BSTR): FPDF_RESULT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_BStr_Set
//          Helper function to copy string data into the FPDF_BSTR.
var
  FPDF_BStr_Set: function(vstr: PFPDF_BSTR; const cstr: PAnsiChar; length: Integer): FPDF_RESULT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_BStr_Clear
//          Helper function to clear a FPDF_BSTR.
var
  FPDF_BStr_Clear: function(bstr: PFPDF_BSTR): FPDF_RESULT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
{$ENDIF PDF_ENABLE_XFA}


// *** _FPDFEDIT_H_ ***

function FPDF_ARGB(a, r, g, b: Byte): DWORD; inline;
function FPDF_GetBValue(argb: DWORD): Byte; inline;
function FPDF_GetGValue(argb: DWORD): Byte; inline;
function FPDF_GetRValue(argb: DWORD): Byte; inline;
function FPDF_GetAValue(argb: DWORD): Byte; inline;


const
  // Refer to PDF Reference version 1.7 table 4.12 for all color space families.
  FPDF_COLORSPACE_UNKNOWN = 0;
  FPDF_COLORSPACE_DEVICEGRAY = 1;
  FPDF_COLORSPACE_DEVICERGB = 2;
  FPDF_COLORSPACE_DEVICECMYK = 3;
  FPDF_COLORSPACE_CALGRAY = 4;
  FPDF_COLORSPACE_CALRGB = 5;
  FPDF_COLORSPACE_LAB = 6;
  FPDF_COLORSPACE_ICCBASED = 7;
  FPDF_COLORSPACE_SEPARATION = 8;
  FPDF_COLORSPACE_DEVICEN = 9;
  FPDF_COLORSPACE_INDEXED = 10;
  FPDF_COLORSPACE_PATTERN = 11;

  // The page object constants.
  FPDF_PAGEOBJ_UNKNOWN = 0;
  FPDF_PAGEOBJ_TEXT = 1;
  FPDF_PAGEOBJ_PATH = 2;
  FPDF_PAGEOBJ_IMAGE = 3;
  FPDF_PAGEOBJ_SHADING = 4;
  FPDF_PAGEOBJ_FORM = 5;

  // The path segment constants.
  FPDF_SEGMENT_UNKNOWN = -1;
  FPDF_SEGMENT_LINETO = 0;
  FPDF_SEGMENT_BEZIERTO = 1;
  FPDF_SEGMENT_MOVETO = 2;

  FPDF_FILLMODE_NONE = 0;
  FPDF_FILLMODE_ALTERNATE = 1;
  FPDF_FILLMODE_WINDING = 2;

  FPDF_FONT_TYPE1 = 1;
  FPDF_FONT_TRUETYPE = 2;

  FPDF_LINECAP_BUTT = 0;
  FPDF_LINECAP_ROUND = 1;
  FPDF_LINECAP_PROJECTING_SQUARE = 2;

  FPDF_LINEJOIN_MITER = 0;
  FPDF_LINEJOIN_ROUND = 1;
  FPDF_LINEJOIN_BEVEL = 2;

  // See FPDF_SetPrintMode() for descriptions.
  FPDF_PRINTMODE_EMF = 0;
  FPDF_PRINTMODE_TEXTONLY = 1;
  FPDF_PRINTMODE_POSTSCRIPT2 = 2;
  FPDF_PRINTMODE_POSTSCRIPT3 = 3;
  FPDF_PRINTMODE_POSTSCRIPT2_PASSTHROUGH = 4;
  FPDF_PRINTMODE_POSTSCRIPT3_PASSTHROUGH = 5;
  FPDF_PRINTMODE_EMF_IMAGE_MASKS = 6;
  FPDF_PRINTMODE_POSTSCRIPT3_TYPE42 = 7;
  FPDF_PRINTMODE_POSTSCRIPT3_TYPE42_PASSTHROUGH= 8;

type
  PFPDF_IMAGEOBJ_METADATA = ^FPDF_IMAGEOBJ_METADATA;
  FPDF_IMAGEOBJ_METADATA = record
    // The image width in pixels.
    width: Cardinal;
    // The image height in pixels.
    height: Cardinal;
    // The image's horizontal pixel-per-inch.
    horizontal_dpi: Single;
    // The image's vertical pixel-per-inch.
    vertical_dpi: Single;
    // The number of bits used to represent each pixel.
    bits_per_pixel: Cardinal;
    // The image's colorspace. See above for the list of FPDF_COLORSPACE_*.
    colorspace: Integer;
    // The image's marked content ID. Useful for pairing with associated alt-text.
    // A value of -1 indicates no ID.
    marked_content_id: Integer;
  end;
  PFPdfImageObjMetaData = ^TFPdfImageObjMetaData;
  TFPdfImageObjMetaData = FPDF_IMAGEOBJ_METADATA;

// Create a new PDF document.
//
// Returns a handle to a new document, or NULL on failure.
var
  FPDF_CreateNewDocument: function: FPDF_DOCUMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Create a new PDF page.
//
//   document   - handle to document.
//   page_index - suggested 0-based index of the page to create. If it is larger
//                than document's current last index(L), the created page index
//                is the next available index -- L+1.
//   width      - the page width in points.
//   height     - the page height in points.
//
// Returns the handle to the new page or NULL on failure.
//
// The page should be closed with FPDF_ClosePage() when finished as
// with any other page in the document.
var
  FPDFPage_New: function(document: FPDF_DOCUMENT; page_index: Integer; width, height: Double): FPDF_PAGE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Delete the page at |page_index|.
//
//   document   - handle to document.
//   page_index - the index of the page to delete.
var
  FPDFPage_Delete: procedure(document: FPDF_DOCUMENT; page_index: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Move the given pages to a new index position.
//
//  page_indices     - the ordered list of pages to move. No duplicates allowed.
//  page_indices_len - the number of elements in |page_indices|
//  dest_page_index  - the new index position to which the pages in
//                     |page_indices| are moved.
//
// Returns TRUE on success. If it returns FALSE, the document may be left in an
// indeterminate state.
//
// Example: The PDF document starts out with pages [A, B, C, D], with indices
// [0, 1, 2, 3].
//
// >  Move(doc, [3, 2], 2, 1); // returns true
// >  // The document has pages [A, D, C, B].
// >
// >  Move(doc, [0, 4, 3], 3, 1); // returns false
// >  // Returned false because index 4 is out of range.
// >
// >  Move(doc, [0, 3, 1], 3, 2); // returns false
// >  // Returned false because index 2 is out of range for 3 page indices.
// >
// >  Move(doc, [2, 2], 2, 0); // returns false
// >  // Returned false because [2, 2] contains duplicates.
//
var
  FPDF_MovePages: function(document: FPDF_DOCUMENT; page_indices: PInteger; page_indices_len: LongWord;
    dest_page_index: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the rotation of |page|.
//
//   page - handle to a page
//
// Returns one of the following indicating the page rotation:
//   0 - No rotation.
//   1 - Rotated 90 degrees clockwise.
//   2 - Rotated 180 degrees clockwise.
//   3 - Rotated 270 degrees clockwise.
var
  FPDFPage_GetRotation: function(page: FPDF_PAGE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set rotation for |page|.
//
//   page   - handle to a page.
//   rotate - the rotation value, one of:
//              0 - No rotation.
//              1 - Rotated 90 degrees clockwise.
//              2 - Rotated 180 degrees clockwise.
//              3 - Rotated 270 degrees clockwise.
var
  FPDFPage_SetRotation: procedure(page: FPDF_PAGE; rotate: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Insert |page_obj| into |page|.
//
//   page     - handle to a page
//   page_obj - handle to a page object. The |page_obj| will be automatically
//              freed.
var
  FPDFPage_InsertObject: procedure(page: FPDF_PAGE; page_obj: FPDF_PAGEOBJECT); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Remove |page_obj| from |page|.
//
//   page     - handle to a page
//   page_obj - handle to a page object to be removed.
//
// Returns TRUE on success.
//
// Ownership is transferred to the caller. Call FPDFPageObj_Destroy() to free
// it.
var
  FPDFPage_RemoveObject: function(page: FPDF_PAGE; page_obj: FPDF_PAGEOBJECT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get number of page objects inside |page|.
//
//   page - handle to a page.
//
// Returns the number of objects in |page|.
var
  FPDFPage_CountObjects: function(page: FPDF_PAGE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get object in |page| at |index|.
//
//   page  - handle to a page.
//   index - the index of a page object.
//
// Returns the handle to the page object, or NULL on failed.
var
  FPDFPage_GetObject: function(page: FPDF_PAGE; index: Integer): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Checks if |page| contains transparency.
//
//   page - handle to a page.
//
// Returns TRUE if |page| contains transparency.
var
  FPDFPage_HasTransparency: function(page: FPDF_PAGE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Generate the content of |page|.
//
//   page - handle to a page.
//
// Returns TRUE on success.
//
// Before you save the page to a file, or reload the page, you must call
// |FPDFPage_GenerateContent| or any changes to |page| will be lost.
var
  FPDFPage_GenerateContent: function(page: FPDF_PAGE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Destroy |page_obj| by releasing its resources. |page_obj| must have been
// created by FPDFPageObj_CreateNew{Path|Rect}() or
// FPDFPageObj_New{Text|Image}Obj(). This function must be called on
// newly-created objects if they are not added to a page through
// FPDFPage_InsertObject() or to an annotation through FPDFAnnot_AppendObject().
//
//   page_obj - handle to a page object.
var
  FPDFPageObj_Destroy: procedure(page_obj: FPDF_PAGEOBJECT); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Checks if |page_object| contains transparency.
//
//   page_object - handle to a page object.
//
// Returns TRUE if |page_object| contains transparency.
var
  FPDFPageObj_HasTransparency: function(page_object: FPDF_PAGEOBJECT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get type of |page_object|.
//
//   page_object - handle to a page object.
//
// Returns one of the FPDF_PAGEOBJ_* values on success, FPDF_PAGEOBJ_UNKNOWN on
// error.
var
  FPDFPageObj_GetType: function(page_object: FPDF_PAGEOBJECT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Transform |page_object| by the given matrix.
//
//   page_object - handle to a page object.
//   a           - matrix value.
//   b           - matrix value.
//   c           - matrix value.
//   d           - matrix value.
//   e           - matrix value.
//   f           - matrix value.
//
// The matrix is composed as:
//   |a c e|
//   |b d f|
// and can be used to scale, rotate, shear and translate the |page_object|.
var
  FPDFPageObj_Transform: procedure(page_object: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the transform matrix of a page object.
//
//   page_object - handle to a page object.
//   matrix      - pointer to struct to receive the matrix value.
//
// The matrix is composed as:
//   |a c e|
//   |b d f|
// and used to scale, rotate, shear and translate the page object.
//
// Returns TRUE on success.
var
  FPDFPageObj_GetMatrix: function(page_object: FPDF_PAGEOBJECT; matrix: PFS_MATRIX): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the transform matrix of a page object.
//
//   page_object - handle to a page object.
//   matrix      - pointer to struct with the matrix value.
//
// The matrix is composed as:
//   |a c e|
//   |b d f|
// and can be used to scale, rotate, shear and translate the page object.
//
// Returns TRUE on success.
var
  FPDFPageObj_SetMatrix: function(path: FPDF_PAGEOBJECT; const matrix: PFS_MATRIX): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Transform all annotations in |page|.
//
//   page - handle to a page.
//   a    - matrix value.
//   b    - matrix value.
//   c    - matrix value.
//   d    - matrix value.
//   e    - matrix value.
//   f    - matrix value.
//
// The matrix is composed as:
//   |a c e|
//   |b d f|
// and can be used to scale, rotate, shear and translate the |page| annotations.
var
  FPDFPage_TransformAnnots: procedure(page: FPDF_PAGE; a, b, c, d, e, f: Double); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Create a new image object.
//
//   document - handle to a document.
//
// Returns a handle to a new image object.
var
  FPDFPageObj_NewImageObj: function(document: FPDF_DOCUMENT): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get number of content marks in |page_object|.
//
//   page_object - handle to a page object.
//
// Returns the number of content marks in |page_object|, or -1 in case of
// failure.
var
  FPDFPageObj_CountMarks: function(page_object: FPDF_PAGEOBJECT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get content mark in |page_object| at |index|.
//
//   page_object - handle to a page object.
//   index       - the index of a page object.
//
// Returns the handle to the content mark, or NULL on failure. The handle is
// still owned by the library, and it should not be freed directly. It becomes
// invalid if the page object is destroyed, either directly or indirectly by
// unloading the page.
var
  FPDFPageObj_GetMark: function(page_object: FPDF_PAGEOBJECT; index: LongWord): FPDF_PAGEOBJECTMARK; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Add a new content mark to a |page_object|.
//
//   page_object - handle to a page object.
//   name        - the name (tag) of the mark.
//
// Returns the handle to the content mark, or NULL on failure. The handle is
// still owned by the library, and it should not be freed directly. It becomes
// invalid if the page object is destroyed, either directly or indirectly by
// unloading the page.
var
  FPDFPageObj_AddMark: function(page_object: FPDF_PAGEOBJECT; name: FPDF_BYTESTRING): FPDF_PAGEOBJECTMARK; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Removes a content |mark| from a |page_object|.
// The mark handle will be invalid after the removal.
//
//   page_object - handle to a page object.
//   mark        - handle to a content mark in that object to remove.
//
// Returns TRUE if the operation succeeded, FALSE if it failed.
var
  FPDFPageObj_RemoveMark: function(page_object: FPDF_PAGEOBJECT; mark: FPDF_PAGEOBJECTMARK): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the name of a content mark.
//
//   mark       - handle to a content mark.
//   buffer     - buffer for holding the returned name in UTF-16LE. This is only
//                modified if |buflen| is longer than the length of the name.
//                Optional, pass null to just retrieve the size of the buffer
//                needed.
//   buflen     - length of the buffer.
//   out_buflen - pointer to variable that will receive the minimum buffer size
//                to contain the name. Not filled if FALSE is returned.
//
// Returns TRUE if the operation succeeded, FALSE if it failed.
var
  FPDFPageObjMark_GetName: function(mark: FPDF_PAGEOBJECTMARK; buffer: Pointer; buflen: LongWord;
    out_buflen: PLongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the number of key/value pair parameters in |mark|.
//
//   mark   - handle to a content mark.
//
// Returns the number of key/value pair parameters |mark|, or -1 in case of
// failure.
var
  FPDFPageObjMark_CountParams: function(mark: FPDF_PAGEOBJECTMARK): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the key of a property in a content mark.
//
//   mark       - handle to a content mark.
//   index      - index of the property.
//   buffer     - buffer for holding the returned key in UTF-16LE. This is only
//                modified if |buflen| is longer than the length of the key.
//                Optional, pass null to just retrieve the size of the buffer
//                needed.
//   buflen     - length of the buffer.
//   out_buflen - pointer to variable that will receive the minimum buffer size
//                to contain the key. Not filled if FALSE is returned.
//
// Returns TRUE if the operation was successful, FALSE otherwise.
var
  FPDFPageObjMark_GetParamKey: function(mark: FPDF_PAGEOBJECTMARK; index: LongWord; buffer: Pointer; buflen: LongWord;
    out_buflen: PLongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the type of the value of a property in a content mark by key.
//
//   mark   - handle to a content mark.
//   key    - string key of the property.
//
// Returns the type of the value, or FPDF_OBJECT_UNKNOWN in case of failure.
var
  FPDFPageObjMark_GetParamValueType: function(mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING): FPDF_OBJECT_TYPE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// Experimental API.
// Get the value of a number property in a content mark by key as int.
// FPDFPageObjMark_GetParamValueType() should have returned FPDF_OBJECT_NUMBER
// for this property.
//
//   mark      - handle to a content mark.
//   key       - string key of the property.
//   out_value - pointer to variable that will receive the value. Not filled if
//               false is returned.
//
// Returns TRUE if the key maps to a number value, FALSE otherwise.
var
  FPDFPageObjMark_GetParamIntValue: function(mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING;
    out_value: PInteger): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the value of a string property in a content mark by key.
//
//   mark       - handle to a content mark.
//   key        - string key of the property.
//   buffer     - buffer for holding the returned value in UTF-16LE. This is
//                only modified if |buflen| is longer than the length of the
//                value.
//                Optional, pass null to just retrieve the size of the buffer
//                needed.
//   buflen     - length of the buffer.
//   out_buflen - pointer to variable that will receive the minimum buffer size
//                to contain the value. Not filled if FALSE is returned.
//
// Returns TRUE if the key maps to a string/blob value, FALSE otherwise.
var
  FPDFPageObjMark_GetParamStringValue: function(mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING; buffer: Pointer;
    buflen: LongWord; out_buflen: PLongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the value of a blob property in a content mark by key.
//
//   mark       - handle to a content mark.
//   key        - string key of the property.
//   buffer     - buffer for holding the returned value. This is only modified
//                if |buflen| is at least as long as the length of the value.
//                Optional, pass null to just retrieve the size of the buffer
//                needed.
//   buflen     - length of the buffer.
//   out_buflen - pointer to variable that will receive the minimum buffer size
//                to contain the value. Not filled if FALSE is returned.
//
// Returns TRUE if the key maps to a string/blob value, FALSE otherwise.
var
  FPDFPageObjMark_GetParamBlobValue: function(mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING; buffer: Pointer;
    buflen: LongWord; out_buflen: PLongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the value of an int property in a content mark by key. If a parameter
// with key |key| exists, its value is set to |value|. Otherwise, it is added as
// a new parameter.
//
//   document    - handle to the document.
//   page_object - handle to the page object with the mark.
//   mark        - handle to a content mark.
//   key         - string key of the property.
//   value       - int value to set.
//
// Returns TRUE if the operation succeeded, FALSE otherwise.
var
  FPDFPageObjMark_SetIntParam: function(document: FPDF_DOCUMENT; page_object: FPDF_PAGEOBJECT;
    mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING; value: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the value of a string property in a content mark by key. If a parameter
// with key |key| exists, its value is set to |value|. Otherwise, it is added as
// a new parameter.
//
//   document    - handle to the document.
//   page_object - handle to the page object with the mark.
//   mark        - handle to a content mark.
//   key         - string key of the property.
//   value       - string value to set.
//
// Returns TRUE if the operation succeeded, FALSE otherwise.
var
  FPDFPageObjMark_SetStringParam: function(document: FPDF_DOCUMENT; page_object: FPDF_PAGEOBJECT;
    mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING; value: FPDF_BYTESTRING): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the value of a blob property in a content mark by key. If a parameter
// with key |key| exists, its value is set to |value|. Otherwise, it is added as
// a new parameter.
//
//   document    - handle to the document.
//   page_object - handle to the page object with the mark.
//   mark        - handle to a content mark.
//   key         - string key of the property.
//   value       - pointer to blob value to set.
//   value_len   - size in bytes of |value|.
//
// Returns TRUE if the operation succeeded, FALSE otherwise.
var
  FPDFPageObjMark_SetBlobParam: function(document: FPDF_DOCUMENT; page_object: FPDF_PAGEOBJECT;
    mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING; value: Pointer; value_len: LongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Removes a property from a content mark by key.
//
//   page_object - handle to the page object with the mark.
//   mark        - handle to a content mark.
//   key         - string key of the property.
//
// Returns TRUE if the operation succeeded, FALSE otherwise.
var
  FPDFPageObjMark_RemoveParam: function(page_object: FPDF_PAGEOBJECT; mark: FPDF_PAGEOBJECTMARK;
    key: FPDF_BYTESTRING): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Load an image from a JPEG image file and then set it into |image_object|.
//
//   pages        - pointer to the start of all loaded pages, may be NULL.
//   count        - number of |pages|, may be 0.
//   image_object - handle to an image object.
//   file_access  - file access handler which specifies the JPEG image file.
//
// Returns TRUE on success.
//
// The image object might already have an associated image, which is shared and
// cached by the loaded pages. In that case, we need to clear the cached image
// for all the loaded pages. Pass |pages| and page count (|count|) to this API
// to clear the image cache. If the image is not previously shared, or NULL is a
// valid |pages| value.
var
  FPDFImageObj_LoadJpegFile: function(pages: PFPDF_PAGE; nCount: Integer; image_object: FPDF_PAGEOBJECT;
    fileAccess: PFPDF_FILEACCESS): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Load an image from a JPEG image file and then set it into |image_object|.
//
//   pages        - pointer to the start of all loaded pages, may be NULL.
//   count        - number of |pages|, may be 0.
//   image_object - handle to an image object.
//   file_access  - file access handler which specifies the JPEG image file.
//
// Returns TRUE on success.
//
// The image object might already have an associated image, which is shared and
// cached by the loaded pages. In that case, we need to clear the cached image
// for all the loaded pages. Pass |pages| and page count (|count|) to this API
// to clear the image cache. If the image is not previously shared, or NULL is a
// valid |pages| value. This function loads the JPEG image inline, so the image
// content is copied to the file. This allows |file_access| and its associated
// data to be deleted after this function returns.
var
  FPDFImageObj_LoadJpegFileInline: function(pages: PFPDF_PAGE; count: Integer; image_object: FPDF_PAGEOBJECT;
    file_access: PFPDF_FILEACCESS): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// TODO(thestig): Start deprecating this once FPDFPageObj_SetMatrix() is stable.
// Set the transform matrix of |image_object|.
//
//   image_object - handle to an image object.
//   a            - matrix value.
//   b            - matrix value.
//   c            - matrix value.
//   d            - matrix value.
//   e            - matrix value.
//   f            - matrix value.
//
// The matrix is composed as:
//   |a c e|
//   |b d f|
// and can be used to scale, rotate, shear and translate the |image_object|.
//
// Returns TRUE on success.
var
  FPDFImageObj_SetMatrix: function(image_object: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set |bitmap| to |image_object|.
//
//   pages        - pointer to the start of all loaded pages, may be NULL.
//   count        - number of |pages|, may be 0.
//   image_object - handle to an image object.
//   bitmap       - handle of the bitmap.
//
// Returns TRUE on success.
var
  FPDFImageObj_SetBitmap: function(pages: PFPDF_PAGE; nCount: Integer; image_object: FPDF_PAGEOBJECT;
    bitmap: FPDF_BITMAP): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get a bitmap rasterization of |image_object|. FPDFImageObj_GetBitmap() only
// operates on |image_object| and does not take the associated image mask into
// account. It also ignores the matrix for |image_object|.
// The returned bitmap will be owned by the caller, and FPDFBitmap_Destroy()
// must be called on the returned bitmap when it is no longer needed.
//
//   image_object - handle to an image object.
//
// Returns the bitmap.
var
  FPDFImageObj_GetBitmap: function(image_object: FPDF_PAGEOBJECT): FPDF_BITMAP; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get a bitmap rasterization of |image_object| that takes the image mask and
// image matrix into account. To render correctly, the caller must provide the
// |document| associated with |image_object|. If there is a |page| associated
// with |image_object|, the caller should provide that as well.
// The returned bitmap will be owned by the caller, and FPDFBitmap_Destroy()
// must be called on the returned bitmap when it is no longer needed.
//
//   document     - handle to a document associated with |image_object|.
//   page         - handle to an optional page associated with |image_object|.
//   image_object - handle to an image object.
//
// Returns the bitmap or NULL on failure.
var
  FPDFImageObj_GetRenderedBitmap: function(document: FPDF_DOCUMENT; page: FPDF_PAGE;
    image_object: FPDF_PAGEOBJECT): FPDF_BITMAP; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the decoded image data of |image_object|. The decoded data is the
// uncompressed image data, i.e. the raw image data after having all filters
// applied. |buffer| is only modified if |buflen| is longer than the length of
// the decoded image data.
//
//   image_object - handle to an image object.
//   buffer       - buffer for holding the decoded image data.
//   buflen       - length of the buffer in bytes.
//
// Returns the length of the decoded image data.
var
  FPDFImageObj_GetImageDataDecoded: function(image_object: FPDF_PAGEOBJECT; buffer: Pointer;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the raw image data of |image_object|. The raw data is the image data as
// stored in the PDF without applying any filters. |buffer| is only modified if
// |buflen| is longer than the length of the raw image data.
//
//   image_object - handle to an image object.
//   buffer       - buffer for holding the raw image data.
//   buflen       - length of the buffer in bytes.
//
// Returns the length of the raw image data.
var
  FPDFImageObj_GetImageDataRaw: function(image_object: FPDF_PAGEOBJECT; buffer: Pointer;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the number of filters (i.e. decoders) of the image in |image_object|.
//
//   image_object - handle to an image object.
//
// Returns the number of |image_object|'s filters.
var
  FPDFImageObj_GetImageFilterCount: function(image_object: FPDF_PAGEOBJECT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the filter at |index| of |image_object|'s list of filters. Note that the
// filters need to be applied in order, i.e. the first filter should be applied
// first, then the second, etc. |buffer| is only modified if |buflen| is longer
// than the length of the filter string.
//
//   image_object - handle to an image object.
//   index        - the index of the filter requested.
//   buffer       - buffer for holding filter string, encoded in UTF-8.
//   buflen       - length of the buffer.
//
// Returns the length of the filter string.
var
  FPDFImageObj_GetImageFilter: function(image_object: FPDF_PAGEOBJECT; index: Integer; buffer: Pointer;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the image metadata of |image_object|, including dimension, DPI, bits per
// pixel, and colorspace. If the |image_object| is not an image object or if it
// does not have an image, then the return value will be false. Otherwise,
// failure to retrieve any specific parameter would result in its value being 0.
//
//   image_object - handle to an image object.
//   page         - handle to the page that |image_object| is on. Required for
//                  retrieving the image's bits per pixel and colorspace.
//   metadata     - receives the image metadata; must not be NULL.
//
// Returns true if successful.
var
  FPDFImageObj_GetImageMetadata: function(image_object: FPDF_PAGEOBJECT; page: FPDF_PAGE;
    metadata: PFPDF_IMAGEOBJ_METADATA): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the image size in pixels. Faster method to get only image size.
//
//   image_object - handle to an image object.
//   width        - receives the image width in pixels; must not be NULL.
//   height       - receives the image height in pixels; must not be NULL.
//
// Returns true if successful.
var
  FPDFImageObj_GetImagePixelSize: function(image_object: FPDF_PAGEOBJECT; var width, height: UInt32): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Create a new path object at an initial position.
//
//   x - initial horizontal position.
//   y - initial vertical position.
//
// Returns a handle to a new path object.
var
  FPDFPageObj_CreateNewPath: function(x, y: Single): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Create a closed path consisting of a rectangle.
//
//   x - horizontal position for the left boundary of the rectangle.
//   y - vertical position for the bottom boundary of the rectangle.
//   w - width of the rectangle.
//   h - height of the rectangle.
//
// Returns a handle to the new path object.
var
  FPDFPageObj_CreateNewRect: function(x, y, w, h: Single): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the bounding box of |page_object|.
//
// page_object  - handle to a page object.
// left         - pointer where the left coordinate will be stored
// bottom       - pointer where the bottom coordinate will be stored
// right        - pointer where the right coordinate will be stored
// top          - pointer where the top coordinate will be stored
//
// On success, returns TRUE and fills in the 4 coordinates.
var
  FPDFPageObj_GetBounds: function(page_object: FPDF_PAGEOBJECT; var left, bottom, right, top: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the quad points that bounds |page_object|.
//
// page_object  - handle to a page object.
// quad_points  - pointer where the quadrilateral points will be stored.
//
// On success, returns TRUE and fills in |quad_points|.
//
// Similar to FPDFPageObj_GetBounds(), this returns the bounds of a page
// object. When the object is rotated by a non-multiple of 90 degrees, this API
// returns a tighter bound that cannot be represented with just the 4 sides of
// a rectangle.
//
// Currently only works the following |page_object| types: FPDF_PAGEOBJ_TEXT and
// FPDF_PAGEOBJ_IMAGE.
var
  FPDFPageObj_GetRotatedBounds: function(page_object: FPDF_PAGEOBJECT; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set the blend mode of |page_object|.
//
// page_object  - handle to a page object.
// blend_mode   - string containing the blend mode.
//
// Blend mode can be one of following: Color, ColorBurn, ColorDodge, Darken,
// Difference, Exclusion, HardLight, Hue, Lighten, Luminosity, Multiply, Normal,
// Overlay, Saturation, Screen, SoftLight
var
  FPDFPageObj_SetBlendMode: procedure(page_object: FPDF_PAGEOBJECT; blend_mode: FPDF_BYTESTRING); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set the stroke RGBA of a page object. Range of values: 0 - 255.
//
// page_object  - the handle to the page object.
// R            - the red component for the object's stroke color.
// G            - the green component for the object's stroke color.
// B            - the blue component for the object's stroke color.
// A            - the stroke alpha for the object.
//
// Returns TRUE on success.
var
  FPDFPageObj_SetStrokeColor: function(page_object: FPDF_PAGEOBJECT; R, G, B, A: Cardinal): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the stroke RGBA of a page object. Range of values: 0 - 255.
//
// page_object  - the handle to the page object.
// R            - the red component of the path stroke color.
// G            - the green component of the object's stroke color.
// B            - the blue component of the object's stroke color.
// A            - the stroke alpha of the object.
//
// Returns TRUE on success.
var
  FPDFPageObj_GetStrokeColor: function(page_object: FPDF_PAGEOBJECT; var R, G, B, A: Cardinal): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set the stroke width of a page object.
//
// path   - the handle to the page object.
// width  - the width of the stroke.
//
// Returns TRUE on success
var
  FPDFPageObj_SetStrokeWidth: function(page_object: FPDF_PAGEOBJECT; width: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the stroke width of a page object.
//
// path   - the handle to the page object.
// width  - the width of the stroke.
//
// Returns TRUE on success
var
  FPDFPageObj_GetStrokeWidth: function(page_object: FPDF_PAGEOBJECT; var width: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the line join of |page_object|.
//
// page_object  - handle to a page object.
//
// Returns the line join, or -1 on failure.
// Line join can be one of following: FPDF_LINEJOIN_MITER, FPDF_LINEJOIN_ROUND,
// FPDF_LINEJOIN_BEVEL
var
  FPDFPageObj_GetLineJoin: function(page_object: FPDF_PAGEOBJECT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set the line join of |page_object|.
//
// page_object  - handle to a page object.
// line_join    - line join
//
// Line join can be one of following: FPDF_LINEJOIN_MITER, FPDF_LINEJOIN_ROUND,
// FPDF_LINEJOIN_BEVEL
var
  FPDFPageObj_SetLineJoin: function(page_object: FPDF_PAGEOBJECT; line_join: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the line cap of |page_object|.
//
// page_object - handle to a page object.
//
// Returns the line cap, or -1 on failure.
// Line cap can be one of following: FPDF_LINECAP_BUTT, FPDF_LINECAP_ROUND,
// FPDF_LINECAP_PROJECTING_SQUARE
var
  FPDFPageObj_GetLineCap: function(page_object: FPDF_PAGEOBJECT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set the line cap of |page_object|.
//
// page_object - handle to a page object.
// line_cap    - line cap
//
// Line cap can be one of following: FPDF_LINECAP_BUTT, FPDF_LINECAP_ROUND,
// FPDF_LINECAP_PROJECTING_SQUARE
var
  FPDFPageObj_SetLineCap: function(page_object: FPDF_PAGEOBJECT; line_cap: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set the fill RGBA of a page object. Range of values: 0 - 255.
//
// page_object  - the handle to the page object.
// R            - the red component for the object's fill color.
// G            - the green component for the object's fill color.
// B            - the blue component for the object's fill color.
// A            - the fill alpha for the object.
//
// Returns TRUE on success.
var
  FPDFPageObj_SetFillColor: function(page_object: FPDF_PAGEOBJECT; R, G, B, A: Cardinal): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the fill RGBA of a page object. Range of values: 0 - 255.
//
// page_object  - the handle to the page object.
// R            - the red component of the object's fill color.
// G            - the green component of the object's fill color.
// B            - the blue component of the object's fill color.
// A            - the fill alpha of the object.
//
// Returns TRUE on success.
var
  FPDFPageObj_GetFillColor: function(page_object: FPDF_PAGEOBJECT; var R, G, B, A: Cardinal): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the line dash |phase| of |page_object|.
//
// page_object - handle to a page object.
// phase - pointer where the dashing phase will be stored.
//
// Returns TRUE on success.
var
  FPDFPageObj_GetDashPhase: function(page_object: FPDF_PAGEOBJECT; var phase: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the line dash phase of |page_object|.
//
// page_object - handle to a page object.
// phase - line dash phase.
//
// Returns TRUE on success.
var
  FPDFPageObj_SetDashPhase: function(page_object: FPDF_PAGEOBJECT; phase: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the line dash array of |page_object|.
//
// page_object - handle to a page object.
//
// Returns the line dash array size or -1 on failure.
var
  FPDFPageObj_GetDashCount: function(page_object: FPDF_PAGEOBJECT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the line dash array of |page_object|.
//
// page_object - handle to a page object.
// dash_array - pointer where the dashing array will be stored.
// dash_count - number of elements in |dash_array|.
//
// Returns TRUE on success.
var
  FPDFPageObj_GetDashArray: function(page_object: FPDF_PAGEOBJECT; dash_array: PSingle; dash_count: SIZE_T): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the line dash array of |page_object|.
//
// page_object - handle to a page object.
// dash_array - the dash array.
// dash_count - number of elements in |dash_array|.
// phase - the line dash phase.
//
// Returns TRUE on success.
var
  FPDFPageObj_SetDashArray: function(page_object: FPDF_PAGEOBJECT; const dash_array: PSingle; dash_count: SIZE_T;
    phase: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get number of segments inside |path|.
//
//   path - handle to a path.
//
// A segment is a command, created by e.g. FPDFPath_MoveTo(),
// FPDFPath_LineTo() or FPDFPath_BezierTo().
//
// Returns the number of objects in |path| or -1 on failure.
var
  FPDFPath_CountSegments: function(path: FPDF_PAGEOBJECT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get segment in |path| at |index|.
//
//   path  - handle to a path.
//   index - the index of a segment.
//
// Returns the handle to the segment, or NULL on faiure.
var
  FPDFPath_GetPathSegment: function(path: FPDF_PAGEOBJECT; index: Integer): FPDF_PATHSEGMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get coordinates of |segment|.
//
//   segment  - handle to a segment.
//   x      - the horizontal position of the segment.
//   y      - the vertical position of the segment.
//
// Returns TRUE on success, otherwise |x| and |y| is not set.
var
  FPDFPathSegment_GetPoint: function(segment: FPDF_PATHSEGMENT; var x, y: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get type of |segment|.
//
//   segment - handle to a segment.
//
// Returns one of the FPDF_SEGMENT_* values on success,
// FPDF_SEGMENT_UNKNOWN on error.
var
  FPDFPathSegment_GetType: function(segment: FPDF_PATHSEGMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Gets if the |segment| closes the current subpath of a given path.
//
//   segment - handle to a segment.
//
// Returns close flag for non-NULL segment, FALSE otherwise.
var
  FPDFPathSegment_GetClose: function(segment: FPDF_PATHSEGMENT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Move a path's current point.
//
// path   - the handle to the path object.
// x      - the horizontal position of the new current point.
// y      - the vertical position of the new current point.
//
// Note that no line will be created between the previous current point and the
// new one.
//
// Returns TRUE on success
var
  FPDFPath_MoveTo: function(path: FPDF_PAGEOBJECT; x, y: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Add a line between the current point and a new point in the path.
//
// path   - the handle to the path object.
// x      - the horizontal position of the new point.
// y      - the vertical position of the new point.
//
// The path's current point is changed to (x, y).
//
// Returns TRUE on success
var
  FPDFPath_LineTo: function(path: FPDF_PAGEOBJECT; x, y: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Add a cubic Bezier curve to the given path, starting at the current point.
//
// path   - the handle to the path object.
// x1     - the horizontal position of the first Bezier control point.
// y1     - the vertical position of the first Bezier control point.
// x2     - the horizontal position of the second Bezier control point.
// y2     - the vertical position of the second Bezier control point.
// x3     - the horizontal position of the ending point of the Bezier curve.
// y3     - the vertical position of the ending point of the Bezier curve.
//
// Returns TRUE on success
var
  FPDFPath_BezierTo: function(path: FPDF_PAGEOBJECT; x1, y1, x2, y2, x3, y3: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Close the current subpath of a given path.
//
// path   - the handle to the path object.
//
// This will add a line between the current point and the initial point of the
// subpath, thus terminating the current subpath.
//
// Returns TRUE on success
var
  FPDFPath_Close: function(path: FPDF_PAGEOBJECT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set the drawing mode of a path.
//
// path     - the handle to the path object.
// fillmode - the filling mode to be set: one of the FPDF_FILLMODE_* flags.
// stroke   - a boolean specifying if the path should be stroked or not.
//
// Returns TRUE on success
var
  FPDFPath_SetDrawMode: function(path: FPDF_PAGEOBJECT; fillmode: Integer; stoke: FPDF_BOOL): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the drawing mode of a path.
//
// path     - the handle to the path object.
// fillmode - the filling mode of the path: one of the FPDF_FILLMODE_* flags.
// stroke   - a boolean specifying if the path is stroked or not.
//
// Returns TRUE on success
var
  FPDFPath_GetDrawMode: function(path: FPDF_PAGEOBJECT; var fillmode: Integer; var stoke: FPDF_BOOL): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Create a new text object using one of the standard PDF fonts.
//
// document   - handle to the document.
// font       - string containing the font name, without spaces.
// font_size  - the font size for the new text object.
//
// Returns a handle to a new text object, or NULL on failure
var
  FPDFPageObj_NewTextObj: function(document: FPDF_DOCUMENT; font: FPDF_BYTESTRING; font_size: Single): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set the text for a text object. If it had text, it will be replaced.
//
// text_object  - handle to the text object.
// text         - the UTF-16LE encoded string containing the text to be added.
//
// Returns TRUE on success
var
  FPDFText_SetText: function(text_object: FPDF_PAGEOBJECT; text: FPDF_WIDESTRING): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the text using charcodes for a text object. If it had text, it will be
// replaced.
//
// text_object  - handle to the text object.
// charcodes    - pointer to an array of charcodes to be added.
// count        - number of elements in |charcodes|.
//
// Returns TRUE on success
var
  FPDFText_SetCharcodes: function(text_object: FPDF_PAGEOBJECT; const charcodes: PUINT; count: SIZE_T): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Returns a font object loaded from a stream of data. The font is loaded
// into the document.
//
// document   - handle to the document.
// data       - the stream of data, which will be copied by the font object.
// size       - size of the stream, in bytes.
// font_type  - FPDF_FONT_TYPE1 or FPDF_FONT_TRUETYPE depending on the font
// type.
// cid        - a boolean specifying if the font is a CID font or not.
//
// The loaded font can be closed using FPDFFont_Close.
//
// Returns NULL on failure
var
  FPDFText_LoadFont: function(document: FPDF_DOCUMENT; data: PByte; size: DWORD;
    font_type: Integer; cid: FPDF_BOOL): FPDF_FONT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Loads one of the standard 14 fonts per PDF spec 1.7 page 416. The preferred
// way of using font style is using a dash to separate the name from the style,
// for example 'Helvetica-BoldItalic'.
//
// document   - handle to the document.
// font       - string containing the font name, without spaces.
//
// The loaded font can be closed using FPDFFont_Close.
//
// Returns NULL on failure.
var
  FPDFText_LoadStandardFont: function(document: FPDF_DOCUMENT; font: FPDF_BYTESTRING): FPDF_FONT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the font size of a text object.
//
//   text - handle to a text.
//
//   size - pointer to the font size of the text object, measured in points
//   (about 1/72 inch)
//
// Returns TRUE on success.
var
  FPDFTextObj_GetFontSize: function(text: FPDF_PAGEOBJECT; var size: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Close a loaded PDF font.
//
// font   - Handle to the loaded font.
var
  FPDFFont_Close: procedure(font: FPDF_FONT); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Create a new text object using a loaded font.
//
// document   - handle to the document.
// font       - handle to the font object.
// font_size  - the font size for the new text object.
//
// Returns a handle to a new text object, or NULL on failure
var
  FPDFPageObj_CreateTextObj: function(document: FPDF_DOCUMENT; font: FPDF_FONT; font_size: Single): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the text rendering mode of a text object.
//
// text     - the handle to the text object.
//
// Returns one of the known FPDF_TEXT_RENDERMODE enum values on success,
// FPDF_TEXTRENDERMODE_UNKNOWN on error.
var
  FPDFTextObj_GetTextRenderMode: function(text: FPDF_PAGEOBJECT): FPDF_TEXT_RENDERMODE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the text rendering mode of a text object.
//
// text         - the handle to the text object.
// render_mode  - the FPDF_TEXT_RENDERMODE enum value to be set (cannot set to
//                FPDF_TEXTRENDERMODE_UNKNOWN).
//
// Returns TRUE on success.
var
  FPDFTextObj_SetTextRenderMode: function(text: FPDF_PAGEOBJECT; render_mode: FPDF_TEXT_RENDERMODE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the text of a text object.
//
// text_object      - the handle to the text object.
// text_page        - the handle to the text page.
// buffer           - the address of a buffer that receives the text.
// length           - the size, in bytes, of |buffer|.
//
// Returns the number of bytes in the text (including the trailing NUL
// character) on success, 0 on error.
//
// Regardless of the platform, the |buffer| is always in UTF-16LE encoding.
// If |length| is less than the returned length, or |buffer| is NULL, |buffer|
// will not be modified.
var
  FPDFTextObj_GetText: function(text_object: FPDF_PAGEOBJECT; text_page: FPDF_TEXTPAGE; buffer: PFPDF_WCHAR;
    length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get a bitmap rasterization of |text_object|. To render correctly, the caller
// must provide the |document| associated with |text_object|. If there is a
// |page| associated with |text_object|, the caller should provide that as well.
// The returned bitmap will be owned by the caller, and FPDFBitmap_Destroy()
// must be called on the returned bitmap when it is no longer needed.
//
//   document    - handle to a document associated with |text_object|.
//   page        - handle to an optional page associated with |text_object|.
//   text_object - handle to a text object.
//   scale       - the scaling factor, which must be greater than 0.
//
// Returns the bitmap or NULL on failure.
var
  FPDFTextObj_GetRenderedBitmap: function(document: FPDF_DOCUMENT; page: FPDF_PAGE; text_object: FPDF_PAGEOBJECT;
    scale: Single): FPDF_BITMAP; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the font of a text object.
//
// text - the handle to the text object.
//
// Returns a handle to the font object held by |text| which retains ownership.
var
  FPDFTextObj_GetFont: function(text: FPDF_PAGEOBJECT): FPDF_FONT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the font name of a font.
//
// font   - the handle to the font object.
// buffer - the address of a buffer that receives the font name.
// length - the size, in bytes, of |buffer|.
//
// Returns the number of bytes in the font name (including the trailing NUL
// character) on success, 0 on error.
//
// Regardless of the platform, the |buffer| is always in UTF-8 encoding.
// If |length| is less than the returned length, or |buffer| is NULL, |buffer|
// will not be modified.
var
  FPDFFont_GetFontName: function(font: FPDF_FONT; buffer: PAnsiChar; length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the decoded data from the |font| object.
//
// font       - The handle to the font object. (Required)
// buffer     - The address of a buffer that receives the font data.
// buflen     - Length of the buffer.
// out_buflen - Pointer to variable that will receive the minimum buffer size
//              to contain the font data. Not filled if the return value is
//              FALSE. (Required)
//
// Returns TRUE on success. In which case, |out_buflen| will be filled, and
// |buffer| will be filled if it is large enough. Returns FALSE if any of the
// required parameters are null.
//
// The decoded data is the uncompressed font data. i.e. the raw font data after
// having all stream filters applied, when the data is embedded.
//
// If the font is not embedded, then this API will instead return the data for
// the substitution font it is using.
var
  FPDFFont_GetFontData: function(font: FPDF_FONT; buffer: PByte; buflen: SIZE_T; var out_buflen: SIZE_T): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get whether |font| is embedded or not.
//
// font - the handle to the font object.
//
// Returns 1 if the font is embedded, 0 if it not, and -1 on failure.
var
  FPDFFont_GetIsEmbedded: function(font: FPDF_FONT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the descriptor flags of a font.
//
// font - the handle to the font object.
//
// Returns the bit flags specifying various characteristics of the font as
// defined in ISO 32000-1:2008, table 123, -1 on failure.
var
  FPDFFont_GetFlags: function(font: FPDF_FONT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the font weight of a font.
//
// font - the handle to the font object.
//
// Returns the font weight, -1 on failure.
// Typical values are 400 (normal) and 700 (bold).
var
  FPDFFont_GetWeight: function(font: FPDF_FONT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the italic angle of a font.
//
// font  - the handle to the font object.
// angle - pointer where the italic angle will be stored
//
// The italic angle of a |font| is defined as degrees counterclockwise
// from vertical. For a font that slopes to the right, this will be negative.
//
// Returns TRUE on success; |angle| unmodified on failure.
var
  FPDFFont_GetItalicAngle: function(font: FPDF_FONT; var angle: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get ascent distance of a font.
//
// font       - the handle to the font object.
// font_size  - the size of the |font|.
// ascent     - pointer where the font ascent will be stored
//
// Ascent is the maximum distance in points above the baseline reached by the
// glyphs of the |font|. One point is 1/72 inch (around 0.3528 mm).
//
// Returns TRUE on success; |ascent| unmodified on failure.
var
  FPDFFont_GetAscent: function(font: FPDF_FONT; font_size: Single; var ascent: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get descent distance of a font.
//
// font       - the handle to the font object.
// font_size  - the size of the |font|.
// descent    - pointer where the font descent will be stored
//
// Descent is the maximum distance in points below the baseline reached by the
// glyphs of the |font|. One point is 1/72 inch (around 0.3528 mm).
//
// Returns TRUE on success; |descent| unmodified on failure.
var
  FPDFFont_GetDescent: function(font: FPDF_FONT; font_size: Single; var descent: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the width of a glyph in a font.
//
// font       - the handle to the font object.
// glyph      - the glyph.
// font_size  - the size of the font.
// width      - pointer where the glyph width will be stored
//
// Glyph width is the distance from the end of the prior glyph to the next
// glyph. This will be the vertical distance for vertical writing.
//
// Returns TRUE on success; |width| unmodified on failure.
var
  FPDFFont_GetGlyphWidth: function(font: FPDF_FONT; glyph: UINT; font_size: Single; var width: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the glyphpath describing how to draw a font glyph.
//
// font       - the handle to the font object.
// glyph      - the glyph being drawn.
// font_size  - the size of the font.
//
// Returns the handle to the segment, or NULL on faiure.
var
  FPDFFont_GetGlyphPath: function(font: FPDF_FONT; glyph: UINT; font_size: Single): FPDF_GLYPHPATH; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get number of segments inside glyphpath.
//
// glyphpath - handle to a glyph path.
//
// Returns the number of objects in |glyphpath| or -1 on failure.
var
  FPDFGlyphPath_CountGlyphSegments: function(glyphpath: FPDF_GLYPHPATH): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get segment in glyphpath at index.
//
// glyphpath  - handle to a glyph path.
// index      - the index of a segment.
//
// Returns the handle to the segment, or NULL on faiure.
var
  FPDFGlyphPath_GetGlyphPathSegment: function(glyphpath: FPDF_GLYPHPATH; index: Integer): FPDF_PATHSEGMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get number of page objects inside |form_object|.
//
//   form_object - handle to a form object.
//
// Returns the number of objects in |form_object| on success, -1 on error.
var
  FPDFFormObj_CountObjects: function(form_object: FPDF_PAGEOBJECT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get page object in |form_object| at |index|.
//
//   form_object - handle to a form object.
//   index       - the 0-based index of a page object.
//
// Returns the handle to the page object, or NULL on error.
var
  FPDFFormObj_GetObject: function(form_object: FPDF_PAGEOBJECT; index: LongWord): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// *** _FPDF_PPO_H_ ***

// Experimental API.
// Import pages to a FPDF_DOCUMENT.
//
//   dest_doc     - The destination document for the pages.
//   src_doc      - The document to be imported.
//   page_indices - An array of page indices to be imported. The first page is
//                  zero. If |page_indices| is NULL, all pages from |src_doc|
//                  are imported.
//   length       - The length of the |page_indices| array.
//   index        - The page index at which to insert the first imported page
//                  into |dest_doc|. The first page is zero.
//
// Returns TRUE on success. Returns FALSE if any pages in |page_indices| is
// invalid.
var
  FPDF_ImportPagesByIndex: function(dest_doc, src_doc: FPDF_DOCUMENT; page_indices: PInteger;
    length: LongWord; index: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Import pages to a FPDF_DOCUMENT.
//
//   dest_doc  - The destination document for the pages.
//   src_doc   - The document to be imported.
//   pagerange - A page range string, Such as "1,3,5-7". The first page is one.
//               If |pagerange| is NULL, all pages from |src_doc| are imported.
//   index     - The page index at which to insert the first imported page into
//               |dest_doc|. The first page is zero.
//
// Returns TRUE on success. Returns FALSE if any pages in |pagerange| is
// invalid or if |pagerange| cannot be read.
var
  FPDF_ImportPages: function(dest_doc, src_doc: FPDF_DOCUMENT; pagerange: FPDF_BYTESTRING; index: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Create a new document from |src_doc|.  The pages of |src_doc| will be
// combined to provide |num_pages_on_x_axis x num_pages_on_y_axis| pages per
// |output_doc| page.
//
//   src_doc             - The document to be imported.
//   output_width        - The output page width in PDF "user space" units.
//   output_height       - The output page height in PDF "user space" units.
//   num_pages_on_x_axis - The number of pages on X Axis.
//   num_pages_on_y_axis - The number of pages on Y Axis.
//
// Return value:
//   A handle to the created document, or NULL on failure.
//
// Comments:
//   number of pages per page = num_pages_on_x_axis * num_pages_on_y_axis
//
var
  FPDF_ImportNPagesToOne: function(src_doc: FPDF_DOCUMENT; output_width, output_height: Single;
    num_pages_on_x_axis, num_pages_on_y_axis: SIZE_T): FPDF_DOCUMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Create a template to generate form xobjects from |src_doc|'s page at
// |src_page_index|, for use in |dest_doc|.
//
// Returns a handle on success, or NULL on failure. Caller owns the newly
// created object.
var
  FPDF_NewXObjectFromPage: function(dest_doc, src_doc: FPDF_DOCUMENT; src_page_index: Integer): FPDF_XOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Close an FPDF_XOBJECT handle created by FPDF_NewXObjectFromPage().
// FPDF_PAGEOBJECTs created from the FPDF_XOBJECT handle are not affected.
var
  FPDF_CloseXObject: procedure(xobject: FPDF_XOBJECT); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Create a new form object from an FPDF_XOBJECT object.
//
// Returns a new form object on success, or NULL on failure. Caller owns the
// newly created object.
var
  FPDF_NewFormObjectFromXObject: function(xobject: FPDF_XOBJECT): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Copy the viewer preferences from |src_doc| into |dest_doc|.
//
//   dest_doc - Document to write the viewer preferences into.
//   src_doc  - Document to read the viewer preferences from.
//
// Returns TRUE on success.
var
  FPDF_CopyViewerPreferences: function(dest_doc, src_doc: FPDF_DOCUMENT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_SAVE_H_ ***

type
  // Structure for custom file write
  PFPDF_FILEWRITE = ^FPDF_FILEWRITE;
  FPDF_FILEWRITE = record
    //
    // Version number of the interface. Currently must be 1.
    //
    version: Integer;

    //
    // Method: WriteBlock
    //          Output a block of data in your custom way.
    // Interface Version:
    //          1
    // Implementation Required:
    //          Yes
    // Comments:
    //          Called by function FPDF_SaveDocument
    // Parameters:
    //          pThis       -   Pointer to the structure itself
    //          pData       -   Pointer to a buffer to output
    //          size        -   The size of the buffer.
    // Return value:
    //          Should be non-zero if successful, zero for error.
    //
    WriteBlock: function(pThis: PFPDF_FILEWRITE; pData: Pointer; size: LongWord): Integer; cdecl;
  end;
  PFPdfFileWrite = ^TFPdfFileWrite;
  TFPdfFileWrite = FPDF_FILEWRITE;

const
  // Flags for FPDF_SaveAsCopy()
  FPDF_INCREMENTAL     = 1;
  FPDF_NO_INCREMENTAL  = 2;
  FPDF_REMOVE_SECURITY = 3;

// Function: FPDF_SaveAsCopy
//          Saves the copy of specified document in custom way.
// Parameters:
//          document        -   Handle to document, as returned by
//                              FPDF_LoadDocument() or FPDF_CreateNewDocument().
//          pFileWrite      -   A pointer to a custom file write structure.
//          flags           -   The creating flags.
// Return value:
//          TRUE for succeed, FALSE for failed.
//
var
  FPDF_SaveAsCopy: function(document: FPDF_DOCUMENT; pFileWrite: PFPDF_FILEWRITE; flags: FPDF_DWORD): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_SaveWithVersion
//          Same as FPDF_SaveAsCopy(), except the file version of the
//          saved document can be specified by the caller.
// Parameters:
//          document        -   Handle to document.
//          pFileWrite      -   A pointer to a custom file write structure.
//          flags           -   The creating flags.
//          fileVersion     -   The PDF file version. File version: 14 for 1.4, 15 for 1.5, ...
// Return value:
//          TRUE if succeed, FALSE if failed.
//
var
  FPDF_SaveWithVersion: function(document: FPDF_DOCUMENT; pFileWrite: PFPDF_FILEWRITE;
    flags: FPDF_DWORD; fileVersion: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_FLATTEN_H_ ***

const
  FLATTEN_FAIL       = 0;  // Flatten operation failed.
  FLATTEN_SUCCESS    = 1;  // Flatten operation succeed.
  FLATTEN_NOTINGTODO = 2;  // Nothing to be flattened.

  FLAT_NORMALDISPLAY = 0;  // Flatten for normal display.
  FLAT_PRINT         = 1;  // Flatten for print.

// Flatten annotations and form fields into the page contents.
//
//   page  - handle to the page.
//   nFlag - One of the |FLAT_*| values denoting the page usage.
//
// Returns one of the |FLATTEN_*| values.
//
// Currently, all failures return |FLATTEN_FAIL| with no indication of the
// cause.
var
  FPDFPage_Flatten: function(page: FPDF_PAGE; nFlag: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDFTEXT_H_ ***

// Function: FPDFText_LoadPage
//          Prepare information about all characters in a page.
// Parameters:
//          page    -   Handle to the page. Returned by FPDF_LoadPage function (in FPDFVIEW module).
// Return value:
//          A handle to the text page information structure.
//          NULL if something goes wrong.
// Comments:
//          Application must call FPDFText_ClosePage to release the text page
//          information.
//
var
  FPDFText_LoadPage: function(page: FPDF_PAGE): FPDF_TEXTPAGE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_ClosePage
//          Release all resources allocated for a text page information structure.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return Value:
//          None.
//
var
  FPDFText_ClosePage: procedure(text_page: FPDF_TEXTPAGE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_CountChars
//          Get number of characters in a page.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return value:
//          Number of characters in the page. Return -1 for error.
//          Generated characters, like additional space characters, new line
//          characters, are also counted.
// Comments:
//          Characters in a page form a "stream", inside the stream, each character has an index.
//          We will use the index parameters in many of FPDFTEXT functions. The first character in the page
//          has an index value of zero.
//
var
  FPDFText_CountChars: function(text_page: FPDF_TEXTPAGE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetUnicode
//          Get Unicode of a character in a page.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return value:
//          The Unicode of the particular character.
//          If a character is not encoded in Unicode and Foxit engine can't convert to Unicode,
//          the return value will be zero.
//
var
  FPDFText_GetUnicode: function(text_page: FPDF_TEXTPAGE; index: Integer): WideChar; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_IsGenerated
//          Get if a character in a page is generated by PDFium.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return value:
//          1 if the character is generated by PDFium.
//          0 if the character is not generated by PDFium.
//          -1 if there was an error.
//
var
  FPDFText_IsGenerated: function(text_page: FPDF_TEXTPAGE; index: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_IsHyphen
//          Get if a character in a page is a hyphen.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return value:
//          1 if the character is a hyphen.
//          0 if the character is not a hyphen.
//          -1 if there was an error.
//
var
  FPDFText_IsHyphen: function(text_page: FPDF_TEXTPAGE; index: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_HasUnicodeMapError
//          Get if a character in a page has an invalid unicode mapping.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return value:
//          1 if the character has an invalid unicode mapping.
//          0 if the character has no known unicode mapping issues.
//          -1 if there was an error.
//
var
  FPDFText_HasUnicodeMapError: function(text_page: FPDF_TEXTPAGE; index: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetFontSize
//          Get the font size of a particular character.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return value:
//          The font size of the particular character, measured in points (about
//          1/72 inch). This is the typographic size of the font (so called
//          "em size").
//
var
  FPDFText_GetFontSize: function(text_page: FPDF_TEXTPAGE; index: Integer): Double; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_GetFontInfo
//          Get the font name and flags of a particular character.
// Parameters:
//          text_page - Handle to a text page information structure.
//                      Returned by FPDFText_LoadPage function.
//          index     - Zero-based index of the character.
//          buffer    - A buffer receiving the font name.
//          buflen    - The length of |buffer| in bytes.
//          flags     - Optional pointer to an int receiving the font flags.
//                      These flags should be interpreted per PDF spec 1.7
//                      Section 5.7.1 Font Descriptor Flags.
// Return value:
//          On success, return the length of the font name, including the
//          trailing NUL character, in bytes. If this length is less than or
//          equal to |length|, |buffer| is set to the font name, |flags| is
//          set to the font flags. |buffer| is in UTF-8 encoding. Return 0 on
//          failure.
//
var
  FPDFText_GetFontInfo: function(text_page: FPDF_TEXTPAGE; index: Integer; buffer: Pointer; buflen: LongWord;
    flags: PInteger): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_GetFontWeight
//          Get the font weight of a particular character.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return value:
//          On success, return the font weight of the particular character. If
//          |text_page| is invalid, if |index| is out of bounds, or if the
//          character's text object is undefined, return -1.
//
var
  FPDFText_GetFontWeight: function(text_page: FPDF_TEXTPAGE; index: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_GetTextRenderMode
//          Get text rendering mode of character.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return Value:
//          On success, return the render mode value. A valid value is of type
//          FPDF_TEXT_RENDERMODE. If |text_page| is invalid, if |index| is out
//          of bounds, or if the text object is undefined, then return
//          FPDF_TEXTRENDERMODE_UNKNOWN.
//
var
  FPDFText_GetTextRenderMode: function(text_page: FPDF_TEXTPAGE; index: Integer): FPDF_TEXT_RENDERMODE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_GetFillColor
//          Get the fill color of a particular character.
// Parameters:
//          text_page      -   Handle to a text page information structure.
//                             Returned by FPDFText_LoadPage function.
//          index          -   Zero-based index of the character.
//          R              -   Pointer to an unsigned int number receiving the
//                             red value of the fill color.
//          G              -   Pointer to an unsigned int number receiving the
//                             green value of the fill color.
//          B              -   Pointer to an unsigned int number receiving the
//                             blue value of the fill color.
//          A              -   Pointer to an unsigned int number receiving the
//                             alpha value of the fill color.
// Return value:
//          Whether the call succeeded. If false, |R|, |G|, |B| and |A| are
//          unchanged.
//
var
  FPDFText_GetFillColor: function(text_page: FPDF_TEXTPAGE; index: Integer; var R, G, B, A: Cardinal): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_GetStrokeColor
//          Get the stroke color of a particular character.
// Parameters:
//          text_page      -   Handle to a text page information structure.
//                             Returned by FPDFText_LoadPage function.
//          index          -   Zero-based index of the character.
//          R              -   Pointer to an unsigned int number receiving the
//                             red value of the stroke color.
//          G              -   Pointer to an unsigned int number receiving the
//                             green value of the stroke color.
//          B              -   Pointer to an unsigned int number receiving the
//                             blue value of the stroke color.
//          A              -   Pointer to an unsigned int number receiving the
//                             alpha value of the stroke color.
// Return value:
//          Whether the call succeeded. If false, |R|, |G|, |B| and |A| are
//          unchanged.
//
var
  FPDFText_GetStrokeColor: function(text_page: FPDF_TEXTPAGE; index: Integer; var R, G, B, A: Cardinal): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_GetCharAngle
//          Get character rotation angle.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return Value:
//          On success, return the angle value in radian. Value will always be
//          greater or equal to 0. If |text_page| is invalid, or if |index| is
//          out of bounds, then return -1.
//
var
  FPDFText_GetCharAngle: function(text_page: FPDF_TEXTPAGE; index: Integer): Single; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetCharBox
//          Get bounding box of a particular character.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
//          left        -   Pointer to a double number receiving left position of the character box.
//          right       -   Pointer to a double number receiving right position of the character box.
//          bottom      -   Pointer to a double number receiving bottom position of the character box.
//          top         -   Pointer to a double number receiving top position of the character box.
// Return Value:
//          On success, return TRUE and fill in |left|, |right|, |bottom|, and
//          |top|. If |text_page| is invalid, or if |index| is out of bounds,
//          then return FALSE, and the out parameters remain unmodified.
// Comments:
//          All positions are measured in PDF "user space".
//
var
  FPDFText_GetCharBox: procedure(text_page: FPDF_TEXTPAGE; index: Integer; var left, right, bottom, top: Double); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_GetLooseCharBox
//          Get a "loose" bounding box of a particular character, i.e., covering
//          the entire glyph bounds, without taking the actual glyph shape into
//          account.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
//          rect        -   Pointer to a FS_RECTF receiving the character box.
// Return Value:
//          On success, return TRUE and fill in |rect|. If |text_page| is
//          invalid, or if |index| is out of bounds, then return FALSE, and the
//          |rect| out parameter remains unmodified.
// Comments:
//          All positions are measured in PDF "user space".
//
var
  FPDFText_GetLooseCharBox: function(text_page: FPDF_TEXTPAGE; index: Integer; rect: PFS_RECTF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFText_GetMatrix
//          Get the effective transformation matrix for a particular character.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage().
//          index       -   Zero-based index of the character.
//          matrix      -   Pointer to a FS_MATRIX receiving the transformation
//                          matrix.
// Return Value:
//          On success, return TRUE and fill in |matrix|. If |text_page| is
//          invalid, or if |index| is out of bounds, or if |matrix| is NULL,
//          then return FALSE, and |matrix| remains unmodified.
//
var
  FPDFText_GetMatrix: function(text_page: FPDF_TEXTPAGE; index: Integer; matrix: PFS_MATRIX): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetCharOrigin
//          Get origin of a particular character.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
//          x           -   Pointer to a double number receiving x coordinate of
//                          the character origin.
//          y           -   Pointer to a double number receiving y coordinate of
//                          the character origin.
// Return Value:
//          Whether the call succeeded. If false, x and y are unchanged.
// Comments:
//          All positions are measured in PDF "user space".
//
var
  FPDFText_GetCharOrigin: function(text_page: FPDF_TEXTPAGE; index: Integer; var x, y: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetCharIndexAtPos
//          Get the index of a character at or nearby a certain position on the
//          page.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          x           -   X position in PDF "user space".
//          y           -   Y position in PDF "user space".
//          xTolerance  -   An x-axis tolerance value for character hit
//                          detection, in point units.
//          yTolerance  -   A y-axis tolerance value for character hit
//                          detection, in point units.
// Return Value:
//          The zero-based index of the character at, or nearby the point (x,y).
//          If there is no character at or nearby the point, return value will
//          be -1. If an error occurs, -3 will be returned.
//
var
  FPDFText_GetCharIndexAtPos: function(text_page: FPDF_TEXTPAGE; x, y, xTorelance, yTolerance: Double): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetText
//          Extract unicode text string from the page.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          start_index -   Index for the start characters.
//          count       -   Number of characters to be extracted.
//          result      -   A buffer (allocated by application) receiving the
//                          extracted unicodes. The size of the buffer must be
//                          able to hold the number of characters plus a
//                          terminator.
// Return Value:
//          Number of characters written into the result buffer, including the
//          trailing terminator.
// Comments:
//          This function ignores characters without unicode information.
//          It returns all characters on the page, even those that are not
//          visible when the page has a cropbox. To filter out the characters
//          outside of the cropbox, use FPDF_GetPageBoundingBox() and
//          FPDFText_GetCharBox().
//
var
  FPDFText_GetText: function(text_page: FPDF_TEXTPAGE; start_index, count: Integer; result: PWideChar): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_CountRects
//          Counts number of rectangular areas occupied by a segment of text,
//          and caches the result for subsequent FPDFText_GetRect() calls.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          start_index -   Index for the start character.
//          count       -   Number of characters, or -1 for all remaining.
// Return value:
//          Number of rectangles, 0 if text_page is null, or -1 on bad
//          start_index.
// Comments:
//          This function, along with FPDFText_GetRect can be used by
//          applications to detect the position on the page for a text segment,
//          so proper areas can be highlighted. The FPDFText_* functions will
//          automatically merge small character boxes into bigger one if those
//          characters are on the same line and use same font settings.
//
var
  FPDFText_CountRects: function(text_page: FPDF_TEXTPAGE; start_index, count: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetRect
//          Get a rectangular area from the result generated by
//          FPDFText_CountRects.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          rect_index  -   Zero-based index for the rectangle.
//          left        -   Pointer to a double value receiving the rectangle
//                          left boundary.
//          top         -   Pointer to a double value receiving the rectangle
//                          top boundary.
//          right       -   Pointer to a double value receiving the rectangle
//                          right boundary.
//          bottom      -   Pointer to a double value receiving the rectangle
//                          bottom boundary.
// Return Value:
//          On success, return TRUE and fill in |left|, |top|, |right|, and
//          |bottom|. If |text_page| is invalid then return FALSE, and the out
//          parameters remain unmodified. If |text_page| is valid but
//          |rect_index| is out of bounds, then return FALSE and set the out
//          parameters to 0.
//
var
  FPDFText_GetRect: procedure(text_page: FPDF_TEXTPAGE; rect_index: Integer; var left, top, right, bottom: Double); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetBoundedText
//          Extract unicode text within a rectangular boundary on the page.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
//          left        -   Left boundary.
//          top         -   Top boundary.
//          right       -   Right boundary.
//          bottom      -   Bottom boundary.
//          buffer      -   A unicode buffer.
//          buflen      -   Number of characters (not bytes) for the buffer,
//                          excluding an additional terminator.
// Return Value:
//          If buffer is NULL or buflen is zero, return number of characters
//          (not bytes) of text present within the rectangle, excluding a
//          terminating NUL. Generally you should pass a buffer at least one
//          larger than this if you want a terminating NUL, which will be
//          provided if space is available. Otherwise, return number of
//          characters copied into the buffer, including the terminating NUL
//          when space for it is available.
// Comment:
//          If the buffer is too small, as much text as will fit is copied into
//          it.
//
var
  FPDFText_GetBoundedText: function(text_page: FPDF_TEXTPAGE; left, top, right, bottom: Double;
    buffer: PWideChar; buflen: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

const
  // Flags used by FPDFText_FindStart function.
  FPDF_MATCHCASE      = $00000001; // If not set, it will not match case by default.
  FPDF_MATCHWHOLEWORD = $00000002; // If not set, it will not match the whole word by default.
  FPDF_CONSECUTIVE    = $00000004; // If not set, it will skip past the current match to look for the next match.

// Function: FPDFText_FindStart
//          Start a search.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          findwhat    -   A unicode match pattern.
//          flags       -   Option flags.
//          start_index -   Start from this character. -1 for end of the page.
// Return Value:
//          A handle for the search context. FPDFText_FindClose must be called
//          to release this handle.
//
var
  FPDFText_FindStart: function(text_page: FPDF_TEXTPAGE; findwhat: FPDF_WIDESTRING; flags: LongWord;
    start_index: Integer): FPDF_SCHHANDLE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_FindNext
//          Search in the direction from page start to end.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          Whether a match is found.
//
var
  FPDFText_FindNext: function(handle: FPDF_SCHHANDLE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_FindPrev
//          Search in the direction from page end to start.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          Whether a match is found.
//
var
  FPDFText_FindPrev: function(handle: FPDF_SCHHANDLE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetSchResultIndex
//          Get the starting character index of the search result.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          Index for the starting character.
//
var
  FPDFText_GetSchResultIndex: function(handle: FPDF_SCHHANDLE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_GetSchCount
//          Get the number of matched characters in the search result.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          Number of matched characters.
//
var
  FPDFText_GetSchCount: function(handle: FPDF_SCHHANDLE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFText_FindClose
//          Release a search context.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          None.
//
var
  FPDFText_FindClose: procedure(handle: FPDF_SCHHANDLE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFLink_LoadWebLinks
//          Prepare information about weblinks in a page.
// Parameters:
//          text_page   -   Handle to a text page information structure.
//                          Returned by FPDFText_LoadPage function.
// Return Value:
//          A handle to the page's links information structure, or
//          NULL if something goes wrong.
// Comments:
//          Weblinks are those links implicitly embedded in PDF pages. PDF also
//          has a type of annotation called "link" (FPDFTEXT doesn't deal with
//          that kind of link). FPDFTEXT weblink feature is useful for
//          automatically detecting links in the page contents. For example,
//          things like "https://www.example.com" will be detected, so
//          applications can allow user to click on those characters to activate
//          the link, even the PDF doesn't come with link annotations.
//
//          FPDFLink_CloseWebLinks must be called to release resources.
//
var
  FPDFLink_LoadWebLinks: function(text_page: FPDF_TEXTPAGE): FPDF_PAGELINK; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFLink_CountWebLinks
//          Count number of detected web links.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
// Return Value:
//          Number of detected web links.
//
var
  FPDFLink_CountWebLinks: function(link_page: FPDF_PAGELINK): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFLink_GetURL
//          Fetch the URL information for a detected web link.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
//          link_index  -   Zero-based index for the link.
//          buffer      -   A unicode buffer for the result.
//          buflen      -   Number of 16-bit code units (not bytes) for the
//                          buffer, including an additional terminator.
// Return Value:
//          If |buffer| is NULL or |buflen| is zero, return the number of 16-bit
//          code units (not bytes) needed to buffer the result (an additional
//          terminator is included in this count).
//          Otherwise, copy the result into |buffer|, truncating at |buflen| if
//          the result is too large to fit, and return the number of 16-bit code
//          units actually copied into the buffer (the additional terminator is
//          also included in this count).
//          If |link_index| does not correspond to a valid link, then the result
//          is an empty string.
//
var
  FPDFLink_GetURL: function(link_page: FPDF_PAGELINK; link_index: Integer; buffer: PWideChar; buflen: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFLink_CountRects
//          Count number of rectangular areas for the link.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
//          link_index  -   Zero-based index for the link.
// Return Value:
//          Number of rectangular areas for the link.  If |link_index| does
//          not correspond to a valid link, then 0 is returned.
//
var
  FPDFLink_CountRects: function(link_page: FPDF_PAGELINK; link_index: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFLink_GetRect
//          Fetch the boundaries of a rectangle for a link.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
//          link_index  -   Zero-based index for the link.
//          rect_index  -   Zero-based index for a rectangle.
//          left        -   Pointer to a double value receiving the rectangle
//                          left boundary.
//          top         -   Pointer to a double value receiving the rectangle
//                          top boundary.
//          right       -   Pointer to a double value receiving the rectangle
//                          right boundary.
//          bottom      -   Pointer to a double value receiving the rectangle
//                          bottom boundary.
// Return Value:
//          On success, return TRUE and fill in |left|, |top|, |right|, and
//          |bottom|. If |link_page| is invalid or if |link_index| does not
//          correspond to a valid link, then return FALSE, and the out
//          parameters remain unmodified.
//
var
  FPDFLink_GetRect: procedure(link_page: FPDF_PAGELINK; link_index, rect_index: Integer;
    var left, top, right, bottom: Double); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFLink_GetTextRange
//          Fetch the start char index and char count for a link.
// Parameters:
//          link_page         -   Handle returned by FPDFLink_LoadWebLinks.
//          link_index        -   Zero-based index for the link.
//          start_char_index  -   pointer to int receiving the start char index
//          char_count        -   pointer to int receiving the char count
// Return Value:
//          On success, return TRUE and fill in |start_char_index| and
//          |char_count|. if |link_page| is invalid or if |link_index| does
//          not correspond to a valid link, then return FALSE and the out
//          parameters remain unmodified.
//
var
  FPDFLink_GetTextRange: function(link_page: FPDF_PAGELINK; link_index: Integer;
    start_char_index, char_count: PInteger): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDFLink_CloseWebLinks
//          Release resources used by weblink feature.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
// Return Value:
//          None.
//
var
  FPDFLink_CloseWebLinks: procedure(link_page: FPDF_PAGELINK); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_SEARCH_EX_H ***

// Get the character index in |text_page| internal character list.
//
//   text_page  - a text page information structure.
//   nTextIndex - index of the text returned from FPDFText_GetText().
//
// Returns the index of the character in internal character list. -1 for error.
var
  FPDFText_GetCharIndexFromTextIndex: function(text_page: FPDF_TEXTPAGE; nTextIndex: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// Get the text index in |text_page| internal character list.
//
//   text_page  - a text page information structure.
//   nCharIndex - index of the character in internal character list.
//
// Returns the index of the text returned from FPDFText_GetText(). -1 for error.
var
  FPDFText_GetTextIndexFromCharIndex: function(text_page: FPDF_TEXTPAGE; nCharIndex: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_PROGRESSIVE_H_ ***

const
  //Flags for progressive process status.
  FPDF_RENDER_READER         = 0;
  FPDF_RENDER_TOBECOUNTINUED = 1;
  FPDF_RENDER_DONE           = 2;
  FPDF_RENDER_FAILED         = 3;

// IFPDF_RENDERINFO interface.
type
  PIFSDK_PAUSE = ^IFSDK_PAUSE;
  IFSDK_PAUSE = record
    //*
    //* Version number of the interface. Currently must be 1.
    //*
    version: Integer;

    //*
    //* Method: NeedToPauseNow
    //*      Check if we need to pause a progressive process now.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself
    //* Return Value:
    //*       Non-zero for pause now, 0 for continue.
    //*
    //*
    NeedToPauseNow: function(pThis: PIFSDK_PAUSE): FPDF_BOOL; cdecl;

    // A user defined data pointer, used by user's application. Can be NULL.
    user: Pointer;
  end;
  PIFSDKPause = ^TIFSDKPause;
  TIFSDKPause = IFSDK_PAUSE;

// Experimental API.
// Function: FPDF_RenderPageBitmapWithColorScheme_Start
//          Start to render page contents to a device independent bitmap
//          progressively with a specified color scheme for the content.
// Parameters:
//          bitmap       -   Handle to the device independent bitmap (as the
//                           output buffer). Bitmap handle can be created by
//                           FPDFBitmap_Create function.
//          page         -   Handle to the page as returned by FPDF_LoadPage
//                           function.
//          start_x      -   Left pixel position of the display area in the
//                           bitmap coordinate.
//          start_y      -   Top pixel position of the display area in the
//                           bitmap coordinate.
//          size_x       -   Horizontal size (in pixels) for displaying the
//                           page.
//          size_y       -   Vertical size (in pixels) for displaying the page.
//          rotate       -   Page orientation: 0 (normal), 1 (rotated 90
//                           degrees clockwise), 2 (rotated 180 degrees),
//                           3 (rotated 90 degrees counter-clockwise).
//          flags        -   0 for normal display, or combination of flags
//                           defined in fpdfview.h. With FPDF_ANNOT flag, it
//                           renders all annotations that does not require
//                           user-interaction, which are all annotations except
//                           widget and popup annotations.
//          color_scheme -   Color scheme to be used in rendering the |page|.
//                           If null, this function will work similar to
//                           FPDF_RenderPageBitmap_Start().
//          pause        -   The IFSDK_PAUSE interface. A callback mechanism
//                           allowing the page rendering process.
// Return value:
//          Rendering Status. See flags for progressive process status for the
//          details.
var
  FPDF_RenderPageBitmapWithColorScheme_Start: function(bitmap: FPDF_BITMAP; page: FPDF_PAGE;
    start_x, start_y, size_x, size_y: Integer; rotate: Integer; flags: Integer;
    const color_scheme: PFPDF_COLORSCHEME; pause: PIFSDK_PAUSE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_RenderPageBitmap_Start
//          Start to render page contents to a device independent bitmap
//          progressively.
// Parameters:
//          bitmap      -   Handle to the device independent bitmap (as the
//                          output buffer). Bitmap handle can be created by
//                          FPDFBitmap_Create().
//          page        -   Handle to the page, as returned by FPDF_LoadPage().
//          start_x     -   Left pixel position of the display area in the
//                          bitmap coordinates.
//          start_y     -   Top pixel position of the display area in the bitmap
//                          coordinates.
//          size_x      -   Horizontal size (in pixels) for displaying the page.
//          size_y      -   Vertical size (in pixels) for displaying the page.
//          rotate      -   Page orientation: 0 (normal), 1 (rotated 90 degrees
//                          clockwise), 2 (rotated 180 degrees), 3 (rotated 90
//                          degrees counter-clockwise).
//          flags       -   0 for normal display, or combination of flags
//                          defined in fpdfview.h. With FPDF_ANNOT flag, it
//                          renders all annotations that does not require
//                          user-interaction, which are all annotations except
//                          widget and popup annotations.
//          pause       -   The IFSDK_PAUSE interface.A callback mechanism
//                          allowing the page rendering process
// Return value:
//          Rendering Status. See flags for progressive process status for the
//          details.
var
  FPDF_RenderPageBitmap_Start: function(bitmap: FPDF_BITMAP; page: FPDF_PAGE;
    start_x, start_y, size_x, size_y: Integer; rotate: Integer; flags: Integer;
    pause: PIFSDK_PAUSE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_RenderPage_Continue
//          Continue rendering a PDF page.
// Parameters:
//          page        -   Handle to the page, as returned by FPDF_LoadPage().
//          pause       -   The IFSDK_PAUSE interface (a callback mechanism
//                          allowing the page rendering process to be paused
//                          before it's finished). This can be NULL if you
//                          don't want to pause.
// Return value:
//          The rendering status. See flags for progressive process status for
//          the details.
var
  FPDF_RenderPage_Continue: function(page: FPDF_PAGE; pause: PIFSDK_PAUSE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_RenderPage_Close
//          Release the resource allocate during page rendering. Need to be
//          called after finishing rendering or
//          cancel the rendering.
// Parameters:
//          page        -   Handle to the page, as returned by FPDF_LoadPage().
// Return value:
//          None.
var
  FPDF_RenderPage_Close: procedure(page: FPDF_PAGE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_SIGNATURE_H_ ***

// Experimental API.
// Function: FPDF_GetSignatureCount
//          Get total number of signatures in the document.
// Parameters:
//          document    -   Handle to document. Returned by FPDF_LoadDocument().
// Return value:
//          Total number of signatures in the document on success, -1 on error.
var
  FPDF_GetSignatureCount: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_GetSignatureObject
//          Get the Nth signature of the document.
// Parameters:
//          document    -   Handle to document. Returned by FPDF_LoadDocument().
//          index       -   Index into the array of signatures of the document.
// Return value:
//          Returns the handle to the signature, or NULL on failure. The caller
//          does not take ownership of the returned FPDF_SIGNATURE. Instead, it
//          remains valid until FPDF_CloseDocument() is called for the document.
var
  FPDF_GetSignatureObject: function(document: FPDF_DOCUMENT; index: Integer): FPDF_SIGNATURE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFSignatureObj_GetContents
//          Get the contents of a signature object.
// Parameters:
//          signature   -   Handle to the signature object. Returned by
//                          FPDF_GetSignatureObject().
//          buffer      -   The address of a buffer that receives the contents.
//          length      -   The size, in bytes, of |buffer|.
// Return value:
//          Returns the number of bytes in the contents on success, 0 on error.
//
// For public-key signatures, |buffer| is either a DER-encoded PKCS#1 binary or
// a DER-encoded PKCS#7 binary. If |length| is less than the returned length, or
// |buffer| is NULL, |buffer| will not be modified.
var
  FPDFSignatureObj_GetContents: function(signature: FPDF_SIGNATURE; buffer: Pointer; length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFSignatureObj_GetByteRange
//          Get the byte range of a signature object.
// Parameters:
//          signature   -   Handle to the signature object. Returned by
//                          FPDF_GetSignatureObject().
//          buffer      -   The address of a buffer that receives the
//                          byte range.
//          length      -   The size, in ints, of |buffer|.
// Return value:
//          Returns the number of ints in the byte range on
//          success, 0 on error.
//
// |buffer| is an array of pairs of integers (starting byte offset,
// length in bytes) that describes the exact byte range for the digest
// calculation. If |length| is less than the returned length, or
// |buffer| is NULL, |buffer| will not be modified.
var
  FPDFSignatureObj_GetByteRange: function(signature: FPDF_SIGNATURE; buffer: PInteger; length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFSignatureObj_GetSubFilter
//          Get the encoding of the value of a signature object.
// Parameters:
//          signature   -   Handle to the signature object. Returned by
//                          FPDF_GetSignatureObject().
//          buffer      -   The address of a buffer that receives the encoding.
//          length      -   The size, in bytes, of |buffer|.
// Return value:
//          Returns the number of bytes in the encoding name (including the
//          trailing NUL character) on success, 0 on error.
//
// The |buffer| is always encoded in 7-bit ASCII. If |length| is less than the
// returned length, or |buffer| is NULL, |buffer| will not be modified.
var
  FPDFSignatureObj_GetSubFilter: function(signature: FPDF_SIGNATURE; buffer: PAnsiChar; length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFSignatureObj_GetReason
//          Get the reason (comment) of the signature object.
// Parameters:
//          signature   -   Handle to the signature object. Returned by
//                          FPDF_GetSignatureObject().
//          buffer      -   The address of a buffer that receives the reason.
//          length      -   The size, in bytes, of |buffer|.
// Return value:
//          Returns the number of bytes in the reason on success, 0 on error.
//
// Regardless of the platform, the |buffer| is always in UTF-16LE encoding. The
// string is terminated by a UTF16 NUL character. If |length| is less than the
// returned length, or |buffer| is NULL, |buffer| will not be modified.
var
  FPDFSignatureObj_GetReason: function(signature: FPDF_SIGNATURE; buffer: Pointer; length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFSignatureObj_GetTime
//          Get the time of signing of a signature object.
// Parameters:
//          signature   -   Handle to the signature object. Returned by
//                          FPDF_GetSignatureObject().
//          buffer      -   The address of a buffer that receives the time.
//          length      -   The size, in bytes, of |buffer|.
// Return value:
//          Returns the number of bytes in the encoding name (including the
//          trailing NUL character) on success, 0 on error.
//
// The |buffer| is always encoded in 7-bit ASCII. If |length| is less than the
// returned length, or |buffer| is NULL, |buffer| will not be modified.
//
// The format of time is expected to be D:YYYYMMDDHHMMSS+XX'YY', i.e. it's
// percision is seconds, with timezone information. This value should be used
// only when the time of signing is not available in the (PKCS#7 binary)
// signature.
var
  FPDFSignatureObj_GetTime: function(signature: FPDF_SIGNATURE; buffer: PAnsiChar; length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDFSignatureObj_GetDocMDPPermission
//          Get the DocMDP permission of a signature object.
// Parameters:
//          signature   -   Handle to the signature object. Returned by
//                          FPDF_GetSignatureObject().
// Return value:
//          Returns the permission (1, 2 or 3) on success, 0 on error.
var
  FPDFSignatureObj_GetDocMDPPermission: function(signature: FPDF_SIGNATURE): UInt32; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// *** _FPDF_DOC_H_ ***

const
  PDFACTION_UNSUPPORTED  = 0;    // Unsupported action type.
  PDFACTION_GOTO         = 1;    // Go to a destination within current document.
  PDFACTION_REMOTEGOTO   = 2;    // Go to a destination within another document.
  PDFACTION_URI          = 3;    // Universal Resource Identifier, including web pages and
                                 // other Internet based resources.
  PDFACTION_LAUNCH       = 4;    // Launch an application or open a file.
  PDFACTION_EMBEDDEDGOTO = 5;    // Go to a destination in an embedded file.

// View destination fit types. See pdfmark reference v9, page 48.
  PDFDEST_VIEW_UNKNOWN_MODE = 0;
  PDFDEST_VIEW_XYZ = 1;
  PDFDEST_VIEW_FIT = 2;
  PDFDEST_VIEW_FITH = 3;
  PDFDEST_VIEW_FITV = 4;
  PDFDEST_VIEW_FITR = 5;
  PDFDEST_VIEW_FITB = 6;
  PDFDEST_VIEW_FITBH = 7;
  PDFDEST_VIEW_FITBV = 8;

// The file identifier entry type. See section 14.4 "File Identifiers" of the
// ISO 32000-1:2008 spec.
type
  FPDF_FILEIDTYPE = (
    FILEIDTYPE_PERMANENT = 0,
    FILEIDTYPE_CHANGING = 1
  );

// Get the first child of |bookmark|, or the first top-level bookmark item.
//
//   document - handle to the document.
//   bookmark - handle to the current bookmark. Pass NULL for the first top
//              level item.
//
// Returns a handle to the first child of |bookmark| or the first top-level
// bookmark item. NULL if no child or top-level bookmark found.
var
  FPDFBookmark_GetFirstChild: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_BOOKMARK; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the next sibling of |bookmark|.
//
//   document - handle to the document.
//   bookmark - handle to the current bookmark.
//
// Returns a handle to the next sibling of |bookmark|, or NULL if this is the
// last bookmark at this level.
//
// Note that the caller is responsible for handling circular bookmark
// references, as may arise from malformed documents.
var
  FPDFBookmark_GetNextSibling: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_BOOKMARK; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the title of |bookmark|.
//
//   bookmark - handle to the bookmark.
//   buffer   - buffer for the title. May be NULL.
//   buflen   - the length of the buffer in bytes. May be 0.
//
// Returns the number of bytes in the title, including the terminating NUL
// character. The number of bytes is returned regardless of the |buffer| and
// |buflen| parameters.
//
// Regardless of the platform, the |buffer| is always in UTF-16LE encoding. The
// string is terminated by a UTF16 NUL character. If |buflen| is less than the
// required length, or |buffer| is NULL, |buffer| will not be modified.
var
  FPDFBookmark_GetTitle: function(bookmark: FPDF_BOOKMARK; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the number of chlidren of |bookmark|.
//
//   bookmark - handle to the bookmark.
//
// Returns a signed integer that represents the number of sub-items the given
// bookmark has. If the value is positive, child items shall be shown by default
// (open state). If the value is negative, child items shall be hidden by
// default (closed state). Please refer to PDF 32000-1:2008, Table 153.
// Returns 0 if the bookmark has no children or is invalid.
var
  FPDFBookmark_GetCount: function(bookmark: FPDF_BOOKMARK): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Find the bookmark with |title| in |document|.
//
//   document - handle to the document.
//   title    - the UTF-16LE encoded Unicode title for which to search.
//
// Returns the handle to the bookmark, or NULL if |title| can't be found.
//
// FPDFBookmark_Find() will always return the first bookmark found even if
// multiple bookmarks have the same |title|.
var
  FPDFBookmark_Find: function(document: FPDF_DOCUMENT; title: FPDF_WIDESTRING): FPDF_BOOKMARK; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the destination associated with |bookmark|.
//
//   document - handle to the document.
//   bookmark - handle to the bookmark.
//
// Returns the handle to the destination data, or NULL if no destination is
// associated with |bookmark|.
var
  FPDFBookmark_GetDest: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_DEST; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the action associated with |bookmark|.
//
//   bookmark - handle to the bookmark.
//
// Returns the handle to the action data, or NULL if no action is associated
// with |bookmark|.
// If this function returns a valid handle, it is valid as long as |bookmark| is
// valid.
// If this function returns NULL, FPDFBookmark_GetDest() should be called to get
// the |bookmark| destination data.
var
  FPDFBookmark_GetAction: function(bookmark: FPDF_BOOKMARK): FPDF_ACTION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the type of |action|.
//
//   action - handle to the action.
//
// Returns one of:
//   PDFACTION_UNSUPPORTED
//   PDFACTION_GOTO
//   PDFACTION_REMOTEGOTO
//   PDFACTION_URI
//   PDFACTION_LAUNCH
var
  FPDFAction_GetType: function(action: FPDF_ACTION): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the destination of |action|.
//
//   document - handle to the document.
//   action   - handle to the action. |action| must be a |PDFACTION_GOTO| or
//              |PDFACTION_REMOTEGOTO|.
//
// Returns a handle to the destination data, or NULL on error, typically
// because the arguments were bad or the action was of the wrong type.
//
// In the case of |PDFACTION_REMOTEGOTO|, you must first call
// FPDFAction_GetFilePath(), then load the document at that path, then pass
// the document handle from that document as |document| to FPDFAction_GetDest().
var
  FPDFAction_GetDest: function(document: FPDF_DOCUMENT; action: FPDF_ACTION): FPDF_DEST; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the file path of |action|.
//
//   action - handle to the action. |action| must be a |PDFACTION_LAUNCH| or
//            |PDFACTION_REMOTEGOTO|.
//   buffer - a buffer for output the path string. May be NULL.
//   buflen - the length of the buffer, in bytes. May be 0.
//
// Returns the number of bytes in the file path, including the trailing NUL
// character, or 0 on error, typically because the arguments were bad or the
// action was of the wrong type.
//
// Regardless of the platform, the |buffer| is always in UTF-8 encoding.
// If |buflen| is less than the returned length, or |buffer| is NULL, |buffer|
// will not be modified.
var
  FPDFAction_GetFilePath: function(action: FPDF_ACTION; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the URI path of |action|.
//
//   document - handle to the document.
//   action   - handle to the action. Must be a |PDFACTION_URI|.
//   buffer   - a buffer for the path string. May be NULL.
//   buflen   - the length of the buffer, in bytes. May be 0.
//
// Returns the number of bytes in the URI path, including the trailing NUL
// character, or 0 on error, typically because the arguments were bad or the
// action was of the wrong type.
//
// The |buffer| may contain badly encoded data. The caller should validate the
// output. e.g. Check to see if it is UTF-8.
//
// If |buflen| is less than the returned length, or |buffer| is NULL, |buffer|
// will not be modified.
//
// Historically, the documentation for this API claimed |buffer| is always
// encoded in 7-bit ASCII, but did not actually enforce it.
// https://pdfium.googlesource.com/pdfium.git/+/d609e84cee2e14a18333247485af91df48a40592
// added that enforcement, but that did not work well for real world PDFs that
// used UTF-8. As of this writing, this API reverted back to its original
// behavior prior to commit d609e84cee.
var
  FPDFAction_GetURIPath: function(document: FPDF_DOCUMENT; action: FPDF_ACTION; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the page index of |dest|.
//
//   document - handle to the document.
//   dest     - handle to the destination.
//
// Returns the 0-based page index containing |dest|. Returns -1 on error.
var
  FPDFDest_GetDestPageIndex: function(document: FPDF_DOCUMENT; dest: FPDF_DEST): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the view (fit type) specified by |dest|.
//
//   dest         - handle to the destination.
//   pNumParams   - receives the number of view parameters, which is at most 4.
//   pParams      - buffer to write the view parameters. Must be at least 4
//                  FS_FLOATs long.
// Returns one of the PDFDEST_VIEW_* constants, PDFDEST_VIEW_UNKNOWN_MODE if
// |dest| does not specify a view.
var
  FPDFDest_GetView: function(dest: FPDF_DEST; pNumParams: PLongWord; pParams: PFS_FLOAT): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the (x, y, zoom) location of |dest| in the destination page, if the
// destination is in [page /XYZ x y zoom] syntax.
//
//   dest       - handle to the destination.
//   hasXVal    - out parameter; true if the x value is not null
//   hasYVal    - out parameter; true if the y value is not null
//   hasZoomVal - out parameter; true if the zoom value is not null
//   x          - out parameter; the x coordinate, in page coordinates.
//   y          - out parameter; the y coordinate, in page coordinates.
//   zoom       - out parameter; the zoom value.
// Returns TRUE on successfully reading the /XYZ value.
//
// Note the [x, y, zoom] values are only set if the corresponding hasXVal,
// hasYVal or hasZoomVal flags are true.
var
  FPDFDest_GetLocationInPage: function(dest: FPDF_DEST; var hasXVal, hasYVal, hasZoomVal: FPDF_BOOL;
    var x, y, zoom: FS_FLOAT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Find a link at point (|x|,|y|) on |page|.
//
//   page - handle to the document page.
//   x    - the x coordinate, in the page coordinate system.
//   y    - the y coordinate, in the page coordinate system.
//
// Returns a handle to the link, or NULL if no link found at the given point.
//
// You can convert coordinates from screen coordinates to page coordinates using
// FPDF_DeviceToPage().
var
  FPDFLink_GetLinkAtPoint: function(page: FPDF_PAGE; x, y: Double): FPDF_LINK; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Find the Z-order of link at point (|x|,|y|) on |page|.
//
//   page - handle to the document page.
//   x    - the x coordinate, in the page coordinate system.
//   y    - the y coordinate, in the page coordinate system.
//
// Returns the Z-order of the link, or -1 if no link found at the given point.
// Larger Z-order numbers are closer to the front.
//
// You can convert coordinates from screen coordinates to page coordinates using
// FPDF_DeviceToPage().
var
  FPDFLink_GetLinkZOrderAtPoint: function(page: FPDF_PAGE; x, y: Double): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get destination info for |link|.
//
//   document - handle to the document.
//   link     - handle to the link.
//
// Returns a handle to the destination, or NULL if there is no destination
// associated with the link. In this case, you should call FPDFLink_GetAction()
// to retrieve the action associated with |link|.
var
  FPDFLink_GetDest: function(document: FPDF_DOCUMENT; link: FPDF_LINK): FPDF_DEST; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get action info for |link|.
//
//   link - handle to the link.
//
// Returns a handle to the action associated to |link|, or NULL if no action.
// If this function returns a valid handle, it is valid as long as |link| is
// valid.
var
  FPDFLink_GetAction: function(link: FPDF_LINK): FPDF_ACTION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Enumerates all the link annotations in |page|.
//
//   page       - handle to the page.
//   start_pos  - the start position, should initially be 0 and is updated with
//                the next start position on return.
//   link_annot - the link handle for |startPos|.
//
// Returns TRUE on success.
var
  FPDFLink_Enumerate: function(page: FPDF_PAGE; var start_pos: Integer; link_annot: PFPDF_LINK): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets FPDF_ANNOTATION object for |link_annot|.
//
//   page       - handle to the page in which FPDF_LINK object is present.
//   link_annot - handle to link annotation.
//
// Returns FPDF_ANNOTATION from the FPDF_LINK and NULL on failure,
// if the input link annot or page is NULL.
var
  FPDFLink_GetAnnot: function(page: FPDF_PAGE; link_annot: FPDF_LINK): FPDF_ANNOTATION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the rectangle for |link_annot|.
//
//   link_annot - handle to the link annotation.
//   rect       - the annotation rectangle.
//
// Returns true on success.
var
  FPDFLink_GetAnnotRect: function(link_annot: FPDF_LINK; rect: PFS_RECTF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the count of quadrilateral points to the |link_annot|.
//
//   link_annot - handle to the link annotation.
//
// Returns the count of quadrilateral points.
var
  FPDFLink_CountQuadPoints: function(link_annot: FPDF_LINK): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the quadrilateral points for the specified |quad_index| in |link_annot|.
//
//   link_annot  - handle to the link annotation.
//   quad_index  - the specified quad point index.
//   quad_points - receives the quadrilateral points.
//
// Returns true on success.
var
  FPDFLink_GetQuadPoints: function(link_annot: FPDF_LINK; quad_index: Integer; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets an additional-action from |page|.
//
//   page      - handle to the page, as returned by FPDF_LoadPage().
//   aa_type   - the type of the page object's addtional-action, defined
//               in public/fpdf_formfill.h
//
//   Returns the handle to the action data, or NULL if there is no
//   additional-action of type |aa_type|.
//   If this function returns a valid handle, it is valid as long as |page| is
//   valid.
var
  FPDF_GetPageAAction: function(page: FPDF_PAGE; aa_type: Integer): FPDF_ACTION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the file identifer defined in the trailer of |document|.
//
//   document - handle to the document.
//   id_type  - the file identifier type to retrieve.
//   buffer   - a buffer for the file identifier. May be NULL.
//   buflen   - the length of the buffer, in bytes. May be 0.
//
// Returns the number of bytes in the file identifier, including the NUL
// terminator.
//
// The |buffer| is always a byte string. The |buffer| is followed by a NUL
// terminator.  If |buflen| is less than the returned length, or |buffer| is
// NULL, |buffer| will not be modified.
var
  FPDF_GetFileIdentifier: function(document: FPDF_DOCUMENT; id_type: FPDF_FILEIDTYPE; buffer: Pointer;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get meta-data |tag| content from |document|.
//
//   document - handle to the document.
//   tag      - the tag to retrieve. The tag can be one of:
//                Title, Author, Subject, Keywords, Creator, Producer,
//                CreationDate, or ModDate.
//              For detailed explanations of these tags and their respective
//              values, please refer to PDF Reference 1.6, section 10.2.1,
//              'Document Information Dictionary'.
//   buffer   - a buffer for the tag. May be NULL.
//   buflen   - the length of the buffer, in bytes. May be 0.
//
// Returns the number of bytes in the tag, including trailing zeros.
//
// The |buffer| is always encoded in UTF-16LE. The |buffer| is followed by two
// bytes of zeros indicating the end of the string.  If |buflen| is less than
// the returned length, or |buffer| is NULL, |buffer| will not be modified.
//
// For linearized files, FPDFAvail_IsFormAvail must be called before this, and
// it must have returned PDF_FORM_AVAIL or PDF_FORM_NOTEXIST. Before that, there
// is no guarantee the metadata has been loaded.
var
  FPDF_GetMetaText: function(doc: FPDF_DOCUMENT; tag: FPDF_BYTESTRING; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the page label for |page_index| from |document|.
//
//   document    - handle to the document.
//   page_index  - the 0-based index of the page.
//   buffer      - a buffer for the page label. May be NULL.
//   buflen      - the length of the buffer, in bytes. May be 0.
//
// Returns the number of bytes in the page label, including trailing zeros.
//
// The |buffer| is always encoded in UTF-16LE. The |buffer| is followed by two
// bytes of zeros indicating the end of the string.  If |buflen| is less than
// the returned length, or |buffer| is NULL, |buffer| will not be modified.
var
  FPDF_GetPageLabel: function(document: FPDF_DOCUMENT; page_index: integer; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_SYSFONTINFO_H_ ***

const
  // Character sets for the font
  FXFONT_ANSI_CHARSET            = 0;
  FXFONT_DEFAULT_CHARSET         = 1;
  FXFONT_SYMBOL_CHARSET          = 2;
  FXFONT_SHIFTJIS_CHARSET        = 128;
  FXFONT_HANGEUL_CHARSET         = 129;
  FXFONT_GB2312_CHARSET          = 134;
  FXFONT_CHINESEBIG5_CHARSET     = 136;
  FXFONT_GREEK_CHARSET           = 161;
  FXFONT_VIETNAMESE_CHARSET      = 163;
  FXFONT_HEBREW_CHARSET          = 177;
  FXFONT_ARABIC_CHARSET          = 178;
  FXFONT_CYRILLIC_CHARSET        = 204;
  FXFONT_THAI_CHARSET            = 222;
  FXFONT_EASTERNEUROPEAN_CHARSET = 238;


  // Font pitch and family flags
  FXFONT_FF_FIXEDPITCH = 1;
  FXFONT_FF_ROMAN      = 1 shl 4;
  FXFONT_FF_SCRIPT     = 4 shl 4;

  // Typical weight values
  FXFONT_FW_NORMAL = 400;
  FXFONT_FW_BOLD   = 700;

//*
//* Interface: FPDF_SYSFONTINFO
//*      Interface for getting system font information and font mapping
//*
type
  PFPDF_SYSFONTINFO = ^FPDF_SYSFONTINFO;
  FPDF_SYSFONTINFO = record
    //*
    //* Version number of the interface. Currently must be 1.
    //*
    version: Integer;

    //*
    //* Method: Release
    //*          Give implementation a chance to release any data after the
    //* interface is no longer used
    //* Interface Version:
    //*          1
    //* Implementation Required:
    //*          No
    //* Comments:
    //*          Called by Foxit SDK during the final cleanup process.
    //* Parameters:
    //*          pThis       -   Pointer to the interface structure itself
    //* Return Value:
    //*          None
    //*
    Release: procedure(pThis: PFPDF_SYSFONTINFO); cdecl;

    //*
    //* Method: EnumFonts
    //*          Enumerate all fonts installed on the system
    //* Interface Version:
    //*          1
    //* Implementation Required:
    //*          No
    //* Parameters:
    //*          pThis       -   Pointer to the interface structure itself
    //*          pMapper     -   An opaque pointer to internal font mapper, used
    //*                          when calling FPDF_AddInstalledFont().
    //* Return Value:
    //*          None
    //* Comments:
    //*          Implementations should call FPDF_AddIntalledFont() function for
    //*          each font found. Only TrueType/OpenType and Type1 fonts are accepted
    //*          by PDFium.
    //*
    EnumFonts: procedure(pThis: PFPDF_SYSFONTINFO; pMapper: Pointer); cdecl;

    //*
    //* Method: MapFont
    //*          Use the system font mapper to get a font handle from requested
    //*          parameters.
    //* Interface Version:
    //*          1
    //* Implementation Required:
    //*          Required if GetFont method is not implemented.
    //* Parameters:
    //*          pThis       -   Pointer to the interface structure itself
    //*          weight      -   Weight of the requested font. 400 is normal and
    //*                          700 is bold.
    //*          bItalic     -   Italic option of the requested font, TRUE or
    //*                          FALSE.
    //*          charset     -   Character set identifier for the requested font.
    //*                          See above defined constants.
    //*          pitch_family -  A combination of flags. See above defined
    //*                          constants.
    //*          face        -   Typeface name. Currently use system local encoding
    //*                          only.
    //*          bExact      -   Obsolete: this parameter is now ignored.
    //* Return Value:
    //*          An opaque pointer for font handle, or NULL if system mapping is
    //*          not supported.
    //* Comments:
    //*          If the system supports native font mapper (like Windows),
    //*          implementation can implement this method to get a font handle.
    //*          Otherwise, PDFium will do the mapping and then call GetFont
    //*          method. Only TrueType/OpenType and Type1 fonts are accepted
    //*          by PDFium.
    //*
    MapFont: function(pThis: PFPDF_SYSFONTINFO; weight, bItalic, charset, pitch_family: Integer;
      face: PAnsiChar; bExact: PInteger): Pointer; cdecl;

    //*
    //* Method: GetFont
    //*          Get a handle to a particular font by its internal ID
    //* Interface Version:
    //*          1
    //* Implementation Required:
    //*          Required if MapFont method is not implemented.
    //* Return Value:
    //*          An opaque pointer for font handle.
    //* Parameters:
    //*          pThis       -   Pointer to the interface structure itself
    //*          face        -   Typeface name in system local encoding.
    //* Comments:
    //*          If the system mapping not supported, PDFium will do the font
    //*          mapping and use this method to get a font handle.
    //*
    GetFont: function(pThis: PFPDF_SYSFONTINFO; face: PAnsiChar): Pointer; cdecl;

    //*
    //* Method: GetFontData
    //*          Get font data from a font
    //* Interface Version:
    //*          1
    //* Implementation Required:
    //*          Yes
    //* Parameters:
    //*          pThis       -   Pointer to the interface structure itself
    //*          hFont       -   Font handle returned by MapFont or GetFont method
    //*          table       -   TrueType/OpenType table identifier (refer to
    //*                          TrueType specification), or 0 for the whole file.
    //*          buffer      -   The buffer receiving the font data. Can be NULL if
    //*                          not provided.
    //*          buf_size    -   Buffer size, can be zero if not provided.
    //* Return Value:
    //*          Number of bytes needed, if buffer not provided or not large
    //*          enough, or number of bytes written into buffer otherwise.
    //* Comments:
    //*          Can read either the full font file, or a particular
    //*          TrueType/OpenType table.
    //*
    GetFontData: function(pThis: PFPDF_SYSFONTINFO; hFont: Pointer; table: LongWord; buffer: PWideChar;
      buf_size: LongWord): LongWord; cdecl;

    //*
    //* Method: GetFaceName
    //*          Get face name from a font handle
    //* Interface Version:
    //*          1
    //* Implementation Required:
    //*          No
    //* Parameters:
    //*          pThis       -   Pointer to the interface structure itself
    //*          hFont       -   Font handle returned by MapFont or GetFont method
    //*          buffer      -   The buffer receiving the face name. Can be NULL if
    //*                          not provided
    //*          buf_size    -   Buffer size, can be zero if not provided
    //* Return Value:
    //*          Number of bytes needed, if buffer not provided or not large
    //*          enough, or number of bytes written into buffer otherwise.
    //*
    GetFaceName: function(pThis: PFPDF_SYSFONTINFO; hFont: Pointer; buffer: PAnsiChar; buf_size: LongWord): LongWord; cdecl;

    //*
    //* Method: GetFontCharset
    //*          Get character set information for a font handle
    //* Interface Version:
    //*          1
    //* Implementation Required:
    //*          No
    //* Parameters:
    //*          pThis       -   Pointer to the interface structure itself
    //*          hFont       -   Font handle returned by MapFont or GetFont method
    //* Return Value:
    //*          Character set identifier. See defined constants above.
    //*
    GetFontCharset: function(pThis: PFPDF_SYSFONTINFO; hFont: Pointer): Integer; cdecl;

    //*
    //* Method: DeleteFont
    //*          Delete a font handle
    //* Interface Version:
    //*          1
    //* Implementation Required:
    //*          Yes
    //* Parameters:
    //*          pThis       -   Pointer to the interface structure itself
    //*          hFont       -   Font handle returned by MapFont or GetFont method
    //* Return Value:
    //*          None
    //*
    DeleteFont: procedure(pThis: PFPDF_SYSFONTINFO; hFont: Pointer); cdecl;
  end;
  PFPdfSysFontInfo = ^TFPdfSysFontInfo;
  TFPdfSysFontInfo = FPDF_SYSFONTINFO;

  PFPDF_CharsetFontMap = ^FPDF_CharsetFontMap;
  FPDF_CharsetFontMap = record
    charset: Integer;     // Character Set Enum value, see FXFONT_*_CHARSET above.
    fontname: PAnsiChar;  // Name of default font to use with that charset.
  end;
  PFPdfCharsetFontMap = ^TFPdfCharsetFontMap;
  TFPdfCharsetFontMap = FPDF_CharsetFontMap;

//*
//* Function: FPDF_GetDefaultTTFMap
//*    Returns a pointer to the default character set to TT Font name map. The
//*    map is an array of FPDF_CharsetFontMap structs, with its end indicated
//*    by a { -1, NULL } entry.
//* Parameters:
//*     None.
//* Return Value:
//*     Pointer to the Charset Font Map.
//*
var
  FPDF_GetDefaultTTFMap: function: PFPDF_CharsetFontMap; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_AddInstalledFont
//*          Add a system font to the list in PDFium.
//* Comments:
//*          This function is only called during the system font list building
//*          process.
//* Parameters:
//*          mapper          -   Opaque pointer to Foxit font mapper
//*          face            -   The font face name
//*          charset         -   Font character set. See above defined constants.
//* Return Value:
//*          None.
//*
var
  FPDF_AddInstalledFont: procedure(mapper: Pointer; face: PAnsiChar; charset: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_SetSystemFontInfo
//*          Set the system font info interface into PDFium
//* Parameters:
//*          pFontInfo       -   Pointer to a FPDF_SYSFONTINFO structure
//* Return Value:
//*          None
//* Comments:
//*          Platform support implementation should implement required methods of
//*          FFDF_SYSFONTINFO interface, then call this function during PDFium
//*          initialization process.
//*
var
  FPDF_SetSystemFontInfo: procedure(pFontInfo: PFPDF_SYSFONTINFO); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_GetDefaultSystemFontInfo
//*          Get default system font info interface for current platform
//* Parameters:
//*          None
//* Return Value:
//*          Pointer to a FPDF_SYSFONTINFO structure describing the default
//*          interface, or NULL if the platform doesn't have a default interface.
//*          Application should call FPDF_FreeDefaultSystemFontInfo to free the
//*          returned pointer.
//* Comments:
//*          For some platforms, PDFium implements a default version of system
//*          font info interface. The default implementation can be passed to
//*          FPDF_SetSystemFontInfo().
//*
var
  FPDF_GetDefaultSystemFontInfo: function(): FPDF_SYSFONTINFO; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_FreeDefaultSystemFontInfo
//*           Free a default system font info interface
//* Parameters:
//*           pFontInfo       -   Pointer to a FPDF_SYSFONTINFO structure
//* Return Value:
//*           None
//* Comments:
//*           This function should be called on the output from
//*           FPDF_SetSystemFontInfo() once it is no longer needed.
//*
var
  FPDF_FreeDefaultSystemFontInfo: procedure(pFontInfo: PFPDF_SYSFONTINFO); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_EXT_H_ ***

const
  //flags for type of unsupport object.
  FPDF_UNSP_DOC_XFAFORM               = 1;  // Unsupported XFA form.
  FPDF_UNSP_DOC_PORTABLECOLLECTION    = 2;  // Unsupported portable collection.
  FPDF_UNSP_DOC_ATTACHMENT            = 3;  // Unsupported attachment.
  FPDF_UNSP_DOC_SECURITY              = 4;  // Unsupported security.
  FPDF_UNSP_DOC_SHAREDREVIEW          = 5;  // Unsupported shared review.
  FPDF_UNSP_DOC_SHAREDFORM_ACROBAT    = 6;  // Unsupported shared form, acrobat.
  FPDF_UNSP_DOC_SHAREDFORM_FILESYSTEM = 7;  // Unsupported shared form, filesystem.
  FPDF_UNSP_DOC_SHAREDFORM_EMAIL      = 8;  // Unsupported shared form, email.
  FPDF_UNSP_ANNOT_3DANNOT             = 11; // Unsupported 3D annotation.
  FPDF_UNSP_ANNOT_MOVIE               = 12; // Unsupported movie annotation.
  FPDF_UNSP_ANNOT_SOUND               = 13; // Unsupported sound annotation.
  FPDF_UNSP_ANNOT_SCREEN_MEDIA        = 14; // Unsupported screen media annotation.
  FPDF_UNSP_ANNOT_SCREEN_RICHMEDIA    = 15; // Unsupported screen rich media annotation.
  FPDF_UNSP_ANNOT_ATTACHMENT          = 16; // Unsupported attachment annotation.
  FPDF_UNSP_ANNOT_SIG                 = 17; // Unsupported signature annotation.

type
  PUNSUPPORT_INFO = ^UNSUPPORT_INFO;
  UNSUPPORT_INFO = record
    // Version number of the interface. Must be 1.
    version: Integer;

    // Unsupported object notification function.
    // Interface Version: 1
    // Implementation Required: Yes
    //
    //   pThis - pointer to the interface structure.
    //   nType - the type of unsupported object. One of the |FPDF_UNSP_*| entries.
    FSDK_UnSupport_Handler: procedure(pThis: PUNSUPPORT_INFO; nType: Integer); cdecl;
  end;
  PUnsupportInfo = ^TUnsupportInfo;
  TUnsupportInfo = UNSUPPORT_INFO;

// Setup an unsupported object handler.
//
//   unsp_info - Pointer to an UNSUPPORT_INFO structure.
//
// Returns TRUE on success.
var
  FSDK_SetUnSpObjProcessHandler: function(unsp_info: PUNSUPPORT_INFO): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set replacement function for calls to time().
//
// This API is intended to be used only for testing, thus may cause PDFium to
// behave poorly in production environments.
//
//   func - Function pointer to alternate implementation of time(), or
//          NULL to restore to actual time() call itself.
type
  TFPDFTimeFunction = function: TIME_T; cdecl;
var
  FSDK_SetTimeFunction: procedure(func: TFPDFTimeFunction); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Set replacement function for calls to localtime().
//
// This API is intended to be used only for testing, thus may cause PDFium to
// behave poorly in production environments.
//
//   func - Function pointer to alternate implementation of localtime(), or
//          NULL to restore to actual localtime() call itself.
type
  PFPDF_struct_tm = ^FPDF_struct_tm;
  FPDF_struct_tm = record
    tm_sec: Integer;
    tm_min: Integer;
    tm_hour: Integer;
    tm_mday: Integer;
    tm_mon: Integer;
    tm_year: Integer;
    tm_wday: Integer;
    tm_yday: Integer;
    tm_isdst: Integer;
  end;

type
  TFPDFLocaltimeFunction = function(timer: PTIME_T): PFPDF_struct_tm; cdecl;
var
  FSDK_SetLocaltimeFunction: procedure(func: TFPDFLocaltimeFunction); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

const
  PAGEMODE_UNKNOWN        = -1; // Unknown page mode.
  PAGEMODE_USENONE        = 0;  // Document outline, and thumbnails hidden.
  PAGEMODE_USEOUTLINES    = 1;  // Document outline visible.
  PAGEMODE_USETHUMBS      = 2;  // Thumbnail images visible.
  PAGEMODE_FULLSCREEN     = 3;  // Full-screen mode, no menu bar, window controls, or other decorations visible.
  PAGEMODE_USEOC          = 4;  // Optional content group panel visible.
  PAGEMODE_USEATTACHMENTS = 5;  // Attachments panel visible.

// Get the document's PageMode.
//
//   doc - Handle to document.
//
// Returns one of the |PAGEMODE_*| flags defined above.
//
// The page mode defines how the document should be initially displayed.
var
  FPDFDoc_GetPageMode: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_DATAAVAIL_H_ ***

const
  PDF_LINEARIZATION_UNKNOWN = -1;
  PDF_NOT_LINEARIZED = 0;
  PDF_LINEARIZED = 1;

  PDF_DATA_ERROR = -1;
  PDF_DATA_NOTAVAIL = 0;
  PDF_DATA_AVAIL = 1;

  PDF_FORM_ERROR = -1;
  PDF_FORM_NOTAVAIL = 0;
  PDF_FORM_AVAIL = 1;
  PDF_FORM_NOTEXIST = 2;

type
  // Interface for checking whether sections of the file are available.
  PFX_FILEAVAIL = ^FX_FILEAVAIL;
  FX_FILEAVAIL = record
    // Version number of the interface. Must be 1.
    version: Integer;

    // Reports if the specified data section is currently available. A section is
    // available if all bytes in the section are available.
    //
    // Interface Version: 1
    // Implementation Required: Yes
    //
    //   pThis  - pointer to the interface structure.
    //   offset - the offset of the data section in the file.
    //   size   - the size of the data section.
    //
    // Returns true if the specified data section at |offset| of |size|
    // is available.
    IsDataAvail: function(pThis: PFX_FILEAVAIL; offset, size: SIZE_T): FPDF_BOOL; cdecl;
  end;
  PFXFileAvail = ^TFXFileAvail;
  TFXFileAvail = FX_FILEAVAIL;

// Create a document availability provider.
//
//   file_avail - pointer to file availability interface.
//   file       - pointer to a file access interface.
//
// Returns a handle to the document availability provider, or NULL on error.
//
// FPDFAvail_Destroy() must be called when done with the availability provider.
var
  FPDFAvail_Create: function(file_avail: PFX_FILEAVAIL; file_: PFPDF_FILEACCESS): FPDF_AVAIL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Destroy the |avail| document availability provider.
//
//   avail - handle to document availability provider to be destroyed.
var
  FPDFAvail_Destroy: procedure(avail: FPDF_AVAIL); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Download hints interface. Used to receive hints for further downloading.
type
  PFX_DOWNLOADHINTS = ^FX_DOWNLOADHINTS;
  FX_DOWNLOADHINTS = record
    // Version number of the interface. Must be 1.
    version: Integer;

    // Add a section to be downloaded.
    //
    // Interface Version: 1
    // Implementation Required: Yes
    //
    //   pThis  - pointer to the interface structure.
    //   offset - the offset of the hint reported to be downloaded.
    //   size   - the size of the hint reported to be downloaded.
    //
    // The |offset| and |size| of the section may not be unique. Part of the
    // section might be already available. The download manager must deal with
    // overlapping sections.
    AddSegment: procedure(pThis: PFX_DOWNLOADHINTS; offset, size: SIZE_T); cdecl;
  end;
  PFXDownloadHints = ^TFXDownloadHints;
  TFXDownloadHints = FX_DOWNLOADHINTS;

// Checks if the document is ready for loading, if not, gets download hints.
//
//   avail - handle to document availability provider.
//   hints - pointer to a download hints interface.
//
// Returns one of:
//   PDF_DATA_ERROR: A common error is returned. Data availability unknown.
//   PDF_DATA_NOTAVAIL: Data not yet available.
//   PDF_DATA_AVAIL: Data available.
//
// Applications should call this function whenever new data arrives, and process
// all the generated download hints, if any, until the function returns
// |PDF_DATA_ERROR| or |PDF_DATA_AVAIL|.
// if hints is nullptr, the function just check current document availability.
//
// Once all data is available, call FPDFAvail_GetDocument() to get a document
// handle.
var
  FPDFAvail_IsDocAvail: function(avail: FPDF_AVAIL; hints: PFX_DOWNLOADHINTS): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get document from the availability provider.
//
//   avail    - handle to document availability provider.
//   password - password for decrypting the PDF file. Optional.
//
// Returns a handle to the document.
//
// When FPDFAvail_IsDocAvail() returns TRUE, call FPDFAvail_GetDocument() to
// retrieve the document handle.
// See the comments for FPDF_LoadDocument() regarding the encoding for
// |password|.
var
  FPDFAvail_GetDocument: function(avail: FPDF_AVAIL; password: FPDF_BYTESTRING): FPDF_DOCUMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Get the page number for the first available page in a linearized PDF.
//
//   doc - document handle.
//
// Returns the zero-based index for the first available page.
//
// For most linearized PDFs, the first available page will be the first page,
// however, some PDFs might make another page the first available page.
// For non-linearized PDFs, this function will always return zero.
var
  FPDFAvail_GetFirstPageNum: function(doc: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Check if |page_index| is ready for loading, if not, get the
// |FX_DOWNLOADHINTS|.
//
//   avail      - handle to document availability provider.
//   page_index - index number of the page. Zero for the first page.
//   hints      - pointer to a download hints interface. Populated if
//                |page_index| is not available.
//
// Returns one of:
//   PDF_DATA_ERROR: A common error is returned. Data availability unknown.
//   PDF_DATA_NOTAVAIL: Data not yet available.
//   PDF_DATA_AVAIL: Data available.
//
// This function can be called only after FPDFAvail_GetDocument() is called.
// Applications should call this function whenever new data arrives and process
// all the generated download |hints|, if any, until this function returns
// |PDF_DATA_ERROR| or |PDF_DATA_AVAIL|. Applications can then perform page
// loading.
// if hints is nullptr, the function just check current availability of
// specified page.
var
  FPDFAvail_IsPageAvail: function(avail: FPDF_AVAIL; page_index: Integer; hints: PFX_DOWNLOADHINTS): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Check if form data is ready for initialization, if not, get the
// |FX_DOWNLOADHINTS|.
//
//   avail - handle to document availability provider.
//   hints - pointer to a download hints interface. Populated if form is not
//           ready for initialization.
//
// Returns one of:
//   PDF_FORM_ERROR: A common eror, in general incorrect parameters.
//   PDF_FORM_NOTAVAIL: Data not available.
//   PDF_FORM_AVAIL: Data available.
//   PDF_FORM_NOTEXIST: No form data.
//
// This function can be called only after FPDFAvail_GetDocument() is called.
// The application should call this function whenever new data arrives and
// process all the generated download |hints|, if any, until the function
// |PDF_FORM_ERROR|, |PDF_FORM_AVAIL| or |PDF_FORM_NOTEXIST|.
// if hints is nullptr, the function just check current form availability.
//
// Applications can then perform page loading. It is recommend to call
// FPDFDOC_InitFormFillEnvironment() when |PDF_FORM_AVAIL| is returned.
var
  FPDFAvail_IsFormAvail: function(avail: FPDF_AVAIL; hints: PFX_DOWNLOADHINTS): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Check whether a document is a linearized PDF.
//
//   avail - handle to document availability provider.
//
// Returns one of:
//   PDF_LINEARIZED
//   PDF_NOT_LINEARIZED
//   PDF_LINEARIZATION_UNKNOWN
//
// FPDFAvail_IsLinearized() will return |PDF_LINEARIZED| or |PDF_NOT_LINEARIZED|
// when we have 1k  of data. If the files size less than 1k, it returns
// |PDF_LINEARIZATION_UNKNOWN| as there is insufficient information to determine
// if the PDF is linearlized.
var
  FPDFAvail_IsLinearized: function(avail: FPDF_AVAIL): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPD_FORMFILL_H ***

const
  // These values are return values for a public API, so should not be changed
  // other than the count when adding new values.
  FORMTYPE_NONE           = 0;       // Document contains no forms
  FORMTYPE_ACRO_FORM      = 1;       // Forms are specified using AcroForm spec
  FORMTYPE_XFA_FULL       = 2;       // Forms are specified using the entire XFA spec
  FORMTYPE_XFA_FOREGROUND = 3;       // Forms are specified using the XFAF subset of XFA spec
  FORMTYPE_COUNT          = 4;       // The number of form types

  JSPLATFORM_ALERT_BUTTON_OK          = 0;  // OK button
  JSPLATFORM_ALERT_BUTTON_OKCANCEL    = 1;  // OK & Cancel buttons
  JSPLATFORM_ALERT_BUTTON_YESNO       = 2;  // Yes & No buttons
  JSPLATFORM_ALERT_BUTTON_YESNOCANCEL = 3;  // Yes, No & Cancel buttons
  JSPLATFORM_ALERT_BUTTON_DEFAULT = JSPLATFORM_ALERT_BUTTON_OK;

  JSPLATFORM_ALERT_ICON_ERROR    = 0;  // Error
  JSPLATFORM_ALERT_ICON_WARNING  = 1;  // Warning
  JSPLATFORM_ALERT_ICON_QUESTION = 2;  // Question
  JSPLATFORM_ALERT_ICON_STATUS   = 3;  // Status
  JSPLATFORM_ALERT_ICON_ASTERISK = 4;  // Asterisk
  JSPLATFORM_ALERT_ICON_DEFAULT = JSPLATFORM_ALERT_ICON_ERROR;

  JSPLATFORM_ALERT_RETURN_OK     = 1;  // OK
  JSPLATFORM_ALERT_RETURN_CANCEL = 2;  // Cancel
  JSPLATFORM_ALERT_RETURN_NO     = 3;  // No
  JSPLATFORM_ALERT_RETURN_YES    = 4;  // Yes

  JSPLATFORM_BEEP_ERROR    = 0;  // Error
  JSPLATFORM_BEEP_WARNING  = 1;  // Warning
  JSPLATFORM_BEEP_QUESTION = 2;  // Question
  JSPLATFORM_BEEP_STATUS   = 3;  // Status
  JSPLATFORM_BEEP_DEFAULT  = 4; // Default

type
  PIPDF_JsPlatform = ^IPDF_JsPlatform;
  IPDF_JsPlatform = record
    //*
    //* Version number of the interface. Currently must be 2.
    //*
    version: Integer;

    //* Version 1.

    //*
    //* Method: app_alert
    //*       Pop up a dialog to show warning or hint.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself.
    //*       Msg         -   A string containing the message to be displayed.
    //*       Title       -   The title of the dialog.
    //*       Type        -   The type of button group, one of the
    //*                       JSPLATFORM_ALERT_BUTTON_* values above.
    //*       nIcon       -   The type of the icon, one of the
    //*                       JSPLATFORM_ALERT_ICON_* above.
    //* Return Value:
    //*       Option selected by user in dialogue, one of the
    //*       JSPLATFORM_ALERT_RETURN_* values above.
    //*
    app_alert: function(pThis: PIPDF_JsPlatform; Msg, Title: FPDF_WIDESTRING; nType: Integer;
                        Icon: Integer): Integer; cdecl;

    //*
    //* Method: app_beep
    //*       Causes the system to play a sound.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself
    //*       nType       -   The sound type, see JSPLATFORM_BEEP_TYPE_*
    //*                       above.
    //* Return Value:
    //*       None
    //*
    app_beep: procedure(pThis: PIPDF_JsPlatform; nType: Integer); cdecl;

    //*
    //* Method: app_response
    //*       Displays a dialog box containing a question and an entry field for
    //*       the user to reply to the question.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself
    //*       Question    -   The question to be posed to the user.
    //*       Title       -   The title of the dialog box.
    //*       Default     -   A default value for the answer to the question. If
    //*                       not specified, no default value is presented.
    //*       cLabel      -   A short string to appear in front of and on the
    //*                       same line as the edit text field.
    //*       bPassword   -   If true, indicates that the user's response should
    //*                       be shown as asterisks (*) or bullets (?) to mask
    //*                       the response, which might be sensitive information.
    //*       response    -   A string buffer allocated by PDFium, to receive the
    //*                       user's response.
    //*       length      -   The length of the buffer in bytes. Currently, it is
    //*                       always 2048.
    //* Return Value:
    //*       Number of bytes the complete user input would actually require, not
    //*       including trailing zeros, regardless of the value of the length
    //*       parameter or the presence of the response buffer.
    //* Comments:
    //*       No matter on what platform, the response buffer should be always
    //*       written using UTF-16LE encoding. If a response buffer is
    //*       present and the size of the user input exceeds the capacity of the
    //*       buffer as specified by the length parameter, only the
    //*       first "length" bytes of the user input are to be written to the
    //*       buffer.
    //*
    app_response: function(pThis: PIPDF_JsPlatform; Question, Title, Default, cLabel: FPDF_WIDESTRING;
                           bPassword: FPDF_BOOL; response: Pointer; length: Integer): Integer; cdecl;

    //*
    //* Method: Doc_getFilePath
    //*       Get the file path of the current document.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself
    //*       filePath    -   The string buffer to receive the file path. Can
    //*                       be NULL.
    //*       length      -   The length of the buffer, number of bytes. Can
    //*                       be 0.
    //* Return Value:
    //*       Number of bytes the filePath consumes, including trailing zeros.
    //* Comments:
    //*       The filePath should always be provided in the local encoding.
    //*       The return value always indicated number of bytes required for
    //*       the buffer, even when there is no buffer specified, or the buffer
    //*       size is less than required. In this case, the buffer will not
    //*       be modified.
    //*
    Doc_getFilePath: function(pThis: PIPDF_JsPlatform; filePath: Pointer; length: Integer): Integer; cdecl;

    //*
    //* Method: Doc_mail
    //*       Mails the data buffer as an attachment to all recipients, with or
    //*       without user interaction.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself
    //*       mailData    -   Pointer to the data buffer to be sent. Can be NULL.
    //*       length      -   The size,in bytes, of the buffer pointed by
    //*                       mailData parameter. Can be 0.
    //*       bUI         -   If true, the rest of the parameters are used in a
    //*                       compose-new-message window that is displayed to the
    //*                       user. If false, the cTo parameter is required and
    //*                       all others are optional.
    //*       To          -   A semicolon-delimited list of recipients for the
    //*                       message.
    //*       Subject     -   The subject of the message. The length limit is
    //*                       64 KB.
    //*       CC          -   A semicolon-delimited list of CC recipients for
    //*                       the message.
    //*       BCC         -   A semicolon-delimited list of BCC recipients for
    //*                       the message.
    //*       Msg         -   The content of the message. The length limit is
    //*                       64 KB.
    //* Return Value:
    //*       None.
    //* Comments:
    //*       If the parameter mailData is NULL or length is 0, the current
    //*       document will be mailed as an attachment to all recipients.
    //*
    Doc_mail: procedure(pThis: PIPDF_JsPlatform; mailData: Pointer; length: Integer; bUI: FPDF_BOOL;
                        sTo, subject, CC, BCC, Msg: FPDF_WIDESTRING); cdecl;

    //*
    //* Method: Doc_print
    //*       Prints all or a specific number of pages of the document.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis         -   Pointer to the interface structure itself.
    //*       bUI           -   If true, will cause a UI to be presented to the
    //*                         user to obtain printing information and confirm
    //*                         the action.
    //*       nStart        -   A 0-based index that defines the start of an
    //*                         inclusive range of pages.
    //*       nEnd          -   A 0-based index that defines the end of an
    //*                         inclusive page range.
    //*       bSilent       -   If true, suppresses the cancel dialog box while
    //*                         the document is printing. The default is false.
    //*       bShrinkToFit  -   If true, the page is shrunk (if necessary) to
    //*                         fit within the imageable area of the printed page.
    //*       bPrintAsImage -   If true, print pages as an image.
    //*       bReverse      -   If true, print from nEnd to nStart.
    //*       bAnnotations  -   If true (the default), annotations are
    //*                         printed.
    //* Return Value:
    //*       None.
    //*
    Doc_print: procedure(pThis: PIPDF_JsPlatform; bUI: FPDF_BOOKMARK; nStart, nEnd: Integer;
                         bSilent, bShrinkToFit, bPrintAsImage, bReverse, bAnnotations: FPDF_BOOL); cdecl;

    //*
    //* Method: Doc_submitForm
    //*       Send the form data to a specified URL.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself
    //*       formData    -   Pointer to the data buffer to be sent.
    //*       length      -   The size,in bytes, of the buffer pointed by
    //*                       formData parameter.
    //*       URL         -   The URL to send to.
    //* Return Value:
    //*       None.
    //*
    Doc_submitForm: procedure(pThis: PIPDF_JsPlatform; formData: Pointer; length: Integer; URL: FPDF_WIDESTRING); cdecl;

    //*
    //* Method: Doc_gotoPage
    //*       Jump to a specified page.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself
    //*       nPageNum    -   The specified page number, zero for the first page.
    //* Return Value:
    //*       None.
    //*
    Doc_gotoPage: procedure(pThis: PIPDF_JsPlatform; nPageNum: Integer); cdecl;

    //*
    //* Method: Field_browse
    //*       Show a file selection dialog, and return the selected file path.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself.
    //*       filePath    -   Pointer to the data buffer to receive the file
    //*                       path. Can be NULL.
    //*       length      -   The length of the buffer, in bytes. Can be 0.
    //* Return Value:
    //*       Number of bytes the filePath consumes, including trailing zeros.
    //* Comments:
    //*       The filePath shoule always be provided in local encoding.
    //*
    Field_browse: function(pThis: PIPDF_JsPlatform; filePath: Pointer; length: Integer): Integer; cdecl;

    //*
    //* Pointer for embedder-specific data. Unused by PDFium, and despite
    //* its name, can be any data the embedder desires, though traditionally
    //* a FPDF_FORMFILLINFO interface.
    //*
    m_pFormfillinfo: Pointer;

    //* Version 2.

    m_isolate: Pointer;               // Unused in v3, retain for compatibility.
    m_v8EmbedderSlot: DWORD;          // Unused in v3, retain for compatibility.

    //* Version 3.
    //* Version 3 moves m_Isolate and m_v8EmbedderSlot to FPDF_LIBRARY_CONFIG.
  end;
  PIPDFJsPlatform = ^TIPDFJsPlatform;
  TIPDFJsPlatform = IPDF_JSPLATFORM;

// Flags for Cursor type
const
  FXCT_ARROW = 0;
  FXCT_NESW  = 1;
  FXCT_NWSE  = 2;
  FXCT_VBEAM = 3;
  FXCT_HBEAM = 4;
  FXCT_HAND  = 5;

//*
//* Function signature for the callback function passed to the FFI_SetTimer
//* method.
//* Parameters:
//*          idEvent     -   Identifier of the timer.
//* Return value:
//*          None.
//*
type
  TFPDFTimerCallback = procedure(idEvent: Integer); cdecl;

type
  //*
  //* Declares of a struct type to the local system time.
  //*
  {$IFDEF MSWINDOWS}
  PFPDF_SYSTEMTIME = PSystemTime;
  FPDF_SYSTEMTIME = TSystemTime;
  {$ELSE}
  PFPDF_SYSTEMTIME = ^FPDF_SYSTEMTIME;
  FPDF_SYSTEMTIME = record
    wYear: Word;          // years since 1900
    wMonth: Word;         // months since January - [0,11]
    wDayOfWeek: Word;     // days since Sunday - [0,6]
    wDay: Word;           // day of the month - [1,31]
    wHour: Word;          // hours since midnight - [0,23]
    wMinute: Word;        // minutes after the hour - [0,59]
    wSecond: Word;        // seconds after the minute - [0,59]
    wMilliseconds: Word;  // milliseconds after the second - [0,999]
  end;
  {$ENDIF MSWINDOWS}
  PFPDFSystemTime = ^TFPDFSystemTime;
  TFPDFSystemTime = FPDF_SYSTEMTIME;

{$IFDEF PDF_ENABLE_XFA}
// XFA
const
  // Pageview event flags
  FXFA_PAGEVIEWEVENT_POSTADDED   = 1; // After a new pageview is added.
  FXFA_PAGEVIEWEVENT_POSTREMOVED = 3; // After a pageview is removed.

  // Definitions for Right Context Menu Features Of XFA Fields
  FXFA_MENU_COPY      = 1;
  FXFA_MENU_CUT       = 2;
  FXFA_MENU_SELECTALL = 4;
  FXFA_MENU_UNDO      = 8;
  FXFA_MENU_REDO      = 16;
  FXFA_MENU_PASTE     = 32;

  // Definitions for File Type.
  FXFA_SAVEAS_XML = 1;
  FXFA_SAVEAS_XDP = 2;
{$ENDIF PDF_ENABLE_XFA}

type
  PFPDF_FORMFILLINFO = ^FPDF_FORMFILLINFO;
  FPDF_FORMFILLINFO = record
    //*
    //* Version number of the interface.
    //* Version 1 contains stable interfaces. Version 2 has additional
    //* experimental interfaces.
    //* When PDFium is built without the XFA module, version can be 1 or 2.
    //* With version 1, only stable interfaces are called. With version 2,
    //* additional experimental interfaces are also called.
    //* When PDFium is built with the XFA module, version must be 2.
    //* All the XFA related interfaces are experimental. If PDFium is built with
    //* the XFA module and version 1 then none of the XFA related interfaces
    //* would be called. When PDFium is built with XFA module then the version
    //* must be 2.
    //*
    version: Integer;

    //* Version 1.

    //*
    //* Method: Release
    //*     Give the implementation a chance to release any resources after the
    //*     interface is no longer used.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     No
    //* Comments:
    //*     Called by PDFium during the final cleanup process.
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself
    //* Return Value:
    //*     None
    //*
    Release: procedure(pThis: PFPDF_FORMFILLINFO); cdecl;

    //*
    //* Method: FFI_Invalidate
    //*     Invalidate the client area within the specified rectangle.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     page        -   Handle to the page. Returned by FPDF_LoadPage().
    //*     left        -   Left position of the client area in PDF page
    //*                     coordinates.
    //*     top         -   Top position of the client area in PDF page
    //*                     coordinates.
    //*     right       -   Right position of the client area in PDF page
    //*                     coordinates.
    //*     bottom      -   Bottom position of the client area in PDF page
    //*                     coordinates.
    //* Return Value:
    //*     None.
    //*
    //* Comments:
    //*       All positions are measured in PDF "user space".
    //*       Implementation should call FPDF_RenderPageBitmap() for repainting
    //*       the specified page area.
    //*
    FFI_Invalidate: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; left, top, right, bottom: Double); cdecl;

    //*
    //* Method: FFI_OutputSelectedRect
    //*     When the user selects text in form fields with the mouse, this
    //*     callback function will be invoked with the selected areas.
    //*
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     No
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     page        -   Handle to the page. Returned by FPDF_LoadPage()/
    //*     left        -   Left position of the client area in PDF page
    //*                     coordinates.
    //*     top         -   Top position of the client area in PDF page
    //*                     coordinates.
    //*     right       -   Right position of the client area in PDF page
    //*                     coordinates.
    //*     bottom      -   Bottom position of the client area in PDF page
    //*                     coordinates.
    //* Return Value:
    //*     None.
    //*
    //* Comments:
    //*       This callback function is useful for implementing special text
    //*       selection effects. An implementation should first record the
    //*       returned rectangles, then draw them one by one during the next
    //*       painting period. Lastly, it should remove all the recorded
    //*       rectangles when finished painting.
    //*
    FFI_OutputSelectedRect: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; left, top, right, bottom: Double); cdecl;

    //*
    //* Method: FFI_SetCursor
    //*     Set the Cursor shape.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself.
    //*       nCursorType -   Cursor type, see Flags for Cursor type for details.
    //* Return value:
    //*     None.
    //*
    FFI_SetCursor: procedure(pThis: PFPDF_FORMFILLINFO; nCursorType: Integer); cdecl;

    //*
    //* Method: FFI_SetTimer
    //*     This method installs a system timer. An interval value is specified,
    //*     and every time that interval elapses, the system must call into the
    //*     callback function with the timer ID as returned by this function.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     uElapse     -   Specifies the time-out value, in milliseconds.
    //*     lpTimerFunc -   A pointer to the callback function-TimerCallback.
    //* Return value:
    //*     The timer identifier of the new timer if the function is successful.
    //*     An application passes this value to the FFI_KillTimer method to kill
    //*     the timer. Nonzero if it is successful; otherwise, it is zero.
    //*
    FFI_SetTimer: function(pThis: PFPDF_FORMFILLINFO; uElapse: Integer; lpTimerFunc: TFPDFTimerCallback): Integer; cdecl;

    //*
    //* Method: FFI_KillTimer
    //*     This method uninstalls a system timer, as set by an earlier call to
    //*     FFI_SetTimer.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     nTimerID    -   The timer ID returned by FFI_SetTimer function.
    //* Return value:
    //*     None.
    //*

    FFI_KillTimer: procedure(pThis: PFPDF_FORMFILLINFO; nTimerID: Integer); cdecl;

    //*
    //* Method: FFI_GetLocalTime
    //*     This method receives the current local time on the system.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //* Return value:
    //*     The local time. See FPDF_SYSTEMTIME above for details.
    //* Note: Unused.
    //*
    FFI_GetLocalTime: function(pThis: PFPDF_FORMFILLINFO): FPDF_SYSTEMTIME; cdecl;

    //*
    //* Method: FFI_OnChange
    //*     This method will be invoked to notify the implementation when the
    //*     value of any FormField on the document had been changed.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     no
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //* Return value:
    //*     None.
    //*
    FFI_OnChange: procedure(pThis: PFPDF_FORMFILLINFO); cdecl;

    //*
    //* Method: FFI_GetPage
    //*       This method receives the page handle associated with a specified
    //*       page index.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself.
    //*       document    -   Handle to document. Returned by FPDF_LoadDocument().
    //*       nPageIndex  -   Index number of the page. 0 for the first page.
    //* Return value:
    //*       Handle to the page, as previously returned to the implementation by
    //*       FPDF_LoadPage().
    //* Comments:
    //*       The implementation is expected to keep track of the page handles it
    //*       receives from PDFium, and their mappings to page numbers. In some
    //*       cases, the document-level JavaScript action may refer to a page
    //*       which hadn't been loaded yet. To successfully run the Javascript
    //*       action, the implementation needs to load the page.
    //*
    FFI_GetPage: function(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT; nPageIndex: Integer): FPDF_PAGE; cdecl;

    //*
    //* Method: FFI_GetCurrentPage
    //*       This method receives the handle to the current page.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       Yes when V8 support is present, otherwise unused.
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself.
    //*       document    -   Handle to document. Returned by FPDF_LoadDocument().
    //* Return value:
    //*       Handle to the page. Returned by FPDF_LoadPage().
    //* Comments:
    //*       PDFium doesn't keep keep track of the "current page" (e.g. the one
    //*       that is most visible on screen), so it must ask the embedder for
    //*       this information.
    //*
    FFI_GetCurrentPage: function(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT): FPDF_PAGE; cdecl;

    //*
    //* Method: FFI_GetRotation
    //*       This method receives currently rotation of the page view.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       yes
    //* Parameters:
    //*       pThis       -   Pointer to the interface structure itself.
    //*       page        -   Handle to page, as returned by FPDF_LoadPage().
    //* Return value:
    //*       A number to indicate the page rotation in 90 degree increments
    //*       in a clockwise direction:
    //*         0 - 0 degrees
    //*         1 - 90 degrees
    //*         2 - 180 degrees
    //*         3 - 270 degrees
    //* Note: Unused.
    //*
    FFI_GetRotation: function(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE): Integer; cdecl;

    //*
    //* Method: FFI_ExecuteNamedAction
    //*     This method will execute a named action.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis           -   Pointer to the interface structure itself.
    //*     namedAction     -   A byte string which indicates the named action,
    //*                         terminated by 0.
    //* Return value:
    //*     None.
    //* Comments:
    //*     See ISO 32000-1:2008, section 12.6.4.11 for descriptions of the
    //*     standard named actions, but note that a document may supply any
    //*     name of its choosing.
    //*
    FFI_ExecuteNamedAction: procedure(pThis: PFPDF_FORMFILLINFO; namedAction: FPDF_BYTESTRING); cdecl;

    //*
    //* Method: FFI_SetTextFieldFocus
    //*       Called when a text field is getting or losing focus.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       no
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       value           -   The string value of the form field, in UTF-16LE
    //*                           format.
    //*       valueLen        -   The length of the string value. This is the
    //*                           number of characters, not bytes.
    //*       is_focus        -   True if the form field is getting focus, false
    //*                           if the form field is losing focus.
    //* Return value:
    //*       None.
    //* Comments:
    //*       Only supports text fields and combobox fields.
    //*
    FFI_SetTextFieldFocus: procedure(pThis: PFPDF_FORMFILLINFO; value: FPDF_WIDESTRING; valueLen: FPDF_DWORD; is_focus: FPDF_BOOL); cdecl;

    //*
    //* Method: FFI_DoURIAction
    //*       Ask the implementation to navigate to a uniform resource identifier.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       No
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       bsURI           -   A byte string which indicates the uniform
    //*                           resource identifier, terminated by 0.
    //* Return value:
    //*       None.
    //* Comments:
    //*       If the embedder is version 2 or higher and have implementation for
    //*       FFI_DoURIActionWithKeyboardModifier, then
    //*       FFI_DoURIActionWithKeyboardModifier takes precedence over
    //*       FFI_DoURIAction.
    //*       See the URI actions description of <<PDF Reference, version 1.7>>
    //*       for more details.
    //*
    FFI_DoURIAction: procedure(pThis: PFPDF_FORMFILLINFO; bsURI: FPDF_WIDESTRING); cdecl;

    //*
    //* Method: FFI_DoGoToAction
    //*       This action changes the view to a specified destination.
    //* Interface Version:
    //*       1
    //* Implementation Required:
    //*       No
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       nPageIndex      -   The index of the PDF page.
    //*       zoomMode        -   The zoom mode for viewing page. See below.
    //*       fPosArray       -   The float array which carries the position info.
    //*       sizeofArray     -   The size of float array.
    //* PDFZoom values:
    //*         - XYZ = 1
    //*         - FITPAGE = 2
    //*         - FITHORZ = 3
    //*         - FITVERT = 4
    //*         - FITRECT = 5
    //*         - FITBBOX = 6
    //*         - FITBHORZ = 7
    //*         - FITBVERT = 8
    //* Return value:
    //*       None.
    //* Comments:
    //*       See the Destinations description of <<PDF Reference, version 1.7>>
    //*       in 8.2.1 for more details.
    //*
    FFI_DoGoToAction: procedure(pThis: PFPDF_FORMFILLINFO; nPageIndex, zoomMode: Integer; fPosArray: PSingle; sizeofArray: Integer); cdecl;

    //*
    //*   Pointer to IPDF_JSPLATFORM interface.
    //*   Unused if PDFium is built without V8 support. Otherwise, if NULL, then
    //*   JavaScript will be prevented from executing while rendering the document.
    //*
    m_pJsPlatform: PIPDF_JSPLATFORM;

    //* Version 2 - Experimental.
    //*
    //* Whether the XFA module is disabled when built with the XFA module.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //*
    xfa_disabled: FPDF_BOOL;

    //*
    //* Method: FFI_DisplayCaret
    //*       This method will show the caret at specified position.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       page            -   Handle to page. Returned by FPDF_LoadPage().
    //*       left            -   Left position of the client area in PDF page
    //*                           coordinates.
    //*       top             -   Top position of the client area in PDF page
    //*                           coordinates.
    //*       right           -   Right position of the client area in PDF page
    //*                           coordinates.
    //*       bottom          -   Bottom position of the client area in PDF page
    //*                           coordinates.
    //* Return value:
    //*       None.
    //*
    FFI_DisplayCaret: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; bVisible: FPDF_BOOL;
                                left, top, right, bottom: Double); cdecl;

    //*
    //* Method: FFI_GetCurrentPageIndex
    //*       This method will get the current page index.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       document        -   Handle to document from FPDF_LoadDocument().
    //* Return value:
    //*       The index of current page.
    //*
    FFI_GetCurrentPageIndex: function(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT): Integer; cdecl;

    //*
    //* Method: FFI_SetCurrentPage
    //*       This method will set the current page.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       document        -   Handle to document from FPDF_LoadDocument().
    //*       iCurPage        -   The index of the PDF page.
    //* Return value:
    //*       None.
    //*
    FFI_SetCurrentPage: procedure(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT; iCurPage: Integer); cdecl;

    //*
    //* Method: FFI_GotoURL
    //*       This method will navigate to the specified URL.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis            -   Pointer to the interface structure itself.
    //*       document         -   Handle to document from FPDF_LoadDocument().
    //*       wsURL            -   The string value of the URL, in UTF-16LE format.
    //* Return value:
    //*       None.
    //*
    FFI_GotoURL: procedure(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT; wsURL: FPDF_WIDESTRING); cdecl;

    //*
    //* Method: FFI_GetPageViewRect
    //*       This method will get the current page view rectangle.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       page            -   Handle to page. Returned by FPDF_LoadPage().
    //*       left            -   The pointer to receive left position of the page
    //*                           view area in PDF page coordinates.
    //*       top             -   The pointer to receive top position of the page
    //*                           view area in PDF page coordinates.
    //*       right           -   The pointer to receive right position of the
    //*                           page view area in PDF page coordinates.
    //*       bottom          -   The pointer to receive bottom position of the
    //*                           page view area in PDF page coordinates.
    //* Return value:
    //*     None.
    //*
    FFI_GetPageViewRect: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; var left, top, right, bottom: Double); cdecl;

    //*
    //* Method: FFI_PageEvent
    //*       This method fires when pages have been added to or deleted from
    //*       the XFA document.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       page_count      -   The number of pages to be added or deleted.
    //*       event_type      -   See FXFA_PAGEVIEWEVENT_* above.
    //* Return value:
    //*       None.
    //* Comments:
    //*       The pages to be added or deleted always start from the last page
    //*       of document. This means that if parameter page_count is 2 and
    //*       event type is FXFA_PAGEVIEWEVENT_POSTADDED, 2 new pages have been
    //*       appended to the tail of document; If page_count is 2 and
    //*       event type is FXFA_PAGEVIEWEVENT_POSTREMOVED, the last 2 pages
    //*       have been deleted.
    //*
    FFI_PageEvent: procedure(pThis: PFPDF_FORMFILLINFO; page_count: Integer; event_type: FPDF_DWORD); cdecl;

    //*
    //* Method: FFI_PopupMenu
    //*       This method will track the right context menu for XFA fields.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       page            -   Handle to page. Returned by FPDF_LoadPage().
    //*       hWidget         -   Always null, exists for compatibility.
    //*       menuFlag        -   The menu flags. Please refer to macro definition
    //*                           of FXFA_MENU_XXX and this can be one or a
    //*                           combination of these macros.
    //*       x               -   X position of the client area in PDF page
    //*                           coordinates.
    //*       y               -   Y position of the client area in PDF page
    //*                           coordinates.
    //* Return value:
    //*       TRUE indicates success; otherwise false.
    //*
    FFI_PopupMenu: function(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; hWidget: FPDF_WIDGET;
                            menuFlag: Integer; x, y: Single): FPDF_BOOL; cdecl;

    //*
    //* Method: FFI_OpenFile
    //*       This method will open the specified file with the specified mode.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       fileFlag        -   The file flag. Please refer to macro definition
    //*                           of FXFA_SAVEAS_XXX and use one of these macros.
    //*       wsURL           -   The string value of the file URL, in UTF-16LE
    //*                           format.
    //*       mode            -   The mode for open file, e.g. "rb" or "wb".
    //* Return value:
    //*       The handle to FPDF_FILEHANDLER.
    //**
    FFI_OpenFile: function(pThis: PFPDF_FORMFILLINFO; fileFlag: Integer; wsURL: FPDF_WIDESTRING;
                           mode: PAnsiChar): PFPDF_FILEHANDLER; cdecl;

    //*
    //* Method: FFI_EmailTo
    //*       This method will email the specified file stream to the specified
    //*       contact.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       pFileHandler    -   Handle to the FPDF_FILEHANDLER.
    //*       pTo             -   A semicolon-delimited list of recipients for the
    //*                           message,in UTF-16LE format.
    //*       pSubject        -   The subject of the message,in UTF-16LE format.
    //*       pCC             -   A semicolon-delimited list of CC recipients for
    //*                           the message,in UTF-16LE format.
    //*       pBcc            -   A semicolon-delimited list of BCC recipients for
    //*                           the message,in UTF-16LE format.
    //*       pMsg            -   Pointer to the data buffer to be sent.Can be
    //*                           NULL,in UTF-16LE format.
    //* Return value:
    //*       None.
    //*
    FFI_EmailTo: procedure(pThis: PFPDF_FORMFILLINFO; fileHandler: PFPDF_FILEHANDLER;
                           pTo, pSubject, pCC, pBcc, pMsg: FPDF_WIDESTRING); cdecl;

    //*
    //* Method: FFI_UploadTo
    //*       This method will upload the specified file stream to the
    //*       specified URL.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       pFileHandler    -   Handle to the FPDF_FILEHANDLER.
    //*       fileFlag        -   The file flag. Please refer to macro definition
    //*                           of FXFA_SAVEAS_XXX and use one of these macros.
    //*       uploadTo        -   Pointer to the URL path, in UTF-16LE format.
    //* Return value:
    //*       None.
    //*
    FFI_UploadTo: procedure(pThis: PFPDF_FORMFILLINFO; fileHandler: PFPDF_FILEHANDLER; fileFlag: Integer;
                            uploadTo: FPDF_WIDESTRING); cdecl;

    //*
    //* Method: FFI_GetPlatform
    //*       This method will get the current platform.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       platform        -   Pointer to the data buffer to receive the
    //*                           platform,in UTF-16LE format. Can be NULL.
    //*       length          -   The length of the buffer in bytes. Can be
    //*                           0 to query the required size.
    //* Return value:
    //*       The length of the buffer, number of bytes.
    //*
    FFI_GetPlatform: function(pThis: PFPDF_FORMFILLINFO; platform_: Pointer; length: Integer): Integer; cdecl;

    //*
    //* Method: FFI_GetLanguage
    //*       This method will get the current language.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       language        -   Pointer to the data buffer to receive the
    //*                           current language. Can be NULL.
    //*       length          -   The length of the buffer in bytes. Can be
    //*                           0 to query the required size.
    //* Return value:
    //*       The length of the buffer, number of bytes.
    //*
    FFI_GetLanguage: function(pThis: PFPDF_FORMFILLINFO; language: Pointer; length: Integer): Integer; cdecl;

    //*
    //* Method: FFI_DownloadFromURL
    //*       This method will download the specified file from the URL.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       URL             -   The string value of the file URL, in UTF-16LE
    //*                           format.
    //* Return value:
    //*       The handle to FPDF_FILEHANDLER.
    //*
    FFI_DownloadFromURL: function(pThis: PFPDF_FORMFILLINFO; URL: FPDF_WIDESTRING): PFPDF_FILEHANDLER; cdecl;

    //*
    //* Method: FFI_PostRequestURL
    //*       This method will post the request to the server URL.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       wsURL           -   The string value of the server URL, in UTF-16LE
    //*                           format.
    //*       wsData          -   The post data,in UTF-16LE format.
    //*       wsContentType   -   The content type of the request data, in
    //*                           UTF-16LE format.
    //*       wsEncode        -   The encode type, in UTF-16LE format.
    //*       wsHeader        -   The request header,in UTF-16LE format.
    //*       response        -   Pointer to the FPDF_BSTR to receive the response
    //*                           data from the server, in UTF-16LE format.
    //* Return value:
    //*       TRUE indicates success, otherwise FALSE.
    //*
    FFI_PostRequestURL: function(pThis: PFPDF_FORMFILLINFO; wsURL, wsData, wsContentType,
                                 wsEncode, wsHeader: FPDF_WIDESTRING; respone: PFPDF_BSTR): FPDF_BOOL; cdecl;

    //*
    //* Method: FFI_PutRequestURL
    //*       This method will put the request to the server URL.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       Required for XFA, otherwise set to NULL.
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       wsURL           -   The string value of the server URL, in UTF-16LE
    //*                           format.
    //*       wsData          -   The put data, in UTF-16LE format.
    //*       wsEncode        -   The encode type, in UTR-16LE format.
    //* Return value:
    //*       TRUE indicates success, otherwise FALSE.
    //*
    FFI_PutRequestURL: function(pThis: PFPDF_FORMFILLINFO; wsURL, wsData, wsEncode: FPDF_WIDESTRING): FPDF_BOOL; cdecl;

    //*
    //* Method: FFI_OnFocusChange
    //*     Called when the focused annotation is updated.
    //* Interface Version:
    //*     Ignored if |version| < 2.
    //* Implementation Required:
    //*     No
    //* Parameters:
    //*     param           -   Pointer to the interface structure itself.
    //*     annot           -   The focused annotation.
    //*     page_index      -   Index number of the page which contains the
    //*                         focused annotation. 0 for the first page.
    //* Return value:
    //*     None.
    //* Comments:
    //*     This callback function is useful for implementing any view based
    //*     action such as scrolling the annotation rect into view. The
    //*     embedder should not copy and store the annot as its scope is
    //*     limited to this call only.
    //*
    FFI_OnFocusChange: procedure(param: PFPDF_FORMFILLINFO; annot: FPDF_ANNOTATION; page_index: Integer); cdecl;

    //*
    //* Method: FFI_DoURIActionWithKeyboardModifier
    //*       Ask the implementation to navigate to a uniform resource identifier
    //*       with the specified modifiers.
    //* Interface Version:
    //*       Ignored if |version| < 2.
    //* Implementation Required:
    //*       No
    //* Parameters:
    //*       param           -   Pointer to the interface structure itself.
    //*       uri             -   A byte string which indicates the uniform
    //*                           resource identifier, terminated by 0.
    //*       modifiers       -   Keyboard modifier that indicates which of
    //*                           the virtual keys are down, if any.
    //* Return value:
    //*       None.
    //* Comments:
    //*       If the embedder who is version 2 and does not implement this API,
    //*       then a call will be redirected to FFI_DoURIAction.
    //*       See the URI actions description of <<PDF Reference, version 1.7>>
    //*       for more details.
    //*
    FFI_DoURIActionWithKeyboardModifier: procedure(param: PFPDF_FORMFILLINFO; uri: FPDF_BYTESTRING; modifiers: Integer); cdecl;
  end;
  PFPDFFormFillInfo = ^TFPDFFormFillInfo;
  TFPDFFormFillInfo = FPDF_FORMFILLINFO;


//*
//* Function: FPDFDOC_InitFormFillEnvironment
//*       Initialize form fill environment.
//* Parameters:
//*       document        -   Handle to document from FPDF_LoadDocument().
//*       formInfo        -   Pointer to a FPDF_FORMFILLINFO structure.
//* Return Value:
//*       Handle to the form fill module, or NULL on failure.
//* Comments:
//*       This function should be called before any form fill operation.
//*       The FPDF_FORMFILLINFO passed in via |formInfo| must remain valid until
//*       the returned FPDF_FORMHANDLE is closed.
//*
var
  FPDFDOC_InitFormFillEnvironment: function(document: FPDF_DOCUMENT; formInfo: PFPDF_FORMFILLINFO): FPDF_FORMHANDLE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDFDOC_ExitFormFillEnvironment
//*       Take ownership of |hHandle| and exit form fill environment.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//* Return Value:
//*       None.
//* Comments:
//*       This function is a no-op when |hHandle| is null.
//*
var
  FPDFDOC_ExitFormFillEnvironment: procedure(hHandle: FPDF_FORMHANDLE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnAfterLoadPage
//*       This method is required for implementing all the form related
//*       functions. Should be invoked after user successfully loaded a
//*       PDF page, and FPDFDOC_InitFormFillEnvironment() has been invoked.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//* Return Value:
//*       None.
//*
var
  FORM_OnAfterLoadPage: procedure(page: FPDF_PAGE; hHandle: FPDF_FORMHANDLE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnBeforeClosePage
//*       This method is required for implementing all the form related
//*       functions. Should be invoked before user closes the PDF page.
//* Parameters:
//*        page        -   Handle to the page, as returned by FPDF_LoadPage().
//*        hHandle     -   Handle to the form fill module, as returned by
//*                        FPDFDOC_InitFormFillEnvironment().
//* Return Value:
//*        None.
//*
var
  FORM_OnBeforeClosePage: procedure(page: FPDF_PAGE; hHandle: FPDF_FORMHANDLE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_DoDocumentJSAction
//*       This method is required for performing document-level JavaScript
//*       actions. It should be invoked after the PDF document has been loaded.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//* Return Value:
//*       None.
//* Comments:
//*       If there is document-level JavaScript action embedded in the
//*       document, this method will execute the JavaScript action. Otherwise,
//*       the method will do nothing.
//*
var
  FORM_DoDocumentJSAction: procedure(hHandle: FPDF_FORMHANDLE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_DoDocumentOpenAction
//*       This method is required for performing open-action when the document
//*       is opened.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//* Return Value:
//*       None.
//* Comments:
//*       This method will do nothing if there are no open-actions embedded
//*       in the document.
//*
var
  FORM_DoDocumentOpenAction: procedure(hHandle: FPDF_FORMHANDLE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

const
  // Additional actions type of document:
  //   WC, before closing document, JavaScript action.
  //   WS, before saving document, JavaScript action.
  //   DS, after saving document, JavaScript action.
  //   WP, before printing document, JavaScript action.
  //   DP, after printing document, JavaScript action.
  FPDFDOC_AACTION_WC = $10;
  FPDFDOC_AACTION_WS = $11;
  FPDFDOC_AACTION_DS = $12;
  FPDFDOC_AACTION_WP = $13;
  FPDFDOC_AACTION_DP = $14;

//*
//* Function: FORM_DoDocumentAAction
//*       This method is required for performing the document's
//*       additional-action.
//* Parameters:
//*       hHandle     -   Handle to the form fill module. Returned by
//*                       FPDFDOC_InitFormFillEnvironment.
//*       aaType      -   The type of the additional-actions which defined
//*                       above.
//* Return Value:
//*       None.
//* Comments:
//*       This method will do nothing if there is no document
//*       additional-action corresponding to the specified |aaType|.
//*
var
  FORM_DoDocumentAAction: procedure(hHandle: FPDF_FORMHANDLE; aaType: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

const
  // Additional-action types of page object:
  //   OPEN (/O) -- An action to be performed when the page is opened
  //   CLOSE (/C) -- An action to be performed when the page is closed
  FPDFPAGE_AACTION_OPEN  = 0;
  FPDFPAGE_AACTION_CLOSE = 1;

//*
//* Function: FORM_DoPageAAction
//*       This method is required for performing the page object's
//*       additional-action when opened or closed.
//* Parameters:
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       aaType      -   The type of the page object's additional-actions
//*                       which defined above.
//* Return Value:
//*       None.
//* Comments:
//*       This method will do nothing if no additional-action corresponding
//*       to the specified |aaType| exists.
//*
var
  FORM_DoPageAAction: procedure(page: FPDF_PAGE; hHandle: FPDF_FORMHANDLE; aaType: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnMouseMove
//*       Call this member function when the mouse cursor moves.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       modifier    -   Indicates whether various virtual keys are down.
//*       page_x      -   Specifies the x-coordinate of the cursor in PDF user
//*                       space.
//*       page_y      -   Specifies the y-coordinate of the cursor in PDF user
//*                       space.
//* Return Value:
//*       True indicates success; otherwise false.
//*
var
  FORM_OnMouseMove: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer;
    page_x, page_y: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Experimental API
//* Function: FORM_OnMouseWheel
//*       Call this member function when the user scrolls the mouse wheel.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       modifier    -   Indicates whether various virtual keys are down.
//*       page_coord  -   Specifies the coordinates of the cursor in PDF user
//*                       space.
//*       delta_x     -   Specifies the amount of wheel movement on the x-axis,
//*                       in units of platform-agnostic wheel deltas. Negative
//*                       values mean left.
//*       delta_y     -   Specifies the amount of wheel movement on the y-axis,
//*                       in units of platform-agnostic wheel deltas. Negative
//*                       values mean down.
//* Return Value:
//*       True indicates success; otherwise false.
//* Comments:
//*       For |delta_x| and |delta_y|, the caller must normalize
//*       platform-specific wheel deltas. e.g. On Windows, a delta value of 240
//*       for a WM_MOUSEWHEEL event normalizes to 2, since Windows defines
//*       WHEEL_DELTA as 120.
//*
var
  FORM_OnMouseWheel: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer;
    const page_coord: PFS_POINTF; delta_x, delta_y: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnFocus
//*       This function focuses the form annotation at a given point. If the
//*       annotation at the point already has focus, nothing happens. If there
//*       is no annotation at the point, removes form focus.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       modifier    -   Indicates whether various virtual keys are down.
//*       page_x      -   Specifies the x-coordinate of the cursor in PDF user
//*                       space.
//*       page_y      -   Specifies the y-coordinate of the cursor in PDF user
//*                       space.
//* Return Value:
//*       True if there is an annotation at the given point and it has focus.
//*
var
  FORM_OnFocus: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer;
    page_x, page_y: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnLButtonDown
//*       Call this member function when the user presses the left
//*       mouse button.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       modifier    -   Indicates whether various virtual keys are down.
//*       page_x      -   Specifies the x-coordinate of the cursor in PDF user
//*                       space.
//*       page_y      -   Specifies the y-coordinate of the cursor in PDF user
//*                       space.
//* Return Value:
//*       True indicates success; otherwise false.
//*
var
  FORM_OnLButtonDown: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer;
    page_x, page_y: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnRButtonDown
//*       Same as above, execpt for the right mouse button.
//* Comments:
//*       At the present time, has no effect except in XFA builds, but is
//*       included for the sake of symmetry.
//*
var
  FORM_OnRButtonDown: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer;
    page_x, page_y: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnLButtonUp
//*       Call this member function when the user releases the left
//*       mouse button.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       modifier    -   Indicates whether various virtual keys are down.
//*       page_x      -   Specifies the x-coordinate of the cursor in device.
//*       page_y      -   Specifies the y-coordinate of the cursor in device.
//* Return Value:
//*       True indicates success; otherwise false.
//*
var
  FORM_OnLButtonUp: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer;
    page_x, page_y: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnRButtonUp
//*       Same as above, execpt for the right mouse button.
//* Comments:
//*       At the present time, has no effect except in XFA builds, but is
//*       included for the sake of symmetry.
//*
var
  FORM_OnRButtonUp: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer;
    page_x, page_y: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnLButtonDoubleClick
//*       Call this member function when the user double clicks the
//*       left mouse button.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       modifier    -   Indicates whether various virtual keys are down.
//*       page_x      -   Specifies the x-coordinate of the cursor in PDF user
//*                       space.
//*       page_y      -   Specifies the y-coordinate of the cursor in PDF user
//*                       space.
//* Return Value:
//*       True indicates success; otherwise false.
//*
var
  FORM_OnLButtonDoubleClick: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer;
    page_x, page_y: Double): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnKeyDown
//*       Call this member function when a nonsystem key is pressed.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, aseturned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       nKeyCode    -   The virtual-key code of the given key (see
//*                       fpdf_fwlevent.h for virtual key codes).
//*       modifier    -   Mask of key flags (see fpdf_fwlevent.h for key
//*                       flag values).
//* Return Value:
//*       True indicates success; otherwise false.
//*
var
  FORM_OnKeyDown: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; nKeyCode, modifier: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnKeyUp
//*       Call this member function when a nonsystem key is released.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       nKeyCode    -   The virtual-key code of the given key (see
//*                       fpdf_fwlevent.h for virtual key codes).
//*       modifier    -   Mask of key flags (see fpdf_fwlevent.h for key
//*                       flag values).
//* Return Value:
//*       True indicates success; otherwise false.
//* Comments:
//*       Currently unimplemented and always returns false. PDFium reserves this
//*       API and may implement it in the future on an as-needed basis.
//*
var
  FORM_OnKeyUp: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; nKeyCode, modifier: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_OnChar
//*       Call this member function when a keystroke translates to a
//*       nonsystem character.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       nChar       -   The character code value itself.
//*       modifier    -   Mask of key flags (see fpdf_fwlevent.h for key
//*                       flag values).
//* Return Value:
//*       True indicates success; otherwise false.
//*
var
  FORM_OnChar: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; nChar, modifier: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Experimental API
//* Function: FORM_GetFocusedText
//*       Call this function to obtain the text within the current focused
//*       field, if any.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       buffer      -   Buffer for holding the form text, encoded in
//*                       UTF-16LE. If NULL, |buffer| is not modified.
//*       buflen      -   Length of |buffer| in bytes. If |buflen| is less
//*                       than the length of the form text string, |buffer| is
//*                       not modified.
//* Return Value:
//*       Length in bytes for the text in the focused field.
//*
var
  FORM_GetFocusedText: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_GetSelectedText
//*       Call this function to obtain selected text within a form text
//*       field or form combobox text field.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//*       buffer      -   Buffer for holding the selected text, encoded in
//*                       UTF-16LE. If NULL, |buffer| is not modified.
//*       buflen      -   Length of |buffer| in bytes. If |buflen| is less
//*                       than the length of the selected text string,
//*                       |buffer| is not modified.
//* Return Value:
//*       Length in bytes of selected text in form text field or form combobox
//*       text field.
//*
var
  FORM_GetSelectedText: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//* Experimental API
//* Function: FORM_ReplaceAndKeepSelection
//*       Call this function to replace the selected text in a form
//*       text field or user-editable form combobox text field with another
//*       text string (which can be empty or non-empty). If there is no
//*       selected text, this function will append the replacement text after
//*       the current caret position. After the insertion, the inserted text
//*       will be selected.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as Returned by FPDF_LoadPage().
//*       wsText      -   The text to be inserted, in UTF-16LE format.
//* Return Value:
//*       None.
//*
var
  FORM_ReplaceAndKeepSelection: procedure(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; wsText: FPDF_WIDESTRING); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_ReplaceSelection
//*       Call this function to replace the selected text in a form
//*       text field or user-editable form combobox text field with another
//*       text string (which can be empty or non-empty). If there is no
//*       selected text, this function will append the replacement text after
//*       the current caret position. After the insertion, the selection range
//*       will be set to empty.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as Returned by FPDF_LoadPage().
//*       wsText      -   The text to be inserted, in UTF-16LE format.
//* Return Value:
//*       None.
//*
var
  FORM_ReplaceSelection: procedure(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; wsText: FPDF_WIDESTRING); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Experimental API
//* Function: FORM_SelectAllText
//*       Call this function to select all the text within the currently focused
//*       form text field or form combobox text field.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//* Return Value:
//*       Whether the operation succeeded or not.
//*
var
  FORM_SelectAllText: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_CanUndo
//*       Find out if it is possible for the current focused widget in a given
//*       form to perform an undo operation.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//* Return Value:
//*       True if it is possible to undo.
//*
var
  FORM_CanUndo: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_CanRedo
//*       Find out if it is possible for the current focused widget in a given
//*       form to perform a redo operation.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//* Return Value:
//*       True if it is possible to redo.
//*
var
  FORM_CanRedo: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_Undo
//*       Make the current focussed widget perform an undo operation.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//* Return Value:
//*       True if the undo operation succeeded.
//*
var
  FORM_Undo: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_Redo
//*       Make the current focussed widget perform a redo operation.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page        -   Handle to the page, as returned by FPDF_LoadPage().
//* Return Value:
//*       True if the redo operation succeeded.
//*
var
  FORM_Redo: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FORM_ForceToKillFocus.
//*       Call this member function to force to kill the focus of the form
//*       field which has focus. If it would kill the focus of a form field,
//*       save the value of form field if was changed by theuser.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//* Return Value:
//*       True indicates success; otherwise false.
//*
var
  FORM_ForceToKillFocus: function(hHandle: FPDF_FORMHANDLE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Experimental API.
//* Function: FORM_GetFocusedAnnot.
//*       Call this member function to get the currently focused annotation.
//* Parameters:
//*       handle      -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       page_index  -   Buffer to hold the index number of the page which
//*                       contains the focused annotation. 0 for the first page.
//*                       Can't be NULL.
//*       annot       -   Buffer to hold the focused annotation. Can't be NULL.
//* Return Value:
//*       On success, return true and write to the out parameters. Otherwise return
//*       false and leave the out parameters unmodified.
//* Comments:
//*       Not currently supported for XFA forms - will report no focused
//*       annotation.
//*       Must call FPDFPage_CloseAnnot() when the annotation returned in |annot|
//*       by this function is no longer needed.
//*       This will return true and set |page_index| to -1 and |annot| to NULL, if
//*       there is no focused annotation.
//*
var
  FORM_GetFocusedAnnot: function(handle: FPDF_FORMHANDLE; var page_index: Integer;
    var annot: FPDF_ANNOTATION): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Experimental API.
//* Function: FORM_SetFocusedAnnot.
//*       Call this member function to set the currently focused annotation.
//* Parameters:
//*       handle      -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       annot       -   Handle to an annotation.
//* Return Value:
//*       True indicates success; otherwise false.
//* Comments:
//*       |annot| can't be NULL. To kill focus, use FORM_ForceToKillFocus()
//*       instead.
//*
var
  FORM_SetFocusedAnnot: function(handle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Form Field Types
// The names of the defines are stable, but the specific values associated with
// them are not, so do not hardcode their values.
const
  FPDF_FORMFIELD_UNKNOWN        = 0;   // Unknown.
  FPDF_FORMFIELD_PUSHBUTTON     = 1;   // push button type.
  FPDF_FORMFIELD_CHECKBOX       = 2;   // check box type.
  FPDF_FORMFIELD_RADIOBUTTON    = 3;   // radio button type.
  FPDF_FORMFIELD_COMBOBOX       = 4;   // combo box type.
  FPDF_FORMFIELD_LISTBOX        = 5;   // list box type.
  FPDF_FORMFIELD_TEXTFIELD      = 6;   // text field type.
  FPDF_FORMFIELD_SIGNATURE      = 7;   // text field type.
{$IFDEF PDF_ENABLE_XFA}
  FPDF_FORMFIELD_XFA            = 8;   // Generic XFA type.
  FPDF_FORMFIELD_XFA_CHECKBOX   = 9;   // XFA check box type.
  FPDF_FORMFIELD_XFA_COMBOBOX   = 10;  // XFA combo box type.
  FPDF_FORMFIELD_XFA_IMAGEFIELD = 11;  // XFA image field type.
  FPDF_FORMFIELD_XFA_LISTBOX    = 12;  // XFA list box type.
  FPDF_FORMFIELD_XFA_PUSHBUTTON = 13;  // XFA push button type.
  FPDF_FORMFIELD_XFA_SIGNATURE  = 14;  // XFA signture field type.
  FPDF_FORMFIELD_XFA_TEXTFIELD  = 15;  // XFA text field type.
{$ENDIF PDF_ENABLE_XFA}

{$IFDEF PDF_ENABLE_XFA}
  FPDF_FORMFIELD_COUNT = 16;
{$ELSE}
  FPDF_FORMFIELD_COUNT = 8;
{$ENDIF PDF_ENABLE_XFA}

{$IFDEF PDF_ENABLE_XFA}
function IS_XFA_FORMFIELD(type_: Integer): Boolean; inline;
{$ENDIF PDF_ENABLE_XFA}


//*
//* Function: FPDFPage_HasFormFieldAtPoint
//*     Get the form field type by point.
//* Parameters:
//*     hHandle     -   Handle to the form fill module. Returned by
//*                     FPDFDOC_InitFormFillEnvironment().
//*     page        -   Handle to the page. Returned by FPDF_LoadPage().
//*     page_x      -   X position in PDF "user space".
//*     page_y      -   Y position in PDF "user space".
//* Return Value:
//*     Return the type of the form field; -1 indicates no field.
//*     See field types above.
//*
var
  FPDFPage_HasFormFieldAtPoint: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; page_x, page_y: Double): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDFPage_FormFieldZOrderAtPoint
//*     Get the form field z-order by point.
//* Parameters:
//*     hHandle     -   Handle to the form fill module. Returned by
//*                     FPDFDOC_InitFormFillEnvironment().
//*     page        -   Handle to the page. Returned by FPDF_LoadPage().
//*     page_x      -   X position in PDF "user space".
//*     page_y      -   Y position in PDF "user space".
//* Return Value:
//*     Return the z-order of the form field; -1 indicates no field.
//*     Higher numbers are closer to the front.
//*
var
  FPDFPage_FormFieldZOrderAtPoint: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; page_x, page_y: Double): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_SetFormFieldHighlightColor
//*       Set the highlight color of the specified (or all) form fields
//*       in the document.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       doc         -   Handle to the document, as returned by
//*                       FPDF_LoadDocument().
//*       fieldType   -   A 32-bit integer indicating the type of a form
//*                       field (defined above).
//*       color       -   The highlight color of the form field. Constructed by
//*                       0xxxrrggbb.
//* Return Value:
//*       None.
//* Comments:
//*       When the parameter fieldType is set to FPDF_FORMFIELD_UNKNOWN, the
//*       highlight color will be applied to all the form fields in the
//*       document.
//*       Please refresh the client window to show the highlight immediately
//*       if necessary.
//*
var
  FPDF_SetFormFieldHighlightColor: procedure(hHandle: FPDF_FORMHANDLE; fieldType: Integer; Color: LongWord); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_SetFormFieldHighlightAlpha
//*       Set the transparency of the form field highlight color in the
//*       document.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//*       doc         -   Handle to the document, as returaned by
//*                       FPDF_LoadDocument().
//*       alpha       -   The transparency of the form field highlight color,
//*                       between 0-255.
//* Return Value:
//*       None.
//*
var
  FPDF_SetFormFieldHighlightAlpha: procedure(hHandle: FPDF_FORMHANDLE; alpha: Byte); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_RemoveFormFieldHighlight
//*       Remove the form field highlight color in the document.
//* Parameters:
//*       hHandle     -   Handle to the form fill module, as returned by
//*                       FPDFDOC_InitFormFillEnvironment().
//* Return Value:
//*       None.
//* Comments:
//*       Please refresh the client window to remove the highlight immediately
//*       if necessary.
//*
var
  FPDF_RemoveFormFieldHighlight: procedure(hHandle: FPDF_FORMHANDLE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_FFLDraw
//*       Render FormFields and popup window on a page to a device independent
//*       bitmap.
//* Parameters:
//*       hHandle      -   Handle to the form fill module, as returned by
//*                        FPDFDOC_InitFormFillEnvironment().
//*       bitmap       -   Handle to the device independent bitmap (as the
//*                        output buffer). Bitmap handles can be created by
//*                        FPDFBitmap_Create().
//*       page         -   Handle to the page, as returned by FPDF_LoadPage().
//*       start_x      -   Left pixel position of the display area in the
//*                        device coordinates.
//*       start_y      -   Top pixel position of the display area in the device
//*                        coordinates.
//*       size_x       -   Horizontal size (in pixels) for displaying the page.
//*       size_y       -   Vertical size (in pixels) for displaying the page.
//*       rotate       -   Page orientation: 0 (normal), 1 (rotated 90 degrees
//*                        clockwise), 2 (rotated 180 degrees), 3 (rotated 90
//*                        degrees counter-clockwise).
//*       flags        -   0 for normal display, or combination of flags
//*                        defined above.
//* Return Value:
//*       None.
//* Comments:
//*       This function is designed to render annotations that are
//*       user-interactive, which are widget annotations (for FormFields) and
//*       popup annotations.
//*       With the FPDF_ANNOT flag, this function will render a popup annotation
//*       when users mouse-hover on a non-widget annotation. Regardless of
//*       FPDF_ANNOT flag, this function will always render widget annotations
//*       for FormFields.
//*       In order to implement the FormFill functions, implementation should
//*       call this function after rendering functions, such as
//*       FPDF_RenderPageBitmap() or FPDF_RenderPageBitmap_Start(), have
//*       finished rendering the page contents.
//*
var
  FPDF_FFLDraw: procedure(hHandle: FPDF_FORMHANDLE; bitmap: FPDF_BITMAP; page: FPDF_PAGE;
    start_x, start_y, size_x, size_y, rotate, flags: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

{$IFDEF _SKIA_SUPPORT_}
var
  FPDF_FFLDrawSkia: procedure(hHandle: FPDF_FORMHANDLE; canvas: FPDF_SKIA_CANVAS; page: FPDF_PAGE;
    start_x, start_y, size_x, size_y, rotate, flags: Integer); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
{$ENDIF _SKIA_SUPPORT_}

//*
//* Experimental API
//* Function: FPDF_GetFormType
//*           Returns the type of form contained in the PDF document.
//* Parameters:
//*           document - Handle to document.
//* Return Value:
//*           Integer value representing one of the FORMTYPE_ values.
//* Comments:
//*           If |document| is NULL, then the return value is FORMTYPE_NONE.
//*
var
  FPDF_GetFormType: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Experimental API
//* Function: FORM_SetIndexSelected
//*           Selects/deselects the value at the given |index| of the focused
//*           annotation.
//* Parameters:
//*           hHandle     -   Handle to the form fill module. Returned by
//*                           FPDFDOC_InitFormFillEnvironment.
//*           page        -   Handle to the page. Returned by FPDF_LoadPage
//*           index       -   0-based index of value to be set as
//*                           selected/unselected
//*           selected    -   true to select, false to deselect
//* Return Value:
//*           TRUE if the operation succeeded.
//*           FALSE if the operation failed or widget is not a supported type.
//* Comments:
//*           Intended for use with listbox/combobox widget types. Comboboxes
//*           have at most a single value selected at a time which cannot be
//*           deselected. Deselect on a combobox is a no-op that returns false.
//*           Default implementation is a no-op that will return false for
//*           other types.
//*           Not currently supported for XFA forms - will return false.
//*
var
  FORM_SetIndexSelected: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; index: Integer;
    selected: FPDF_BOOL): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Experimental API
//* Function: FORM_IsIndexSelected
//*           Returns whether or not the value at |index| of the focused
//*           annotation is currently selected.
//* Parameters:
//*           hHandle     -   Handle to the form fill module. Returned by
//*                           FPDFDOC_InitFormFillEnvironment.
//*           page        -   Handle to the page. Returned by FPDF_LoadPage
//*           index       -   0-based Index of value to check
//* Return Value:
//*           TRUE if value at |index| is currently selected.
//*           FALSE if value at |index| is not selected or widget is not a
//*           supported type.
//* Comments:
//*           Intended for use with listbox/combobox widget types. Default
//*           implementation is a no-op that will return false for other types.
//*           Not currently supported for XFA forms - will return false.
//*
var
  FORM_IsIndexSelected: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; index: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//*
//* Function: FPDF_LoadXFA
//*          If the document consists of XFA fields, call this method to
//*          attempt to load XFA fields.
//* Parameters:
//*          document     -   Handle to document from FPDF_LoadDocument().
//* Return Value:
//*          TRUE upon success, otherwise FALSE. If XFA support is not built
//*          into PDFium, performs no action and always returns FALSE.
//*
var
  FPDF_LoadXFA: function(document: FPDF_DOCUMENT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_ANNOT_H_ ***

const
  FPDF_ANNOT_UNKNOWN = 0;
  FPDF_ANNOT_TEXT = 1;
  FPDF_ANNOT_LINK = 2;
  FPDF_ANNOT_FREETEXT = 3;
  FPDF_ANNOT_LINE = 4;
  FPDF_ANNOT_SQUARE = 5;
  FPDF_ANNOT_CIRCLE = 6;
  FPDF_ANNOT_POLYGON = 7;
  FPDF_ANNOT_POLYLINE = 8;
  FPDF_ANNOT_HIGHLIGHT = 9;
  FPDF_ANNOT_UNDERLINE = 10;
  FPDF_ANNOT_SQUIGGLY = 11;
  FPDF_ANNOT_STRIKEOUT = 12;
  FPDF_ANNOT_STAMP = 13;
  FPDF_ANNOT_CARET = 14;
  FPDF_ANNOT_INK = 15;
  FPDF_ANNOT_POPUP = 16;
  FPDF_ANNOT_FILEATTACHMENT = 17;
  FPDF_ANNOT_SOUND = 18;
  FPDF_ANNOT_MOVIE = 19;
  FPDF_ANNOT_WIDGET = 20;
  FPDF_ANNOT_SCREEN = 21;
  FPDF_ANNOT_PRINTERMARK = 22;
  FPDF_ANNOT_TRAPNET = 23;
  FPDF_ANNOT_WATERMARK = 24;
  FPDF_ANNOT_THREED = 25;
  FPDF_ANNOT_RICHMEDIA = 26;
  FPDF_ANNOT_XFAWIDGET = 27;
  FPDF_ANNOT_REDACT = 28;

  // Refer to PDF Reference (6th edition) table 8.16 for all annotation flags.
  FPDF_ANNOT_FLAG_NONE = 0;
  FPDF_ANNOT_FLAG_INVISIBLE = (1 shl 0);
  FPDF_ANNOT_FLAG_HIDDEN = (1 shl 1);
  FPDF_ANNOT_FLAG_PRINT = (1 shl 2);
  FPDF_ANNOT_FLAG_NOZOOM = (1 shl 3);
  FPDF_ANNOT_FLAG_NOROTATE = (1 shl 4);
  FPDF_ANNOT_FLAG_NOVIEW = (1 shl 5);
  FPDF_ANNOT_FLAG_READONLY = (1 shl 6);
  FPDF_ANNOT_FLAG_LOCKED = (1 shl 7);
  FPDF_ANNOT_FLAG_TOGGLENOVIEW = (1 shl 8);

  FPDF_ANNOT_APPEARANCEMODE_NORMAL = 0;
  FPDF_ANNOT_APPEARANCEMODE_ROLLOVER = 1;
  FPDF_ANNOT_APPEARANCEMODE_DOWN = 2;
  FPDF_ANNOT_APPEARANCEMODE_COUNT = 3;

  // Refer to PDF Reference version 1.7 table 8.70 for field flags common to all
  // interactive form field types.
  FPDF_FORMFLAG_NONE = 0;
  FPDF_FORMFLAG_READONLY = (1 shl 0);
  FPDF_FORMFLAG_REQUIRED = (1 shl 1);
  FPDF_FORMFLAG_NOEXPORT = (1 shl 2);

  // Refer to PDF Reference version 1.7 table 8.77 for field flags specific to
  // interactive form text fields.
  FPDF_FORMFLAG_TEXT_MULTILINE = (1 shl 12);
  FPDF_FORMFLAG_TEXT_PASSWORD  = (1 shl 13);

  // Refer to PDF Reference version 1.7 table 8.79 for field flags specific to
  // interactive form choice fields.
  FPDF_FORMFLAG_CHOICE_COMBO = (1 shl 17);
  FPDF_FORMFLAG_CHOICE_EDIT = (1 shl 18);
  FPDF_FORMFLAG_CHOICE_MULTI_SELECT = (1 shl 21);

  // Additional actions type of form field:
  //   K, on key stroke, JavaScript action.
  //   F, on format, JavaScript action.
  //   V, on validate, JavaScript action.
  //   C, on calculate, JavaScript action.
  FPDF_ANNOT_AACTION_KEY_STROKE = 12;
  FPDF_ANNOT_AACTION_FORMAT = 13;
  FPDF_ANNOT_AACTION_VALIDATE = 14;
  FPDF_ANNOT_AACTION_CALCULATE = 15;

type
  FPDFANNOT_COLORTYPE = (
    FPDFANNOT_COLORTYPE_Color = 0,
    FPDFANNOT_COLORTYPE_InteriorColor
  );

// Experimental API.
// Check if an annotation subtype is currently supported for creation.
// Currently supported subtypes:
//    - circle
//    - freetext
//    - highlight
//    - ink
//    - link
//    - popup
//    - square,
//    - squiggly
//    - stamp
//    - strikeout
//    - text
//    - underline
//
//   subtype   - the subtype to be checked.
//
// Returns true if this subtype supported.
var
  FPDFAnnot_IsSupportedSubtype: function(subtype: FPDF_ANNOTATION_SUBTYPE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Create an annotation in |page| of the subtype |subtype|. If the specified
// subtype is illegal or unsupported, then a new annotation will not be created.
// Must call FPDFPage_CloseAnnot() when the annotation returned by this
// function is no longer needed.
//
//   page      - handle to a page.
//   subtype   - the subtype of the new annotation.
//
// Returns a handle to the new annotation object, or NULL on failure.
var
  FPDFPage_CreateAnnot: function(page: FPDF_PAGE; subtype: FPDF_ANNOTATION_SUBTYPE): FPDF_ANNOTATION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the number of annotations in |page|.
//
//   page   - handle to a page.
//
// Returns the number of annotations in |page|.
var
  FPDFPage_GetAnnotCount: function(page: FPDF_PAGE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get annotation in |page| at |index|. Must call FPDFPage_CloseAnnot() when the
// annotation returned by this function is no longer needed.
//
//   page  - handle to a page.
//   index - the index of the annotation.
//
// Returns a handle to the annotation object, or NULL on failure.
var
  FPDFPage_GetAnnot: function(page: FPDF_PAGE; index: Integer): FPDF_ANNOTATION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the index of |annot| in |page|. This is the opposite of
// FPDFPage_GetAnnot().
//
//   page  - handle to the page that the annotation is on.
//   annot - handle to an annotation.
//
// Returns the index of |annot|, or -1 on failure.
var
  FPDFPage_GetAnnotIndex: function(page: FPDF_PAGE; annot: FPDF_ANNOTATION): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Close an annotation. Must be called when the annotation returned by
// FPDFPage_CreateAnnot() or FPDFPage_GetAnnot() is no longer needed. This
// function does not remove the annotation from the document.
//
//   annot  - handle to an annotation.
var
  FPDFPage_CloseAnnot: procedure(annot: FPDF_ANNOTATION); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Remove the annotation in |page| at |index|.
//
//   page  - handle to a page.
//   index - the index of the annotation.
//
// Returns true if successful.
var
  FPDFPage_RemoveAnnot: function(page: FPDF_PAGE; index: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the subtype of an annotation.
//
//   annot  - handle to an annotation.
//
// Returns the annotation subtype.
var
  FPDFAnnot_GetSubtype: function(annot: FPDF_ANNOTATION): FPDF_ANNOTATION_SUBTYPE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Check if an annotation subtype is currently supported for object extraction,
// update, and removal.
// Currently supported subtypes: ink and stamp.
//
//   subtype   - the subtype to be checked.
//
// Returns true if this subtype supported.
var
  FPDFAnnot_IsObjectSupportedSubtype: function(subtype: FPDF_ANNOTATION_SUBTYPE): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Update |obj| in |annot|. |obj| must be in |annot| already and must have
// been retrieved by FPDFAnnot_GetObject(). Currently, only ink and stamp
// annotations are supported by this API. Also note that only path, image, and
// text objects have APIs for modification; see FPDFPath_*(), FPDFText_*(), and
// FPDFImageObj_*().
//
//   annot  - handle to an annotation.
//   obj    - handle to the object that |annot| needs to update.
//
// Return true if successful.
var
  FPDFAnnot_UpdateObject: function(annot: FPDF_ANNOTATION; obj: FPDF_PAGEOBJECT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Add a new InkStroke, represented by an array of points, to the InkList of
// |annot|. The API creates an InkList if one doesn't already exist in |annot|.
// This API works only for ink annotations. Please refer to ISO 32000-1:2008
// spec, section 12.5.6.13.
//
//   annot       - handle to an annotation.
//   points      - pointer to a FS_POINTF array representing input points.
//   point_count - number of elements in |points| array. This should not exceed
//                 the maximum value that can be represented by an int32_t).
//
// Returns the 0-based index at which the new InkStroke is added in the InkList
// of the |annot|. Returns -1 on failure.
var
  FPDFAnnot_AddInkStroke: function(annot: FPDF_ANNOTATION; const points: PFS_POINTF; point_count: SIZE_T): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Removes an InkList in |annot|.
// This API works only for ink annotations.
//
//   annot  - handle to an annotation.
//
// Return true on successful removal of /InkList entry from context of the
// non-null ink |annot|. Returns false on failure.
var
  FPDFAnnot_RemoveInkList: function(annot: FPDF_ANNOTATION): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Add |obj| to |annot|. |obj| must have been created by
// FPDFPageObj_CreateNew{Path|Rect}() or FPDFPageObj_New{Text|Image}Obj(), and
// will be owned by |annot|. Note that an |obj| cannot belong to more than one
// |annot|. Currently, only ink and stamp annotations are supported by this API.
// Also note that only path, image, and text objects have APIs for creation.
//
//   annot  - handle to an annotation.
//   obj    - handle to the object that is to be added to |annot|.
//
// Return true if successful.
var
  FPDFAnnot_AppendObject: function(annot: FPDF_ANNOTATION; obj: FPDF_PAGEOBJECT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the total number of objects in |annot|, including path objects, text
// objects, external objects, image objects, and shading objects.
//
//   annot  - handle to an annotation.
//
// Returns the number of objects in |annot|.
var
  FPDFAnnot_GetObjectCount: function(annot: FPDF_ANNOTATION): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the object in |annot| at |index|.
//
//   annot  - handle to an annotation.
//   index  - the index of the object.
//
// Return a handle to the object, or NULL on failure.
var
  FPDFAnnot_GetObject: function(annot: FPDF_ANNOTATION; index: Integer): FPDF_PAGEOBJECT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Remove the object in |annot| at |index|.
//
//   annot  - handle to an annotation.
//   index  - the index of the object to be removed.
//
// Return true if successful.
var
  FPDFAnnot_RemoveObject: function(annot: FPDF_ANNOTATION; index: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the color of an annotation. Fails when called on annotations with
// appearance streams already defined; instead use
// FPDFPath_Set{Stroke|Fill}Color().
//
//   annot    - handle to an annotation.
//   type     - type of the color to be set.
//   R, G, B  - buffer to hold the RGB value of the color. Ranges from 0 to 255.
//   A        - buffer to hold the opacity. Ranges from 0 to 255.
//
// Returns true if successful.
var
  FPDFAnnot_SetColor: function(annot: FPDF_ANNOTATION; type_: FPDFANNOT_COLORTYPE; R, G, B, A: Cardinal): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the color of an annotation. If no color is specified, default to yellow
// for highlight annotation, black for all else. Fails when called on
// annotations with appearance streams already defined; instead use
// FPDFPath_Get{Stroke|Fill}Color().
//
//   annot    - handle to an annotation.
//   type     - type of the color requested.
//   R, G, B  - buffer to hold the RGB value of the color. Ranges from 0 to 255.
//   A        - buffer to hold the opacity. Ranges from 0 to 255.
//
// Returns true if successful.
var
  FPDFAnnot_GetColor: function(annot: FPDF_ANNOTATION; type_: FPDFANNOT_COLORTYPE; var R, G, B, A: Cardinal): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Check if the annotation is of a type that has attachment points
// (i.e. quadpoints). Quadpoints are the vertices of the rectangle that
// encompasses the texts affected by the annotation. They provide the
// coordinates in the page where the annotation is attached. Only text markup
// annotations (i.e. highlight, strikeout, squiggly, and underline) and link
// annotations have quadpoints.
//
//   annot  - handle to an annotation.
//
// Returns true if the annotation is of a type that has quadpoints, false
// otherwise.
var
  FPDFAnnot_HasAttachmentPoints: function(annot: FPDF_ANNOTATION): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Replace the attachment points (i.e. quadpoints) set of an annotation at
// |quad_index|. This index needs to be within the result of
// FPDFAnnot_CountAttachmentPoints().
// If the annotation's appearance stream is defined and this annotation is of a
// type with quadpoints, then update the bounding box too if the new quadpoints
// define a bigger one.
//
//   annot       - handle to an annotation.
//   quad_index  - index of the set of quadpoints.
//   quad_points - the quadpoints to be set.
//
// Returns true if successful.
var
  FPDFAnnot_SetAttachmentPoints: function(annot: FPDF_ANNOTATION; quad_index: SIZE_T; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Append to the list of attachment points (i.e. quadpoints) of an annotation.
// If the annotation's appearance stream is defined and this annotation is of a
// type with quadpoints, then update the bounding box too if the new quadpoints
// define a bigger one.
//
//   annot       - handle to an annotation.
//   quad_points - the quadpoints to be set.
//
// Returns true if successful.
var
  FPDFAnnot_AppendAttachmentPoints: function(annot: FPDF_ANNOTATION; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the number of sets of quadpoints of an annotation.
//
//   annot  - handle to an annotation.
//
// Returns the number of sets of quadpoints, or 0 on failure.
var
  FPDFAnnot_CountAttachmentPoints: function(annot: FPDF_ANNOTATION): SIZE_T; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the attachment points (i.e. quadpoints) of an annotation.
//
//   annot       - handle to an annotation.
//   quad_index  - index of the set of quadpoints.
//   quad_points - receives the quadpoints; must not be NULL.
//
// Returns true if successful.
var
  FPDFAnnot_GetAttachmentPoints: function(annot: FPDF_ANNOTATION; quad_index: SIZE_T; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the annotation rectangle defining the location of the annotation. If the
// annotation's appearance stream is defined and this annotation is of a type
// without quadpoints, then update the bounding box too if the new rectangle
// defines a bigger one.
//
//   annot  - handle to an annotation.
//   rect   - the annotation rectangle to be set.
//
// Returns true if successful.
var
  FPDFAnnot_SetRect: function(annot: FPDF_ANNOTATION; rect: PFS_RECTF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the annotation rectangle defining the location of the annotation.
//
//   annot  - handle to an annotation.
//   rect   - receives the rectangle; must not be NULL.
//
// Returns true if successful.
var
  FPDFAnnot_GetRect: function(annot: FPDF_ANNOTATION; rect: PFS_RECTF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the vertices of a polygon or polyline annotation. |buffer| is an array of
// points of the annotation. If |length| is less than the returned length, or
// |annot| or |buffer| is NULL, |buffer| will not be modified.
//
//   annot  - handle to an annotation, as returned by e.g. FPDFPage_GetAnnot()
//   buffer - buffer for holding the points.
//   length - length of the buffer in points.
//
// Returns the number of points if the annotation is of type polygon or
// polyline, 0 otherwise.
var
  FPDFAnnot_GetVertices: function(annot: FPDF_ANNOTATION; buffer: PFS_POINTF; length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the number of paths in the ink list of an ink annotation.
//
//   annot  - handle to an annotation, as returned by e.g. FPDFPage_GetAnnot()
//
// Returns the number of paths in the ink list if the annotation is of type ink,
// 0 otherwise.
var
  FPDFAnnot_GetInkListCount: function(annot: FPDF_ANNOTATION): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get a path in the ink list of an ink annotation. |buffer| is an array of
// points of the path. If |length| is less than the returned length, or |annot|
// or |buffer| is NULL, |buffer| will not be modified.
//
//   annot  - handle to an annotation, as returned by e.g. FPDFPage_GetAnnot()
//   path_index - index of the path
//   buffer - buffer for holding the points.
//   length - length of the buffer in points.
//
// Returns the number of points of the path if the annotation is of type ink, 0
// otherwise.
var
  FPDFAnnot_GetInkListPath: function(annot: FPDF_ANNOTATION; path_index: LongWord; buffer: PFS_POINTF;
    length: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the starting and ending coordinates of a line annotation.
//
//   annot  - handle to an annotation, as returned by e.g. FPDFPage_GetAnnot()
//   start - starting point
//   end - ending point
//
// Returns true if the annotation is of type line, |start| and |end| are not
// NULL, false otherwise.
var
  FPDFAnnot_GetLine: function(annot: FPDF_ANNOTATION; start, end_: PFS_POINTF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the characteristics of the annotation's border (rounded rectangle).
//
//   annot              - handle to an annotation
//   horizontal_radius  - horizontal corner radius, in default user space units
//   vertical_radius    - vertical corner radius, in default user space units
//   border_width       - border width, in default user space units
//
// Returns true if setting the border for |annot| succeeds, false otherwise.
//
// If |annot| contains an appearance stream that overrides the border values,
// then the appearance stream will be removed on success.
var
  FPDFAnnot_SetBorder: function(annot: FPDF_ANNOTATION; horizontal_radius, vertical_radius, border_width: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the characteristics of the annotation's border (rounded rectangle).
//
//   annot              - handle to an annotation
//   horizontal_radius  - horizontal corner radius, in default user space units
//   vertical_radius    - vertical corner radius, in default user space units
//   border_width       - border width, in default user space units
//
// Returns true if |horizontal_radius|, |vertical_radius| and |border_width| are
// not NULL, false otherwise.
var
  FPDFAnnot_GetBorder: function(annot: FPDF_ANNOTATION; var horizontal_radius, vertical_radius, border_width: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the JavaScript of an event of the annotation's additional actions.
// |buffer| is only modified if |buflen| is large enough to hold the whole
// JavaScript string. If |buflen| is smaller, the total size of the JavaScript
// is still returned, but nothing is copied.  If there is no JavaScript for
// |event| in |annot|, an empty string is written to |buf| and 2 is returned,
// denoting the size of the null terminator in the buffer.  On other errors,
// nothing is written to |buffer| and 0 is returned.
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    annot       -   handle to an interactive form annotation.
//    event       -   event type, one of the FPDF_ANNOT_AACTION_* values.
//    buffer      -   buffer for holding the value string, encoded in UTF-16LE.
//    buflen      -   length of the buffer in bytes.
//
// Returns the length of the string value in bytes, including the 2-byte
// null terminator.
var
  FPDFAnnot_GetFormAdditionalActionJavaScript: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION;
    event: Integer; buffer: PFPDF_WCHAR; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Check if |annot|'s dictionary has |key| as a key.
//
//   annot  - handle to an annotation.
//   key    - the key to look for, encoded in UTF-8.
//
// Returns true if |key| exists.
var
  FPDFAnnot_HasKey: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the type of the value corresponding to |key| in |annot|'s dictionary.
//
//   annot  - handle to an annotation.
//   key    - the key to look for, encoded in UTF-8.
//
// Returns the type of the dictionary value.
var
  FPDFAnnot_GetValueType: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING): FPDF_OBJECT_TYPE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the string value corresponding to |key| in |annot|'s dictionary,
// overwriting the existing value if any. The value type would be
// FPDF_OBJECT_STRING after this function call succeeds.
//
//   annot  - handle to an annotation.
//   key    - the key to the dictionary entry to be set, encoded in UTF-8.
//   value  - the string value to be set, encoded in UTF-16LE.
//
// Returns true if successful.
var
  FPDFAnnot_SetStringValue: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING; value: FPDF_WIDESTRING): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the string value corresponding to |key| in |annot|'s dictionary. |buffer|
// is only modified if |buflen| is longer than the length of contents. Note that
// if |key| does not exist in the dictionary or if |key|'s corresponding value
// in the dictionary is not a string (i.e. the value is not of type
// FPDF_OBJECT_STRING or FPDF_OBJECT_NAME), then an empty string would be copied
// to |buffer| and the return value would be 2. On other errors, nothing would
// be added to |buffer| and the return value would be 0.
//
//   annot  - handle to an annotation.
//   key    - the key to the requested dictionary entry, encoded in UTF-8.
//   buffer - buffer for holding the value string, encoded in UTF-16LE.
//   buflen - length of the buffer in bytes.
//
// Returns the length of the string value in bytes.
var
  FPDFAnnot_GetStringValue: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING; buffer: PFPDF_WCHAR;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the float value corresponding to |key| in |annot|'s dictionary. Writes
// value to |value| and returns True if |key| exists in the dictionary and
// |key|'s corresponding value is a number (FPDF_OBJECT_NUMBER), False
// otherwise.
//
//   annot  - handle to an annotation.
//   key    - the key to the requested dictionary entry, encoded in UTF-8.
//   value  - receives the value, must not be NULL.
//
// Returns True if value found, False otherwise.
var
  FPDFAnnot_GetNumberValue: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING; value: PSingle): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the AP (appearance string) in |annot|'s dictionary for a given
// |appearanceMode|.
//
//   annot          - handle to an annotation.
//   appearanceMode - the appearance mode (normal, rollover or down) for which
//                    to get the AP.
//   value          - the string value to be set, encoded in UTF-16LE. If
//                    nullptr is passed, the AP is cleared for that mode. If the
//                    mode is Normal, APs for all modes are cleared.
//
// Returns true if successful.
var
  FPDFAnnot_SetAP: function(annot: FPDF_ANNOTATION; appearanceMode: FPDF_ANNOT_APPEARANCEMODE;
    value: FPDF_WIDESTRING): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the AP (appearance string) from |annot|'s dictionary for a given
// |appearanceMode|.
// |buffer| is only modified if |buflen| is large enough to hold the whole AP
// string. If |buflen| is smaller, the total size of the AP is still returned,
// but nothing is copied.
// If there is no appearance stream for |annot| in |appearanceMode|, an empty
// string is written to |buf| and 2 is returned.
// On other errors, nothing is written to |buffer| and 0 is returned.
//
//   annot          - handle to an annotation.
//   appearanceMode - the appearance mode (normal, rollover or down) for which
//                    to get the AP.
//   buffer         - buffer for holding the value string, encoded in UTF-16LE.
//   buflen         - length of the buffer in bytes.
//
// Returns the length of the string value in bytes.
var
  FPDFAnnot_GetAP: function(annot: FPDF_ANNOTATION; appearanceMode: FPDF_ANNOT_APPEARANCEMODE; buffer: PFPDF_WCHAR;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the annotation corresponding to |key| in |annot|'s dictionary. Common
// keys for linking annotations include "IRT" and "Popup". Must call
// FPDFPage_CloseAnnot() when the annotation returned by this function is no
// longer needed.
//
//   annot  - handle to an annotation.
//   key    - the key to the requested dictionary entry, encoded in UTF-8.
//
// Returns a handle to the linked annotation object, or NULL on failure.
var
  FPDFAnnot_GetLinkedAnnot: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING): FPDF_ANNOTATION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the annotation flags of |annot|.
//
//   annot    - handle to an annotation.
//
// Returns the annotation flags.
var
  FPDFAnnot_GetFlags: function(annot: FPDF_ANNOTATION): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the |annot|'s flags to be of the value |flags|.
//
//   annot      - handle to an annotation.
//   flags      - the flag values to be set.
//
// Returns true if successful.
var
  FPDFAnnot_SetFlags: function(annot: FPDF_ANNOTATION; flags: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the annotation flags of |annot|.
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    annot       -   handle to an interactive form annotation.
//
// Returns the annotation flags specific to interactive forms.
var
  FPDFAnnot_GetFormFieldFlags: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Retrieves an interactive form annotation whose rectangle contains a given
// point on a page. Must call FPDFPage_CloseAnnot() when the annotation returned
// is no longer needed.
//
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    page        -   handle to the page, returned by FPDF_LoadPage function.
//    point       -   position in PDF "user space".
//
// Returns the interactive form annotation whose rectangle contains the given
// coordinates on the page. If there is no such annotation, return NULL.
var
  FPDFAnnot_GetFormFieldAtPoint: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE;
    const point: PFS_POINTF): FPDF_ANNOTATION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets the name of |annot|, which is an interactive form annotation.
// |buffer| is only modified if |buflen| is longer than the length of contents.
// In case of error, nothing will be added to |buffer| and the return value will
// be 0. Note that return value of empty string is 2 for "\0\0".
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    annot       -   handle to an interactive form annotation.
//    buffer      -   buffer for holding the name string, encoded in UTF-16LE.
//    buflen      -   length of the buffer in bytes.
//
// Returns the length of the string value in bytes.
var
  FPDFAnnot_GetFormFieldName: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION; buffer: PFPDF_WCHAR;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets the alternate name of |annot|, which is an interactive form annotation.
// |buffer| is only modified if |buflen| is longer than the length of contents.
// In case of error, nothing will be added to |buffer| and the return value will
// be 0. Note that return value of empty string is 2 for "\0\0".
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    annot       -   handle to an interactive form annotation.
//    buffer      -   buffer for holding the alternate name string, encoded in
//                    UTF-16LE.
//    buflen      -   length of the buffer in bytes.
//
// Returns the length of the string value in bytes.
var
  FPDFAnnot_GetFormFieldAlternateName: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION; buffer: PFPDF_WCHAR;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets the form field type of |annot|, which is an interactive form annotation.
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    annot       -   handle to an interactive form annotation.
//
// Returns the type of the form field (one of the FPDF_FORMFIELD_* values) on
// success. Returns -1 on error.
// See field types in fpdf_formfill.h.
var
  FPDFAnnot_GetFormFieldType: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets the value of |annot|, which is an interactive form annotation.
// |buffer| is only modified if |buflen| is longer than the length of contents.
// In case of error, nothing will be added to |buffer| and the return value will
// be 0. Note that return value of empty string is 2 for "\0\0".
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    annot       -   handle to an interactive form annotation.
//    buffer      -   buffer for holding the value string, encoded in UTF-16LE.
//    buflen      -   length of the buffer in bytes.
//
// Returns the length of the string value in bytes.
var
  FPDFAnnot_GetFormFieldValue: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION; buffer: PFPDF_WCHAR;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the number of options in the |annot|'s "Opt" dictionary. Intended for
// use with listbox and combobox widget annotations.
//
//   hHandle - handle to the form fill module, returned by
//             FPDFDOC_InitFormFillEnvironment.
//   annot   - handle to an annotation.
//
// Returns the number of options in "Opt" dictionary on success. Return value
// will be -1 if annotation does not have an "Opt" dictionary or other error.
var
  FPDFAnnot_GetOptionCount: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the string value for the label of the option at |index| in |annot|'s
// "Opt" dictionary. Intended for use with listbox and combobox widget
// annotations. |buffer| is only modified if |buflen| is longer than the length
// of contents. If index is out of range or in case of other error, nothing
// will be added to |buffer| and the return value will be 0. Note that
// return value of empty string is 2 for "\0\0".
//
//   hHandle - handle to the form fill module, returned by
//             FPDFDOC_InitFormFillEnvironment.
//   annot   - handle to an annotation.
//   index   - numeric index of the option in the "Opt" array
//   buffer  - buffer for holding the value string, encoded in UTF-16LE.
//   buflen  - length of the buffer in bytes.
//
// Returns the length of the string value in bytes.
// If |annot| does not have an "Opt" array, |index| is out of range or if any
// other error occurs, returns 0.
var
  FPDFAnnot_GetOptionLabel: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION; index: Integer;
    buffer: PFPDF_WCHAR; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Determine whether or not the option at |index| in |annot|'s "Opt" dictionary
// is selected. Intended for use with listbox and combobox widget annotations.
//
//   handle  - handle to the form fill module, returned by
//             FPDFDOC_InitFormFillEnvironment.
//   annot   - handle to an annotation.
//   index   - numeric index of the option in the "Opt" array.
//
// Returns true if the option at |index| in |annot|'s "Opt" dictionary is
// selected, false otherwise.
var
  FPDFAnnot_IsOptionSelected: function(handle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION; index: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the float value of the font size for an |annot| with variable text.
// If 0, the font is to be auto-sized: its size is computed as a function of
// the height of the annotation rectangle.
//
//   hHandle - handle to the form fill module, returned by
//             FPDFDOC_InitFormFillEnvironment.
//   annot   - handle to an annotation.
//   value   - Required. Float which will be set to font size on success.
//
// Returns true if the font size was set in |value|, false on error or if
// |value| not provided.
var
  FPDFAnnot_GetFontSize: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION; var value: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Determine if |annot| is a form widget that is checked. Intended for use with
// checkbox and radio button widgets.
//
//   hHandle - handle to the form fill module, returned by
//             FPDFDOC_InitFormFillEnvironment.
//   annot   - handle to an annotation.
//
// Returns true if |annot| is a form widget and is checked, false otherwise.
var
  FPDFAnnot_IsChecked: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the list of focusable annotation subtypes. Annotations of subtype
// FPDF_ANNOT_WIDGET are by default focusable. New subtypes set using this API
// will override the existing subtypes.
//
//   hHandle  - handle to the form fill module, returned by
//              FPDFDOC_InitFormFillEnvironment.
//   subtypes - list of annotation subtype which can be tabbed over.
//   count    - total number of annotation subtype in list.
// Returns true if list of annotation subtype is set successfully, false
// otherwise.
var
  FPDFAnnot_SetFocusableSubtypes: function(hHandle: FPDF_FORMHANDLE; const subtypes: PFPDF_ANNOTATION_SUBTYPE;
    count: SIZE_T): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the count of focusable annotation subtypes as set by host
// for a |hHandle|.
//
//   hHandle  - handle to the form fill module, returned by
//              FPDFDOC_InitFormFillEnvironment.
// Returns the count of focusable annotation subtypes or -1 on error.
// Note : Annotations of type FPDF_ANNOT_WIDGET are by default focusable.
var
  FPDFAnnot_GetFocusableSubtypesCount: function(hHandle: FPDF_FORMHANDLE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the list of focusable annotation subtype as set by host.
//
//   hHandle  - handle to the form fill module, returned by
//              FPDFDOC_InitFormFillEnvironment.
//   subtypes - receives the list of annotation subtype which can be tabbed
//              over. Caller must have allocated |subtypes| more than or
//              equal to the count obtained from
//              FPDFAnnot_GetFocusableSubtypesCount() API.
//   count    - size of |subtypes|.
// Returns true on success and set list of annotation subtype to |subtypes|,
// false otherwise.
// Note : Annotations of type FPDF_ANNOT_WIDGET are by default focusable.
var
  FPDFAnnot_GetFocusableSubtypes: function(hHandle: FPDF_FORMHANDLE; subtypes: PFPDF_ANNOTATION_SUBTYPE;
    count: SIZE_T): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets FPDF_LINK object for |annot|. Intended to use for link annotations.
//
//   annot   - handle to an annotation.
//
// Returns FPDF_LINK from the FPDF_ANNOTATION and NULL on failure,
// if the input annot is NULL or input annot's subtype is not link.
var
  FPDFAnnot_GetLink: function(annot: FPDF_ANNOTATION): FPDF_LINK; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets the count of annotations in the |annot|'s control group.
// A group of interactive form annotations is collectively called a form
// control group. Here, |annot|, an interactive form annotation, should be
// either a radio button or a checkbox.
//
//   hHandle - handle to the form fill module, returned by
//             FPDFDOC_InitFormFillEnvironment.
//   annot   - handle to an annotation.
//
// Returns number of controls in its control group or -1 on error.
var
  FPDFAnnot_GetFormControlCount: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets the index of |annot| in |annot|'s control group.
// A group of interactive form annotations is collectively called a form
// control group. Here, |annot|, an interactive form annotation, should be
// either a radio button or a checkbox.
//
//   hHandle - handle to the form fill module, returned by
//             FPDFDOC_InitFormFillEnvironment.
//   annot   - handle to an annotation.
//
// Returns index of a given |annot| in its control group or -1 on error.
var
  FPDFAnnot_GetFormControlIndex: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets the export value of |annot| which is an interactive form annotation.
// Intended for use with radio button and checkbox widget annotations.
// |buffer| is only modified if |buflen| is longer than the length of contents.
// In case of error, nothing will be added to |buffer| and the return value
// will be 0. Note that return value of empty string is 2 for "\0\0".
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    annot       -   handle to an interactive form annotation.
//    buffer      -   buffer for holding the value string, encoded in UTF-16LE.
//    buflen      -   length of the buffer in bytes.
//
// Returns the length of the string value in bytes.
var
  FPDFAnnot_GetFormFieldExportValue: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION;
    buffer: PFPDF_WCHAR; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Add a URI action to |annot|, overwriting the existing action, if any.
//
//   annot  - handle to a link annotation.
//   uri    - the URI to be set, encoded in 7-bit ASCII.
//
// Returns true if successful.
var
  FPDFAnnot_SetURI: function(annot: FPDF_ANNOTATION; uri: PAnsiChar): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// *** _FPDF_CATALOG_H_ ***

//**
//* Experimental API.
//*
//* Determine if |document| represents a tagged PDF.
//*
//* For the definition of tagged PDF, See (see 10.7 "Tagged PDF" in PDF
//* Reference 1.7).
//*
//*   document - handle to a document.
//*
//* Returns |true| iff |document| is a tagged PDF.
//*
var
  FPDFCatalog_IsTagged: function(document: FPDF_DOCUMENT): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_ATTACHMENT_H_ ***

// Experimental API.
// Get the number of embedded files in |document|.
//
//   document - handle to a document.
//
// Returns the number of embedded files in |document|.
var
  FPDFDoc_GetAttachmentCount: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Add an embedded file with |name| in |document|. If |name| is empty, or if
// |name| is the name of a existing embedded file in |document|, or if
// |document|'s embedded file name tree is too deep (i.e. |document| has too
// many embedded files already), then a new attachment will not be added.
//
//   document - handle to a document.
//   name     - name of the new attachment.
//
// Returns a handle to the new attachment object, or NULL on failure.
var
  FPDFDoc_AddAttachment: function(document: FPDF_DOCUMENT; name: FPDF_WIDESTRING): FPDF_ATTACHMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the embedded attachment at |index| in |document|. Note that the returned
// attachment handle is only valid while |document| is open.
//
//   document - handle to a document.
//   index    - the index of the requested embedded file.
//
// Returns the handle to the attachment object, or NULL on failure.
var
  FPDFDoc_GetAttachment: function(document: FPDF_DOCUMENT; index: Integer): FPDF_ATTACHMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Delete the embedded attachment at |index| in |document|. Note that this does
// not remove the attachment data from the PDF file; it simply removes the
// file's entry in the embedded files name tree so that it does not appear in
// the attachment list. This behavior may change in the future.
//
//   document - handle to a document.
//   index    - the index of the embedded file to be deleted.
//
// Returns true if successful.
var
  FPDFDoc_DeleteAttachment: function(document: FPDF_DOCUMENT; index: Integer): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the name of the |attachment| file. |buffer| is only modified if |buflen|
// is longer than the length of the file name. On errors, |buffer| is unmodified
// and the returned length is 0.
//
//   attachment - handle to an attachment.
//   buffer     - buffer for holding the file name, encoded in UTF-16LE.
//   buflen     - length of the buffer in bytes.
//
// Returns the length of the file name in bytes.
var
  FPDFAttachment_GetName: function(attachment: FPDF_ATTACHMENT; buffer: PFPDF_WCHAR; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Check if the params dictionary of |attachment| has |key| as a key.
//
//   attachment - handle to an attachment.
//   key        - the key to look for, encoded in UTF-8.
//
// Returns true if |key| exists.
var
  FPDFAttachment_HasKey: function(attachment: FPDF_ATTACHMENT; key: FPDF_BYTESTRING): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the type of the value corresponding to |key| in the params dictionary of
// the embedded |attachment|.
//
//   attachment - handle to an attachment.
//   key        - the key to look for, encoded in UTF-8.
//
// Returns the type of the dictionary value.
var
  FPDFAttachment_GetValueType: function(attachment: FPDF_ATTACHMENT; key: FPDF_BYTESTRING): FPDF_OBJECT_TYPE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the string value corresponding to |key| in the params dictionary of the
// embedded file |attachment|, overwriting the existing value if any. The value
// type should be FPDF_OBJECT_STRING after this function call succeeds.
//
//   attachment - handle to an attachment.
//   key        - the key to the dictionary entry, encoded in UTF-8.
//   value      - the string value to be set, encoded in UTF-16LE.
//
// Returns true if successful.
var
  FPDFAttachment_SetStringValue: function(attachment: FPDF_ATTACHMENT; key: FPDF_BYTESTRING;
    value: FPDF_WIDESTRING): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the string value corresponding to |key| in the params dictionary of the
// embedded file |attachment|. |buffer| is only modified if |buflen| is longer
// than the length of the string value. Note that if |key| does not exist in the
// dictionary or if |key|'s corresponding value in the dictionary is not a
// string (i.e. the value is not of type FPDF_OBJECT_STRING or
// FPDF_OBJECT_NAME), then an empty string would be copied to |buffer| and the
// return value would be 2. On other errors, nothing would be added to |buffer|
// and the return value would be 0.
//
//   attachment - handle to an attachment.
//   key        - the key to the requested string value, encoded in UTF-8.
//   buffer     - buffer for holding the string value encoded in UTF-16LE.
//   buflen     - length of the buffer in bytes.
//
// Returns the length of the dictionary value string in bytes.
var
  FPDFAttachment_GetStringValue: function(attachment: FPDF_ATTACHMENT; key: FPDF_BYTESTRING; buffer: PFPDF_WCHAR;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Set the file data of |attachment|, overwriting the existing file data if any.
// The creation date and checksum will be updated, while all other dictionary
// entries will be deleted. Note that only contents with |len| smaller than
// INT_MAX is supported.
//
//   attachment - handle to an attachment.
//   contents   - buffer holding the file data to write to |attachment|.
//   len        - length of file data in bytes.
//
// Returns true if successful.
var
  FPDFAttachment_SetFile: function(attachment: FPDF_ATTACHMENT; document: FPDF_DOCUMENT;
    contents: Pointer; len: LongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the file data of |attachment|.
// When the attachment file data is readable, true is returned, and |out_buflen|
// is updated to indicate the file data size. |buffer| is only modified if
// |buflen| is non-null and long enough to contain the entire file data. Callers
// must check both the return value and the input |buflen| is no less than the
// returned |out_buflen| before using the data.
//
// Otherwise, when the attachment file data is unreadable or when |out_buflen|
// is null, false is returned and |buffer| and |out_buflen| remain unmodified.
//
//   attachment - handle to an attachment.
//   buffer     - buffer for holding the file data from |attachment|.
//   buflen     - length of the buffer in bytes.
//   out_buflen - pointer to the variable that will receive the minimum buffer
//                size to contain the file data of |attachment|.
//
// Returns true on success, false otherwise.
var
  FPDFAttachment_GetFile: function(attachment: FPDF_ATTACHMENT; buffer: Pointer; buflen: LongWord;
    var out_buflen: LongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_FWLEVENT_H_ ***

// Key flags.
type
  FWL_EVENTFLAG = Integer;
const
  FWL_EVENTFLAG_ShiftKey = 1 shl 0;
  FWL_EVENTFLAG_ControlKey = 1 shl 1;
  FWL_EVENTFLAG_AltKey = 1 shl 2;
  FWL_EVENTFLAG_MetaKey = 1 shl 3;
  FWL_EVENTFLAG_KeyPad = 1 shl 4;
  FWL_EVENTFLAG_AutoRepeat = 1 shl 5;
  FWL_EVENTFLAG_LeftButtonDown = 1 shl 6;
  FWL_EVENTFLAG_MiddleButtonDown = 1 shl 7;
  FWL_EVENTFLAG_RightButtonDown = 1 shl 8;

type
  FWL_VKEYCODE = Integer; // note: FWL_VKEY_* equals Windows.VK_*


// *** _FPDF_TRANSFORMPAGE_H_ ***

//**
//* Set "MediaBox" entry to the page dictionary.
//*
//* page   - Handle to a page.
//* left   - The left of the rectangle.
//* bottom - The bottom of the rectangle.
//* right  - The right of the rectangle.
//* top    - The top of the rectangle.
//*
var
  FPDFPage_SetMediaBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Set "CropBox" entry to the page dictionary.
//*
//* page   - Handle to a page.
//* left   - The left of the rectangle.
//* bottom - The bottom of the rectangle.
//* right  - The right of the rectangle.
//* top    - The top of the rectangle.
//*
var
  FPDFPage_SetCropBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Set "BleedBox" entry to the page dictionary.
//*
//* page   - Handle to a page.
//* left   - The left of the rectangle.
//* bottom - The bottom of the rectangle.
//* right  - The right of the rectangle.
//* top    - The top of the rectangle.
//*
var
  FPDFPage_SetBleedBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


//**
//* Set "TrimBox" entry to the page dictionary.
//*
//* page   - Handle to a page.
//* left   - The left of the rectangle.
//* bottom - The bottom of the rectangle.
//* right  - The right of the rectangle.
//* top    - The top of the rectangle.
//*
var
  FPDFPage_SetTrimBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


//**
//* Set "ArtBox" entry to the page dictionary.
//*
//* page   - Handle to a page.
//* left   - The left of the rectangle.
//* bottom - The bottom of the rectangle.
//* right  - The right of the rectangle.
//* top    - The top of the rectangle.
//*
var
  FPDFPage_SetArtBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Get "MediaBox" entry from the page dictionary.
//*
//* page   - Handle to a page.
//* left   - Pointer to a float value receiving the left of the rectangle.
//* bottom - Pointer to a float value receiving the bottom of the rectangle.
//* right  - Pointer to a float value receiving the right of the rectangle.
//* top    - Pointer to a float value receiving the top of the rectangle.
//*
//* On success, return true and write to the out parameters. Otherwise return
//* false and leave the out parameters unmodified.
//*
var
  FPDFPage_GetMediaBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Get "CropBox" entry from the page dictionary.
//*
//* page   - Handle to a page.
//* left   - Pointer to a float value receiving the left of the rectangle.
//* bottom - Pointer to a float value receiving the bottom of the rectangle.
//* right  - Pointer to a float value receiving the right of the rectangle.
//* top    - Pointer to a float value receiving the top of the rectangle.
//*
//* On success, return true and write to the out parameters. Otherwise return
//* false and leave the out parameters unmodified.
//*
var
  FPDFPage_GetCropBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Get "BleedBox" entry from the page dictionary.
//*
//* page   - Handle to a page.
//* left   - Pointer to a float value receiving the left of the rectangle.
//* bottom - Pointer to a float value receiving the bottom of the rectangle.
//* right  - Pointer to a float value receiving the right of the rectangle.
//* top    - Pointer to a float value receiving the top of the rectangle.
//*
//* On success, return true and write to the out parameters. Otherwise return
//* false and leave the out parameters unmodified.
//*
var
  FPDFPage_GetBleedBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Get "TrimBox" entry from the page dictionary.
//*
//* page   - Handle to a page.
//* left   - Pointer to a float value receiving the left of the rectangle.
//* bottom - Pointer to a float value receiving the bottom of the rectangle.
//* right  - Pointer to a float value receiving the right of the rectangle.
//* top    - Pointer to a float value receiving the top of the rectangle.
//*
//* On success, return true and write to the out parameters. Otherwise return
//* false and leave the out parameters unmodified.
//*
var
  FPDFPage_GetTrimBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Get "ArtBox" entry from the page dictionary.
//*
//* page   - Handle to a page.
//* left   - Pointer to a float value receiving the left of the rectangle.
//* bottom - Pointer to a float value receiving the bottom of the rectangle.
//* right  - Pointer to a float value receiving the right of the rectangle.
//* top    - Pointer to a float value receiving the top of the rectangle.
//*
//* On success, return true and write to the out parameters. Otherwise return
//* false and leave the out parameters unmodified.
//*
var
  FPDFPage_GetArtBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Apply transforms to |page|.
//*
//* If |matrix| is provided it will be applied to transform the page.
//* If |clipRect| is provided it will be used to clip the resulting page.
//* If neither |matrix| or |clipRect| are provided this method returns |false|.
//* Returns |true| if transforms are applied.
//*
//* This function will transform the whole page, and would take effect to all the
//* objects in the page.
//*
//* page        - Page handle.
//* matrix      - Transform matrix.
//* clipRect    - Clipping rectangle.
//*
var
  FPDFPage_TransFormWithClip: function(page: FPDF_PAGE; matrix: PFS_MATRIX; clipRect: PFS_RECTF): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Transform (scale, rotate, shear, move) the clip path of page object.
//* page_object - Handle to a page object. Returned by
//* FPDFPageObj_NewImageObj().
//*
//* a  - The coefficient "a" of the matrix.
//* b  - The coefficient "b" of the matrix.
//* c  - The coefficient "c" of the matrix.
//* d  - The coefficient "d" of the matrix.
//* e  - The coefficient "e" of the matrix.
//* f  - The coefficient "f" of the matrix.
//*
var
  FPDFPageObj_TransformClipPath: procedure(page_object: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the clip path of the page object.
//
//   page object - Handle to a page object. Returned by e.g.
//                 FPDFPage_GetObject().
//
// Returns the handle to the clip path, or NULL on failure. The caller does not
// take ownership of the returned FPDF_CLIPPATH. Instead, it remains valid until
// FPDF_ClosePage() is called for the page containing |page_object|.
var
  FPDFPageObj_GetClipPath: function(page_object: FPDF_PAGEOBJECT): FPDF_CLIPPATH; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get number of paths inside |clip_path|.
//
//   clip_path - handle to a clip_path.
//
// Returns the number of objects in |clip_path| or -1 on failure.
var
  FPDFClipPath_CountPaths: function(clip_path: FPDF_CLIPPATH): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get number of segments inside one path of |clip_path|.
//
//   clip_path  - handle to a clip_path.
//   path_index - index into the array of paths of the clip path.
//
// Returns the number of segments or -1 on failure.
var
  FPDFClipPath_CountPathSegments: function(clip_path: FPDF_CLIPPATH; path_index: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get segment in one specific path of |clip_path| at index.
//
//   clip_path     - handle to a clip_path.
//   path_index    - the index of a path.
//   segment_index - the index of a segment.
//
// Returns the handle to the segment, or NULL on failure. The caller does not
// take ownership of the returned FPDF_PATHSEGMENT. Instead, it remains valid
// until FPDF_ClosePage() is called for the page containing |clip_path|.
var
  FPDFClipPath_GetPathSegment: function(clip_path: FPDF_CLIPPATH; path_index, segment_index: Integer): FPDF_PATHSEGMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Create a new clip path, with a rectangle inserted.
//*
//* Caller takes ownership of the returned FPDF_CLIPPATH. It should be freed with
//* FPDF_DestroyClipPath().
//*
//* left   - The left of the clip box.
//* bottom - The bottom of the clip box.
//* right  - The right of the clip box.
//* top    - The top of the clip box.
//*
var
  FPDF_CreateClipPath: function(page_object: FPDF_PAGEOBJECT; left, bottom, right, top: Single): FPDF_CLIPPATH; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Destroy the clip path.
//*
//* clipPath - A handle to the clip path. It will be invalid after this call.
//*
var
  FPDF_DestroyClipPath: procedure(clipPath: FPDF_CLIPPATH); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

//**
//* Clip the page content, the page content that outside the clipping region
//* become invisible.
//*
//* A clip path will be inserted before the page content stream or content array.
//* In this way, the page content will be clipped by this clip path.
//*
//* page        - A page handle.
//* clipPath    - A handle to the clip path. (Does not take ownership.)
//*
var
  FPDFPage_InsertClipPath: procedure(page: FPDF_PAGE; clipPath: FPDF_CLIPPATH); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_STRUCTTREE_H_ ***

// Function: FPDF_StructTree_GetForPage
//          Get the structure tree for a page.
// Parameters:
//          page        -   Handle to the page, as returned by FPDF_LoadPage().
// Return value:
//          A handle to the structure tree or NULL on error.
var
  FPDF_StructTree_GetForPage: function(page: FPDF_PAGE): FPDF_STRUCTTREE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructTree_Close
//          Release a resource allocated by FPDF_StructTree_GetForPage().
// Parameters:
//          struct_tree -   Handle to the structure tree, as returned by
//                          FPDF_StructTree_LoadPage().
// Return value:
//          None.
var
  FPDF_StructTree_Close: procedure(struct_tree: FPDF_STRUCTTREE); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructTree_CountChildren
//          Count the number of children for the structure tree.
// Parameters:
//          struct_tree -   Handle to the structure tree, as returned by
//                          FPDF_StructTree_LoadPage().
// Return value:
//          The number of children, or -1 on error.
var
  FPDF_StructTree_CountChildren: function(struct_tree: FPDF_STRUCTTREE): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructTree_GetChildAtIndex
//          Get a child in the structure tree.
// Parameters:
//          struct_tree -   Handle to the structure tree, as returned by
//                          FPDF_StructTree_LoadPage().
//          index       -   The index for the child, 0-based.
// Return value:
//          The child at the n-th index or NULL on error.
var
  FPDF_StructTree_GetChildAtIndex: function(struct_tree: FPDF_STRUCTTREE; index: Integer): FPDF_STRUCTELEMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructElement_GetAltText
//          Get the alt text for a given element.
// Parameters:
//          struct_element -   Handle to the struct element.
//          buffer         -   A buffer for output the alt text. May be NULL.
//          buflen         -   The length of the buffer, in bytes. May be 0.
// Return value:
//          The number of bytes in the alt text, including the terminating NUL
//          character. The number of bytes is returned regardless of the
//          |buffer| and |buflen| parameters.
// Comments:
//          Regardless of the platform, the |buffer| is always in UTF-16LE
//          encoding. The string is terminated by a UTF16 NUL character. If
//          |buflen| is less than the required length, or |buffer| is NULL,
//          |buffer| will not be modified.
var
  FPDF_StructElement_GetAltText: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_GetActualText
//          Get the actual text for a given element.
// Parameters:
//          struct_element -   Handle to the struct element.
//          buffer         -   A buffer for output the actual text. May be NULL.
//          buflen         -   The length of the buffer, in bytes. May be 0.
// Return value:
//          The number of bytes in the actual text, including the terminating
//          NUL character. The number of bytes is returned regardless of the
//          |buffer| and |buflen| parameters.
// Comments:
//          Regardless of the platform, the |buffer| is always in UTF-16LE
//          encoding. The string is terminated by a UTF16 NUL character. If
//          |buflen| is less than the required length, or |buffer| is NULL,
//          |buffer| will not be modified.
var
  FPDF_StructElement_GetActualText: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructElement_GetID
//          Get the ID for a given element.
// Parameters:
//          struct_element -   Handle to the struct element.
//          buffer         -   A buffer for output the ID string. May be NULL.
//          buflen         -   The length of the buffer, in bytes. May be 0.
// Return value:
//          The number of bytes in the ID string, including the terminating NUL
//          character. The number of bytes is returned regardless of the
//          |buffer| and |buflen| parameters.
// Comments:
//          Regardless of the platform, the |buffer| is always in UTF-16LE
//          encoding. The string is terminated by a UTF16 NUL character. If
//          |buflen| is less than the required length, or |buffer| is NULL,
//          |buffer| will not be modified.
var
  FPDF_StructElement_GetID: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_GetLang
//          Get the case-insensitive IETF BCP 47 language code for an element.
// Parameters:
//          struct_element -   Handle to the struct element.
//          buffer         -   A buffer for output the lang string. May be NULL.
//          buflen         -   The length of the buffer, in bytes. May be 0.
// Return value:
//          The number of bytes in the ID string, including the terminating NUL
//          character. The number of bytes is returned regardless of the
//          |buffer| and |buflen| parameters.
// Comments:
//          Regardless of the platform, the |buffer| is always in UTF-16LE
//          encoding. The string is terminated by a UTF16 NUL character. If
//          |buflen| is less than the required length, or |buffer| is NULL,
//          |buffer| will not be modified.
var
  FPDF_StructElement_GetLang: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_GetStringAttribute
//          Get a struct element attribute of type "name" or "string".
// Parameters:
//          struct_element -   Handle to the struct element.
//          attr_name      -   The name of the attribute to retrieve.
//          buffer         -   A buffer for output. May be NULL.
//          buflen         -   The length of the buffer, in bytes. May be 0.
// Return value:
//          The number of bytes in the attribute value, including the
//          terminating NUL character. The number of bytes is returned
//          regardless of the |buffer| and |buflen| parameters.
// Comments:
//          Regardless of the platform, the |buffer| is always in UTF-16LE
//          encoding. The string is terminated by a UTF16 NUL character. If
//          |buflen| is less than the required length, or |buffer| is NULL,
//          |buffer| will not be modified.
var
  FPDF_StructElement_GetStringAttribute: function(struct_element: FPDF_STRUCTELEMENT;
    attr_name: FPDF_BYTESTRING; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructElement_GetMarkedContentID
//          Get the marked content ID for a given element.
// Parameters:
//          struct_element -   Handle to the struct element.
// Return value:
//          The marked content ID of the element. If no ID exists, returns
//          -1.
var
  FPDF_StructElement_GetMarkedContentID: function(struct_element: FPDF_STRUCTELEMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructElement_GetType
//           Get the type (/S) for a given element.
// Parameters:
//           struct_element - Handle to the struct element.
//           buffer         - A buffer for output. May be NULL.
//           buflen         - The length of the buffer, in bytes. May be 0.
// Return value:
//           The number of bytes in the type, including the terminating NUL
//           character. The number of bytes is returned regardless of the
//           |buffer| and |buflen| parameters.
// Comments:
//           Regardless of the platform, the |buffer| is always in UTF-16LE
//           encoding. The string is terminated by a UTF16 NUL character. If
//           |buflen| is less than the required length, or |buffer| is NULL,
//           |buffer| will not be modified.
var
  FPDF_StructElement_GetType: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_GetObjType
//           Get the object type (/Type) for a given element.
// Parameters:
//           struct_element - Handle to the struct element.
//           buffer         - A buffer for output. May be NULL.
//           buflen         - The length of the buffer, in bytes. May be 0.
// Return value:
//           The number of bytes in the object type, including the terminating
//           NUL character. The number of bytes is returned regardless of the
//           |buffer| and |buflen| parameters.
// Comments:
//           Regardless of the platform, the |buffer| is always in UTF-16LE
//           encoding. The string is terminated by a UTF16 NUL character. If
//           |buflen| is less than the required length, or |buffer| is NULL,
//           |buffer| will not be modified.
var
  FPDF_StructElement_GetObjType: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructElement_GetTitle
//           Get the title (/T) for a given element.
// Parameters:
//           struct_element - Handle to the struct element.
//           buffer         - A buffer for output. May be NULL.
//           buflen         - The length of the buffer, in bytes. May be 0.
// Return value:
//           The number of bytes in the title, including the terminating NUL
//           character. The number of bytes is returned regardless of the
//           |buffer| and |buflen| parameters.
// Comments:
//           Regardless of the platform, the |buffer| is always in UTF-16LE
//           encoding. The string is terminated by a UTF16 NUL character. If
//           |buflen| is less than the required length, or |buffer| is NULL,
//           |buffer| will not be modified.
var
  FPDF_StructElement_GetTitle: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructElement_CountChildren
//          Count the number of children for the structure element.
// Parameters:
//          struct_element -   Handle to the struct element.
// Return value:
//          The number of children, or -1 on error.
var
  FPDF_StructElement_CountChildren: function(struct_element: FPDF_STRUCTELEMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructElement_GetChildAtIndex
//          Get a child in the structure element.
// Parameters:
//          struct_element -   Handle to the struct element.
//          index          -   The index for the child, 0-based.
// Return value:
//          The child at the n-th index or NULL on error.
// Comments:
//          If the child exists but is not an element, then this function will
//          return NULL. This will also return NULL for out of bounds indices.
var
  FPDF_StructElement_GetChildAtIndex: function(struct_element: FPDF_STRUCTELEMENT; index: Integer): FPDF_STRUCTELEMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_GetParent
//          Get the parent of the structure element.
// Parameters:
//          struct_element -   Handle to the struct element.
// Return value:
//          The parent structure element or NULL on error.
// Comments:
//          If structure element is StructTreeRoot, then this function will
//          return NULL.
var
  FPDF_StructElement_GetParent: function(struct_element: FPDF_STRUCTELEMENT): FPDF_STRUCTELEMENT; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Function: FPDF_StructElement_GetAttributeCount
//          Count the number of attributes for the structure element.
// Parameters:
//          struct_element -   Handle to the struct element.
// Return value:
//          The number of attributes, or -1 on error.
var
  FPDF_StructElement_GetAttributeCount: function(struct_element: FPDF_STRUCTELEMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_GetAttributeAtIndex
//          Get an attribute object in the structure element.
// Parameters:
//          struct_element -   Handle to the struct element.
//          index          -   The index for the attribute object, 0-based.
// Return value:
//          The attribute object at the n-th index or NULL on error.
// Comments:
//          If the attribute object exists but is not a dict, then this
//          function will return NULL. This will also return NULL for out of
//          bounds indices.
var
  FPDF_StructElement_GetAttributeAtIndex: function(struct_element: FPDF_STRUCTELEMENT; index: Integer): FPDF_STRUCTELEMENT_ATTR; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_Attr_GetCount
//          Count the number of attributes in a structure element attribute map.
// Parameters:
//          struct_attribute - Handle to the struct element attribute.
// Return value:
//          The number of attributes, or -1 on error.
var
  FPDF_StructElement_Attr_GetCount: function(struct_attribute: FPDF_STRUCTELEMENT_ATTR): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// Experimental API.
// Function: FPDF_StructElement_Attr_GetName
//          Get the name of an attribute in a structure element attribute map.
// Parameters:
//          struct_attribute   - Handle to the struct element attribute.
//          index              - The index of attribute in the map.
//          buffer             - A buffer for output. May be NULL. This is only
//                               modified if |buflen| is longer than the length
//                               of the key. Optional, pass null to just
//                               retrieve the size of the buffer needed.
//          buflen             - The length of the buffer.
//          out_buflen         - A pointer to variable that will receive the
//                               minimum buffer size to contain the key. Not
//                               filled if FALSE is returned.
// Return value:
//          TRUE if the operation was successful, FALSE otherwise.
var
  FPDF_StructElement_Attr_GetName: function(struct_attribute: FPDF_STRUCTELEMENT_ATTR; index: Integer; buffer: Pointer;
    buflen: LongWord; var out_buflen: LongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_Attr_GetType
//          Get the type of an attribute in a structure element attribute map.
// Parameters:
//          struct_attribute   - Handle to the struct element attribute.
//          name               - The attribute name.
// Return value:
//          Returns the type of the value, or FPDF_OBJECT_UNKNOWN in case of
//          failure.
var
  FPDF_StructElement_Attr_GetType: function(struct_attribute: FPDF_STRUCTELEMENT_ATTR; name: FPDF_BYTESTRING): FPDF_OBJECT_TYPE; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_Attr_GetBooleanValue
//          Get the value of a boolean attribute in an attribute map by name as
//          FPDF_BOOL. FPDF_StructElement_Attr_GetType() should have returned
//          FPDF_OBJECT_BOOLEAN for this property.
// Parameters:
//          struct_attribute   - Handle to the struct element attribute.
//          name               - The attribute name.
//          out_value          - A pointer to variable that will receive the
//                               value. Not filled if false is returned.
// Return value:
//          Returns TRUE if the name maps to a boolean value, FALSE otherwise.
var
  FPDF_StructElement_Attr_GetBooleanValue: function(struct_attribute: FPDF_STRUCTELEMENT_ATTR; name: FPDF_BYTESTRING;
    var out_value: FPDF_BOOL): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_Attr_GetNumberValue
//          Get the value of a number attribute in an attribute map by name as
//          float. FPDF_StructElement_Attr_GetType() should have returned
//          FPDF_OBJECT_NUMBER for this property.
// Parameters:
//          struct_attribute   - Handle to the struct element attribute.
//          name               - The attribute name.
//          out_value          - A pointer to variable that will receive the
//                               value. Not filled if false is returned.
// Return value:
//          Returns TRUE if the name maps to a number value, FALSE otherwise.
var
  FPDF_StructElement_Attr_GetNumberValue: function(struct_attribute: FPDF_STRUCTELEMENT_ATTR; name: FPDF_BYTESTRING;
    var out_value: Single): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_Attr_GetStringValue
//          Get the value of a string attribute in an attribute map by name as
//          string. FPDF_StructElement_Attr_GetType() should have returned
//          FPDF_OBJECT_STRING or FPDF_OBJECT_NAME for this property.
// Parameters:
//          struct_attribute   - Handle to the struct element attribute.
//          name               - The attribute name.
//          buffer             - A buffer for holding the returned key in
//                               UTF-16LE. This is only modified if |buflen| is
//                               longer than the length of the key. Optional,
//                               pass null to just retrieve the size of the
//                               buffer needed.
//          buflen             - The length of the buffer.
//          out_buflen         - A pointer to variable that will receive the
//                               minimum buffer size to contain the key. Not
//                               filled if FALSE is returned.
// Return value:
//          Returns TRUE if the name maps to a string value, FALSE otherwise.
var
  FPDF_StructElement_Attr_GetStringValue: function(struct_attribute: FPDF_STRUCTELEMENT_ATTR; name: FPDF_BYTESTRING;
    buffer: Pointer; buflen: LongWord; var out_buflen: LongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_Attr_GetBlobValue
//          Get the value of a blob attribute in an attribute map by name as
//          string.
// Parameters:
//          struct_attribute   - Handle to the struct element attribute.
//          name               - The attribute name.
//          buffer             - A buffer for holding the returned value. This
//                               is only modified if |buflen| is at least as
//                               long as the length of the value. Optional, pass
//                               null to just retrieve the size of the buffer
//                               needed.
//          buflen             - The length of the buffer.
//          out_buflen         - A pointer to variable that will receive the
//                               minimum buffer size to contain the key. Not
//                               filled if FALSE is returned.
// Return value:
//          Returns TRUE if the name maps to a string value, FALSE otherwise.
var
  FPDF_StructElement_Attr_GetBlobValue: function(struct_attribute: FPDF_STRUCTELEMENT_ATTR; name: FPDF_BYTESTRING;
    buffer: Pointer; buflen: LongWord; var out_buflen: LongWord): FPDF_BOOL; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_GetMarkedContentIdCount
//          Get the count of marked content ids for a given element.
// Parameters:
//          struct_element -   Handle to the struct element.
// Return value:
//          The count of marked content ids or -1 if none exists.
var
  FPDF_StructElement_GetMarkedContentIdCount: function(struct_element: FPDF_STRUCTELEMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Function: FPDF_StructElement_GetMarkedContentIdAtIndex
//          Get the marked content id at a given index for a given element.
// Parameters:
//          struct_element -   Handle to the struct element.
//          index          -   The index of the marked content id, 0-based.
// Return value:
//          The marked content ID of the element. If no ID exists, returns
//          -1.
var
  FPDF_StructElement_GetMarkedContentIdAtIndex: function(struct_element: FPDF_STRUCTELEMENT; index: Integer): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_LIBS_H_ ***

{$IFDEF PDF_ENABLE_V8}

// Function: FPDF_InitEmbeddedLibraries
//          Initialize embedded libraries (v8, iuctl) included in pdfium
// Parameters:
//          resourcePath - a path to v8 resources (snapshot_blob.bin, icudtl.dat, ...)
// Return value:
//          None.
// Comments:
//          This function must be called before calling FPDF_InitLibrary()
//          if v8 suppport is enabled
var
  FPDF_InitEmbeddedLibraries: procedure(const resourcePath: PAnsiChar); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
{$ENDIF PDF_ENABLE_V8}


// *** _FPDF_JAVASCRIPT_H_ ***

// Experimental API.
// Get the number of JavaScript actions in |document|.
//
//   document - handle to a document.
//
// Returns the number of JavaScript actions in |document| or -1 on error.
var
  FPDFDoc_GetJavaScriptActionCount: function(document: FPDF_DOCUMENT): Integer; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the JavaScript action at |index| in |document|.
//
//   document - handle to a document.
//   index    - the index of the requested JavaScript action.
//
// Returns the handle to the JavaScript action, or NULL on failure.
// Caller owns the returned handle and must close it with
// FPDFDoc_CloseJavaScriptAction().
var
  FPDFDoc_GetJavaScriptAction: function(document: FPDF_DOCUMENT; index: Integer): FPDF_JAVASCRIPT_ACTION; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Close a loaded FPDF_JAVASCRIPT_ACTION object.

//   javascript - Handle to a JavaScript action.
var
  FPDFDoc_CloseJavaScriptAction: procedure(javascript: FPDF_JAVASCRIPT_ACTION); {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the name from the |javascript| handle. |buffer| is only modified if
// |buflen| is longer than the length of the name. On errors, |buffer| is
// unmodified and the returned length is 0.
//
//   javascript - handle to an JavaScript action.
//   buffer     - buffer for holding the name, encoded in UTF-16LE.
//   buflen     - length of the buffer in bytes.
//
// Returns the length of the JavaScript action name in bytes.
var
  FPDFJavaScriptAction_GetName: function(javascript: FPDF_JAVASCRIPT_ACTION; buffer: PFPDF_WCHAR;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Get the script from the |javascript| handle. |buffer| is only modified if
// |buflen| is longer than the length of the script. On errors, |buffer| is
// unmodified and the returned length is 0.
//
//   javascript - handle to an JavaScript action.
//   buffer     - buffer for holding the name, encoded in UTF-16LE.
//   buflen     - length of the buffer in bytes.
//
// Returns the length of the JavaScript action name in bytes.
var
  FPDFJavaScriptAction_GetScript: function(javascript: FPDF_JAVASCRIPT_ACTION; buffer: PFPDF_WCHAR;
    buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// *** _FPDF_THUMBNAIL_H_ ***

// Experimental API.
// Gets the decoded data from the thumbnail of |page| if it exists.
// This only modifies |buffer| if |buflen| less than or equal to the
// size of the decoded data. Returns the size of the decoded
// data or 0 if thumbnail DNE. Optional, pass null to just retrieve
// the size of the buffer needed.
//
//   page    - handle to a page.
//   buffer  - buffer for holding the decoded image data.
//   buflen  - length of the buffer in bytes.
var
  FPDFPage_GetDecodedThumbnailData: function(page: FPDF_PAGE; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Gets the raw data from the thumbnail of |page| if it exists.
// This only modifies |buffer| if |buflen| is less than or equal to
// the size of the raw data. Returns the size of the raw data or 0
// if thumbnail DNE. Optional, pass null to just retrieve the size
// of the buffer needed.
//
//   page    - handle to a page.
//   buffer  - buffer for holding the raw image data.
//   buflen  - length of the buffer in bytes.
var
  FPDFPage_GetRawThumbnailData: function(page: FPDF_PAGE; buffer: Pointer; buflen: LongWord): LongWord; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};

// Experimental API.
// Returns the thumbnail of |page| as a FPDF_BITMAP. Returns a nullptr
// if unable to access the thumbnail's stream.
//
//   page - handle to a page.
var
  FPDFPage_GetThumbnailAsBitmap: function(page: FPDF_PAGE): FPDF_BITMAP; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};


// ***********************************************************************

procedure InitPDFium(const DllPath: string = '' {$IFDEF PDF_ENABLE_V8}; const ResPath: string = ''{$ENDIF});
procedure InitPDFiumEx(const DllFileName: string{$IFDEF PDF_ENABLE_V8}; const ResPath: string{$ENDIF});

implementation

uses
  {$IFDEF CPUX64}
  Math,
  {$ENDIF CPUX64}
  SysUtils;

resourcestring
  RsFailedToLoadProc = 'Symbol "%s" was not found in pdfium.dll';
  RsPdfiumNotLoaded = 'pdfium.dll is not loaded';
  RsFunctionNotSupported = 'PDFium function is not supported';

function FPDF_ARGB(a, r, g, b: Byte): DWORD; inline;
begin
  Result := DWORD(b) or (DWORD(g) shl 8) or (DWORD(r) shl 16) or (DWORD(a) shl 24);
end;

function FPDF_GetBValue(argb: DWORD): Byte; inline;
begin
  Result := Byte(argb);
end;

function FPDF_GetGValue(argb: DWORD): Byte; inline;
begin
  Result := Byte(argb shr 8);
end;

function FPDF_GetRValue(argb: DWORD): Byte; inline;
begin
  Result := Byte(argb shr 16);
end;

function FPDF_GetAValue(argb: DWORD): Byte; inline;
begin
  Result := Byte(argb shr 24);
end;

{$IFDEF PDF_ENABLE_XFA}
function IS_XFA_FORMFIELD(type_: Integer): Boolean; inline;
begin
  case type_ of
    FPDF_FORMFIELD_XFA,
    FPDF_FORMFIELD_XFA_CHECKBOX,
    FPDF_FORMFIELD_XFA_COMBOBOX,
    FPDF_FORMFIELD_XFA_IMAGEFIELD,
    FPDF_FORMFIELD_XFA_LISTBOX,
    FPDF_FORMFIELD_XFA_PUSHBUTTON,
    FPDF_FORMFIELD_XFA_SIGNATURE,
    FPDF_FORMFIELD_XFA_TEXTFIELD:
      Result := True;
  else
    Result := False;
  end;
end;
{$ENDIF PDF_ENABLE_XFA}


type
  TImportFuncRec = record
    P: PPointer;
    {$IF defined(FPC) and not defined(MSWINDOWS)}
    N: AnsiString; // The "dynlibs" unit's GetProcAddress uses an AnsiString instead of PAnsiChar
    {$ELSE}
    N: PAnsiChar;
    {$IFEND}
    Quirk: Boolean; // True: if the symbol can't be found, no exception is raised. If both Quirk
                    //       and Optional are True and the symbol can't be found, it will be mapped
                    //       to FunctionNotSupported.
                    // (used if the symbol's name has changed and both DLL versions should be supported)
    Optional: Boolean; // True: If the symbol can't be found, it is set to nil.
                       // (used for optional exported features like V8 and XFA)
  end;

const
  {$IFDEF FPC}
    {$WARN 3175 off : Some fields coming before "$1" were not initialized}
    {$WARN 3177 off : Some fields coming after "$1" were not initialized}
  {$ENDIF FPC}
  ImportFuncs: array[0..427
    {$IFDEF MSWINDOWS     } + 2 {$ENDIF}
    {$IFDEF _SKIA_SUPPORT_} + 2 {$ENDIF}
    {$IFDEF PDF_ENABLE_V8 } + 3 {$ENDIF}
    {$IFDEF PDF_ENABLE_XFA} + 3 {$ENDIF}
    ] of TImportFuncRec = (

    // *** _FPDFVIEW_H_ ***
    (P: @@FPDF_InitLibraryWithConfig;                   N: 'FPDF_InitLibraryWithConfig'),
    (P: @@FPDF_InitLibrary;                             N: 'FPDF_InitLibrary'),
    (P: @@FPDF_DestroyLibrary;                          N: 'FPDF_DestroyLibrary'),
    (P: @@FPDF_SetSandBoxPolicy;                        N: 'FPDF_SetSandBoxPolicy'),
    {$IFDEF MSWINDOWS}
    (P: @@FPDF_SetPrintMode;                            N: 'FPDF_SetPrintMode'),
    {$ENDIF MSWINDOWS}
    (P: @@FPDF_LoadDocument;                            N: 'FPDF_LoadDocument'),
    (P: @@FPDF_LoadMemDocument;                         N: 'FPDF_LoadMemDocument'),
    (P: @@FPDF_LoadMemDocument64;                       N: 'FPDF_LoadMemDocument64'),
    (P: @@FPDF_LoadCustomDocument;                      N: 'FPDF_LoadCustomDocument'),
    (P: @@FPDF_GetFileVersion;                          N: 'FPDF_GetFileVersion'),
    (P: @@FPDF_GetLastError;                            N: 'FPDF_GetLastError'),
    (P: @@FPDF_DocumentHasValidCrossReferenceTable;     N: 'FPDF_DocumentHasValidCrossReferenceTable'),
    (P: @@FPDF_GetTrailerEnds;                          N: 'FPDF_GetTrailerEnds'),
    (P: @@FPDF_GetDocPermissions;                       N: 'FPDF_GetDocPermissions'),
    (P: @@FPDF_GetDocUserPermissions;                   N: 'FPDF_GetDocUserPermissions'),
    (P: @@FPDF_GetSecurityHandlerRevision;              N: 'FPDF_GetSecurityHandlerRevision'),
    (P: @@FPDF_GetPageCount;                            N: 'FPDF_GetPageCount'),
    (P: @@FPDF_LoadPage;                                N: 'FPDF_LoadPage'),
    (P: @@FPDF_GetPageWidthF;                           N: 'FPDF_GetPageWidthF'),
    (P: @@FPDF_GetPageWidth;                            N: 'FPDF_GetPageWidth'),
    (P: @@FPDF_GetPageHeightF;                          N: 'FPDF_GetPageHeightF'),
    (P: @@FPDF_GetPageHeight;                           N: 'FPDF_GetPageHeight'),
    (P: @@FPDF_GetPageBoundingBox;                      N: 'FPDF_GetPageBoundingBox'),
    (P: @@FPDF_GetPageSizeByIndexF;                     N: 'FPDF_GetPageSizeByIndexF'),
    (P: @@FPDF_GetPageSizeByIndex;                      N: 'FPDF_GetPageSizeByIndex'),
    {$IFDEF MSWINDOWS}
    (P: @@FPDF_RenderPage;                              N: 'FPDF_RenderPage'),
    {$ENDIF MSWINDOWS}
    (P: @@FPDF_RenderPageBitmap;                        N: 'FPDF_RenderPageBitmap'),
    (P: @@FPDF_RenderPageBitmapWithMatrix;              N: 'FPDF_RenderPageBitmapWithMatrix'),
    {$IFDEF _SKIA_SUPPORT_}
    (P: @@FPDF_RenderPageSkia;                          N: 'FPDF_RenderPageSkia'; Quirk: True; Optional: True),
    {$ENDIF _SKIA_SUPPORT_}
    (P: @@FPDF_ClosePage;                               N: 'FPDF_ClosePage'),
    (P: @@FPDF_CloseDocument;                           N: 'FPDF_CloseDocument'),
    (P: @@FPDF_DeviceToPage;                            N: 'FPDF_DeviceToPage'),
    (P: @@FPDF_PageToDevice;                            N: 'FPDF_PageToDevice'),
    (P: @@FPDFBitmap_Create;                            N: 'FPDFBitmap_Create'),
    (P: @@FPDFBitmap_CreateEx;                          N: 'FPDFBitmap_CreateEx'),
    (P: @@FPDFBitmap_GetFormat;                         N: 'FPDFBitmap_GetFormat'),
    (P: @@FPDFBitmap_FillRect;                          N: 'FPDFBitmap_FillRect'),
    (P: @@FPDFBitmap_GetBuffer;                         N: 'FPDFBitmap_GetBuffer'),
    (P: @@FPDFBitmap_GetWidth;                          N: 'FPDFBitmap_GetWidth'),
    (P: @@FPDFBitmap_GetHeight;                         N: 'FPDFBitmap_GetHeight'),
    (P: @@FPDFBitmap_GetStride;                         N: 'FPDFBitmap_GetStride'),
    (P: @@FPDFBitmap_Destroy;                           N: 'FPDFBitmap_Destroy'),
    (P: @@FPDF_VIEWERREF_GetPrintScaling;               N: 'FPDF_VIEWERREF_GetPrintScaling'),
    (P: @@FPDF_VIEWERREF_GetNumCopies;                  N: 'FPDF_VIEWERREF_GetNumCopies'),
    (P: @@FPDF_VIEWERREF_GetPrintPageRange;             N: 'FPDF_VIEWERREF_GetPrintPageRange'),
    (P: @@FPDF_VIEWERREF_GetPrintPageRangeCount;        N: 'FPDF_VIEWERREF_GetPrintPageRangeCount'),
    (P: @@FPDF_VIEWERREF_GetPrintPageRangeElement;      N: 'FPDF_VIEWERREF_GetPrintPageRangeElement'),
    (P: @@FPDF_VIEWERREF_GetDuplex;                     N: 'FPDF_VIEWERREF_GetDuplex'),
    (P: @@FPDF_VIEWERREF_GetName;                       N: 'FPDF_VIEWERREF_GetName'),
    (P: @@FPDF_CountNamedDests;                         N: 'FPDF_CountNamedDests'),
    (P: @@FPDF_GetNamedDestByName;                      N: 'FPDF_GetNamedDestByName'),
    (P: @@FPDF_GetNamedDest;                            N: 'FPDF_GetNamedDest'),
    (P: @@FPDF_GetXFAPacketCount;                       N: 'FPDF_GetXFAPacketCount'),
    (P: @@FPDF_GetXFAPacketName;                        N: 'FPDF_GetXFAPacketName'),
    (P: @@FPDF_GetXFAPacketContent;                     N: 'FPDF_GetXFAPacketContent'),
    {$IFDEF PDF_ENABLE_V8}
    (P: @@FPDF_GetRecommendedV8Flags;                   N: 'FPDF_GetRecommendedV8Flags'; Quirk: True; Optional: True),
    (P: @@FPDF_GetArrayBufferAllocatorSharedInstance;   N: 'FPDF_GetArrayBufferAllocatorSharedInstance'; Quirk: True; Optional: True),
    {$ENDIF PDF_ENABLE_V8}
    {$IFDEF PDF_ENABLE_XFA}
    (P: @@FPDF_BStr_Init;                               N: 'FPDF_BStr_Init'; Quirk: True; Optional: True),
    (P: @@FPDF_BStr_Set;                                N: 'FPDF_BStr_Set'; Quirk: True; Optional: True),
    (P: @@FPDF_BStr_Clear;                              N: 'FPDF_BStr_Clear'; Quirk: True; Optional: True),
    {$ENDIF PDF_ENABLE_XFA}

    // *** _FPDF_EDIT_H_ ***
    (P: @@FPDF_CreateNewDocument;                       N: 'FPDF_CreateNewDocument'),
    (P: @@FPDFPage_New;                                 N: 'FPDFPage_New'),
    (P: @@FPDFPage_Delete;                              N: 'FPDFPage_Delete'),
    (P: @@FPDF_MovePages;                               N: 'FPDF_MovePages'),
    (P: @@FPDFPage_GetRotation;                         N: 'FPDFPage_GetRotation'),
    (P: @@FPDFPage_SetRotation;                         N: 'FPDFPage_SetRotation'),
    (P: @@FPDFPage_InsertObject;                        N: 'FPDFPage_InsertObject'),
    (P: @@FPDFPage_RemoveObject;                        N: 'FPDFPage_RemoveObject'),
    (P: @@FPDFPage_CountObjects;                        N: 'FPDFPage_CountObjects'),
    (P: @@FPDFPage_GetObject;                           N: 'FPDFPage_GetObject'),
    (P: @@FPDFPage_HasTransparency;                     N: 'FPDFPage_HasTransparency'),
    (P: @@FPDFPage_GenerateContent;                     N: 'FPDFPage_GenerateContent'),
    (P: @@FPDFPageObj_Destroy;                          N: 'FPDFPageObj_Destroy'),
    (P: @@FPDFPageObj_HasTransparency;                  N: 'FPDFPageObj_HasTransparency'),
    (P: @@FPDFPageObj_GetType;                          N: 'FPDFPageObj_GetType'),
    (P: @@FPDFPageObj_Transform;                        N: 'FPDFPageObj_Transform'),
    (P: @@FPDFPageObj_GetMatrix;                        N: 'FPDFPageObj_GetMatrix'),
    (P: @@FPDFPageObj_SetMatrix;                        N: 'FPDFPageObj_SetMatrix'),
    (P: @@FPDFPage_TransformAnnots;                     N: 'FPDFPage_TransformAnnots'),
    (P: @@FPDFPageObj_NewImageObj;                      N: 'FPDFPageObj_NewImageObj'),
    (P: @@FPDFPageObj_CountMarks;                       N: 'FPDFPageObj_CountMarks'),
    (P: @@FPDFPageObj_GetMark;                          N: 'FPDFPageObj_GetMark'),
    (P: @@FPDFPageObj_AddMark;                          N: 'FPDFPageObj_AddMark'),
    (P: @@FPDFPageObj_RemoveMark;                       N: 'FPDFPageObj_RemoveMark'),
    (P: @@FPDFPageObjMark_GetName;                      N: 'FPDFPageObjMark_GetName'),
    (P: @@FPDFPageObjMark_CountParams;                  N: 'FPDFPageObjMark_CountParams'),
    (P: @@FPDFPageObjMark_GetParamKey;                  N: 'FPDFPageObjMark_GetParamKey'),
    (P: @@FPDFPageObjMark_GetParamValueType;            N: 'FPDFPageObjMark_GetParamValueType'),
    (P: @@FPDFPageObjMark_GetParamIntValue;             N: 'FPDFPageObjMark_GetParamIntValue'),
    (P: @@FPDFPageObjMark_GetParamStringValue;          N: 'FPDFPageObjMark_GetParamStringValue'),
    (P: @@FPDFPageObjMark_GetParamBlobValue;            N: 'FPDFPageObjMark_GetParamBlobValue'),
    (P: @@FPDFPageObjMark_SetIntParam;                  N: 'FPDFPageObjMark_SetIntParam'),
    (P: @@FPDFPageObjMark_SetStringParam;               N: 'FPDFPageObjMark_SetStringParam'),
    (P: @@FPDFPageObjMark_SetBlobParam;                 N: 'FPDFPageObjMark_SetBlobParam'),
    (P: @@FPDFPageObjMark_RemoveParam;                  N: 'FPDFPageObjMark_RemoveParam'),
    (P: @@FPDFImageObj_LoadJpegFile;                    N: 'FPDFImageObj_LoadJpegFile'),
    (P: @@FPDFImageObj_LoadJpegFileInline;              N: 'FPDFImageObj_LoadJpegFileInline'),
    (P: @@FPDFImageObj_SetMatrix;                       N: 'FPDFImageObj_SetMatrix'),
    (P: @@FPDFImageObj_SetBitmap;                       N: 'FPDFImageObj_SetBitmap'),
    (P: @@FPDFImageObj_GetBitmap;                       N: 'FPDFImageObj_GetBitmap'),
    (P: @@FPDFImageObj_GetRenderedBitmap;               N: 'FPDFImageObj_GetRenderedBitmap'),
    (P: @@FPDFImageObj_GetImageDataDecoded;             N: 'FPDFImageObj_GetImageDataDecoded'),
    (P: @@FPDFImageObj_GetImageDataRaw;                 N: 'FPDFImageObj_GetImageDataRaw'),
    (P: @@FPDFImageObj_GetImageFilterCount;             N: 'FPDFImageObj_GetImageFilterCount'),
    (P: @@FPDFImageObj_GetImageFilter;                  N: 'FPDFImageObj_GetImageFilter'),
    (P: @@FPDFImageObj_GetImageMetadata;                N: 'FPDFImageObj_GetImageMetadata'),
    (P: @@FPDFImageObj_GetImagePixelSize;               N: 'FPDFImageObj_GetImagePixelSize'),
    (P: @@FPDFPageObj_CreateNewPath;                    N: 'FPDFPageObj_CreateNewPath'),
    (P: @@FPDFPageObj_CreateNewRect;                    N: 'FPDFPageObj_CreateNewRect'),
    (P: @@FPDFPageObj_GetBounds;                        N: 'FPDFPageObj_GetBounds'),
    (P: @@FPDFPageObj_GetRotatedBounds;                 N: 'FPDFPageObj_GetRotatedBounds'),
    (P: @@FPDFPageObj_SetBlendMode;                     N: 'FPDFPageObj_SetBlendMode'),
    (P: @@FPDFPageObj_SetStrokeColor;                   N: 'FPDFPageObj_SetStrokeColor'),
    (P: @@FPDFPageObj_GetStrokeColor;                   N: 'FPDFPageObj_GetStrokeColor'),
    (P: @@FPDFPageObj_SetStrokeWidth;                   N: 'FPDFPageObj_SetStrokeWidth'),
    (P: @@FPDFPageObj_GetStrokeWidth;                   N: 'FPDFPageObj_GetStrokeWidth'),
    (P: @@FPDFPageObj_GetLineJoin;                      N: 'FPDFPageObj_GetLineJoin'),
    (P: @@FPDFPageObj_SetLineJoin;                      N: 'FPDFPageObj_SetLineJoin'),
    (P: @@FPDFPageObj_GetLineCap;                       N: 'FPDFPageObj_GetLineCap'),
    (P: @@FPDFPageObj_SetLineCap;                       N: 'FPDFPageObj_SetLineCap'),
    (P: @@FPDFPageObj_SetFillColor;                     N: 'FPDFPageObj_SetFillColor'),
    (P: @@FPDFPageObj_GetFillColor;                     N: 'FPDFPageObj_GetFillColor'),
    (P: @@FPDFPageObj_GetDashPhase;                     N: 'FPDFPageObj_GetDashPhase'),
    (P: @@FPDFPageObj_SetDashPhase;                     N: 'FPDFPageObj_SetDashPhase'),
    (P: @@FPDFPageObj_GetDashCount;                     N: 'FPDFPageObj_GetDashCount'),
    (P: @@FPDFPageObj_GetDashArray;                     N: 'FPDFPageObj_GetDashArray'),
    (P: @@FPDFPageObj_SetDashArray;                     N: 'FPDFPageObj_SetDashArray'),
    (P: @@FPDFPath_CountSegments;                       N: 'FPDFPath_CountSegments'),
    (P: @@FPDFPath_GetPathSegment;                      N: 'FPDFPath_GetPathSegment'),
    (P: @@FPDFPathSegment_GetPoint;                     N: 'FPDFPathSegment_GetPoint'),
    (P: @@FPDFPathSegment_GetType;                      N: 'FPDFPathSegment_GetType'),
    (P: @@FPDFPathSegment_GetClose;                     N: 'FPDFPathSegment_GetClose'),
    (P: @@FPDFPath_MoveTo;                              N: 'FPDFPath_MoveTo'),
    (P: @@FPDFPath_LineTo;                              N: 'FPDFPath_LineTo'),
    (P: @@FPDFPath_BezierTo;                            N: 'FPDFPath_BezierTo'),
    (P: @@FPDFPath_Close;                               N: 'FPDFPath_Close'),
    (P: @@FPDFPath_SetDrawMode;                         N: 'FPDFPath_SetDrawMode'),
    (P: @@FPDFPath_GetDrawMode;                         N: 'FPDFPath_GetDrawMode'),
    (P: @@FPDFPageObj_NewTextObj;                       N: 'FPDFPageObj_NewTextObj'),
    (P: @@FPDFText_SetText;                             N: 'FPDFText_SetText'),
    (P: @@FPDFText_SetCharcodes;                        N: 'FPDFText_SetCharcodes'),
    (P: @@FPDFText_LoadFont;                            N: 'FPDFText_LoadFont'),
    (P: @@FPDFText_LoadStandardFont;                    N: 'FPDFText_LoadStandardFont'),
    (P: @@FPDFTextObj_GetFontSize;                      N: 'FPDFTextObj_GetFontSize'),
    (P: @@FPDFFont_Close;                               N: 'FPDFFont_Close'),
    (P: @@FPDFPageObj_CreateTextObj;                    N: 'FPDFPageObj_CreateTextObj'),
    (P: @@FPDFTextObj_GetTextRenderMode;                N: 'FPDFTextObj_GetTextRenderMode'),
    (P: @@FPDFTextObj_SetTextRenderMode;                N: 'FPDFTextObj_SetTextRenderMode'),
    (P: @@FPDFTextObj_GetText;                          N: 'FPDFTextObj_GetText'),
    (P: @@FPDFTextObj_GetRenderedBitmap;                N: 'FPDFTextObj_GetRenderedBitmap'),
    (P: @@FPDFTextObj_GetFont;                          N: 'FPDFTextObj_GetFont'),
    (P: @@FPDFFont_GetFontName;                         N: 'FPDFFont_GetFontName'),
    (P: @@FPDFFont_GetFontData;                         N: 'FPDFFont_GetFontData'),
    (P: @@FPDFFont_GetIsEmbedded;                       N: 'FPDFFont_GetIsEmbedded'),
    (P: @@FPDFFont_GetFlags;                            N: 'FPDFFont_GetFlags'),
    (P: @@FPDFFont_GetWeight;                           N: 'FPDFFont_GetWeight'),
    (P: @@FPDFFont_GetItalicAngle;                      N: 'FPDFFont_GetItalicAngle'),
    (P: @@FPDFFont_GetAscent;                           N: 'FPDFFont_GetAscent'),
    (P: @@FPDFFont_GetDescent;                          N: 'FPDFFont_GetDescent'),
    (P: @@FPDFFont_GetGlyphWidth;                       N: 'FPDFFont_GetGlyphWidth'),
    (P: @@FPDFFont_GetGlyphPath;                        N: 'FPDFFont_GetGlyphPath'),
    (P: @@FPDFGlyphPath_CountGlyphSegments;             N: 'FPDFGlyphPath_CountGlyphSegments'),
    (P: @@FPDFGlyphPath_GetGlyphPathSegment;            N: 'FPDFGlyphPath_GetGlyphPathSegment'),
    (P: @@FPDFFormObj_CountObjects;                     N: 'FPDFFormObj_CountObjects'),
    (P: @@FPDFFormObj_GetObject;                        N: 'FPDFFormObj_GetObject'),

    // *** _FPDF_PPO_H_ ***
    (P: @@FPDF_ImportPagesByIndex;                      N: 'FPDF_ImportPagesByIndex'),
    (P: @@FPDF_ImportPages;                             N: 'FPDF_ImportPages'),
    (P: @@FPDF_ImportNPagesToOne;                       N: 'FPDF_ImportNPagesToOne'),
    (P: @@FPDF_NewXObjectFromPage;                      N: 'FPDF_NewXObjectFromPage'),
    (P: @@FPDF_CloseXObject;                            N: 'FPDF_CloseXObject'),
    (P: @@FPDF_NewFormObjectFromXObject;                N: 'FPDF_NewFormObjectFromXObject'),
    (P: @@FPDF_CopyViewerPreferences;                   N: 'FPDF_CopyViewerPreferences'),

    // *** _FPDF_SAVE_H_ ***
    (P: @@FPDF_SaveAsCopy;                              N: 'FPDF_SaveAsCopy'),
    (P: @@FPDF_SaveWithVersion;                         N: 'FPDF_SaveWithVersion'),

    // *** _FPDFTEXT_H_ ***
    (P: @@FPDFText_LoadPage;                            N: 'FPDFText_LoadPage'),
    (P: @@FPDFText_ClosePage;                           N: 'FPDFText_ClosePage'),
    (P: @@FPDFText_CountChars;                          N: 'FPDFText_CountChars'),
    (P: @@FPDFText_GetUnicode;                          N: 'FPDFText_GetUnicode'),
    (P: @@FPDFText_IsGenerated;                         N: 'FPDFText_IsGenerated'),
    (P: @@FPDFText_IsHyphen;                            N: 'FPDFText_IsHyphen'),
    (P: @@FPDFText_HasUnicodeMapError;                  N: 'FPDFText_HasUnicodeMapError'),
    (P: @@FPDFText_GetFontSize;                         N: 'FPDFText_GetFontSize'),
    (P: @@FPDFText_GetFontInfo;                         N: 'FPDFText_GetFontInfo'),
    (P: @@FPDFText_GetFontWeight;                       N: 'FPDFText_GetFontWeight'),
    (P: @@FPDFText_GetTextRenderMode;                   N: 'FPDFText_GetTextRenderMode'),
    (P: @@FPDFText_GetFillColor;                        N: 'FPDFText_GetFillColor'),
    (P: @@FPDFText_GetStrokeColor;                      N: 'FPDFText_GetStrokeColor'),
    (P: @@FPDFText_GetCharAngle;                        N: 'FPDFText_GetCharAngle'),
    (P: @@FPDFText_GetCharBox;                          N: 'FPDFText_GetCharBox'),
    (P: @@FPDFText_GetLooseCharBox;                     N: 'FPDFText_GetLooseCharBox'),
    (P: @@FPDFText_GetMatrix;                           N: 'FPDFText_GetMatrix'),
    (P: @@FPDFText_GetCharOrigin;                       N: 'FPDFText_GetCharOrigin'),
    (P: @@FPDFText_GetCharIndexAtPos;                   N: 'FPDFText_GetCharIndexAtPos'),
    (P: @@FPDFText_GetText;                             N: 'FPDFText_GetText'),
    (P: @@FPDFText_CountRects;                          N: 'FPDFText_CountRects'),
    (P: @@FPDFText_GetRect;                             N: 'FPDFText_GetRect'),
    (P: @@FPDFText_GetBoundedText;                      N: 'FPDFText_GetBoundedText'),
    (P: @@FPDFText_FindStart;                           N: 'FPDFText_FindStart'),
    (P: @@FPDFText_FindNext;                            N: 'FPDFText_FindNext'),
    (P: @@FPDFText_FindPrev;                            N: 'FPDFText_FindPrev'),
    (P: @@FPDFText_GetSchResultIndex;                   N: 'FPDFText_GetSchResultIndex'),
    (P: @@FPDFText_GetSchCount;                         N: 'FPDFText_GetSchCount'),
    (P: @@FPDFText_FindClose;                           N: 'FPDFText_FindClose'),
    (P: @@FPDFLink_LoadWebLinks;                        N: 'FPDFLink_LoadWebLinks'),
    (P: @@FPDFLink_CountWebLinks;                       N: 'FPDFLink_CountWebLinks'),
    (P: @@FPDFLink_GetURL;                              N: 'FPDFLink_GetURL'),
    (P: @@FPDFLink_CountRects;                          N: 'FPDFLink_CountRects'),
    (P: @@FPDFLink_GetRect;                             N: 'FPDFLink_GetRect'),
    (P: @@FPDFLink_GetTextRange;                        N: 'FPDFLink_GetTextRange'),
    (P: @@FPDFLink_CloseWebLinks;                       N: 'FPDFLink_CloseWebLinks'),

    // *** _FPDF_SEARCHEX_H_ ***
    (P: @@FPDFText_GetCharIndexFromTextIndex;           N: 'FPDFText_GetCharIndexFromTextIndex'),
    (P: @@FPDFText_GetTextIndexFromCharIndex;           N: 'FPDFText_GetTextIndexFromCharIndex'),

    // *** _FPDF_PROGRESSIVE_H_ ***
    (P: @@FPDF_RenderPageBitmapWithColorScheme_Start;   N: 'FPDF_RenderPageBitmapWithColorScheme_Start'),
    (P: @@FPDF_RenderPageBitmap_Start;                  N: 'FPDF_RenderPageBitmap_Start'),
    (P: @@FPDF_RenderPage_Continue;                     N: 'FPDF_RenderPage_Continue'),
    (P: @@FPDF_RenderPage_Close;                        N: 'FPDF_RenderPage_Close'),

    // *** _FPDF_SIGNATURE_H_ ***
    (P: @@FPDF_GetSignatureCount;                       N: 'FPDF_GetSignatureCount'),
    (P: @@FPDF_GetSignatureObject;                      N: 'FPDF_GetSignatureObject'),
    (P: @@FPDFSignatureObj_GetContents;                 N: 'FPDFSignatureObj_GetContents'),
    (P: @@FPDFSignatureObj_GetByteRange;                N: 'FPDFSignatureObj_GetByteRange'),
    (P: @@FPDFSignatureObj_GetSubFilter;                N: 'FPDFSignatureObj_GetSubFilter'),
    (P: @@FPDFSignatureObj_GetReason;                   N: 'FPDFSignatureObj_GetReason'),
    (P: @@FPDFSignatureObj_GetTime;                     N: 'FPDFSignatureObj_GetTime'),
    (P: @@FPDFSignatureObj_GetDocMDPPermission;         N: 'FPDFSignatureObj_GetDocMDPPermission'),

    // *** _FPDF_FLATTEN_H_ ***
    (P: @@FPDFPage_Flatten;                             N: 'FPDFPage_Flatten'),

    // *** _FPDF_DOC_H_ ***
    (P: @@FPDFBookmark_GetFirstChild;                   N: 'FPDFBookmark_GetFirstChild'),
    (P: @@FPDFBookmark_GetNextSibling;                  N: 'FPDFBookmark_GetNextSibling'),
    (P: @@FPDFBookmark_GetTitle;                        N: 'FPDFBookmark_GetTitle'),
    (P: @@FPDFBookmark_GetCount;                        N: 'FPDFBookmark_GetCount'),
    (P: @@FPDFBookmark_Find;                            N: 'FPDFBookmark_Find'),
    (P: @@FPDFBookmark_GetDest;                         N: 'FPDFBookmark_GetDest'),
    (P: @@FPDFBookmark_GetAction;                       N: 'FPDFBookmark_GetAction'),
    (P: @@FPDFAction_GetDest;                           N: 'FPDFAction_GetDest'),
    (P: @@FPDFAction_GetType;                           N: 'FPDFAction_GetType'),
    (P: @@FPDFAction_GetFilePath;                       N: 'FPDFAction_GetFilePath'),
    (P: @@FPDFAction_GetURIPath;                        N: 'FPDFAction_GetURIPath'),
    (P: @@FPDFDest_GetDestPageIndex;                    N: 'FPDFDest_GetDestPageIndex'),
    (P: @@FPDFDest_GetView;                             N: 'FPDFDest_GetView'),
    (P: @@FPDFDest_GetLocationInPage;                   N: 'FPDFDest_GetLocationInPage'),
    (P: @@FPDFLink_GetLinkAtPoint;                      N: 'FPDFLink_GetLinkAtPoint'),
    (P: @@FPDFLink_GetLinkZOrderAtPoint;                N: 'FPDFLink_GetLinkZOrderAtPoint'),
    (P: @@FPDFLink_GetDest;                             N: 'FPDFLink_GetDest'),
    (P: @@FPDFLink_GetAction;                           N: 'FPDFLink_GetAction'),
    (P: @@FPDFLink_Enumerate;                           N: 'FPDFLink_Enumerate'),
    (P: @@FPDFLink_GetAnnot;                            N: 'FPDFLink_GetAnnot'),
    (P: @@FPDFLink_GetAnnotRect;                        N: 'FPDFLink_GetAnnotRect'),
    (P: @@FPDFLink_CountQuadPoints;                     N: 'FPDFLink_CountQuadPoints'),
    (P: @@FPDFLink_GetQuadPoints;                       N: 'FPDFLink_GetQuadPoints'),
    (P: @@FPDF_GetPageAAction;                          N: 'FPDF_GetPageAAction'),
    (P: @@FPDF_GetFileIdentifier;                       N: 'FPDF_GetFileIdentifier'),
    (P: @@FPDF_GetMetaText;                             N: 'FPDF_GetMetaText'),
    (P: @@FPDF_GetPageLabel;                            N: 'FPDF_GetPageLabel'),

    // *** _FPDF_SYSFONTINFO_H_ ***
    (P: @@FPDF_GetDefaultTTFMap;                        N: 'FPDF_GetDefaultTTFMap'),
    (P: @@FPDF_AddInstalledFont;                        N: 'FPDF_AddInstalledFont'),
    (P: @@FPDF_SetSystemFontInfo;                       N: 'FPDF_SetSystemFontInfo'),
    (P: @@FPDF_GetDefaultSystemFontInfo;                N: 'FPDF_GetDefaultSystemFontInfo'),
    (P: @@FPDFDoc_GetPageMode;                          N: 'FPDFDoc_GetPageMode'),

    // *** _FPDF_EXT_H_ ***
    (P: @@FSDK_SetUnSpObjProcessHandler;                N: 'FSDK_SetUnSpObjProcessHandler'),
    (P: @@FSDK_SetTimeFunction;                         N: 'FSDK_SetTimeFunction'),
    (P: @@FSDK_SetLocaltimeFunction;                    N: 'FSDK_SetLocaltimeFunction'),

    // *** _FPDF_DATAAVAIL_H_ ***
    (P: @@FPDFAvail_Create;                             N: 'FPDFAvail_Create'),
    (P: @@FPDFAvail_Destroy;                            N: 'FPDFAvail_Destroy'),
    (P: @@FPDFAvail_IsDocAvail;                         N: 'FPDFAvail_IsDocAvail'),
    (P: @@FPDFAvail_GetDocument;                        N: 'FPDFAvail_GetDocument'),
    (P: @@FPDFAvail_GetFirstPageNum;                    N: 'FPDFAvail_GetFirstPageNum'),
    (P: @@FPDFAvail_IsPageAvail;                        N: 'FPDFAvail_IsPageAvail'),
    (P: @@FPDFAvail_IsFormAvail;                        N: 'FPDFAvail_IsFormAvail'),
    (P: @@FPDFAvail_IsLinearized;                       N: 'FPDFAvail_IsLinearized'),

    // *** _FPD_FORMFILL_H ***
    (P: @@FPDFDOC_InitFormFillEnvironment;              N: 'FPDFDOC_InitFormFillEnvironment'),
    (P: @@FPDFDOC_ExitFormFillEnvironment;              N: 'FPDFDOC_ExitFormFillEnvironment'),
    (P: @@FORM_OnAfterLoadPage;                         N: 'FORM_OnAfterLoadPage'),
    (P: @@FORM_OnBeforeClosePage;                       N: 'FORM_OnBeforeClosePage'),
    (P: @@FORM_DoDocumentJSAction;                      N: 'FORM_DoDocumentJSAction'),
    (P: @@FORM_DoDocumentOpenAction;                    N: 'FORM_DoDocumentOpenAction'),
    (P: @@FORM_DoDocumentAAction;                       N: 'FORM_DoDocumentAAction'),
    (P: @@FORM_DoPageAAction;                           N: 'FORM_DoPageAAction'),
    (P: @@FORM_OnMouseMove;                             N: 'FORM_OnMouseMove'),
    (P: @@FORM_OnMouseWheel;                            N: 'FORM_OnMouseWheel'),
    (P: @@FORM_OnFocus;                                 N: 'FORM_OnFocus'),
    (P: @@FORM_OnLButtonDown;                           N: 'FORM_OnLButtonDown'),
    (P: @@FORM_OnRButtonDown;                           N: 'FORM_OnRButtonDown'),
    (P: @@FORM_OnLButtonUp;                             N: 'FORM_OnLButtonUp'),
    (P: @@FORM_OnRButtonUp;                             N: 'FORM_OnRButtonUp'),
    (P: @@FORM_OnLButtonDoubleClick;                    N: 'FORM_OnLButtonDoubleClick'),
    (P: @@FORM_OnKeyDown;                               N: 'FORM_OnKeyDown'),
    (P: @@FORM_OnKeyUp;                                 N: 'FORM_OnKeyUp'),
    (P: @@FORM_OnChar;                                  N: 'FORM_OnChar'),
    (P: @@FORM_GetFocusedText;                          N: 'FORM_GetFocusedText'),
    (P: @@FORM_GetSelectedText;                         N: 'FORM_GetSelectedText'),
    (P: @@FORM_ReplaceAndKeepSelection;                 N: 'FORM_ReplaceAndKeepSelection'),
    (P: @@FORM_ReplaceSelection;                        N: 'FORM_ReplaceSelection'),
    (P: @@FORM_SelectAllText;                           N: 'FORM_SelectAllText'),
    (P: @@FORM_CanUndo;                                 N: 'FORM_CanUndo'),
    (P: @@FORM_CanRedo;                                 N: 'FORM_CanRedo'),
    (P: @@FORM_Undo;                                    N: 'FORM_Undo'),
    (P: @@FORM_Redo;                                    N: 'FORM_Redo'),
    (P: @@FORM_ForceToKillFocus;                        N: 'FORM_ForceToKillFocus'),
    (P: @@FORM_GetFocusedAnnot;                         N: 'FORM_GetFocusedAnnot'),
    (P: @@FORM_SetFocusedAnnot;                         N: 'FORM_SetFocusedAnnot'),
    (P: @@FPDFPage_HasFormFieldAtPoint;                 N: 'FPDFPage_HasFormFieldAtPoint'),
    (P: @@FPDFPage_FormFieldZOrderAtPoint;              N: 'FPDFPage_FormFieldZOrderAtPoint'),
    (P: @@FPDF_SetFormFieldHighlightColor;              N: 'FPDF_SetFormFieldHighlightColor'),
    (P: @@FPDF_SetFormFieldHighlightAlpha;              N: 'FPDF_SetFormFieldHighlightAlpha'),
    (P: @@FPDF_RemoveFormFieldHighlight;                N: 'FPDF_RemoveFormFieldHighlight'),
    (P: @@FPDF_FFLDraw;                                 N: 'FPDF_FFLDraw'),
    {$IFDEF _SKIA_SUPPORT_}
    (P: @@FPDF_FFLDrawSkia;                             N: 'FPDF_FFLDrawSkia'; Quirk: True; Optional: True),
    {$ENDIF _SKIA_SUPPORT_}

    (P: @@FPDF_GetFormType;                             N: 'FPDF_GetFormType'),
    (P: @@FORM_SetIndexSelected;                        N: 'FORM_SetIndexSelected'),
    (P: @@FORM_IsIndexSelected;                         N: 'FORM_IsIndexSelected'),
    (P: @@FPDF_LoadXFA;                                 N: 'FPDF_LoadXFA'),

    // *** _FPDF_CATALOG_H_ ***
    (P: @@FPDFCatalog_IsTagged;                         N: 'FPDFCatalog_IsTagged'),

    // *** _FPDF_ATTACHMENT_H_ ***
    (P: @@FPDFDoc_GetAttachmentCount;                   N: 'FPDFDoc_GetAttachmentCount'),
    (P: @@FPDFDoc_AddAttachment;                        N: 'FPDFDoc_AddAttachment'),
    (P: @@FPDFDoc_GetAttachment;                        N: 'FPDFDoc_GetAttachment'),
    (P: @@FPDFDoc_DeleteAttachment;                     N: 'FPDFDoc_DeleteAttachment'),
    (P: @@FPDFAttachment_GetName;                       N: 'FPDFAttachment_GetName'),
    (P: @@FPDFAttachment_HasKey;                        N: 'FPDFAttachment_HasKey'),
    (P: @@FPDFAttachment_GetValueType;                  N: 'FPDFAttachment_GetValueType'),
    (P: @@FPDFAttachment_SetStringValue;                N: 'FPDFAttachment_SetStringValue'),
    (P: @@FPDFAttachment_GetStringValue;                N: 'FPDFAttachment_GetStringValue'),
    (P: @@FPDFAttachment_SetFile;                       N: 'FPDFAttachment_SetFile'),
    (P: @@FPDFAttachment_GetFile;                       N: 'FPDFAttachment_GetFile'),

    // *** _FPDF_TRANSFORMPAGE_H_ ***
    (P: @@FPDFPage_SetMediaBox;                         N: 'FPDFPage_SetMediaBox'),
    (P: @@FPDFPage_SetCropBox;                          N: 'FPDFPage_SetCropBox'),
    (P: @@FPDFPage_SetBleedBox;                         N: 'FPDFPage_SetBleedBox'),
    (P: @@FPDFPage_SetTrimBox;                          N: 'FPDFPage_SetTrimBox'),
    (P: @@FPDFPage_SetArtBox;                           N: 'FPDFPage_SetArtBox'),
    (P: @@FPDFPage_GetMediaBox;                         N: 'FPDFPage_GetMediaBox'),
    (P: @@FPDFPage_GetCropBox;                          N: 'FPDFPage_GetCropBox'),
    (P: @@FPDFPage_GetBleedBox;                         N: 'FPDFPage_GetBleedBox'),
    (P: @@FPDFPage_GetTrimBox;                          N: 'FPDFPage_GetTrimBox'),
    (P: @@FPDFPage_GetArtBox;                           N: 'FPDFPage_GetArtBox'),
    (P: @@FPDFPage_TransFormWithClip;                   N: 'FPDFPage_TransFormWithClip'),
    (P: @@FPDFPageObj_TransformClipPath;                N: 'FPDFPageObj_TransformClipPath'),
    (P: @@FPDFPageObj_GetClipPath;                      N: 'FPDFPageObj_GetClipPath'),
    (P: @@FPDFClipPath_CountPaths;                      N: 'FPDFClipPath_CountPaths'),
    (P: @@FPDFClipPath_CountPathSegments;               N: 'FPDFClipPath_CountPathSegments'),
    (P: @@FPDFClipPath_GetPathSegment;                  N: 'FPDFClipPath_GetPathSegment'),
    (P: @@FPDF_CreateClipPath;                          N: 'FPDF_CreateClipPath'),
    (P: @@FPDF_DestroyClipPath;                         N: 'FPDF_DestroyClipPath'),
    (P: @@FPDFPage_InsertClipPath;                      N: 'FPDFPage_InsertClipPath'),

    // *** _FPDF_STRUCTTREE_H_ ***
    (P: @@FPDF_StructTree_GetForPage;                   N: 'FPDF_StructTree_GetForPage'),
    (P: @@FPDF_StructTree_Close;                        N: 'FPDF_StructTree_Close'),
    (P: @@FPDF_StructTree_CountChildren;                N: 'FPDF_StructTree_CountChildren'),
    (P: @@FPDF_StructTree_GetChildAtIndex;              N: 'FPDF_StructTree_GetChildAtIndex'),
    (P: @@FPDF_StructElement_GetAltText;                N: 'FPDF_StructElement_GetAltText'),
    (P: @@FPDF_StructElement_GetActualText;             N: 'FPDF_StructElement_GetActualText'),
    (P: @@FPDF_StructElement_GetID;                     N: 'FPDF_StructElement_GetID'),
    (P: @@FPDF_StructElement_GetLang;                   N: 'FPDF_StructElement_GetLang'),
    (P: @@FPDF_StructElement_GetStringAttribute;        N: 'FPDF_StructElement_GetStringAttribute'),
    (P: @@FPDF_StructElement_GetMarkedContentID;        N: 'FPDF_StructElement_GetMarkedContentID'),
    (P: @@FPDF_StructElement_GetType;                   N: 'FPDF_StructElement_GetType'),
    (P: @@FPDF_StructElement_GetObjType;                N: 'FPDF_StructElement_GetObjType'),
    (P: @@FPDF_StructElement_GetTitle;                  N: 'FPDF_StructElement_GetTitle'),
    (P: @@FPDF_StructElement_CountChildren;             N: 'FPDF_StructElement_CountChildren'),
    (P: @@FPDF_StructElement_GetChildAtIndex;           N: 'FPDF_StructElement_GetChildAtIndex'),
    (P: @@FPDF_StructElement_GetParent;                 N: 'FPDF_StructElement_GetParent'),
    (P: @@FPDF_StructElement_GetAttributeCount;         N: 'FPDF_StructElement_GetAttributeCount'),
    (P: @@FPDF_StructElement_GetAttributeAtIndex;       N: 'FPDF_StructElement_GetAttributeAtIndex'),
    (P: @@FPDF_StructElement_Attr_GetCount;             N: 'FPDF_StructElement_Attr_GetCount'),
    (P: @@FPDF_StructElement_Attr_GetName;              N: 'FPDF_StructElement_Attr_GetName'),
    (P: @@FPDF_StructElement_Attr_GetType;              N: 'FPDF_StructElement_Attr_GetType'),
    (P: @@FPDF_StructElement_Attr_GetBooleanValue;      N: 'FPDF_StructElement_Attr_GetBooleanValue'),
    (P: @@FPDF_StructElement_Attr_GetNumberValue;       N: 'FPDF_StructElement_Attr_GetNumberValue'),
    (P: @@FPDF_StructElement_Attr_GetStringValue;       N: 'FPDF_StructElement_Attr_GetStringValue'),
    (P: @@FPDF_StructElement_Attr_GetBlobValue;         N: 'FPDF_StructElement_Attr_GetBlobValue'),
    (P: @@FPDF_StructElement_GetMarkedContentIdCount;   N: 'FPDF_StructElement_GetMarkedContentIdCount'),
    (P: @@FPDF_StructElement_GetMarkedContentIdAtIndex; N: 'FPDF_StructElement_GetMarkedContentIdAtIndex'),

    (P: @@FPDFAnnot_IsSupportedSubtype;                 N: 'FPDFAnnot_IsSupportedSubtype'),
    (P: @@FPDFPage_CreateAnnot;                         N: 'FPDFPage_CreateAnnot'),
    (P: @@FPDFPage_GetAnnotCount;                       N: 'FPDFPage_GetAnnotCount'),
    (P: @@FPDFPage_GetAnnot;                            N: 'FPDFPage_GetAnnot'),
    (P: @@FPDFPage_GetAnnotIndex;                       N: 'FPDFPage_GetAnnotIndex'),
    (P: @@FPDFPage_CloseAnnot;                          N: 'FPDFPage_CloseAnnot'),
    (P: @@FPDFPage_RemoveAnnot;                         N: 'FPDFPage_RemoveAnnot'),
    (P: @@FPDFAnnot_GetSubtype;                         N: 'FPDFAnnot_GetSubtype'),
    (P: @@FPDFAnnot_IsObjectSupportedSubtype;           N: 'FPDFAnnot_IsObjectSupportedSubtype'),
    (P: @@FPDFAnnot_UpdateObject;                       N: 'FPDFAnnot_UpdateObject'),
    (P: @@FPDFAnnot_AddInkStroke;                       N: 'FPDFAnnot_AddInkStroke'),
    (P: @@FPDFAnnot_RemoveInkList;                      N: 'FPDFAnnot_RemoveInkList'),
    (P: @@FPDFAnnot_AppendObject;                       N: 'FPDFAnnot_AppendObject'),
    (P: @@FPDFAnnot_GetObjectCount;                     N: 'FPDFAnnot_GetObjectCount'),
    (P: @@FPDFAnnot_GetObject;                          N: 'FPDFAnnot_GetObject'),
    (P: @@FPDFAnnot_RemoveObject;                       N: 'FPDFAnnot_RemoveObject'),
    (P: @@FPDFAnnot_SetColor;                           N: 'FPDFAnnot_SetColor'),
    (P: @@FPDFAnnot_GetColor;                           N: 'FPDFAnnot_GetColor'),
    (P: @@FPDFAnnot_HasAttachmentPoints;                N: 'FPDFAnnot_HasAttachmentPoints'),
    (P: @@FPDFAnnot_SetAttachmentPoints;                N: 'FPDFAnnot_SetAttachmentPoints'),
    (P: @@FPDFAnnot_AppendAttachmentPoints;             N: 'FPDFAnnot_AppendAttachmentPoints'),
    (P: @@FPDFAnnot_CountAttachmentPoints;              N: 'FPDFAnnot_CountAttachmentPoints'),
    (P: @@FPDFAnnot_GetAttachmentPoints;                N: 'FPDFAnnot_GetAttachmentPoints'),
    (P: @@FPDFAnnot_SetRect;                            N: 'FPDFAnnot_SetRect'),
    (P: @@FPDFAnnot_GetRect;                            N: 'FPDFAnnot_GetRect'),
    (P: @@FPDFAnnot_GetVertices;                        N: 'FPDFAnnot_GetVertices'),
    (P: @@FPDFAnnot_GetInkListCount;                    N: 'FPDFAnnot_GetInkListCount'),
    (P: @@FPDFAnnot_GetInkListPath;                     N: 'FPDFAnnot_GetInkListPath'),
    (P: @@FPDFAnnot_GetLine;                            N: 'FPDFAnnot_GetLine'),
    (P: @@FPDFAnnot_SetBorder;                          N: 'FPDFAnnot_SetBorder'),
    (P: @@FPDFAnnot_GetBorder;                          N: 'FPDFAnnot_GetBorder'),
    (P: @@FPDFAnnot_GetFormAdditionalActionJavaScript;  N: 'FPDFAnnot_GetFormAdditionalActionJavaScript'),
    (P: @@FPDFAnnot_HasKey;                             N: 'FPDFAnnot_HasKey'),
    (P: @@FPDFAnnot_GetValueType;                       N: 'FPDFAnnot_GetValueType'),
    (P: @@FPDFAnnot_SetStringValue;                     N: 'FPDFAnnot_SetStringValue'),
    (P: @@FPDFAnnot_GetStringValue;                     N: 'FPDFAnnot_GetStringValue'),
    (P: @@FPDFAnnot_GetNumberValue;                     N: 'FPDFAnnot_GetNumberValue'),
    (P: @@FPDFAnnot_SetAP;                              N: 'FPDFAnnot_SetAP'),
    (P: @@FPDFAnnot_GetAP;                              N: 'FPDFAnnot_GetAP'),
    (P: @@FPDFAnnot_GetLinkedAnnot;                     N: 'FPDFAnnot_GetLinkedAnnot'),
    (P: @@FPDFAnnot_GetFlags;                           N: 'FPDFAnnot_GetFlags'),
    (P: @@FPDFAnnot_SetFlags;                           N: 'FPDFAnnot_SetFlags'),
    (P: @@FPDFAnnot_GetFormFieldFlags;                  N: 'FPDFAnnot_GetFormFieldFlags'),
    (P: @@FPDFAnnot_GetFormFieldAtPoint;                N: 'FPDFAnnot_GetFormFieldAtPoint'),
    (P: @@FPDFAnnot_GetFormFieldName;                   N: 'FPDFAnnot_GetFormFieldName'),
    (P: @@FPDFAnnot_GetFormFieldAlternateName;          N: 'FPDFAnnot_GetFormFieldAlternateName'),
    (P: @@FPDFAnnot_GetFormFieldType;                   N: 'FPDFAnnot_GetFormFieldType'),
    (P: @@FPDFAnnot_GetFormFieldValue;                  N: 'FPDFAnnot_GetFormFieldValue'),
    (P: @@FPDFAnnot_GetOptionCount;                     N: 'FPDFAnnot_GetOptionCount'),
    (P: @@FPDFAnnot_GetOptionLabel;                     N: 'FPDFAnnot_GetOptionLabel'),
    (P: @@FPDFAnnot_IsOptionSelected;                   N: 'FPDFAnnot_IsOptionSelected'),
    (P: @@FPDFAnnot_GetFontSize;                        N: 'FPDFAnnot_GetFontSize'),
    (P: @@FPDFAnnot_IsChecked;                          N: 'FPDFAnnot_IsChecked'),

    (P: @@FPDFAnnot_SetFocusableSubtypes;               N: 'FPDFAnnot_SetFocusableSubtypes'),
    (P: @@FPDFAnnot_GetFocusableSubtypesCount;          N: 'FPDFAnnot_GetFocusableSubtypesCount'),
    (P: @@FPDFAnnot_GetFocusableSubtypes;               N: 'FPDFAnnot_GetFocusableSubtypes'),
    (P: @@FPDFAnnot_GetLink;                            N: 'FPDFAnnot_GetLink'),
    (P: @@FPDFAnnot_GetFormControlCount;                N: 'FPDFAnnot_GetFormControlCount'),
    (P: @@FPDFAnnot_GetFormControlIndex;                N: 'FPDFAnnot_GetFormControlIndex'),
    (P: @@FPDFAnnot_GetFormFieldExportValue;            N: 'FPDFAnnot_GetFormFieldExportValue'),
    (P: @@FPDFAnnot_SetURI;                             N: 'FPDFAnnot_SetURI'),

    {$IFDEF PDF_ENABLE_V8}
    // *** _FPDF_LIBS_H_ ***
    (P: @@FPDF_InitEmbeddedLibraries;                   N: 'FPDF_InitEmbeddedLibraries'; Optional: True),
    {$ENDIF PDF_ENABLE_V8}

    // *** _FPDF_JAVASCRIPT_H_ ***
    (P: @@FPDFDoc_GetJavaScriptActionCount;             N: 'FPDFDoc_GetJavaScriptActionCount'),
    (P: @@FPDFDoc_GetJavaScriptAction;                  N: 'FPDFDoc_GetJavaScriptAction'),
    (P: @@FPDFDoc_CloseJavaScriptAction;                N: 'FPDFDoc_CloseJavaScriptAction'),
    (P: @@FPDFJavaScriptAction_GetName;                 N: 'FPDFJavaScriptAction_GetName'),
    (P: @@FPDFJavaScriptAction_GetScript;               N: 'FPDFJavaScriptAction_GetScript'),

    // *** _FPDF_THUMBNAIL_H_ ***
    (P: @@FPDFPage_GetDecodedThumbnailData;             N: 'FPDFPage_GetDecodedThumbnailData'),
    (P: @@FPDFPage_GetRawThumbnailData;                 N: 'FPDFPage_GetRawThumbnailData'),
    (P: @@FPDFPage_GetThumbnailAsBitmap;                N: 'FPDFPage_GetThumbnailAsBitmap')
  );
  {$IFDEF FPC}
    {$WARN 3175 on : Some fields coming before "$1" were not initialized}
    {$WARN 3177 on : Some fields coming after "$1" were not initialized}
  {$ENDIF FPC}

const
  pdfium_dll = 'pdfium.dll';

var
  PdfiumModule: HMODULE;

procedure NotLoaded; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
begin
  raise Exception.CreateRes(@RsPdfiumNotLoaded);
end;

procedure FunctionNotSupported; {$IFDEF DLLEXPORT}stdcall{$ELSE}cdecl{$ENDIF};
begin
  raise Exception.CreateRes(@RsFunctionNotSupported);
end;

function PDF_USE_XFA: Boolean;
begin
  {$IFDEF PDF_ENABLE_XFA}
  Result := Assigned(FPDF_BStr_Init) and (@FPDF_BStr_Init <> @NotLoaded) and (@FPDF_BStr_Init <> @FunctionNotSupported);
  {$ELSE}
  Result := False;
  {$ENDIF PDF_ENABLE_XFA}
end;

function PDF_IsSkiaAvailable: Boolean;
begin
  {$IFDEF _SKIA_SUPPORT_}
  Result := Assigned(FPDF_RenderPageSkia) and (@FPDF_RenderPageSkia <> @NotLoaded) and (@FPDF_RenderPageSkia <> @FunctionNotSupported)
            and Assigned(FPDF_FFLDrawSkia) and (@FPDF_FFLDrawSkia <> @NotLoaded) and (@FPDF_FFLDrawSkia <> @FunctionNotSupported);
  {$ELSE}
  Result := False;
  {$ENDIF _SKIA_SUPPORT_}
end;

procedure Init;
var
  I: Integer;
begin
  for I := 0 to Length(ImportFuncs) - 1 do
    ImportFuncs[I].P^ := @NotLoaded;
end;

procedure InitPDFium(const DllPath: string{$IFDEF PDF_ENABLE_V8}; const ResPath: string{$ENDIF});
begin
  if DllPath <> '' then
    InitPDFiumEx(IncludeTrailingPathDelimiter(DllPath) + pdfium_dll{$IFDEF PDF_ENABLE_V8}, ResPath{$ENDIF})
  else
    InitPDFiumEx(''{$IFDEF PDF_ENABLE_V8}, ResPath{$ENDIF});
end;

procedure InitPDFiumEx(const DllFileName: string{$IFDEF PDF_ENABLE_V8}; const ResPath: string{$ENDIF});
var
  I: Integer;
  Path: string;
  LibraryConfig: FPDF_LIBRARY_CONFIG;
begin
  if PdfiumModule <> 0 then
    Exit;

  {$IFDEF CPUX64}
    {$IFDEF FPC}
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
    {$ELSE}
  // Pdfium requires all arithmetic exceptions to be masked in 64bit mode
  if GetExceptionMask <> exAllArithmeticExceptions then
    SetExceptionMask(exAllArithmeticExceptions);
    {$ENDIF FPC}
  {$ENDIF CPUX64}

  if DllFileName <> '' then
    PdfiumModule := SafeLoadLibrary(DllFileName)
  else
    PdfiumModule := SafeLoadLibrary(pdfium_dll);

  if PdfiumModule = 0 then
  begin
    {$IF not defined(FPC) and (CompilerVersion >= 24.0)} // XE3+
    if DllFileName <> '' then
      RaiseLastOSError(GetLastError, '.'#10#10 + DllFileName)
    else
      RaiseLastOSError(GetLastError, '.'#10#10 + pdfium_dll);
    {$ELSE}
    RaiseLastOSError;
    {$IFEND}
  end;

  // Import the pdfium.dll functions
  for I := 0 to Length(ImportFuncs) - 1 do
  begin
    if ImportFuncs[I].P^ = @NotLoaded then
    begin
      ImportFuncs[I].P^ := GetProcAddress(PdfiumModule, ImportFuncs[I].N);
      if ImportFuncs[I].P^ = nil then
      begin
        if ImportFuncs[I].Optional then
        begin
          if ImportFuncs[I].Quirk then
            ImportFuncs[I].P^ := @FunctionNotSupported;
        end
        else
        begin
          ImportFuncs[I].P^ := @NotLoaded;
          if not ImportFuncs[I].Quirk then
          begin
            FreeLibrary(PdfiumModule);
            PdfiumModule := 0;
            Init; // reset all functions to @NotLoaded
            raise Exception.CreateResFmt(@RsFailedToLoadProc, [ImportFuncs[I].N]);
          end;
        end;
      end;
    end;
  end;

  {$IFDEF PDF_ENABLE_V8}
  // Initialize the V8 engine if available
  if Assigned(FPDF_InitEmbeddedLibraries) then
  begin
    if ResPath <> '' then
      Path := IncludeTrailingPathDelimiter(ResPath)
    else if DllFileName <> '' then
    begin
      Path := ExtractFileDir(DllFileName);
      if Path <> '' then
        Path := IncludeTrailingPathDelimiter(Path);
    end;

    if Path = '' then
    begin
      // If the DLL was already loaded we can use its path
      Path := GetModuleName(PdfiumModule);
      if Path <> '' then
        Path := IncludeTrailingPathDelimiter(ExtractFilePath(Path));
    end;

    FPDF_InitEmbeddedLibraries(PAnsiChar(AnsiString(Path))); // requires trailing path delimiter
  end
  else
    @FPDF_InitEmbeddedLibraries := @FunctionNotSupported;
  {$ENDIF PDF_ENABLE_V8}

  // Initialize the pdfium library
  {$IFDEF FPC} {$WARN 5057 off : Local variable "$1" does not seem to be initialized} {$ENDIF FPC}
  FillChar(LibraryConfig, SizeOf(LibraryConfig), 0);
  {$IFDEF FPC} {$WARN 5057 on} {$ENDIF FPC}
  LibraryConfig.version := 4;
  LibraryConfig.m_RendererType := FPDF_RENDERERTYPE_AGG;
  {if IsSkiaAvailable and SkiaRendererEnabled then
    LibraryConfig.m_RendererType := FPDF_RENDERERTYPE_SKIA;}
  FPDF_InitLibraryWithConfig(@LibraryConfig);
end;

initialization
  Init;

finalization
  if PdfiumModule <> 0 then
  begin
    FPDF_DestroyLibrary;
    FreeLibrary(PdfiumModule);
  end;

end.

