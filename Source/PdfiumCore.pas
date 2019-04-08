{$A8,B-,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,T-,U-,V+,X+,Z1}
{$STRINGCHECKS OFF}

unit PdfiumCore;

interface

uses
  Windows, Types, SysUtils, Classes, Contnrs, PdfiumLib, Graphics;

type
  EPdfException = class(Exception);
  EPdfUnsupportedFeatureException = class(EPdfException);
  EPdfArgumentOutOfRange = class(EPdfException);

  TPdfUnsupportedFeatureHandler = procedure(nType: Integer; const Typ: string) of object;

  TPdfDocument = class;
  TPdfPage = class;

  TPdfPoint = record
    X, Y: Double;
    procedure Offset(XOffset, YOffset: Double);
    class function Empty: TPdfPoint; static;
  end;

  TPdfRect = record
  private
    function GetHeight: Double; inline;
    function GetWidth: Double; inline;
    procedure SetHeight(const Value: Double); inline;
    procedure SetWidth(const Value: Double); inline;
  public
    property Width: Double read GetWidth write SetWidth;
    property Height: Double read GetHeight write SetHeight;
    procedure Offset(XOffset, YOffset: Double);

    class function Empty: TPdfRect; static;
  public
    case Integer of
      0: (Left, Top, Right, Bottom: Double);
      1: (TopLeft: TPdfPoint; BottomRight: TPdfPoint);
  end;

  TPdfRectArray = array of TPdfRect;

  TPdfDocumentCustomReadProc = function(Param: Pointer; Position: LongWord; Buffer: PByte; Size: LongWord): Boolean;

  TPdfPageRenderOptionType = (
    proAnnotations,            // Set if annotations are to be rendered.
    proLCDOptimized,           // Set if using text rendering optimized for LCD display.
    proNoNativeText,           // Don't use the native text output available on some platforms
    proGrayscale,              // Grayscale output.
    proNoCatch,                // Set if you don't want to catch exception.
    proLimitedImageCacheSize,  // Limit image cache size.
    proForceHalftone,          // Always use halftone for image stretching.
    proPrinting,               // Render for printing.
    proReverseByteOrder        // Set whether render in a reverse Byte order, this flag only enable when render to a bitmap.
  );
  TPdfPageRenderOptions = set of TPdfPageRenderOptionType;

  TPdfPageRotation = (
    prNormal             = 0,
    pr90Clockwise        = 1,
    pr180                = 2,
    pr90CounterClockwide = 3
  );

  TPdfDocumentSaveOption = (
    dsoIncremental    = 1,
    dsoNoIncremental  = 2,
    dsoRemoveSecurity = 3
  );

  TPdfDocumentLoadOption = (
    dloNormal,   // load the whole file into memory
    dloMMF,      // load the file by using a memory mapped file (file stays open)
    dloOnDemand  // load the file using the custom load function (file stays open)
  );

  TPdfDocumentPageMode = (
    dpmUnknown        = -1, // Unknown value
    dpmUseNone        = 0,  // Neither document outline nor thumbnail images visible
    dpmUseOutlines    = 1,  // Document outline visible
    dpmUseThumbs      = 2,  // Thumbnial images visible
    dpmFullScreen     = 3,  // Full-screen mode, with no menu bar, window controls, or any other window visible
    dpmUseOC          = 4,  // Optional content group panel visible
    dpmUseAttachments = 5   // Attachments panel visible
  );

  TPdfPrintMode = (
    pmEMF = 0,
    pmTextMode = 1,
    pmPostScript2 = 2,
    pmPostScript3 = 3,
    pmPostScriptPassThrough2 = 4,
    pmPostScriptPassThrough3 = 5
  );

  TPdfBitmapFormat = (
    bfGrays = FPDFBitmap_Gray, // Gray scale bitmap, one byte per pixel.
    bfBGR   = FPDFBitmap_BGR,  // 3 bytes per pixel, byte order: blue, green, red.
    bfBGRx  = FPDFBitmap_BGRx, // 4 bytes per pixel, byte order: blue, green, red, unused.
    bfBGRA  = FPDFBitmap_BGRA  // 4 bytes per pixel, byte order: blue, green, red, alpha.
  );

  TPdfFormFieldType = (
    fftUnknown,
    fftPushButton,
    fftCheckBox,
    fftRadioButton,
    fftComboBox,
    fftListBox,
    fftTextField,
    fftSignature
  );

  _TPdfBitmapHideCtor = class(TObject)
  private
    procedure Create;
  end;

  TPdfBitmap = class(_TPdfBitmapHideCtor)
  private
    FBitmap: FPDF_BITMAP;
    FOwnsBitmap: Boolean;
    FWidth: Integer;
    FHeight: Integer;
    FBytesPerScanLine: Integer;
  public
    constructor Create(ABitmap: FPDF_BITMAP; AOwnsBitmap: Boolean = False); overload;
    constructor Create(AWidth, AHeight: Integer; AAlpha: Boolean); overload;
    constructor Create(AWidth, AHeight: Integer; AFormat: TPdfBitmapFormat); overload;
    constructor Create(AWidth, AHeight: Integer; AFormat: TPdfBitmapFormat; ABuffer: Pointer; ABytesPerScanline: Integer); overload;
    destructor Destroy; override;

    procedure FillRect(ALeft, ATop, AWidth, AHeight: Integer; AColor: FPDF_DWORD);
    function GetBuffer: Pointer;

    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property BytesPerScanline: Integer read FBytesPerScanLine;
    property Bitmap: FPDF_BITMAP read FBitmap;
  end;

  PPdfFormFillHandler = ^TPdfFormFillHandler;
  TPdfFormFillHandler = record
    FormFillInfo: FPDF_FORMFILLINFO;
    Document: TPdfDocument;
  end;

  TPdfPage = class(TObject)
  private
    FDocument: TPdfDocument;
    FPage: FPDF_PAGE;
    FWidth: Double;
    FHeight: Double;
    FTransparency: Boolean;
    FRotation: TPdfPageRotation;
    FTextHandle: FPDF_TEXTPAGE;
    FSearchHandle: FPDF_SCHHANDLE;
    FLinkHandle: FPDF_PAGELINK;
    constructor Create(ADocument: TPdfDocument; APage: FPDF_PAGE);
    procedure UpdateMetrics;
    procedure Open;
    procedure SetRotation(const Value: TPdfPageRotation);
    function BeginText: Boolean;
    function BeginWebLinks: Boolean;
    class function GetDrawFlags(const Options: TPdfPageRenderOptions): Integer; static;
    procedure AfterOpen;
    function IsValidForm: Boolean;
    function GetMouseModifier(const Shift: TShiftState): Integer;
    function GetKeyModifier(KeyData: LPARAM): Integer;
    function GetHandle: FPDF_PAGE;
  public
    destructor Destroy; override;
    procedure Close;

    procedure Draw(DC: HDC; X, Y, Width, Height: Integer; Rotate: TPdfPageRotation = prNormal;
      const Options: TPdfPageRenderOptions = []);
    procedure DrawToPdfBitmap(APdfBitmap: TPdfBitmap; X, Y, Width, Height: Integer; Rotate: TPdfPageRotation = prNormal;
      const Options: TPdfPageRenderOptions = []);
    procedure DrawFormToPdfBitmap(APdfBitmap: TPdfBitmap; X, Y, Width, Height: Integer; Rotate: TPdfPageRotation = prNormal;
      const Options: TPdfPageRenderOptions = []);

    function DeviceToPage(X, Y, Width, Height: Integer; DeviceX, DeviceY: Integer; Rotate: TPdfPageRotation = prNormal): TPdfPoint; overload;
    function PageToDevice(X, Y, Width, Height: Integer; PageX, PageY: Double; Rotate: TPdfPageRotation = prNormal): TPoint; overload;
    function DeviceToPage(X, Y, Width, Height: Integer; const R: TRect; Rotate: TPdfPageRotation = prNormal): TPdfRect; overload;
    function PageToDevice(X, Y, Width, Height: Integer; const R: TPdfRect; Rotate: TPdfPageRotation = prNormal): TRect; overload;

    procedure ApplyChanges;

    function FormEventFocus(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventMouseMove(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventLButtonDown(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventLButtonUp(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventKeyDown(KeyCode: Word; KeyData: LPARAM): Boolean;
    function FormEventKeyUp(KeyCode: Word; KeyData: LPARAM): Boolean;
    function FormEventKeyPress(Key: Word; KeyData: LPARAM): Boolean;
    procedure FormEventKillFocus;

    function BeginFind(const SearchString: string; MatchCase, MatchWholeWord: Boolean; FromEnd: Boolean): Boolean;
    function FindNext(var CharIndex, Count: Integer): Boolean;
    function FindPrev(var CharIndex, Count: Integer): Boolean;
    procedure EndFind;

    function GetCharCount: Integer;
    function ReadChar(CharIndex: Integer): WideChar;
    function GetCharFontSize(CharIndex: Integer): Double;
    function GetCharBox(CharIndex: Integer): TPdfRect;
    function GetCharIndexAt(PageX, PageY, ToleranceX, ToleranceY: Double): Integer;
    function ReadText(CharIndex, Count: Integer): string;
    function GetTextAt(const R: TPdfRect): string; overload;
    function GetTextAt(Left, Top, Right, Bottom: Double): string; overload;

    function GetTextRectCount(CharIndex, Count: Integer): Integer;
    function GetTextRect(RectIndex: Integer): TPdfRect;

    function HasFormFieldAtPoint(X, Y: Double): TPdfFormFieldType;

    function GetWebLinkCount: Integer;
    function GetWebLinkURL(LinkIndex: Integer): string;
    function GetWebLinkRectCount(LinkIndex: Integer): Integer;
    function GetWebLinkRect(LinkIndex, RectIndex: Integer): TPdfRect;

    property Handle: FPDF_PAGE read GetHandle;
    property Width: Double read FWidth;
    property Height: Double read FHeight;
    property Transparency: Boolean read FTransparency;
    property Rotation: TPdfPageRotation read FRotation write SetRotation;
  end;

  TPdfFormInvalidateEvent = procedure(Document: TPdfDocument; Page: TPdfPage; const PageRect: TPdfRect) of object;
  TPdfFormOutputSelectedRectEvent = procedure(Document: TPdfDocument; Page: TPdfPage; const PageRect: TPdfRect) of object;
  TPdfFormGetCurrentPage = procedure(Document: TPdfDocument; var CurrentPage: TPdfPage) of object;

  TPdfDocument = class(TObject)
  private type
    PCustomLoadDataRec = ^TCustomLoadDataRec;
    TCustomLoadDataRec = record
      Param: Pointer;
      GetBlock: TPdfDocumentCustomReadProc;
      FileAccess: TFPDFFileAccess;
    end;
  private
    FDocument: FPDF_DOCUMENT;
    FPages: TObjectList;
    FFileName: string;
    FFileHandle: THandle;
    FFileMapping: THandle;
    FBuffer: PByte;
    FBytes: TBytes;
    FClosing: Boolean;
    FUnsupportedFeatures: Boolean;
    FCustomLoadData: PCustomLoadDataRec;

    FForm: FPDF_FORMHANDLE;
    FFormFillHandler: TPdfFormFillHandler;
    FFormFieldHighlightColor: TColor;
    FFormFieldHighlightAlpha: Integer;
    FPrintHidesFormFieldHighlight: Boolean;
    FFormModified: Boolean;
    FOnFormInvalidate: TPdfFormInvalidateEvent;
    FOnFormOutputSelectedRect: TPdfFormOutputSelectedRectEvent;
    FOnFormGetCurrentPage: TPdfFormGetCurrentPage;

    procedure InternLoadFromMem(Buffer: PByte; Size: Integer; const APassword: AnsiString);
    procedure InternLoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; ASize: LongWord; AParam: Pointer; const APassword: AnsiString);
    function GetPage(Index: Integer): TPdfPage;
    function GetPageCount: Integer;
    procedure ExtractPage(APage: TPdfPage);
    function ReloadPage(APage: TPdfPage): FPDF_PAGE;
    function GetPrintScaling: Boolean;
    function GetActive: Boolean;
    procedure CheckActive;
    function GetSecurityHandlerRevision: Integer;
    function GetDocPermissions: Integer;
    function GetFileVersion: Integer;
    function GetPageSize(Index: Integer): TPdfPoint;
    function GetPageMode: TPdfDocumentPageMode;
    function GetNumCopies: Integer;
    procedure DocumentLoaded;
    procedure SetFormFieldHighlightAlpha(Value: Integer);
    procedure SetFormFieldHighlightColor(const Value: TColor);
    function FindPage(Page: FPDF_PAGE): TPdfPage;
    procedure UpdateFormFieldHighlight;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; ASize: LongWord; AParam: Pointer; const APassword: AnsiString = '');
    procedure LoadFromActiveStream(Stream: TStream; const APassword: AnsiString = ''); // Stream must not be released until the document is closed
    procedure LoadFromActiveBuffer(Buffer: Pointer; Size: Integer; const APassword: AnsiString = ''); // Buffer must not be released until the document is closed
    procedure LoadFromBytes(const ABytes: TBytes; const APassword: AnsiString = ''); overload;
    procedure LoadFromBytes(const ABytes: TBytes; AIndex: Integer; ACount: Integer; const APassword: AnsiString = ''); overload;
    procedure LoadFromStream(AStream: TStream; const APassword: AnsiString = '');
    procedure LoadFromFile(const AFileName: string; const APassword: AnsiString = ''; ALoadOptions: TPdfDocumentLoadOption = dloMMF);
    procedure Close;

    procedure SaveToFile(const AFileName: string; Option: TPdfDocumentSaveOption = dsoRemoveSecurity; FileVersion: Integer = -1);
    procedure SaveToStream(Stream: TStream; Option: TPdfDocumentSaveOption = dsoRemoveSecurity; FileVersion: Integer = -1);
    procedure SaveToBytes(var Bytes: TBytes; Option: TPdfDocumentSaveOption = dsoRemoveSecurity; FileVersion: Integer = -1);

    function NewDocument: Boolean;
    function ImportPages(Source: TPdfDocument; const Range: string = ''; Index: Integer = -1): Boolean;
    procedure DeletePage(Index: Integer);
    function NewPage(Width, Height: Double; Index: Integer = -1): TPdfPage;
    function ApplyViewerPreferences(Source: TPdfDocument): Boolean;

    function GetMetaText(const TagName: string): string;
    class function SetPrintMode(PrintMode: TPdfPrintMode): Boolean; static;

    property FileName: string read FFileName;
    property PageCount: Integer read GetPageCount;
    property Pages[Index: Integer]: TPdfPage read GetPage;
    property PageSizes[Index: Integer]: TPdfPoint read GetPageSize;

    property Active: Boolean read GetActive;
    property PrintScaling: Boolean read GetPrintScaling;
    property NumCopies: Integer read GetNumCopies;
    property SecurityHandlerRevision: Integer read GetSecurityHandlerRevision;
    property DocPermissions: Integer read GetDocPermissions;
    property FileVersion: Integer read GetFileVersion;
    property PageMode: TPdfDocumentPageMode read GetPageMode;

    // if UnsupportedFeatures is True, then the document has unsupported features. It is updated
    // after accessing a page.
    property UnsupportedFeatures: Boolean read FUnsupportedFeatures;
    property Handle: FPDF_DOCUMENT read FDocument;
    property FormHandle: FPDF_FORMHANDLE read FForm;

    property FormFieldHighlightColor: TColor read FFormFieldHighlightColor write SetFormFieldHighlightColor default $FFE4DD;
    property FormFieldHighlightAlpha: Integer read FFormFieldHighlightAlpha write SetFormFieldHighlightAlpha default 100;
    property PrintHidesFormFieldHighlight: Boolean read FPrintHidesFormFieldHighlight write FPrintHidesFormFieldHighlight default True;

    property FormModified: Boolean read FFormModified write FFormModified;
    property OnFormInvalidate: TPdfFormInvalidateEvent read FOnFormInvalidate write FOnFormInvalidate;
    property OnFormOutputSelectedRect: TPdfFormOutputSelectedRectEvent read FOnFormOutputSelectedRect write FOnFormOutputSelectedRect;
    property OnFormGetCurrentPage: TPdfFormGetCurrentPage read FOnFormGetCurrentPage write FOnFormGetCurrentPage;
  end;

function SetThreadPdfUnsupportedFeatureHandler(const Handler: TPdfUnsupportedFeatureHandler): TPdfUnsupportedFeatureHandler;

var
  PDFiumDllDir: string = '';

implementation

resourcestring
  RsUnsupportedFeature = 'Function %s not supported';
  RsArgumentsOutOfRange = 'Functions argument "%s" out of range';
  RsDocumentNotActive = 'PDF document is not open';
  RsFileTooLarge = 'PDF file "%s" is too large';

  RsPdfErrorSuccess  = 'No error';
  RsPdfErrorUnknown  = 'Unknown error';
  RsPdfErrorFile     = 'File not found or can''t be opened';
  RsPdfErrorFormat   = 'File is not a PDF document or is corrupted';
  RsPdfErrorPassword = 'Password required oder invalid password';
  RsPdfErrorSecurity = 'Security schema is not support';
  RsPdfErrorPage     = 'Page does not exist or data error';

threadvar
  ThreadPdfUnsupportedFeatureHandler: TPdfUnsupportedFeatureHandler;
  UnsupportedFeatureCurrentDocument: TPdfDocument;

function SetThreadPdfUnsupportedFeatureHandler(const Handler: TPdfUnsupportedFeatureHandler): TPdfUnsupportedFeatureHandler;
begin
  Result := ThreadPdfUnsupportedFeatureHandler;
  ThreadPdfUnsupportedFeatureHandler := Handler;
end;

function GetUnsupportedFeatureName(nType: Integer): string;
begin
  case nType of
    FPDF_UNSP_DOC_XFAFORM:
      Result := 'XFA';

    FPDF_UNSP_DOC_PORTABLECOLLECTION:
      Result := 'Portfolios_Packages';

    FPDF_UNSP_DOC_ATTACHMENT,
    FPDF_UNSP_ANNOT_ATTACHMENT:
      Result := 'Attachment';

    FPDF_UNSP_DOC_SECURITY:
      Result := 'Rights_Management';

    FPDF_UNSP_DOC_SHAREDREVIEW:
      Result := 'Shared_Review';

    FPDF_UNSP_DOC_SHAREDFORM_ACROBAT,
    FPDF_UNSP_DOC_SHAREDFORM_FILESYSTEM,
    FPDF_UNSP_DOC_SHAREDFORM_EMAIL:
      Result := 'Shared_Form';

    FPDF_UNSP_ANNOT_3DANNOT:
      Result := '3D';

    FPDF_UNSP_ANNOT_MOVIE:
      Result := 'Movie';

    FPDF_UNSP_ANNOT_SOUND:
      Result := 'Sound';

    FPDF_UNSP_ANNOT_SCREEN_MEDIA,
    FPDF_UNSP_ANNOT_SCREEN_RICHMEDIA:
      Result := 'Screen';

    FPDF_UNSP_ANNOT_SIG:
      Result := 'Digital_Signature';

  else
    Result := 'Unknown';
  end;
end;

procedure UnsupportedHandler(pThis: PUNSUPPORT_INFO; nType: Integer); cdecl;
var
  Document: TPdfDocument;
begin
  Document := UnsupportedFeatureCurrentDocument;
  if Document <> nil then
    Document.FUnsupportedFeatures := True;

  if Assigned(ThreadPdfUnsupportedFeatureHandler) then
    ThreadPdfUnsupportedFeatureHandler(nType, GetUnsupportedFeatureName(nType));
  //raise EPdfUnsupportedFeatureException.CreateResFmt(@RsUnsupportedFeature, [GetUnsupportedFeatureName]);
end;

var
  PDFiumInitCritSect: TRTLCriticalSection;
  UnsupportInfo: TUnsupportInfo = (
    version: 1;
    FSDK_UnSupport_Handler: UnsupportedHandler;
  );

procedure InitLib;
{$J+}
const
  Initialized: Integer = 0;
{$J-}
begin
  if Initialized = 0 then
  begin
    EnterCriticalSection(PDFiumInitCritSect);
    try
      if Initialized = 0 then
      begin
        InitPDFium(PDFiumDllDir);
        FSDK_SetUnSpObjProcessHandler(@UnsupportInfo);
        Initialized := 1;
      end;
    finally
      LeaveCriticalSection(PDFiumInitCritSect);
    end;
  end;
end;

procedure RaiseLastPdfError;
begin
  case FPDF_GetLastError of
    FPDF_ERR_SUCCESS:
      raise EPdfException.CreateRes(@RsPdfErrorSuccess);
    FPDF_ERR_FILE:
      raise EPdfException.CreateRes(@RsPdfErrorFile);
    FPDF_ERR_FORMAT:
      raise EPdfException.CreateRes(@RsPdfErrorFormat);
    FPDF_ERR_PASSWORD:
      raise EPdfException.CreateRes(@RsPdfErrorPassword);
    FPDF_ERR_SECURITY:
      raise EPdfException.CreateRes(@RsPdfErrorSecurity);
    FPDF_ERR_PAGE:
      raise EPdfException.CreateRes(@RsPdfErrorPage);
  else
    raise EPdfException.CreateRes(@RsPdfErrorUnknown);
  end;
end;

procedure FFI_Invalidate(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; left, top, right, bottom: Double); cdecl;
var
  Handler: PPdfFormFillHandler;
  Pg: TPdfPage;
  R: TPdfRect;
begin
  Handler := PPdfFormFillHandler(pThis);
  if Assigned(Handler.Document.OnFormInvalidate) then
  begin
    Pg := Handler.Document.FindPage(page);
    if Pg <> nil then
    begin
      R.Left := left;
      R.Top := top;
      R.Right := right;
      R.Bottom := bottom;
      Handler.Document.OnFormInvalidate(Handler.Document, Pg, R);
    end;
  end;
end;

procedure FFI_Change(pThis: PFPDF_FORMFILLINFO); cdecl;
var
  Handler: PPdfFormFillHandler;
begin
  Handler := PPdfFormFillHandler(pThis);
  Handler.Document.FormModified := True;
end;

procedure FFI_OutputSelectedRect(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE; left, top, right, bottom: Double); cdecl;
var
  Handler: PPdfFormFillHandler;
  Pg: TPdfPage;
  R: TPdfRect;
begin
  Handler := PPdfFormFillHandler(pThis);
  if Assigned(Handler.Document.OnFormOutputSelectedRect) then
  begin
    Pg := Handler.Document.FindPage(Page);
    if Pg <> nil then
    begin
      R.Left := left;
      R.Top := top;
      R.Right := right;
      R.Bottom := bottom;
      Handler.Document.OnFormOutputSelectedRect(Handler.Document, Pg, R);
    end;
  end;
end;

var
  FFITimers: array of record
    Id: UINT;
    Proc: TFPDFTimerCallback;
  end;
  FFITimersCritSect: TRTLCriticalSection;

procedure FormTimerProc(hwnd: HWND; uMsg: UINT; timerId: UINT; dwTime: DWORD); stdcall;
var
  I: Integer;
  Proc: TFPDFTimerCallback;
begin
  Proc := nil;
  EnterCriticalSection(FFITimersCritSect);
  try
    for I := 0 to Length(FFITimers) - 1 do
    begin
      if FFITimers[I].Id = timerId then
      begin
        Proc := FFITimers[I].Proc;
        Break;
      end;
    end;
  finally
    LeaveCriticalSection(FFITimersCritSect);
  end;

  if Assigned(Proc) then
    Proc(timerId);
end;

function FFI_SetTimer(pThis: PFPDF_FORMFILLINFO; uElapse: Integer; lpTimerFunc: TFPDFTimerCallback): Integer; cdecl;
var
  I: Integer;
  Id: UINT;
begin
  Id := SetTimer(0, 0, uElapse, @FormTimerProc);
  Result := Integer(Id);
  if Id <> 0 then
  begin
    EnterCriticalSection(FFITimersCritSect);
    try
      for I := 0 to Length(FFITimers) - 1 do
      begin
        if FFITimers[I].Id = 0 then
        begin
          FFITimers[I].Id := Id;
          FFITimers[I].Proc := lpTimerFunc;
          Exit;
        end;
      end;
      I := Length(FFITimers);
      SetLength(FFITimers, I + 1);
      FFITimers[I].Id := Id;
      FFITimers[I].Proc := lpTimerFunc;
    finally
      LeaveCriticalSection(FFITimersCritSect);
    end;
  end;
end;

procedure FFI_KillTimer(pThis: PFPDF_FORMFILLINFO; nTimerID: Integer); cdecl;
var
  I: Integer;
begin
  if nTimerID <> 0 then
  begin
    KillTimer(0, nTimerID);

    EnterCriticalSection(FFITimersCritSect);
    try
      for I := 0 to Length(FFITimers) - 1 do
      begin
        if FFITimers[I].Id = UINT(nTimerID) then
        begin
          FFITimers[I].Id := 0;
          FFITimers[I].Proc := nil;
        end;
      end;

      I := Length(FFITimers) - 1;
      while (I >= 0) and (FFITimers[I].Id = 0) do
        Dec(I);
      SetLength(FFITimers, I + 1);
    finally
      LeaveCriticalSection(FFITimersCritSect);
    end;
  end;
end;

function FFI_GetLocalTime(pThis: PFPDF_FORMFILLINFO): FPDF_SYSTEMTIME; cdecl;
begin
  GetLocalTime(PSystemTime(@Result)^);
end;

function FFI_GetPage(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT; nPageIndex: Integer): FPDF_PAGE; cdecl;
var
  Handler: PPdfFormFillHandler;
begin
  Handler := PPdfFormFillHandler(pThis);
  Result := nil;
  if (Handler.Document <> nil) and (Handler.Document.FDocument = document) then
  begin
    if (nPageIndex >= 0) and (nPageIndex < Handler.Document.PageCount) then
      Result := Handler.Document.Pages[nPageIndex].FPage;
  end;
end;

function FFI_GetCurrentPage(pThis: PFPDF_FORMFILLINFO; document: FPDF_DOCUMENT): FPDF_PAGE; cdecl;
var
  Handler: PPdfFormFillHandler;
  Pg: TPdfPage;
begin
  Handler := PPdfFormFillHandler(pThis);
  Result := nil;
  if (Handler.Document <> nil) and (Handler.Document.FDocument = document) and Assigned(Handler.Document.OnFormGetCurrentPage) then
  begin
    Pg := nil;
    Handler.Document.OnFormGetCurrentPage(Handler.Document, Pg);
    Result := nil;
    if Pg <> nil then
      Result := Pg.FPage;
  end;
end;

function FFI_GetRotation(pThis: PFPDF_FORMFILLINFO; page: FPDF_PAGE): Integer; cdecl;
begin
  Result := 0;
end;

procedure FFI_SetCursor(pThis: PFPDF_FORMFILLINFO; nCursorType: Integer); cdecl;
begin
end;

procedure FFI_SetTextFieldFocus(pThis: PFPDF_FORMFILLINFO; value: FPDF_WIDESTRING; valueLen: FPDF_DWORD; is_focus: FPDF_BOOL); cdecl;
begin
end;


{ TPdfRect }

procedure TPdfRect.Offset(XOffset, YOffset: Double);
begin
  Left := Left + XOffset;
  Top := Top + YOffset;
  Right := Right + XOffset;
  Bottom := Bottom + YOffset;
end;

class function TPdfRect.Empty: TPdfRect;
begin
  Result.Left := 0;
  Result.Top := 0;
  Result.Right := 0;
  Result.Bottom := 0;
end;

function TPdfRect.GetHeight: Double;
begin
  Result := Bottom - Top;
end;

function TPdfRect.GetWidth: Double;
begin
  Result := Right - Left;
end;

procedure TPdfRect.SetHeight(const Value: Double);
begin
  Bottom := Top + Value;
end;

procedure TPdfRect.SetWidth(const Value: Double);
begin
  Right := Left + Value;
end;

{ TPdfDocument }

constructor TPdfDocument.Create;
begin
  inherited Create;
  FPages := TObjectList.Create;
  FFileHandle := INVALID_HANDLE_VALUE;
  FFormFieldHighlightColor := $FFE4DD;
  FFormFieldHighlightAlpha := 100;
  FPrintHidesFormFieldHighlight := True;

  InitLib;
end;

destructor TPdfDocument.Destroy;
begin
  Close;
  FPages.Free;
  inherited Destroy;
end;

procedure TPdfDocument.Close;
begin
  FClosing := True;
  try
    FPages.Clear;
    FUnsupportedFeatures := False;

    if FDocument <> nil then
    begin
      if FForm <> nil then
      begin
        FORM_DoDocumentAAction(FForm, FPDFDOC_AACTION_WC);
        FPDFDOC_ExitFormFillEnvironment(FForm);
        FForm := nil;
      end;

      FPDF_CloseDocument(FDocument);
      FDocument := nil;
    end;

    if FCustomLoadData <> nil then
    begin
      Dispose(FCustomLoadData);
      FCustomLoadData := nil;
    end;

    if FFileMapping <> 0 then
    begin
      if FBuffer <> nil then
      begin
        UnmapViewOfFile(FBuffer);
        FBuffer := nil;
      end;
      CloseHandle(FFileMapping);
      FFileMapping := 0;
    end
    else if FBuffer <> nil then
    begin
      FreeMem(FBuffer);
      FBuffer := nil;
    end;
    FBytes := nil;

    if FFileHandle <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FFileHandle);
      FFileHandle := INVALID_HANDLE_VALUE;
    end;

    FFileName := '';
    FFormModified := False;
  finally
    FClosing := False;
  end;
end;

function ReadFromActiveFile(Param: Pointer; Position: LongWord; Buffer: PByte; Size: LongWord): Boolean;
var
  NumRead: DWORD;
begin
  if Buffer <> nil then
  begin
    SetFilePointer(THandle(Param), Position, nil, FILE_BEGIN);
    Result := ReadFile(THandle(Param), Buffer^, Size, NumRead, nil) and (NumRead = Size);
  end
  else
    Result := Size = 0;
end;

procedure TPdfDocument.LoadFromFile(const AFileName: string; const APassword: AnsiString; ALoadOptions: TPdfDocumentLoadOption);
var
  Size, Offset: NativeInt;
  NumRead: DWORD;
  SizeHigh: DWORD;
begin
  Close;

  FFileHandle := CreateFile(PChar(AFileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if FFileHandle = INVALID_HANDLE_VALUE then
    RaiseLastOSError;
  try
    Size := GetFileSize(FFileHandle, @SizeHigh);
    if SizeHigh <> 0 then
      raise EPdfException.CreateResFmt(@RsFileTooLarge, [ExtractFileName(AFileName)]);

    case ALoadOptions of
      dloNormal:
        begin
          if Size > 0 then
          begin
            GetMem(FBuffer, Size);
            Offset := 0;
            while Offset < Size do
            begin
              if ((Size - Offset) and not $FFFFFFFF) <> 0 then
                NumRead := $40000000
              else
                NumRead := Size - Offset;

              if not ReadFile(FFileHandle, FBuffer[Offset], NumRead, NumRead, nil) then
                RaiseLastOSError;
              Inc(Offset, NumRead);
            end;

            InternLoadFromMem(FBuffer, Size, APassword);
          end;
        end;

      dloMMF:
        begin
          FFileMapping := CreateFileMapping(FFileHandle, nil, PAGE_READONLY, 0, Size, nil);
          if FFileMapping = 0 then
            RaiseLastOSError;
          FBuffer := MapViewOfFile(FFileMapping, FILE_MAP_READ, 0, 0, Size);
          if FBuffer = nil then
            RaiseLastOSError;

          InternLoadFromMem(FBuffer, Size, APassword);
        end;

      dloOnDemand:
        InternLoadFromCustom(ReadFromActiveFile, Size, Pointer(FFileHandle), APassword);
    end;
  except
    Close;
    raise;
  end;
  FFileName := AFileName;
end;

procedure TPdfDocument.LoadFromStream(AStream: TStream; const APassword: AnsiString);
var
  Size: NativeInt;
begin
  Close;
  Size := AStream.Size;
  if Size > 0 then
  begin
    GetMem(FBuffer, Size);
    try
      AStream.ReadBuffer(FBuffer^, Size);
      InternLoadFromMem(FBuffer, Size, APassword);
    except
      Close;
      raise;
    end;
  end;
end;

procedure TPdfDocument.LoadFromActiveBuffer(Buffer: Pointer; Size: Integer; const APassword: AnsiString);
begin
  Close;
  InternLoadFromMem(Buffer, Size, APassword);
end;

procedure TPdfDocument.LoadFromBytes(const ABytes: TBytes; const APassword: AnsiString);
begin
  LoadFromBytes(ABytes, 0, Length(ABytes), APassword);
end;

procedure TPdfDocument.LoadFromBytes(const ABytes: TBytes; AIndex, ACount: Integer;
  const APassword: AnsiString);
var
  Len: Integer;
begin
  Close;

  Len := Length(ABytes);
  if AIndex >= Len then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['Index']);
  if AIndex + ACount > Len then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['Count']);

  FBytes := ABytes; // keep alive after return
  InternLoadFromMem(@ABytes[AIndex], ACount, APassword);
end;

function ReadFromActiveStream(Param: Pointer; Position: LongWord; Buffer: PByte; Size: LongWord): Boolean;
begin
  if Buffer <> nil then
  begin
    TStream(Param).Seek(Position, TSeekOrigin.soBeginning);
    Result := TStream(Param).Read(Buffer^, Size) = Integer(Size);
  end
  else
    Result := Size = 0;
end;

procedure TPdfDocument.LoadFromActiveStream(Stream: TStream; const APassword: AnsiString);
begin
  if Stream = nil then
    Close
  else
    LoadFromCustom(ReadFromActiveStream, Stream.Size, Stream, APassword);
end;

procedure TPdfDocument.LoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; ASize: LongWord;
  AParam: Pointer; const APassword: AnsiString);
begin
  Close;
  InternLoadFromCustom(ReadFunc, ASize, AParam, APassword);
end;

function GetLoadFromCustomBlock(Param: Pointer; Position: LongWord; Buffer: PByte; Size: LongWord): Integer; cdecl;
var
  Data: TPdfDocument.PCustomLoadDataRec;
begin
  Data := TPdfDocument(param).FCustomLoadData;
  Result := Ord(Data.GetBlock(Data.Param, Position, Buffer, Size));
end;

procedure TPdfDocument.InternLoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; ASize: LongWord;
  AParam: Pointer; const APassword: AnsiString);
var
  OldCurDoc: TPdfDocument;
begin
  if Assigned(ReadFunc) then
  begin
    New(FCustomLoadData);
    FCustomLoadData.Param := AParam;
    FCustomLoadData.GetBlock := ReadFunc;
    FCustomLoadData.FileAccess.m_FileLen := ASize;
    FCustomLoadData.FileAccess.m_GetBlock := GetLoadFromCustomBlock;
    FCustomLoadData.FileAccess.m_Param := Self;

    OldCurDoc := UnsupportedFeatureCurrentDocument;
    try
      UnsupportedFeatureCurrentDocument := Self;
      FDocument := FPDF_LoadCustomDocument(@FCustomLoadData.FileAccess, PAnsiChar(APassword));
      DocumentLoaded;
    finally
      UnsupportedFeatureCurrentDocument := OldCurDoc;
    end;
  end;
end;

procedure TPdfDocument.InternLoadFromMem(Buffer: PByte; Size: Integer; const APassword: AnsiString);
begin
  if Size > 0 then
  begin
    FDocument := FPDF_LoadMemDocument(Buffer, Size, PAnsiChar(Pointer(APassword)));
    DocumentLoaded;
  end;
end;

procedure TPdfDocument.DocumentLoaded;
begin
  FFormModified := False;
  if FDocument = nil then
    RaiseLastPdfError;

  FPages.Count := FPDF_GetPageCount(FDocument);

  FillChar(FFormFillHandler, SizeOf(TPdfFormFillHandler), 0);
  FFormFillHandler.Document := Self;
  FFormFillHandler.FormFillInfo.version := 1;
  FFormFillHandler.FormFillInfo.FFI_Invalidate := FFI_Invalidate;
  FFormFillHandler.FormFillInfo.FFI_OnChange := FFI_Change;
  FFormFillHandler.FormFillInfo.FFI_OutputSelectedRect := FFI_OutputSelectedRect;
  FFormFillHandler.FormFillInfo.FFI_SetTimer := FFI_SetTimer;
  FFormFillHandler.FormFillInfo.FFI_KillTimer := FFI_KillTimer;
  FFormFillHandler.FormFillInfo.FFI_GetLocalTime := FFI_GetLocalTime;
  FFormFillHandler.FormFillInfo.FFI_GetPage := FFI_GetPage;
  FFormFillHandler.FormFillInfo.FFI_GetCurrentPage := FFI_GetCurrentPage;
  FFormFillHandler.FormFillInfo.FFI_GetRotation := FFI_GetRotation;
  FFormFillHandler.FormFillInfo.FFI_SetCursor := FFI_SetCursor;
  FFormFillHandler.FormFillInfo.FFI_SetTextFieldFocus := FFI_SetTextFieldFocus;

  FForm := FPDFDOC_InitFormFillEnvironment(FDocument, @FFormFillHandler.FormFillInfo);
  if FForm <> nil then
  begin
    UpdateFormFieldHighlight;

    FORM_DoDocumentJSAction(FForm);
    FORM_DoDocumentOpenAction(FForm);
  end;
end;

procedure TPdfDocument.UpdateFormFieldHighlight;
begin
  FPDF_SetFormFieldHighlightColor(FForm, 0, {ColorToRGB}(FFormFieldHighlightColor));
  FPDF_SetFormFieldHighlightAlpha(FForm, FFormFieldHighlightAlpha);
end;

function TPdfDocument.GetPage(Index: Integer): TPdfPage;
var
  LPage: FPDF_PAGE;
begin
  Result := TPdfPage(FPages[Index]);
  if Result = nil then
  begin
    LPage := FPDF_LoadPage(FDocument, Index);
    if LPage = nil then
      RaiseLastPdfError;
    Result := TPdfPage.Create(Self, LPage);
    FPages[Index] := Result;
  end
end;

function TPdfDocument.GetPageCount: Integer;
begin
  Result := FPages.Count;
end;

procedure TPdfDocument.ExtractPage(APage: TPdfPage);
begin
  if not FClosing then
    FPages.Extract(APage);
end;

function TPdfDocument.ReloadPage(APage: TPdfPage): FPDF_PAGE;
var
  Index: Integer;
begin
  CheckActive;
  Index := FPages.IndexOf(APage);
  Result := FPDF_LoadPage(FDocument, Index);
  if Result = nil then
    RaiseLastPdfError;
end;

function TPdfDocument.GetPrintScaling: Boolean;
begin
  CheckActive;
  Result := FPDF_VIEWERREF_GetPrintScaling(FDocument) <> 0;
end;

function TPdfDocument.GetActive: Boolean;
begin
  Result := FDocument <> nil;
end;

procedure TPdfDocument.CheckActive;
begin
  if not Active then
    raise EPdfException.CreateRes(@RsDocumentNotActive);
end;

function TPdfDocument.ImportPages(Source: TPdfDocument; const Range: string; Index: Integer): Boolean;
var
  A: AnsiString;
  I, NewCount, OldCount, InsertCount: Integer;
begin
  CheckActive;
  Source.CheckActive;

  OldCount := FPDF_GetPageCount(FDocument);
  if Index < 0 then
    Index := OldCount;
  A := AnsiString(Range);
  Result := FPDF_ImportPages(FDocument, Source.FDocument, PAnsiChar(Pointer(A)), Index) <> 0;
  NewCount := FPDF_GetPageCount(FDocument);
  InsertCount := NewCount - OldCount;
  if InsertCount > 0 then
  begin
    FPages.Count := NewCount;
    if Index < OldCount then
    begin
      Move(FPages.List[Index], FPages.List[Index + InsertCount], (OldCount - Index) * SizeOf(TObject));
      for I := Index to Index + InsertCount - 1 do
        FPages.List[Index] := nil;
    end;
  end;
end;

procedure TPdfDocument.SaveToFile(const AFileName: string; Option: TPdfDocumentSaveOption; FileVersion: Integer);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, fmCreate or fmShareDenyWrite);
  try
    SaveToStream(Stream, Option, FileVersion);
  finally
    Stream.Free;
  end;
end;

type
  PFPDFFileWriteEx = ^TFPDFFileWriteEx;
  TFPDFFileWriteEx = record
    Inner: TFPDFFileWrite;
    Stream: TStream;
  end;

function WriteBlockToStream(pThis: PFPDF_FILEWRITE; pData: Pointer; size: LongWord): Integer; cdecl;
begin
  Result := Ord(LongWord(PFPDFFileWriteEx(pThis).Stream.Write(pData^, size)) = size);
end;

procedure TPdfDocument.SaveToStream(Stream: TStream; Option: TPdfDocumentSaveOption; FileVersion: Integer);
var
  FileWriteInfo: TFPDFFileWriteEx;
begin
  FileWriteInfo.Inner.version := 1;
  FileWriteInfo.Inner.WriteBlock := @WriteBlockToStream;
  FileWriteInfo.Stream := Stream;

  if FForm <> nil then
    FORM_ForceToKillFocus(FForm); // also save the form field data that is currently focused

  if FileVersion <> -1 then
    FPDF_SaveWithVersion(FDocument, @FileWriteInfo, Ord(Option), FileVersion)
  else
    FPDF_SaveAsCopy(FDocument, @FileWriteInfo, Ord(Option));
end;

procedure TPdfDocument.SaveToBytes(var Bytes: TBytes; Option: TPdfDocumentSaveOption; FileVersion: Integer);
var
  Stream: TBytesStream;
begin
  Stream := TBytesStream.Create(nil);
  try
    SaveToStream(Stream, Option, FileVersion);
    Bytes := Stream.Bytes;
  finally
    Stream.Free;
  end;
end;

function TPdfDocument.NewDocument: Boolean;
begin
  Close;
  FDocument := FPDF_CreateNewDocument;
  Result := FDocument <> nil;
  FFormModified := False;
end;

procedure TPdfDocument.DeletePage(Index: Integer);
begin
  CheckActive;
  FPages.Delete(Index);
  FPDFPage_Delete(FDocument, Index);
end;

function TPdfDocument.NewPage(Width, Height: Double; Index: Integer): TPdfPage;
var
  LPage: FPDF_PAGE;
begin
  CheckActive;
  if Index < 0 then
    Index := FPages.Count;
  LPage := FPDFPage_New(FDocument, Index, Width, Height);
  if LPage <> nil then
  begin
    Result := TPdfPage.Create(Self, LPage);
    FPages.Insert(Index, Result);
  end
  else
    Result := nil;
end;

function TPdfDocument.ApplyViewerPreferences(Source: TPdfDocument): Boolean;
begin
  CheckActive;
  Source.CheckActive;
  Result := FPDF_CopyViewerPreferences(FDocument, Source.FDocument) <> 0;
end;

function TPdfDocument.GetMetaText(const TagName: string): string;
var
  Len: Integer;
  A: AnsiString;
begin
  CheckActive;
  A := AnsiString(TagName);
  Len := (FPDF_GetMetaText(FDocument, PAnsiChar(A), nil, 0) div SizeOf(WideChar)) - 1;
  if Len > 0 then
  begin
    SetLength(Result, Len);
    FPDF_GetMetaText(FDocument, PAnsiChar(A), PChar(Result), (Len + 1) * SizeOf(WideChar));
  end
  else
    Result := '';
end;

function TPdfDocument.GetSecurityHandlerRevision: Integer;
begin
  CheckActive;
  Result := FPDF_GetSecurityHandlerRevision(FDocument);
end;

function TPdfDocument.GetDocPermissions: Integer;
begin
  Result := Integer(FPDF_GetDocPermissions(FDocument));
end;

function TPdfDocument.GetFileVersion: Integer;
begin
  CheckActive;
  if FPDF_GetFileVersion(FDocument, Result) = 0 then
    Result := 0;
end;

function TPdfDocument.GetPageSize(Index: Integer): TPdfPoint;
begin
  CheckActive;
  if FPDF_GetPageSizeByIndex(FDocument, Index, Result.X, Result.Y) = 0 then
  begin
    Result.X := 0;
    Result.Y := 0;
  end;
end;

function TPdfDocument.GetPageMode: TPdfDocumentPageMode;
begin
  CheckActive;
  Result := TPdfDocumentPageMode(FPDFDoc_GetPageMode(FDocument));
end;

function TPdfDocument.GetNumCopies: Integer;
begin
  CheckActive;
  Result := FPDF_VIEWERREF_GetNumCopies(FDocument);
end;

class function TPdfDocument.SetPrintMode(PrintMode: TPdfPrintMode): Boolean;
begin
  InitLib;
  Result := FPDF_SetPrintMode(Ord(PrintMode)) <> 0;
end;

procedure TPdfDocument.SetFormFieldHighlightAlpha(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if Value > 255 then
    Value := 255;

  if Value <> FFormFieldHighlightAlpha then
  begin
    FFormFieldHighlightAlpha := Value;
    if Active then
      FPDF_SetFormFieldHighlightAlpha(FForm, FFormFieldHighlightAlpha);
  end;
end;

procedure TPdfDocument.SetFormFieldHighlightColor(const Value: TColor);
begin
  if Value <> FFormFieldHighlightColor then
  begin
    FFormFieldHighlightColor := Value;
    if Active then
      FPDF_SetFormFieldHighlightColor(FForm, 0, {ColorToRGB}(FFormFieldHighlightColor));
  end;
end;

function TPdfDocument.FindPage(Page: FPDF_PAGE): TPdfPage;
var
  I: Integer;
begin
  // The page must be already loaded
  for I := 0 to PageCount - 1 do
  begin
    Result := TPdfPage(FPages[I]);
    if (Result <> nil) and (Result.FPage = Page) then
      Exit;
  end;
  Result := nil;
end;

{ TPdfPage }

constructor TPdfPage.Create(ADocument: TPdfDocument; APage: FPDF_PAGE);
begin
  inherited Create;
  FDocument := ADocument;
  FPage := APage;

  AfterOpen;
end;

destructor TPdfPage.Destroy;
begin
  Close;
  FDocument.ExtractPage(Self);
  inherited Destroy;
end;

function TPdfPage.IsValidForm: Boolean;
begin
  Result := (FDocument <> nil) and (FDocument.FForm <> nil) and (FPage <> nil);
end;

procedure TPdfPage.AfterOpen;
var
  OldCurDoc: TPdfDocument;
begin
  if IsValidForm then
  begin
    OldCurDoc := UnsupportedFeatureCurrentDocument;
    try
      UnsupportedFeatureCurrentDocument := FDocument;
      FORM_OnAfterLoadPage(FPage, FDocument.FForm);
      FORM_DoPageAAction(FPage, FDocument.FForm, FPDFPAGE_AACTION_OPEN);
    finally
      UnsupportedFeatureCurrentDocument := OldCurDoc;
    end;
  end;

  UpdateMetrics;
end;

procedure TPdfPage.Close;
begin
  if IsValidForm then
  begin
    FORM_DoPageAAction(FPage, FDocument.FForm, FPDFPAGE_AACTION_CLOSE);
    FORM_OnBeforeClosePage(FPage, FDocument.FForm);
  end;

  if FLinkHandle <> nil then
  begin
    FPDFLink_CloseWebLinks(FLinkHandle);
    FLinkHandle := nil;
  end;
  if FSearchHandle <> nil then
  begin
    FPDFText_FindClose(FSearchHandle);
    FSearchHandle := nil;
  end;
  if FTextHandle <> nil then
  begin
    FPDFText_ClosePage(FTextHandle);
    FTextHandle := nil;
  end;
  if FPage <> nil then
  begin
    FPDF_ClosePage(FPage);
    FPage := nil;
  end;
end;

procedure TPdfPage.Open;
begin
  if FPage = nil then
  begin
    FPage := FDocument.ReloadPage(Self);
    AfterOpen;
  end;
end;

class function TPdfPage.GetDrawFlags(const Options: TPdfPageRenderOptions): Integer;
begin
  Result := 0;
  if proAnnotations in Options then
    Result := Result or FPDF_ANNOT;
  if proLCDOptimized in Options then
    Result := Result or FPDF_LCD_TEXT;
  if proNoNativeText in Options then
    Result := Result or FPDF_NO_NATIVETEXT;
  if proGrayscale in Options then
    Result := Result or FPDF_GRAYSCALE;
  if proNoCatch in Options then
    Result := Result or FPDF_NO_CATCH;
  if proLimitedImageCacheSize in Options then
    Result := Result or FPDF_RENDER_LIMITEDIMAGECACHE;
  if proForceHalftone in Options then
    Result := Result or FPDF_RENDER_FORCEHALFTONE;
  if proPrinting in Options then
    Result := Result or FPDF_PRINTING;
  if proReverseByteOrder in Options then
    Result := Result or FPDF_REVERSE_BYTE_ORDER;
end;

procedure TPdfPage.Draw(DC: HDC; X, Y, Width, Height: Integer; Rotate: TPdfPageRotation; const Options: TPdfPageRenderOptions);
var
  BitmapInfo: TBitmapInfo;
  Bmp, OldBmp: HBITMAP;
  BmpBits: Pointer;
  PdfBmp: TPdfBitmap;
  BmpDC: HDC;
begin
  Open;

  if proPrinting in Options then
  begin
    FPDF_RenderPage(DC, FPage, X, Y, Width, Height, Ord(Rotate), GetDrawFlags(Options));
    Exit;
  end;


  FillChar(BitmapInfo, SizeOf(BitmapInfo), 0);
  BitmapInfo.bmiHeader.biSize := SizeOf(BitmapInfo);
  BitmapInfo.bmiHeader.biWidth := Width;
  BitmapInfo.bmiHeader.biHeight := -Height;
  BitmapInfo.bmiHeader.biPlanes := 1;
  BitmapInfo.bmiHeader.biBitCount := 32;
  BitmapInfo.bmiHeader.biCompression := BI_RGB;
  BmpBits := nil;
  Bmp := CreateDIBSection(DC, BitmapInfo, DIB_RGB_COLORS, BmpBits, 0, 0);
  if Bmp <> 0 then
  begin
    try
      PdfBmp := TPdfBitmap.Create(Width, Height, bfBGRA, BmpBits, Width * 4);
      try
        if Transparency then
          PdfBmp.FillRect(0, 0, Width, Height, $00FFFFFF)
        else
          PdfBmp.FillRect(0, 0, Width, Height, $FFFFFFFF);
        DrawToPdfBitmap(PdfBmp, 0, 0, Width, Height, Rotate, Options);
        DrawFormToPdfBitmap(PdfBmp, 0, 0, Width, Height, Rotate, Options);
      finally
        PdfBmp.Free;
      end;

      BmpDC := CreateCompatibleDC(DC);
      OldBmp := SelectObject(BmpDC, Bmp);
      BitBlt(DC, X, Y, Width, Height, BmpDC, 0, 0, SRCCOPY);
      SelectObject(BmpDC, OldBmp);
      DeleteDC(BmpDC);
    finally
      DeleteObject(Bmp);
    end;
  end;
end;

procedure TPdfPage.DrawToPdfBitmap(APdfBitmap: TPdfBitmap; X, Y, Width, Height: Integer;
  Rotate: TPdfPageRotation; const Options: TPdfPageRenderOptions);
begin
  Open;
  FPDF_RenderPageBitmap(APdfBitmap.FBitmap, FPage, X, Y, Width, Height, Ord(Rotate), GetDrawFlags(Options));
end;

procedure TPdfPage.DrawFormToPdfBitmap(APdfBitmap: TPdfBitmap; X, Y, Width, Height: Integer;
  Rotate: TPdfPageRotation; const Options: TPdfPageRenderOptions);
begin
  Open;
  if IsValidForm then
  begin
    if proPrinting in Options then
    begin
      if FDocument.PrintHidesFormFieldHighlight then
        FPDF_RemoveFormFieldHighlight(FDocument.FForm);
        //FPDF_SetFormFieldHighlightAlpha(FDocument.FForm, 0); // hide the highlight
      FORM_ForceToKillFocus(FDocument.FForm);
    end;
    try
      FPDF_FFLDraw(FDocument.FForm, APdfBitmap.FBitmap, FPage, X, Y, Width, Height, Ord(Rotate), GetDrawFlags(Options));
    finally
      if (proPrinting in Options) and FDocument.PrintHidesFormFieldHighlight then
        FDocument.UpdateFormFieldHighlight;
    end;
  end;
end;

procedure TPdfPage.UpdateMetrics;
begin
  FWidth := FPDF_GetPageWidth(FPage);
  FHeight := FPDF_GetPageHeight(FPage);
  FTransparency := FPDFPage_HasTransparency(FPage) <> 0;
  FRotation := TPdfPageRotation(FPDFPage_GetRotation(FPage));
end;

function TPdfPage.DeviceToPage(X, Y, Width, Height: Integer; DeviceX, DeviceY: Integer; Rotate: TPdfPageRotation): TPdfPoint;
begin
  Open;
  FPDF_DeviceToPage(FPage, X, Y, Width, Height, Ord(Rotate), DeviceX, DeviceY, Result.X, Result.Y);
end;

function TPdfPage.PageToDevice(X, Y, Width, Height: Integer; PageX, PageY: Double;
  Rotate: TPdfPageRotation): TPoint;
begin
  Open;
  FPDF_PageToDevice(FPage, X, Y, Width, Height, Ord(Rotate), PageX, PageY, Result.X, Result.Y);
end;

function TPdfPage.DeviceToPage(X, Y, Width, Height: Integer; const R: TRect; Rotate: TPdfPageRotation): TPdfRect;
begin
  Result.TopLeft := DeviceToPage(X, Y, Width, Height, R.Left, R.Top, Rotate);
  Result.BottomRight := DeviceToPage(X, Y, Width, Height, R.Right, R.Bottom, Rotate);
end;

function TPdfPage.PageToDevice(X, Y, Width, Height: Integer; const R: TPdfRect; Rotate: TPdfPageRotation): TRect;
var
  T: Integer;
begin
  Result.TopLeft := PageToDevice(X, Y, Width, Height, R.Left, R.Top, Rotate);
  Result.BottomRight := PageToDevice(X, Y, Width, Height, R.Right, R.Bottom, Rotate);
  if Result.Top > Result.Bottom then
  begin
    T := Result.Top;
    Result.Top := Result.Bottom;
    Result.Bottom := T;
  end;
end;

procedure TPdfPage.SetRotation(const Value: TPdfPageRotation);
begin
  Open;
  FPDFPage_SetRotation(FPage, Ord(Value));
  FRotation := TPdfPageRotation(FPDFPage_GetRotation(FPage));
end;

procedure TPdfPage.ApplyChanges;
begin
  if FPage <> nil then
    FPDFPage_GenerateContent(FPage);
end;

function TPdfPage.BeginText: Boolean;
begin
  if FTextHandle = nil then
  begin
    Open;
    FTextHandle := FPDFText_LoadPage(FPage);
  end;
  Result := FTextHandle <> nil;
end;

function TPdfPage.BeginWebLinks: Boolean;
begin
  if (FLinkHandle = nil) and BeginText then
    FLinkHandle := FPDFLink_LoadWebLinks(FTextHandle);
  Result := FLinkHandle <> nil;
end;

function TPdfPage.BeginFind(const SearchString: string; MatchCase, MatchWholeWord,
  FromEnd: Boolean): Boolean;
var
  Flags, StartIndex: Integer;
begin
  EndFind;
  if BeginText then
  begin
    Flags := 0;
    if MatchCase then
      Flags := Flags or FPDF_MATCHCASE;
    if MatchWholeWord then
      Flags := Flags or FPDF_MATCHWHOLEWORD;

    if FromEnd then
      StartIndex := -1
    else
      StartIndex := 0;

    FSearchHandle := FPDFText_FindStart(FTextHandle, PChar(SearchString), Flags, StartIndex);
  end;
  Result := FSearchHandle <> nil;
end;

procedure TPdfPage.EndFind;
begin
  if FSearchHandle <> nil then
  begin
    FPDFText_FindClose(FSearchHandle);
    FSearchHandle := nil;
  end;
end;

function TPdfPage.FindNext(var CharIndex, Count: Integer): Boolean;
begin
  CharIndex := 0;
  Count := 0;
  if FSearchHandle <> nil then
  begin
    Result := FPDFText_FindNext(FSearchHandle) <> 0;
    if Result then
    begin
      CharIndex := FPDFText_GetSchResultIndex(FSearchHandle);
      Count := FPDFText_GetSchCount(FSearchHandle);
    end;
  end
  else
    Result := False;
end;

function TPdfPage.FindPrev(var CharIndex, Count: Integer): Boolean;
begin
  CharIndex := 0;
  Count := 0;
  if FSearchHandle <> nil then
  begin
    Result := FPDFText_FindPrev(FSearchHandle) <> 0;
    if Result then
    begin
      CharIndex := FPDFText_GetSchResultIndex(FSearchHandle);
      Count := FPDFText_GetSchCount(FSearchHandle);
    end;
  end
  else
    Result := False;
end;

function TPdfPage.GetCharCount: Integer;
begin
  if BeginText then
    Result := FPDFText_CountChars(FTextHandle)
  else
    Result := 0;
end;

function TPdfPage.ReadChar(CharIndex: Integer): WideChar;
begin
  if BeginText then
    Result := FPDFText_GetUnicode(FTextHandle, CharIndex)
  else
    Result := #0;
end;

function TPdfPage.GetCharFontSize(CharIndex: Integer): Double;
begin
  if BeginText then
    Result := FPDFText_GetFontSize(FTextHandle, CharIndex)
  else
    Result := 0;
end;

function TPdfPage.GetCharBox(CharIndex: Integer): TPdfRect;
begin
  if BeginText then
    FPDFText_GetCharBox(FTextHandle, CharIndex, Result.Left, Result.Right, Result.Bottom, Result.Top)
  else
    Result := TPdfRect.Empty;
end;

function TPdfPage.GetCharIndexAt(PageX, PageY, ToleranceX, ToleranceY: Double): Integer;
begin
  if BeginText then
    Result := FPDFText_GetCharIndexAtPos(FTextHandle, PageX, PageY, ToleranceX, ToleranceY)
  else
    Result := 0;
end;

function TPdfPage.ReadText(CharIndex, Count: Integer): string;
var
  Len: Integer;
begin
  if (Count > 0) and BeginText then
  begin
    SetLength(Result, Count);
    Len := FPDFText_GetText(FTextHandle, CharIndex, Count + 1, PChar(Result)); // include #0 terminater
    if Len = 0 then
      Result := ''
    else if Len + 1 < Count then
      SetLength(Result, Len - 1);
  end
  else
    Result := '';
end;

function TPdfPage.GetTextAt(Left, Top, Right, Bottom: Double): string;
var
  Len: Integer;
begin
  if BeginText then
  begin
    Len := FPDFText_GetBoundedText(FTextHandle, Left, Top, Right, Bottom, nil, 0); // excluding #0 terminator
    SetLength(Result, Len);
    if Len > 0 then
      FPDFText_GetBoundedText(FTextHandle, Left, Top, Right, Bottom, PChar(Result), Len);
  end
  else
    Result := '';
end;

function TPdfPage.GetTextAt(const R: TPdfRect): string;
begin
  Result := GetTextAt(R.Left, R.Top, R.Right, R.Bottom);
end;

function TPdfPage.GetTextRectCount(CharIndex, Count: Integer): Integer;
begin
  if BeginText then
    Result := FPDFText_CountRects(FTextHandle, CharIndex, Count)
  else
    Result := 0;
end;

function TPdfPage.GetTextRect(RectIndex: Integer): TPdfRect;
begin
  if BeginText then
    FPDFText_GetRect(FTextHandle, RectIndex, Result.Left, Result.Top, Result.Right, Result.Bottom)
  else
    Result := TPdfRect.Empty;
end;

function TPdfPage.GetWebLinkCount: Integer;
begin
  if BeginWebLinks then
  begin
    Result := FPDFLink_CountWebLinks(FLinkHandle);
    if Result < 0 then
      Result := 0;
  end
  else
    Result := 0;
end;

function TPdfPage.GetWebLinkURL(LinkIndex: Integer): string;
var
  Len: Integer;
begin
  Result := '';
  if BeginWebLinks then
  begin
    Len := FPDFLink_GetURL(FLinkHandle, LinkIndex, nil, 0) - 1; // including #0 terminator
    if Len > 0 then
    begin
      SetLength(Result, Len);
      FPDFLink_GetURL(FLinkHandle, LinkIndex, PChar(Result), Len + 1); // including #0 terminator
    end;
  end;
end;

function TPdfPage.GetWebLinkRectCount(LinkIndex: Integer): Integer;
begin
  if BeginWebLinks then
    Result := FPDFLink_CountRects(FLinkHandle, LinkIndex)
  else
    Result := 0;
end;

function TPdfPage.GetWebLinkRect(LinkIndex, RectIndex: Integer): TPdfRect;
begin
  if BeginWebLinks then
    FPDFLink_GetRect(FLinkHandle, LinkIndex, RectIndex, Result.Left, Result.Top, Result.Right, Result.Bottom)
  else
    Result := TPdfRect.Empty;
end;

function TPdfPage.GetMouseModifier(const Shift: TShiftState): Integer;
begin
  Result := 0;
  if ssShift in Shift then
    Result := Result or FWL_EVENTFLAG_ShiftKey;
  if ssCtrl in Shift then
    Result := Result or FWL_EVENTFLAG_ControlKey;
  if ssAlt in Shift then
    Result := Result or FWL_EVENTFLAG_AltKey;
  if ssLeft in Shift then
    Result := Result or FWL_EVENTFLAG_LeftButtonDown;
  if ssMiddle in Shift then
    Result := Result or FWL_EVENTFLAG_MiddleButtonDown;
  if ssRight in Shift then
    Result := Result or FWL_EVENTFLAG_RightButtonDown;
end;

function TPdfPage.GetKeyModifier(KeyData: LPARAM): Integer;
const
  AltMask = $20000000;
begin
  Result := 0;
  if GetKeyState(VK_SHIFT) < 0 then
    Result := Result or FWL_EVENTFLAG_ShiftKey;
  if GetKeyState(VK_CONTROL) < 0 then
    Result := Result or FWL_EVENTFLAG_ControlKey;
  if KeyData and AltMask <> 0 then
    Result := Result or FWL_EVENTFLAG_AltKey;
end;

function TPdfPage.FormEventFocus(const Shift: TShiftState; PageX, PageY: Double): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnFocus(FDocument.FForm, FPage, GetMouseModifier(Shift), PageX, PageY) <> 0
  else
    Result := False;
end;

function TPdfPage.FormEventMouseMove(const Shift: TShiftState; PageX, PageY: Double): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnMouseMove(FDocument.FForm, FPage, GetMouseModifier(Shift), PageX, PageY) <> 0
  else
    Result := False;
end;

function TPdfPage.FormEventLButtonDown(const Shift: TShiftState; PageX, PageY: Double): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnLButtonDown(FDocument.FForm, FPage, GetMouseModifier(Shift), PageX, PageY) <> 0
  else
    Result := False;
end;

function TPdfPage.FormEventLButtonUp(const Shift: TShiftState; PageX, PageY: Double): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnLButtonUp(FDocument.FForm, FPage, GetMouseModifier(Shift), PageX, PageY) <> 0
  else
    Result := False;
end;

function TPdfPage.FormEventKeyDown(KeyCode: Word; KeyData: LPARAM): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnKeyDown(FDocument.FForm, FPage, KeyCode, GetKeyModifier(KeyData)) <> 0
  else
    Result := False;
end;

function TPdfPage.FormEventKeyUp(KeyCode: Word; KeyData: LPARAM): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnKeyUp(FDocument.FForm, FPage, KeyCode, GetKeyModifier(KeyData)) <> 0
  else
    Result := False;
end;

function TPdfPage.FormEventKeyPress(Key: Word; KeyData: LPARAM): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnChar(FDocument.FForm, FPage, Key, GetKeyModifier(KeyData)) <> 0
  else
    Result := False;
end;

procedure TPdfPage.FormEventKillFocus;
begin
  if IsValidForm then
    FORM_ForceToKillFocus(FDocument.FForm);
end;

function TPdfPage.HasFormFieldAtPoint(X, Y: Double): TPdfFormFieldType;
begin
  case FPDFPage_HasFormFieldAtPoint(FDocument.FForm, FPage, X, Y) of
    FPDF_FORMFIELD_PUSHBUTTON:
      Result := fftPushButton;
    FPDF_FORMFIELD_CHECKBOX:
      Result := fftCheckBox;
    FPDF_FORMFIELD_RADIOBUTTON:
      Result := fftRadioButton;
    FPDF_FORMFIELD_COMBOBOX:
      Result := fftComboBox;
    FPDF_FORMFIELD_LISTBOX:
      Result := fftListBox;
    FPDF_FORMFIELD_TEXTFIELD:
      Result := fftTextField;
    FPDF_FORMFIELD_SIGNATURE:
      Result := fftSignature;
  else
    Result := fftUnknown;
  end;
end;

function TPdfPage.GetHandle: FPDF_PAGE;
begin
  Open;
  Result := FPage;
end;

{ _TPdfBitmapHideCtor }

procedure _TPdfBitmapHideCtor.Create;
begin
  inherited Create;
end;

{ TPdfBitmap }

constructor TPdfBitmap.Create(ABitmap: FPDF_BITMAP; AOwnsBitmap: Boolean);
begin
  inherited Create;
  FBitmap := ABitmap;
  FOwnsBitmap := AOwnsBitmap;
  if FBitmap <> nil then
  begin
    FWidth := FPDFBitmap_GetWidth(FBitmap);
    FHeight := FPDFBitmap_GetHeight(FBitmap);
    FBytesPerScanLine := FPDFBitmap_GetStride(FBitmap);
  end;
end;

constructor TPdfBitmap.Create(AWidth, AHeight: Integer; AAlpha: Boolean);
begin
  Create(FPDFBitmap_Create(AWidth, AHeight, Ord(AAlpha)), True);
end;

constructor TPdfBitmap.Create(AWidth, AHeight: Integer; AFormat: TPdfBitmapFormat);
begin
  Create(FPDFBitmap_CreateEx(AWidth, AHeight, Ord(AFormat), nil, 0), True);
end;

constructor TPdfBitmap.Create(AWidth, AHeight: Integer; AFormat: TPdfBitmapFormat; ABuffer: Pointer;
  ABytesPerScanLine: Integer);
begin
  Create(FPDFBitmap_CreateEx(AWidth, AHeight, Ord(AFormat), ABuffer, ABytesPerScanline), True);
end;

destructor TPdfBitmap.Destroy;
begin
  if FOwnsBitmap and (FBitmap <> nil) then
    FPDFBitmap_Destroy(FBitmap);
  inherited Destroy;
end;

function TPdfBitmap.GetBuffer: Pointer;
begin
  if FBitmap <> nil then
    Result := FPDFBitmap_GetBuffer(FBitmap)
  else
    Result := nil;
end;

procedure TPdfBitmap.FillRect(ALeft, ATop, AWidth, AHeight: Integer; AColor: FPDF_DWORD);
begin
  if FBitmap <> nil then
    FPDFBitmap_FillRect(FBitmap, ALeft, ATop, AWidth, AHeight, AColor);
end;

{ TPdfPoint }

procedure TPdfPoint.Offset(XOffset, YOffset: Double);
begin
  X := X + XOffset;
  Y := Y + YOffset;
end;

class function TPdfPoint.Empty: TPdfPoint;
begin
  Result.X := 0;
  Result.Y := 0;
end;

initialization
  InitializeCriticalSectionAndSpinCount(PDFiumInitCritSect, 4000);
  InitializeCriticalSectionAndSpinCount(FFITimersCritSect, 4000);

finalization
  DeleteCriticalSection(FFITimersCritSect);
  DeleteCriticalSection(PDFiumInitCritSect);

end.
