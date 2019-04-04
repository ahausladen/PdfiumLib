{$A8,B-,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,T-,U-,V+,X+,Z1}
{$STRINGCHECKS OFF} // It only slows down Delphi strings, doesn't help C++Builder migration and is finally gone in XE+

// Use DLLs (x64, x86) from https://github.com/bblanchon/pdfium-binaries

unit PdfiumLib;

{$SCOPEDENUMS ON}

{.$DEFINE PDFIUM_PRINT_TEXT_WITH_GDI}
{.$DEFINE _SKIA_SUPPORT_}
{.$DEFINE PDF_ENABLE_XFA}
{.$DEFINE PDF_ENABLE_V8}

interface

{$IFDEF MSWINDOWS}
uses
  Windows;
{$ENDIF MSWINDOWS}

// *** _FPDFVIEW_H_ ***

{$IFDEF PDF_ENABLE_XFA}
  // PDF_USE_XFA is set in confirmation that this version of PDFium can support
  // XFA forms as requested by the PDF_ENABLE_XFA setting.
  {$DEFINE PDF_USE_XFA}
{$ENDIF PDF_ENABLE_XFA}

type
  {$IF not declared(SIZE_T)}
  SIZE_T = LongWord;
  {$IFEND}
  {$IF not declared(DWORD)}
  DWORD = UInt32;
  {$IFEND}
  TIME_T = Longint;
  PTIME_T = ^TIME_T;

  // Data types
  __FPDF_PTRREC = record end;
  __PFPDF_PTRREC = ^__FPDF_PTRREC;
  PFPDF_LINK = ^FPDF_LINK; // array
  PFPDF_PAGE = ^FPDF_PAGE; // array

  // PDF types - use incomplete types for type safety.
  FPDF_ACTION          = type __PFPDF_PTRREC;
  FPDF_ANNOTATION     = type __PFPDF_PTRREC;
  FPDF_ATTACHMENT     = type __PFPDF_PTRREC;
  FPDF_BITMAP         = type __PFPDF_PTRREC;
  FPDF_BOOKMARK       = type __PFPDF_PTRREC;
  FPDF_CLIPPATH       = type __PFPDF_PTRREC;
  FPDF_DEST           = type __PFPDF_PTRREC;
  FPDF_DOCUMENT       = type __PFPDF_PTRREC;
  FPDF_FONT           = type __PFPDF_PTRREC;
  FPDF_FORMHANDLE     = type __PFPDF_PTRREC;
  FPDF_LINK           = type __PFPDF_PTRREC;
  FPDF_PAGE           = type __PFPDF_PTRREC;
  FPDF_PAGELINK       = type __PFPDF_PTRREC;
  FPDF_PAGEOBJECT     = type __PFPDF_PTRREC;  // (text, path, etc.)
  FPDF_PAGEOBJECTMARK = type __PFPDF_PTRREC;
  FPDF_PAGERANGE      = type __PFPDF_PTRREC;
  FPDF_PATHSEGMENT    = type __PFPDF_PTRREC;
  FPDF_RECORDER       = type Pointer;  // Passed into skia.
  FPDF_SCHHANDLE      = type __PFPDF_PTRREC;
  FPDF_STRUCTELEMENT  = type __PFPDF_PTRREC;
  FPDF_STRUCTTREE     = type __PFPDF_PTRREC;
  FPDF_TEXTPAGE       = type __PFPDF_PTRREC;

{$IFDEF PDF_ENABLE_XFA}
  FPDF_WIDGET         = type __PFPDF_PTRREC;
{$ENDIF PDF_ENABLE_XFA}

  // Basic data types
  FPDF_BOOL  = Integer;
  FPDF_ERROR = Integer;
  FPDF_DWORD = LongWord;
  FS_FLOAT = Single;
  PFS_FLOAT = ^FS_FLOAT;

{$IFDEF PDF_ENABLE_XFA}
  FPDF_LPVOID = Pointer;
  FPDF_LPCVOID = Pointer;
  FPDF_LPCSTR = PAnsiChar;
  FPDF_RESULT = Integer;
{$ENDIF PDF_ENABLE_XFA}

  // Duplex types
  FPDF_DUPLEXTYPE = (
    DuplexUndefined = 0,
    Simplex,
    DuplexFlipShortEdge,
    DuplexFlipLongEdge
  );

  // String types
  FPDF_WCHAR = WideChar;
  FPDF_LPCBYTE = PAnsiChar;

  // FPDFSDK may use three types of strings: byte string, wide string (UTF-16LE
  // encoded), and platform dependent string
  FPDF_BYTESTRING = PAnsiChar;

  // FPDFSDK always uses UTF-16LE encoded wide strings, each character uses 2
  // bytes (except surrogation), with the low byte first.
  FPDF_WIDESTRING = PWideChar;

{$IFDEF PDF_ENABLE_XFA}
  // Structure for a byte string.
  // Note, a byte string commonly means a UTF-16LE formated string.
  PFPDF_BSTR = ^FPDF_BSTR;
  FPDF_BSTR = record
    // String buffer.
    str: PAnsiChar; // PByte
    // Length of the string, in bytes.
    len: Integer;
  end;
  PFPdfBStr = ^TFPdfBStr;
  TFPdfBStr = FPDF_BSTR;
{$ENDIF PDF_ENABLE_XFA}

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

type
  // Annotation enums.
  FPDF_ANNOTATION_SUBTYPE = Integer;
  FPDF_ANNOT_APPEARANCEMODE = Integer;

  // Dictionary value types.
  FPDF_OBJECT_TYPE = Integer;

// Function: FPDF_InitLibrary
//          Initialize the FPDFSDK library
// Parameters:
//          None
// Return value:
//          None.
// Comments:
//          Convenience function to call FPDF_InitLibraryWithConfig() for
//          backwards comatibility purposes.
var
  FPDF_InitLibrary: procedure(); stdcall;

type
  // Process-wide options for initializing the library.
  PFPDF_LIBRARY_CONFIG = ^FPDF_LIBRARY_CONFIG;
  FPDF_LIBRARY_CONFIG = record
    // Version number of the interface. Currently must be 2.
    version: Integer;

    // Array of paths to scan in place of the defaults when using built-in
    // FXGE font loading code. The array is terminated by a NULL pointer.
    // The Array may be NULL itself to use the default paths. May be ignored
    // entirely depending upon the platform.
    m_pUserFontPaths: PPAnsiChar;

    // Version 2.

    // pointer to the v8::Isolate to use, or NULL to force PDFium to create one.
    m_pIsolate: Pointer;

    // The embedder data slot to use in the v8::Isolate to store PDFium's
    // per-isolate data. The value needs to be between 0 and
    // v8::Internals::kNumIsolateDataLots (exclusive). Note that 0 is fine
    // for most embedders.
    m_v8EmbedderSlot: Cardinal;
  end;
  PFPdfLibraryConfig = ^TFPdfLibraryConfig;
  TFPdfLibraryConfig = FPDF_LIBRARY_CONFIG;

// Function: FPDF_InitLibraryWithConfig
//          Initialize the FPDFSDK library
// Parameters:
//          config - configuration information as above.
// Return value:
//          None.
// Comments:
//          You have to call this function before you can call any PDF
//          processing functions.
var
  FPDF_InitLibraryWithConfig: procedure(config: PFPDF_LIBRARY_CONFIG); stdcall;

// Function: FPDF_DestroyLibary
//          Release all resources allocated by the FPDFSDK library.
// Parameters:
//          None.
// Return value:
//          None.
// Comments:
//          You can call this function to release all memory blocks allocated by the library.
//          After this function is called, you should not call any PDF processing functions.
var
  FPDF_DestroyLibrary: procedure(); stdcall;

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
  FPDF_SetSandBoxPolicy: procedure(policy: FPDF_DWORD; enable: FPDF_BOOL); stdcall;

{$IFDEF MSWINDOWS}
  {$IFDEF PDFIUM_PRINT_TEXT_WITH_GDI}
// Pointer to a helper function to make |font| with |text| of |text_length|
// accessible when printing text with GDI. This is useful in sandboxed
// environments where PDFium's access to GDI may be restricted.
type
  TPDFiumEnsureTypefaceCharactersAccessible = procedure(font: PLogFont; text: PWideChar; text_length: SIZE_T); cdecl;

// Function: FPDF_SetTypefaceAccessibleFunc
//          Set the function pointer that makes GDI fonts available in sandboxed
//          environments. Experimental API.
// Parameters:
//          func -   A function pointer. See description above.
// Return value:
//          None.
var
  FPDF_SetTypefaceAccessibleFunc: procedure(func: TPDFiumEnsureTypefaceCharactersAccessible); stdcall;

// Function: FPDF_SetPrintTextWithGDI
//          Set whether to use GDI to draw fonts when printing on Windows.
//          Experimental API.
// Parameters:
//          use_gdi -   Set to true to enable printing text with GDI.
// Return value:
//          None.
var
  FPDF_SetPrintTextWithGDI: procedure(use_gdi: FPDF_BOOL); stdcall;
  {$ENDIF PDFIUM_PRINT_TEXT_WITH_GDI}

// Function: FPDF_SetPrintMode
//          Set printing mode when printing on Windows.
//          Experimental API.
// Parameters:
//          mode - FPDF_PRINTMODE_EMF to output EMF (default)
//                 FPDF_PRINTMODE_TEXTONLY to output text only (for charstream devices)
//                 FPDF_PRINTMODE_POSTSCRIPT2 to output level 2 PostScript into EMF as a series of GDI comments.
//                 FPDF_PRINTMODE_POSTSCRIPT3 to output level 3 PostScript into EMF as a series of GDI comments.
//                 FPDF_PRINTMODE_POSTSCRIPT2_PASSTHROUGH to output level 2 PostScript via ExtEscape() in PASSTHROUGH mode.
//                 FPDF_PRINTMODE_POSTSCRIPT3_PASSTHROUGH to output level 3 PostScript via ExtEscape() in PASSTHROUGH mode.
// Return value:
//          True if successful, false if unsuccessful (typically invalid input).
var
  FPDF_SetPrintMode: function(mode: Integer): FPDF_BOOL; stdcall;
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
//          The encoding for |password| can be either UTF-8 or Latin-1. PDFs,
//          depending on the security handler revision, will only accept one or
//          the other encoding. If |password|'s encoding and the PDF's expected
//          encoding do not match, FPDF_LoadDocument() will automatically
//          convert |password| to the other encoding.
var
  FPDF_LoadDocument: function(file_path: FPDF_STRING; password: FPDF_BYTESTRING): FPDF_DOCUMENT; stdcall;

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
  FPDF_LoadMemDocument: function(data_buf: Pointer; size: Integer; password: FPDF_BYTESTRING): FPDF_DOCUMENT; stdcall;

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
    // It may be possible for FPDFSDK to call this function multiple times for
    // the same position.
    // Return value: should be non-zero if successful, zero for error.
    m_GetBlock: function(param: Pointer; position: LongWord; pBuf: PByte; size: LongWord): Integer; cdecl;

    // A custom pointer for all implementation specific data.  This pointer will
    // be used as the first parameter to the m_GetBlock callback.
    m_Param: Pointer;
  end;
  PFPdfFileAccess = ^TFPdfFileAccess;
  TFPdfFileAccess = FPDF_FILEACCESS;

{$IFDEF PDF_ENABLE_XFA}
  //**
  //* @brief Structure for file reading or writing (I/O).
  //*
  //* @note This is a handler and should be implemented by callers.
  //*
  PFPDF_FILEHANDLER = ^FPDF_FILEHANDLER;
  FPDF_FILEHANDLER = record
    //**
    //* @brief User-defined data.
    //* @note Callers can use this field to track controls.
    //*
    clientData: FPDF_LPVOID;
    //**
    //* @brief Callback function to release the current file stream object.
    //*
    //* @param[in] clientData    Pointer to user-defined data.
    //*
    //* @return None.
    //*
    Release: procedure(clientData: FPDF_LPVOID); cdecl;
    //**
    //* @brief Callback function to retrieve the current file stream size.
    //*
    //* @param[in] clientData    Pointer to user-defined data.
    //*
    //* @return Size of file stream.
    //*
    GetSize: function(clientData: FPDF_LPVOID): FPDF_DWORD; cdecl;
    //**
    //* @brief Callback function to read data from the current file stream.
    //*
    //* @param[in]   clientData  Pointer to user-defined data.
    //* @param[in]   offset      Offset position starts from the beginning of file
    //*                          stream. This parameter indicates reading position.
    //* @param[in]   buffer      Memory buffer to store data which are read from
    //*                          file stream. This parameter should not be <b>NULL</b>.
    //* @param[in]   size        Size of data which should be read from file
    //*                          stream, in bytes. The buffer indicated by the parameter <i>buffer</i>
    //*                          should be enough to store specified data.
    //*
    //* @return 0 for success, other value for failure.
    //*
    ReadBlock: function(clientData: FPDF_LPVOID; offset: FPDF_DWORD; buffer: FPDF_LPVOID; size: FPDF_DWORD): FPDF_RESULT; cdecl;
    //**
    //* @brief   Callback function to write data into the current file stream.
    //*
    //* @param[in]   clientData  Pointer to user-defined data.
    //* @param[in]   offset      Offset position starts from the beginning of file
    //*                          stream. This parameter indicates writing position.
    //* @param[in]   buffer      Memory buffer contains data which is written into
    //*                          file stream. This parameter should not be <b>NULL</b>.
    //* @param[in]   size        Size of data which should be written into file
    //*                          stream, in bytes.
    //*
    //* @return 0 for success, other value for failure.
    //*
    WriteBlock: function(clientData: FPDF_LPVOID; offset: FPDF_DWORD; buffer: FPDF_LPCVOID; size: FPDF_DWORD): FPDF_RESULT; cdecl;
    //**
    //* @brief   Callback function to flush all internal accessing buffers.
    //*
    //* @param[in]   clientData  Pointer to user-defined data.
    //*
    //* @return 0 for success, other value for failure.
    //*
    Flush: function(clientData: FPDF_LPVOID): FPDF_RESULT; cdecl;
    //**
    //* @brief   Callback function to change file size.
    //*
    //* @details This function is called under writing mode usually. Implementer
    //* can determine whether to realize it based on application requests.
    //*
    //* @param[in]   clientData  Pointer to user-defined data.
    //* @param[in]   size        New size of file stream, in bytes.
    //*
    //* @return 0 for success, other value for failure.
    //*
    Truncate: function(clientData: FPDF_LPVOID; size: FPDF_DWORD): FPDF_RESULT; cdecl;
  end;
  FPDF_LPFILEHANDLER = PFPDF_FILEHANDLER;
  PFPdfFileHandler = ^TFPdfFileHandler;
  TFPdfFileHandler = FPDF_FILEHANDLER;

{$ENDIF PDF_ENABLE_XFA}

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
  FPDF_LoadCustomDocument: function(pFileAccess: PFPDF_FILEACCESS; password: FPDF_BYTESTRING): FPDF_DOCUMENT; stdcall;

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
  FPDF_GetFileVersion: function(doc: FPDF_DOCUMENT; var fileVersion: Integer): FPDF_BOOL; stdcall;

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
//          function is not defined.
var
  FPDF_GetLastError: function(): LongWord; stdcall;

// Function: FPDF_DocumentHasValidCrossReferenceTable
//          Whether the document's cross reference table is valid or not.
//          Experimental API.
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
  FPDF_DocumentHasValidCrossReferenceTable: function(document: FPDF_DOCUMENT): FPDF_BOOL; stdcall;

// Function: FPDF_GetDocPermission
//          Get file permission flags of the document.
// Parameters:
//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
// Return value:
//          A 32-bit integer indicating permission flags. Please refer to the
//          PDF Reference for detailed descriptions. If the document is not
//          protected, 0xffffffff will be returned.
var
  FPDF_GetDocPermissions: function(document: FPDF_DOCUMENT): LongWord; stdcall;


// Function: FPDF_GetSecurityHandlerRevision
//          Get the revision for the security handler.
// Parameters:
//          document    -   Handle to a document. Returned by FPDF_LoadDocument.
// Return value:
//          The security handler revision number. Please refer to the PDF
//          Reference for a detailed description. If the document is not
//          protected, -1 will be returned.
var
  FPDF_GetSecurityHandlerRevision: function(document: FPDF_DOCUMENT): Integer; stdcall;

// Function: FPDF_GetPageCount
//          Get total number of pages in the document.
// Parameters:
//          document    -   Handle to document. Returned by FPDF_LoadDocument.
// Return value:
//          Total number of pages in the document.
var
  FPDF_GetPageCount: function(document: FPDF_DOCUMENT): Integer; stdcall;

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
  FPDF_LoadPage: function(document: FPDF_DOCUMENT; page_index: Integer): FPDF_PAGE; stdcall;

// Function: FPDF_GetPageWidth
//          Get page width.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
// Return value:
//          Page width (excluding non-displayable area) measured in points.
//          One point is 1/72 inch (around 0.3528 mm).
var
  FPDF_GetPageWidth: function(page: FPDF_PAGE): Double; stdcall;

// Function: FPDF_GetPageHeight
//          Get page height.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage.
// Return value:
//          Page height (excluding non-displayable area) measured in points.
//          One point is 1/72 inch (around 0.3528 mm)
var
  FPDF_GetPageHeight: function(page: FPDF_PAGE): Double; stdcall;

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
  FPDF_GetPageBoundingBox: function(page: FPDF_PAGE; rect: PFS_RECTF): FPDF_BOOL; stdcall;

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
var
  FPDF_GetPageSizeByIndex: function(document: FPDF_DOCUMENT; page_index: Integer; var width, height: Double): Integer; stdcall;

// Page rendering flags. They can be combined with bit-wise OR.
const
  FPDF_ANNOT                    = $01;   // Set if annotations are to be rendered.
  FPDF_LCD_TEXT                 = $02;   // Set if using text rendering optimized for LCD display.
  FPDF_NO_NATIVETEXT            = $04;   // Don't use the native text output available on some platforms
  FPDF_GRAYSCALE                = $08;   // Grayscale output.
  FPDF_DEBUG_INFO               = $80;   // Set if you want to get some debug info.
  FPDF_NO_CATCH                 = $100;  // Set if you don't want to catch exceptions.
  FPDF_RENDER_LIMITEDIMAGECACHE = $200;  // Limit image cache size.
  FPDF_RENDER_FORCEHALFTONE     = $400;  // Always use halftone for image stretching.
  FPDF_PRINTING                 = $800;  // Render for printing.
  FPDF_RENDER_NO_SMOOTHTEXT     = $1000; // Set to disable anti-aliasing on text.
  FPDF_RENDER_NO_SMOOTHIMAGE    = $2000; // Set to disable anti-aliasing on images.
  FPDF_RENDER_NO_SMOOTHPATH     = $4000; // Set to disable anti-aliasing on paths.
  // Set whether to render in a reverse Byte order, this flag is only used when
  // rendering to a bitmap.
  FPDF_REVERSE_BYTE_ORDER       = $10;

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
    rotate: Integer; flags: Integer); stdcall;
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
    rotate: Integer; flags: Integer); stdcall;

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
    clipping: PFS_RECTF; flags: Integer); stdcall;

{$IFDEF _SKIA_SUPPORT_}
var
  FPDF_RenderPageSkp: function(page: FPDF_PAGE; size_x, size_y: Integer): FPDF_RECORDER; stdcall;
{$ENDIF _SKIA_SUPPORT_}

// Function: FPDF_ClosePage
//          Close a loaded PDF page.
// Parameters:
//          page        -   Handle to the loaded page.
// Return value:
//          None.
var
  FPDF_ClosePage: procedure(page: FPDF_PAGE); stdcall;

// Function: FPDF_CloseDocument
//          Close a loaded PDF document.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          None.
var
  FPDF_CloseDocument: procedure(document: FPDF_DOCUMENT); stdcall;

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
    rotate: Integer; device_x, device_y: Integer; var page_x, page_y: Double); stdcall;

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
    rotate: Integer; page_x, page_y: Double; var device_x, device_y: Integer); stdcall;

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
//          FPDFBitmap_FillRect to fill the bitmap using any color.var
  FPDFBitmap_Create: function(width, height: Integer; alpha: Integer): FPDF_BITMAP; stdcall;


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
//          stride      -   Number of bytes for each scan line, for external
//                          buffer only.
// Return value:
//          The bitmap handle, or NULL if parameter error or out of memory.
// Comments:
//          Similar to FPDFBitmap_Create function, but allows for more formats
//          and an external buffer is supported. The bitmap created by this
//          function can be used in any place that a FPDF_BITMAP handle is
//          required.
//
//          If an external buffer is used, then the application should destroy
//          the buffer by itself. FPDFBitmap_Destroy function will not destroy
//          the buffer.
var
  FPDFBitmap_CreateEx: function(width, height: Integer; format: Integer; first_scan: Pointer;
    stride: Integer): FPDF_BITMAP; stdcall;

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
  FPDFBitmap_GetFormat: function(bitmap: FPDF_BITMAP): Integer; stdcall;

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
  FPDFBitmap_FillRect: procedure(bitmap: FPDF_BITMAP; left, top, width, height: Integer; color: FPDF_DWORD); stdcall;

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
//          The data is in BGRA format. Where the A maybe unused if alpha was
//          not specified.
var
  FPDFBitmap_GetBuffer: function(bitmap: FPDF_BITMAP): Pointer; stdcall;

// Function: FPDFBitmap_GetWidth
//          Get width of a bitmap.
// Parameters:
//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
//                          or FPDFImageObj_GetBitmap.
// Return value:
//          The width of the bitmap in pixels.
var
  FPDFBitmap_GetWidth: function(bitmap: FPDF_BITMAP): Integer; stdcall;

// Function: FPDFBitmap_GetHeight
//          Get height of a bitmap.
// Parameters:
//          bitmap      -   Handle to the bitmap. Returned by FPDFBitmap_Create
//                          or FPDFImageObj_GetBitmap.
// Return value:
//          The height of the bitmap in pixels.
var
  FPDFBitmap_GetHeight: function(bitmap: FPDF_BITMAP): Integer; stdcall;

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
  FPDFBitmap_GetStride: function(bitmap: FPDF_BITMAP): Integer; stdcall;

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
  FPDFBitmap_Destroy: procedure(bitmap: FPDF_BITMAP); stdcall;

// Function: FPDF_VIEWERREF_GetPrintScaling
//          Whether the PDF document prefers to be scaled or not.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          None.
var
  FPDF_VIEWERREF_GetPrintScaling: function(document: FPDF_DOCUMENT): FPDF_BOOL; stdcall;

// Function: FPDF_VIEWERREF_GetNumCopies
//          Returns the number of copies to be printed.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          The number of copies to be printed.
var
  FPDF_VIEWERREF_GetNumCopies: function(document: FPDF_DOCUMENT): Integer; stdcall;

// Function: FPDF_VIEWERREF_GetPrintPageRange
//          Page numbers to initialize print dialog box when file is printed.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          The print page range to be used for printing.
var
  FPDF_VIEWERREF_GetPrintPageRange: function(document: FPDF_DOCUMENT): FPDF_PAGERANGE; stdcall;

// Function: FPDF_VIEWERREF_GetPrintPageRangeCount
//          Returns the number of elements in a FPDF_PAGERANGE.
//          Experimental API.
// Parameters:
//          pagerange   -   Handle to the page range.
// Return value:
//          The number of elements in the page range. Returns 0 on error.
var
  FPDF_VIEWERREF_GetPrintPageRangeCount: function(pagerange: FPDF_PAGERANGE): SIZE_T; stdcall;

// Function: FPDF_VIEWERREF_GetPrintPageRangeElement
//          Returns an element from a FPDF_PAGERANGE.
//          Experimental API.
// Parameters:
//          pagerange   -   Handle to the page range.
//          index       -   Index of the element.
// Return value:
//          The value of the element in the page range at a given index.
//          Returns -1 on error.
var
  FPDF_VIEWERREF_GetPrintPageRangeElement: function(pagerange: FPDF_PAGERANGE; index: SIZE_T): Integer; stdcall;

// Function: FPDF_VIEWERREF_GetDuplex
//          Returns the paper handling option to be used when printing from
//          the print dialog.
// Parameters:
//          document    -   Handle to the loaded document.
// Return value:
//          The paper handling option to be used when printing.
var
  FPDF_VIEWERREF_GetDuplex: function(document: FPDF_DOCUMENT): FPDF_DUPLEXTYPE; stdcall;

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
    length: LongWord): LongWord; stdcall;

// Function: FPDF_CountNamedDests
//          Get the count of named destinations in the PDF document.
// Parameters:
//          document    -   Handle to a document
// Return value:
//          The count of named destinations.
var
  FPDF_CountNamedDests: function(document: FPDF_DOCUMENT): FPDF_DWORD; stdcall;

// Function: FPDF_GetNamedDestByName
//          Get a the destination handle for the given name.
// Parameters:
//          document    -   Handle to the loaded document.
//          name        -   The name of a destination.
// Return value:
//          The handle to the destination.
var
  FPDF_GetNamedDestByName: function(document: FPDF_DOCUMENT; name: FPDF_BYTESTRING): FPDF_DEST; stdcall;

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
  FPDF_GetNamedDest: function(document: FPDF_DOCUMENT; index: Integer; buffer: Pointer; var buflen: LongWord): FPDF_DEST; stdcall;

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
  FPDF_GetRecommendedV8Flags: function: PAnsiChar; stdcall;
{$ENDIF PDF_ENABLE_V8}

{$IFDEF PDF_ENABLE_XFA}
// Function: FPDF_BStr_Init
//          Helper function to initialize a byte string.
var
  FPDF_BStr_Init: function(str: PFPDF_BSTR): FPDF_RESULT; stdcall;

// Function: FPDF_BStr_Set
//          Helper function to set string data.
var
  FPDF_BStr_Set: function(str: PFPDF_BSTR; bstr: FPDF_LPCSTR; length: Integer): FPDF_RESULT; stdcall;

// Function: FPDF_BStr_Clear
//          Helper function to clear a byte string.
var
  FPDF_BStr_Clear: function(str: PFPDF_BSTR): FPDF_RESULT; stdcall;
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

  FPDF_PRINTMODE_EMF = 0;
  FPDF_PRINTMODE_TEXTONLY = 1;
  FPDF_PRINTMODE_POSTSCRIPT2 = 2;
  FPDF_PRINTMODE_POSTSCRIPT3 = 3;
  FPDF_PRINTMODE_POSTSCRIPT2_PASSTHROUGH = 4;
  FPDF_PRINTMODE_POSTSCRIPT3_PASSTHROUGH = 5;

  FPDF_TEXTRENDERMODE_FILL = 0;
  FPDF_TEXTRENDERMODE_STROKE = 1;
  FPDF_TEXTRENDERMODE_FILL_STROKE = 2;
  FPDF_TEXTRENDERMODE_INVISIBLE = 3;
  FPDF_TEXTRENDERMODE_FILL_CLIP = 4;
  FPDF_TEXTRENDERMODE_STROKE_CLIP = 5;
  FPDF_TEXTRENDERMODE_FILL_STROKE_CLIP = 6;
  FPDF_TEXTRENDERMODE_CLIP = 7;

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
  FPDF_CreateNewDocument: function: FPDF_DOCUMENT; stdcall;

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
  FPDFPage_New: function(document: FPDF_DOCUMENT; page_index: Integer; width, height: Double): FPDF_PAGE; stdcall;

// Delete the page at |page_index|.
//
//   document   - handle to document.
//   page_index - the index of the page to delete.
var
  FPDFPage_Delete: procedure(document: FPDF_DOCUMENT; page_index: Integer); stdcall;

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
  FPDFPage_GetRotation: function(page: FPDF_PAGE): Integer; stdcall;

// Set rotation for |page|.
//
//   page   - handle to a page.
//   rotate - the rotation value, one of:
//              0 - No rotation.
//              1 - Rotated 90 degrees clockwise.
//              2 - Rotated 180 degrees clockwise.
//              3 - Rotated 270 degrees clockwise.
var
  FPDFPage_SetRotation: procedure(page: FPDF_PAGE; rotate: Integer); stdcall;

// Insert |page_obj| into |page|.
//
//   page     - handle to a page
//   page_obj - handle to a page object. The |page_obj| will be automatically
//              freed.
var
  FPDFPage_InsertObject: procedure(page: FPDF_PAGE; page_obj: FPDF_PAGEOBJECT); stdcall;

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
  FPDFPage_RemoveObject: function(page: FPDF_PAGE; page_obj: FPDF_PAGEOBJECT): FPDF_BOOL; stdcall;

// Get number of page objects inside |page|.
//
//   page - handle to a page.
//
// Returns the number of objects in |page|.
var
  FPDFPage_CountObjects: function(page: FPDF_PAGE): Integer; stdcall;

// Get object in |page| at |index|.
//
//   page  - handle to a page.
//   index - the index of a page object.
//
// Returns the handle to the page object, or NULL on failed.
var
  FPDFPage_GetObject: function(page: FPDF_PAGE; index: Integer): FPDF_PAGEOBJECT; stdcall;

// Checks if |page| contains transparency.
//
//   page - handle to a page.
//
// Returns TRUE if |page| contains transparency.
var
  FPDFPage_HasTransparency: function(page: FPDF_PAGE): FPDF_BOOL; stdcall;

// Generate the content of |page|.
//
//   page - handle to a page.
//
// Returns TRUE on success.
//
// Before you save the page to a file, or reload the page, you must call
// |FPDFPage_GenerateContent| or any changes to |page| will be lost.
var
  FPDFPage_GenerateContent: function(page: FPDF_PAGE): FPDF_BOOL; stdcall;

// Destroy |page_obj| by releasing its resources. |page_obj| must have been
// created by FPDFPageObj_CreateNew{Path|Rect}() or
// FPDFPageObj_New{Text|Image}Obj(). This function must be called on
// newly-created objects if they are not added to a page through
// FPDFPage_InsertObject() or to an annotation through FPDFAnnot_AppendObject().
//
//   page_obj - handle to a page object.
var
  FPDFPageObj_Destroy: procedure(page_obj: FPDF_PAGEOBJECT); stdcall;

// Checks if |page_object| contains transparency.
//
//   page_object - handle to a page object.
//
// Returns TRUE if |pageObject| contains transparency.
var
  FPDFPageObj_HasTransparency: function(page_object: FPDF_PAGEOBJECT): FPDF_BOOL; stdcall;

// Get type of |page_object|.
//
//   page_object - handle to a page object.
//
// Returns one of the FPDF_PAGEOBJ_* values on success, FPDF_PAGEOBJ_UNKNOWN on
// error.
var
  FPDFPageObj_GetType: function(page_object: FPDF_PAGEOBJECT): Integer; stdcall;

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
  FPDFPageObj_Transform: procedure(page_object: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double); stdcall;

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
  FPDFPage_TransformAnnots: procedure(page: FPDF_PAGE; a, b, c, d, e, f: Double); stdcall;

// Create a new image object.
//
//   document - handle to a document.
//
// Returns a handle to a new image object.
var
  FPDFPageObj_NewImageObj: function(document: FPDF_DOCUMENT): FPDF_PAGEOBJECT; stdcall;

// Experimental API.
// Get number of content marks in |page_object|.
//
//   page_object - handle to a page object.
//
// Returns the number of content marks in |page_object|, or -1 in case of
// failure.
var
  FPDFPageObj_CountMarks: function(page_object: FPDF_PAGEOBJECT): Integer; stdcall;

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
  FPDFPageObj_GetMark: function(page_object: FPDF_PAGEOBJECT; index: LongWord): FPDF_PAGEOBJECTMARK; stdcall;

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
  FPDFPageObj_AddMark: function(page_object: FPDF_PAGEOBJECT; name: FPDF_BYTESTRING): FPDF_PAGEOBJECTMARK; stdcall;

// Experimental API.
// Removes a content |mark| from a |page_object|.
// The mark handle will be invalid after the removal.
//
//   page_object - handle to a page object.
//   mark        - handle to a content mark in that object to remove.
//
// Returns TRUE if the operation succeeded, FALSE if it failed.
var
  FPDFPageObj_RemoveMark: function(page_object: FPDF_PAGEOBJECT; mark: FPDF_PAGEOBJECTMARK): FPDF_BOOL; stdcall;

// Experimental API.
// Get the name of a content mark.
//
//   mark       - handle to a content mark.
//   buffer     - buffer for holding the returned name in UTF16-LE. This is only
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
    out_buflen: PLongWord): FPDF_BOOL; stdcall;

// Experimental API.
// Get the number of key/value pair parameters in |mark|.
//
//   mark   - handle to a content mark.
//
// Returns the number of key/value pair parameters |mark|, or -1 in case of
// failure.
var
  FPDFPageObjMark_CountParams: function(mark: FPDF_PAGEOBJECTMARK): Integer; stdcall;

// Experimental API.
// Get the key of a property in a content mark.
//
//   mark       - handle to a content mark.
//   index      - index of the property.
//   buffer     - buffer for holding the returned key in UTF16-LE. This is only
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
    out_buflen: PLongWord): FPDF_BOOL; stdcall;

// Experimental API.
// Get the type of the value of a property in a content mark by key.
//
//   mark   - handle to a content mark.
//   key    - string key of the property.
//
// Returns the type of the value, or FPDF_OBJECT_UNKNOWN in case of failure.
var
  FPDFPageObjMark_GetParamValueType: function(mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING): FPDF_OBJECT_TYPE; stdcall;


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
    out_value: PInteger): FPDF_BOOL; stdcall;

// Experimental API.
// Get the value of a string property in a content mark by key.
//
//   mark       - handle to a content mark.
//   key        - string key of the property.
//   buffer     - buffer for holding the returned value in UTF16-LE. This is
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
    buflen: LongWord; out_buflen: PLongWord): FPDF_BOOL; stdcall;

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
    buflen: LongWord; out_buflen: PLongWord): FPDF_BOOL; stdcall;

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
    mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING; value: Integer): FPDF_BOOL; stdcall;

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
    mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING; value: FPDF_BYTESTRING): FPDF_BOOL; stdcall;

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
    mark: FPDF_PAGEOBJECTMARK; key: FPDF_BYTESTRING; value: Pointer; value_len: LongWord): FPDF_BOOL; stdcall;

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
    key: FPDF_BYTESTRING): FPDF_BOOL; stdcall;

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
    fileAccess: PFPDF_FILEACCESS): FPDF_BOOL; stdcall;

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
    file_access: PFPDF_FILEACCESS): FPDF_BOOL; stdcall;

// Experimental API.
// Get the transform matrix of an image object.
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
// and used to scale, rotate, shear and translate the image.
//
// Returns TRUE on success.
var
  FPDFImageObj_GetMatrix: function(path: FPDF_PAGEOBJECT; var a, b, c, d, e, f: Double): FPDF_BOOL; stdcall;

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
  FPDFImageObj_SetMatrix: function(image_object: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double): FPDF_BOOL; stdcall;

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
    bitmap: FPDF_BITMAP): FPDF_BOOL; stdcall;

// Get a bitmap rasterisation of |image_object|. The returned bitmap will be
// owned by the caller, and FPDFBitmap_Destroy() must be called on the returned
// bitmap when it is no longer needed.
//
//   image_object - handle to an image object.
//
// Returns the bitmap.
var
  FPDFImageObj_GetBitmap: function(image_object: FPDF_PAGEOBJECT): FPDF_BITMAP; stdcall;

// Get the decoded image data of |image_object|. The decoded data is the
// uncompressed image data, i.e. the raw image data after having all filters
// applied. |buffer| is only modified if |buflen| is longer than the length of
// the decoded image data.
//
//   image_object - handle to an image object.
//   buffer       - buffer for holding the decoded image data in raw bytes.
//   buflen       - length of the buffer.
//
// Returns the length of the decoded image data.
var
  FPDFImageObj_GetImageDataDecoded: function(image_object: FPDF_PAGEOBJECT; buffer: Pointer;
    buflen: LongWord): LongWord; stdcall;

// Get the raw image data of |image_object|. The raw data is the image data as
// stored in the PDF without applying any filters. |buffer| is only modified if
// |buflen| is longer than the length of the raw image data.
//
//   image_object - handle to an image object.
//   buffer       - buffer for holding the raw image data in raw bytes.
//   buflen       - length of the buffer.
//
// Returns the length of the raw image data.
var
  FPDFImageObj_GetImageDataRaw: function(image_object: FPDF_PAGEOBJECT; buffer: Pointer;
    buflen: LongWord): LongWord; stdcall;

// Get the number of filters (i.e. decoders) of the image in |image_object|.
//
//   image_object - handle to an image object.
//
// Returns the number of |image_object|'s filters.
var
  FPDFImageObj_GetImageFilterCount: function(image_object: FPDF_PAGEOBJECT): Integer; stdcall;

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
    buflen: LongWord): LongWord; stdcall;

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
    metadata: PFPDF_IMAGEOBJ_METADATA): FPDF_BOOL; stdcall;

// Create a new path object at an initial position.
//
//   x - initial horizontal position.
//   y - initial vertical position.
//
// Returns a handle to a new path object.
var
  FPDFPageObj_CreateNewPath: function(x, y: Single): FPDF_PAGEOBJECT; stdcall;

// Create a closed path consisting of a rectangle.
//
//   x - horizontal position for the left boundary of the rectangle.
//   y - vertical position for the bottom boundary of the rectangle.
//   w - width of the rectangle.
//   h - height of the rectangle.
//
// Returns a handle to the new path object.
var
  FPDFPageObj_CreateNewRect: function(x, y, w, h: Single): FPDF_PAGEOBJECT; stdcall;

// Get the bounding box of |page_object|.
//
// page_object  - handle to a page object.
// left         - pointer where the left coordinate will be stored
// bottom       - pointer where the bottom coordinate will be stored
// right        - pointer where the right coordinate will be stored
// top          - pointer where the top coordinate will be stored
//
// Returns TRUE on success.
var
  FPDFPageObj_GetBounds: function(page_object: FPDF_PAGEOBJECT; var left, bottom, right, top: Single): FPDF_BOOL; stdcall;

// Set the blend mode of |page_object|.
//
// page_object  - handle to a page object.
// blend_mode   - string containing the blend mode.
//
// Blend mode can be one of following: Color, ColorBurn, ColorDodge, Darken,
// Difference, Exclusion, HardLight, Hue, Lighten, Luminosity, Multiply, Normal,
// Overlay, Saturation, Screen, SoftLight
var
  FPDFPageObj_SetBlendMode: procedure(page_object: FPDF_PAGEOBJECT; blend_mode: FPDF_BYTESTRING); stdcall;

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
  FPDFPageObj_SetStrokeColor: function(page_object: FPDF_PAGEOBJECT; R, G, B, A: Cardinal): FPDF_BOOL; stdcall;

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
  FPDFPageObj_GetStrokeColor: function(page_object: FPDF_PAGEOBJECT; var R, G, B, A: Cardinal): FPDF_BOOL; stdcall;

// Set the stroke width of a page object.
//
// path   - the handle to the page object.
// width  - the width of the stroke.
//
// Returns TRUE on success
var
  FPDFPageObj_SetStrokeWidth: function(page_object: FPDF_PAGEOBJECT; width: Single): FPDF_BOOL; stdcall;

// Experimental API.
// Get the stroke width of a page object.
//
// path   - the handle to the page object.
// width  - the width of the stroke.
//
// Returns TRUE on success
var
  FPDFPageObj_GetStrokeWidth: function(page_object: FPDF_PAGEOBJECT; var width: Single): FPDF_BOOL; stdcall;

// Get the line join of |page_object|.
//
// page_object  - handle to a page object.
//
// Returns the line join, or -1 on failure.
// Line join can be one of following: FPDF_LINEJOIN_MITER, FPDF_LINEJOIN_ROUND,
// FPDF_LINEJOIN_BEVEL
var
  FPDFPageObj_GetLineJoin: function(page_object: FPDF_PAGEOBJECT): Integer; stdcall;

// Set the line join of |page_object|.
//
// page_object  - handle to a page object.
// line_join    - line join
//
// Line join can be one of following: FPDF_LINEJOIN_MITER, FPDF_LINEJOIN_ROUND,
// FPDF_LINEJOIN_BEVEL
var
  FPDFPageObj_SetLineJoin: function(page_object: FPDF_PAGEOBJECT; line_join: Integer): FPDF_BOOL; stdcall;

// Get the line cap of |page_object|.
//
// page_object - handle to a page object.
//
// Returns the line cap, or -1 on failure.
// Line cap can be one of following: FPDF_LINECAP_BUTT, FPDF_LINECAP_ROUND,
// FPDF_LINECAP_PROJECTING_SQUARE
var
  FPDFPageObj_GetLineCap: function(page_object: FPDF_PAGEOBJECT): Integer; stdcall;

// Set the line cap of |page_object|.
//
// page_object - handle to a page object.
// line_cap    - line cap
//
// Line cap can be one of following: FPDF_LINECAP_BUTT, FPDF_LINECAP_ROUND,
// FPDF_LINECAP_PROJECTING_SQUARE
var
  FPDFPageObj_SetLineCap: function(page_object: FPDF_PAGEOBJECT; line_cap: Integer): FPDF_BOOL; stdcall;

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
  FPDFPageObj_SetFillColor: function(page_object: FPDF_PAGEOBJECT; R, G, B, A: Cardinal): FPDF_BOOL; stdcall;

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
  FPDFPageObj_GetFillColor: function(page_object: FPDF_PAGEOBJECT; var R, G, B, A: Cardinal): FPDF_BOOL; stdcall;

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
  FPDFPath_CountSegments: function(path: FPDF_PAGEOBJECT): Integer; stdcall;

// Experimental API.
// Get segment in |path| at |index|.
//
//   path  - handle to a path.
//   index - the index of a segment.
//
// Returns the handle to the segment, or NULL on faiure.
var
  FPDFPath_GetPathSegment: function(path: FPDF_PAGEOBJECT; index: Integer): FPDF_PATHSEGMENT; stdcall;

// Experimental API.
// Get coordinates of |segment|.
//
//   segment  - handle to a segment.
//   x      - the horizontal position of the segment.
//   y      - the vertical position of the segment.
//
// Returns TRUE on success, otherwise |x| and |y| is not set.
var
  FPDFPathSegment_GetPoint: function(segment: FPDF_PATHSEGMENT; var x, y: Single): FPDF_BOOL; stdcall;

// Experimental API.
// Get type of |segment|.
//
//   segment - handle to a segment.
//
// Returns one of the FPDF_SEGMENT_* values on success,
// FPDF_SEGMENT_UNKNOWN on error.
var
  FPDFPathSegment_GetType: function(segment: FPDF_PATHSEGMENT): Integer; stdcall;

// Experimental API.
// Gets if the |segment| closes the current subpath of a given path.
//
//   segment - handle to a segment.
//
// Returns close flag for non-NULL segment, FALSE otherwise.
var
  FPDFPathSegment_GetClose: function(segment: FPDF_PATHSEGMENT): FPDF_BOOL; stdcall;

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
  FPDFPath_MoveTo: function(path: FPDF_PAGEOBJECT; x, y: Single): FPDF_BOOL; stdcall;

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
  FPDFPath_LineTo: function(path: FPDF_PAGEOBJECT; x, y: Single): FPDF_BOOL; stdcall;

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
  FPDFPath_BezierTo: function(path: FPDF_PAGEOBJECT; x1, y1, x2, y2, x3, y3: Single): FPDF_BOOL; stdcall;

// Close the current subpath of a given path.
//
// path   - the handle to the path object.
//
// This will add a line between the current point and the initial point of the
// subpath, thus terminating the current subpath.
//
// Returns TRUE on success
var
  FPDFPath_Close: function(path: FPDF_PAGEOBJECT): FPDF_BOOL; stdcall;

// Set the drawing mode of a path.
//
// path     - the handle to the path object.
// fillmode - the filling mode to be set: one of the FPDF_FILLMODE_* flags.
// stroke   - a boolean specifying if the path should be stroked or not.
//
// Returns TRUE on success
var
  FPDFPath_SetDrawMode: function(path: FPDF_PAGEOBJECT; fillmode: Integer; stoke: FPDF_BOOL): FPDF_BOOL; stdcall;

// Experimental API.
// Get the drawing mode of a path.
//
// path     - the handle to the path object.
// fillmode - the filling mode of the path: one of the FPDF_FILLMODE_* flags.
// stroke   - a boolean specifying if the path is stroked or not.
//
// Returns TRUE on success
var
  FPDFPath_GetDrawMode: function(path: FPDF_PAGEOBJECT; var fillmode: Integer; var stoke: FPDF_BOOL): FPDF_BOOL; stdcall;

// Experimental API.
// Get the transform matrix of a path.
//
//   path - handle to a path.
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
// and used to scale, rotate, shear and translate the path.
//
// Returns TRUE on success.
var
  FPDFPath_GetMatrix: function(path: FPDF_PAGEOBJECT; var a, b, c, d, e, f: Double): FPDF_BOOL; stdcall;

// Experimental API.
// Set the transform matrix of a path.
//
//   path - handle to a path.
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
// and can be used to scale, rotate, shear and translate the path.
//
// Returns TRUE on success.
var
  FPDFPath_SetMatrix: function(path: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double): FPDF_BOOL; stdcall;

  // Create a new text object using one of the standard PDF fonts.
//
// document   - handle to the document.
// font       - string containing the font name, without spaces.
// font_size  - the font size for the new text object.
//
// Returns a handle to a new text object, or NULL on failure
var
  FPDFPageObj_NewTextObj: function(document: FPDF_DOCUMENT; font: FPDF_BYTESTRING; font_size: Single): FPDF_PAGEOBJECT; stdcall;

// Set the text for a textobject. If it had text, it will be replaced.
//
// text_object  - handle to the text object.
// text         - the UTF-16LE encoded string containing the text to be added.
//
// Returns TRUE on success
var
  FPDFText_SetText: function(text_object: FPDF_PAGEOBJECT; text: FPDF_WIDESTRING): FPDF_BOOL; stdcall;

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
    font_type: Integer; cid: FPDF_BOOL): FPDF_FONT; stdcall;

// Experimental API.
// Loads one of the standard 14 fonts per PDF spec 1.7 page 416. The preferred
// way of using font style is using a dash to separate the name from the style,
// for example 'Helvetica-BoldItalic'.
//
// document   - handle to the document.
// font       - string containing the font name, without spaces.
//
// The loaded font should NOT be closed using FPDFFont_Close. It will be
// unloaded during the document's destruction.
//
// Returns NULL on failure.
var
  FPDFText_LoadStandardFont: function(document: FPDF_DOCUMENT; font: FPDF_BYTESTRING): FPDF_FONT; stdcall;

// Experimental API.
// Get the transform matrix of a text object.
//
//   text - handle to a text.
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
// and used to scale, rotate, shear and translate the text.
//
// Returns TRUE on success.
var
  FPDFText_GetMatrix: function(text: FPDF_PAGEOBJECT; var a, b, c, d, e, f: Double): FPDF_BOOL; stdcall;

// Experimental API.
// Get the font size of a text object.
//
//   text - handle to a text.
//
// Returns the font size of the text object, measured in points (about 1/72
// inch) on success; 0 on failure.
var
  FPDFTextObj_GetFontSize: function(text: FPDF_PAGEOBJECT): Double; stdcall;

// Close a loaded PDF font.
//
// font   - Handle to the loaded font.
var
  FPDFFont_Close: procedure(font: FPDF_FONT); stdcall;

// Create a new text object using a loaded font.
//
// document   - handle to the document.
// font       - handle to the font object.
// font_size  - the font size for the new text object.
//
// Returns a handle to a new text object, or NULL on failure
var
  FPDFPageObj_CreateTextObj: function(document: FPDF_DOCUMENT; font: FPDF_FONT; font_size: Single): FPDF_PAGEOBJECT; stdcall;

// Experimental API.
// Get the text rendering mode of a text object.
//
// text     - the handle to the text object.
//
// Returns one of the FPDF_TEXTRENDERMODE_* flags on success, -1 on error.
var
  FPDFText_GetTextRenderMode: function(text: FPDF_PAGEOBJECT): Integer; stdcall;

// Experimental API.
// Get the font name of a text object.
//
// text             - the handle to the text object.
// buffer           - the address of a buffer that receives the font name.
// length           - the size, in bytes, of |buffer|.
//
// Returns the number of bytes in the font name (including the trailing NUL
// character) on success, 0 on error.
//
// Regardless of the platform, the |buffer| is always in UTF-8 encoding.
// If |length| is less than the returned length, or |buffer| is NULL, |buffer|
// will not be modified.
var
  FPDFTextObj_GetFontName: function(text: FPDF_PAGEOBJECT; buffer: Pointer; length: LongWord): LongWord; stdcall;

// Experimental API.
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
// Regardless of the platform, the |buffer| is always in UTF16-LE encoding.
// If |length| is less than the returned length, or |buffer| is NULL, |buffer|
// will not be modified.
var
  FPDFTextObj_GetText: function(text_object: FPDF_PAGEOBJECT; text_page: FPDF_TEXTPAGE; buffer: Pointer;
    length: LongWord): LongWord; stdcall;

// Experimental API.
// Get number of page objects inside |form_object|.
//
//   form_object - handle to a form object.
//
// Returns the number of objects in |form_object| on success, -1 on error.
var
  FPDFFormObj_CountObjects: function(form_object: FPDF_PAGEOBJECT): Integer; stdcall;

// Experimental API.
// Get page object in |form_object| at |index|.
//
//   form_object - handle to a form object.
//   index       - the 0-based index of a page object.
//
// Returns the handle to the page object, or NULL on error.
var
  FPDFFormObj_GetObject: function(form_object: FPDF_PAGEOBJECT; index: LongWord): FPDF_PAGEOBJECT; stdcall;

// Experimental API.
// Get the transform matrix of a form object.
//
//   form_object - handle to a form.
//   a           - pointer to out variable to receive matrix value.
//   b           - pointer to out variable to receive matrix value.
//   c           - pointer to out variable to receive matrix value.
//   d           - pointer to out variable to receive matrix value.
//   e           - pointer to out variable to receive matrix value.
//   f           - pointer to out variable to receive matrix value.
//
// The matrix is composed as:
//   |a c e|
//   |b d f|
// and used to scale, rotate, shear and translate the form object.
//
// Returns TRUE on success.
var
  FPDFFormObj_GetMatrix: function(form_object: FPDF_PAGEOBJECT; var a, b, c, d, e, f: Double): FPDF_BOOL; stdcall;


// *** _FPDF_PPO_H_ ***

// Import pages to a FPDF_DOCUMENT.
//
//   dest_doc  - The destination document for the pages.
//   src_doc   - The document to be imported.
//   pagerange - A page range string, Such as "1,3,5-7". If |pagerange| is NULL,
//               all pages from |src_doc| are imported.
//   index     - The page index to insert at.
//
// Returns TRUE on success.
var
  FPDF_ImportPages: function(dest_doc, src_doc: FPDF_DOCUMENT; pagerange: FPDF_BYTESTRING; index: Integer): FPDF_BOOL; stdcall;

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
    num_pages_on_x_axis, num_pages_on_y_axis: SIZE_T): FPDF_DOCUMENT; stdcall;

// Copy the viewer preferences from |src_doc| into |dest_doc|.
//
//   dest_doc - Document to write the viewer preferences into.
//   src_doc  - Document to read the viewer preferences from.
//
// Returns TRUE on success.
var
  FPDF_CopyViewerPreferences: function(dest_doc, src_doc: FPDF_DOCUMENT): FPDF_BOOL; stdcall;


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
  FPDF_INCREMENTAL     = 1; // @brief Incremental.
  FPDF_NO_INCREMENTAL  = 2; // @brief No Incremental.
  FPDF_REMOVE_SECURITY = 3; // @brief Remove security.

// Function: FPDF_SaveAsCopy
//          Saves the copy of specified document in custom way.
// Parameters:
//          document        -   Handle to document. Returned by FPDF_LoadDocument and FPDF_CreateNewDocument.
//          pFileWrite      -   A pointer to a custom file write structure.
//          flags           -   The creating flags.
// Return value:
//          TRUE for succeed, FALSE for failed.
//
var
  FPDF_SaveAsCopy: function(document: FPDF_DOCUMENT; pFileWrite: PFPDF_FILEWRITE; flags: FPDF_DWORD): FPDF_BOOL; stdcall;

// Function: FPDF_SaveWithVersion
//          Same as function ::FPDF_SaveAsCopy, except the file version of the
//          saved document could be specified by user.
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
    flags: FPDF_DWORD; fileVersion: Integer): FPDF_BOOL; stdcall;


// *** _FPDF_FLATTEN_H_ ***

const
  FLATTEN_FAIL       = 0;  // Flatten operation failed.
  FLATTEN_SUCCESS    = 1;  // Flatten operation succeed.
  FLATTEN_NOTINGTODO = 2;  // Nothing to be flattened.

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
  FPDFPage_Flatten: function(page: FPDF_PAGE; nFlag: Integer): Integer; stdcall;


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
  FPDFText_LoadPage: function(page: FPDF_PAGE): FPDF_TEXTPAGE; stdcall;

// Function: FPDFText_ClosePage
//          Release all resources allocated for a text page information structure.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return Value:
//          None.
//
var
  FPDFText_ClosePage: procedure(text_page: FPDF_TEXTPAGE); stdcall;

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
  FPDFText_CountChars: function(text_page: FPDF_TEXTPAGE): Integer; stdcall;

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
  FPDFText_GetUnicode: function(text_page: FPDF_TEXTPAGE; index: Integer): WideChar; stdcall;

// Function: FPDFText_GetFontSize
//          Get the font size of a particular character.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
// Return value:
//          The font size of the particular character, measured in points (about 1/72 inch).
//          This is the typographic size of the font (so called "em size").
//
var
  FPDFText_GetFontSize: function(text_page: FPDF_TEXTPAGE; index: Integer): Double; stdcall;

// Experimental API.
// Function: FPDFText_GetFontInfo
//          Get the font name and flags of a particular character.
// Parameters:
//          text_page - Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          index     - Zero-based index of the character.
//          buffer    - A buffer receiving the font name.
//          buflen    - The length of |buffer| in bytes.
//          flags     - Optional pointer to an int receiving the font flags.
//                      These flags should be interpreted per PDF spec 1.7 Section 5.7.1
//                      Font Descriptor Flags.
// Return value:
//          On success, return the length of the font name, including the
//          trailing NUL character, in bytes. If this length is less than or
//          equal to |length|, |buffer| is set to the font name, |flags| is
//          set to the font flags. |buffer| is in UTF-8 encoding. Return 0 on
//          failure.
var
  FPDFText_GetFontInfo: function(text_page: FPDF_TEXTPAGE; index: Integer; buffer: Pointer; buflen: LongWord;
    flags: PInteger): LongWord; stdcall;

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
  FPDFText_GetCharBox: procedure(text_page: FPDF_TEXTPAGE; index: Integer; var left, right, bottom, top: Double); stdcall;

// Function: FPDFText_GetCharOrigin
//          Get origin of a particular character.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          index       -   Zero-based index of the character.
//          x           -   Pointer to a double number receiving x coordinate of the character origin.
//          y           -   Pointer to a double number receiving y coordinate of the character origin.
// Return Value:
//          Whether the call succeeded. If false, x and y are unchanged.
// Comments:
//          All positions are measured in PDF "user space".
//
var
  FPDFText_GetCharOrigin: function(text_page: FPDF_TEXTPAGE; index: Integer; var x, y: Double): FPDF_BOOL; stdcall;

// Function: FPDFText_GetCharIndexAtPos
//          Get the index of a character at or nearby a certain position on the
//          page.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          x           -   X position in PDF "user space".
//          y           -   Y position in PDF "user space".
//          xTolerance  -   An x-axis tolerance value for character hit detection, in point unit.
//          yTolerance  -   A y-axis tolerance value for character hit detection, in point unit.
// Return Value:
//          The zero-based index of the character at, or nearby the point (x,y).
//          If there is no character at or nearby the point, return value will be -1.
//          If an error occurs, -3 will be returned.
//
var
  FPDFText_GetCharIndexAtPos: function(text_page: FPDF_TEXTPAGE; x, y, xTorelance, yTolerance: Double): Integer; stdcall;

// Function: FPDFText_GetText
//          Extract unicode text string from the page.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          start_index -   Index for the start characters.
//          count       -   Number of characters to be extracted.
//          result      -   A buffer (allocated by application) receiving the extracted unicodes.
//                          The size of the buffer must be able to hold the
//                          number of characters plus a terminator.
// Return Value:
//          Number of characters written into the result buffer, including the
//          trailing terminator.
// Comments:
//          This function ignores characters without unicode information.
//
var
  FPDFText_GetText: function(text_page: FPDF_TEXTPAGE; start_index, count: Integer; result: PWideChar): Integer; stdcall;

// Function: FPDFText_CountRects
//          Count number of rectangular areas occupied by a segment of texts.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          start_index -   Index for the start characters.
//          count       -   Number of characters.
// Return value:
//          Number of rectangles. Zero for error.
// Comments:
//          This function, along with FPDFText_GetRect can be used by applications to detect the position
//          on the page for a text segment, so proper areas can be highlighted or something.
//          FPDFTEXT will automatically merge small character boxes into bigger one if those characters
//          are on the same line and use same font settings.
//

var
  FPDFText_CountRects: function(text_page: FPDF_TEXTPAGE; start_index, count: Integer): Integer; stdcall;

// Function: FPDFText_GetRect
//          Get a rectangular area from the result generated by FPDFText_CountRects.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          rect_index  -   Zero-based index for the rectangle.
//          left        -   Pointer to a double value receiving the rectangle left boundary.
//          top         -   Pointer to a double value receiving the rectangle top boundary.
//          right       -   Pointer to a double value receiving the rectangle right boundary.
//          bottom      -   Pointer to a double value receiving the rectangle bottom boundary.
// Return Value:
//          On success, return TRUE and fill in |left|, |top|, |right|, and
//          |bottom|. If |text_page| is invalid then return FALSE, and the out
//          parameters remain unmodified. If |text_page| is valid but
//          |rect_index| is out of bounds, then return FALSE and set the out
//          parameters to 0.
//

var
  FPDFText_GetRect: procedure(text_page: FPDF_TEXTPAGE; rect_index: Integer; var left, top, right, bottom: Double); stdcall;

// Function: FPDFText_GetBoundedText
//          Extract unicode text within a rectangular boundary on the page.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//          left        -   Left boundary.
//          top         -   Top boundary.
//          right       -   Right boundary.
//          bottom      -   Bottom boundary.
//          buffer      -   A unicode buffer.
//          buflen      -   Number of characters (not bytes) for the buffer, excluding an additional terminator.
// Return Value:
//          If buffer is NULL or buflen is zero, return number of characters (not bytes) of text present within
//          the rectangle, excluding a terminating NUL.  Generally you should pass a buffer at least one larger
//          than this if you want a terminating NUL, which will be provided if space is available.
//          Otherwise, return number of characters copied into the buffer, including the terminating NUL
//          when space for it is available.
// Comment:
//          If the buffer is too small, as much text as will fit is copied into it.
//
var
  FPDFText_GetBoundedText: function(text_page: FPDF_TEXTPAGE; left, top, right, bottom: Double;
    buffer: PWideChar; buflen: Integer): Integer; stdcall;

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
    start_index: Integer): FPDF_SCHHANDLE; stdcall;

// Function: FPDFText_FindNext
//          Search in the direction from page start to end.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          Whether a match is found.
//
var
  FPDFText_FindNext: function(handle: FPDF_SCHHANDLE): FPDF_BOOL; stdcall;

// Function: FPDFText_FindPrev
//          Search in the direction from page end to start.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          Whether a match is found.
//
var
  FPDFText_FindPrev: function(handle: FPDF_SCHHANDLE): FPDF_BOOL; stdcall;

// Function: FPDFText_GetSchResultIndex
//          Get the starting character index of the search result.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          Index for the starting character.
//
var
  FPDFText_GetSchResultIndex: function(handle: FPDF_SCHHANDLE): Integer; stdcall;

// Function: FPDFText_GetSchCount
//          Get the number of matched characters in the search result.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          Number of matched characters.
//
var
  FPDFText_GetSchCount: function(handle: FPDF_SCHHANDLE): Integer; stdcall;

// Function: FPDFText_FindClose
//          Release a search context.
// Parameters:
//          handle      -   A search context handle returned by FPDFText_FindStart.
// Return Value:
//          None.
//
var
  FPDFText_FindClose: procedure(handle: FPDF_SCHHANDLE); stdcall;

// Function: FPDFLink_LoadWebLinks
//          Prepare information about weblinks in a page.
// Parameters:
//          text_page   -   Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return Value:
//          A handle to the page's links information structure. NULL if something goes wrong.
// Comments:
//          Weblinks are those links implicitly embedded in PDF pages. PDF also has a type of
//          annotation called "link", FPDFTEXT doesn't deal with that kind of link.
//          FPDFTEXT weblink feature is useful for automatically detecting links in the page
//          contents. For example, things like "http://www.foxitsoftware.com" will be detected,
//          so applications can allow user to click on those characters to activate the link,
//          even the PDF doesn't come with link annotations.
//
//          FPDFLink_CloseWebLinks must be called to release resources.
//
var
  FPDFLink_LoadWebLinks: function(text_page: FPDF_TEXTPAGE): FPDF_PAGELINK; stdcall;

// Function: FPDFLink_CountWebLinks
//          Count number of detected web links.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
// Return Value:
//          Number of detected web links.
//
var
  FPDFLink_CountWebLinks: function(link_page: FPDF_PAGELINK): Integer; stdcall;

// Function: FPDFLink_GetURL
//          Fetch the URL information for a detected web link.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
//          link_index  -   Zero-based index for the link.
//          buffer      -   A unicode buffer for the result.
//          buflen      -   Number of characters (not bytes) for the buffer,
//                          including an additional terminator.
// Return Value:
//          If |buffer| is NULL or |buflen| is zero, return the number of
//          characters (not bytes) needed to buffer the result (an additional
//          terminator is included in this count).
//          Otherwise, copy the result into |buffer|, truncating at |buflen| if
//          the result is too large to fit, and return the number of characters
//          actually copied into the buffer (the additional terminator is also
//          included in this count).
//          If |link_index| does not correspond to a valid link, then the result
//          is an empty string.
//
var
  FPDFLink_GetURL: function(link_page: FPDF_PAGELINK; link_index: Integer; buffer: PWideChar; buflen: Integer): Integer; stdcall;

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
  FPDFLink_CountRects: function(link_page: FPDF_PAGELINK; link_index: Integer): Integer; stdcall;

// Function: FPDFLink_GetRect
//          Fetch the boundaries of a rectangle for a link.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
//          link_index  -   Zero-based index for the link.
//          rect_index  -   Zero-based index for a rectangle.
//          left        -   Pointer to a double value receiving the rectangle left boundary.
//          top         -   Pointer to a double value receiving the rectangle top boundary.
//          right       -   Pointer to a double value receiving the rectangle right boundary.
//          bottom      -   Pointer to a double value receiving the rectangle bottom boundary.
// Return Value:
//          On success, return TRUE and fill in |left|, |top|, |right|, and
//          |bottom|. If |link_page| is invalid or if |link_index| does not
//          correspond to a valid link, then return FALSE, and the out
//          parameters remain unmodified.
//
var
  FPDFLink_GetRect: procedure(link_page: FPDF_PAGELINK; link_index, rect_index: Integer;
    var left, top, right, bottom: Double); stdcall;

// Function: FPDFLink_CloseWebLinks
//          Release resources used by weblink feature.
// Parameters:
//          link_page   -   Handle returned by FPDFLink_LoadWebLinks.
// Return Value:
//          None.
//
var
  FPDFLink_CloseWebLinks: procedure(link_page: FPDF_PAGELINK); stdcall;


// *** _FPDF_SEARCH_EX_H ***

// Get the character index in |text_page| internal character list.
//
//   text_page  - a text page information structure.
//   nTextIndex - index of the text returned from FPDFText_GetText().
//
// Returns the index of the character in internal character list. -1 for error.
var
  FPDFText_GetCharIndexFromTextIndex: function(text_page: FPDF_TEXTPAGE; nTextIndex: Integer): Integer; stdcall;


// Get the text index in |text_page| internal character list.
//
//   text_page  - a text page information structure.
//   nCharIndex - index of the character in internal character list.
//
// Returns the index of the text returned from FPDFText_GetText(). -1 for error.
var
  FPDFText_GetTextIndexFromCharIndex: function(text_page: FPDF_TEXTPAGE; nCharIndex: Integer): Integer; stdcall;


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
    //**
    //* Version number of the interface. Currently must be 1.
    //**
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

// Function: FPDF_RenderPageBitmap_Start
//          Start to render page contents to a device independent bitmap
//          progressively.
// Parameters:
//          bitmap      -   Handle to the device independent bitmap (as the output buffer).
//                          Bitmap handle can be created by FPDFBitmap_Create function.
//          page        -   Handle to the page. Returned by FPDF_LoadPage function.
//          start_x     -   Left pixel position of the display area in the bitmap coordinate.
//          start_y     -   Top pixel position of the display area in the bitmap coordinate.
//          size_x      -   Horizontal size (in pixels) for displaying the page.
//          size_y      -   Vertical size (in pixels) for displaying the page.
//          rotate      -   Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                          2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
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
//
var
  FPDF_RenderPageBitmap_Start: function(bitmap: FPDF_BITMAP; page: FPDF_PAGE;
    start_x, start_y, size_x, size_y: Integer; rotate: Integer; flags: Integer;
    pause: PIFSDK_PAUSE): Integer; stdcall;

// Function: FPDF_RenderPage_Continue
//          Continue rendering a PDF page.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage function.
//          pause       -   The IFSDK_PAUSE interface.A callback mechanism allowing the page rendering process
//                          to be paused before it's finished. This can be NULL if you don't want to pause.
// Return value:
//          The rendering status. See flags for progressive process status for
//          the details.
var
  FPDF_RenderPage_Continue: function(page: FPDF_PAGE; pause: PIFSDK_PAUSE): Integer; stdcall;

// Function: FPDF_RenderPage_Close
//          Release the resource allocate during page rendering. Need to be
//          called after finishing rendering or cancel the rendering.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage function.
// Return value:
//          NULL
var
  FPDF_RenderPage_Close: procedure(page: FPDF_PAGE); stdcall;


// *** _FPDF_DOC_H_ ***
const
  PDFACTION_UNSUPPORTED = 0;    // Unsupported action type.
  PDFACTION_GOTO        = 1;    // Go to a destination within current document.
  PDFACTION_REMOTEGOTO  = 2;    // Go to a destination within another document.
  PDFACTION_URI         = 3;    // Universal Resource Identifier, including web pages and
                                // other Internet based resources.
  PDFACTION_LAUNCH      = 4;    // Launch an application or open a file.

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

// _FS_DEF_STRUCTURE_QUADPOINTSF_
type
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

// Get the first child of |bookmark|, or the first top-level bookmark item.
//
//   document - handle to the document.
//   bookmark - handle to the current bookmark. Pass NULL for the first top
//              level item.
//
// Returns a handle to the first child of |bookmark| or the first top-level
// bookmark item. NULL if no child or top-level bookmark found.
var
  FPDFBookmark_GetFirstChild: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_BOOKMARK; stdcall;

// Get the next sibling of |bookmark|.
//
//   document - handle to the document.
//   bookmark - handle to the current bookmark.
//
// Returns a handle to the next sibling of |bookmark|, or NULL if this is the
// last bookmark at this level.
var
  FPDFBookmark_GetNextSibling: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_BOOKMARK; stdcall;

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
  FPDFBookmark_GetTitle: function(bookmark: FPDF_BOOKMARK; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

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
  FPDFBookmark_Find: function(document: FPDF_DOCUMENT; title: FPDF_WIDESTRING): FPDF_BOOKMARK; stdcall;

// Get the destination associated with |bookmark|.
//
//   document - handle to the document.
//   bookmark - handle to the bookmark.
//
// Returns the handle to the destination data,  NULL if no destination is
// associated with |bookmark|.
var
  FPDFBookmark_GetDest: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_DEST; stdcall;

// Get the action associated with |bookmark|.
//
//   bookmark - handle to the bookmark.
//
// Returns the handle to the action data, or NULL if no action is associated
// with |bookmark|. When NULL is returned, FPDFBookmark_GetDest() should be
// called to get the |bookmark| destination data.
var
  FPDFBookmark_GetAction: function(bookmark: FPDF_BOOKMARK): FPDF_ACTION; stdcall;

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
  FPDFAction_GetType: function(action: FPDF_ACTION): LongWord; stdcall;

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
  FPDFAction_GetDest: function(document: FPDF_DOCUMENT; action: FPDF_ACTION): FPDF_DEST; stdcall;

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
  FPDFAction_GetFilePath: function(action: FPDF_ACTION; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

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
// The |buffer| is always encoded in 7-bit ASCII. If |buflen| is less than the
// returned length, or |buffer| is NULL, |buffer| will not be modified.
var
  FPDFAction_GetURIPath: function(document: FPDF_DOCUMENT; action: FPDF_ACTION; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

// Get the page index of |dest|.
//
//   document - handle to the document.
//   dest     - handle to the destination.
//
// Returns the 0-based page index containing |dest|. Returns -1 on error.
var
  FPDFDest_GetDestPageIndex: function(document: FPDF_DOCUMENT; dest: FPDF_DEST): LongWord; stdcall;

// Get the view (fit type) specified by |dest|.
// Experimental API. Subject to change.
//
//   dest         - handle to the destination.
//   pNumParams   - receives the number of view parameters, which is at most 4.
//   pParams      - buffer to write the view parameters. Must be at least 4
//                  FS_FLOATs long.
// Returns one of the PDFDEST_VIEW_* constants, PDFDEST_VIEW_UNKNOWN_MODE if
// |dest| does not specify a view.
var
  FPDFDest_GetView: function(dest: FPDF_DEST; pNumParams: PLongWord; pParams: PFS_FLOAT): LongWord; stdcall;

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
  FPDFDest_GetLocationInPage: function(dest: FPDF_DEST; var hasXCoord, hasYCoord, hasZoom: FPDF_BOOL;
    var x, y, zoom: FS_FLOAT): FPDF_BOOL; stdcall;

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
  FPDFLink_GetLinkAtPoint: function(page: FPDF_PAGE; x, y: Double): FPDF_LINK; stdcall;

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
  FPDFLink_GetLinkZOrderAtPoint: function(page: FPDF_PAGE; x, y: Double): Integer; stdcall;

// Get destination info for |link|.
//
//   document - handle to the document.
//   link     - handle to the link.
//
// Returns a handle to the destination, or NULL if there is no destination
// associated with the link. In this case, you should call FPDFLink_GetAction()
// to retrieve the action associated with |link|.
var
  FPDFLink_GetDest: function(document: FPDF_DOCUMENT; link: FPDF_LINK): FPDF_DEST; stdcall;

// Get action info for |link|.
//
//   link - handle to the link.
//
// Returns a handle to the action associated to |link|, or NULL if no action.
var
  FPDFLink_GetAction: function(link: FPDF_LINK): FPDF_ACTION; stdcall;

// Enumerates all the link annotations in |page|.
//
//   page       - handle to the page.
//   start_pos  - the start position, should initially be 0 and is updated with
//                the next start position on return.
//   link_annot - the link handle for |startPos|.
//
// Returns TRUE on success.
var
  FPDFLink_Enumerate: function(page: FPDF_PAGE; var start_pos: Integer; link_annot: PFPDF_LINK): FPDF_BOOL; stdcall;

// Get the rectangle for |link_annot|.
//
//   link_annot - handle to the link annotation.
//   rect       - the annotation rectangle.
//
// Returns true on success.
var
  FPDFLink_GetAnnotRect: function(link_annot: FPDF_LINK; rect: PFS_RECTF): FPDF_BOOL; stdcall;

// Get the count of quadrilateral points to the |link_annot|.
//
//   link_annot - handle to the link annotation.
//
// Returns the count of quadrilateral points.
var
  FPDFLink_CountQuadPoints: function(link_annot: FPDF_LINK): Integer; stdcall;

// Get the quadrilateral points for the specified |quad_index| in |link_annot|.
//
//   link_annot  - handle to the link annotation.
//   quad_index  - the specified quad point index.
//   quad_points - receives the quadrilateral points.
//
// Returns true on success.
var
  FPDFLink_GetQuadPoints: function(link_annot: FPDF_LINK; quad_index: Integer; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; stdcall;

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
  FPDF_GetMetaText: function(doc: FPDF_DOCUMENT; tag: FPDF_BYTESTRING; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

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
  FPDF_GetPageLabel: function(document: FPDF_DOCUMENT; page_index: integer; buffer: Pointer; buflen: LongWord): LongWord; stdcall;


// *** _FPDF_SYSFONTINFO_H_ ***
const
  // Character sets for the font
  FXFONT_ANSI_CHARSET        = 0;
  FXFONT_DEFAULT_CHARSET     = 1;
  FXFONT_SYMBOL_CHARSET      = 2;
  FXFONT_SHIFTJIS_CHARSET    = 128;
  FXFONT_HANGEUL_CHARSET     = 129;
  FXFONT_GB2312_CHARSET      = 134;
  FXFONT_CHINESEBIG5_CHARSET = 136;

  // Font pitch and family flags
  FXFONT_FF_FIXEDPITCH = 1;
  FXFONT_FF_ROMAN      = 1 shl 4;
  FXFONT_FF_SCRIPT     = 4 shl 4;

  // Typical weight values
  FXFONT_FW_NORMAL = 400;
  FXFONT_FW_BOLD   = 700;

//**
//* Interface: FPDF_SYSFONTINFO
//*      Interface for getting system font information and font mapping
//*
type
  PFPDF_SYSFONTINFO = ^FPDF_SYSFONTINFO;
  FPDF_SYSFONTINFO = record
    //**
    //* Version number of the interface. Currently must be 1.
    //**/
    version: Integer;

    //**
    //* Method: Release
    //*      Give implementation a chance to release any data after the interface is no longer used
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      No
    //* Comments:
    //*      Called by Foxit SDK during the final cleanup process.
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself
    //* Return Value:
    //*      None
    //*
    Release: procedure(pThis: PFPDF_SYSFONTINFO); cdecl;

    //**
    //* Method: EnumFonts
    //*      Enumerate all fonts installed on the system
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      No
    //* Comments:
    //*      Implementation should call FPDF_AddIntalledFont() function for each font found.
    //*      Only TrueType/OpenType and Type1 fonts are accepted by Foxit SDK.
    //* Parameters:
    //*      pThis      -  Pointer to the interface structure itself
    //*      pMapper    -  An opaque pointer to internal font mapper, used when calling FPDF_AddInstalledFont
    //* Return Value:
    //*      None
    //*
    EnumFonts: procedure(pThis: PFPDF_SYSFONTINFO; pMapper: Pointer); cdecl;

    //**
    //* Method: MapFont
    //*      Use the system font mapper to get a font handle from requested parameters
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      Yes only if GetFont method is not implemented.
    //* Comments:
    //*      If the system supports native font mapper (like Windows), implementation can implement this method to get a font handle.
    //*      Otherwise, Foxit SDK will do the mapping and then call GetFont method.
    //*      Only TrueType/OpenType and Type1 fonts are accepted by Foxit SDK.
    //* Parameters:
    //*      pThis        -  Pointer to the interface structure itself
    //*      weight       -  Weight of the requested font. 400 is normal and 700 is bold.
    //*      bItalic      -  Italic option of the requested font, TRUE or FALSE.
    //*      charset      -  Character set identifier for the requested font. See above defined constants.
    //*      pitch_family -  A combination of flags. See above defined constants.
    //*      face         -  Typeface name. Currently use system local encoding only.
    //*      bExact       -  Pointer to an boolean value receiving the indicator whether mapper found the exact match.
    //*              If mapper is not sure whether it's exact match, ignore this paramter.
    //* Return Value:
    //*      An opaque pointer for font handle, or NULL if system mapping is not supported.
    //**
    MapFont: function(pThis: PFPDF_SYSFONTINFO; weight, bItalic, charset, pitch_family: Integer;
      face: PAnsiChar; bExact: PInteger): Pointer; cdecl;

    //**
    //* Method: GetFont
    //*      Get a handle to a particular font by its internal ID
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      Yes only if MapFont method is not implemented.
    //* Comments:
    //*      If the system mapping not supported, Foxit SDK will do the font mapping and use this method to get a font handle.
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself
    //*      face     -  Typeface name. Currently use system local encoding only.
    //* Return Value:
    //*      An opaque pointer for font handle.
    //**
    GetFont: function(pThis: PFPDF_SYSFONTINFO; face: PAnsiChar): Pointer; cdecl;

    //**
    //* Method: GetFontData
    //*      Get font data from a font
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      Yes
    //* Comments:
    //*      Can read either full font file, or a particular TrueType/OpenType table
    //* Parameters:
    //*      pThis     -  Pointer to the interface structure itself
    //*      hFont     -  Font handle returned by MapFont or GetFont method
    //*      table     -  TrueType/OpenType table identifier (refer to TrueType specification).
    //*                   0 for the whole font file.
    //*      buffer    -  The buffer receiving the font data. Can be NULL if not provided
    //*      buf_size  -  Buffer size, can be zero if not provided
    //* Return Value:
    //*      Number of bytes needed, if buffer not provided or not large enough,
    //*      or number of bytes written into buffer otherwise.
    //**
    GetFontData: function(pThis: PFPDF_SYSFONTINFO; hFont: Pointer; table: LongWord; buffer: PWideChar;
      buf_size: LongWord): LongWord; cdecl;

    //**
    //* Method: GetFaceName
    //*      Get face name from a font handle
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      No
    //* Parameters:
    //*      pThis     -  Pointer to the interface structure itself
    //*      hFont     -  Font handle returned by MapFont or GetFont method
    //*      buffer    -  The buffer receiving the face name. Can be NULL if not provided
    //*      buf_size  -  Buffer size, can be zero if not provided
    //* Return Value:
    //*      Number of bytes needed, if buffer not provided or not large enough,
    //*      or number of bytes written into buffer otherwise.
    //**
    GetFaceName: function(pThis: PFPDF_SYSFONTINFO; hFont: Pointer; buffer: PAnsiChar; buf_size: LongWord): LongWord; cdecl;

    //**
    //* Method: GetFontCharset
    //*      Get character set information for a font handle
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      No
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself
    //*      hFont    -  Font handle returned by MapFont or GetFont method
    //* Return Value:
    //*      Character set identifier. See defined constants above.
    //**
    GetFontCharset: function(pThis: PFPDF_SYSFONTINFO; hFont: Pointer): Integer; cdecl;

    //**
    //* Method: DeleteFont
    //*      Delete a font handle
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      Yes
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself
    //*      hFont    -  Font handle returned by MapFont or GetFont method
    //* Return Value:
    //*      None
    //**
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

//**
//* Function: FPDF_GetDefaultTTFMap
//*    Returns a pointer to the default character set to TT Font name map. The
//*    map is an array of FPDF_CharsetFontMap structs, with its end indicated
//*    by a { -1, NULL } entry.
//* Parameters:
//*     None.
//* Return Value:
//*     Pointer to the Charset Font Map.
//**
var
  FPDF_GetDefaultTTFMap: function: PFPDF_CharsetFontMap; stdcall;

//**
//* Function: FPDF_AddInstalledFont
//*      Add a system font to the list in Foxit SDK.
//* Comments:
//*      This function is only called during the system font list building process.
//* Parameters:
//*      mapper   -  Opaque pointer to Foxit font mapper
//*      face     -  The font face name
//*      charset  -  Font character set. See above defined constants.
//* Return Value:
//*      None.
//**
var
  FPDF_AddInstalledFont: procedure(mapper: Pointer; face: PAnsiChar; charset: Integer); stdcall;

//**
//* Function: FPDF_SetSystemFontInfo
//*      Set the system font info interface into Foxit SDK
//* Comments:
//*      Platform support implementation should implement required methods of FFDF_SYSFONTINFO interface,
//*      then call this function during SDK initialization process.
//* Parameters:
//*      pFontInfo    -  Pointer to a FPDF_SYSFONTINFO structure
//* Return Value:
//*      None
//**
var
  FPDF_SetSystemFontInfo: procedure(pFontInfo: PFPDF_SYSFONTINFO); stdcall;

//**
//* Function: FPDF_GetDefaultSystemFontInfo
//*          Get default system font info interface for current platform
//* Comments:
//*          For some platforms Foxit SDK implement a default version of system
//*          font info interface.
//*          The default implementation can be used in FPDF_SetSystemFontInfo function.
//* Parameters:
//*          None
//* Return Value:
//*          Pointer to a FPDF_SYSFONTINFO structure describing the default interface.
//*          Or NULL if the platform doesn't have a default interface.
//*          Application should call FPDF_FreeDefaultSystemFontInfo to free the
//*          returned pointer.
//**
var
  FPDF_GetDefaultSystemFontInfo: function(): FPDF_SYSFONTINFO; stdcall;

//**
//* Function: FPDF_FreeDefaultSystemFontInfo
//*           Free a default system font info interface
//* Comments:
//*           This function should be called on the output from
//*           FPDF_SetSystemFontInfo once it is no longer needed by the client.
//* Parameters:
//*           pFontInfo       -   Pointer to a FPDF_SYSFONTINFO structure
//* Return Value:
//*          None
//**
var
  FPDF_FreeDefaultSystemFontInfo: procedure(pFontInfo: PFPDF_SYSFONTINFO); stdcall;

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
  FSDK_SetUnSpObjProcessHandler: function(unsp_info: PUNSUPPORT_INFO): FPDF_BOOL; stdcall;

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
  FSDK_SetTimeFunction: procedure(func: TFPDFTimeFunction); stdcall;

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
  FSDK_SetLocaltimeFunction: procedure(func: TFPDFLocaltimeFunction); stdcall;

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
  FPDFDoc_GetPageMode: function(document: FPDF_DOCUMENT): Integer; stdcall;


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

  FPDF_AVAIL = ^__FPDF_PTRREC;

// Create a document availability provider.
//
//   file_avail - pointer to file availability interface.
//   file       - pointer to a file access interface.
//
// Returns a handle to the document availability provider, or NULL on error.
//
// FPDFAvail_Destroy() must be called when done with the availability provider.
var
  FPDFAvail_Create: function(file_avail: PFX_FILEAVAIL; file_: PFPDF_FILEACCESS): FPDF_AVAIL; stdcall;

// Destroy the |avail| document availability provider.
//
//   avail - handle to document availability provider to be destroyed.
var
  FPDFAvail_Destroy: procedure(avail: FPDF_AVAIL); stdcall;

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
  FPDFAvail_IsDocAvail: function(avail: FPDF_AVAIL; hints: PFX_DOWNLOADHINTS): Integer; stdcall;

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
  FPDFAvail_GetDocument: function(avail: FPDF_AVAIL; password: FPDF_BYTESTRING): FPDF_DOCUMENT; stdcall;

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
  FPDFAvail_GetFirstPageNum: function(doc: FPDF_DOCUMENT): Integer; stdcall;

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
  FPDFAvail_IsPageAvail: function(avail: FPDF_AVAIL; page_index: Integer; hints: PFX_DOWNLOADHINTS): Integer; stdcall;

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
  FPDFAvail_IsFormAvail: function(avail: FPDF_AVAIL; hints: PFX_DOWNLOADHINTS): Integer; stdcall;

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
  FPDFAvail_IsLinearized: function(avail: FPDF_AVAIL): FPDF_BOOL; stdcall;


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
    //**
    //* Version number of the interface. Currently must be 2.
    //**
    version: Integer;

    //* Version 1.

    //**
    //* Method: app_alert
    //*           pop up a dialog to show warning or hint.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself.
    //*           Msg         -   A string containing the message to be displayed.
    //*           Title       -   The title of the dialog.
    //*           Type        -   The type of button group, see
    //*                           JSPLATFORM_ALERT_BUTTON_* above.
    //*           nIcon       -   The icon type, see see
    //*                           JSPLATFORM_ALERT_ICON_* above .
    //*
    //* Return Value:
    //*           Option selected by user in dialogue, see
    //*           JSPLATFORM_ALERT_RETURN_* above.
    //*
    app_alert: function(pThis: PIPDF_JsPlatform; Msg, Title: FPDF_WIDESTRING; nType: Integer; Icon: Integer): Integer; cdecl;

    //**
    //* Method: app_beep
    //*           Causes the system to play a sound.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself
    //*           nType       -   The sound type, see see JSPLATFORM_BEEP_TYPE_*
    //*                           above.
    //*
    //* Return Value:
    //*           None
    //*
    app_beep: procedure(pThis: PIPDF_JsPlatform; nType: Integer); cdecl;

    //**
    //* Method: app_response
    //*           Displays a dialog box containing a question and an entry field for
    //* the user to reply to the question.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself
    //*           Question    -   The question to be posed to the user.
    //*           Title       -   The title of the dialog box.
    //*           Default     -   A default value for the answer to the question. If
    //* not specified, no default value is presented.
    //*           cLabel      -   A short string to appear in front of and on the
    //* same line as the edit text field.
    //*           bPassword   -   If true, indicates that the user's response should
    //* show as asterisks (*) or bullets (?) to mask the response, which might be
    //* sensitive information. The default is false.
    //*           response    -   A string buffer allocated by SDK, to receive the
    //* user's response.
    //*           length      -   The length of the buffer, number of bytes.
    //* Currently, It's always be 2048.
    //* Return Value:
    //*       Number of bytes the complete user input would actually require, not
    //* including trailing zeros, regardless of the value of the length
    //*       parameter or the presence of the response buffer.
    //* Comments:
    //*       No matter on what platform, the response buffer should be always
    //* written using UTF-16LE encoding. If a response buffer is
    //*       present and the size of the user input exceeds the capacity of the
    //* buffer as specified by the length parameter, only the
    //*       first "length" bytes of the user input are to be written to the
    //* buffer.
    //*
    app_response: function(pThis: PIPDF_JsPlatform; Question, Title, Default, cLabel: FPDF_WIDESTRING; bPassword: FPDF_BOOL; response: Pointer; length: Integer): Integer; cdecl;

    //*
    //* Method: Doc_getFilePath
    //*           Get the file path of the current document.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself
    //*           filePath    -   The string buffer to receive the file path. Can be
    //* NULL.
    //*           length      -   The length of the buffer, number of bytes. Can be
    //* 0.
    //* Return Value:
    //*       Number of bytes the filePath consumes, including trailing zeros.
    //* Comments:
    //*       The filePath should be always input in local encoding.
    //*
    //*       The return value always indicated number of bytes required for the
    //*       buffer , even when there is no buffer specified, or the buffer size is
    //*       less than required. In this case, the buffer will not be modified.
    //*
    Doc_getFilePath: function(pThis: PIPDF_JsPlatform; filePath: Pointer; length: Integer): Integer; cdecl;

    //*
    //* Method: Doc_mail
    //*           Mails the data buffer as an attachment to all recipients, with or
    //* without user interaction.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself
    //*           mailData    -   Pointer to the data buffer to be sent.Can be NULL.
    //*           length      -   The size,in bytes, of the buffer pointed by
    //* mailData parameter.Can be 0.
    //*           bUI         -   If true, the rest of the parameters are used in a
    //* compose-new-message window that is displayed to the user. If false, the cTo
    //* parameter is required and all others are optional.
    //*           To          -   A semicolon-delimited list of recipients for the
    //* message.
    //*           Subject     -   The subject of the message. The length limit is 64
    //* KB.
    //*           CC          -   A semicolon-delimited list of CC recipients for
    //* the message.
    //*           BCC         -   A semicolon-delimited list of BCC recipients for
    //* the message.
    //*           Msg         -   The content of the message. The length limit is 64
    //* KB.
    //* Return Value:
    //*           None.
    //* Comments:
    //*           If the parameter mailData is NULL or length is 0, the current
    //* document will be mailed as an attachment to all recipients.
    //*
    Doc_mail: procedure(pThis: PIPDF_JsPlatform; mailData: Pointer; length: Integer; bUI: FPDF_BOOL; sTo, subject, CC, BCC, Msg: FPDF_WIDESTRING); cdecl;

    //*
    //* Method: Doc_print
    //*           Prints all or a specific number of pages of the document.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself.
    //*           bUI         -   If true, will cause a UI to be presented to the
    //* user to obtain printing information and confirm the action.
    //*           nStart      -   A 0-based index that defines the start of an
    //* inclusive range of pages.
    //*           nEnd        -   A 0-based index that defines the end of an
    //* inclusive page range.
    //*           bSilent     -   If true, suppresses the cancel dialog box while
    //* the document is printing. The default is false.
    //*           bShrinkToFit    -   If true, the page is shrunk (if necessary) to
    //* fit within the imageable area of the printed page.
    //*           bPrintAsImage   -   If true, print pages as an image.
    //*           bReverse    -   If true, print from nEnd to nStart.
    //*           bAnnotations    -   If true (the default), annotations are
    //* printed.
    //*
    Doc_print: procedure(pThis: PIPDF_JsPlatform; bUI: FPDF_BOOKMARK; nStart, nEnd: Integer; bSilent, bShrinkToFit, bPrintAsImage, bReverse, bAnnotations: FPDF_BOOL); cdecl;

    //*
    //* Method: Doc_submitForm
    //*           Send the form data to a specified URL.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself
    //*           formData    -   Pointer to the data buffer to be sent.
    //*           length      -   The size,in bytes, of the buffer pointed by
    //* formData parameter.
    //*           URL         -   The URL to send to.
    //* Return Value:
    //*           None.
    //*
    //*
    Doc_submitForm: procedure(pThis: PIPDF_JsPlatform; formData: Pointer; length: Integer; URL: FPDF_WIDESTRING); cdecl;

    //*
    //* Method: Doc_gotoPage
    //*           Jump to a specified page.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself
    //*           nPageNum    -   The specified page number, zero for the first
    //* page.
    //* Return Value:
    //*           None.
    //*
    //*
    Doc_gotoPage: procedure(pThis: PIPDF_JsPlatform; nPageNum: Integer); cdecl;

    //*
    //* Method: Field_browse
    //*           Show a file selection dialog, and return the selected file path.
    //* Interface Version:
    //*           1
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*           pThis       -   Pointer to the interface structure itself.
    //*           filePath    -   Pointer to the data buffer to receive the file
    //* path.Can be NULL.
    //*           length      -   The length of the buffer, number of bytes. Can be
    //* 0.
    //* Return Value:
    //*       Number of bytes the filePath consumes, including trailing zeros.
    //* Comments:
    //*       The filePath shoule be always input in local encoding.
    //*
    Field_browse: function(pThis: PIPDF_JsPlatform; filePath: Pointer; length: Integer): Integer; cdecl;

    //**
    //*  pointer to FPDF_FORMFILLINFO interface.
    //**
    m_pFormfillinfo: Pointer;

    //* Version 2.

    m_isolate: Pointer;               // Unused in v3, retain for compatibility.
    m_v8EmbedderSlot: DWORD;          // Unused in v3, retain for compatibility.

    //* Version 3.
    // Version 3 moves m_Isolate and m_v8EmbedderSlot to FPDF_LIBRARY_CONFIG.
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

//**
//* Function signature for the callback function passed to the FFI_SetTimer
//* method.
//* Parameters:
//*          idEvent     -   Identifier of the timer.
//* Return value:
//*          None.
//**
type
  TFPDFTimerCallback = procedure(idEvent: Integer); cdecl;

const
  PDFZOOM_XYZ      = 1;
  PDFZOOM_FITPAGE  = 2;
  PDFZOOM_FITHORZ  = 3;
  PDFZOOM_FITVERT  = 4;
  PDFZOOM_FITRECT  = 5;
  PDFZOOM_FITBBOX  = 6;
  PDFZOOM_FITBHORZ = 7;
  PDFZOOM_FITBVERT = 8;

type
  //**
  //* Declares of a struct type to the local system time.
  //**
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
  //**
  //* @name Pageview  event flags
  //*
  FXFA_PAGEVIEWEVENT_POSTADDED   = 1; // @brief After a new pageview is added.
  FXFA_PAGEVIEWEVENT_POSTREMOVED = 3; // @brief After a pageview is removed.

  // menu
  //**
  //* @name Macro Definitions for Right Context Menu Features Of XFA Fields
  //*
  FXFA_MENU_COPY      = 1;
  FXFA_MENU_CUT       = 2;
  FXFA_MENU_SELECTALL = 4;
  FXFA_MENU_UNDO      = 8;
  FXFA_MENU_REDO      = 16;
  FXFA_MENU_PASTE     = 32;

  // file type
  //**
  //* @name Macro Definitions for File Type.
  //*
  FXFA_SAVEAS_XML = 1;
  FXFA_SAVEAS_XDP = 2;
{$ENDIF PDF_ENABLE_XFA}

type
  PFPDF_FORMFILLINFO = ^FPDF_FORMFILLINFO;
  FPDF_FORMFILLINFO = record
    //**
    //* Version number of the interface. Currently must be 1 (when PDFium is built
    //*  without the XFA module) or must be 2 (when built with the XFA module).
    //**
    version: Integer;

    //* Version 1.

    //**
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

    //**
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
    //*     All positions are measured in PDF "user space".
    //*     Implementation should call FPDF_RenderPageBitmap() for repainting the
    //*     specified page area.
    //*
    FFI_Invalidate: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; left, top, right, bottom: Double); cdecl;

    //**
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
    //*     This callback function is useful for implementing special text
    //*     selection effects. An implementation should first record the returned
    //*     rectangles, then draw them one by one during the next painting period.
    //*     Lastly, it should remove all the recorded rectangles when finished
    //*     painting.
    //*
    FFI_OutputSelectedRect: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; left, top, right, bottom: Double); cdecl;

    //**
    //* Method: FFI_SetCursor
    //*     Set the Cursor shape.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     nCursorType -   Cursor type, see Flags for Cursor type for the details.
    //* Return value:
    //*     None.
    //*
    FFI_SetCursor: procedure(pThis: PFPDF_FORMFILLINFO; nCursorType: Integer); cdecl;

    //**
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

    //**
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

    //**
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

    //**
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

    //**
    //* Method: FFI_GetPage
    //*     This method receives the page handle associated with a specified page
    //*     index.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     document    -   Handle to document. Returned by FPDF_LoadDocument().
    //*     nPageIndex  -   Index number of the page. 0 for the first page.
    //* Return value:
    //*     Handle to the page, as previously returned to the implementation by
    //*     FPDF_LoadPage().
    //* Comments:
    //*     The implementation is expected to keep track of the page handles it
    //*     receives from PDFium, and their mappings to page numbers.
    //*     In some cases, the document-level JavaScript action may refer to a
    //*     page which hadn't been loaded yet. To successfully run the Javascript
    //*     action, the implementation need to load the page.
    //*
    FFI_GetPage: function(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT; nPageIndex: Integer): FPDF_PAGE; cdecl;

    //**
    //* Method: FFI_GetCurrentPage
    //*     This method receives the handle to the current page.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     document    -   Handle to document. Returned by FPDF_LoadDocument().
    //* Return value:
    //*     Handle to the page. Returned by FPDF_LoadPage().
    //* Comments:
    //*     The implementation is expected to keep track of the current page. e.g.
    //*     The current page can be the one that is most visible on screen.
    //*
    FFI_GetCurrentPage: function(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT): FPDF_PAGE; cdecl;

    //**
    //* Method: FFI_GetRotation
    //*     This method receives currently rotation of the page view.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     page        -   Handle to page. Returned by FPDF_LoadPage function.
    //* Return value:
    //*     A number to indicate the page rotation in 90 degree increments in a
    //*     clockwise direction:
    //*     0 - 0 degrees
    //*     1 - 90 degrees
    //*     2 - 180 degrees
    //*     3 - 270 degrees
    //* Note: Unused.
    //*
    FFI_GetRotation: function(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE): Integer; cdecl;

    //**
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
    //*     See the named actions description of <<PDF Reference, version 1.7>>
    //*     for more details.
    //*
    FFI_ExecuteNamedAction: procedure(pThis: PFPDF_FORMFILLINFO; namedAction: FPDF_BYTESTRING); cdecl;

    //**
    //* Method: FFI_SetTextFieldFocus
    //*     Called when a text field is getting or losing focus.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     no
    //* Parameters:
    //*     pThis           -   Pointer to the interface structure itself.
    //*     value           -   The string value of the form field, in UTF-16LE
    //*                         format.
    //*     valueLen        -   The length of the string value. This is the number
    //*                         of characters, not bytes.
    //*     is_focus        -   True if the form field is getting focus, False if
    //*                         the form field is losing focus.
    //* Return value:
    //*     None.
    //* Comments:
    //*     Only supports text fields and combobox fields.
    //*
    FFI_SetTextFieldFocus: procedure(pThis: PFPDF_FORMFILLINFO; value: FPDF_WIDESTRING; valueLen: FPDF_DWORD; is_focus: FPDF_BOOL); cdecl;

    //**
    //* Method: FFI_DoURIAction
    //*     Ask the implementation to navigate to a uniform resource identifier.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     No
    //* Parameters:
    //*     pThis           -   Pointer to the interface structure itself.
    //*     bsURI           -   A byte string which indicates the uniform resource
    //*                         identifier, terminated by 0.
    //* Return value:
    //*     None.
    //* Comments:
    //*     See the URI actions description of <<PDF Reference, version 1.7>> for
    //*     more details.
    //*
    FFI_DoURIAction: procedure(pThis: PFPDF_FORMFILLINFO; bsURI: FPDF_WIDESTRING); cdecl;

    //**
    //* Method: FFI_DoGoToAction
    //*     This action changes the view to a specified destination.
    //* Interface Version:
    //*     1
    //* Implementation Required:
    //*     No
    //* Parameters:
    //*     pThis           -   Pointer to the interface structure itself.
    //*     nPageIndex      -   The index of the PDF page.
    //*     zoomMode        -   The zoom mode for viewing page. See below.
    //*     fPosArray       -   The float array which carries the position info.
    //*     sizeofArray     -   The size of float array.
    //*
    //* PDFZoom values:
    //*   - XYZ = 1
    //*   - FITPAGE = 2
    //*   - FITHORZ = 3
    //*   - FITVERT = 4
    //*   - FITRECT = 5
    //*   - FITBBOX = 6
    //*   - FITBHORZ = 7
    //*   - FITBVERT = 8
    //*
    //* Return value:
    //*     None.
    //* Comments:
    //*     See the Destinations description of <<PDF Reference, version 1.7>> in
    //*     8.2.1 for more details.
    //*
    FFI_DoGoToAction: procedure(pThis: PFPDF_FORMFILLINFO; nPageIndex, zoomMode: Integer; fPosArray: PSingle; sizeofArray: Integer); cdecl;

    //**
    //*   Pointer to IPDF_JSPLATFORM interface.
    //*   Unused if PDFium is built without V8 support. Otherwise, if NULL, then
    //*   JavaScript will be prevented from executing while rendering the document.
    //**
    m_pJsPlatform: PIPDF_JSPLATFORM;

{$IFDEF PDF_ENABLE_XFA}
   //* Version 2.

    //**
    //* Method: FFI_DisplayCaret
    //*     This method will show the caret at specified position.
    //* Interface Version:
    //*     2
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis           -   Pointer to the interface structure itself.
    //*     page            -   Handle to page. Returned by FPDF_LoadPage().
    //*     left            -   Left position of the client area in PDF page
    //*                         coordinates.
    //*     top             -   Top position of the client area in PDF page
    //*                         coordinates.
    //*     right           -   Right position of the client area in PDF page
    //*                         coordinates.
    //*     bottom          -   Bottom position of the client area in PDF page
    //*                         coordinates.
    //* Return value:
    //*     None.
    //*
    FFI_DisplayCaret: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; bVisible: FPDF_BOOL; left, top, right, bottom: Double); cdecl;

    //**
    //* Method: FFI_GetCurrentPageIndex
    //*           This method will get the current page index.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       document        -   Handle to document. Returned by FPDF_LoadDocument
    //*function.
    //* Return value:
    //*       The index of current page.
    //**
    FFI_GetCurrentPageIndex: function(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT): Integer; cdecl;

    //**
    //* Method: FFI_SetCurrentPage
    //*           This method will set the current page.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       document        -   Handle to document. Returned by FPDF_LoadDocument
    //*function.
    //*       iCurPage        -   The index of the PDF page.
    //* Return value:
    //*       None.
    //**
    FFI_SetCurrentPage: procedure(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT; iCurPage: Integer); cdecl;

    //**
    //* Method: FFI_GotoURL
    //*           This method will link to the specified URL.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           no
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       document        -   Handle to document. Returned by FPDF_LoadDocument
    //*function.
    //*       wsURL           -   The string value of the URL, in UTF-16LE format.
    //* Return value:
    //*       None.
    //**
    FFI_GotoURL: procedure(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT; wsURL: FPDF_WIDESTRING); cdecl;

    //**
    //* Method: FFI_GetPageViewRect
    //*     This method will get the current page view rectangle.
    //* Interface Version:
    //*     2
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis           -   Pointer to the interface structure itself.
    //*     page            -   Handle to page. Returned by FPDF_LoadPage().
    //*     left            -   The pointer to receive left position of the page
    //*                         view area in PDF page coordinates.
    //*     top             -   The pointer to receive top position of the page
    //*                         view area in PDF page coordinates.
    //*     right           -   The pointer to receive right position of the page
    //*                         view area in PDF page coordinates.
    //*     bottom          -   The pointer to receive bottom position of the page
    //*                         view area in PDF page coordinates.
    //* Return value:
    //*     None.
    //*
    FFI_GetPageViewRect: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; var left, top, right, bottom: Double); cdecl;

    //**
    //* Method: FFI_PageEvent
    //*     This method fires when pages have been added to or deleted from the XFA
    //*     document.
    //* Interface Version:
    //*     2
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis       -   Pointer to the interface structure itself.
    //*     page_count  -   The number of pages to be added to or deleted from the
    //*                     document.
    //*     event_type  -   See FXFA_PAGEVIEWEVENT_* above.
    //* Return value:
    //*       None.
    //* Comments:
    //*           The pages to be added or deleted always start from the last page
    //*           of document. This means that if parameter page_count is 2 and
    //*           event type is FXFA_PAGEVIEWEVENT_POSTADDED, 2 new pages have been
    //*           appended to the tail of document; If page_count is 2 and
    //*           event type is FXFA_PAGEVIEWEVENT_POSTREMOVED, the last 2 pages
    //*           have been deleted.
    //**/
    FFI_PageEvent: procedure(pThis: PFPDF_FORMFILLINFO; page_count: Integer; event_type: FPDF_DWORD); cdecl;

    //**
    //* Method: FFI_PopupMenu
    //*     This method will track the right context menu for XFA fields.
    //* Interface Version:
    //*     2
    //* Implementation Required:
    //*     yes
    //* Parameters:
    //*     pThis           -   Pointer to the interface structure itself.
    //*     page            -   Handle to page. Returned by FPDF_LoadPage().
    //*     hWidget         -   Handle to XFA fields.
    //*     menuFlag        -   The menu flags. Please refer to macro definition
    //*                         of FXFA_MENU_XXX and this can be one or a
    //*                         combination of these macros.
    //*     x               -   X position of the client area in PDF page
    //*                         coordinates.
    //*     y               -   Y position of the client area in PDF page
    //*                         coordinates.
    //* Return value:
    //*     TRUE indicates success; otherwise false.
    //*
    FFI_PopupMenu: function(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; hWidget: FPDF_WIDGET; menuFlag: Integer; x, y: Single): FPDF_BOOL; cdecl;

    //**
    //* Method: FFI_OpenFile
    //*           This method will open the specified file with the specified mode.
    //* Interface Version
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       fileFlag        -   The file flag.Please refer to macro definition of
    //*                           FXFA_SAVEAS_XXX and this can be one of these macros.
    //*       wsURL           -   The string value of the file URL, in UTF-16LE
    //*format.
    //*       mode            -   The mode for open file.
    //* Return value:
    //*       The handle to FPDF_FILEHANDLER.
    //**
    FFI_OpenFile: function(pThis: PFPDF_FORMFILLINFO; fileFlag: Integer; wsURL: FPDF_WIDESTRING; mode: PAnsiChar): FPDF_FILEHANDLER; cdecl;

    //**
    //* Method: FFI_EmailTo
    //*           This method will email the specified file stream to the specified
    //*           contacter.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
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
    //**/
    FFI_EmailTo: procedure(pThis: PFPDF_FORMFILLINFO; fileHandler: PFPDF_FILEHANDLER; pTo, pSubject, pCC, pBcc, pMsg: FPDF_WIDESTRING); cdecl;

    //**
    //* Method: FFI_UploadTo
    //*           This method will get upload the specified file stream to the
    //*specified URL.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       pFileHandler    -   Handle to the FPDF_FILEHANDLER.
    //*       fileFlag        -   The file flag.Please refer to macro definition of
    //*FXFA_SAVEAS_XXX and this can be one of these macros.
    //*       uploadTo        -   Pointer to the URL path, in UTF-16LE format.
    //* Return value:
    //*       None.
    //**/
    FFI_UploadTo: procedure(pThis: PFPDF_FORMFILLINFO; fileHandler: PFPDF_FILEHANDLER; fileFlag: Integer; uploadTo: FPDF_WIDESTRING); cdecl;

    //**
    //* Method: FFI_GetPlatform
    //*           This method will get the current platform.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       platform        -   Pointer to the data buffer to receive the
    //*platform.Can be NULL,in UTF-16LE format.
    //*       length          -   The length of the buffer, number of bytes. Can be
    //*0.
    //* Return value:
    //*       The length of the buffer, number of bytes.
    //**
    FFI_GetPlatform: function(pThis: PFPDF_FORMFILLINFO; platform_: Pointer; length: Integer): Integer; cdecl;

    //**
    //* Method: FFI_GetLanguage
    //*           This method will get the current language.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       language        -   Pointer to the data buffer to receive the current
    //*language.Can be NULL.
    //*       length          -   The length of the buffer, number of bytes. Can be
    //*0.
    //* Return value:
    //*       The length of the buffer, number of bytes.
    //**/
    FFI_GetLanguage: function(pThis: PFPDF_FORMFILLINFO; language: Pointer; length: Integer): Integer; cdecl;

    //**
    //* Method: FFI_DownloadFromURL
    //*           This method will download the specified file from the URL.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       URL             -   The string value of the file URL, in UTF-16LE
    //*format.
    //* Return value:
    //*       The handle to FPDF_FILEHANDLER.
    //**/
    FFI_DownloadFromURL: function(pThis: PFPDF_FORMFILLINFO; URL: FPDF_WIDESTRING): FPDF_LPFILEHANDLER; cdecl;

    //**
    //* Method: FFI_PostRequestURL
    //*           This method will post the request to the server URL.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       wsURL           -   The string value of the server URL, in UTF-16LE
    //*format.
    //*       wsData          -   The post data,in UTF-16LE format.
    //*       wsContentType   -   The content type of the request data,in UTF-16LE
    //*format.
    //*       wsEncode        -   The encode type,in UTF-16LE format.
    //*       wsHeader        -   The request header,in UTF-16LE format.
    //*       response        -   Pointer to the FPDF_BSTR to receive the response
    //*data from server,,in UTF-16LE format.
    //* Return value:
    //*       TRUE indicates success, otherwise FALSE.
    //**/
    FFI_PostRequestURL: function(pThis: PFPDF_FORMFILLINFO; wsURL, wsData, wsContentType, wsEncode, wsHeader: FPDF_WIDESTRING; respone: PFPDF_BSTR): FPDF_BOOL; cdecl;

    //**
    //* Method: FFI_PutRequestURL
    //*           This method will put the request to the server URL.
    //* Interface Version:
    //*           2
    //* Implementation Required:
    //*           yes
    //* Parameters:
    //*       pThis           -   Pointer to the interface structure itself.
    //*       wsURL           -   The string value of the server URL, in UTF-16LE
    //*format.
    //*       wsData          -   The put data, in UTF-16LE format.
    //*       wsEncode        -   The encode type, in UTR-16LE format.
    //* Return value:
    //*       TRUE indicates success, otherwise FALSE.
    //**/
    FFI_PutRequestURL: function(pThis: PFPDF_FORMFILLINFO; wsURL, wsData, wsEncode: FPDF_WIDESTRING): FPDF_BOOL; cdecl;
    {$ENDIF PDF_ENABLE_XFA}
  end;
  PFPDFFormFillInfo = ^TFPDFFormFillInfo;
  TFPDFFormFillInfo = FPDF_FORMFILLINFO;


//**
//* Function: FPDFDOC_InitFormFillEnvironment
//*          Init form fill environment.
//* Comments:
//*          This function should be called before any form fill operation.
//* Parameters:
//*          document        -   Handle to document. Returned by
//*                              FPDF_LoadDocument function.
//*          pFormFillInfo   -   Pointer to a FPDF_FORMFILLINFO structure.
//* Return Value:
//*          Return handler to the form fill module. NULL means fails.
//**
var
  FPDFDOC_InitFormFillEnvironment: function(document: FPDF_DOCUMENT; formInfo: PFPDF_FORMFILLINFO): FPDF_FORMHANDLE; stdcall;

//**
//* Function: FPDFDOC_ExitFormFillEnvironment
//*          Exit form fill environment.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//* Return Value:
//*          NULL.
//**
var
  FPDFDOC_ExitFormFillEnvironment: procedure(hHandle: FPDF_FORMHANDLE); stdcall;

//**
//* Function: FORM_OnAfterLoadPage
//*      This method is required for implementing all the form related functions. Should be invoked after user
//*      successfully loaded a PDF page, and method FPDFDOC_InitFormFillEnvironment had been invoked.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//* Return Value:
//*      NONE.
//**
var
  FORM_OnAfterLoadPage: procedure(page: FPDF_PAGE; hHandle: FPDF_FORMHANDLE); stdcall;

//**
//* Function: FORM_OnBeforeClosePage
//*      This method is required for implementing all the form related functions. Should be invoked before user
//*      close the PDF page.
//* Parameters:
//*      page       -  Handle to the page. Returned by FPDF_LoadPage function.
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//* Return Value:
//*      NONE.
//**
var
  FORM_OnBeforeClosePage: procedure(page: FPDF_PAGE; hHandle: FPDF_FORMHANDLE); stdcall;

//**
//* Function: FORM_DoDocumentJSAction
//*      This method is required for performing Document-level JavaScript action. It should be invoked after the PDF document
//*      had been loaded.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//* Return Value:
//*      NONE
//* Comments:
//*      If there is Document-level JavaScript action embedded in the document, this method will execute the javascript action;
//*      otherwise, the method will do nothing.
//**
var
  FORM_DoDocumentJSAction: procedure(hHandle: FPDF_FORMHANDLE); stdcall;

//**
//* Function: FORM_DoDocumentOpenAction
//*      This method is required for performing open-action when the document is opened.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//* Return Value:
//*      NONE
//* Comments:
//*      This method will do nothing if there is no open-actions embedded in the document.
//**
var
  FORM_DoDocumentOpenAction: procedure(hHandle: FPDF_FORMHANDLE); stdcall;

// additional actions type of document.
const
  FPDFDOC_AACTION_WC = $10;    //WC, before closing document, JavaScript action.
  FPDFDOC_AACTION_WS = $11;    //WS, before saving document, JavaScript action.
  FPDFDOC_AACTION_DS = $12;    //DS, after saving document, JavaScript action.
  FPDFDOC_AACTION_WP = $13;    //WP, before printing document, JavaScript action.
  FPDFDOC_AACTION_DP = $14;    //DP, after printing document, JavaScript action.

//**
//* Function: FORM_DoDocumentAAction
//*      This method is required for performing the document's additional-action.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      aaType     -   The type of the additional-actions which defined above.
//* Return Value:
//*      NONE
//* Comments:
//*      This method will do nothing if there is no document additional-action corresponding to the specified aaType.
//**
var
  FORM_DoDocumentAAction: procedure(hHandle: FPDF_FORMHANDLE; aaType: Integer); stdcall;

// Additional-action types of page object
const
  FPDFPAGE_AACTION_OPEN  = 0;    // OPEN (/O) -- An action to be performed when the page is opened
  FPDFPAGE_AACTION_CLOSE = 1;    // CLOSE (/C) -- An action to be performed when the page is closed

//**
//* Function: FORM_DoPageAAction
//*      This method is required for performing the page object's additional-action when opened or closed.
//* Parameters:
//*      page     -  Handle to the page. Returned by FPDF_LoadPage function.
//*      hHandle  -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      aaType   -   The type of the page object's additional-actions which defined above.
//* Return Value:
//*      NONE
//* Comments:
//*      This method will do nothing if no additional-action corresponding to the specified aaType exists.
//**
var
  FORM_DoPageAAction: procedure(page: FPDF_PAGE; hHandle: FPDF_FORMHANDLE; aaType: Integer); stdcall;

//**
//* Function: FORM_OnMouseMove
//*      You can call this member function when the mouse cursor moves.
//* Parameters:
//*      hHandle   -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//*      modifier  -  Indicates whether various virtual keys are down.
//*      page_x    -  Specifies the x-coordinate of the cursor in PDF user space.
//*      page_y    -  Specifies the y-coordinate of the cursor in PDF user space.
//* Return Value:
//*      TRUE indicates success; otherwise false.
//**
var
  FORM_OnMouseMove: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer; page_x, page_y: Double): FPDF_BOOL; stdcall;

//**
//* Function: FORM_OnFocus
//*          This function focuses the form annotation at a given point. If the
//*          annotation at the point already has focus, nothing happens. If there
//*          is no annotation at the point, remove form focus.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//*          page        -   Handle to the page. Returned by FPDF_LoadPage.
//*          modifier    -   Indicates whether various virtual keys are down.
//*          page_x      -   Specifies the x-coordinate of the cursor in PDF user
//*                          space.
//*          page_y      -   Specifies the y-coordinate of the cursor in PDF user
//*                          space.
//* Return Value:
//*          TRUE if there is an annotation at the given point and it has focus.
//**
var
  FORM_OnFocus: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer; page_x, page_y: Double): FPDF_BOOL; stdcall;

//**
//* Function: FORM_OnLButtonDown
//*      You can call this member function when the user presses the left mouse button.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      page       -  Handle to the page. Returned by FPDF_LoadPage function.
//*      modifier   -  Indicates whether various virtual keys are down.
//*      page_x     -  Specifies the x-coordinate of the cursor in PDF user space.
//*      page_y     -  Specifies the y-coordinate of the cursor in PDF user space.
//* Return Value:
//*      TRUE indicates success; otherwise false.
//**
var
  FORM_OnLButtonDown: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer; page_x, page_y: Double): FPDF_BOOL; stdcall;

//**
//* Function: FORM_OnLButtonUp
//*      You can call this member function when the user releases the left mouse button.
//* Parameters:
//*      hHandle   -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//*      modifier  -  Indicates whether various virtual keys are down.
//*      page_x    -  Specifies the x-coordinate of the cursor in device.
//*      page_y    -  Specifies the y-coordinate of the cursor in device.
//* Return Value:
//*      TRUE indicates success; otherwise false.
//**
var
  FORM_OnLButtonUp: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer; page_x, page_y: Double): FPDF_BOOL; stdcall;

  //**
  //* Function: FORM_OnLButtonDoubleClick
  //*          You can call this member function when the user double clicks the
  //*          left mouse button.
  //* Parameters:
  //*          hHandle     -   Handle to the form fill module. Returned by
  //*                          FPDFDOC_InitFormFillEnvironment().
  //*          page        -   Handle to the page. Returned by FPDF_LoadPage
  //*                          function.
  //*          modifier    -   Indicates whether various virtual keys are down.
  //*          page_x      -   Specifies the x-coordinate of the cursor in PDF user
  //*                          space.
  //*          page_y      -   Specifies the y-coordinate of the cursor in PDF user
  //*                          space.
  //* Return Value:
  //*          TRUE indicates success; otherwise false.
  //*
var
  FORM_OnLButtonDoubleClick: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer; page_x, page_y: Double): FPDF_BOOL; stdcall;

{$IFDEF PDF_ENABLE_XFA}
var
  FORM_OnRButtonDown: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer; page_x, page_y: Double): FPDF_BOOL; stdcall;
var
  FORM_OnRButtonUp: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; modifier: Integer; page_x, page_y: Double): FPDF_BOOL; stdcall;
{$ENDIF PDF_ENABLE_XFA}

//**
//* Function: FORM_OnKeyDown
//*      You can call this member function when a nonsystem key is pressed.
//* Parameters:
//*      hHandle   -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//*      nKeyCode  -  Indicates whether various virtual keys are down.
//*      modifier  -  Contains the scan code, key-transition code, previous key state, and context code.
//* Return Value:
//*      TRUE indicates success; otherwise false.
//**
var
  FORM_OnKeyDown: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; nKeyCode, modifier: Integer): FPDF_BOOL; stdcall;

//**
//* Function: FORM_OnKeyUp
//*      You can call this member function when a nonsystem key is released.
//* Parameters:
//*      hHandle   -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//*      nKeyCode  -  The virtual-key code of the given key.
//*      modifier  -  Contains the scan code, key-transition code, previous key state, and context code.
//* Return Value:
//*      TRUE indicates success; otherwise false.
//**
var
  FORM_OnKeyUp: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; nKeyCode, modifier: Integer): FPDF_BOOL; stdcall;

//**
//* Function: FORM_OnChar
//*      You can call this member function when a keystroke translates to a nonsystem character.
//* Parameters:
//*      hHandle   -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//*      nChar     -  The character code value of the key.
//*      modifier  -  Contains the scan code, key-transition code, previous key state, and context code.
//* Return Value:
//*      TRUE indicates success; otherwise false.
//**
var
  FORM_OnChar: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; nChar, modifier: Integer): FPDF_BOOL; stdcall;

//**
//* Experimental API
//* Function: FORM_GetFocusedText
//*          You can call this function to obtain the text within the current
//*          focused field, if any.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//*          page        -   Handle to the page. Returned by FPDF_LoadPage
//*                          function.
//*          buffer      -   Buffer for holding the form text, encoded in
//*                          UTF16-LE. If NULL, |buffer| is not modified.
//*          buflen      -   Length of |buffer| in bytes. If |buflen| is less
//*                          than the length of the form text string, |buffer| is
//*                          not modified.
//* Return Value:
//*          Length in bytes for the text in the focused field.
//**
var
  FORM_GetFocusedText: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

//**
//* Function: FORM_GetSelectedText
//*          You can call this function to obtain selected text within
//*          a form text field or form combobox text field.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//*          page        -   Handle to the page. Returned by FPDF_LoadPage
//*                          function.
//*          buffer      -   Buffer for holding the selected text, encoded in
//*                          UTF16-LE. If NULL, |buffer| is not modified.
//*          buflen      -   Length of |buffer| in bytes. If |buflen| is less
//*                          than the length of the selected text string,
//*                          |buffer| is not modified.
//* Return Value:
//*          Length in bytes of selected text in form text field or form combobox
//*          text field.
//**
var
  FORM_GetSelectedText: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

//**
//* Function: FORM_ReplaceSelection
//*          You can call this function to replace the selected text in a form
//*          text field or user-editable form combobox text field with another
//*          text string (which can be empty or non-empty). If there is no
//*          selected text, this function will append the replacement text after
//*          the current caret position.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//*          page        -   Handle to the page. Returned by FPDF_LoadPage
//*                          function.
//*          wsText      -   The text to be inserted, in UTF-16LE format.
//* Return Value:
//*          None.
//**
var
  FORM_ReplaceSelection: procedure(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; wsText: FPDF_WIDESTRING); stdcall;

//**
//* Function: FORM_CanUndo
//*          Find out if it is possible for the current focused widget in a given
//*          form to perform an undo operation.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//*          page        -   Handle to the page. Returned by FPDF_LoadPage
//*                          function.
//* Return Value:
//*          True if it is possible to undo.
//**
var
  FORM_CanUndo: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; stdcall;

//**
//* Function: FORM_CanRedo
//*          Find out if it is possible for the current focused widget in a given
//*          form to perform a redo operation.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//*          page        -   Handle to the page. Returned by FPDF_LoadPage
//*                          function.
//* Return Value:
//*          True if it is possible to redo.
//**
var
  FORM_CanRedo: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; stdcall;

//**
//* Function: FORM_Undo
//*          Make the current focussed widget perform an undo operation.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//*          page        -   Handle to the page. Returned by FPDF_LoadPage
//*                          function.
//* Return Value:
//*          True if the undo operation succeeded.
//**
var
  FORM_Undo: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; stdcall;

//**
//* Function: FORM_Redo
//*          Make the current focussed widget perform a redo operation.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by
//*                          FPDFDOC_InitFormFillEnvironment.
//*          page        -   Handle to the page. Returned by FPDF_LoadPage
//*                          function.
//* Return Value:
//*          True if the redo operation succeeded.
//**
var
  FORM_Redo: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE): FPDF_BOOL; stdcall;

//**
//* Function: FORM_ForceToKillFocus.
//*      You can call this member function to force to kill the focus of the form field which got focus.
//*      It would kill the focus on the form field, save the value of form field if it's changed by user.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//* Return Value:
//*      TRUE indicates success; otherwise false.
//**
var
  FORM_ForceToKillFocus: function(hHandle: FPDF_FORMHANDLE): FPDF_BOOL; stdcall;

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


//**
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
//**
var
  FPDFPage_HasFormFieldAtPoint: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; page_x, page_y: Double): Integer; stdcall;

//**
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
//**
var
  FPDFPage_FormFieldZOrderAtPoint: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; page_x, page_y: Double): Integer; stdcall;

//**
//* Function: FPDF_SetFormFieldHighlightColor
//*          Set the highlight color of specified or all the form fields in the document.
//* Parameters:
//*          hHandle     -   Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*          doc         -   Handle to the document. Returned by FPDF_LoadDocument function.
//*          fieldType   -   A 32-bit integer indicating the type of a form field(defined above).
//*          color       -   The highlight color of the form field.Constructed by 0xxxrrggbb.
//* Return Value:
//*          NONE.
//* Comments:
//*          When the parameter fieldType is set to FPDF_FORMFIELD_UNKNOWN, the
//*          highlight color will be applied to all the form fields in the document.
//*          Please refresh the client window to show the highlight immediately if necessary.
//**
var
  FPDF_SetFormFieldHighlightColor: procedure(hHandle: FPDF_FORMHANDLE; fieldType: Integer; Color: LongWord); stdcall;

//**
//* Function: FPDF_SetFormFieldHighlightAlpha
//*      Set the transparency of the form field highlight color in the document.
//* Parameters:
//*      hHandle  -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      doc      -  Handle to the document. Returned by FPDF_LoadDocument function.
//*      alpha    -  The transparency of the form field highlight color. between 0-255.
//* Return Value:
//*      NONE.
//**
var
  FPDF_SetFormFieldHighlightAlpha: procedure(hHandle: FPDF_FORMHANDLE; alpha: Byte); stdcall;

//**
//* Function: FPDF_RemoveFormFieldHighlight
//*      Remove the form field highlight color in the document.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//* Return Value:
//*      NONE.
//* Comments:
//*      Please refresh the client window to remove the highlight immediately if necessary.
//**
var
  FPDF_RemoveFormFieldHighlight: procedure(hHandle: FPDF_FORMHANDLE); stdcall;

//**
//* Function: FPDF_FFLDraw
//*           Render FormFields and popup window on a page to a device independent bitmap.
//* Parameters:
//*           hHandle     -   Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*           bitmap      -   Handle to the device independent bitmap (as the output buffer).
//*                           Bitmap handle can be created by FPDFBitmap_Create function.
//*           page        -   Handle to the page. Returned by FPDF_LoadPage function.
//*           start_x     -   Left pixel position of the display area in the device coordinate.
//*           start_y     -   Top pixel position of the display area in the device coordinate.
//*           size_x      -   Horizontal size (in pixels) for displaying the page.
//*           size_y      -   Vertical size (in pixels) for displaying the page.
//*           rotate      -   Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//*                           2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//*           flags       -   0 for normal display, or combination of flags defined above.
//* Return Value:
//*           None.
//* Comments:
//*           This function is designed to render annotations that are
//*           user-interactive, which are widget annotation (for FormFields) and popup annotation.
//*           With FPDF_ANNOT flag, this function will render popup annotation
//*           when users mouse-hover on non-widget annotation. Regardless of FPDF_ANNOT flag,
//*           this function will always render widget annotations for FormFields.
//*           In order to implement the FormFill functions, implementation should
//*           call this function after rendering functions, such as FPDF_RenderPageBitmap or
//*           FPDF_RenderPageBitmap_Start, finish rendering the page contents.
//**
var
  FPDF_FFLDraw: procedure(hHandle: FPDF_FORMHANDLE; bitmap: FPDF_BITMAP; page: FPDF_PAGE; start_x, start_y, size_x, size_y, rotate, flags: Integer); stdcall;

{$IFDEF _SKIA_SUPPORT_}
  FPDF_FFLRecord: procedure(hHandle: FPDF_FORMHANDLE; recorder: FPDF_RECORDER; page: FPDF_PAGE; start_x, start_y, size_x, size_y, rotate, flags: Integer); stdcall;
{$ENDIF _SKIA_SUPPORT_}

//**
//* Experimental API
//* Function: FPDF_GetFormType
//*           Returns the type of form contained in the PDF document.
//* Parameters:
//*           document - Handle to document.
//* Return Value:
//*           Integer value representing one of the FORMTYPE_ values.
//* Comments:
//*           If |document| is NULL, then the return value is FORMTYPE_NONE.
//**
var
  FPDF_GetFormType: function(document: FPDF_DOCUMENT): Integer; stdcall;

//**
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
//**
var
  FORM_SetIndexSelected: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; index: Integer;
    selected: FPDF_BOOL): FPDF_BOOL; stdcall;

//**
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
//**
var
  FORM_IsIndexSelected: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; index: Integer): FPDF_BOOL; stdcall;

{$IFDEF PDF_ENABLE_XFA}
//**
//* Function: FPDF_LoadXFA
//*          If the document consists of XFA fields, there should call this ethod to load XFA fields.
//* Parameters:
//*          document        -   Handle to document. Returned by FPDF_LoadDocument function.
//* Return Value:
//*          TRUE indicates success,otherwise FALSE.
//**
var
  FPDF_LoadXFA: function(document: FPDF_DOCUMENT): FPDF_BOOL; stdcall;
{$ENDIF PDF_ENABLE_XFA}


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

// Refer to PDF Reference version 1.7 table 8.70 for field flags common to all
// interactive form field types.
  FPDF_FORMFLAG_NONE = 0;
  FPDF_FORMFLAG_READONLY = (1 shl 0);
  FPDF_FORMFLAG_REQUIRED = (1 shl 1);
  FPDF_FORMFLAG_NOEXPORT = (1 shl 2);

// Refer to PDF Reference version 1.7 table 8.77 for field flags specific to
// interactive form text fields.
  FPDF_FORMFLAG_TEXT_MULTILINE = (1 shl 12);

// Refer to PDF Reference version 1.7 table 8.79 for field flags specific to
// interactive form choice fields.
  FPDF_FORMFLAG_CHOICE_COMBO = (1 shl 17);
  FPDF_FORMFLAG_CHOICE_EDIT = (1 shl 18);

type
  FPDFANNOT_COLORTYPE = (
    FPDFANNOT_COLORTYPE_Color = 0,
    FPDFANNOT_COLORTYPE_InteriorColor
  );

// Experimental API.
// Check if an annotation subtype is currently supported for creation.
// Currently supported subtypes: circle, highlight, ink, popup, square,
// squiggly, stamp, strikeout, text, and underline.
//
//   subtype   - the subtype to be checked.
//
// Returns true if this subtype supported.
var
  FPDFAnnot_IsSupportedSubtype: function(subtype: FPDF_ANNOTATION_SUBTYPE): FPDF_BOOL; stdcall;

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
  FPDFPage_CreateAnnot: function(page: FPDF_PAGE; subtype: FPDF_ANNOTATION_SUBTYPE): FPDF_ANNOTATION; stdcall;

// Experimental API.
// Get the number of annotations in |page|.
//
//   page   - handle to a page.
//
// Returns the number of annotations in |page|.
var
  FPDFPage_GetAnnotCount: function(page: FPDF_PAGE): Integer; stdcall;

// Experimental API.
// Get annotation in |page| at |index|. Must call FPDFPage_CloseAnnot() when the
// annotation returned by this function is no longer needed.
//
//   page  - handle to a page.
//   index - the index of the annotation.
//
// Returns a handle to the annotation object, or NULL on failure.
var
  FPDFPage_GetAnnot: function(page: FPDF_PAGE; index: Integer): FPDF_ANNOTATION; stdcall;

// Experimental API.
// Get the index of |annot| in |page|. This is the opposite of
// FPDFPage_GetAnnot().
//
//   page  - handle to the page that the annotation is on.
//   annot - handle to an annotation.
//
// Returns the index of |annot|, or -1 on failure.
var
  FPDFPage_GetAnnotIndex: function(page: FPDF_PAGE; annot: FPDF_ANNOTATION): Integer; stdcall;

// Experimental API.
// Close an annotation. Must be called when the annotation returned by
// FPDFPage_CreateAnnot() or FPDFPage_GetAnnot() is no longer needed. This
// function does not remove the annotation from the document.
//
//   annot  - handle to an annotation.
var
  FPDFPage_CloseAnnot: procedure(annot: FPDF_ANNOTATION); stdcall;

// Experimental API.
// Remove the annotation in |page| at |index|.
//
//   page  - handle to a page.
//   index - the index of the annotation.
//
// Returns true if successful.
var
  FPDFPage_RemoveAnnot: function(page: FPDF_PAGE; index: Integer): FPDF_BOOL; stdcall;

// Experimental API.
// Get the subtype of an annotation.
//
//   annot  - handle to an annotation.
//
// Returns the annotation subtype.
var
  FPDFAnnot_GetSubtype: function(annot: FPDF_ANNOTATION): FPDF_ANNOTATION_SUBTYPE; stdcall;

// Experimental API.
// Check if an annotation subtype is currently supported for object extraction,
// update, and removal.
// Currently supported subtypes: ink and stamp.
//
//   subtype   - the subtype to be checked.
//
// Returns true if this subtype supported.
var
  FPDFAnnot_IsObjectSupportedSubtype: function(subtype: FPDF_ANNOTATION_SUBTYPE): FPDF_BOOL; stdcall;

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
  FPDFAnnot_UpdateObject: function(annot: FPDF_ANNOTATION; obj: FPDF_PAGEOBJECT): FPDF_BOOL; stdcall;

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
  FPDFAnnot_AppendObject: function(annot: FPDF_ANNOTATION; obj: FPDF_PAGEOBJECT): FPDF_BOOL; stdcall;

// Experimental API.
// Get the total number of objects in |annot|, including path objects, text
// objects, external objects, image objects, and shading objects.
//
//   annot  - handle to an annotation.
//
// Returns the number of objects in |annot|.
var
  FPDFAnnot_GetObjectCount: function(annot: FPDF_ANNOTATION): Integer; stdcall;

// Experimental API.
// Get the object in |annot| at |index|.
//
//   annot  - handle to an annotation.
//   index  - the index of the object.
//
// Return a handle to the object, or NULL on failure.
var
  FPDFAnnot_GetObject: function(annot: FPDF_ANNOTATION; index: Integer): FPDF_PAGEOBJECT; stdcall;

// Experimental API.
// Remove the object in |annot| at |index|.
//
//   annot  - handle to an annotation.
//   index  - the index of the object to be removed.
//
// Return true if successful.
var
  FPDFAnnot_RemoveObject: function(annot: FPDF_ANNOTATION; index: Integer): FPDF_BOOL; stdcall;

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
  FPDFAnnot_SetColor: function(annot: FPDF_ANNOTATION; type_: FPDFANNOT_COLORTYPE; R, G, B, A: Cardinal): FPDF_BOOL; stdcall;

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
  FPDFAnnot_GetColor: function(annot: FPDF_ANNOTATION; type_: FPDFANNOT_COLORTYPE; var R, G, B, A: Cardinal): FPDF_BOOL; stdcall;

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
  FPDFAnnot_HasAttachmentPoints: function(annot: FPDF_ANNOTATION): FPDF_BOOL; stdcall;

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
  FPDFAnnot_SetAttachmentPoints: function(annot: FPDF_ANNOTATION; quad_index: SIZE_T; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; stdcall;

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
  FPDFAnnot_AppendAttachmentPoints: function(annot: FPDF_ANNOTATION; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; stdcall;

// Experimental API.
// Get the number of sets of quadpoints of an annotation.
//
//   annot  - handle to an annotation.
//
// Returns the number of sets of quadpoints, or 0 on failure.
var
  FPDFAnnot_CountAttachmentPoints: function(annot: FPDF_ANNOTATION): SIZE_T; stdcall;

// Experimental API.
// Get the attachment points (i.e. quadpoints) of an annotation.
//
//   annot       - handle to an annotation.
//   quad_index  - index of the set of quadpoints.
//   quad_points - receives the quadpoints; must not be NULL.
//
// Returns true if successful.
var
  FPDFAnnot_GetAttachmentPoints: function(annot: FPDF_ANNOTATION; quad_index: SIZE_T; quad_points: PFS_QUADPOINTSF): FPDF_BOOL; stdcall;

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
  FPDFAnnot_SetRect: function(annot: FPDF_ANNOTATION; rect: PFS_RECTF): FPDF_BOOL; stdcall;

// Experimental API.
// Get the annotation rectangle defining the location of the annotation.
//
//   annot  - handle to an annotation.
//   rect   - receives the rectangle; must not be NULL.
//
// Returns true if successful.
var
  FPDFAnnot_GetRect: function(annot: FPDF_ANNOTATION; rect: PFS_RECTF): FPDF_BOOL; stdcall;

// Experimental API.
// Check if |annot|'s dictionary has |key| as a key.
//
//   annot  - handle to an annotation.
//   key    - the key to look for, encoded in UTF-8.
//
// Returns true if |key| exists.
var
  FPDFAnnot_HasKey: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING): FPDF_BOOL; stdcall;

// Experimental API.
// Get the type of the value corresponding to |key| in |annot|'s dictionary.
//
//   annot  - handle to an annotation.
//   key    - the key to look for, encoded in UTF-8.
//
// Returns the type of the dictionary value.
var
  FPDFAnnot_GetValueType: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING): FPDF_OBJECT_TYPE; stdcall;

// Experimental API.
// Set the string value corresponding to |key| in |annot|'s dictionary,
// overwriting the existing value if any. The value type would be
// FPDF_OBJECT_STRING after this function call succeeds.
//
//   annot  - handle to an annotation.
//   key    - the key to the dictionary entry to be set, encoded in UTF-8.
//   value  - the string value to be set, encoded in UTF16-LE.
//
// Returns true if successful.
var
  FPDFAnnot_SetStringValue: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING; value: FPDF_WIDESTRING): FPDF_BOOL; stdcall;

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
//   buffer - buffer for holding the value string, encoded in UTF16-LE.
//   buflen - length of the buffer.
//
// Returns the length of the string value.
var
  FPDFAnnot_GetStringValue: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING; buffer: Pointer; buglen: LongWord): LongWord; stdcall;

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
  FPDFAnnot_GetNumberValue: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING; value: PSingle): FPDF_BOOL; stdcall;

// Experimental API.
// Set the AP (appearance string) in |annot|'s dictionary for a given
// |appearanceMode|.
//
//   annot          - handle to an annotation.
//   appearanceMode - the appearance mode (normal, rollover or down) for which
//                    to get the AP.
//   value          - the string value to be set, encoded in UTF16-LE. If
//                    nullptr is passed, the AP is cleared for that mode. If the
//                    mode is Normal, APs for all modes are cleared.
//
// Returns true if successful.
var
  FPDFAnnot_SetAP: function(annot: FPDF_ANNOTATION; appearanceMode: FPDF_ANNOT_APPEARANCEMODE; value: FPDF_WIDESTRING): FPDF_BOOL; stdcall;

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
//   buffer         - buffer for holding the value string, encoded in UTF16-LE.
//   buflen         - length of the buffer.
//
// Returns the length of the string value.
var
  FPDFAnnot_GetAP: function(annot: FPDF_ANNOTATION; appearanceMode: FPDF_ANNOT_APPEARANCEMODE; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

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
  FPDFAnnot_GetLinkedAnnot: function(annot: FPDF_ANNOTATION; key: FPDF_BYTESTRING): FPDF_ANNOTATION; stdcall;

// Experimental API.
// Get the annotation flags of |annot|.
//
//   annot    - handle to an annotation.
//
// Returns the annotation flags.
var
  FPDFAnnot_GetFlags: function(annot: FPDF_ANNOTATION): Integer; stdcall;

// Experimental API.
// Set the |annot|'s flags to be of the value |flags|.
//
//   annot      - handle to an annotation.
//   flags      - the flag values to be set.
//
// Returns true if successful.
var
  FPDFAnnot_SetFlags: function(annot: FPDF_ANNOTATION; flags: Integer): FPDF_BOOL; stdcall;

// Experimental API.
// Get the annotation flags of |annot|, which is an interactive form
// annotation in |page|.
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    page        -   handle to a page.
//    annot       -   handle to an interactive form annotation.
//
// Returns the annotation flags specific to interactive forms.
var
  FPDFAnnot_GetFormFieldFlags: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; annot: FPDF_ANNOTATION): Integer; stdcall;

// Experimental API.
// Retrieves an interactive form annotation whose rectangle contains a given
// point on a page. Must call FPDFPage_CloseAnnot() when the annotation returned
// is no longer needed.
//
//
//    hHandle     -   handle to the form fill module, returned by
//                    FPDFDOC_InitFormFillEnvironment().
//    page        -   handle to the page, returned by FPDF_LoadPage function.
//    page_x      -   X position in PDF "user space".
//    page_y      -   Y position in PDF "user space".
//
// Returns the interactive form annotation whose rectangle contains the given
// coordinates on the page. If there is no such annotation, return NULL.
var
  FPDFAnnot_GetFormFieldAtPoint: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; page_x, page_y: Double): FPDF_ANNOTATION; stdcall;

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
  FPDFAnnot_GetOptionCount: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION): Integer; stdcall;

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
//   buffer  - buffer for holding the value string, encoded in UTF16-LE.
//   buflen  - length of the buffer.
//
// Returns the length of the string value or 0 if annot does not have "Opt"
// array, index is out of range or other error.
var
  FPDFAnnot_GetOptionLabel: function(hHandle: FPDF_FORMHANDLE; annot: FPDF_ANNOTATION; index: Integer; buffer: Pointer; buflen: LongWord): LongWord; stdcall;


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
  FPDFCatalog_IsTagged: function(document: FPDF_DOCUMENT): FPDF_BOOL; stdcall;


// *** _FPDF_ATTACHMENT_H_ ***

// Experimental API.
// Get the number of embedded files in |document|.
//
//   document - handle to a document.
//
// Returns the number of embedded files in |document|.
var
  FPDFDoc_GetAttachmentCount: function(document: FPDF_DOCUMENT): Integer; stdcall;

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
  FPDFDoc_AddAttachment: function(document: FPDF_DOCUMENT; name: FPDF_WIDESTRING): FPDF_ATTACHMENT; stdcall;

// Experimental API.
// Get the embedded attachment at |index| in |document|. Note that the returned
// attachment handle is only valid while |document| is open.
//
//   document - handle to a document.
//   index    - the index of the requested embedded file.
//
// Returns the handle to the attachment object, or NULL on failure.
var
  FPDFDoc_GetAttachment: function(document: FPDF_DOCUMENT; index: Integer): FPDF_ATTACHMENT; stdcall;

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
  FPDFDoc_DeleteAttachment: function(document: FPDF_DOCUMENT; index: Integer): FPDF_BOOL; stdcall;

// Experimental API.
// Get the name of the |attachment| file. |buffer| is only modified if |buflen|
// is longer than the length of the file name. On errors, |buffer| is unmodified
// and the returned length is 0.
//
//   attachment - handle to an attachment.
//   buffer     - buffer for holding the file name, encoded in UTF16-LE.
//   buflen     - length of the buffer.
//
// Returns the length of the file name.
var
  FPDFAttachment_GetName: function(attachment: FPDF_ATTACHMENT; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

// Experimental API.
// Check if the params dictionary of |attachment| has |key| as a key.
//
//   attachment - handle to an attachment.
//   key        - the key to look for, encoded in UTF-8.
//
// Returns true if |key| exists.
var
  FPDFAttachment_HasKey: function(attachment: FPDF_ATTACHMENT; key: FPDF_BYTESTRING): FPDF_BOOL; stdcall;

// Experimental API.
// Get the type of the value corresponding to |key| in the params dictionary of
// the embedded |attachment|.
//
//   attachment - handle to an attachment.
//   key        - the key to look for, encoded in UTF-8.
//
// Returns the type of the dictionary value.
var
  FPDFAttachment_GetValueType: function(attachment: FPDF_ATTACHMENT; key: FPDF_BYTESTRING): FPDF_OBJECT_TYPE; stdcall;

// Experimental API.
// Set the string value corresponding to |key| in the params dictionary of the
// embedded file |attachment|, overwriting the existing value if any. The value
// type should be FPDF_OBJECT_STRING after this function call succeeds.
//
//   attachment - handle to an attachment.
//   key        - the key to the dictionary entry, encoded in UTF-8.
//   value      - the string value to be set, encoded in UTF16-LE.
//
// Returns true if successful.
var
  FPDFAttachment_SetStringValue: function(attachment: FPDF_ATTACHMENT; key: FPDF_BYTESTRING;
    value: FPDF_WIDESTRING): FPDF_BOOL; stdcall;

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
//   buffer     - buffer for holding the string value encoded in UTF16-LE.
//   buflen     - length of the buffer.
//
// Returns the length of the dictionary value string.
var
  FPDFAttachment_GetStringValue: function(attachment: FPDF_ATTACHMENT; key: FPDF_BYTESTRING; buffer: Pointer;
    buflen: LongWord): LongWord; stdcall;

// Experimental API.
// Set the file data of |attachment|, overwriting the existing file data if any.
// The creation date and checksum will be updated, while all other dictionary
// entries will be deleted. Note that only contents with |len| smaller than
// INT_MAX is supported.
//
//   attachment - handle to an attachment.
//   contents   - buffer holding the file data to be written in raw bytes.
//   len        - length of file data.
//
// Returns true if successful.
var
  FPDFAttachment_SetFile: function(attachment: FPDF_ATTACHMENT; document: FPDF_DOCUMENT;
    contents: Pointer; const len: LongWord): FPDF_BOOL; stdcall;

// Experimental API.
// Get the file data of |attachment|. |buffer| is only modified if |buflen| is
// longer than the length of the file. On errors, |buffer| is unmodified and the
// returned length is 0.
//
//   attachment - handle to an attachment.
//   buffer     - buffer for holding the file data in raw bytes.
//   buflen     - length of the buffer.
//
// Returns the length of the file.
var
  FPDFAttachment_GetFile: function(attachment: FPDF_ATTACHMENT; buffer: Pointer; buflen: LongWord): LongWord; stdcall;


// *** _FPDF_FWLEVENT_H_ ***
type
  FPDF_INT32 = Int32;
  FPDF_UINT32 = DWORD;
  FPDF_FLOAT = Single;

  // Event types.
  FWL_EVENTTYPE = (
    FWL_EVENTTYPE_Mouse = 0,
    FWL_EVENTTYPE_MouseWheel,
    FWL_EVENTTYPE_Key
  );

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

// Mouse messages.
type
  FWL_EVENT_MOUSECMD = (
    FWL_EVENTMOUSECMD_LButtonDown = 1,
    FWL_EVENTMOUSECMD_LButtonUp,
    FWL_EVENTMOUSECMD_LButtonDblClk,
    FWL_EVENTMOUSECMD_RButtonDown,
    FWL_EVENTMOUSECMD_RButtonUp,
    FWL_EVENTMOUSECMD_RButtonDblClk,
    FWL_EVENTMOUSECMD_MButtonDown,
    FWL_EVENTMOUSECMD_MButtonUp,
    FWL_EVENTMOUSECMD_MButtonDblClk,
    FWL_EVENTMOUSECMD_MouseMove,
    FWL_EVENTMOUSECMD_MouseEnter,
    FWL_EVENTMOUSECMD_MouseHover,
    FWL_EVENTMOUSECMD_MouseLeave
  );

  // Mouse events.
  PFWL_EVENT_MOUSE = ^FWL_EVENT_MOUSE;
  FWL_EVENT_MOUSE = record
    command: FPDF_UINT32;
    flag: FPDF_DWORD;
    x: FPDF_FLOAT;
    y: FPDF_FLOAT;
  end;
  PFwlEventMouse = ^TFwlEventMouse;
  TFwlEventMouse = FWL_EVENT_MOUSE;

  // Mouse wheel events.
  PFWL_EVENT_MOUSEWHEEL = ^FWL_EVENT_MOUSEWHEEL;
  FWL_EVENT_MOUSEWHEEL = record
    flag: FPDF_DWORD;
    x: FPDF_FLOAT;
    y: FPDF_FLOAT;
    deltaX: FPDF_FLOAT;
    deltaY: FPDF_FLOAT;
  end;
  PFwlEventMouseWheel = ^TFwlEventMouseWheel;
  TFwlEventMouseWheel = FWL_EVENT_MOUSEWHEEL;

  FWL_VKEYCODE = Integer; // note: FWL_VKEY_* equals Windows.VK_*

  // Key event commands.
  FWL_EVENTKEYCMD = (
    FWL_EVENTKEYCMD_KeyDown = 1,
    FWL_EVENTKEYCMD_KeyUp,
    FWL_EVENTKEYCMD_Char
  );

  // Key events.
  PFWL_EVENT_KEY = ^FWL_EVENT_KEY;
  FWL_EVENT_KEY = record
    command: FPDF_UINT32;
    flag: FPDF_DWORD;
    code: record
            case Integer of
              // Virtual key code.
              0: (vkcode: FPDF_UINT32);
              // Character code.
              1: (charcode: FPDF_DWORD);
          end;
  end;
  PFwlEventKey = ^TFwlEventKey;
  TFwlEventKey = FWL_EVENT_KEY;

  // Event types.
  PFWL_EVENT = ^FWL_EVENT;
  FWL_EVENT = record
    // Structure size.
    size: FPDF_UINT32;
    // FWL_EVENTTYPE.
    type_: FPDF_UINT32;
    s: record
         case Integer of
           0: (mouse: FWL_EVENT_MOUSE);
           1: (wheel: FWL_EVENT_MOUSEWHEEL);
           2: (key: FWL_EVENT_KEY);
       end;
  end;
  PFwlEvent = ^TFwlEvent;
  TFwlEvent = FWL_EVENT;



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
  FPDFPage_SetMediaBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); stdcall;

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
  FPDFPage_SetCropBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); stdcall;

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
  FPDFPage_SetBleedBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); stdcall;


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
  FPDFPage_SetTrimBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); stdcall;


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
  FPDFPage_SetArtBox: procedure(page: FPDF_PAGE; left, bottom, right, top: Single); stdcall;

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
  FPDFPage_GetMediaBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); stdcall;

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
  FPDFPage_GetCropBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); stdcall;

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
  FPDFPage_GetBleedBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); stdcall;

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
  FPDFPage_GetTrimBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); stdcall;

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
  FPDFPage_GetArtBox: procedure(page: FPDF_PAGE; var left, bottom, right, top: Single); stdcall;

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
  FPDFPage_TransFormWithClip: function(page: FPDF_PAGE; matrix: PFS_MATRIX; clipRect: PFS_RECTF): FPDF_BOOL; stdcall;

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
  FPDFPageObj_TransformClipPath: procedure(page_object: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double); stdcall;

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
  FPDF_CreateClipPath: function(page_object: FPDF_PAGEOBJECT; left, bottom, right, top: Single): FPDF_CLIPPATH; stdcall;

//**
//* Destroy the clip path.
//*
//* clipPath - A handle to the clip path. It will be invalid after this call.
//*
var
  FPDF_DestroyClipPath: procedure(clipPath: FPDF_CLIPPATH); stdcall;

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
  FPDFPage_InsertClipPath: procedure(page: FPDF_PAGE; clipPath: FPDF_CLIPPATH); stdcall;


// *** _FPDF_STRUCTTREE_H_ ***

// Function: FPDF_StructTree_GetForPage
//          Get the structure tree for a page.
// Parameters:
//          page        -   Handle to the page. Returned by FPDF_LoadPage
//          function.
// Return value:
//          A handle to the structure tree or NULL on error.
var
  FPDF_StructTree_GetForPage: function(page: FPDF_PAGE): FPDF_STRUCTTREE; stdcall;

// Function: FPDF_StructTree_Close
//          Release the resource allocate by FPDF_StructTree_GetForPage.
// Parameters:
//          struct_tree -   Handle to the struct tree. Returned by
//          FPDF_StructTree_LoadPage function.
// Return value:
//          NULL
var
  FPDF_StructTree_Close: procedure(struct_tree: FPDF_STRUCTTREE); stdcall;

// Function: FPDF_StructTree_CountChildren
//          Count the number of children for the structure tree.
// Parameters:
//          struct_tree -   Handle to the struct tree. Returned by
//          FPDF_StructTree_LoadPage function.
// Return value:
//          The number of children, or -1 on error.
var
  FPDF_StructTree_CountChildren: function(struct_tree: FPDF_STRUCTTREE): Integer; stdcall;

// Function: FPDF_StructTree_GetChildAtIndex
//          Get a child in the structure tree.
// Parameters:
//          struct_tree -   Handle to the struct tree. Returned by
//          FPDF_StructTree_LoadPage function.
//          index       -   The index for the child, 0-based.
// Return value:
//          The child at the n-th index or NULL on error.
var
  FPDF_StructTree_GetChildAtIndex: function(struct_tree: FPDF_STRUCTTREE; index: Integer): FPDF_STRUCTELEMENT; stdcall;

// Function: FPDF_StructElement_GetAltText
//          Get the alt text for a given element.
// Parameters:
//          struct_element -   Handle to the struct element.
//          buffer         -   A buffer for output the alt text. May be NULL.
//          buflen         -   The length of the buffer, in bytes. May be 0.
// Return value:
//          The number of bytes in the title, including the terminating NUL
//          character. The number of bytes is returned regardless of the
//          |buffer| and |buflen| parameters.
// Comments:
//          Regardless of the platform, the |buffer| is always in UTF-16LE
//          encoding. The string is terminated by a UTF16 NUL character. If
//          |buflen| is less than the required length, or |buffer| is NULL,
//          |buffer| will not be modified.
var
  FPDF_StructElement_GetAltText: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

// Function: FPDF_StructElement_GetMarkedContentID
//          Get the marked content ID for a given element.
// Parameters:
//          struct_element -   Handle to the struct element.
// Return value:
//          The marked content ID of the element. If no ID exists, returns
//          -1.
var
  FPDF_StructElement_GetMarkedContentID: function(struct_element: FPDF_STRUCTELEMENT): Integer; stdcall;

// Function: FPDF_StructElement_GetType
//           Get the type (/S) for a given element.
// Parameters:
//           struct_element - Handle to the struct element.
//           buffer        - A buffer for output. May be NULL.
//           buflen        - The length of the buffer, in bytes. May be 0.
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
  FPDF_StructElement_GetType: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

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
  FPDF_StructElement_GetTitle: function(struct_element: FPDF_STRUCTELEMENT; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

// Function: FPDF_StructElement_CountChildren
//          Count the number of children for the structure element.
// Parameters:
//          struct_element -   Handle to the struct element.
// Return value:
//          The number of children, or -1 on error.
var
  FPDF_StructElement_CountChildren: function(struct_element: FPDF_STRUCTELEMENT): Integer; stdcall;

// Function: FPDF_StructElement_GetChildAtIndex
//          Get a child in the structure element.
// Parameters:
//          struct_tree -   Handle to the struct element.
//          index       -   The index for the child, 0-based.
// Return value:
//          The child at the n-th index or NULL on error.
// Comments:
//          If the child exists but is not an element, then this function will
//          return NULL. This will also return NULL for out of bounds indices.
var
  FPDF_StructElement_GetChildAtIndex: function(struct_element: FPDF_STRUCTELEMENT; index: Integer): FPDF_STRUCTELEMENT; stdcall;


// ***********************************************************************

procedure InitPDFium(const DllPath: string = '');

implementation

uses
  SysUtils;

resourcestring
  RsFailedToLoadProc = 'Symbol "%s" was not found in pdfium.dll';
  RsPdfiumNotLoaded = 'pdfium.dll is not loaded';

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
    N: PAnsiChar;
    Quirk: Boolean; // True: if the symbol can't be found, no exception is raised
                    // (used if the symbol's name has changed and both DLL versions should be supported)
  end;

const
  {$IFDEF CPUX64}
  UC = '';
  AT0 = '';
  AT4 = '';
  AT8 = '';
  AT12 = '';
  AT16 = '';
  AT20 = '';
  AT24 = '';
  AT28 = '';
  AT32 = '';
  AT36 = '';
  AT40 = '';
  AT44 = '';
  AT48 = '';
  AT52 = '';
  {$ELSE}
  UC = '_';
  AT0 = '@0';
  AT4 = '@4';
  AT8 = '@8';
  AT12 = '@12';
  AT16 = '@16';
  AT20 = '@20';
  AT24 = '@24';
  AT28 = '@28';
  AT32 = '@32';
  AT36 = '@36';
  AT40 = '@40';
  AT44 = '@44';
  AT48 = '@48';
  AT52 = '@52';
  {$ENDIF CPUX64}

  ImportFuncs: array[0..307
    {$IFDEF MSWINDOWS}
    + 2
      {$IFDEF PDFIUM_PRINT_TEXT_WITH_GDI} + 2 {$ENDIF}
      {$IFDEF _SKIA_SUPPORT_            } + 2 {$ENDIF}
      {$IFDEF PDF_ENABLE_V8             } + 1 {$ENDIF}
      {$IFDEF PDF_ENABLE_XFA            } + 6 {$ENDIF}
    {$ENDIF}
    ] of TImportFuncRec = (

    // *** _FPDFVIEW_H_ ***
    (P: @@FPDF_InitLibrary;                   N: UC + 'FPDF_InitLibrary' + AT0),
    (P: @@FPDF_InitLibraryWithConfig;         N: UC + 'FPDF_InitLibraryWithConfig' + AT4),
    (P: @@FPDF_DestroyLibrary;                N: UC + 'FPDF_DestroyLibrary' + AT0),
    (P: @@FPDF_SetSandBoxPolicy;              N: UC + 'FPDF_SetSandBoxPolicy' + AT8),
    {$IFDEF MSWINDOWS}
      {$IFDEF PDFIUM_PRINT_TEXT_WITH_GDI}
    (P: @@FPDF_SetTypefaceAccessibleFunc;     N: UC + 'FPDF_SetTypefaceAccessibleFunc' + AT4),
    (P: @@FPDF_SetPrintTextWithGDI;           N: UC + 'FPDF_SetPrintTextWithGDI' + AT4),
      {$ENDIF PDFIUM_PRINT_TEXT_WITH_GDI}
    (P: @@FPDF_SetPrintMode;                  N: UC + 'FPDF_SetPrintMode' + AT4),
    {$ENDIF MSWINDOWS}
    (P: @@FPDF_LoadDocument;                  N: UC + 'FPDF_LoadDocument' + AT8),
    (P: @@FPDF_LoadMemDocument;               N: UC + 'FPDF_LoadMemDocument' + AT12),
    (P: @@FPDF_LoadCustomDocument;            N: UC + 'FPDF_LoadCustomDocument' + AT8),
    (P: @@FPDF_GetFileVersion;                N: UC + 'FPDF_GetFileVersion' + AT8),
    (P: @@FPDF_GetLastError;                  N: UC + 'FPDF_GetLastError' + AT0),
    (P: @@FPDF_DocumentHasValidCrossReferenceTable; N: UC + 'FPDF_DocumentHasValidCrossReferenceTable' + AT4),
    (P: @@FPDF_GetDocPermissions;             N: UC + 'FPDF_GetDocPermissions' + AT4),
    (P: @@FPDF_GetSecurityHandlerRevision;    N: UC + 'FPDF_GetSecurityHandlerRevision' + AT4),
    (P: @@FPDF_GetPageCount;                  N: UC + 'FPDF_GetPageCount' + AT4),
    (P: @@FPDF_LoadPage;                      N: UC + 'FPDF_LoadPage' + AT8),
    (P: @@FPDF_GetPageWidth;                  N: UC + 'FPDF_GetPageWidth' + AT4),
    (P: @@FPDF_GetPageHeight;                 N: UC + 'FPDF_GetPageHeight' + AT4),
    (P: @@FPDF_GetPageBoundingBox;            N: UC + 'FPDF_GetPageBoundingBox' + AT8),
    (P: @@FPDF_GetPageSizeByIndex;            N: UC + 'FPDF_GetPageSizeByIndex' + AT16),
    {$IFDEF MSWINDOWS}
    (P: @@FPDF_RenderPage;                    N: UC + 'FPDF_RenderPage' + AT32),
    {$ENDIF MSWINDOWS}
    (P: @@FPDF_RenderPageBitmap;              N: UC + 'FPDF_RenderPageBitmap' + AT32),
    (P: @@FPDF_RenderPageBitmapWithMatrix;    N: UC + 'FPDF_RenderPageBitmapWithMatrix' + AT20),
    {$IFDEF _SKIA_SUPPORT_}
    (P: @@FPDF_RenderPageSkp;                 N: UC + 'FPDF_RenderPageSkp' + AT12),
    {$ENDIF _SKIA_SUPPORT_}
    (P: @@FPDF_ClosePage;                     N: UC + 'FPDF_ClosePage' + AT4),
    (P: @@FPDF_CloseDocument;                 N: UC + 'FPDF_CloseDocument' + AT4),
    (P: @@FPDF_DeviceToPage;                  N: UC + 'FPDF_DeviceToPage' + AT40),
    (P: @@FPDF_PageToDevice;                  N: UC + 'FPDF_PageToDevice' + AT48),
    (P: @@FPDFBitmap_Create;                  N: UC + 'FPDFBitmap_Create' + AT12),
    (P: @@FPDFBitmap_CreateEx;                N: UC + 'FPDFBitmap_CreateEx' + AT20),
    (P: @@FPDFBitmap_GetFormat;               N: UC + 'FPDFBitmap_GetFormat' + AT4),
    (P: @@FPDFBitmap_FillRect;                N: UC + 'FPDFBitmap_FillRect' + AT24),
    (P: @@FPDFBitmap_GetBuffer;               N: UC + 'FPDFBitmap_GetBuffer' + AT4),
    (P: @@FPDFBitmap_GetWidth;                N: UC + 'FPDFBitmap_GetWidth' + AT4),
    (P: @@FPDFBitmap_GetHeight;               N: UC + 'FPDFBitmap_GetHeight' + AT4),
    (P: @@FPDFBitmap_GetStride;               N: UC + 'FPDFBitmap_GetStride' + AT4),
    (P: @@FPDFBitmap_Destroy;                 N: UC + 'FPDFBitmap_Destroy' + AT4),
    (P: @@FPDF_VIEWERREF_GetPrintScaling;     N: UC + 'FPDF_VIEWERREF_GetPrintScaling' + AT4),
    (P: @@FPDF_VIEWERREF_GetNumCopies;        N: UC + 'FPDF_VIEWERREF_GetNumCopies' + AT4),
    (P: @@FPDF_VIEWERREF_GetPrintPageRange;   N: UC + 'FPDF_VIEWERREF_GetPrintPageRange' + AT4),
    (P: @@FPDF_VIEWERREF_GetPrintPageRangeCount;   N: UC + 'FPDF_VIEWERREF_GetPrintPageRangeCount' + AT4),
    (P: @@FPDF_VIEWERREF_GetPrintPageRangeElement; N: UC + 'FPDF_VIEWERREF_GetPrintPageRangeElement' + AT8),
    (P: @@FPDF_VIEWERREF_GetDuplex;           N: UC + 'FPDF_VIEWERREF_GetDuplex' + AT4),
    (P: @@FPDF_VIEWERREF_GetName;             N: UC + 'FPDF_VIEWERREF_GetName' + AT16),
    (P: @@FPDF_CountNamedDests;               N: UC + 'FPDF_CountNamedDests' + AT4),
    (P: @@FPDF_GetNamedDestByName;            N: UC + 'FPDF_GetNamedDestByName' + AT8),
    (P: @@FPDF_GetNamedDest;                  N: UC + 'FPDF_GetNamedDest' + AT16),
    {$IFDEF PDF_ENABLE_V8}
    (P: @@FPDF_GetRecommendedV8Flags;         N: UC + 'FPDF_GetRecommendedV8Flags' + AT0),
    {$ENDIF PDF_ENABLE_V8}
    {$IFDEF PDF_ENABLE_XFA}
    (P: @@FPDF_BStr_Init;                     N: UC + 'FPDF_BStr_Init' + AT4),
    (P: @@FPDF_BStr_Set;                      N: UC + 'FPDF_BStr_Set' + AT12),
    (P: @@FPDF_BStr_Clear;                    N: UC + 'FPDF_BStr_Clear' + AT4),
    {$ENDIF PDF_ENABLE_XFA}

    // *** _FPDF_EDIT_H_ ***
    (P: @@FPDF_CreateNewDocument;             N: UC + 'FPDF_CreateNewDocument' + AT0),
    (P: @@FPDFPage_New;                       N: UC + 'FPDFPage_New' + AT24),
    (P: @@FPDFPage_Delete;                    N: UC + 'FPDFPage_Delete' + AT8),
    (P: @@FPDFPage_GetRotation;               N: UC + 'FPDFPage_GetRotation' + AT4),
    (P: @@FPDFPage_SetRotation;               N: UC + 'FPDFPage_SetRotation' + AT8),
    (P: @@FPDFPage_InsertObject;              N: UC + 'FPDFPage_InsertObject' + AT8),
    (P: @@FPDFPage_RemoveObject;              N: UC + 'FPDFPage_RemoveObject' + AT8),
    (P: @@FPDFPage_CountObjects;              N: UC + 'FPDFPage_CountObjects' + AT4),
    (P: @@FPDFPage_GetObject;                 N: UC + 'FPDFPage_GetObject' + AT8),
    (P: @@FPDFPage_HasTransparency;           N: UC + 'FPDFPage_HasTransparency' + AT4),
    (P: @@FPDFPage_GenerateContent;           N: UC + 'FPDFPage_GenerateContent' + AT4),
    (P: @@FPDFPageObj_Destroy;                N: UC + 'FPDFPageObj_Destroy' + AT4),
    (P: @@FPDFPageObj_HasTransparency;        N: UC + 'FPDFPageObj_HasTransparency' + AT4),
    (P: @@FPDFPageObj_GetType;                N: UC + 'FPDFPageObj_GetType' + AT4),
    (P: @@FPDFPageObj_Transform;              N: UC + 'FPDFPageObj_Transform' + AT52),
    (P: @@FPDFPage_TransformAnnots;           N: UC + 'FPDFPage_TransformAnnots' + AT52),
    (P: @@FPDFPageObj_NewImageObj;            N: UC + 'FPDFPageObj_NewImageObj' + AT4),
    (P: @@FPDFPageObj_CountMarks;             N: UC + 'FPDFPageObj_CountMarks' + AT4),
    (P: @@FPDFPageObj_GetMark;                N: UC + 'FPDFPageObj_GetMark' + AT8),
    (P: @@FPDFPageObj_AddMark;                N: UC + 'FPDFPageObj_AddMark' + AT8),
    (P: @@FPDFPageObj_RemoveMark;             N: UC + 'FPDFPageObj_RemoveMark' + AT8),
    (P: @@FPDFPageObjMark_GetName;            N: UC + 'FPDFPageObjMark_GetName' + AT16),
    (P: @@FPDFPageObjMark_CountParams;        N: UC + 'FPDFPageObjMark_CountParams' + AT4),
    (P: @@FPDFPageObjMark_GetParamKey;        N: UC + 'FPDFPageObjMark_GetParamKey' + AT20),
    (P: @@FPDFPageObjMark_GetParamValueType;  N: UC + 'FPDFPageObjMark_GetParamValueType' + AT8),
    (P: @@FPDFPageObjMark_GetParamIntValue;   N: UC + 'FPDFPageObjMark_GetParamIntValue' + AT12),
    (P: @@FPDFPageObjMark_GetParamStringValue;N: UC + 'FPDFPageObjMark_GetParamStringValue' + AT20),
    (P: @@FPDFPageObjMark_GetParamBlobValue;  N: UC + 'FPDFPageObjMark_GetParamBlobValue' + AT20),
    (P: @@FPDFPageObjMark_SetIntParam;        N: UC + 'FPDFPageObjMark_SetIntParam' + AT20),
    (P: @@FPDFPageObjMark_SetStringParam;     N: UC + 'FPDFPageObjMark_SetStringParam' + AT20),
    (P: @@FPDFPageObjMark_SetBlobParam;       N: UC + 'FPDFPageObjMark_SetBlobParam' + AT24),
    (P: @@FPDFPageObjMark_RemoveParam;        N: UC + 'FPDFPageObjMark_RemoveParam' + AT12),
    (P: @@FPDFImageObj_LoadJpegFile;          N: UC + 'FPDFImageObj_LoadJpegFile' + AT16),
    (P: @@FPDFImageObj_LoadJpegFileInline;    N: UC + 'FPDFImageObj_LoadJpegFileInline' + AT16),
    (P: @@FPDFImageObj_GetMatrix;             N: UC + 'FPDFImageObj_GetMatrix' + AT28),
    (P: @@FPDFImageObj_SetMatrix;             N: UC + 'FPDFImageObj_SetMatrix' + AT52),
    (P: @@FPDFImageObj_SetBitmap;             N: UC + 'FPDFImageObj_SetBitmap' + AT16),
    (P: @@FPDFImageObj_GetBitmap;             N: UC + 'FPDFImageObj_GetBitmap' + AT4),
    (P: @@FPDFImageObj_GetImageDataDecoded;   N: UC + 'FPDFImageObj_GetImageDataDecoded' + AT12),
    (P: @@FPDFImageObj_GetImageDataRaw;       N: UC + 'FPDFImageObj_GetImageDataRaw' + AT12),
    (P: @@FPDFImageObj_GetImageFilterCount;   N: UC + 'FPDFImageObj_GetImageFilterCount' + AT4),
    (P: @@FPDFImageObj_GetImageFilter;        N: UC + 'FPDFImageObj_GetImageFilter' + AT16),
    (P: @@FPDFImageObj_GetImageMetadata;      N: UC + 'FPDFImageObj_GetImageMetadata' + AT12),
    (P: @@FPDFPageObj_CreateNewPath;          N: UC + 'FPDFPageObj_CreateNewPath' + AT8),
    (P: @@FPDFPageObj_CreateNewRect;          N: UC + 'FPDFPageObj_CreateNewRect' + AT16),
    (P: @@FPDFPageObj_GetBounds;              N: UC + 'FPDFPageObj_GetBounds' + AT20),
    (P: @@FPDFPageObj_SetBlendMode;           N: UC + 'FPDFPageObj_SetBlendMode' + AT8),
    (P: @@FPDFPageObj_SetStrokeColor;         N: UC + 'FPDFPageObj_SetStrokeColor' + AT20),
    (P: @@FPDFPageObj_GetStrokeColor;         N: UC + 'FPDFPageObj_GetStrokeColor' + AT20),
    (P: @@FPDFPageObj_SetStrokeWidth;         N: UC + 'FPDFPageObj_SetStrokeWidth' + AT8),
    (P: @@FPDFPageObj_GetStrokeWidth;         N: UC + 'FPDFPageObj_GetStrokeWidth' + AT8),
    (P: @@FPDFPageObj_GetLineJoin;            N: UC + 'FPDFPageObj_GetLineJoin' + AT4),
    (P: @@FPDFPageObj_SetLineJoin;            N: UC + 'FPDFPageObj_SetLineJoin' + AT8),
    (P: @@FPDFPageObj_GetLineCap;             N: UC + 'FPDFPageObj_GetLineCap' + AT4),
    (P: @@FPDFPageObj_SetLineCap;             N: UC + 'FPDFPageObj_SetLineCap' + AT8),
    (P: @@FPDFPageObj_SetFillColor;           N: UC + 'FPDFPageObj_SetFillColor' + AT20),
    (P: @@FPDFPageObj_GetFillColor;           N: UC + 'FPDFPageObj_GetFillColor' + AT20),
    (P: @@FPDFPath_CountSegments;             N: UC + 'FPDFPath_CountSegments' + AT4),
    (P: @@FPDFPath_GetPathSegment;            N: UC + 'FPDFPath_GetPathSegment' + AT8),
    (P: @@FPDFPathSegment_GetPoint;           N: UC + 'FPDFPathSegment_GetPoint' + AT12),
    (P: @@FPDFPathSegment_GetType;            N: UC + 'FPDFPathSegment_GetType' + AT4),
    (P: @@FPDFPathSegment_GetClose;           N: UC + 'FPDFPathSegment_GetClose' + AT4),
    (P: @@FPDFPath_MoveTo;                    N: UC + 'FPDFPath_MoveTo' + AT12),
    (P: @@FPDFPath_LineTo;                    N: UC + 'FPDFPath_LineTo' + AT12),
    (P: @@FPDFPath_BezierTo;                  N: UC + 'FPDFPath_BezierTo' + AT28),
    (P: @@FPDFPath_Close;                     N: UC + 'FPDFPath_Close' + AT4),
    (P: @@FPDFPath_SetDrawMode;               N: UC + 'FPDFPath_SetDrawMode' + AT12),
    (P: @@FPDFPath_GetDrawMode;               N: UC + 'FPDFPath_GetDrawMode' + AT12),
    (P: @@FPDFPath_GetMatrix;                 N: UC + 'FPDFPath_GetMatrix' + AT28),
    (P: @@FPDFPath_SetMatrix;                 N: UC + 'FPDFPath_SetMatrix' + AT52),
    (P: @@FPDFPageObj_NewTextObj;             N: UC + 'FPDFPageObj_NewTextObj' + AT12),
    (P: @@FPDFText_SetText;                   N: UC + 'FPDFText_SetText' + AT8),
    (P: @@FPDFText_LoadFont;                  N: UC + 'FPDFText_LoadFont' + AT20),
    (P: @@FPDFText_LoadStandardFont;          N: UC + 'FPDFText_LoadStandardFont' + AT8),
    (P: @@FPDFText_GetMatrix;                 N: UC + 'FPDFText_GetMatrix' + AT28),
    (P: @@FPDFTextObj_GetFontSize;            N: UC + 'FPDFTextObj_GetFontSize' + AT4),
    (P: @@FPDFFont_Close;                     N: UC + 'FPDFFont_Close' + AT4),
    (P: @@FPDFPageObj_CreateTextObj;          N: UC + 'FPDFPageObj_CreateTextObj' + AT12),
    (P: @@FPDFText_GetTextRenderMode;         N: UC + 'FPDFText_GetTextRenderMode' + AT4),
    (P: @@FPDFTextObj_GetFontName;            N: UC + 'FPDFTextObj_GetFontName' + AT12),
    (P: @@FPDFTextObj_GetText;                N: UC + 'FPDFTextObj_GetText' + AT16),
    (P: @@FPDFFormObj_CountObjects;           N: UC + 'FPDFFormObj_CountObjects' + AT4),
    (P: @@FPDFFormObj_GetObject;              N: UC + 'FPDFFormObj_GetObject' + AT8),
    (P: @@FPDFFormObj_GetMatrix;              N: UC + 'FPDFFormObj_GetMatrix' + AT28),

    // *** _FPDF_PPO_H_ ***
    (P: @@FPDF_ImportPages;                   N: UC + 'FPDF_ImportPages' + AT16),
    (P: @@FPDF_ImportNPagesToOne;             N: UC + 'FPDF_ImportNPagesToOne' + AT20),
    (P: @@FPDF_CopyViewerPreferences;         N: UC + 'FPDF_CopyViewerPreferences' + AT8),

    // *** _FPDF_SAVE_H_ ***
    (P: @@FPDF_SaveAsCopy;                    N: UC + 'FPDF_SaveAsCopy' + AT12),
    (P: @@FPDF_SaveWithVersion;               N: UC + 'FPDF_SaveWithVersion' + AT16),

    // *** _FPDFTEXT_H_ ***
    (P: @@FPDFText_LoadPage;                  N: UC + 'FPDFText_LoadPage' + AT4),
    (P: @@FPDFText_ClosePage;                 N: UC + 'FPDFText_ClosePage' + AT4),
    (P: @@FPDFText_CountChars;                N: UC + 'FPDFText_CountChars' + AT4),
    (P: @@FPDFText_GetUnicode;                N: UC + 'FPDFText_GetUnicode' + AT8),
    (P: @@FPDFText_GetFontSize;               N: UC + 'FPDFText_GetFontSize' + AT8),
    (P: @@FPDFText_GetFontInfo;               N: UC + 'FPDFText_GetFontInfo' + AT20),
    (P: @@FPDFText_GetCharBox;                N: UC + 'FPDFText_GetCharBox' + AT24),
    (P: @@FPDFText_GetCharOrigin;             N: UC + 'FPDFText_GetCharOrigin' + AT16),
    (P: @@FPDFText_GetCharIndexAtPos;         N: UC + 'FPDFText_GetCharIndexAtPos' + AT36),
    (P: @@FPDFText_GetText;                   N: UC + 'FPDFText_GetText' + AT16),
    (P: @@FPDFText_CountRects;                N: UC + 'FPDFText_CountRects' + AT12),
    (P: @@FPDFText_GetRect;                   N: UC + 'FPDFText_GetRect' + AT24),
    (P: @@FPDFText_GetBoundedText;            N: UC + 'FPDFText_GetBoundedText' + AT44),
    (P: @@FPDFText_FindStart;                 N: UC + 'FPDFText_FindStart' + AT16),
    (P: @@FPDFText_FindNext;                  N: UC + 'FPDFText_FindNext' + AT4),
    (P: @@FPDFText_FindPrev;                  N: UC + 'FPDFText_FindPrev' + AT4),
    (P: @@FPDFText_GetSchResultIndex;         N: UC + 'FPDFText_GetSchResultIndex' + AT4),
    (P: @@FPDFText_GetSchCount;               N: UC + 'FPDFText_GetSchCount' + AT4),
    (P: @@FPDFText_FindClose;                 N: UC + 'FPDFText_FindClose' + AT4),
    (P: @@FPDFLink_LoadWebLinks;              N: UC + 'FPDFLink_LoadWebLinks' + AT4),
    (P: @@FPDFLink_CountWebLinks;             N: UC + 'FPDFLink_CountWebLinks' + AT4),
    (P: @@FPDFLink_GetURL;                    N: UC + 'FPDFLink_GetURL' + AT16),
    (P: @@FPDFLink_CountRects;                N: UC + 'FPDFLink_CountRects' + AT8),
    (P: @@FPDFLink_GetRect;                   N: UC + 'FPDFLink_GetRect' + AT28),
    (P: @@FPDFLink_CloseWebLinks;             N: UC + 'FPDFLink_CloseWebLinks' + AT4),

    // *** _FPDF_SEARCHEX_H_ ***
    (P: @@FPDFText_GetCharIndexFromTextIndex; N: UC + 'FPDFText_GetCharIndexFromTextIndex' + AT8),
    (P: @@FPDFText_GetTextIndexFromCharIndex; N: UC + 'FPDFText_GetTextIndexFromCharIndex' + AT8),

    // *** _FPDF_PROGRESSIVE_H_ ***
    (P: @@FPDF_RenderPageBitmap_Start;        N: UC + 'FPDF_RenderPageBitmap_Start' + AT36),
    (P: @@FPDF_RenderPage_Continue;           N: UC + 'FPDF_RenderPage_Continue' + AT8),
    (P: @@FPDF_RenderPage_Close;              N: UC + 'FPDF_RenderPage_Close' + AT4),

    // *** _FPDF_FLATTEN_H_ ***
    (P: @@FPDFPage_Flatten;                   N: UC + 'FPDFPage_Flatten' + AT8),

    // *** _FPDF_DOC_H_ ***
    (P: @@FPDFBookmark_GetFirstChild;         N: UC + 'FPDFBookmark_GetFirstChild' + AT8),
    (P: @@FPDFBookmark_GetNextSibling;        N: UC + 'FPDFBookmark_GetNextSibling' + AT8),
    (P: @@FPDFBookmark_GetTitle;              N: UC + 'FPDFBookmark_GetTitle' + AT12),
    (P: @@FPDFBookmark_Find;                  N: UC + 'FPDFBookmark_Find' + AT8),
    (P: @@FPDFBookmark_GetDest;               N: UC + 'FPDFBookmark_GetDest' + AT8),
    (P: @@FPDFBookmark_GetAction;             N: UC + 'FPDFBookmark_GetAction' + AT4),
    (P: @@FPDFAction_GetDest;                 N: UC + 'FPDFAction_GetDest' + AT8),
    (P: @@FPDFAction_GetFilePath;             N: UC + 'FPDFAction_GetFilePath' + AT12),
    (P: @@FPDFAction_GetURIPath;              N: UC + 'FPDFAction_GetURIPath' + AT16),
    (P: @@FPDFDest_GetDestPageIndex;          N: UC + 'FPDFDest_GetDestPageIndex' + AT8),
    (P: @@FPDFDest_GetView;                   N: UC + 'FPDFDest_GetView' + AT12),
    (P: @@FPDFDest_GetLocationInPage;         N: UC + 'FPDFDest_GetLocationInPage' + AT28),
    (P: @@FPDFLink_GetLinkAtPoint;            N: UC + 'FPDFLink_GetLinkAtPoint' + AT20),
    (P: @@FPDFLink_GetLinkZOrderAtPoint;      N: UC + 'FPDFLink_GetLinkZOrderAtPoint' + AT20),
    (P: @@FPDFLink_GetDest;                   N: UC + 'FPDFLink_GetDest' + AT8),
    (P: @@FPDFLink_GetAction;                 N: UC + 'FPDFLink_GetAction' + AT4),
    (P: @@FPDFLink_Enumerate;                 N: UC + 'FPDFLink_Enumerate' + AT12),
    (P: @@FPDFLink_GetAnnotRect;              N: UC + 'FPDFLink_GetAnnotRect' + AT8),
    (P: @@FPDFLink_CountQuadPoints;           N: UC + 'FPDFLink_CountQuadPoints' + AT4),
    (P: @@FPDFLink_GetQuadPoints;             N: UC + 'FPDFLink_GetQuadPoints' + AT12),
    (P: @@FPDF_GetMetaText;                   N: UC + 'FPDF_GetMetaText' + AT16),
    (P: @@FPDF_GetPageLabel;                  N: UC + 'FPDF_GetPageLabel' + AT16),

    // *** _FPDF_SYSFONTINFO_H_ ***
    (P: @@FPDF_GetDefaultTTFMap;              N: UC + 'FPDF_GetDefaultTTFMap' + AT0),
    (P: @@FPDF_AddInstalledFont;              N: UC + 'FPDF_AddInstalledFont' + AT12),
    (P: @@FPDF_SetSystemFontInfo;             N: UC + 'FPDF_SetSystemFontInfo' + AT4),
    (P: @@FPDF_GetDefaultSystemFontInfo;      N: UC + 'FPDF_GetDefaultSystemFontInfo' + AT0),
    (P: @@FPDFDoc_GetPageMode;                N: UC + 'FPDFDoc_GetPageMode' + AT4),

    // *** _FPDF_EXT_H_ ***
    (P: @@FSDK_SetUnSpObjProcessHandler;      N: UC + 'FSDK_SetUnSpObjProcessHandler' + AT4),
    (P: @@FSDK_SetTimeFunction;               N: UC + 'FSDK_SetTimeFunction' + AT4),
    (P: @@FSDK_SetLocaltimeFunction;          N: UC + 'FSDK_SetLocaltimeFunction' + AT4),

    // *** _FPDF_DATAAVAIL_H_ ***
    (P: @@FPDFAvail_Create;                   N: UC + 'FPDFAvail_Create' + AT8),
    (P: @@FPDFAvail_Destroy;                  N: UC + 'FPDFAvail_Destroy' + AT4),
    (P: @@FPDFAvail_IsDocAvail;               N: UC + 'FPDFAvail_IsDocAvail' + AT8),
    (P: @@FPDFAvail_GetDocument;              N: UC + 'FPDFAvail_GetDocument' + AT8),
    (P: @@FPDFAvail_GetFirstPageNum;          N: UC + 'FPDFAvail_GetFirstPageNum' + AT4),
    (P: @@FPDFAvail_IsPageAvail;              N: UC + 'FPDFAvail_IsPageAvail' + AT12),
    (P: @@FPDFAvail_IsFormAvail;              N: UC + 'FPDFAvail_IsFormAvail' + AT8),
    (P: @@FPDFAvail_IsLinearized;             N: UC + 'FPDFAvail_IsLinearized' + AT4),

    // *** _FPD_FORMFILL_H ***
    (P: @@FPDFDOC_InitFormFillEnvironment;    N: UC + 'FPDFDOC_InitFormFillEnvironment' + AT8),
    (P: @@FPDFDOC_ExitFormFillEnvironment;    N: UC + 'FPDFDOC_ExitFormFillEnvironment' + AT4),
    (P: @@FORM_OnAfterLoadPage;               N: UC + 'FORM_OnAfterLoadPage' + AT8),
    (P: @@FORM_OnBeforeClosePage;             N: UC + 'FORM_OnBeforeClosePage' + AT8),
    (P: @@FORM_DoDocumentJSAction;            N: UC + 'FORM_DoDocumentJSAction' + AT4),
    (P: @@FORM_DoDocumentOpenAction;          N: UC + 'FORM_DoDocumentOpenAction' + AT4),
    (P: @@FORM_DoDocumentAAction;             N: UC + 'FORM_DoDocumentAAction' + AT8),
    (P: @@FORM_DoPageAAction;                 N: UC + 'FORM_DoPageAAction' + AT12),
    (P: @@FORM_OnMouseMove;                   N: UC + 'FORM_OnMouseMove' + AT28),
    (P: @@FORM_OnFocus;                       N: UC + 'FORM_OnFocus' + AT28),
    (P: @@FORM_OnLButtonDown;                 N: UC + 'FORM_OnLButtonDown' + AT28),
    (P: @@FORM_OnLButtonUp;                   N: UC + 'FORM_OnLButtonUp' + AT28),
    (P: @@FORM_OnLButtonDoubleClick;          N: UC + 'FORM_OnLButtonDoubleClick' + AT28),
    {$IFDEF PDF_ENABLE_XFA}
    (P: @@FORM_OnRButtonDown;                 N: UC + 'FORM_OnRButtonDown' + AT28),
    (P: @@FORM_OnRButtonUp;                   N: UC + 'FORM_OnRButtonUp' + AT28),
    {$ENDIF PDF_ENABLE_XFA}
    (P: @@FORM_OnKeyDown;                     N: UC + 'FORM_OnKeyDown' + AT16),
    (P: @@FORM_OnKeyUp;                       N: UC + 'FORM_OnKeyUp' + AT16),
    (P: @@FORM_OnChar;                        N: UC + 'FORM_OnChar' + AT16),
    (P: @@FORM_GetFocusedText;                N: UC + 'FORM_GetFocusedText' + AT16),
    (P: @@FORM_GetSelectedText;               N: UC + 'FORM_GetSelectedText' + AT16),
    (P: @@FORM_ReplaceSelection;              N: UC + 'FORM_ReplaceSelection' + AT12),
    (P: @@FORM_CanUndo;                       N: UC + 'FORM_CanUndo' + AT8),
    (P: @@FORM_CanRedo;                       N: UC + 'FORM_CanRedo' + AT8),
    (P: @@FORM_Undo;                          N: UC + 'FORM_Undo' + AT8),
    (P: @@FORM_Redo;                          N: UC + 'FORM_Redo' + AT8),
    (P: @@FORM_ForceToKillFocus;              N: UC + 'FORM_ForceToKillFocus' + AT4),
    (P: @@FPDFPage_HasFormFieldAtPoint;       N: UC + 'FPDFPage_HasFormFieldAtPoint' + AT24),
    (P: @@FPDFPage_FormFieldZOrderAtPoint;    N: UC + 'FPDFPage_FormFieldZOrderAtPoint' + AT24),
    (P: @@FPDF_SetFormFieldHighlightColor;    N: UC + 'FPDF_SetFormFieldHighlightColor' + AT12),
    (P: @@FPDF_SetFormFieldHighlightAlpha;    N: UC + 'FPDF_SetFormFieldHighlightAlpha' + AT8),
    (P: @@FPDF_RemoveFormFieldHighlight;      N: UC + 'FPDF_RemoveFormFieldHighlight' + AT4),
    (P: @@FPDF_FFLDraw;                       N: UC + 'FPDF_FFLDraw' + AT36),
    {$IFDEF _SKIA_SUPPORT_}
    (P: @@FPDF_FFLRecord;                     N: UC + 'FPDF_FFLRecord' + AT36),
    {$ENDIF _SKIA_SUPPORT_}

    (P: @@FPDF_GetFormType;                   N: UC + 'FPDF_GetFormType' + AT4),
    (P: @@FORM_SetIndexSelected;              N: UC + 'FORM_SetIndexSelected' + AT16),
    (P: @@FORM_IsIndexSelected;               N: UC + 'FORM_IsIndexSelected' + AT12),
    {$IFDEF PDF_ENABLE_XFA}
    (P: @@FPDF_LoadXFA;                       N: UC + 'FPDF_LoadXFA' + AT4),
    {$ENDIF PDF_ENABLE_XFA}

    // *** _FPDF_CATALOG_H_ ***
    (P: @@FPDFCatalog_IsTagged;               N: UC + 'FPDFCatalog_IsTagged' + AT4),

    // *** _FPDF_ATTACHMENT_H_ ***
    (P: @@FPDFDoc_GetAttachmentCount;         N: UC + 'FPDFDoc_GetAttachmentCount' + AT4),
    (P: @@FPDFDoc_AddAttachment;              N: UC + 'FPDFDoc_AddAttachment' + AT8),
    (P: @@FPDFDoc_GetAttachment;              N: UC + 'FPDFDoc_GetAttachment' + AT8),
    (P: @@FPDFDoc_DeleteAttachment;           N: UC + 'FPDFDoc_DeleteAttachment' + AT8),
    (P: @@FPDFAttachment_GetName;             N: UC + 'FPDFAttachment_GetName' + AT12),
    (P: @@FPDFAttachment_HasKey;              N: UC + 'FPDFAttachment_HasKey' + AT8),
    (P: @@FPDFAttachment_GetValueType;        N: UC + 'FPDFAttachment_GetValueType' + AT8),
    (P: @@FPDFAttachment_SetStringValue;      N: UC + 'FPDFAttachment_SetStringValue' + AT12),
    (P: @@FPDFAttachment_GetStringValue;      N: UC + 'FPDFAttachment_GetStringValue' + AT16),
    (P: @@FPDFAttachment_SetFile;             N: UC + 'FPDFAttachment_SetFile' + AT16),
    (P: @@FPDFAttachment_GetFile;             N: UC + 'FPDFAttachment_GetFile' + AT12),

    // *** _FPDF_TRANSFORMPAGE_H_ ***
    (P: @@FPDFPage_SetMediaBox;               N: UC + 'FPDFPage_SetMediaBox' + AT20),
    (P: @@FPDFPage_SetCropBox;                N: UC + 'FPDFPage_SetCropBox' + AT20),
    (P: @@FPDFPage_SetBleedBox;               N: UC + 'FPDFPage_SetBleedBox' + AT20),
    (P: @@FPDFPage_SetTrimBox;                N: UC + 'FPDFPage_SetTrimBox' + AT20),
    (P: @@FPDFPage_SetArtBox;                 N: UC + 'FPDFPage_SetArtBox' + AT20),
    (P: @@FPDFPage_GetMediaBox;               N: UC + 'FPDFPage_GetMediaBox' + AT20),
    (P: @@FPDFPage_GetCropBox;                N: UC + 'FPDFPage_GetCropBox' + AT20),
    (P: @@FPDFPage_GetBleedBox;               N: UC + 'FPDFPage_GetBleedBox' + AT20),
    (P: @@FPDFPage_GetTrimBox;                N: UC + 'FPDFPage_GetTrimBox' + AT20),
    (P: @@FPDFPage_GetArtBox;                 N: UC + 'FPDFPage_GetArtBox' + AT20),
    (P: @@FPDFPage_TransFormWithClip;         N: UC + 'FPDFPage_TransFormWithClip' + AT12),
    (P: @@FPDFPageObj_TransformClipPath;      N: UC + 'FPDFPageObj_TransformClipPath' + AT52),
    (P: @@FPDF_CreateClipPath;                N: UC + 'FPDF_CreateClipPath' + AT16),
    (P: @@FPDF_DestroyClipPath;               N: UC + 'FPDF_DestroyClipPath' + AT4),
    (P: @@FPDFPage_InsertClipPath;            N: UC + 'FPDFPage_InsertClipPath' + AT8),

    // *** _FPDF_STRUCTTREE_H_ ***
    (P: @@FPDF_StructTree_GetForPage;         N: UC + 'FPDF_StructTree_GetForPage' + AT4),
    (P: @@FPDF_StructTree_Close;              N: UC + 'FPDF_StructTree_Close' + AT4),
    (P: @@FPDF_StructTree_CountChildren;      N: UC + 'FPDF_StructTree_CountChildren' + AT4),
    (P: @@FPDF_StructTree_GetChildAtIndex;    N: UC + 'FPDF_StructTree_GetChildAtIndex' + AT8),
    (P: @@FPDF_StructElement_GetAltText;      N: UC + 'FPDF_StructElement_GetAltText' + AT12),
    (P: @@FPDF_StructElement_GetMarkedContentID;N: UC + 'FPDF_StructElement_GetMarkedContentID' + AT4),
    (P: @@FPDF_StructElement_GetType;         N: UC + 'FPDF_StructElement_GetType' + AT12),
    (P: @@FPDF_StructElement_GetTitle;        N: UC + 'FPDF_StructElement_GetTitle' + AT12),
    (P: @@FPDF_StructElement_CountChildren;   N: UC + 'FPDF_StructElement_CountChildren' + AT4),
    (P: @@FPDF_StructElement_GetChildAtIndex; N: UC + 'FPDF_StructElement_GetChildAtIndex' + AT8),

    (P: @@FPDFAnnot_IsSupportedSubtype;       N: UC + 'FPDFAnnot_IsSupportedSubtype' + AT4),
    (P: @@FPDFPage_CreateAnnot;               N: UC + 'FPDFPage_CreateAnnot' + AT8),
    (P: @@FPDFPage_GetAnnotCount;             N: UC + 'FPDFPage_GetAnnotCount' + AT4),
    (P: @@FPDFPage_GetAnnot;                  N: UC + 'FPDFPage_GetAnnot' + AT8),
    (P: @@FPDFPage_GetAnnotIndex;             N: UC + 'FPDFPage_GetAnnotIndex' + AT8),
    (P: @@FPDFPage_CloseAnnot;                N: UC + 'FPDFPage_CloseAnnot' + AT4),
    (P: @@FPDFPage_RemoveAnnot;               N: UC + 'FPDFPage_RemoveAnnot' + AT8),
    (P: @@FPDFAnnot_GetSubtype;               N: UC + 'FPDFAnnot_GetSubtype' + AT4),
    (P: @@FPDFAnnot_IsObjectSupportedSubtype; N: UC + 'FPDFAnnot_IsObjectSupportedSubtype' + AT4),
    (P: @@FPDFAnnot_UpdateObject;             N: UC + 'FPDFAnnot_UpdateObject' + AT8),
    (P: @@FPDFAnnot_AppendObject;             N: UC + 'FPDFAnnot_AppendObject' + AT8),
    (P: @@FPDFAnnot_GetObjectCount;           N: UC + 'FPDFAnnot_GetObjectCount' + AT4),
    (P: @@FPDFAnnot_GetObject;                N: UC + 'FPDFAnnot_GetObject' + AT8),
    (P: @@FPDFAnnot_RemoveObject;             N: UC + 'FPDFAnnot_RemoveObject' + AT8),
    (P: @@FPDFAnnot_SetColor;                 N: UC + 'FPDFAnnot_SetColor' + AT24),
    (P: @@FPDFAnnot_GetColor;                 N: UC + 'FPDFAnnot_GetColor' + AT24),
    (P: @@FPDFAnnot_HasAttachmentPoints;      N: UC + 'FPDFAnnot_HasAttachmentPoints' + AT4),
    (P: @@FPDFAnnot_SetAttachmentPoints;      N: UC + 'FPDFAnnot_SetAttachmentPoints' + AT12),
    (P: @@FPDFAnnot_AppendAttachmentPoints;   N: UC + 'FPDFAnnot_AppendAttachmentPoints' + AT8),
    (P: @@FPDFAnnot_CountAttachmentPoints;    N: UC + 'FPDFAnnot_CountAttachmentPoints' + AT4),
    (P: @@FPDFAnnot_GetAttachmentPoints;      N: UC + 'FPDFAnnot_GetAttachmentPoints' + AT12),
    (P: @@FPDFAnnot_SetRect;                  N: UC + 'FPDFAnnot_SetRect' + AT8),
    (P: @@FPDFAnnot_GetRect;                  N: UC + 'FPDFAnnot_GetRect' + AT8),
    (P: @@FPDFAnnot_HasKey;                   N: UC + 'FPDFAnnot_HasKey' + AT8),
    (P: @@FPDFAnnot_GetValueType;             N: UC + 'FPDFAnnot_GetValueType' + AT8),
    (P: @@FPDFAnnot_SetStringValue;           N: UC + 'FPDFAnnot_SetStringValue' + AT12),
    (P: @@FPDFAnnot_GetStringValue;           N: UC + 'FPDFAnnot_GetStringValue' + AT16),
    (P: @@FPDFAnnot_GetNumberValue;           N: UC + 'FPDFAnnot_GetNumberValue' + AT12),
    (P: @@FPDFAnnot_SetAP;                    N: UC + 'FPDFAnnot_SetAP' + AT12),
    (P: @@FPDFAnnot_GetAP;                    N: UC + 'FPDFAnnot_GetAP' + AT16),
    (P: @@FPDFAnnot_GetLinkedAnnot;           N: UC + 'FPDFAnnot_GetLinkedAnnot' + AT8),
    (P: @@FPDFAnnot_GetFlags;                 N: UC + 'FPDFAnnot_GetFlags' + AT4),
    (P: @@FPDFAnnot_SetFlags;                 N: UC + 'FPDFAnnot_SetFlags' + AT8),
    (P: @@FPDFAnnot_GetFormFieldFlags;        N: UC + 'FPDFAnnot_GetFormFieldFlags' + AT12),
    (P: @@FPDFAnnot_GetFormFieldAtPoint;      N: UC + 'FPDFAnnot_GetFormFieldAtPoint' + AT24),
    (P: @@FPDFAnnot_GetOptionCount;           N: UC + 'FPDFAnnot_GetOptionCount' + AT8),
    (P: @@FPDFAnnot_GetOptionLabel;           N: UC + 'FPDFAnnot_GetOptionLabel' + AT20)
  );

var
  PdfiumModule: HMODULE;

procedure NotLoaded; stdcall;
begin
  raise Exception.CreateRes(@RsPdfiumNotLoaded);
end;

procedure Init;
var
  I: Integer;
begin
  for I := 0 to Length(ImportFuncs) - 1 do
    ImportFuncs[I].P^ := @NotLoaded;
end;

procedure InitPDFium(const DllPath: string);
const
  pdfium_dll = 'pdfium.dll';
var
  I: Integer;
begin
  if PdfiumModule <> 0 then
    Exit;

  if DllPath <> '' then
    PdfiumModule := SafeLoadLibrary(IncludeTrailingPathDelimiter(DllPath) + pdfium_dll)
  else
    PdfiumModule := SafeLoadLibrary(pdfium_dll);

  if PdfiumModule = 0 then
    RaiseLastOSError;

  for I := 0 to Length(ImportFuncs) - 1 do
  begin
    if ImportFuncs[I].P^ = @NotLoaded then
    begin
      ImportFuncs[I].P^ := GetProcAddress(PdfiumModule, ImportFuncs[I].N);
      if ImportFuncs[I].P^ = nil then
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

  FPDF_InitLibrary;
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
