{$A8,B-,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,T-,U-,V+,X+,Z1}
{$STRINGCHECKS OFF} // It only slows down Delphi strings, doesn't help C++Builder migration and is finally gone in XE+

// Use DLLs (x64, x86) from https://github.com/pvginkel/PdfiumViewer/tree/master/Libraries/Pdfium
// PDFium license see https://github.com/pvginkel/PdfiumViewer/tree/master/PDFium%20License

unit PdfiumLib;

{$SCOPEDENUMS ON}

interface

{$IFDEF MSWINDOWS}
uses
  Windows;
{$ENDIF MSWINDOWS}

// *** _FPDFVIEW_H_ ***

type
  {$IF not declared(SIZE_T)}
  SIZE_T = LongWord;
  {$IFEND}
  {$IF not declared(DWORD)}
  DWORD = UInt16;
  {$IFEND}

  // Data types
  __FPDF_PTRREC = record end;

  FPDF_MODULEMGR    = ^__FPDF_PTRREC;

  // PDF types
  FPDF_DOCUMENT     = ^__FPDF_PTRREC;
  FPDF_PAGE         = ^__FPDF_PTRREC;
  FPDF_PAGEOBJECT   = ^__FPDF_PTRREC; // Page object(text, path, etc)
  FPDF_PATH         = ^__FPDF_PTRREC;
  FPDF_CLIPPATH     = ^__FPDF_PTRREC;
  FPDF_BITMAP       = ^__FPDF_PTRREC;
  FPDF_FONT         = ^__FPDF_PTRREC;

  FPDF_TEXTPAGE     = ^__FPDF_PTRREC;
  FPDF_SCHHANDLE    = ^__FPDF_PTRREC;
  FPDF_PAGELINK     = ^__FPDF_PTRREC;
  FPDF_HMODULE      = ^__FPDF_PTRREC;
  FPDF_DOCSCHHANDLE = ^__FPDF_PTRREC;

  FPDF_BOOKMARK     = ^__FPDF_PTRREC;
  FPDF_DEST         = ^__FPDF_PTRREC;
  FPDF_ACTION       = ^__FPDF_PTRREC;
  FPDF_LINK         = ^__FPDF_PTRREC;
  FPDF_PAGERANGE    = ^__FPDF_PTRREC;

  // Basic data types
  FPDF_BOOL  = Integer;
  FPDF_ERROR = Integer;
  FPDF_DWORD = LongWord;

  FS_FLOAT = Single;

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

  // FPDFSDK may use three types of strings: byte string, wide string (UTF-16LE encoded), and platform dependent string
  FPDF_BYTESTRING = PAnsiChar;

  FPDF_WIDESTRING = PWideChar; // Foxit PDF SDK always use UTF-16LE encoding wide string,
                               // each character use 2 bytes (except surrogation), with low byte first.

  // For Windows programmers: for most case it's OK to treat FPDF_WIDESTRING as Windows unicode string,
  //     however, special care needs to be taken if you expect to process Unicode larger than 0xffff.
  // For Linux/Unix programmers: most compiler/library environment uses 4 bytes for a Unicode character,
  //    you have to convert between FPDF_WIDESTRING and system wide string by yourself.

  FPDF_STRING = PAnsiChar;

  PFPDF_LINK = ^FPDF_LINK; // array
  PFPDF_PAGE = ^FPDF_PAGE; // array

  // @brief Matrix for transformation.
  FS_MATRIX = record
    a: Single; //< @brief Coefficient a.
    b: Single; //< @brief Coefficient b.
    c: Single; //< @brief Coefficient c.
    d: Single; //< @brief Coefficient d.
    e: Single; //< @brief Coefficient e.
    f: Single; //< @brief Coefficient f.
  end;
  PFSMatrix = ^TFSMatrix;
  TFSMatrix = FS_MATRIX;

  // @brief Rectangle area(float) in device or page coordination system.
  PFS_RECTF = ^FS_RECTF;
  FS_RECTF = record
    //@brief The x-coordinate of the left-top corner.
    left: Single;
    //@brief The y-coordinate of the left-top corner.
    top: Single;
    //@brief The x-coordinate of the right-bottom corner.
    right: Single;
    //@brief The y-coordinate of the right-bottom corner.
    bottom: Single;
  end;
  // @brief Const Pointer to ::FS_RECTF structure.
  FS_LPCRECTF = ^FS_RECTF;
  PFSRectF = ^TFSRectF;
  TFSRectF = FS_RECTF;

// extern const char g_ExpireDate[];
// extern const char g_ModuleCodes[];


// Function: FPDF_InitLibrary
//      Initialize the FPDFSDK library
// Parameters:
//      None
// Return value:
//      None.
// Comments:
//      You have to call this function before you can call any PDF processing functions.
var
  FPDF_InitLibrary: procedure(); stdcall;

// Function: FPDF_DestroyLibary
//      Release all resources allocated by the FPDFSDK library.
// Parameters:
//      None.
// Return value:
//      None.
// Comments:
//      You can call this function to release all memory blocks allocated by the library.
//      After this function called, you should not call any PDF processing functions.
var
  FPDF_DestroyLibrary: procedure(); stdcall;

// Policy for accessing the local machine time.
const
  FPDF_POLICY_MACHINETIME_ACCESS = 0;

// Function: FPDF_SetSandBoxPolicy
//      Set the policy for the sandbox environment.
// Parameters:
//      policy    -  The specified policy for setting, for example:FPDF_POLICY_MACHINETIME_ACCESS.
//      enable    -  True for enable, False for disable the policy.
// Return value:
//      None.
var
  FPDF_SetSandBoxPolicy: procedure(policy: FPDF_DWORD; enable: FPDF_BOOL); stdcall;

//**
//* Open and load a PDF document.
//* @param[in] file_path  -  Path to the PDF file (including extension).
//* @param[in] password   -  A string used as the password for PDF file.
//*                          If no password needed, empty or NULL can be used.
//* @note    Loaded document can be closed by FPDF_CloseDocument.
//*      If this function fails, you can use FPDF_GetLastError() to retrieve
//*      the reason why it fails.
//* @retval  A handle to the loaded document. If failed, NULL is returned.
//**
var
  FPDF_LoadDocument: function(file_path: FPDF_STRING; password: FPDF_BYTESTRING): FPDF_DOCUMENT; stdcall;

// Function: FPDF_LoadMemDocument
//      Open and load a PDF document from memory.
// Parameters:
//      data_buf  -  Pointer to a buffer containing the PDF document.
//      size      -  Number of bytes in the PDF document.
//      password  -  A string used as the password for PDF file.
//                    If no password needed, empty or NULL can be used.
// Return value:
//      A handle to the loaded document. If failed, NULL is returned.
// Comments:
//      The memory buffer must remain valid when the document is open.
//      Loaded document can be closed by FPDF_CloseDocument.
//      If this function fails, you can use FPDF_GetLastError() to retrieve
//      the reason why it fails.
//
var
  FPDF_LoadMemDocument: function(data_buf: Pointer; size: Integer; password: FPDF_BYTESTRING): FPDF_DOCUMENT; stdcall;

// Structure for custom file access.
type
  PFPDF_FILEACCESS = ^FPDF_FILEACCESS;
  FPDF_FILEACCESS = record
    // File length, in bytes.
    m_FileLen: LongWord;

    // A function pointer for getting a block of data from specific position.
    // Position is specified by byte offset from beginning of the file.
    // The position and size will never go out range of file length.
    // It may be possible for FPDFSDK to call this function multiple times for same position.
    // Return value: should be non-zero if successful, zero for error.
    m_GetBlock: function(param: Pointer; position: LongWord; pBuf: PByte; size: LongWord): Integer; cdecl;

    // A custom pointer for all implementation specific data.
    // This pointer will be used as the first parameter to m_GetBlock callback.
    m_Param: Pointer;
  end;
  PFPDFFileAccess = ^TFPDFFileAccess;
  TFPDFFileAccess = FPDF_FILEACCESS;

// Function: FPDF_LoadCustomDocument
//      Load PDF document from a custom access descriptor.
// Parameters:
//      pFileAccess  -  A structure for access the file.
//      password     -  Optional password for decrypting the PDF file.
// Return value:
//      A handle to the loaded document. If failed, NULL is returned.
// Comments:
//      The application should maintain the file resources being valid until the PDF document close.
//      Loaded document can be closed by FPDF_CloseDocument.
var
  FPDF_LoadCustomDocument: function(pFileAccess: PFPDF_FILEACCESS; password: FPDF_BYTESTRING): FPDF_DOCUMENT; stdcall;

// Function: FPDF_GetFileVersion
//      Get the file version of the specific PDF document.
// Parameters:
//      doc          -  Handle to document.
//      fileVersion  -  The PDF file version. File version: 14 for 1.4, 15 for 1.5, ...
// Return value:
//      TRUE if this call succeed, If failed, FALSE is returned.
// Comments:
//      If the document is created by function ::FPDF_CreateNewDocument, then this function would always fail.
var
  FPDF_GetFileVersion: function(doc: FPDF_DOCUMENT; var fileVersion: Integer): FPDF_BOOL; stdcall;

const
  FPDF_ERR_SUCCESS  = 0;    // No error.
  FPDF_ERR_UNKNOWN  = 1;    // Unknown error.
  FPDF_ERR_FILE     = 2;    // File not found or could not be opened.
  FPDF_ERR_FORMAT   = 3;    // File not in PDF format or corrupted.
  FPDF_ERR_PASSWORD = 4;    // Password required or incorrect password.
  FPDF_ERR_SECURITY = 5;    // Unsupported security scheme.
  FPDF_ERR_PAGE     = 6;    // Page not found or content error.

// Function: FPDF_GetLastError
//      Get last error code when an SDK function failed.
// Parameters:
//      None.
// Return value:
//      A 32-bit integer indicating error codes (defined above).
// Comments:
//      If the previous SDK call succeeded, the return value of this function
//      is not defined.
//
var
  FPDF_GetLastError: function(): LongWord; stdcall;

// Function: FPDF_GetDocPermission
//      Get file permission flags of the document.
// Parameters:
//      document  -  Handle to document. Returned by FPDF_LoadDocument function.
// Return value:
//      A 32-bit integer indicating permission flags. Please refer to PDF Reference for
//      detailed description. If the document is not protected, 0xffffffff will be returned.
//
var
  FPDF_GetDocPermissions: function(document: FPDF_DOCUMENT): LongWord; stdcall;


// Function: FPDF_GetSecurityHandlerRevision
//      Get the revision for security handler.
// Parameters:
//      document  -  Handle to document. Returned by FPDF_LoadDocument function.
// Return value:
//      The security handler revision number. Please refer to PDF Reference for
//      detailed description. If the document is not protected, -1 will be returned.
//
var
  FPDF_GetSecurityHandlerRevision: function(document: FPDF_DOCUMENT): Integer; stdcall;

// Function: FPDF_GetPageCount
//      Get total number of pages in a document.
// Parameters:
//      document  -  Handle to document. Returned by FPDF_LoadDocument function.
// Return value:
//      Total number of pages in the document.
//
var
  FPDF_GetPageCount: function(document: FPDF_DOCUMENT): Integer; stdcall;

// Function: FPDF_LoadPage
//      Load a page inside a document.
// Parameters:
//      document    -  Handle to document. Returned by FPDF_LoadDocument function.
//      page_index  -  Index number of the page. 0 for the first page.
// Return value:
//      A handle to the loaded page. If failed, NULL is returned.
// Comments:
//      Loaded page can be rendered to devices using FPDF_RenderPage function.
//      Loaded page can be closed by FPDF_ClosePage.
//
var
  FPDF_LoadPage: function(document: FPDF_DOCUMENT; page_index: Integer): FPDF_PAGE; stdcall;

// Function: FPDF_GetPageWidth
//      Get page width.
// Parameters:
//      page    -  Handle to the page. Returned by FPDF_LoadPage function.
// Return value:
//      Page width (excluding non-displayable area) measured in points.
//      One point is 1/72 inch (around 0.3528 mm).
//
var
  FPDF_GetPageWidth: function(page: FPDF_PAGE): Double; stdcall;

// Function: FPDF_GetPageHeight
//      Get page height.
// Parameters:
//      page    -  Handle to the page. Returned by FPDF_LoadPage function.
// Return value:
//      Page height (excluding non-displayable area) measured in points.
//      One point is 1/72 inch (around 0.3528 mm)
//
var
  FPDF_GetPageHeight: function(page: FPDF_PAGE): Double; stdcall;

// Function: FPDF_GetPageSizeByIndex
//      Get the size of a page by index.
// Parameters:
//      document    -  Handle to document. Returned by FPDF_LoadDocument function.
//      page_index  -  Page index, zero for the first page.
//      width       -  Pointer to a double value receiving the page width (in points).
//      height      -  Pointer to a double value receiving the page height (in points).
// Return value:
//      Non-zero for success. 0 for error (document or page not found).
//
var
  FPDF_GetPageSizeByIndex: function(document: FPDF_DOCUMENT; page_index: Integer; var width, height: Double): Integer; stdcall;

// Page rendering flags. They can be combined with bit OR.
const
  FPDF_ANNOT                    = $01;  // Set if annotations are to be rendered.
  FPDF_LCD_TEXT                 = $02;  // Set if using text rendering optimized for LCD display.
  FPDF_NO_NATIVETEXT            = $04;  // Don't use the native text output available on some platforms
  FPDF_GRAYSCALE                = $08;  // Grayscale output.
  FPDF_DEBUG_INFO               = $80;  // Set if you want to get some debug info.
  // Please discuss with Foxit first if you need to collect debug info.
  FPDF_NO_CATCH                 = $100; // Set if you don't want to catch exception.
  FPDF_RENDER_LIMITEDIMAGECACHE = $200; // Limit image cache size.
  FPDF_RENDER_FORCEHALFTONE     = $400; // Always use halftone for image stretching.
  FPDF_PRINTING                 = $800; // Render for printing.
  FPDF_REVERSE_BYTE_ORDER       = $10;  //set whether render in a reverse Byte order, this flag only
                                        //enable when render to a bitmap.
{$IFDEF MSWINDOWS}
// Function: FPDF_RenderPage
//      Render contents in a page to a device (screen, bitmap, or printer).
//      This function is only supported on Windows system.
// Parameters:
//      dc      -  Handle to device context.
//      page    -  Handle to the page. Returned by FPDF_LoadPage function.
//      start_x -  Left pixel position of the display area in the device coordinate.
//      start_y -  Top pixel position of the display area in the device coordinate.
//      size_x  -  Horizontal size (in pixels) for displaying the page.
//      size_y  -  Vertical size (in pixels) for displaying the page.
//      rotate  -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                 2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//      flags   -  0 for normal display, or combination of flags defined above.
// Return value:
//      None.
//
var
  FPDF_RenderPage: procedure(DC: HDC; page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer;
    rotate: Integer; flags: Integer); stdcall;
{$ENDIF MSWINDOWS}

// Function: FPDF_RenderPageBitmap
//      Render contents in a page to a device independent bitmap
// Parameters:
//      bitmap   -  Handle to the device independent bitmap (as the output buffer).
//                  Bitmap handle can be created by FPDFBitmap_Create function.
//      page     -  Handle to the page. Returned by FPDF_LoadPage function.
//      start_x  -  Left pixel position of the display area in the bitmap coordinate.
//      start_y  -  Top pixel position of the display area in the bitmap coordinate.
//      size_x   -  Horizontal size (in pixels) for displaying the page.
//      size_y   -  Vertical size (in pixels) for displaying the page.
//      rotate   -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                  2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//      flags    -  0 for normal display, or combination of flags defined above.
// Return value:
//      None.
//
var
  FPDF_RenderPageBitmap: procedure(bitmap: FPDF_BITMAP; page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer;
    rotate: Integer; flags: Integer); stdcall;

// Function: FPDF_ClosePage
//      Close a loaded PDF page.
// Parameters:
//      page    -  Handle to the loaded page.
// Return value:
//      None.
//
var
  FPDF_ClosePage: procedure(page: FPDF_PAGE); stdcall;

// Function: FPDF_CloseDocument
//      Close a loaded PDF document.
// Parameters:
//      document  -  Handle to the loaded document.
// Return value:
//      None.
//
var
  FPDF_CloseDocument: procedure(document: FPDF_DOCUMENT); stdcall;

// Function: FPDF_DeviceToPage
//      Convert the screen coordinate of a point to page coordinate.
// Parameters:
//      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//      start_x   -  Left pixel position of the display area in the device coordinate.
//      start_y   -  Top pixel position of the display area in the device coordinate.
//      size_x    -  Horizontal size (in pixels) for displaying the page.
//      size_y    -  Vertical size (in pixels) for displaying the page.
//      rotate    -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                   2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//      device_x  -  X value in device coordinate, for the point to be converted.
//      device_y  -  Y value in device coordinate, for the point to be converted.
//      page_x    -  A Pointer to a double receiving the converted X value in page coordinate.
//      page_y    -  A Pointer to a double receiving the converted Y value in page coordinate.
// Return value:
//      None.
// Comments:
//      The page coordinate system has its origin at left-bottom corner of the page, with X axis goes along
//      the bottom side to the right, and Y axis goes along the left side upward. NOTE: this coordinate system
//      can be altered when you zoom, scroll, or rotate a page, however, a point on the page should always have
//      the same coordinate values in the page coordinate system.
//
//      The device coordinate system is device dependent. For screen device, its origin is at left-top
//      corner of the window. However this origin can be altered by Windows coordinate transformation
//      utilities. You must make sure the start_x, start_y, size_x, size_y and rotate parameters have exactly
//      same values as you used in FPDF_RenderPage() function call.
//
var
  FPDF_DeviceToPage: procedure(page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer;
    rotate: Integer; device_x, device_y: Integer; var page_x, page_y: Double); stdcall;

// Function: FPDF_PageToDevice
//      Convert the page coordinate of a point to screen coordinate.
// Parameters:
//      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//      start_x   -  Left pixel position of the display area in the device coordinate.
//      start_y   -  Top pixel position of the display area in the device coordinate.
//      size_x    -  Horizontal size (in pixels) for displaying the page.
//      size_y    -  Vertical size (in pixels) for displaying the page.
//      rotate    -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                   2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//      page_x    -  X value in page coordinate, for the point to be converted.
//      page_y    -  Y value in page coordinate, for the point to be converted.
//      device_x  -  A pointer to an integer receiving the result X value in device coordinate.
//      device_y  -  A pointer to an integer receiving the result Y value in device coordinate.
// Return value:
//      None.
// Comments:
//      See comments of FPDF_DeviceToPage() function.
//
var
  FPDF_PageToDevice: procedure(page: FPDF_PAGE; start_x, start_y, size_x, size_y: Integer;
    rotate: Integer; page_x, page_y: Double; var device_x, device_y: Integer); stdcall;

// Function: FPDFBitmap_Create
//      Create a Foxit Device Independent Bitmap (FXDIB).
// Parameters:
//      width    -  Number of pixels in a horizontal line of the bitmap. Must be greater than 0.
//      height   -  Number of pixels in a vertical line of the bitmap. Must be greater than 0.
//      alpha    -  A flag indicating whether alpha channel is used. Non-zero for using alpha, zero for not using.
// Return value:
//      The created bitmap handle, or NULL if parameter error or out of memory.
// Comments:
//      An FXDIB always use 4 byte per pixel. The first byte of a pixel is always double word aligned.
//      Each pixel contains red (R), green (G), blue (B) and optionally alpha (A) values.
//      The byte order is BGRx (the last byte unused if no alpha channel) or BGRA.
//
//      The pixels in a horizontal line (also called scan line) are stored side by side, with left most
//      pixel stored first (with lower memory address). Each scan line uses width*4 bytes.
//
//      Scan lines are stored one after another, with top most scan line stored first. There is no gap
//      between adjacent scan lines.
//
//      This function allocates enough memory for holding all pixels in the bitmap, but it doesn't
//      initialize the buffer. Applications can use FPDFBitmap_FillRect to fill the bitmap using any color.
var
  FPDFBitmap_Create: function(width, height: Integer; alpha: Integer): FPDF_BITMAP; stdcall;


const
  // More DIB formats
  FPDFBitmap_Gray = 1; // Gray scale bitmap, one byte per pixel.
  FPDFBitmap_BGR  = 2; // 3 bytes per pixel, byte order: blue, green, red.
  FPDFBitmap_BGRx = 3; // 4 bytes per pixel, byte order: blue, green, red, unused.
  FPDFBitmap_BGRA = 4; // 4 bytes per pixel, byte order: blue, green, red, alpha.

// Function: FPDFBitmap_CreateEx
//      Create a Foxit Device Independent Bitmap (FXDIB)
// Parameters:
//      width       -  Number of pixels in a horizontal line of the bitmap. Must be greater than 0.
//      height      -  Number of pixels in a vertical line of the bitmap. Must be greater than 0.
//      format      -  A number indicating for bitmap format, as defined above.
//      first_scan  -  A pointer to the first byte of first scan line, for external buffer
//                     only. If this parameter is NULL, then the SDK will create its own buffer.
//      stride      -  Number of bytes for each scan line, for external buffer only..
// Return value:
//      The created bitmap handle, or NULL if parameter error or out of memory.
// Comments:
//      Similar to FPDFBitmap_Create function, with more formats and external buffer supported.
//      Bitmap created by this function can be used in any place that a FPDF_BITMAP handle is
//      required.
//
//      If external scanline buffer is used, then the application should destroy the buffer
//      by itself. FPDFBitmap_Destroy function will not destroy the buffer.
//
var
  FPDFBitmap_CreateEx: function(width, height: Integer; format: Integer; first_scan: Pointer;
    stride: Integer): FPDF_BITMAP; stdcall;

// Function: FPDFBitmap_FillRect
//      Fill a rectangle area in an FXDIB.
// Parameters:
//      bitmap  -  The handle to the bitmap. Returned by FPDFBitmap_Create function.
//      left    -  The left side position. Starting from 0 at the left-most pixel.
//      top     -  The top side position. Starting from 0 at the top-most scan line.
//      width   -  Number of pixels to be filled in each scan line.
//      height  -  Number of scan lines to be filled.
//      color   -  A 32-bit value specifing the color, in 8888 ARGB format.
// Return value:
//      None.
// Comments:
//      This function set the color and (optionally) alpha value in specified region of the bitmap.
//      NOTE: If alpha channel is used, this function does NOT composite the background with the source color,
//      instead the background will be replaced by the source color and alpha.
//      If alpha channel is not used, the "alpha" parameter is ignored.
//
var
  FPDFBitmap_FillRect: procedure(bitmap: FPDF_BITMAP; left, top, width, height: Integer; color: FPDF_DWORD); stdcall;

// Function: FPDFBitmap_GetBuffer
//      Get data buffer of an FXDIB
// Parameters:
//      bitmap    -  Handle to the bitmap. Returned by FPDFBitmap_Create function.
// Return value:
//      The pointer to the first byte of the bitmap buffer.
// Comments:
//      The stride may be more than width * number of bytes per pixel
//      Applications can use this function to get the bitmap buffer pointer, then manipulate any color
//      and/or alpha values for any pixels in the bitmap.
var
  FPDFBitmap_GetBuffer: function(bitmap: FPDF_BITMAP): Pointer; stdcall;

// Function: FPDFBitmap_GetWidth
//      Get width of an FXDIB.
// Parameters:
//      bitmap    -  Handle to the bitmap. Returned by FPDFBitmap_Create function.
// Return value:
//      The number of pixels in a horizontal line of the bitmap.
var
  FPDFBitmap_GetWidth: function(bitmap: FPDF_BITMAP): Integer; stdcall;

// Function: FPDFBitmap_GetHeight
//      Get height of an FXDIB.
// Parameters:
//      bitmap    -  Handle to the bitmap. Returned by FPDFBitmap_Create function.
// Return value:
//      The number of pixels in a vertical line of the bitmap.
var
  FPDFBitmap_GetHeight: function(bitmap: FPDF_BITMAP): Integer; stdcall;

// Function: FPDFBitmap_GetStride
//      Get number of bytes for each scan line in the bitmap buffer.
// Parameters:
//      bitmap    -  Handle to the bitmap. Returned by FPDFBitmap_Create function.
// Return value:
//      The number of bytes for each scan line in the bitmap buffer.
// Comments:
//      The stride may be more than width * number of bytes per pixel
var
  FPDFBitmap_GetStride: function(bitmap: FPDF_BITMAP): Integer; stdcall;

// Function: FPDFBitmap_Destroy
//      Destroy an FXDIB and release all related buffers.
// Parameters:
//      bitmap    -  Handle to the bitmap. Returned by FPDFBitmap_Create function.
// Return value:
//      None.
// Comments:
//      This function will not destroy any external buffer.
//
var
  FPDFBitmap_Destroy: procedure(bitmap: FPDF_BITMAP); stdcall;

// Function: FPDF_VIEWERREF_GetPrintScaling
//      Whether the PDF document prefers to be scaled or not.
// Parameters:
//      document  -  Handle to the loaded document.
// Return value:
//      None.
//
var
  FPDF_VIEWERREF_GetPrintScaling: function(document: FPDF_DOCUMENT): FPDF_BOOL; stdcall;

// Function: FPDF_VIEWERREF_GetNumCopies
//      Returns the number of copies to be printed.
// Parameters:
//      document  -  Handle to the loaded document.
// Return value:
//          The number of copies to be printed.
//
var
  FPDF_VIEWERREF_GetNumCopies: function(document: FPDF_DOCUMENT): Integer; stdcall;

// Function: FPDF_VIEWERREF_GetPrintPageRange
//      Page numbers to initialize print dialog box when file is printed.
// Parameters:
//      document  -  Handle to the loaded document.
// Return value:
//          The print page range to be used for printing.
//
var
  FPDF_VIEWERREF_GetPrintPageRange: function(document: FPDF_DOCUMENT): FPDF_PAGERANGE; stdcall;

// Function: FPDF_VIEWERREF_GetDuplex
//      Returns the paper handling option to be used when printing from print dialog.
// Parameters:
//      document  -  Handle to the loaded document.
// Return value:
//          The paper handling option to be used when printing.
//
var
  FPDF_VIEWERREF_GetDuplex: function(document: FPDF_DOCUMENT): FPDF_DUPLEXTYPE; stdcall;

// Function: FPDF_CountNamedDests
//      Get the count of named destinations in the PDF document.
// Parameters:
//      document  -  Handle to a document
// Return value:
//      The count of named destinations.
var
  FPDF_CountNamedDests: function(document: FPDF_DOCUMENT): FPDF_DWORD; stdcall;

// Function: FPDF_GetNamedDestByName
//      get a special dest handle by the index.
// Parameters:
//      document  -  Handle to the loaded document.
//      name      -  The name of a special named dest.
// Return value:
//      The handle of the dest.
//
var
  FPDF_GetNamedDestByName: function(document: FPDF_DOCUMENT; name: FPDF_BYTESTRING): FPDF_DEST; stdcall;

// Function: FPDF_GetNamedDest
//      Get the specified named destinations of the PDF document by index.
// Parameters:
//      document  -  Handle to a document
//      index     -  The index of named destination.
//      buffer    -  The buffer to obtain destination name, used as wchar_t*.
//      buflen    -  The length of the buffer in byte.
// Return value:
//      The destination handle of a named destination, NULL when retrieving the length.
// Comments:
//      Call this function twice to get the name of the named destination:
//      1) First time pass in |buffer| as NULL and get buflen.
//      2) Second time pass in allocated |buffer| and buflen to retrieve |buffer|, which should be used as wchar_t*.
//         If buflen is not sufficiently large, it will be returned as -1.
//
var
  FPDF_GetNamedDest: function(document: FPDF_DOCUMENT; index: Integer; buffer: Pointer; var buflen: LongWord): FPDF_DEST; stdcall;


// *** _FPDFEDIT_H_ ***

function FPDF_ARGB(a, r, g, b: Byte): DWORD; inline;
function FPDF_GetBValue(argb: DWORD): Byte; inline;
function FPDF_GetGValue(argb: DWORD): Byte; inline;
function FPDF_GetRValue(argb: DWORD): Byte; inline;
function FPDF_GetAValue(argb: DWORD): Byte; inline;

//////////////////////////////////////////////////////////////////////
//
// Document functions
//
//////////////////////////////////////////////////////////////////////

// Function: FPDF_CreateNewDocument
//      Create a new PDF document.
// Parameters:
//      None.
// Return value:
//      A handle to a document. If failed, NULL is returned.
var
  FPDF_CreateNewDocument: function(): FPDF_DOCUMENT; stdcall;

//////////////////////////////////////////////////////////////////////
//
// Page functions
//
//////////////////////////////////////////////////////////////////////

// Function: FPDFPage_New
//      Construct an empty page.
// Parameters:
//      document    -  Handle to document. Returned by FPDF_LoadDocument and FPDF_CreateNewDocument.
//      page_index  -  The index of a page.
//      width       -  The page width.
//      height      -  The page height.
// Return value:
//      The handle to the page.
// Comments:
//      Loaded page can be deleted by FPDFPage_Delete.
var
  FPDFPage_New: function(document: FPDF_DOCUMENT; page_index: Integer; width, height: Double): FPDF_PAGE; stdcall;

// Function: FPDFPage_Delete
//      Delete a PDF page.
// Parameters:
//      document    -  Handle to document. Returned by FPDF_LoadDocument and FPDF_CreateNewDocument.
//      page_index  -  The index of a page.
// Return value:
//      None.
var
  FPDFPage_Delete: procedure(document: FPDF_DOCUMENT; page_index: Integer); stdcall;

// Function: FPDFPage_GetRotation
//      Get the page rotation. One of following values will be returned: 0(0), 1(90), 2(180), 3(270).
// Parameters:
//      page    -  Handle to a page. Returned by FPDFPage_New or FPDF_LoadPage.
// Return value:
//      The PDF page rotation.
// Comment:
//      The PDF page rotation is rotated clockwise.
var
  FPDFPage_GetRotation: function(page: FPDF_PAGE): Integer; stdcall;

// Function: FPDFPage_SetRotation
//      Set page rotation. One of following values will be set: 0(0), 1(90), 2(180), 3(270).
// Parameters:
//      page    -  Handle to a page. Returned by FPDFPage_New or FPDF_LoadPage.
//      rotate  -  The value of the PDF page rotation.
// Return value:
//      None.
// Comment:
//      The PDF page rotation is rotated clockwise.
//
var
  FPDFPage_SetRotation: procedure(page: FPDF_PAGE; rotate: Integer); stdcall;

// Function: FPDFPage_InsertObject
//      Insert an object to the page. The page object is automatically freed.
// Parameters:
//      page      -  Handle to a page. Returned by FPDFPage_New or FPDF_LoadPage.
//      page_obj  -  Handle to a page object. Returned by FPDFPageObj_NewTextObj,FPDFPageObj_NewTextObjEx and
//              FPDFPageObj_NewPathObj.
// Return value:
//      None.
var
  FPDFPage_InsertObject: procedure(page: FPDF_PAGE; page_obj: FPDF_PAGEOBJECT); stdcall;

// Function: FPDFPage_CountObject
//      Get number of page objects inside the page.
// Parameters:
//      page    -  Handle to a page. Returned by FPDFPage_New or FPDF_LoadPage.
// Return value:
//      The number of the page object.
var
  FPDFPage_CountObject: function(page: FPDF_PAGE): Integer; stdcall;

// Function: FPDFPage_GetObject
//      Get page object by index.
// Parameters:
//      page     -  Handle to a page. Returned by FPDFPage_New or FPDF_LoadPage.
//      index    -  The index of a page object.
// Return value:
//      The handle of the page object. Null for failed.
var
  FPDFPage_GetObject: function(page: FPDF_PAGE; index: Integer): FPDF_PAGEOBJECT; stdcall;

// Function: FPDFPage_HasTransparency
//      Check that whether the content of specified PDF page contains transparency.
// Parameters:
//      page    -  Handle to a page. Returned by FPDFPage_New or FPDF_LoadPage.
// Return value:
//      TRUE means that the PDF page does contains transparency.
//      Otherwise, returns FALSE.
var
  FPDFPage_HasTransparency: function(page: FPDF_PAGE): FPDF_BOOL; stdcall;

// Function: FPDFPage_GenerateContent
//      Generate PDF Page content.
// Parameters:
//      page    -  Handle to a page. Returned by FPDFPage_New or FPDF_LoadPage.
// Return value:
//      True if successful, false otherwise.
// Comment:
//      Before you save the page to a file, or reload the page, you must call the FPDFPage_GenerateContent function.
//      Or the changed information will be lost.
var
  FPDFPage_GenerateContent: function(page: FPDF_PAGE): FPDF_BOOL; stdcall;

//////////////////////////////////////////////////////////////////////
//
// Page Object functions
//
//////////////////////////////////////////////////////////////////////

// Function: FPDFPageObj_HasTransparency
//      Check that whether the specified PDF page object contains transparency.
// Parameters:
//      pageObject  -  Handle to a page object.
// Return value:
//      TRUE means that the PDF page object does contains transparency.
//      Otherwise, returns FALSE.
var
  FPDFPageObj_HasTransparency: function(pageObject: FPDF_PAGEOBJECT): FPDF_BOOL; stdcall;

// Function: FPDFPageObj_Transform
//      Transform (scale, rotate, shear, move) page object.
// Parameters:
//      page_object  -  Handle to a page object. Returned by FPDFPageObj_NewImageObj.
//      a            -  The coefficient "a" of the matrix.
//      b            -  The  coefficient "b" of the matrix.
//      c            -  The coefficient "c" of the matrix.
//      d            -  The coefficient "d" of the matrix.
//      e            -  The coefficient "e" of the matrix.
//      f            -  The coefficient "f" of the matrix.
// Return value:
//      None.
var
  FPDFPageObj_Transform: procedure(page_object: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double); stdcall;

// Function: FPDFPage_TransformAnnots
//      Transform (scale, rotate, shear, move) all annots in a page.
// Parameters:
//      page   -  Handle to a page.
//      a      -  The coefficient "a" of the matrix.
//      b      -  The  coefficient "b" of the matrix.
//      c      -  The coefficient "c" of the matrix.
//      d      -  The coefficient "d" of the matrix.
//      e      -  The coefficient "e" of the matrix.
//      f      -  The coefficient "f" of the matrix.
// Return value:
//      None.
var
  FPDFPage_TransformAnnots: procedure(page: FPDF_PAGE; a, b, c, d, e, f: Double); stdcall;

const
  // The page object constants.
  FPDF_PAGEOBJ_TEXT    = 1;
  FPDF_PAGEOBJ_PATH    = 2;
  FPDF_PAGEOBJ_IMAGE   = 3;
  FPDF_PAGEOBJ_SHADING = 4;
  FPDF_PAGEOBJ_FORM    = 5;

//////////////////////////////////////////////////////////////////////
//
// Image functions
//
//////////////////////////////////////////////////////////////////////

// Function: FPDFPageObj_NewImageObj
//      Create a new Image Object.
// Parameters:
//      document    -  Handle to document. Returned by FPDF_LoadDocument or FPDF_CreateNewDocument function.
// Return Value:
//      Handle of image object.
var
  FPDFPageObj_NewImageObj: function(document: FPDF_DOCUMENT): FPDF_PAGEOBJECT; stdcall;

// Function: FPDFImageObj_LoadJpegFile
//      Load Image from a JPEG image file and then set it to an image object.
// Parameters:
//      pages         -  Pointers to the start of all loaded pages, could be NULL.
//      nCount        -  Number of pages, could be 0.
//      image_object  -  Handle of image object returned by FPDFPageObj_NewImageObj.
//      fileAccess    -  The custom file access handler, which specifies the JPEG image file.
//  Return Value:
//      TRUE if successful, FALSE otherwise.
//  Note:
//      The image object might already has an associated image, which is shared and cached by the loaded pages, In this case, we need to clear the cache of image for all the loaded pages.
//      Pass pages and count to this API to clear the image cache.
var
  FPDFImageObj_LoadJpegFile: function(pages: PFPDF_PAGE; nCount: Integer; image_object: FPDF_PAGEOBJECT;
    fileAccess: PFPDF_FILEACCESS): FPDF_BOOL; stdcall;

// Function: FPDFImageObj_SetMatrix
//      Set the matrix of an image object.
// Parameters:
//      image_object  -  Handle of image object returned by FPDFPageObj_NewImageObj.
//      a             -  The coefficient "a" of the matrix.
//      b             -  The coefficient "b" of the matrix.
//      c             -  The coefficient "c" of the matrix.
//      d             -  The coefficient "d" of the matrix.
//      e             -  The coefficient "e" of the matrix.
//      f             -  The coefficient "f" of the matrix.
// Return value:
//      TRUE if successful, FALSE otherwise.
var
  FPDFImageObj_SetMatrix: function(image_object: FPDF_PAGEOBJECT; a, b, c, d, e, f: Double): FPDF_BOOL; stdcall;

// Function: FPDFImageObj_SetBitmap
//      Set the bitmap to an image object.
// Parameters:
//      pages         -  Pointer's to the start of all loaded pages.
//      nCount        -  Number of pages.
//      image_object  -  Handle of image object returned by FPDFPageObj_NewImageObj.
//      bitmap        -  The handle of the bitmap which you want to set it to the image object.
// Return value:
//      TRUE if successful, FALSE otherwise.
var
  FPDFImageObj_SetBitmap: function(pages: PFPDF_PAGE; nCount: Integer; image_object: FPDF_PAGEOBJECT;
    bitmap: FPDF_BITMAP): FPDF_BOOL; stdcall;

// *** _FPDFPPO_H_ ***

// Function: FPDF_ImportPages
//      Import some pages to a PDF document.
// Parameters:
//      dest_doc   -  The destination document which add the pages.
//      src_doc    -  A document to be imported.
//      pagerange  -  A page range string, Such as "1,3,5-7".
//                    If this parameter is NULL, it would import all pages in src_doc.
//      index      -  The page index wanted to insert from.
// Return value:
//      TRUE for succeed, FALSE for Failed.
var
  FPDF_ImportPages: function(dest_doc, src_doc: FPDF_DOCUMENT; pagerange: FPDF_BYTESTRING; index: Integer): FPDF_BOOL; stdcall;

// Function: FPDF_CopyViewerPreferences
//      Copy the viewer preferences from one PDF document to another.
// Parameters:
//      dest_doc   -  Handle to document to write the viewer preferences to.
//      src_doc    -  Handle to document with the viewer preferences.
// Return value:
//      TRUE for success, FALSE for failure.
var
  FPDF_CopyViewerPreferences: function(dest_doc, src_doc: FPDF_DOCUMENT): FPDF_BOOL; stdcall;

// *** _FPDFSAVE_H_ ***

type
  // Structure for custom file write
  PFPDF_FILEWRITE = ^FPDF_FILEWRITE;
  FPDF_FILEWRITE = record
    //Version number of the interface. Currently must be 1.
    //
    version: Integer;
    //
    // Method: WriteBlock
    //      Output a block of data in your custom way.
    // Interface Version:
    //      1
    // Implementation Required:
    //      Yes
    // Comments:
    //      Called by function FPDF_SaveDocument
    // Parameters:
    //      pThis    -  Pointer to the structure itself
    //      pData    -  Pointer to a buffer to output
    //      size     -  The size of the buffer.
    // Return value:
    //      Should be non-zero if successful, zero for error.
    //
    WriteBlock: function(pThis: PFPDF_FILEWRITE; pData: Pointer; size: LongWord): Integer; cdecl;
  end;
  PFPDFFileWrite = ^TFPDFFileWrite;
  TFPDFFileWrite = FPDF_FILEWRITE;

const
  //@brief Incremental.
  FPDF_INCREMENTAL     = 1;
  //@brief No Incremental.
  FPDF_NO_INCREMENTAL  = 2;
  //@brief Remove security.
  FPDF_REMOVE_SECURITY = 3;

// Function: FPDF_SaveAsCopy
//      Saves the copy of specified document in custom way.
// Parameters:
//      document    -  Handle to document. Returned by FPDF_LoadDocument and FPDF_CreateNewDocument.
//      pFileWrite  -  A pointer to a custom file write structure.
//      flags       -  The creating flags.
// Return value:
//      TRUE for succeed, FALSE for failed.
//
var
  FPDF_SaveAsCopy: function(document: FPDF_DOCUMENT; pFileWrite: PFPDF_FILEWRITE; flags: FPDF_DWORD): FPDF_BOOL; stdcall;

// Function: FPDF_SaveWithVersion
//      Same as function ::FPDF_SaveAsCopy, except the file version of the saved document could be specified by user.
// Parameters:
//      document     -  Handle to document.
//      pFileWrite   -  A pointer to a custom file write structure.
//      flags        -  The creating flags.
//      fileVersion  -  The PDF file version. File version: 14 for 1.4, 15 for 1.5, ...
// Return value:
//      TRUE if succeed, FALSE if failed.
//
var
  FPDF_SaveWithVersion: function(document: FPDF_DOCUMENT; pFileWrite: PFPDF_FILEWRITE;
    flags: FPDF_DWORD; fileVersion: Integer): FPDF_BOOL; stdcall;

// *** _FPDF_FLATTEN_H_ ***

const
  FLATTEN_FAIL       = 0;  // Flatten operation failed.
  FLATTEN_SUCCESS    = 1;  // Flatten operation succeed.
  FLATTEN_NOTINGTODO = 2;  // There is nothing can be flatten.

//Function: FPDFPage_Flatten
//      Flat a pdf page,annotations or form fields will become part of the page contents.
//Parameters:
//      page  - Handle to the page. Returned by FPDF_LoadPage function.
//      nFlag - the flag for the use of flatten result. Zero for normal display, 1 for print.
//Return value:
//      The result flag of the function, See flags above ( FLATTEN_FAIL, FLATTEN_SUCCESS, FLATTEN_NOTINGTODO ).
//
// Comments: Current version all fails return zero. If necessary we will assign different value
//      to indicate different fail reason.
//
var
  FPDFPage_Flatten: function(page: FPDF_PAGE; nFlag: Integer): Integer; stdcall;


// *** _FPDFTEXT_H_ ***

// Function: FPDFText_LoadPage
//      Prepare information about all characters in a page.
// Parameters:
//      page  -  Handle to the page. Returned by FPDF_LoadPage function (in FPDFVIEW module).
// Return value:
//      A handle to the text page information structure.
//      NULL if something goes wrong.
// Comments:
//      Application must call FPDFText_ClosePage to release the text page information.
//      If you don't purchase Text Module , this function will return NULL.
//
var
  FPDFText_LoadPage: function(page: FPDF_PAGE): FPDF_TEXTPAGE; stdcall;

// Function: FPDFText_ClosePage
//      Release all resources allocated for a text page information structure.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return Value:
//      None.
//
var
  FPDFText_ClosePage: procedure(text_page: FPDF_TEXTPAGE); stdcall;

// Function: FPDFText_CountChars
//      Get number of characters in a page.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return value:
//      Number of characters in the page. Return -1 for error.
//      Generated characters, like additional space characters, new line characters, are also counted.
// Comments:
//      Characters in a page form a "stream", inside the stream, each character has an index.
//      We will use the index parameters in many of FPDFTEXT functions. The first character in the page
//      has an index value of zero.
//
var
  FPDFText_CountChars: function(text_page: FPDF_TEXTPAGE): Integer; stdcall;

// Function: FPDFText_GetUnicode
//      Get Unicode of a character in a page.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      index      -  Zero-based index of the character.
// Return value:
//      The Unicode of the particular character.
//      If a character is not encoded in Unicode and Foxit engine can't convert to Unicode,
//      the return value will be zero.
//
var
  FPDFText_GetUnicode: function(text_page: FPDF_TEXTPAGE; index: Integer): WideChar; stdcall;

// Function: FPDFText_GetFontSize
//      Get the font size of a particular character.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      index      -  Zero-based index of the character.
// Return value:
//      The font size of the particular character, measured in points (about 1/72 inch).
//      This is the typographic size of the font (so called "em size").
//
var
  FPDFText_GetFontSize: function(text_page: FPDF_TEXTPAGE; index: Integer): Double; stdcall;

// Function: FPDFText_GetCharBox
//      Get bounding box of a particular character.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      index      -  Zero-based index of the character.
//      left       -  Pointer to a double number receiving left position of the character box.
//      right      -  Pointer to a double number receiving right position of the character box.
//      bottom     -  Pointer to a double number receiving bottom position of the character box.
//      top        -  Pointer to a double number receiving top position of the character box.
// Return Value:
//      None.
// Comments:
//      All positions are measured in PDF "user space".
//
var
  FPDFText_GetCharBox: procedure(text_page: FPDF_TEXTPAGE; index: Integer; var left, right, bottom, top: Double); stdcall;

// Function: FPDFText_GetCharIndexAtPos
//      Get the index of a character at or nearby a certain position on the page.
// Parameters:
//      text_page   -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      x           -  X position in PDF "user space".
//      y           -  Y position in PDF "user space".
//      xTolerance  -  An x-axis tolerance value for character hit detection, in point unit.
//      yTolerance  -  A y-axis tolerance value for character hit detection, in point unit.
// Return Value:
//      The zero-based index of the character at, or nearby the point (x,y).
//      If there is no character at or nearby the point, return value will be -1.
//      If an error occurs, -3 will be returned.
//
var
  FPDFText_GetCharIndexAtPos: function(text_page: FPDF_TEXTPAGE; x, y, xTorelance, yTolerance: Double): Integer; stdcall;

// Function: FPDFText_GetText
//      Extract unicode text string from the page.
// Parameters:
//      text_page    -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      start_index  -  Index for the start characters.
//      count        -  Number of characters to be extracted.
//      result       -  A buffer (allocated by application) receiving the extracted unicodes.
//                      The size of the buffer must be able to hold the number of characters plus a terminator.
// Return Value:
//      Number of characters written into the result buffer, including the trailing terminator.
// Comments:
//      This function ignores characters without unicode information.
//
var
  FPDFText_GetText: function(text_page: FPDF_TEXTPAGE; start_index, count: Integer; result: PWideChar): Integer; stdcall;

// Function: FPDFText_CountRects
//      Count number of rectangular areas occupied by a segment of texts.
// Parameters:
//      text_page    -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      start_index  -  Index for the start characters.
//      count        -  Number of characters.
// Return value:
//      Number of rectangles. Zero for error.
// Comments:
//      This function, along with FPDFText_GetRect can be used by applications to detect the position
//      on the page for a text segment, so proper areas can be highlighted or something.
//      FPDFTEXT will automatically merge small character boxes into bigger one if those characters
//      are on the same line and use same font settings.
//
var
  FPDFText_CountRects: function(text_page: FPDF_TEXTPAGE; start_index, count: Integer): Integer; stdcall;

// Function: FPDFText_GetRect
//      Get a rectangular area from the result generated by FPDFText_CountRects.
// Parameters:
//      text_page   -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      rect_index  -  Zero-based index for the rectangle.
//      left        -  Pointer to a double value receiving the rectangle left boundary.
//      top         -  Pointer to a double value receiving the rectangle top boundary.
//      right       -  Pointer to a double value receiving the rectangle right boundary.
//      bottom      -  Pointer to a double value receiving the rectangle bottom boundary.
// Return Value:
//      None.
//
var
  FPDFText_GetRect: procedure(text_page: FPDF_TEXTPAGE; rect_index: Integer; var left, top, right, bottom: Double); stdcall;

// Function: FPDFText_GetBoundedText
//      Extract unicode text within a rectangular boundary on the page.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      left       -  Left boundary.
//      top        -  Top boundary.
//      right      -  Right boundary.
//      bottom     -  Bottom boundary.
//      buffer     -  A unicode buffer.
//      buflen     -  Number of characters (not bytes) for the buffer, excluding an additional terminator.
// Return Value:
//      If buffer is NULL or buflen is zero, return number of characters (not bytes) needed,
//      otherwise, return number of characters copied into the buffer.
//
var
  FPDFText_GetBoundedText: function(text_page: FPDF_TEXTPAGE; left, top, right, bottom: Double;
    buffer: PWideChar; buflen: Integer): Integer; stdcall;

const
  // Flags used by FPDFText_FindStart function.
  FPDF_MATCHCASE      = $00000001;    //If not set, it will not match case by default.
  FPDF_MATCHWHOLEWORD = $00000002;    //If not set, it will not match the whole word by default.

// Function: FPDFText_FindStart
//      Start a search.
// Parameters:
//      text_page    -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      findwhat     -  A unicode match pattern.
//      flags        -  Option flags.
//      start_index  -  Start from this character. -1 for end of the page.
// Return Value:
//      A handle for the search context. FPDFText_FindClose must be called to release this handle.
//
var
  FPDFText_FindStart: function(text_page: FPDF_TEXTPAGE; findwhat: FPDF_WIDESTRING; flags: LongWord;
    start_index: Integer): FPDF_SCHHANDLE; stdcall;

// Function: FPDFText_FindNext
//      Search in the direction from page start to end.
// Parameters:
//      handle    -  A search context handle returned by FPDFText_FindStart.
// Return Value:
//      Whether a match is found.
//
var
  FPDFText_FindNext: function(handle: FPDF_SCHHANDLE): FPDF_BOOL; stdcall;

// Function: FPDFText_FindPrev
//      Search in the direction from page end to start.
// Parameters:
//      handle    -  A search context handle returned by FPDFText_FindStart.
// Return Value:
//      Whether a match is found.
//
var
  FPDFText_FindPrev: function(handle: FPDF_SCHHANDLE): FPDF_BOOL; stdcall;

// Function: FPDFText_GetSchResultIndex
//      Get the starting character index of the search result.
// Parameters:
//      handle    -  A search context handle returned by FPDFText_FindStart.
// Return Value:
//      Index for the starting character.
//
var
  FPDFText_GetSchResultIndex: function(handle: FPDF_SCHHANDLE): Integer; stdcall;

// Function: FPDFText_GetSchCount
//      Get the number of matched characters in the search result.
// Parameters:
//      handle    -  A search context handle returned by FPDFText_FindStart.
// Return Value:
//      Number of matched characters.
//
var
  FPDFText_GetSchCount: function(handle: FPDF_SCHHANDLE): Integer; stdcall;

// Function: FPDFText_FindClose
//      Release a search context.
// Parameters:
//      handle    -  A search context handle returned by FPDFText_FindStart.
// Return Value:
//      None.
//
var
  FPDFText_FindClose: procedure(handle: FPDF_SCHHANDLE); stdcall;

// Function: FPDFLink_LoadWebLinks
//      Prepare information about weblinks in a page.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return Value:
//      A handle to the page's links information structure.
//      NULL if something goes wrong.
// Comments:
//      Weblinks are those links implicitly embedded in PDF pages. PDF also has a type of
//      annotation called "link", FPDFTEXT doesn't deal with that kind of link.
//      FPDFTEXT weblink feature is useful for automatically detecting links in the page
//      contents. For example, things like "http://www.foxitsoftware.com" will be detected,
//      so applications can allow user to click on those characters to activate the link,
//      even the PDF doesn't come with link annotations.
//
//      FPDFLink_CloseWebLinks must be called to release resources.
//
var
  FPDFLink_LoadWebLinks: function(text_page: FPDF_TEXTPAGE): FPDF_PAGELINK; stdcall;

// Function: FPDFLink_CountWebLinks
//      Count number of detected web links.
// Parameters:
//      link_page  -  Handle returned by FPDFLink_LoadWebLinks.
// Return Value:
//      Number of detected web links.
//
var
  FPDFLink_CountWebLinks: function(link_page: FPDF_PAGELINK): Integer; stdcall;

// Function: FPDFLink_GetURL
//      Fetch the URL information for a detected web link.
// Parameters:
//      link_page    -  Handle returned by FPDFLink_LoadWebLinks.
//      link_index  -  Zero-based index for the link.
//      buffer      -  A unicode buffer.
//      buflen      -  Number of characters (not bytes) for the buffer, including an additional terminator.
// Return Value:
//      If buffer is NULL or buflen is zero, return number of characters (not bytes and an additional terminator is also counted) needed,
//      otherwise, return number of characters copied into the buffer.
//
var
  FPDFLink_GetURL: function(link_page: FPDF_PAGELINK; link_index: Integer; buffer: PWideChar; buflen: Integer): Integer; stdcall;

// Function: FPDFLink_CountRects
//      Count number of rectangular areas for the link.
// Parameters:
//      link_page   -  Handle returned by FPDFLink_LoadWebLinks.
//      link_index  -  Zero-based index for the link.
// Return Value:
//      Number of rectangular areas for the link.
//
var
  FPDFLink_CountRects: function(link_page: FPDF_PAGELINK; link_index: Integer): Integer; stdcall;

// Function: FPDFLink_GetRect
//      Fetch the boundaries of a rectangle for a link.
// Parameters:
//      link_page   -  Handle returned by FPDFLink_LoadWebLinks.
//      link_index  -  Zero-based index for the link.
//      rect_index  -  Zero-based index for a rectangle.
//      left        -  Pointer to a double value receiving the rectangle left boundary.
//      top         -  Pointer to a double value receiving the rectangle top boundary.
//      right       -  Pointer to a double value receiving the rectangle right boundary.
//      bottom      -  Pointer to a double value receiving the rectangle bottom boundary.
// Return Value:
//      None.
//
var
  FPDFLink_GetRect: procedure(link_page: FPDF_PAGELINK; link_index, rect_index: Integer;
    var left, top, right, bottom: Double); stdcall;

// Function: FPDFLink_CloseWebLinks
//      Release resources used by weblink feature.
// Parameters:
//      link_page  -  Handle returned by FPDFLink_LoadWebLinks.
// Return Value:
//      None.
//
var
  FPDFLink_CloseWebLinks: procedure(link_page: FPDF_PAGELINK); stdcall;

// *** _FPDF_SEARCH_EX_H ***

// Function: FPDFText_GetCharIndexFromTextIndex
//    Get the actually char index in text_page's internal char list.
// Parameters:
//      text_page   -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      nTextIndex  -  The index of the text in the string get from FPDFText_GetText.
//  Return value:
//      The index of the character in internal charlist. -1 for error.
var
  FPDFText_GetCharIndexFromTextIndex: function(text_page: FPDF_TEXTPAGE; nTextIndex: Integer): Integer; stdcall;

// *** _FPDF_PROGRESSIVE_H_ ***
const
  //Flags for progressive process status.
  FPDF_RENDER_READER         = 0;
  FPDF_RENDER_TOBECOUNTINUED = 1;
  FPDF_RENDER_DONE           = 2;
  FPDF_RENDER_FAILED         = 3;

//IFPDF_RENDERINFO interface.
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

    //A user defined data pointer, used by user's application. Can be NULL.
    user: Pointer;
  end;
  PIFSDKPause = ^TIFSDKPause;
  TIFSDKPause = IFSDK_PAUSE;

// Function: FPDF_RenderPageBitmap_Start
//      Start to render page contents to a device independent bitmap progressively.
// Parameters:
//      bitmap    -  Handle to the device independent bitmap (as the output buffer).
//                   Bitmap handle can be created by FPDFBitmap_Create function.
//      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//      start_x   -  Left pixel position of the display area in the bitmap coordinate.
//      start_y   -  Top pixel position of the display area in the bitmap coordinate.
//      size_x    -  Horizontal size (in pixels) for displaying the page.
//      size_y    -  Vertical size (in pixels) for displaying the page.
//      rotate    -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                   2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//      flags     -  0 for normal display, or combination of flags defined above.
//      pause     -  The IFSDK_PAUSE interface.A callback mechanism allowing the page rendering process
// Return value:
//      Rendering Status. See flags for progressive process status for the details.
//
var
  FPDF_RenderPageBitmap_Start: function(bitmap: FPDF_BITMAP; page: FPDF_PAGE;
    start_x, start_y, size_x, size_y: Integer; rotate: Integer; flags: Integer;
    pause: PIFSDK_PAUSE): Integer; stdcall;

// Function: FPDF_RenderPage_Continue
//      Continue rendering a PDF page.
// Parameters:
//      page    -  Handle to the page. Returned by FPDF_LoadPage function.
//      pause   -  The IFSDK_PAUSE interface.A callback mechanism allowing the page rendering process
//                 to be paused before it's finished. This can be NULL if you don't want to pause.
// Return value:
//      The rendering status. See flags for progressive process status for the details.
var
  FPDF_RenderPage_Continue: function(page: FPDF_PAGE; pause: PIFSDK_PAUSE): Integer; stdcall;

// Function: FPDF_RenderPage_Close
//      Release the resource allocate during page rendering. Need to be called after finishing rendering or
//      cancel the rendering.
// Parameters:
//      page    -  Handle to the page. Returned by FPDF_LoadPage function.
// Return value:
//      NULL
var
  FPDF_RenderPage_Close: procedure(page: FPDF_PAGE); stdcall;

// *** _FPDFDOC_H_ ***

// Function: FPDFBookmark_GetFirstChild
//      Get the first child of a bookmark item, or the first top level bookmark item.
// Parameters:
//      document  -  Handle to the document. Returned by FPDF_LoadDocument or FPDF_LoadMemDocument.
//      bookmark  -  Handle to the current bookmark. Can be NULL if you want to get the first top level item.
// Return value:
//      Handle to the first child or top level bookmark item. NULL if no child or top level bookmark found.
//
var
  FPDFBookmark_GetFirstChild: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_BOOKMARK; stdcall;

// Function: FPDFBookmark_GetNextSibling
//      Get next bookmark item at the same level.
// Parameters:
//      document  -  Handle to the document. Returned by FPDF_LoadDocument or FPDF_LoadMemDocument.
//      bookmark  -  Handle to the current bookmark. Cannot be NULL.
// Return value:
//      Handle to the next bookmark item at the same level. NULL if this is the last bookmark at this level.
//
var
  FPDFBookmark_GetNextSibling: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_BOOKMARK; stdcall;

// Function: FPDFBookmark_GetTitle
//      Get title of a bookmark.
// Parameters:
//      bookmark  -  Handle to the bookmark.
//      buffer    -  Buffer for the title. Can be NULL.
//      buflen    -  The length of the buffer in bytes. Can be 0.
// Return value:
//      Number of bytes the title consumes, including trailing zeros.
// Comments:
//      Regardless of the platform, the title is always in UTF-16LE encoding. That means the buffer
//      can be treated as an array of WORD (on Intel and compatible CPUs), each WORD representing the Unicode of
//      a character(some special Unicode may take 2 WORDs).The string is followed by two bytes of zero
//      indicating the end of the string.
//
//      The return value always indicates the number of bytes required for the buffer, even if no buffer is specified
//      or the buffer size is less then required. In these cases, the buffer will not be modified.
//
var
  FPDFBookmark_GetTitle: function(bookmark: FPDF_BOOKMARK; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

// Function: FPDFBookmark_Find
//      Find a bookmark in the document, using the bookmark title.
// Parameters:
//      document  -  Handle to the document. Returned by FPDF_LoadDocument or FPDF_LoadMemDocument.
//      title     -  The UTF-16LE encoded Unicode string for the bookmark title to be searched. Can't be NULL.
// Return value:
//      Handle to the found bookmark item. NULL if the title can't be found.
// Comments:
//      It always returns the first found bookmark if more than one bookmarks have the same title.
//
var
  FPDFBookmark_Find: function(document: FPDF_DOCUMENT; title: FPDF_WIDESTRING): FPDF_BOOKMARK; stdcall;

// Function: FPDFBookmark_GetDest
//      Get the destination associated with a bookmark item.
// Parameters:
//      document  -  Handle to the document.
//      bookmark  -  Handle to the bookmark.
// Return value:
//      Handle to the destination data. NULL if no destination is associated with this bookmark.
//
var
  FPDFBookmark_GetDest: function(document: FPDF_DOCUMENT; bookmark: FPDF_BOOKMARK): FPDF_DEST; stdcall;

// Function: FPDFBookmark_GetAction
//      Get the action associated with a bookmark item.
// Parameters:
//      bookmark  -  Handle to the bookmark.
// Return value:
//      Handle to the action data. NULL if no action is associated with this bookmark. In this case, the
//      application should try FPDFBookmark_GetDest.
//
var
  FPDFBookmark_GetAction: function(bookmark: FPDF_BOOKMARK): FPDF_ACTION; stdcall;

const
  PDFACTION_UNSUPPORTED = 0;    // Unsupported action type.
  PDFACTION_GOTO        = 1;    // Go to a destination within current document.
  PDFACTION_REMOTEGOTO  = 2;    // Go to a destination within another document.
  PDFACTION_URI         = 3;    // Universal Resource Identifier, including web pages and
                                // other Internet based resources.
  PDFACTION_LAUNCH      = 4;    // Launch an application or open a file.

// Function: FPDFAction_GetType
//      Get type of an action.
// Parameters:
//      action    -  Handle to the action.
// Return value:
//      A type number as defined above.
//
var
  FPDFAction_GetType: function(action: FPDF_ACTION): LongWord; stdcall;

// Function: FPDFAction_GetDest
//      Get destination of an action.
// Parameters:
//      document  -  Handle to the document.
//      action    -  Handle to the action. It must be a GOTO or REMOTEGOTO action.
// Return value:
//      Handle to the destination data.
// Comments:
//      In case of remote goto action, the application should first use FPDFAction_GetFilePath to
//      get file path, then load that particular document, and use its document handle to call this
//      function.
//
var
  FPDFAction_GetDest: function(document: FPDF_DOCUMENT; action: FPDF_ACTION): FPDF_DEST; stdcall;

// Function: FPDFAction_GetURIPath
//      Get URI path of a URI action.
// Parameters:
//      document  -  Handle to the document.
//      action    -  Handle to the action. Must be a URI action.
//      buffer    -  A buffer for output the path string. Can be NULL.
//      buflen    -  The length of the buffer, number of bytes. Can be 0.
// Return value:
//      Number of bytes the URI path consumes, including trailing zeros.
// Comments:
//      The URI path is always encoded in 7-bit ASCII.
//
//      The return value always indicated number of bytes required for the buffer, even when there is
//      no buffer specified, or the buffer size is less then required. In this case, the buffer will not
//      be modified.
//
var
  FPDFAction_GetURIPath: function(document: FPDF_DOCUMENT; action: FPDF_ACTION; buffer: Pointer; buflen: LongWord): LongWord; stdcall;

// Function: FPDFDest_GetPageIndex
//      Get page index of a destination.
// Parameters:
//      document  -  Handle to the document.
//      dest      -  Handle to the destination.
// Return value:
//      The page index. Starting from 0 for the first page.
//
var
  FPDFDest_GetPageIndex: function(document: FPDF_DOCUMENT; dest: FPDF_DEST): LongWord; stdcall;

// Function: FPDFLink_GetLinkAtPoint
//      Find a link at specified point on a document page.
// Parameters:
//      page   -  Handle to the document page.
//      x      -  The x coordinate of the point, specified in page coordinate system.
//      y      -  The y coordinate of the point, specified in page coordinate system.
// Return value:
//      Handle to the link. NULL if no link found at that point.
// Comments:
//      The point coordinates are specified in page coordinate system. You can convert coordinates
//      from screen system to page system using FPDF_DeviceToPage functions.
//
var
  FPDFLink_GetLinkAtPoint: function(page: FPDF_PAGE; x, y: Double): FPDF_LINK; stdcall;

// Function: FPDFLink_GetDest
//      Get destination info of a link.
// Parameters:
//      document  -  Handle to the document.
//      link      -  Handle to the link. Returned by FPDFLink_GetLinkAtPoint.
// Return value:
//      Handle to the destination. NULL if there is no destination associated with the link, in this case
//      the application should try FPDFLink_GetAction.
//
var
  FPDFLink_GetDest: function(document: FPDF_DOCUMENT; link: FPDF_LINK): FPDF_DEST; stdcall;

// Function: FPDFLink_GetAction
//      Get action info of a link.
// Parameters:
//      link    -  Handle to the link.
// Return value:
//      Handle to the action. NULL if there is no action associated with the link.
//
var
  FPDFLink_GetAction: function(link: FPDF_LINK): FPDF_ACTION; stdcall;

// Function: FPDFLink_Enumerate
//      This function would enumerate all the link annotations in a single PDF page.
// Parameters:
//      page[in]          -  Handle to the page.
//      startPos[in,out]  -  The start position to enumerate the link annotations, which should be specified to start from
//                        -  0 for the first call, and would receive the next position for enumerating to start from.
//      linkAnnot[out]    -  Receive the link handle.
// Return value:
//      TRUE if succceed, else False;
//
var
  FPDFLink_Enumerate: function(page: FPDF_PAGE; var startPos: Integer; linkAnnot: PFPDF_LINK): FPDF_BOOL; stdcall;

// Function: FPDFLink_GetAnnotRect
//      Get the annotation rectangle. (Specified by the ¡°Rect¡± entry of annotation dictionary).
// Parameters:
//      linkAnnot[in]  -  Handle to the link annotation.
//      rect[out]      -  The annotation rect.
// Return value:
//      TRUE if succceed, else False;
//
var
  FPDFLink_GetAnnotRect: function(linkAnnot: FPDF_LINK; rect: PFS_RECTF): FPDF_BOOL; stdcall;

// Function: FPDFLink_CountQuadPoints
//      Get the count of quadrilateral points to the link annotation.
// Parameters:
//      linkAnnot[in]  -  Handle to the link annotation.
// Return value:
//      The count of quadrilateral points.
//
var
  FPDFLink_CountQuadPoints: function(linkAnnot: FPDF_LINK): Integer; stdcall;

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

// Function: FPDFLink_GetQuadPoints
//      Get the quadrilateral points for the specified index in the link annotation.
// Parameters:
//      linkAnnot[in]    -  Handle to the link annotation.
//      quadIndex[in]    -  The specified quad points index.
//      quadPoints[out]  -  Receive the quadrilateral points.
// Return value:
//      True if succeed, else False.
//
var
  FPDFLink_GetQuadPoints: function(linkAnnot: FPDF_LINK; quadIndex: Integer; quadPoints: PFS_QUADPOINTSF): FPDF_BOOL; stdcall;

// Function: FPDF_GetMetaText
//      Get a text from meta data of the document. Result is encoded in UTF-16LE.
// Parameters:
//      doc      -  Handle to a document
//      tag      -  The tag for the meta data. Currently, It can be "Title", "Author",
//                  "Subject", "Keywords", "Creator", "Producer", "CreationDate", or "ModDate".
//                  For detailed explanation of these tags and their respective values,
//                  please refer to PDF Reference 1.6, section 10.2.1, "Document Information Dictionary".
//      buffer   -  A buffer for output the title. Can be NULL.
//      buflen   -  The length of the buffer, number of bytes. Can be 0.
// Return value:
//      Number of bytes the title consumes, including trailing zeros.
// Comments:
//      No matter on what platform, the title is always output in UTF-16LE encoding, which means the buffer
//      can be regarded as an array of WORD (on Intel and compatible CPUs), each WORD represent the Unicode of
//      a character (some special Unicode may take 2 WORDs). The string is followed by two bytes of zero
//      indicating end of the string.
//
//      The return value always indicated number of bytes required for the buffer, even when there is
//      no buffer specified, or the buffer size is less then required. In this case, the buffer will not
//      be modified.
//
var
  FPDF_GetMetaText: function(doc: FPDF_DOCUMENT; tag: FPDF_BYTESTRING; buffer: Pointer; buflen: LongWord): LongWord; stdcall;


// *** _FPDF_SYSFONTINFO_H ***
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
  PFPDFSysFontInfo = ^TFPDFSysFontInfo;
  TFPDFSysFontInfo = FPDF_SYSFONTINFO;

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
//*      Get default system font info interface for current platform
//* Comments:
//*      For some platforms Foxit SDK implement a default version of system font info interface.
//*      The default implementation can be used in FPDF_SetSystemFontInfo function.
//* Parameters:
//*      None
//* Return Value:
//*      Pointer to a FPDF_SYSFONTINFO structure describing the default interface.
//*      Or NULL if the platform doesn't have a default interface.
//*      Application should call FPDF_FreeMemory to free the returned pointer.
//**
var
  FPDF_GetDefaultSystemFontInfo: function(): FPDF_SYSFONTINFO; stdcall;

// *** _FPDF_EXT_H_ ***
const
  //flags for type of unsupport object.
  FPDF_UNSP_DOC_XFAFORM               = 1;
  FPDF_UNSP_DOC_PORTABLECOLLECTION    = 2;
  FPDF_UNSP_DOC_ATTACHMENT            = 3;
  FPDF_UNSP_DOC_SECURITY              = 4;
  FPDF_UNSP_DOC_SHAREDREVIEW          = 5;
  FPDF_UNSP_DOC_SHAREDFORM_ACROBAT    = 6;
  FPDF_UNSP_DOC_SHAREDFORM_FILESYSTEM = 7;
  FPDF_UNSP_DOC_SHAREDFORM_EMAIL      = 8;
  FPDF_UNSP_ANNOT_3DANNOT             = 11;
  FPDF_UNSP_ANNOT_MOVIE               = 12;
  FPDF_UNSP_ANNOT_SOUND               = 13;
  FPDF_UNSP_ANNOT_SCREEN_MEDIA        = 14;
  FPDF_UNSP_ANNOT_SCREEN_RICHMEDIA    = 15;
  FPDF_UNSP_ANNOT_ATTACHMENT          = 16;
  FPDF_UNSP_ANNOT_SIG                 = 17;

type
  PUNSUPPORT_INFO = ^UNSUPPORT_INFO;
  UNSUPPORT_INFO = record
    //**
    //* Version number of the interface. Currently must be 1.
    //**
    version: Integer;
    //**
    //* Method: FSDK_UnSupport_Handler
    //*       UnSupport Object process handling function.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      Yes
    //* Parameters:
    //*    pThis    -  Pointer to the interface structure itself.
    //*    nType    -  The type of unsupportObject
    //*   Return value:
    //*     None.
    //**

    FSDK_UnSupport_Handler: procedure(pThis: PUNSUPPORT_INFO; nType: Integer); cdecl;
  end;
  PUnsupportInfo = ^TUnsupportInfo;
  TUnsupportInfo = UNSUPPORT_INFO;

//**
//* Function: FSDK_SetUnSpObjProcessHandler
//*       Setup A UnSupport Object process handler for foxit sdk.
//* Parameters:
//*      unsp_info    -  Pointer to a UNSUPPORT_INFO structure.
//* Return Value:
//*      TRUE means successful. FALSE means fails.
//**
var
  FSDK_SetUnSpObjProcessHandler: function(unsp_info: PUNSUPPORT_INFO): FPDF_BOOL; stdcall;

const
  //flags for page mode.

  //Unknown value
  PAGEMODE_UNKNOWN        = -1;
  //Neither document outline nor thumbnail images visible
  PAGEMODE_USENONE        = 0;
  //Document outline visible
  PAGEMODE_USEOUTLINES    = 1;
  //Thumbnial images visible
  PAGEMODE_USETHUMBS      = 2;
  //Full-screen mode, with no menu bar, window controls, or any other window visible
  PAGEMODE_FULLSCREEN     = 3;
  //Optional content group panel visible
  PAGEMODE_USEOC          = 4;
  //Attachments panel visible
  PAGEMODE_USEATTACHMENTS = 5;

//**
//* Function: FPDFDoc_GetPageMode
//*       Get the document's PageMode(How the document should be displayed when opened)
//* Parameters:
//*      doc    -  Handle to document. Returned by FPDF_LoadDocument function.
//* Return Value:
//*      The flags for page mode.
//**
var
  FPDFDoc_GetPageMode: function(document: FPDF_DOCUMENT): Integer; stdcall;


// *** _FPDF_DATAAVAIL_H ***

// The result of the process which check linearized PDF.
const
  FSDK_IS_LINEARIZED     = 1;
  FSDK_NOT_LINEARIZED    = 0;
  FSDK_UNKNOW_LINEARIZED = -1;

type
  //**
  //* Interface: FX_FILEAVAIL
  //*      Interface for checking whether the section of the file is available.
  //**
  PFX_FILEAVAIL = ^FX_FILEAVAIL;
  FX_FILEAVAIL = record
    //**
    //* Version number of the interface. Currently must be 1.
    //**
    version: Integer;

    //**
    //* Method: IsDataAvail
    //*    Report whether the specified data section is available. A section is available only if all bytes in the section is available.
    //* Interface Version:
    //*    1
    //* Implementation Required:
    //*    Yes
    //* Parameters:
    //*    pThis     -  Pointer to the interface structure itself.
    //*    offset    -  The offset of the data section in the file.
    //*    size      -  The size of the data section
    //* Return Value:
    //*    true means the specified data section is available.
    //* Comments:
    //*    Called by Foxit SDK to check whether the data section is ready.
    //**
    IsDataAvail: function(pThis: PFX_FILEAVAIL; offset, size: SIZE_T): ByteBool; cdecl;
  end;
  PFXFileAvail = ^TFXFileAvail;
  TFXFileAvail = FX_FILEAVAIL;

  FPDF_AVAIL = ^__FPDF_PTRREC;

//**
//* Function: FPDFAvail_Create
//*      Create a document availability provider.
//*
//* Parameters:
//*      file_avail  -  Pointer to file availability interface to check availability of file data.
//*      file        -  Pointer to a file access interface for reading data from file.
//* Return value:
//*      A handle to the document availability provider. NULL for error.
//* Comments:
//*      Application must call FPDFAvail_Destroy when done with the availability provider.
//**
var
  FPDFAvail_Create: function(file_avail: PFX_FILEAVAIL; fileaccess: PFPDF_FILEACCESS): FPDF_AVAIL; stdcall;

//**
//* Function: FPDFAvail_Destroy
//*      Destroy a document availibity provider.
//*
//* Parameters:
//*      avail    -  Handle to document availability provider returned by FPDFAvail_Create
//* Return Value:
//*      None.
//**
var
  FPDFAvail_Destroy: procedure(avail: FPDF_AVAIL); stdcall;

//**
//* Interface: FX_DOWNLOADHINTS
//*      Download hints interface. Used to receive hints for further downloading.
//**
type
  PFX_DOWNLOADHINTS = ^FX_DOWNLOADHINTS;
  FX_DOWNLOADHINTS = record
    //**
    //* Version number of the interface. Currently must be 1.
    //**
    version: Integer;

    //**
    //* Method: AddSegment
    //*    Add a section to be downloaded.
    //* Interface Version:
    //*    1
    //* Implementation Required:
    //*    Yes
    //* Parameters:
    //*    pThis    -  Pointer to the interface structure itself.
    //*    offset   -  The offset of the hint reported to be downloaded.
    //*    size     -  The size of the hint reported to be downloaded.
    //* Return Value:
    //*    None.
    //* Comments:
    //*    Called by Foxit SDK to report some downloading hints for download manager.
    //*    The position and size of section may be not accurate, part of the section might be already available.
    //*    The download manager must deal with that to maximize download efficiency.
    //**
    AddSegment: procedure(pThis: PFX_DOWNLOADHINTS; offset, size: SIZE_T); cdecl;
  end;
  PFXDownloadHints = ^TFXDownloadHints;
  TFXDownloadHints = FX_DOWNLOADHINTS;

//**
//* Function: FPDFAvail_IsDocAvail
//*      Check whether the document is ready for loading, if not, get download hints.
//*
//* Parameters:
//*      avail    -  Handle to document availability provider returned by FPDFAvail_Create
//*      hints    -  Pointer to a download hints interface, receiving generated hints
//* Return value:
//*      Non-zero for page is fully available, 0 for page not yet available.
//* Comments:
//*      The application should call this function whenever new data arrived, and process all the
//*      generated download hints if any, until the function returns non-zero value. Then the
//*      application can call FPDFAvail_GetDocument() to get a document handle.
//**
var
  FPDFAvail_IsDocAvail: function(avail: FPDF_AVAIL; hints: PFX_DOWNLOADHINTS): Integer; stdcall;

//**
//* Function: FPDFAvail_GetDocument
//*      Get document from the availability provider.
//*
//* Parameters:
//*      avail    -  Handle to document availability provider returned by FPDFAvail_Create
//*     password  -  Optional password for decrypting the PDF file.
//* Return value:
//*      Handle to the document.
//* Comments:
//*      After FPDFAvail_IsDocAvail() returns TRUE, the application should call this function to
//*      get the document handle. To close the document, use FPDF_CloseDocument function.
//**
var
  FPDFAvail_GetDocument: function(avail: FPDF_AVAIL; password: FPDF_BYTESTRING): FPDF_DOCUMENT; stdcall;

//**
//* Function: FPDFAvail_GetFirstPageNum
//*      Get page number for the first available page in a linearized PDF
//*
//* Parameters:
//*      doc      -  A document handle returned by FPDFAvail_GetDocument
//* Return Value:
//*      Zero-based index for the first available page.
//* Comments:
//*      For most linearized PDFs, the first available page would be just the first page, however,
//*      some PDFs might make other page to be the first available page.
//*      For non-linearized PDF, this function will always return zero.
//**
var
  FPDFAvail_GetFirstPageNum: function(doc: FPDF_DOCUMENT): Integer; stdcall;

//**
//* Function: FPDFAvail_IsPageAvail
//*      Check whether a page is ready for loading, if not, get download hints.
//*
//* Parameters:
//*      avail       -  Handle to document availability provider returned by FPDFAvail_Create
//*      page_index  -  Index number of the page. 0 for the first page.
//*      hints       -  Pointer to a download hints interface, receiving generated hints
//* Return value:
//*      Non-zero for page is fully available, 0 for page not yet available.
//* Comments:
//*      This function call be called only after FPDFAvail_GetDocument if called.
//*      The application should call this function whenever new data arrived, and process all the
//*      generated download hints if any, until the function returns non-zero value. Then the
//*      application can perform page loading.
//**
var
  FPDFAvail_IsPageAvail: function(avail: FPDF_AVAIL; page_index: Integer; hints: PFX_DOWNLOADHINTS): Integer; stdcall;

//**
//* Function: FPDFAvail_ISFormAvail
//*      Check whether Form data is ready for init, if not, get download hints.
//*
//* Parameters:
//*      avail    -  Handle to document availability provider returned by FPDFAvail_Create
//*      hints    -  Pointer to a download hints interface, receiving generated hints
//* Return value:
//*      Non-zero for Form data is fully available, 0 for Form data not yet available.
//*      Details: -1 - error, the input parameter not correct, such as hints is null.
//*               0  - data not available
//*               1  - data available
//*               2  - no form data.
//* Comments:
//*      This function call be called only after FPDFAvail_GetDocument if called.
//*      The application should call this function whenever new data arrived, and process all the
//*      generated download hints if any, until the function returns non-zero value. Then the
//*      application can perform page loading. Recommend to call FPDFDOC_InitFormFillEnvironment
//*      after the function returns non-zero value.
//**
var
  FPDFAvail_IsFormAvail: function(avail: FPDF_AVAIL; hints: PFX_DOWNLOADHINTS): Integer; stdcall;

//**
//* Function: FPDFAvail_IsLinearized
//*      To check whether a document is Linearized PDF file.
//*
//* Parameters:
//*      avail    -  Handle to document availability provider returned by FPDFAvail_Create
//* Return value:
//*      return TRUE means the document is linearized PDF else not.
//*      FSDK_IS_LINEARIZED is a linearize file.
//*      FSDK_NOT_LINEARIZED is not a linearize file.
//*      FSDK_UNKNOW_LINEARIZED don't know whether the file is a linearize file.
//* Comments:
//*      It return TRUE/FALSE as soon as we have first 1K data.   If the file's size less than
//*      1K,we don't known whether the PDF is a linearized file.
//*
//**
var
  FPDFAvail_IsLinearized: function(avail: FPDF_AVAIL): FPDF_BOOL; stdcall;


// *** _FPDFORMFILL_H ***
type
  FPDF_FORMHANDLE = ^__FPDF_PTRREC;

  PIPDF_JsPlatform = ^IPDF_JsPlatform;
  IPDF_JsPlatform = record
    //**
    //* Version number of the interface. Currently must be 1.
    //**
    version: Integer;

    //**
    //* Method: app_alert
    //*      pop up a dialog to show warning or hint.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself
    //*      Msg      -  A string containing the message to be displayed.
    //*      Title    -  The title of the dialog.
    //*      Type     -  The stype of button group.
    //*                  0-OK(default);
    //*                  1-OK,Cancel;
    //*                  2-Yes,NO;
    //*                  3-Yes, NO, Cancel.
    //*      nIcon    -  The Icon type.
    //*                  0-Error(default);
    //*                  1-Warning;
    //*                  2-Question;
    //*                  3-Status.
    //* Return Value:
    //*      The return value could be the folowing type:
    //*                  1-OK;
    //*                  2-Cancel;
    //*                  3-NO;
    //*                  4-Yes;
    //**
    app_alert: function(pThis: PIPDF_JsPlatform; Msg, Title: FPDF_WIDESTRING; nType: Integer; Icon: Integer): Integer; cdecl;

    //**
    //* Method: app_beep
    //*      Causes the system to play a sound.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself
    //*      nType    -  The sound type.
    //*                  0 - Error
    //*                  1 - Warning
    //*                  2 - Question
    //*                  3 - Status
    //*                  4 - Default (default value)
    //* Return Value:
    //*      None
    //**
    app_beep: procedure(pThis: PIPDF_JsPlatform; nType: Integer); cdecl;

    //**
    //* Method: app_response
    //*      Displays a dialog box containing a question and an entry field for the user to reply to the question.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis      -  Pointer to the interface structure itself
    //*      Question   -  The question to be posed to the user.
    //*      Title      -  The title of the dialog box.
    //*      Default    -  A default value for the answer to the question. If not specified, no default value is presented.
    //*      cLabel     -  A short string to appear in front of and on the same line as the edit text field.
    //*      bPassword  -  If true, indicates that the user's response should show as asterisks (*) or bullets (?) to mask the response, which might be sensitive information. The default is false.
    //*      response   -  A string buffer allocated by SDK, to receive the user's response.
    //*      length     -  The length of the buffer, number of bytes. Currently, It's always be 2048.
    //* Return Value:
    //*    Number of bytes the complete user input would actually require, not including trailing zeros, regardless of the value of the length
    //*    parameter or the presence of the response buffer.
    //* Comments:
    //*    No matter on what platform, the response buffer should be always written using UTF-16LE encoding. If a response buffer is
    //*    present and the size of the user input exceeds the capacity of the buffer as specified by the length parameter, only the
    //*    first "length" bytes of the user input are to be written to the buffer.
    //**
    app_response: function(pThis: PIPDF_JsPlatform; Question, Title, Default, cLabel: FPDF_WIDESTRING; bPassword: FPDF_BOOL; response: Pointer; length: Integer): Integer; cdecl;

    //**
    //* Method: Doc_getFilePath
    //*      Get the file path of the current document.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis     -  Pointer to the interface structure itself
    //*      filePath  -  The string buffer to receive the file path. Can be NULL.
    //*      length    -  The length of the buffer, number of bytes. Can be 0.
    //* Return Value:
    //*    Number of bytes the filePath consumes, including trailing zeros.
    //* Comments:
    //*    The filePath should be always input in local encoding.
    //*
    //*    The return value always indicated number of bytes required for the buffer, even when there is
    //*    no buffer specified, or the buffer size is less then required. In this case, the buffer will not
    //*    be modified.
    //**
    Doc_getFilePath: function(pThis: PIPDF_JsPlatform; filePath: Pointer; length: Integer): Integer; cdecl;

    //**
    //* Method: Doc_mail
    //*      Mails the data buffer as an attachment to all recipients, with or without user interaction.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis     -  Pointer to the interface structure itself
    //*      mailData  -  Pointer to the data buffer to be sent.Can be NULL.
    //*      length    -  The size,in bytes, of the buffer pointed by mailData parameter.Can be 0.
    //*      bUI       -  If true, the rest of the parameters are used in a compose-new-message window that is displayed to the user. If false, the cTo parameter is required and all others are optional.
    //*      To        -  A semicolon-delimited list of recipients for the message.
    //*      Subject   -  The subject of the message. The length limit is 64 KB.
    //*      CC        -  A semicolon-delimited list of CC recipients for the message.
    //*      BCC       -  A semicolon-delimited list of BCC recipients for the message.
    //*      Msg       -  The content of the message. The length limit is 64 KB.
    //* Return Value:
    //*      None.
    //* Comments:
    //*      If the parameter mailData is NULL or length is 0, the current document will be mailed as an attachment to all recipients.
    //**
    Doc_mail: procedure(pThis: PIPDF_JsPlatform; mailData: Pointer; length: Integer; bUI: FPDF_BOOL; sTo, subject, CC, BCC, Msg: FPDF_WIDESTRING); cdecl;

    //**
    //* Method: Doc_print
    //*      Prints all or a specific number of pages of the document.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis          -  Pointer to the interface structure itself.
    //*      bUI            -  If true, will cause a UI to be presented to the user to obtain printing information and confirm the action.
    //*      nStart         -  A 0-based index that defines the start of an inclusive range of pages.
    //*      nEnd           -  A 0-based index that defines the end of an inclusive page range.
    //*      bSilent        -  If true, suppresses the cancel dialog box while the document is printing. The default is false.
    //*      bShrinkToFit   -  If true, the page is shrunk (if necessary) to fit within the imageable area of the printed page.
    //*      bPrintAsImage  -  If true, print pages as an image.
    //*      bReverse       -  If true, print from nEnd to nStart.
    //*      bAnnotations   -  If true (the default), annotations are printed.
    //**
    Doc_print: procedure(pThis: PIPDF_JsPlatform; bUI: FPDF_BOOKMARK; nStart, nEnd: Integer; bSilent, bShrinkToFit, bPrintAsImage, bReverse, bAnnotations: FPDF_BOOL); cdecl;

    //**
    //* Method: Doc_submitForm
    //*      Send the form data to a specified URL.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis     -  Pointer to the interface structure itself
    //*      formData  -  Pointer to the data buffer to be sent.
    //*      length    -  The size,in bytes, of the buffer pointed by formData parameter.
    //*      URL       -  The URL to send to.
    //* Return Value:
    //*      None.
    //*
    //**
    Doc_submitForm: procedure(pThis: PIPDF_JsPlatform; formData: Pointer; length: Integer; URL: FPDF_WIDESTRING); cdecl;

    //**
    //* Method: Doc_gotoPage
    //*      Jump to a specified page.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis     -  Pointer to the interface structure itself
    //*      nPageNum  -  The specified page number, zero for the first page.
    //* Return Value:
    //*      None.
    //*
    //**
    Doc_gotoPage: procedure(pThis: PIPDF_JsPlatform; nPageNum: Integer); cdecl;

    //**
    //* Method: Field_browse
    //*      Show a file selection dialog, and return the selected file path.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis     -  Pointer to the interface structure itself.
    //*      filePath  -  Pointer to the data buffer to receive the file path.Can be NULL.
    //*      length    -  The length of the buffer, number of bytes. Can be 0.
    //* Return Value:
    //*    Number of bytes the filePath consumes, including trailing zeros.
    //* Comments:
    //*    The filePath shoule be always input in local encoding.
    //**
    Field_browse: function(pThis: PIPDF_JsPlatform; filePath: Pointer; length: Integer): Integer; cdecl;

    //**
    //*  pointer to FPDF_FORMFILLINFO interface.
    //**
    m_pFormfillinfo: Pointer;
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
//* Declares of a pointer type to the callback function for the FFI_SetTimer method.
//* Parameters:
//*      idEvent    -  Identifier of the timer.
//* Return value:
//*      None.
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

  PFPDF_FORMFILLINFO = ^FPDF_FORMFILLINFO;
  FPDF_FORMFILLINFO = record
    //**
    //* Version number of the interface. Currently must be 1.
    //**
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
    Release: procedure(pThis: PFPDF_FORMFILLINFO); cdecl;

    //**
    //* Method: FFI_Invalidate
    //*      Invalidate the client area within the specified rectangle.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself.
    //*      page     -  Handle to the page. Returned by FPDF_LoadPage function.
    //*      left     -  Left position of the client area in PDF page coordinate.
    //*      top      -  Top  position of the client area in PDF page coordinate.
    //*      right    -  Right position of the client area in PDF page  coordinate.
    //*      bottom   -  Bottom position of the client area in PDF page coordinate.
    //* Return Value:
    //*      None.
    //*
    //*comments:
    //*      All positions are measured in PDF "user space".
    //*      Implementation should call FPDF_RenderPageBitmap() function for repainting a specified page area.
    //**
    FFI_Invalidate: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; left, top, right, bottom: Double); cdecl;

    //**
    //* Method: FFI_OutputSelectedRect
    //*      When user is taking the mouse to select texts on a form field, this callback function will keep
    //*      returning the selected areas to the implementation.
    //*
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      No
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself.
    //*      page     -  Handle to the page. Returned by FPDF_LoadPage function.
    //*      left     -  Left position of the client area in PDF page coordinate.
    //*      top      -  Top  position of the client area in PDF page coordinate.
    //*      right    -  Right position of the client area in PDF page  coordinate.
    //*      bottom   -  Bottom position of the client area in PDF page coordinate.
    //* Return Value:
    //*      None.
    //*
    //* comments:
    //*      This CALLBACK function is useful for implementing special text selection effect. Implementation should
    //*      first records the returned rectangles, then draw them one by one at the painting period, last,remove all
    //*      the recorded rectangles when finish painting.
    //**
    FFI_OutputSelectedRect: procedure(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; left, top, right, bottom: Double); cdecl;

    //**
    //* Method: FFI_SetCursor
    //*      Set the Cursor shape.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*     pThis        -  Pointer to the interface structure itself.
    //*     nCursorType  -  Cursor type. see Flags for Cursor type for the details.
    //* Return value:
    //*     None.
    //**
    FFI_SetCursor: procedure(pThis: PFPDF_FORMFILLINFO; nCursorType: Integer); cdecl;

    //**
    //* Method: FFI_SetTimer
    //*      This method installs a system timer. A time-out value is specified,
    //*      and every time a time-out occurs, the system passes a message to
    //*      the TimerProc callback function.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis        -  Pointer to the interface structure itself.
    //*      uElapse      -  Specifies the time-out value, in milliseconds.
    //*      lpTimerFunc  -  A pointer to the callback function-TimerCallback.
    //* Return value:
    //*      The timer identifier of the new timer if the function is successful.
    //*      An application passes this value to the FFI_KillTimer method to kill
    //*      the timer. Nonzero if it is successful; otherwise, it is zero.
    //**
    FFI_SetTimer: function(pThis: PFPDF_FORMFILLINFO; uElapse: Integer; lpTimerFunc: TFPDFTimerCallback): Integer; cdecl;

    //**
    //* Method: FFI_KillTimer
    //*      This method kills the timer event identified by nIDEvent, set by an earlier call to FFI_SetTimer.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*    pThis    -  Pointer to the interface structure itself.
    //*     nTimerID  -  The timer ID return by FFI_SetTimer function.
    //*   Return value:
    //*     None.
    //**
    FFI_KillTimer: procedure(pThis: PFPDF_FORMFILLINFO; nTimerID: Integer); cdecl;

    //**
    //* Method: FFI_GetLocalTime
    //*      This method receives the current local time on the system.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*    pThis    -  Pointer to the interface structure itself.
    //*   Return value:
    //*     None.
    //**
    FFI_GetLocalTime: function(pThis: PFPDF_FORMFILLINFO): FPDF_SYSTEMTIME; cdecl;

    //**
    //* Method: FFI_OnChange
    //*      This method will be invoked to notify implementation when the value of any FormField on the document had been changed.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      no
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself.
    //* Return value:
    //*     None.
    //* */
    FFI_OnChange: procedure(pThis: PFPDF_FORMFILLINFO); cdecl;

    //**
    //* Method: FFI_GetPage
    //*      This method receives the page pointer associated with a specified page index.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis       -  Pointer to the interface structure itself.
    //*      document    -  Handle to document. Returned by FPDF_LoadDocument function.
    //*      nPageIndex  -  Index number of the page. 0 for the first page.
    //* Return value:
    //*      Handle to the page. Returned by FPDF_LoadPage function.
    //* Comments:
    //*      In some cases, the document-level JavaScript action may refer to a page which hadn't been loaded yet.
    //*      To successfully run the javascript action, implementation need to load the page for SDK.
    //**
    FFI_GetPage: function(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT; nPageIndex: Integer): FPDF_PAGE; cdecl;

    //**
    //* Method: FFI_GetCurrentPage
    //*    This method receives the current page pointer.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*    pThis    -  Pointer to the interface structure itself.
    //*    document  -  Handle to document. Returned by FPDF_LoadDocument function.
    //* Return value:
    //*     Handle to the page. Returned by FPDF_LoadPage function.
    //**
    FFI_GetCurrentPage: function(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT): FPDF_PAGE; cdecl;

    //**
    //* Method: FFI_GetRotation
    //*      This method receives currently rotation of the page view.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis    -  Pointer to the interface structure itself.
    //*      page     -  Handle to page. Returned by FPDF_LoadPage function.
    //* Return value:
    //*      The page rotation. Should be 0(0 degree),1(90 degree),2(180 degree),3(270 degree), in a clockwise direction.
    //**
    FFI_GetRotation: function(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE): Integer; cdecl;

    //**
    //* Method: FFI_ExecuteNamedAction
    //*      This method will execute an named action.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      yes
    //* Parameters:
    //*      pThis        -  Pointer to the interface structure itself.
    //*      namedAction  -  A byte string which indicates the named action, terminated by 0.
    //* Return value:
    //*      None.
    //* Comments:
    //*      See the named actions description of <<PDF Reference, version 1.7>> for more details.
    //**
    FFI_ExecuteNamedAction: procedure(pThis: PFPDF_FORMFILLINFO; namedAction: FPDF_BYTESTRING); cdecl;

    //**
    //* @brief This method will be called when a text field is getting or losing a focus.
    //*
    //* @param[in] pThis    Pointer to the interface structure itself.
    //* @param[in] value    The string value of the form field, in UTF-16LE format.
    //* @param[in] valueLen  The length of the string value, number of characters (not bytes).
    //* @param[in] is_focus  True if the form field is getting a focus, False for losing a focus.
    //*
    //* @return None.
    //*
    //* @note Currently,only support text field and combobox field.
    //**
    FFI_SetTextFieldFocus: procedure(pThis: PFPDF_FORMFILLINFO; value: FPDF_WIDESTRING; valueLen: FPDF_DWORD; is_focus: FPDF_BOOL); cdecl;

    //**
    //* Method: FFI_DoURIAction
    //*      This action resolves to a uniform resource identifier.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      No
    //* Parameters:
    //*      pThis      -  Pointer to the interface structure itself.
    //*      bsURI      -  A byte string which indicates the uniform resource identifier, terminated by 0.
    //* Return value:
    //*      None.
    //* Comments:
    //*      See the URI actions description of <<PDF Reference, version 1.7>> for more details.
    //**
    FFI_DoURIAction: procedure(pThis: PFPDF_FORMFILLINFO; bsURI: FPDF_WIDESTRING); cdecl;

    //**
    //* Method: FFI_DoGoToAction
    //*      This action changes the view to a specified destination.
    //* Interface Version:
    //*      1
    //* Implementation Required:
    //*      No
    //* Parameters:
    //*      pThis        -  Pointer to the interface structure itself.
    //*      nPageIndex   -  The index of the PDF page.
    //*      zoomMode     -  The zoom mode for viewing page.See Macros "PDFZOOM_XXX" defined in "fpdfdoc.h".
    //*      fPosArray    -  The float array which carries the position info.
    //*      sizeofArray  -  The size of float array.
    //* Return value:
    //*      None.
    //* Comments:
    //*      See the Destinations description of <<PDF Reference, version 1.7>> in 8.2.1 for more details.
    //**
    FFI_DoGoToAction: procedure(pThis: PFPDF_FORMFILLINFO; nPageIndex, zoomMode: Integer; fPosArray: PSingle; sizeofArray: Integer); cdecl;

    //**
    //*  pointer to IPDF_JSPLATFORM interface
    //**/
    m_pJsPlatform: PIPDF_JSPLATFORM;
  end;
  PFPDFFormFillInfo = ^TFPDFFormFillInfo;
  TFPDFFormFillInfo = FPDF_FORMFILLINFO;


//**
//* Function: FPDFDOC_InitFormFillEnvironment
//*      Init form fill environment.
//* Comments:
//*      This function should be called before any form fill operation.
//* Parameters:
//*      document       -  Handle to document. Returned by FPDF_LoadDocument function.
//*      pFormFillInfo  -  Pointer to a FPDF_FORMFILLINFO structure.
//* Return Value:
//*      Return handler to the form fill module. NULL means fails.
//**
var
  FPDFDOC_InitFormFillEnvironment: function(document: FPDF_DOCUMENT; formInfo: PFPDF_FORMFILLINFO): FPDF_FORMHANDLE; stdcall;

//**
//* Function: FPDFDOC_ExitFormFillEnvironment
//*      Exit form fill environment.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//* Return Value:
//*      NULL.
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
//*      aaType      -   The type of the additional-actions which defined above.
//* Return Value:
//*      NONE
//* Comments:
//*      This method will do nothing if there is no document additional-action corresponding to the specified aaType.
//**
var
  FORM_DoDocumentAAction: procedure(hHandle: FPDF_FORMHANDLE; aaType: Integer); stdcall;

// Additional-action types of page object
const
  FPDFPAGE_AACTION_OPEN  = 0;    // /O -- An action to be performed when the page is opened
  FPDFPAGE_AACTION_CLOSE = 1;    // /C -- An action to be performed when the page is closed

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

// Field Types
const
  FPDF_FORMFIELD_UNKNOWN     = 0;   // Unknown.
  FPDF_FORMFIELD_PUSHBUTTON  = 1;   // push button type.
  FPDF_FORMFIELD_CHECKBOX    = 2;   // check box type.
  FPDF_FORMFIELD_RADIOBUTTON = 3;   // radio button type.
  FPDF_FORMFIELD_COMBOBOX    = 4;   // combo box type.
  FPDF_FORMFIELD_LISTBOX     = 5;   // list box type.
  FPDF_FORMFIELD_TEXTFIELD   = 6;   // text field type.

//**
//* Function: FPDFPage_HasFormFieldAtPoint
//*      Check the form filed position by point.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      page       -  Handle to the page. Returned by FPDF_LoadPage function.
//*      page_x     -  X position in PDF "user space".
//*      page_y     -  Y position in PDF "user space".
//* Return Value:
//*      Return the type of the formfiled; -1 indicates no fields.
//**
var
  FPDFPage_HasFormFieldAtPoint: function(hHandle: FPDF_FORMHANDLE; page: FPDF_PAGE; page_x, page_y: Double): Integer; stdcall;

//**
//* Function: FPDF_SetFormFieldHighlightColor
//*      Set the highlight color of specified or all the form fields in the document.
//* Parameters:
//*      hHandle    -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      doc        -  Handle to the document. Returned by FPDF_LoadDocument function.
//*      fieldType  -  A 32-bit integer indicating the type of a form field(defined above).
//*      color      -  The highlight color of the form field.Constructed by 0xxxrrggbb.
//* Return Value:
//*      NONE.
//* Comments:
//*      When the parameter fieldType is set to zero, the highlight color will be applied to all the form fields in the
//*      document.
//*      Please refresh the client window to show the highlight immediately if necessary.
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
//*      Render FormFeilds on a page to a device independent bitmap.
//* Parameters:
//*      hHandle   -  Handle to the form fill module. Returned by FPDFDOC_InitFormFillEnvironment.
//*      bitmap    -  Handle to the device independent bitmap (as the output buffer).
//*                   Bitmap handle can be created by FPDFBitmap_Create function.
//*      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//*      start_x   -  Left pixel position of the display area in the device coordinate.
//*      start_y   -  Top pixel position of the display area in the device coordinate.
//*      size_x    -  Horizontal size (in pixels) for displaying the page.
//*      size_y    -  Vertical size (in pixels) for displaying the page.
//*      rotate    -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//*                   2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//*      flags     -  0 for normal display, or combination of flags defined above.
//* Return Value:
//*      None.
//* Comments:
//*      This method is designed to only render annotations and FormFields on the page.
//*      Without FPDF_ANNOT specified for flags, Rendering functions such as FPDF_RenderPageBitmap or FPDF_RenderPageBitmap_Start will only render page contents(without annotations) to a bitmap.
//*      In order to implement the FormFill functions,Implementation should call this method after rendering functions finish rendering the page contents.
//**
var
  FPDF_FFLDraw: procedure(hHandle: FPDF_FORMHANDLE; bitmap: FPDF_BITMAP; page: FPDF_PAGE; start_x, start_y, size_x, size_y, rotate, flags: Integer); stdcall;


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


type
  TImportFuncRec = record
    P: PPointer;
    N: PAnsiChar;
    Quirk: Boolean;
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
  ImportFuncs: array[0..135 {$IFDEF MSWINDOWS}+ 1{$ENDIF}] of TImportFuncRec = (
    (P: @@FPDF_InitLibrary;                   N: UC + 'FPDF_InitLibrary' + AT0),
    (P: @@FPDF_DestroyLibrary;                N: UC + 'FPDF_DestroyLibrary' + AT0),
    (P: @@FPDF_SetSandBoxPolicy;              N: UC + 'FPDF_SetSandBoxPolicy' + AT8),
    (P: @@FPDF_LoadDocument;                  N: UC + 'FPDF_LoadDocument' + AT8),
    (P: @@FPDF_LoadMemDocument;               N: UC + 'FPDF_LoadMemDocument' + AT12),
    (P: @@FPDF_LoadCustomDocument;            N: UC + 'FPDF_LoadCustomDocument' + AT8),
    (P: @@FPDF_GetFileVersion;                N: UC + 'FPDF_GetFileVersion' + AT8),
    (P: @@FPDF_GetLastError;                  N: UC + 'FPDF_GetLastError' + AT0),
    (P: @@FPDF_GetDocPermissions;             N: UC + 'FPDF_GetDocPermissions' + AT4),
    (P: @@FPDF_GetSecurityHandlerRevision;    N: UC + 'FPDF_GetSecurityHandlerRevision' + AT4),
    (P: @@FPDF_GetPageCount;                  N: UC + 'FPDF_GetPageCount' + AT4),
    (P: @@FPDF_LoadPage;                      N: UC + 'FPDF_LoadPage' + AT8),
    (P: @@FPDF_GetPageWidth;                  N: UC + 'FPDF_GetPageWidth' + AT4),
    (P: @@FPDF_GetPageHeight;                 N: UC + 'FPDF_GetPageHeight' + AT4),
    (P: @@FPDF_GetPageSizeByIndex;            N: UC + 'FPDF_GetPageSizeByIndex' + AT16),
    {$IFDEF MSWINDOWS}
    (P: @@FPDF_RenderPage;                    N: UC + 'FPDF_RenderPage' + AT32),
    {$ENDIF MSWINDOWS}
    (P: @@FPDF_RenderPageBitmap;              N: UC + 'FPDF_RenderPageBitmap' + AT32),
    (P: @@FPDF_ClosePage;                     N: UC + 'FPDF_ClosePage' + AT4),
    (P: @@FPDF_CloseDocument;                 N: UC + 'FPDF_CloseDocument' + AT4),
    (P: @@FPDF_DeviceToPage;                  N: UC + 'FPDF_DeviceToPage' + AT40),
    (P: @@FPDF_PageToDevice;                  N: UC + 'FPDF_PageToDevice' + AT48),
    (P: @@FPDFBitmap_Create;                  N: UC + 'FPDFBitmap_Create' + AT12),
    (P: @@FPDFBitmap_CreateEx;                N: UC + 'FPDFBitmap_CreateEx' + AT20),
    (P: @@FPDFBitmap_FillRect;                N: UC + 'FPDFBitmap_FillRect' + AT24),
    (P: @@FPDFBitmap_GetBuffer;               N: UC + 'FPDFBitmap_GetBuffer' + AT4),
    (P: @@FPDFBitmap_GetWidth;                N: UC + 'FPDFBitmap_GetWidth' + AT4),
    (P: @@FPDFBitmap_GetHeight;               N: UC + 'FPDFBitmap_GetHeight' + AT4),
    (P: @@FPDFBitmap_GetStride;               N: UC + 'FPDFBitmap_GetStride' + AT4),
    (P: @@FPDFBitmap_Destroy;                 N: UC + 'FPDFBitmap_Destroy' + AT4),
    (P: @@FPDF_VIEWERREF_GetPrintScaling;     N: UC + 'FPDF_VIEWERREF_GetPrintScaling' + AT4),
    (P: @@FPDF_VIEWERREF_GetNumCopies;        N: UC + 'FPDF_VIEWERREF_GetNumCopies' + AT4),
    (P: @@FPDF_VIEWERREF_GetPrintPageRange;   N: UC + 'FPDF_VIEWERREF_GetPrintPageRange' + AT4),
    (P: @@FPDF_VIEWERREF_GetDuplex;           N: UC + 'FPDF_VIEWERREF_GetDuplex' + AT4),
    (P: @@FPDF_CountNamedDests;               N: UC + 'FPDF_CountNamedDests' + AT4),
    (P: @@FPDF_GetNamedDestByName;            N: UC + 'FPDF_GetNamedDestByName' + AT8),
    (P: @@FPDF_GetNamedDest;                  N: UC + 'FPDF_GetNamedDest' + AT16),
    (P: @@FPDF_CreateNewDocument;             N: UC + 'FPDF_CreateNewDocument' + AT0),
    (P: @@FPDFPage_New;                       N: UC + 'FPDFPage_New' + AT24),
    (P: @@FPDFPage_Delete;                    N: UC + 'FPDFPage_Delete' + AT8),
    (P: @@FPDFPage_GetRotation;               N: UC + 'FPDFPage_GetRotation' + AT4),
    (P: @@FPDFPage_SetRotation;               N: UC + 'FPDFPage_SetRotation' + AT8),
    (P: @@FPDFPage_InsertObject;              N: UC + 'FPDFPage_InsertObject' + AT8),
    (P: @@FPDFPage_CountObject;               N: UC + 'FPDFPage_CountObject' + AT4),
    (P: @@FPDFPage_GetObject;                 N: UC + 'FPDFPage_GetObject' + AT8),
    (P: @@FPDFPage_HasTransparency;           N: UC + 'FPDFPage_HasTransparency' + AT4),
    (P: @@FPDFPage_GenerateContent;           N: UC + 'FPDFPage_GenerateContent' + AT4),
    (P: @@FPDFPageObj_HasTransparency;        N: UC + 'FPDFPageObj_HasTransparency' + AT4),
    (P: @@FPDFPageObj_Transform;              N: UC + 'FPDFPageObj_Transform' + AT52),
    (P: @@FPDFPage_TransformAnnots;           N: UC + 'FPDFPage_TransformAnnots' + AT52),
    
    (P: @@FPDFPageObj_NewImageObj;            N: UC + 'FPDFPageObj_NewImageObj' + AT4; Quirk: True),
    (P: @@FPDFPageObj_NewImageObj;            N: UC + 'FPDFPageObj_NewImgeObj' + AT4), // typo in name (older pdfium.dll versions)
    
    (P: @@FPDFImageObj_LoadJpegFile;          N: UC + 'FPDFImageObj_LoadJpegFile' + AT16),
    (P: @@FPDFImageObj_SetMatrix;             N: UC + 'FPDFImageObj_SetMatrix' + AT52),
    (P: @@FPDFImageObj_SetBitmap;             N: UC + 'FPDFImageObj_SetBitmap' + AT16),
    (P: @@FPDF_ImportPages;                   N: UC + 'FPDF_ImportPages' + AT16),
    (P: @@FPDF_CopyViewerPreferences;         N: UC + 'FPDF_CopyViewerPreferences' + AT8),
    (P: @@FPDF_SaveAsCopy;                    N: UC + 'FPDF_SaveAsCopy' + AT12),
    (P: @@FPDF_SaveWithVersion;               N: UC + 'FPDF_SaveWithVersion' + AT16),
    (P: @@FPDFPage_Flatten;                   N: UC + 'FPDFPage_Flatten' + AT8),
    (P: @@FPDFText_LoadPage;                  N: UC + 'FPDFText_LoadPage' + AT4),
    (P: @@FPDFText_ClosePage;                 N: UC + 'FPDFText_ClosePage' + AT4),
    (P: @@FPDFText_CountChars;                N: UC + 'FPDFText_CountChars' + AT4),
    (P: @@FPDFText_GetUnicode;                N: UC + 'FPDFText_GetUnicode' + AT8),
    (P: @@FPDFText_GetCharBox;                N: UC + 'FPDFText_GetCharBox' + AT24),
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
    (P: @@FPDFText_GetCharIndexFromTextIndex; N: UC + 'FPDFText_GetCharIndexFromTextIndex' + AT8),
    (P: @@FPDF_RenderPageBitmap_Start;        N: UC + 'FPDF_RenderPageBitmap_Start' + AT36),
    (P: @@FPDF_RenderPage_Continue;           N: UC + 'FPDF_RenderPage_Continue' + AT8),
    (P: @@FPDF_RenderPage_Close;              N: UC + 'FPDF_RenderPage_Close' + AT4),
    (P: @@FPDFBookmark_GetFirstChild;         N: UC + 'FPDFBookmark_GetFirstChild' + AT8),
    (P: @@FPDFBookmark_GetNextSibling;        N: UC + 'FPDFBookmark_GetNextSibling' + AT8),
    (P: @@FPDFBookmark_GetTitle;              N: UC + 'FPDFBookmark_GetTitle' + AT12),
    (P: @@FPDFBookmark_Find;                  N: UC + 'FPDFBookmark_Find' + AT8),
    (P: @@FPDFBookmark_GetDest;               N: UC + 'FPDFBookmark_GetDest' + AT8),
    (P: @@FPDFBookmark_GetAction;             N: UC + 'FPDFBookmark_GetAction' + AT4),
    (P: @@FPDFAction_GetDest;                 N: UC + 'FPDFAction_GetDest' + AT8),
    (P: @@FPDFAction_GetURIPath;              N: UC + 'FPDFAction_GetURIPath' + AT16),
    (P: @@FPDFDest_GetPageIndex;              N: UC + 'FPDFDest_GetPageIndex' + AT8),
    (P: @@FPDFLink_GetLinkAtPoint;            N: UC + 'FPDFLink_GetLinkAtPoint' + AT20),
    (P: @@FPDFLink_GetDest;                   N: UC + 'FPDFLink_GetDest' + AT8),
    (P: @@FPDFLink_GetAction;                 N: UC + 'FPDFLink_GetAction' + AT4),
    (P: @@FPDFLink_Enumerate;                 N: UC + 'FPDFLink_Enumerate' + AT12),
    (P: @@FPDFLink_GetAnnotRect;              N: UC + 'FPDFLink_GetAnnotRect' + AT8),
    (P: @@FPDFLink_CountQuadPoints;           N: UC + 'FPDFLink_CountQuadPoints' + AT4),
    (P: @@FPDFLink_GetQuadPoints;             N: UC + 'FPDFLink_GetQuadPoints' + AT12),
    (P: @@FPDF_GetMetaText;                   N: UC + 'FPDF_GetMetaText' + AT16),
    (P: @@FPDF_AddInstalledFont;              N: UC + 'FPDF_AddInstalledFont' + AT12),
    (P: @@FPDF_SetSystemFontInfo;             N: UC + 'FPDF_SetSystemFontInfo' + AT4),
    (P: @@FPDF_GetDefaultSystemFontInfo;      N: UC + 'FPDF_GetDefaultSystemFontInfo' + AT0),
    (P: @@FSDK_SetUnSpObjProcessHandler;      N: UC + 'FSDK_SetUnSpObjProcessHandler' + AT4),

    (P: @@FPDFDoc_GetPageMode;                N: UC + 'FPDFDoc_GetPageMode' + AT4; Quirk: True),
    (P: @@FPDFDoc_GetPageMode;                N: 'FPDFDoc_GetPageMode'), // no UC, no ATx (older pdfium.dll versions)

    (P: @@FPDFAvail_Create;                   N: UC + 'FPDFAvail_Create' + AT8),
    (P: @@FPDFAvail_Destroy;                  N: UC + 'FPDFAvail_Destroy' + AT4),
    (P: @@FPDFAvail_IsDocAvail;               N: UC + 'FPDFAvail_IsDocAvail' + AT8),
    (P: @@FPDFAvail_GetDocument;              N: UC + 'FPDFAvail_GetDocument' + AT8),
    (P: @@FPDFAvail_GetFirstPageNum;          N: UC + 'FPDFAvail_GetFirstPageNum' + AT4),
    (P: @@FPDFAvail_IsPageAvail;              N: UC + 'FPDFAvail_IsPageAvail' + AT12),
    (P: @@FPDFAvail_IsFormAvail;              N: UC + 'FPDFAvail_IsFormAvail' + AT8),
    (P: @@FPDFAvail_IsLinearized;             N: UC + 'FPDFAvail_IsLinearized' + AT4),
    (P: @@FPDFDOC_InitFormFillEnvironment;    N: UC + 'FPDFDOC_InitFormFillEnvironment' + AT8),
    (P: @@FPDFDOC_ExitFormFillEnvironment;    N: UC + 'FPDFDOC_ExitFormFillEnvironment' + AT4),
    (P: @@FORM_OnAfterLoadPage;               N: UC + 'FORM_OnAfterLoadPage' + AT8),
    (P: @@FORM_OnBeforeClosePage;             N: UC + 'FORM_OnBeforeClosePage' + AT8),
    (P: @@FORM_DoDocumentJSAction;            N: UC + 'FORM_DoDocumentJSAction' + AT4),
    (P: @@FORM_DoDocumentOpenAction;          N: UC + 'FORM_DoDocumentOpenAction' + AT4),
    (P: @@FORM_DoDocumentAAction;             N: UC + 'FORM_DoDocumentAAction' + AT8),
    (P: @@FORM_DoPageAAction;                 N: UC + 'FORM_DoPageAAction' + AT12),
    (P: @@FORM_OnMouseMove;                   N: UC + 'FORM_OnMouseMove' + AT28),
    (P: @@FORM_OnLButtonDown;                 N: UC + 'FORM_OnLButtonDown' + AT28),
    (P: @@FORM_OnLButtonUp;                   N: UC + 'FORM_OnLButtonUp' + AT28),
    (P: @@FORM_OnKeyDown;                     N: UC + 'FORM_OnKeyDown' + AT16),
    (P: @@FORM_OnKeyUp;                       N: UC + 'FORM_OnKeyUp' + AT16),
    (P: @@FORM_OnChar;                        N: UC + 'FORM_OnChar' + AT16),
    (P: @@FORM_ForceToKillFocus;              N: UC + 'FORM_ForceToKillFocus' + AT4),

    (P: @@FPDFPage_HasFormFieldAtPoint;       N: UC + 'FPDFPage_HasFormFieldAtPoint' + AT24; Quirk: True),
    (P: @@FPDFPage_HasFormFieldAtPoint;       N: UC + 'FPDPage_HasFormFieldAtPoint' + AT24), // typo in name (older pdfium.dll versions)

    (P: @@FPDF_SetFormFieldHighlightColor;    N: UC + 'FPDF_SetFormFieldHighlightColor' + AT12),
    (P: @@FPDF_SetFormFieldHighlightAlpha;    N: UC + 'FPDF_SetFormFieldHighlightAlpha' + AT8),
    (P: @@FPDF_RemoveFormFieldHighlight;      N: UC + 'FPDF_RemoveFormFieldHighlight' + AT4),
    (P: @@FPDF_FFLDraw;                       N: UC + 'FPDF_FFLDraw' + AT36)
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
