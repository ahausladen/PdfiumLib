unit PdfiumCore;

{$IFDEF FPC}
  {$MODE DelphiUnicode}
{$ENDIF FPC}

{$IFNDEF FPC}
  {$A8,B-,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,T-,U-,V+,X+,Z1}
  {$STRINGCHECKS OFF}
{$ENDIF ~FPC}

interface

{.$UNDEF MSWINDOWS}

uses
  {$IFDEF MSWINDOWS}
  Windows, //WinSpool,
  {$ELSE}
    {$IFDEF FPC}
  LCLType,
    {$ENDIF FPC}
  ExtCtrls,
  {$ENDIF MSWINDOWS}
  Types, SysUtils, Classes, Contnrs,
  PdfiumLib;

const
  // DIN A4
  PdfDefaultPageWidth = 595;
  PdfDefaultPageHeight = 842;

type
  EPdfException = class(Exception);
  EPdfUnsupportedFeatureException = class(EPdfException);
  EPdfArgumentOutOfRange = class(EPdfException);

  TPdfUnsupportedFeatureHandler = procedure(nType: Integer; const Typ: string) of object;

  TPdfDocument = class;
  TPdfPage = class;
  TPdfAttachmentList = class;
  TPdfAnnotationList = class;
  TPdfFormField = class;
  TPdfAnnotation = class;

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
    function PtIn(const Pt: TPdfPoint): Boolean;

    class function New(Left, Top, Right, Bottom: Double): TPdfRect; static;
    class function Empty: TPdfRect; static;
  public
    case Integer of
      0: (Left, Top, Right, Bottom: Double);
      1: (TopLeft: TPdfPoint; BottomRight: TPdfPoint);
  end;

  TPdfRectArray = array of TPdfRect;
  TPdfFloatArray = array of FS_FLOAT;

  TPdfDocumentCustomReadProc = function(Param: Pointer; Position: LongWord; Buffer: PByte; Size: LongWord): Boolean;

  TPdfNamedActionType = (
    naPrint,
    naNextPage,
    naPrevPage,
    naFirstPage,
    naLastPage
  );

  TPdfPageRenderOptionType = (
    proAnnotations,            // Set if annotations are to be rendered.
    proLCDOptimized,           // Set if using text rendering optimized for LCD display.
    proNoNativeText,           // Don't use the native text output available on some platforms
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
    dloDefault,  // load the file by using PDFium's file load mechanism (file stays open)
    dloMemory,   // load the whole file into memory
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
    pmEMF                          = FPDF_PRINTMODE_EMF,
    pmTextMode                     = FPDF_PRINTMODE_TEXTONLY,
    pmPostScript2                  = FPDF_PRINTMODE_POSTSCRIPT2,
    pmPostScript3                  = FPDF_PRINTMODE_POSTSCRIPT3,
    pmPostScriptPassThrough2       = FPDF_PRINTMODE_POSTSCRIPT2_PASSTHROUGH,
    pmPostScriptPassThrough3       = FPDF_PRINTMODE_POSTSCRIPT3_PASSTHROUGH,
    pmEMFImageMasks                = FPDF_PRINTMODE_EMF_IMAGE_MASKS,
    pmPostScript3Type42            = FPDF_PRINTMODE_POSTSCRIPT3_TYPE42,
    pmPostScript3Type42PassThrough = FPDF_PRINTMODE_POSTSCRIPT3_TYPE42_PASSTHROUGH
  );

  TPdfFileIdType = (
    pfiPermanent = 0,
    pfiChanging = 1
  );

  TPdfBitmapFormat = (
    bfGrays = FPDFBitmap_Gray, // Gray scale bitmap, one byte per pixel.
    bfBGR   = FPDFBitmap_BGR,  // 3 bytes per pixel, byte order: blue, green, red.
    bfBGRx  = FPDFBitmap_BGRx, // 4 bytes per pixel, byte order: blue, green, red, unused.
    bfBGRA  = FPDFBitmap_BGRA  // 4 bytes per pixel, byte order: blue, green, red, alpha.
  );

  TPdfFormFieldType = (
    fftUnknown         = FPDF_FORMFIELD_UNKNOWN,
    fftPushButton      = FPDF_FORMFIELD_PUSHBUTTON,
    fftCheckBox        = FPDF_FORMFIELD_CHECKBOX,
    fftRadioButton     = FPDF_FORMFIELD_RADIOBUTTON,
    fftComboBox        = FPDF_FORMFIELD_COMBOBOX,
    fftListBox         = FPDF_FORMFIELD_LISTBOX,
    fftTextField       = FPDF_FORMFIELD_TEXTFIELD,
    fftSignature       = FPDF_FORMFIELD_SIGNATURE,

    fftXFA             = FPDF_FORMFIELD_XFA,
    fftXFACheckBox     = FPDF_FORMFIELD_XFA_CHECKBOX,
    fftXFAComboBox     = FPDF_FORMFIELD_XFA_COMBOBOX,
    fftXFAImageField   = FPDF_FORMFIELD_XFA_IMAGEFIELD,
    fftXFAListBox      = FPDF_FORMFIELD_XFA_LISTBOX,
    fftXFAPushButton   = FPDF_FORMFIELD_XFA_PUSHBUTTON,
    fftXFASignature    = FPDF_FORMFIELD_XFA_SIGNATURE,
    fftXfaTextField    = FPDF_FORMFIELD_XFA_TEXTFIELD
  );

  TPdfFormFieldFlagsType = (
    fffReadOnly,
    fffRequired,
    fffNoExport,

    fffTextMultiLine,
    fffTextPassword,

    fffChoiceCombo,
    fffChoiceEdit,
    fffChoiceMultiSelect
  );
  TPdfFormFieldFlags = set of TPdfFormFieldFlagsType;

  TPdfObjectType = (
    otUnknown   = FPDF_OBJECT_UNKNOWN,
    otBoolean   = FPDF_OBJECT_BOOLEAN,
    otNumber    = FPDF_OBJECT_NUMBER,
    otString    = FPDF_OBJECT_STRING,
    otName      = FPDF_OBJECT_NAME,
    otArray     = FPDF_OBJECT_ARRAY,
    otDictinary = FPDF_OBJECT_DICTIONARY,
    otStream    = FPDF_OBJECT_STREAM,
    otNullObj   = FPDF_OBJECT_NULLOBJ,
    otReference = FPDF_OBJECT_REFERENCE
  );

  TPdfAnnotationLinkType = (
    altUnsupported  = PDFACTION_UNSUPPORTED, // Unsupported action type.
    altGoto         = PDFACTION_GOTO,        // Go to a destination within current document.
    altRemoteGoto   = PDFACTION_REMOTEGOTO,  // Go to a destination within another document.
    altURI          = PDFACTION_URI,         // Universal Resource Identifier, including web pages and
                                             // other Internet based resources.
    altLaunch       = PDFACTION_LAUNCH,      // Launch an application or open a file.
    altEmbeddedGoto = PDFACTION_EMBEDDEDGOTO // Go to a destination in an embedded file.
  );

  TPdfLinkGotoDestinationViewKind = (
    lgdvUnknown = PDFDEST_VIEW_UNKNOWN_MODE,
    lgdvXYZ     = PDFDEST_VIEW_XYZ,
    lgdvFit     = PDFDEST_VIEW_FIT,
    lgdvFitH    = PDFDEST_VIEW_FITH,
    lgdvFitV    = PDFDEST_VIEW_FITV,
    lgdvFitR    = PDFDEST_VIEW_FITR,
    lgdvFitB    = PDFDEST_VIEW_FITB,
    lgdvFitBH   = PDFDEST_VIEW_FITBH,
    lgdvFitBV   = PDFDEST_VIEW_FITBV
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

  TPdfFormField = class(TObject)
  private
    FPage: TPdfPage;
    FHandle: FPDF_ANNOTATION;
    FAnnotation: TPdfAnnotation;
    function GetFlags: TPdfFormFieldFlags;
    function GetReadOnly: Boolean;
    function GetName: string;
    function GetAlternateName: string;
    function GetFieldType: TPdfFormFieldType;
    function GetValue: string;
    function GetExportValue: string;
    function GetOptionCount: Integer;
    function GetOptionLabel(Index: Integer): string;
    function GetChecked: Boolean;
    function GetControlIndex: Integer;
    function GetControlCount: Integer;

    procedure SetValue(const Value: string);
    procedure SetChecked(const Value: Boolean);
  protected
    constructor Create(AAnnotation: TPdfAnnotation);

    function BeginEditFormField: FPDF_ANNOTATION;
    procedure EndEditFormField(LastFocusedAnnot: FPDF_ANNOTATION);
  public
    destructor Destroy; override;

    function IsXFAFormField: Boolean;

    function IsOptionSelected(OptionIndex: Integer): Boolean;
    function SelectComboBoxOption(OptionIndex: Integer): Boolean;
    function SelectListBoxOption(OptionIndex: Integer; Selected: Boolean = True): Boolean;

    property Flags: TPdfFormFieldFlags read GetFlags;
    property ReadOnly: Boolean read GetReadOnly;
    property Name: string read GetName;
    property AlternateName: string read GetAlternateName;
    property FieldType: TPdfFormFieldType read GetFieldType;
    property Value: string read GetValue write SetValue;
    property ExportValue: string read GetExportValue;

    // ComboBox/ListBox
    property OptionCount: Integer read GetOptionCount;
    property OptionLabels[Index: Integer]: string read GetOptionLabel;

    // CheckBox/RadioButton
    property Checked: Boolean read GetChecked write SetChecked;
    property ControlIndex: Integer read GetControlIndex;
    property ControlCount: Integer read GetControlCount;

    property Annotation: TPdfAnnotation read FAnnotation;
    property Handle: FPDF_ANNOTATION read FHandle;
  end;

  TPdfFormFieldList = class(TObject)
  private
    FItems: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TPdfFormField;
  protected
    procedure DestroyingItem(Item: TPdfFormField);
  public
    constructor Create(AAnnotations: TPdfAnnotationList);
    destructor Destroy; override;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPdfFormField read GetItem; default;
  end;

  TPdfLinkGotoDestination = class(TObject)
  private
    FPageIndex: Integer;
    FXValid: Boolean;
    FYValid: Boolean;
    FZoomValid: Boolean;
    FX: Single;
    FY: Single;
    FZoom: Single;
    FViewKind: TPdfLinkGotoDestinationViewKind;
    FViewParams: TPdfFloatArray;
  public
    constructor Create(APageIndex: Integer; AXValid, AYValid, AZoomValid: Boolean; AX, AY, AZoom: Single;
      AViewKind: TPdfLinkGotoDestinationViewKind; const AViewParams: TPdfFloatArray);

    property PageIndex: Integer read FPageIndex;

    property XValid: Boolean read FXValid;
    property YValid: Boolean read FYValid;
    property ZoomValid: Boolean read FZoomValid;

    property X: Single read FX;
    property Y: Single read FY;
    property Zoom: Single read FZoom;

    property ViewKind: TPdfLinkGotoDestinationViewKind read FViewKind;
    property ViewParams: TPdfFloatArray read FViewParams;
  end;

  TPdfAnnotation = class(TObject)
  private
    FPage: TPdfPage;
    FHandle: FPDF_ANNOTATION;
    FFormField: TPdfFormField;
    FSubType: FPDF_ANNOTATION_SUBTYPE;
    FLinkDest: FPDF_DEST;
    FLinkType: TPdfAnnotationLinkType;

    function GetPdfLinkAction: FPDF_ACTION;
    function GetFormField: TPdfFormField;
    function GetLinkUri: string;
    function GetAnnotationRect: TPdfRect;
    function GetLinkFileName: string;
  protected
    constructor Create(APage: TPdfPage; AHandle: FPDF_ANNOTATION);
  public
    destructor Destroy; override;

    function IsFormField: Boolean;
    function IsLink: Boolean;

    function GetLinkGotoDestination(var LinkGotoDestination: TPdfLinkGotoDestination; ARemoteDocument: TPdfDocument = nil): Boolean;

    // IsFormField:
    property FormField: TPdfFormField read GetFormField;
    // IsLink:
    property LinkType: TPdfAnnotationLinkType read FLinkType;
    property LinkUri: string read GetLinkUri;
    property LinkFileName: string read GetLinkFileName;

    property AnnotationRect: TPdfRect read GetAnnotationRect;
    property Handle: FPDF_ANNOTATION read FHandle;
  end;

  TPdfAnnotationList = class(TObject)
  private
    FPage: TPdfPage;
    FItems: TObjectList;
    FFormFields: TPdfFormFieldList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TPdfAnnotation;
    function GetFormFields: TPdfFormFieldList;
    function GetAnnotationsLoaded: Boolean;
  protected
    procedure DestroyingItem(Item: TPdfAnnotation);
    procedure DestroyingFormField(FormField: TPdfFormField);
    function FindLink(Link: FPDF_LINK): TPdfAnnotation;
  public
    constructor Create(APage: TPdfPage);
    destructor Destroy; override;
    procedure CloseAnnotations;
    { NewTextAnnotation creates a new text annotation on the page. After adding one or more
      annotations you must call Page.ApplyChanges to show them and make the persist before
      saving the file. R is in page coordinates. }
    function NewTextAnnotation(const Text: string; const R: TPdfRect): Boolean; {experimental;}

    property AnnotationsLoaded: Boolean read GetAnnotationsLoaded;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPdfAnnotation read GetItem; default;

    { A list of all form field annotations }
    property FormFields: TPdfFormFieldList read GetFormFields;
  end;

  TPdfLinkInfo = class(TObject)
  private
    FLinkAnnotation: TPdfAnnotation;
    FWebLinkUrl: string;
    function GetLinkFileName: string;
    function GetLinkType: TPdfAnnotationLinkType;
    function GetLinkUri: string;
  public
    constructor Create(ALinkAnnotation: TPdfAnnotation; const AWebLinkUrl: string);
    function GetLinkGotoDestination(var LinkGotoDestination: TPdfLinkGotoDestination; ARemoteDocument: TPdfDocument = nil): Boolean;

    function IsAnnontation: Boolean;
    function IsWebLink: Boolean;

    property LinkType: TPdfAnnotationLinkType read GetLinkType;
    property LinkUri: string read GetLinkUri;
    property LinkFileName: string read GetLinkFileName;

    property LinkAnnotation: TPdfAnnotation read FLinkAnnotation;
  end;

  { TPdfPageWebLinksInfo caches all the WebLinks for one page. This makes the IsWebLinkAt() methods
    much faster than always calling into the PDFium library. The URLs are not cached. }
  TPdfPageWebLinksInfo = class(TObject)
  private
    FPage: TPdfPage;
    FWebLinksRects: array of TPdfRectArray;
    procedure GetPageWebLinks;
    function GetWebLinkIndex(X, Y: Double): Integer;

    function GetCount: Integer;
    function GetRect(Index: Integer): TPdfRectArray;
    function GetURL(Index: Integer): string;
  public
    constructor Create(APage: TPdfPage);

    function IsWebLinkAt(X, Y: Double): Boolean; overload;
    function IsWebLinkAt(X, Y: Double; var Url: string): Boolean; overload;

    property Count: Integer read GetCount;
    property URLs[Index: Integer]: string read GetURL;
    property Rects[Index: Integer]: TPdfRectArray read GetRect;
  end;

  TPdfPage = class(TObject)
  private
    FDocument: TPdfDocument;
    FPage: FPDF_PAGE;
    FWidth: Single;
    FHeight: Single;
    FTransparency: Boolean;
    FRotation: TPdfPageRotation;
    FAnnotations: TPdfAnnotationList;
    FTextHandle: FPDF_TEXTPAGE;
    FSearchHandle: FPDF_SCHHANDLE;
    FPageLinkHandle: FPDF_PAGELINK;
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
    function GetTextHandle: FPDF_TEXTPAGE;
    function GetFormFields: TPdfFormFieldList;
  protected
    function GetPdfActionFilePath(Action: FPDF_ACTION): string;
    function GetPdfActionUriPath(Action: FPDF_ACTION): string;
  public
    destructor Destroy; override;
    procedure Close;
    function IsLoaded: Boolean;

    procedure Draw(DC: HDC; X, Y, Width, Height: Integer; Rotate: TPdfPageRotation = prNormal;
      const Options: TPdfPageRenderOptions = []; PageBackground: TColorRef = $FFFFFF);
    procedure DrawToPdfBitmap(APdfBitmap: TPdfBitmap; X, Y, Width, Height: Integer; Rotate: TPdfPageRotation = prNormal;
      const Options: TPdfPageRenderOptions = []);
    procedure DrawFormToPdfBitmap(APdfBitmap: TPdfBitmap; X, Y, Width, Height: Integer; Rotate: TPdfPageRotation = prNormal;
      const Options: TPdfPageRenderOptions = []);

    function DeviceToPage(X, Y, Width, Height: Integer; DeviceX, DeviceY: Integer; Rotate: TPdfPageRotation = prNormal): TPdfPoint; overload;
    function PageToDevice(X, Y, Width, Height: Integer; PageX, PageY: Double; Rotate: TPdfPageRotation = prNormal): TPoint; overload;
    function DeviceToPage(X, Y, Width, Height: Integer; const R: TRect; Rotate: TPdfPageRotation = prNormal): TPdfRect; overload;
    function PageToDevice(X, Y, Width, Height: Integer; const R: TPdfRect; Rotate: TPdfPageRotation = prNormal): TRect; overload;

    procedure ApplyChanges;
    procedure Flatten(AFlatPrint: Boolean);

    function FormEventFocus(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventMouseWheel(const Shift: TShiftState; WheelDelta: Integer; PageX, PageY: Double): Boolean;
    function FormEventMouseMove(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventLButtonDown(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventLButtonUp(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventRButtonDown(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventRButtonUp(const Shift: TShiftState; PageX, PageY: Double): Boolean;
    function FormEventKeyDown(KeyCode: Word; KeyData: LPARAM): Boolean;
    function FormEventKeyUp(KeyCode: Word; KeyData: LPARAM): Boolean;
    function FormEventKeyPress(Key: Word; KeyData: LPARAM): Boolean;
    function FormEventKillFocus: Boolean;
    function FormGetFocusedText: string;
    function FormGetSelectedText: string;
    function FormReplaceSelection(const ANewText: string): Boolean;
    function FormReplaceAndKeepSelection(const ANewText: string): Boolean;
    function FormSelectAllText: Boolean;
    function FormCanUndo: Boolean;
    function FormCanRedo: Boolean;
    function FormUndo: Boolean;
    function FormRedo: Boolean;

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

    { IsUriLinkAtPoint returns true if a Link annotation is at the specified coordinates.
      X, Y are in page coordinates. }
    function IsUriLinkAtPoint(X, Y: Double): Boolean; overload;
    { IsUriLinkAtPoint returns true if a Link annotation is at the specified coordinates. If one is found
      the Uri parameter is set to the link's URI.
      X, Y are in page coordinates. }
    function IsUriLinkAtPoint(X, Y: Double; var Uri: string): Boolean; overload;
    { GetLinkAtPoint returns the link annotation for the specified coordinates. If no link annotation
      was found it return nil. It not only returns Uri but also Goto, RemoteGoto, Launch, EmbeddedGoto
      link annotations. }
    function GetLinkAtPoint(X, Y: Double): TPdfAnnotation;

    { WebLinks are URLs that are parsed from the PDFs text content. No link annotation exists
      for them, so the IsUriLinkAtPoint and GetLinkAtPoint methods don't work for them. }
    function GetWebLinkCount: Integer;
    function GetWebLinkURL(LinkIndex: Integer): string;
    function GetWebLinkRectCount(LinkIndex: Integer): Integer;
    function GetWebLinkRect(LinkIndex, RectIndex: Integer): TPdfRect;
    function IsWebLinkAtPoint(X, Y: Double): Boolean; overload;
    function IsWebLinkAtPoint(X, Y: Double; var URL: string): Boolean; overload;

    property Handle: FPDF_PAGE read GetHandle;
    property TextHandle: FPDF_TEXTPAGE read GetTextHandle;

    property Width: Single read FWidth;
    property Height: Single read FHeight;
    property Transparency: Boolean read FTransparency;
    property Rotation: TPdfPageRotation read FRotation write SetRotation;

    property Annotations: TPdfAnnotationList read FAnnotations;
    property FormFields: TPdfFormFieldList read GetFormFields;
  end;

  TPdfFormInvalidateEvent = procedure(Document: TPdfDocument; Page: TPdfPage; const PageRect: TPdfRect) of object;
  TPdfFormOutputSelectedRectEvent = procedure(Document: TPdfDocument; Page: TPdfPage; const PageRect: TPdfRect) of object;
  TPdfFormGetCurrentPageEvent = procedure(Document: TPdfDocument; var CurrentPage: TPdfPage) of object;
  TPdfFormFieldFocusEvent = procedure(Document: TPdfDocument; Value: PWideChar; ValueLen: Integer; FieldFocused: Boolean) of object;
  TPdfExecuteNamedActionEvent = procedure(Document: TPdfDocument; NamedAction: TPdfNamedActionType) of object;

  TPdfAttachment = record
  private
    FDocument: TPdfDocument;
    FHandle: FPDF_ATTACHMENT;
    procedure CheckValid;

    function GetName: string;
    function GetKeyValue(const Key: string): string;
    procedure SetKeyValue(const Key, Value: string);
    function GetContentSize: Integer;
  public
    // SetContent/LoadFromXxx clears the Values[] dictionary.
    procedure SetContent(const ABytes: TBytes); overload;
    procedure SetContent(const ABytes: TBytes; Index: NativeInt; Count: Integer); overload;
    procedure SetContent(ABytes: PByte; Count: Integer); overload;
    procedure SetContent(const Value: RawByteString); overload;
    procedure SetContent(const Value: string; Encoding: TEncoding = nil); overload; // Default-encoding is UTF-8
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);

    procedure GetContent(var ABytes: TBytes); overload;
    procedure GetContent(Buffer: PByte); overload; // use ContentSize to allocate enough memory
    procedure GetContent(var Value: RawByteString); overload;
    procedure GetContent(var Value: string; Encoding: TEncoding = nil); overload;
    function GetContentAsBytes: TBytes;
    function GetContentAsRawByteString: RawByteString;
    function GetContentAsString(Encoding: TEncoding = nil): string; // Default-encoding is UTF-8

    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);

    function HasContent: Boolean;

    function HasKey(const Key: string): Boolean;
    function GetValueType(const Key: string): TPdfObjectType;

    property Name: string read GetName;
    property Values[const Key: string]: string read GetKeyValue write SetKeyValue;
    property ContentSize: Integer read GetContentSize;

    property Handle: FPDF_ATTACHMENT read FHandle;
  end;

  TPdfAttachmentList = class(TObject)
  private
    FDocument: TPdfDocument;
    function GetCount: Integer;
    function GetItem(Index: Integer): TPdfAttachment;
  public
    constructor Create(ADocument: TPdfDocument);

    function Add(const Name: string): TPdfAttachment;
    procedure Delete(Index: Integer);
    function IndexOf(const Name: string): Integer;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPdfAttachment read GetItem; default;
  end;

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
    FAttachments: TPdfAttachmentList;
    FFileName: string;
    {$IFDEF MSWINDOWS}
    FFileHandle: THandle;
    FFileMapping: THandle;
    {$ELSE}
    FFileStream: TFileStream;
    {$ENDIF MSWINDOWS}
    FBuffer: PByte;
    FBytes: TBytes;
    FClosing: Boolean;
    FUnsupportedFeatures: Boolean;
    FCustomLoadData: PCustomLoadDataRec;

    FForm: FPDF_FORMHANDLE;
    FJSPlatform: IPDF_JsPlatform;
    FFormFillHandler: TPdfFormFillHandler;
    FFormFieldHighlightColor: TColorRef;
    FFormFieldHighlightAlpha: Integer;
    FPrintHidesFormFieldHighlight: Boolean;
    FFormModified: Boolean;

    FOnFormInvalidate: TPdfFormInvalidateEvent;
    FOnFormOutputSelectedRect: TPdfFormOutputSelectedRectEvent;
    FOnFormGetCurrentPage: TPdfFormGetCurrentPageEvent;
    FOnFormFieldFocus: TPdfFormFieldFocusEvent;
    FOnExecuteNamedAction: TPdfExecuteNamedActionEvent;

    procedure InternLoadFromFile(const FileName: string; const Password: UTF8String);
    procedure InternLoadFromMem(Buffer: PByte; Size: NativeInt; const Password: UTF8String);
    procedure InternLoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; Size: LongWord;
      Param: Pointer; const Password: UTF8String);
    function InternImportPages(Source: TPdfDocument; PageIndices: PInteger; PageIndicesCount: Integer;
      const Range: AnsiString; Index: Integer; ImportByRange: Boolean): Boolean;
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
    procedure SetFormFieldHighlightColor(const Value: TColorRef);
    function FindPage(Page: FPDF_PAGE): TPdfPage;
    procedure UpdateFormFieldHighlight;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; Size: LongWord; Param: Pointer; const Password: UTF8String = '');
    procedure LoadFromActiveStream(Stream: TStream; const Password: UTF8String = ''); // Stream must not be released until the document is closed
    procedure LoadFromActiveBuffer(Buffer: Pointer; Size: NativeInt; const Password: UTF8String = ''); // Buffer must not be released until the document is closed
    procedure LoadFromBytes(const Bytes: TBytes; const Password: UTF8String = ''); overload;
    procedure LoadFromBytes(const Bytes: TBytes; Index: NativeInt; Count: NativeInt; const Password: UTF8String = ''); overload;
    procedure LoadFromStream(Stream: TStream; const Password: UTF8String = '');
    procedure LoadFromFile(const FileName: string; const Password: UTF8String = ''; LoadOption: TPdfDocumentLoadOption = dloDefault);
    procedure Close;

    procedure SaveToFile(const AFileName: string; Option: TPdfDocumentSaveOption = dsoRemoveSecurity; FileVersion: Integer = -1);
    procedure SaveToStream(Stream: TStream; Option: TPdfDocumentSaveOption = dsoRemoveSecurity; FileVersion: Integer = -1);
    procedure SaveToBytes(var Bytes: TBytes; Option: TPdfDocumentSaveOption = dsoRemoveSecurity; FileVersion: Integer = -1);

    function NewDocument: Boolean;
    class function CreateNPagesOnOnePageDocument(Source: TPdfDocument; NewPageWidth, NewPageHeight: Double; NumPagesXAxis, NumPagesYAxis: Integer): TPdfDocument; overload;
    class function CreateNPagesOnOnePageDocument(Source: TPdfDocument; NumPagesXAxis, NumPagesYAxis: Integer): TPdfDocument; overload;
    function ImportAllPages(Source: TPdfDocument; Index: Integer = -1): Boolean;
    function ImportPages(Source: TPdfDocument; const Range: string = ''; Index: Integer = -1): Boolean;
    function ImportPageRange(Source: TPdfDocument; PageIndex: Integer; Count: Integer = -1; Index: Integer = -1): Boolean;
    function ImportPagesByIndex(Source: TPdfDocument; const PageIndices: array of Integer; Index: Integer = -1): Boolean;
    procedure DeletePage(Index: Integer);
    function NewPage(Width, Height: Double; Index: Integer = -1): TPdfPage; overload;
    function NewPage(Index: Integer = -1): TPdfPage; overload;
    function ApplyViewerPreferences(Source: TPdfDocument): Boolean;
    function IsPageLoaded(PageIndex: Integer): Boolean;

    function GetFileIdentifier(IdType: TPdfFileIdType): string;
    function GetMetaText(const TagName: string): string;

    class function SetPrintMode(PrintMode: TPdfPrintMode): Boolean; static;

    property FileName: string read FFileName;
    property PageCount: Integer read GetPageCount;
    property Pages[Index: Integer]: TPdfPage read GetPage;
    property PageSizes[Index: Integer]: TPdfPoint read GetPageSize;

    property Attachments: TPdfAttachmentList read FAttachments;

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

    property FormFieldHighlightColor: TColorRef read FFormFieldHighlightColor write SetFormFieldHighlightColor default $FFE4DD;
    property FormFieldHighlightAlpha: Integer read FFormFieldHighlightAlpha write SetFormFieldHighlightAlpha default 100;
    property PrintHidesFormFieldHighlight: Boolean read FPrintHidesFormFieldHighlight write FPrintHidesFormFieldHighlight default True;

    property FormModified: Boolean read FFormModified write FFormModified;
    property OnFormInvalidate: TPdfFormInvalidateEvent read FOnFormInvalidate write FOnFormInvalidate;
    property OnFormOutputSelectedRect: TPdfFormOutputSelectedRectEvent read FOnFormOutputSelectedRect write FOnFormOutputSelectedRect;
    property OnFormGetCurrentPage: TPdfFormGetCurrentPageEvent read FOnFormGetCurrentPage write FOnFormGetCurrentPage;
    property OnFormFieldFocus: TPdfFormFieldFocusEvent read FOnFormFieldFocus write FOnFormFieldFocus;
    property OnExecuteNamedAction: TPdfExecuteNamedActionEvent read FOnExecuteNamedAction write FOnExecuteNamedAction;
  end;

  TPdfDocumentPrinterStatusEvent = procedure(Sender: TObject; CurrentPageNum, PageCount: Integer) of object;

  TPdfDocumentPrinter = class(TObject)
  private
    FBeginPrintCounter: Integer;

    FPrinterDC: HDC;
    FPrintPortraitOrientation: Boolean;
    FPaperSize: TSize;
    FPrintArea: TSize;
    FMargins: TPoint;

    FFitPageToPrintArea: Boolean;
    FOnPrintStatus: TPdfDocumentPrinterStatusEvent;

    function IsPortraitOrientation(AWidth, AHeight: Integer): Boolean;
    procedure GetPrinterBounds;
  protected
    function PrinterStartDoc(const AJobTitle: string): Boolean; virtual; abstract;
    procedure PrinterEndDoc; virtual; abstract;
    procedure PrinterStartPage; virtual; abstract;
    procedure PrinterEndPage; virtual; abstract;
    function GetPrinterDC: HDC; virtual; abstract;

    procedure InternPrintPage(APage: TPdfPage; X, Y, Width, Height: Double);
  public
    constructor Create;

    { BeginPrint must be called before printing multiple documents.
      Returns false if the printer can't print. (e.g. The user aborted the PDF Printer's FileDialog) }
    function BeginPrint(const AJobTitle: string = ''): Boolean;
    { EndPrint must be called after printing multiple documents were printed. }
    procedure EndPrint;

    { Prints a range of PDF document pages (0..PageCount-1) }
    function Print(ADocument: TPdfDocument; AFromPageIndex, AToPageIndex: Integer): Boolean; overload;
    { Prints all pages of the PDF document. }
    function Print(ADocument: TPdfDocument): Boolean; overload;


    { If FitPageToPrintArea is true the page fill be scaled to fit into the printable area. }
    property FitPageToPrintArea: Boolean read FFitPageToPrintArea write FFitPageToPrintArea default True;

    { OnPrintStatus is triggered after every printed page }
    property OnPrintStatus: TPdfDocumentPrinterStatusEvent read FOnPrintStatus write FOnPrintStatus;
  end;

function SetThreadPdfUnsupportedFeatureHandler(const Handler: TPdfUnsupportedFeatureHandler): TPdfUnsupportedFeatureHandler;

var
  PDFiumDllDir: string = '';
  PDFiumDllFileName: string = ''; // use this instead of PDFiumDllDir if you want to change the DLLs file name
  {$IF declared(FPDF_InitEmbeddedLibraries)}
  PDFiumResDir: string = '';
  {$IFEND}

implementation

resourcestring
  RsUnsupportedFeature = 'Function %s not supported';
  RsArgumentsOutOfRange = 'Function argument "%s" (%d) out of range';
  RsDocumentNotActive = 'PDF document is not open';
  {$IFNDEF CPUX64}
  RsFileTooLarge = 'PDF file "%s" is too large';
  {$ENDIF ~CPUX64}

  RsPdfCannotDeleteAttachmnent = 'Cannot delete the PDF attachment %d';
  RsPdfCannotAddAttachmnent = 'Cannot add the PDF attachment "%s"';
  RsPdfCannotSetAttachmentContent = 'Cannot set the PDF attachment content';
  RsPdfAttachmentContentNotSet = 'Content must be set before accessing string PDF attachmemt values';

  RsPdfAnnotationNotAFormFieldError = 'The annotation is not a form field';
  RsPdfAnnotationLinkRemoteGotoRequiresRemoteDocument = 'A remote goto annotation link requires a remote document';

  RsPdfErrorSuccess   = 'No error';
  RsPdfErrorUnknown   = 'Unknown error';
  RsPdfErrorFile      = 'File not found or can''t be opened';
  RsPdfErrorFormat    = 'File is not a PDF document or is corrupted';
  RsPdfErrorPassword  = 'Password required oder invalid password';
  RsPdfErrorSecurity  = 'Security schema is not support';
  RsPdfErrorPage      = 'Page does not exist or data error';
  RsPdfErrorXFALoad   = 'Load XFA error';
  RsPdfErrorXFALayout = 'Layout XFA error';

threadvar
  ThreadPdfUnsupportedFeatureHandler: TPdfUnsupportedFeatureHandler;
  UnsupportedFeatureCurrentDocument: TPdfDocument;

type
  { We don't want to use a TBytes temporary array if we can convert directly into the destination
    buffer. }
  TEncodingAccess = class(TEncoding)
  public
    function GetMemCharCount(Bytes: PByte; ByteCount: Integer): Integer;
    function GetMemChars(Bytes: PByte; ByteCount: Integer; Chars: PWideChar; CharCount: Integer): Integer;
  end;

function TEncodingAccess.GetMemCharCount(Bytes: PByte; ByteCount: Integer): Integer;
begin
  Result := GetCharCount(Bytes, ByteCount);
end;

function TEncodingAccess.GetMemChars(Bytes: PByte; ByteCount: Integer; Chars: PWideChar; CharCount: Integer): Integer;
begin
  Result := GetChars(Bytes, ByteCount, Chars, CharCount);
end;

function SetThreadPdfUnsupportedFeatureHandler(const Handler: TPdfUnsupportedFeatureHandler): TPdfUnsupportedFeatureHandler;
begin
  Result := ThreadPdfUnsupportedFeatureHandler;
  ThreadPdfUnsupportedFeatureHandler := Handler;
end;

{$IF defined(MSWINDOWS) and not declared(GetFileSizeEx)}
function GetFileSizeEx(hFile: THandle; var lpFileSize: Int64): BOOL; stdcall;
  external kernel32 name 'GetFileSizeEx';
{$IFEND}

procedure SwapInts(var X, Y: Integer);
var
  Tmp: Integer;
begin
  Tmp := X;
  X := Y;
  Y := Tmp;
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
        if PDFiumDllFileName <> '' then
          InitPDFiumEx(PDFiumDllFileName {$IF declared(FPDF_InitEmbeddedLibraries)}, PDFiumResDir{$IFEND})
        else
          InitPDFium(PDFiumDllDir {$IF declared(FPDF_InitEmbeddedLibraries)}, PDFiumResDir{$IFEND});
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
  case FPDF_GetLastError() of
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
    {$IF declared(FPDF_ERR_XFALOAD)}
    FPDF_ERR_XFALOAD:
      raise EPdfException.CreateRes(@RsPdfErrorXFALoad);
    FPDF_ERR_XFALAYOUT:
      raise EPdfException.CreateRes(@RsPdfErrorXFALayout);
    {$IFEND}
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

{$IFDEF MSWINDOWS}
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
      if Length(FFITimers) <> I + 1 then
        SetLength(FFITimers, I + 1);
    finally
      LeaveCriticalSection(FFITimersCritSect);
    end;
  end;
end;
{$ELSE MSWINDOWS}
type
  TFFITimer = class(TTimer)
  public
    FId: Integer;
    FTimerFunc: TFPDFTimerCallback;
    procedure DoTimerEvent(Sender: TObject);
  end;

var
  FFITimers: array of TFFITimer;
  FFITimersCritSect: TRTLCriticalSection;

{ TFFITimer }

procedure TFFITimer.DoTimerEvent(Sender: TObject);
begin
  FTimerFunc(FId);
end;

function FFI_SetTimer(pThis: PFPDF_FORMFILLINFO; uElapse: Integer; lpTimerFunc: TFPDFTimerCallback): Integer; cdecl;
var
  I: Integer;
  Id: Integer;
  Timer: TFFITimer;
begin
  // Find highest Id
  EnterCriticalSection(FFITimersCritSect);
  try
    Id := 0;
    for I := 0 to Length(FFITimers) - 1 do
      if (FFITimers[I] <> nil) and (FFITimers[I].FId > Id) then
        Id := FFITimers[I].FId;
    Inc(Id);

    Timer := TFFITimer.Create(nil);
    Timer.FId := Id;
    Timer.FTimerFunc:= lpTimerFunc;
    Timer.OnTimer := Timer.DoTimerEvent;
    Timer.Interval := uElapse;

    Result := Id;
    for I := 0 to Length(FFITimers) - 1 do
    begin
      if FFITimers[I] = nil then
      begin
        FFITimers[I] := Timer;
        Exit;
      end;
    end;
    I := Length(FFITimers);
    SetLength(FFITimers, I + 1);
    FFITimers[I] := Timer;
  finally
    LeaveCriticalSection(FFITimersCritSect);
  end;
end;

procedure FFI_KillTimer(pThis: PFPDF_FORMFILLINFO; nTimerID: Integer); cdecl;
var
  I: Integer;
begin
  if nTimerID <> 0 then
  begin
    EnterCriticalSection(FFITimersCritSect);
    try
      for I := 0 to Length(FFITimers) - 1 do
        if (FFITimers[I] <> nil) and (FFITimers[I].FId = nTimerID) then
          FreeAndNil(FFITimers[I]);

      I := Length(FFITimers) - 1;
      while (I >= 0) and (FFITimers[I] = nil) do
        Dec(I);
      if Length(FFITimers) <> I + 1 then
        SetLength(FFITimers, I + 1);
    finally
      LeaveCriticalSection(FFITimersCritSect);
    end;
  end;
end;
{$ENDIF MSWINDOWS}

function FFI_GetLocalTime(pThis: PFPDF_FORMFILLINFO): FPDF_SYSTEMTIME; cdecl;
{$IF not declared(PSystemTime)}
type
  PSystemTime = ^TSystemTime;
{$IFEND}
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

procedure FFI_ExecuteNamedAction(pThis: PFPDF_FORMFILLINFO; namedAction: FPDF_BYTESTRING); cdecl;
var
  Handler: PPdfFormFillHandler;
  NamedActionType: TPdfNamedActionType;
  S: UTF8String;
begin
  Handler := PPdfFormFillHandler(pThis);
  if Assigned(Handler.Document.OnExecuteNamedAction) then
  begin
    S := namedAction;

    if S = 'Print' then
      NamedActionType := naPrint
    else if S = 'NextPage' then
      NamedActionType := naNextPage
    else if S = 'PrevPage' then
      NamedActionType := naPrevPage
    else if S = 'FirstPage' then
      NamedActionType := naFirstPage
    else if S = 'LastPage' then
      NamedActionType := naLastPage
    else
      Exit;

    Handler.Document.OnExecuteNamedAction(Handler.Document, NamedActionType);
  end;
end;

procedure FFI_SetCursor(pThis: PFPDF_FORMFILLINFO; nCursorType: Integer); cdecl;
begin
  // A better solution is to check what form field type is under the mouse cursor in the
  // MoveMove event. Chrome/Edge doesn't rely on SetCursor either.
end;

procedure FFI_SetTextFieldFocus(pThis: PFPDF_FORMFILLINFO; value: FPDF_WIDESTRING; valueLen: FPDF_DWORD; is_focus: FPDF_BOOL); cdecl;
var
  Handler: PPdfFormFillHandler;
begin
  Handler := PPdfFormFillHandler(pThis);
  if (Handler.Document <> nil) and Assigned(Handler.Document.OnFormFieldFocus) then
    Handler.Document.OnFormFieldFocus(Handler.Document, value, valueLen, is_focus <> 0);
end;

procedure FFI_FocusChange(param: PFPDF_FORMFILLINFO; annot: FPDF_ANNOTATION; page_index: Integer); cdecl;
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

class function TPdfRect.New(Left, Top, Right, Bottom: Double): TPdfRect;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Right;
  Result.Bottom := Bottom;
end;

function TPdfRect.PtIn(const Pt: TPdfPoint): Boolean;
begin
  Result := (Pt.X >= Left) and (Pt.X < Right);
  if Result then
  begin
    // Page coordinates are upside down.
    if Top > Bottom then
      Result := (Pt.Y >= Bottom) and (Pt.Y < Top)
    else
      Result := (Pt.Y >= Top) and (Pt.Y < Bottom)
  end;
end;

{ TPdfDocument }

constructor TPdfDocument.Create;
begin
  inherited Create;
  FPages := TObjectList.Create;
  FAttachments := TPdfAttachmentList.Create(Self);
  {$IFDEF MSWINDOWS}
  FFileHandle := INVALID_HANDLE_VALUE;
  {$ENDIF MSWINDOWS}
  FFormFieldHighlightColor := $FFE4DD;
  FFormFieldHighlightAlpha := 100;
  FPrintHidesFormFieldHighlight := True;

  InitLib;
end;

destructor TPdfDocument.Destroy;
begin
  Close;
  FAttachments.Free;
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

    {$IFDEF MSWINDOWS}
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
    else
    {$ENDIF MSWINDOWS}
    if FBuffer <> nil then
    begin
      FreeMem(FBuffer);
      FBuffer := nil;
    end;
    FBytes := nil;

    {$IFDEF MSWINDOWS}
    if FFileHandle <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FFileHandle);
      FFileHandle := INVALID_HANDLE_VALUE;
    end;
    {$ELSE}
    FreeAndNil(FFileStream);
    {$ENDIF MSWINDOWS}

    FFileName := '';
    FFormModified := False;
  finally
    FClosing := False;
  end;
end;

{$IFDEF MSWINDOWS}
function ReadFromActiveFileHandle(Param: Pointer; Position: LongWord; Buffer: PByte; Size: LongWord): Boolean;
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
{$ENDIF MSWINDOWS}

procedure TPdfDocument.LoadFromFile(const FileName: string; const Password: UTF8String; LoadOption: TPdfDocumentLoadOption);
{$IFDEF MSWINDOWS}
var
  Size: Int64;
  Offset: NativeInt;
  NumRead: DWORD;
  LastError: DWORD;
{$ENDIF MSWINDOWS}
begin
  Close;
  if LoadOption = dloDefault then
  begin
    InternLoadFromFile(FileName, Password);
    FFileName := FileName;
    Exit;
  end;

  {$IFDEF MSWINDOWS}
  FFileHandle := CreateFileW(PWideChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if FFileHandle = INVALID_HANDLE_VALUE then
    RaiseLastOSError;
  try
    if not GetFileSizeEx(FFileHandle, Size) then
      RaiseLastOSError;
    if Size > High(Integer) then // PDFium LoadCustomDocument() can only handle PDFs up to 2 GB (see FPDF_FILEACCESS)
    begin
      {$IFDEF CPUX64}
      // FPDF_LoadCustomDocument wasn't updated to load larger files, so we fall back to MMF.
      if LoadOption = dloOnDemand then
        LoadOption := dloMMF;
      {$ELSE}
      raise EPdfException.CreateResFmt(@RsFileTooLarge, [ExtractFileName(FileName)]);
      {$ENDIF CPUX64}
    end;

    case LoadOption of
      dloMemory:
        begin
          if Size > 0 then
          begin
            try
              GetMem(FBuffer, Size);
              Offset := 0;
              while Offset < Size do
              begin
                if ((Size - Offset) and not $FFFFFFFF) <> 0 then
                  NumRead := $40000000
                else
                  NumRead := Size - Offset;

                if not ReadFile(FFileHandle, FBuffer[Offset], NumRead, NumRead, nil) then
                begin
                  LastError := GetLastError;
                  FreeMem(FBuffer);
                  FBuffer := nil;
                  RaiseLastOSError(LastError);
                end;
                Inc(Offset, NumRead);
              end;
            finally
              CloseHandle(FFileHandle);
              FFileHandle := INVALID_HANDLE_VALUE;
            end;

            InternLoadFromMem(FBuffer, Size, Password);
          end;
        end;

      dloMMF:
        begin
          FFileMapping := CreateFileMapping(FFileHandle, nil, PAGE_READONLY, 0, 0, nil);
          if FFileMapping = 0 then
            RaiseLastOSError;
          FBuffer := MapViewOfFile(FFileMapping, FILE_MAP_READ, 0, 0, Size);
          if FBuffer = nil then
            RaiseLastOSError;

          InternLoadFromMem(FBuffer, Size, Password);
        end;

      dloOnDemand:
        InternLoadFromCustom(ReadFromActiveFileHandle, Size, Pointer(FFileHandle), Password);
    end;
  except
    Close;
    raise;
  end;
  {$ELSE}
  FFileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    case LoadOption of
      dloMemory, dloMMF:
        begin
          try
            LoadFromStream(FFileStream, Password);
          finally
            FreeAndNil(FFileStream);
          end;
        end
      dloOnDemand:
        LoadFromActiveStream(FFileStream, Password);
    end;
  except
    FreeAndNil(FFileStream);
    raise;
  end;
  {$ENDIF MSWINDOWS}
  FFileName := FileName;
end;

procedure TPdfDocument.LoadFromStream(Stream: TStream; const Password: UTF8String);
var
  Size: NativeInt;
begin
  Close;
  Size := Stream.Size;
  if Size > 0 then
  begin
    GetMem(FBuffer, Size);
    try
      Stream.ReadBuffer(FBuffer^, Size);
      InternLoadFromMem(FBuffer, Size, Password);
    except
      Close;
      raise;
    end;
  end;
end;

procedure TPdfDocument.LoadFromActiveBuffer(Buffer: Pointer; Size: NativeInt; const Password: UTF8String);
begin
  Close;
  InternLoadFromMem(Buffer, Size, Password);
end;

procedure TPdfDocument.LoadFromBytes(const Bytes: TBytes; const Password: UTF8String);
begin
  LoadFromBytes(Bytes, 0, Length(Bytes), Password);
end;

procedure TPdfDocument.LoadFromBytes(const Bytes: TBytes; Index, Count: NativeInt;
  const Password: UTF8String);
var
  Len: NativeInt;
begin
  Close;

  Len := Length(Bytes);
  if Index >= Len then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['Index', Index]);
  if Index + Count > Len then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['Count', Count]);

  FBytes := Bytes; // keep alive after return
  InternLoadFromMem(@Bytes[Index], Count, Password);
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

procedure TPdfDocument.LoadFromActiveStream(Stream: TStream; const Password: UTF8String);
begin
  if Stream = nil then
    Close
  else
    LoadFromCustom(ReadFromActiveStream, Stream.Size, Stream, Password);
end;

procedure TPdfDocument.LoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; Size: LongWord;
  Param: Pointer; const Password: UTF8String);
begin
  Close;
  InternLoadFromCustom(ReadFunc, Size, Param, Password);
end;

function GetLoadFromCustomBlock(Param: Pointer; Position: LongWord; Buffer: PByte; Size: LongWord): Integer; cdecl;
var
  Data: TPdfDocument.PCustomLoadDataRec;
begin
  Data := TPdfDocument(param).FCustomLoadData;
  Result := Ord(Data.GetBlock(Data.Param, Position, Buffer, Size));
end;

procedure TPdfDocument.InternLoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; Size: LongWord;
  Param: Pointer; const Password: UTF8String);
var
  OldCurDoc: TPdfDocument;
begin
  if Assigned(ReadFunc) then
  begin
    New(FCustomLoadData);
    FCustomLoadData.Param := Param;
    FCustomLoadData.GetBlock := ReadFunc;
    FCustomLoadData.FileAccess.m_FileLen := Size;
    FCustomLoadData.FileAccess.m_GetBlock := GetLoadFromCustomBlock;
    FCustomLoadData.FileAccess.m_Param := Self;

    OldCurDoc := UnsupportedFeatureCurrentDocument;
    try
      UnsupportedFeatureCurrentDocument := Self;
      FDocument := FPDF_LoadCustomDocument(@FCustomLoadData.FileAccess, PAnsiChar(Pointer(Password)));
    finally
      UnsupportedFeatureCurrentDocument := OldCurDoc;
    end;
    DocumentLoaded;
  end;
end;

procedure TPdfDocument.InternLoadFromMem(Buffer: PByte; Size: NativeInt; const Password: UTF8String);
var
  OldCurDoc: TPdfDocument;
begin
  if Size > 0 then
  begin
    OldCurDoc := UnsupportedFeatureCurrentDocument;
    try
      UnsupportedFeatureCurrentDocument := Self;
      FDocument := FPDF_LoadMemDocument64(Buffer, Size, PAnsiChar(Pointer(Password)));
    finally
      UnsupportedFeatureCurrentDocument := OldCurDoc;
    end;
    DocumentLoaded;
  end;
end;

procedure TPdfDocument.InternLoadFromFile(const FileName: string; const Password: UTF8String);
var
  OldCurDoc: TPdfDocument;
  Utf8FileName: UTF8String;
begin
  Utf8FileName := UTF8Encode(FileName);
  OldCurDoc := UnsupportedFeatureCurrentDocument;
  try
    UnsupportedFeatureCurrentDocument := Self;
    // UTF8 now works with LoadDocument and it can handle large PDF files (2 GB+) what
    // FPDF_LoadCustomDocument can't because of the data types in FPDF_FILEACCESS.
    FDocument := FPDF_LoadDocument(PAnsiChar(Utf8FileName), PAnsiChar(Pointer(Password)));
  finally
    UnsupportedFeatureCurrentDocument := OldCurDoc;
  end;
  DocumentLoaded;
end;

procedure TPdfDocument.DocumentLoaded;
begin
  FFormModified := False;
  if FDocument = nil then
    RaiseLastPdfError;

  FPages.Count := FPDF_GetPageCount(FDocument);

  FillChar(FFormFillHandler, SizeOf(TPdfFormFillHandler), 0);
  FFormFillHandler.Document := Self;
  FFormFillHandler.FormFillInfo.version := 1; // will be set to 2 if we use an XFA-enabled DLL
  FFormFillHandler.FormFillInfo.FFI_Invalidate := FFI_Invalidate;
  FFormFillHandler.FormFillInfo.FFI_OnChange := FFI_Change;
  FFormFillHandler.FormFillInfo.FFI_OutputSelectedRect := FFI_OutputSelectedRect;
  FFormFillHandler.FormFillInfo.FFI_SetTimer := FFI_SetTimer;
  FFormFillHandler.FormFillInfo.FFI_KillTimer := FFI_KillTimer;
  FFormFillHandler.FormFillInfo.FFI_GetLocalTime := FFI_GetLocalTime;
  FFormFillHandler.FormFillInfo.FFI_GetPage := FFI_GetPage;
  FFormFillHandler.FormFillInfo.FFI_GetCurrentPage := FFI_GetCurrentPage;
  FFormFillHandler.FormFillInfo.FFI_GetRotation := FFI_GetRotation;
  FFormFillHandler.FormFillInfo.FFI_ExecuteNamedAction := FFI_ExecuteNamedAction;
  FFormFillHandler.FormFillInfo.FFI_SetCursor := FFI_SetCursor;
  FFormFillHandler.FormFillInfo.FFI_SetTextFieldFocus := FFI_SetTextFieldFocus;
  FFormFillHandler.FormFillInfo.FFI_OnFocusChange := FFI_FocusChange;
//  FFormFillHandler.FormFillInfo.FFI_DoURIAction := FFI_DoURIAction;
//  FFormFillHandler.FormFillInfo.FFI_DoGoToAction := FFI_DoGoToAction;

  if PDF_USE_XFA then
  begin
    FJSPlatform.version := 3;
    // FJSPlatform callbacks not implemented

    FFormFillHandler.FormFillInfo.m_pJsPlatform := @FJSPlatform;

    FFormFillHandler.FormFillInfo.version := 2;
    FFormFillHandler.FormFillInfo.xfa_disabled := 1; // Disable XFA support for now
  end;

  FForm := FPDFDOC_InitFormFillEnvironment(FDocument, @FFormFillHandler.FormFillInfo);
  if FForm <> nil then
  begin
    if PDF_USE_XFA and (FFormFillHandler.FormFillInfo.xfa_disabled = 0) then
      FPDF_LoadXFA(FDocument);
    UpdateFormFieldHighlight;

    FORM_DoDocumentJSAction(FForm);
    FORM_DoDocumentOpenAction(FForm);
  end;
end;

procedure TPdfDocument.UpdateFormFieldHighlight;
begin
  FPDF_SetFormFieldHighlightColor(FForm, 0, FFormFieldHighlightColor);
  FPDF_SetFormFieldHighlightAlpha(FForm, FFormFieldHighlightAlpha);
end;

function TPdfDocument.IsPageLoaded(PageIndex: Integer): Boolean;
var
  Page: TPdfPage;
begin
  Page := TPdfPage(FPages[PageIndex]);
  Result := (Page <> nil) and Page.IsLoaded;
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

class function TPdfDocument.CreateNPagesOnOnePageDocument(Source: TPdfDocument;
  NumPagesXAxis, NumPagesYAxis: Integer): TPdfDocument;
begin
  if Source.PageCount > 0 then
    Result := CreateNPagesOnOnePageDocument(Source, Source.PageSizes[0].X, Source.PageSizes[0].Y, NumPagesXAxis, NumPagesYAxis)
  else
    Result := CreateNPagesOnOnePageDocument(Source, PdfDefaultPageWidth, PdfDefaultPageHeight, NumPagesXAxis, NumPagesYAxis); // DIN A4 page
end;

class function TPdfDocument.CreateNPagesOnOnePageDocument(Source: TPdfDocument;
  NewPageWidth, NewPageHeight: Double; NumPagesXAxis, NumPagesYAxis: Integer): TPdfDocument;
var
  OldCurDoc: TPdfDocument;
begin
  Result := TPdfDocument.Create;
  try
    if (Source = nil) or not Source.Active then
      Result.NewDocument
    else
    begin
      OldCurDoc := UnsupportedFeatureCurrentDocument;
      try
        UnsupportedFeatureCurrentDocument := Result;
        Result.FDocument := FPDF_ImportNPagesToOne(Source.FDocument, NewPageWidth, NewPageHeight, NumPagesXAxis, NumPagesYAxis);
      finally
        UnsupportedFeatureCurrentDocument := OldCurDoc;
      end;
      if Result.FDocument <> nil then
        Result.DocumentLoaded
      else
        Result.NewDocument;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TPdfDocument.InternImportPages(Source: TPdfDocument; PageIndices: PInteger; PageIndicesCount: Integer;
  const Range: AnsiString; Index: Integer; ImportByRange: Boolean): Boolean;
var
  I, NewCount, OldCount, InsertCount: Integer;
begin
  CheckActive;
  Source.CheckActive;

  OldCount := FPDF_GetPageCount(FDocument);
  if Index < 0 then
    Index := OldCount;

  if ImportByRange then // Range = '' => Import all pages
    Result := FPDF_ImportPages(FDocument, Source.FDocument, PAnsiChar(Pointer(Range)), Index) <> 0
  else
    Result := FPDF_ImportPagesByIndex(FDocument, Source.FDocument, PageIndices, PageIndicesCount, Index) <> 0;

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

function TPdfDocument.ImportAllPages(Source: TPdfDocument; Index: Integer): Boolean;
begin
  Result := InternImportPages(Source, nil, 0, '', Index, False);
end;

function TPdfDocument.ImportPages(Source: TPdfDocument; const Range: string; Index: Integer): Boolean;
begin
  Result := InternImportPages(Source, nil, 0, AnsiString(Range), Index, True)
end;

function TPdfDocument.ImportPageRange(Source: TPdfDocument; PageIndex, Count, Index: Integer): Boolean;
begin
  Result := False;
  if (Source <> nil) and (PageIndex >= 0) then
  begin
    if Count = -1 then
      Count := Source.PageCount - PageIndex
    else if Count < 0 then
      Exit;

    if Count > 0 then
    begin
      if PageIndex + Count > Source.PageCount then
      begin
        Count := Source.PageCount - PageIndex;
        if Count = 0 then
          Exit;
      end;
      if (PageIndex = 0) and (Count = Source.PageCount) then
        Result := ImportAllPages(Source, Index)
      else
        Result := ImportPages(Source, Format('%d-%d', [PageIndex, PageIndex + Count - 1]));
    end;
  end;
end;

function TPdfDocument.ImportPagesByIndex(Source: TPdfDocument; const PageIndices: array of Integer; Index: Integer = -1): Boolean;
begin
  if Length(PageIndices) > 0 then
    Result := InternImportPages(Source, @PageIndices[0], Length(PageIndices), '', Index, False)
  else
    Result := ImportAllPages(Source, Index);
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
    Inner: TFPDFFileWrite; // emulate object inheritance
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
  CheckActive;

  FileWriteInfo.Inner.version := 1;
  FileWriteInfo.Inner.WriteBlock := @WriteBlockToStream;
  FileWriteInfo.Stream := Stream;

  if FForm <> nil then
  begin
    FORM_ForceToKillFocus(FForm); // also save the form field data that is currently focused
    FORM_DoDocumentAAction(FForm, FPDFDOC_AACTION_WS); // BeforeSave
  end;

  if FileVersion <> -1 then
    FPDF_SaveWithVersion(FDocument, @FileWriteInfo, Ord(Option), FileVersion)
  else
    FPDF_SaveAsCopy(FDocument, @FileWriteInfo, Ord(Option));

  if FForm <> nil then
    FORM_DoDocumentAAction(FForm, FPDFDOC_AACTION_DS); // AfterSave
end;

procedure TPdfDocument.SaveToBytes(var Bytes: TBytes; Option: TPdfDocumentSaveOption; FileVersion: Integer);
var
  Stream: TBytesStream;
  Size: NativeInt;
begin
  CheckActive;

  Stream := TBytesStream.Create(nil);
  try
    SaveToStream(Stream, Option, FileVersion);
    Size := Stream.Size;
    Bytes := Stream.Bytes;
  finally
    Stream.Free;
  end;
  // Trim the byte array from the stream's capacity to the actual size
  if Length(Bytes) <> Size then
    SetLength(Bytes, Size);
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
    Index := FPages.Count; // append new page
  LPage := FPDFPage_New(FDocument, Index, Width, Height);
  if LPage <> nil then
  begin
    Result := TPdfPage.Create(Self, LPage);
    FPages.Insert(Index, Result);
  end
  else
    Result := nil;
end;

function TPdfDocument.NewPage(Index: Integer = -1): TPdfPage;
begin
  Result := NewPage(PdfDefaultPageWidth, PdfDefaultPageHeight, Index);
end;

function TPdfDocument.ApplyViewerPreferences(Source: TPdfDocument): Boolean;
begin
  CheckActive;
  Source.CheckActive;
  Result := FPDF_CopyViewerPreferences(FDocument, Source.FDocument) <> 0;
end;

function TPdfDocument.GetFileIdentifier(IdType: TPdfFileIdType): string;
var
  Len: Integer;
  A: AnsiString;
begin
  CheckActive;
  Len := FPDF_GetFileIdentifier(FDocument, FPDF_FILEIDTYPE(IdType), nil, 0) div SizeOf(AnsiChar) - 1;
  if Len > 0 then
  begin
    SetLength(A, Len);
    FPDF_GetFileIdentifier(FDocument, FPDF_FILEIDTYPE(IdType), PAnsiChar(A), (Len + 1) * SizeOf(AnsiChar));
    Result := string(A);
  end
  else
    Result := '';
end;

function TPdfDocument.GetMetaText(const TagName: string): string;
var
  Len: Integer;
  A: AnsiString;
begin
  CheckActive;
  A := AnsiString(TagName);
  Len := FPDF_GetMetaText(FDocument, PAnsiChar(A), nil, 0) div SizeOf(WideChar) - 1;
  if Len > 0 then
  begin
    SetLength(Result, Len);
    FPDF_GetMetaText(FDocument, PAnsiChar(A), PWideChar(Result), (Len + 1) * SizeOf(WideChar));
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
  CheckActive;
  Result := Integer(FPDF_GetDocPermissions(FDocument));
end;

function TPdfDocument.GetFileVersion: Integer;
begin
  CheckActive;
  if FPDF_GetFileVersion(FDocument, Result) = 0 then
    Result := 0;
end;

function TPdfDocument.GetPageSize(Index: Integer): TPdfPoint;
var
  SizeF: TFSSizeF;
begin
  CheckActive;
  Result.X := 0;
  Result.Y := 0;
  if FPDF_GetPageSizeByIndexF(FDocument, Index, @SizeF) <> 0 then
  begin
    Result.X := SizeF.width;
    Result.Y := SizeF.height;
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
  {$IFDEF MSWINDOWS}
  Result := FPDF_SetPrintMode(Ord(PrintMode)) <> 0;
  {$ELSE}
  Result := False;
  {$ENDIF MSWINDOWS}
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

procedure TPdfDocument.SetFormFieldHighlightColor(const Value: TColorRef);
begin
  if Value <> FFormFieldHighlightColor then
  begin
    FFormFieldHighlightColor := Value;
    if Active then
      FPDF_SetFormFieldHighlightColor(FForm, 0, FFormFieldHighlightColor);
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
  FAnnotations := TPdfAnnotationList.Create(Self);

  AfterOpen;
end;

destructor TPdfPage.Destroy;
begin
  Close;
  FDocument.ExtractPage(Self);
  FreeAndNil(FAnnotations);
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
  FAnnotations.CloseAnnotations;

  if IsValidForm then
  begin
    FORM_DoPageAAction(FPage, FDocument.FForm, FPDFPAGE_AACTION_CLOSE);
    FORM_OnBeforeClosePage(FPage, FDocument.FForm);
  end;

  if FPageLinkHandle <> nil then
  begin
    FPDFLink_CloseWebLinks(FPageLinkHandle);
    FPageLinkHandle := nil;
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

function TPdfPage.GetPdfActionFilePath(Action: FPDF_ACTION): string;
var
  ByteSize: Integer;
  Buf: UTF8String;
begin
  Result := '';
  if Action <> nil then
  begin
    case FPDFAction_GetType(Action) of
      PDFACTION_LAUNCH,
      PDFACTION_REMOTEGOTO:
        begin
          ByteSize := FPDFAction_GetFilePath(Action, nil, 0);
          if ByteSize > 0 then
          begin
            SetLength(Buf, ByteSize); // we could optimize this with "SetLength(Buf, ByteSize - 1)" and use already existing #0 terminator
            ByteSize := FPDFAction_GetFilePath(Action, PAnsiChar(Buf), Length(Buf));
          end;
          if ByteSize > 0 then
          begin
            SetLength(Buf, ByteSize - 1); // ByteSize includes #0
            Result := UTF8ToString(Buf);
          end;
        end;
    end;
  end;
end;

function TPdfPage.GetPdfActionUriPath(Action: FPDF_ACTION): string;
var
  ByteSize: Integer;
  Buf: UTF8String;
begin
  Result := '';
  if Action <> nil then
  begin
    ByteSize := FPDFAction_GetURIPath(FDocument.Handle, Action, nil, 0);
    if ByteSize > 0 then
    begin
      SetLength(Buf, ByteSize); // we could optimize this with "SetLength(Buf, ByteSize - 1)" and use already existing #0 terminator
      ByteSize := FPDFAction_GetURIPath(FDocument.Handle, Action, PAnsiChar(Buf), Length(Buf));
    end;
    if ByteSize > 0 then
    begin
      SetLength(Buf, ByteSize - 1); // ByteSize includes #0
      Result := UTF8ToString(Buf);
    end;
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

procedure TPdfPage.Draw(DC: HDC; X, Y, Width, Height: Integer; Rotate: TPdfPageRotation;
  const Options: TPdfPageRenderOptions; PageBackground: TColorRef);
var
  BitmapInfo: TBitmapInfo;
  Bmp, OldBmp: HBITMAP;
  BmpBits: Pointer;
  PdfBmp: TPdfBitmap;
  BmpDC: HDC;
begin
  Open;

  {$IFDEF MSWINDOWS}
  if proPrinting in Options then
  begin
    if IsValidForm and (FPDFPage_GetAnnotCount(FPage) > 0) then
    begin
      // Form content isn't printed unless it was flattend and the page was reloaded.
      ApplyChanges;
      Flatten(True);
      Close;
      Open;
    end;
    FPDF_RenderPage(DC, FPage, X, Y, Width, Height, Ord(Rotate), GetDrawFlags(Options));
    Exit;
  end;
  {$ENDIF MSWINDOWS}


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
        PdfBmp.FillRect(0, 0, Width, Height, $FF000000 or PageBackground);
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
      FormEventKillFocus;
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
  FWidth := FPDF_GetPageWidthF(FPage);
  FHeight := FPDF_GetPageHeightF(FPage);
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
  // Page coordinales are upside down, but device coordinates aren't.
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
  begin
    FPDFPage_GenerateContent(FPage);

    // Newly added text annotations will not show the text popup unless the page is notified.
    FAnnotations.CloseAnnotations;
    if IsValidForm then
    begin
      FORM_DoPageAAction(FPage, FDocument.FForm, FPDFPAGE_AACTION_CLOSE);
      FORM_OnBeforeClosePage(FPage, FDocument.FForm);

      FORM_OnAfterLoadPage(FPage, FDocument.FForm);
      FORM_DoPageAAction(FPage, FDocument.FForm, FPDFPAGE_AACTION_OPEN);
    end;
  end;
end;

procedure TPdfPage.Flatten(AFlatPrint: Boolean);
const
  Flags: array[Boolean] of Integer = (FLAT_NORMALDISPLAY, FLAT_PRINT);
begin
  if FPage <> nil then
    FPDFPage_Flatten(FPage, Flags[AFlatPrint]);
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
  // WebLinks are not stored in the PDF but are created by parsing the page's text for URLs.
  // They are accessed differently than annotation links, which are stored in the PDF.
  if (FPageLinkHandle = nil) and BeginText then
    FPageLinkHandle := FPDFLink_LoadWebLinks(FTextHandle);
  Result := FPageLinkHandle <> nil;
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

    FSearchHandle := FPDFText_FindStart(FTextHandle, PWideChar(SearchString), Flags, StartIndex);
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
    SetLength(Result, Count); // we let GetText overwrite our #0 terminator with its #0
    Len := FPDFText_GetText(FTextHandle, CharIndex, Count, PWideChar(Result)) - 1; // returned length includes the #0
    if Len <= 0 then
      Result := ''
    else if Len < Count then
      SetLength(Result, Len);
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
      FPDFText_GetBoundedText(FTextHandle, Left, Top, Right, Bottom, PWideChar(Result), Len);
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

function TPdfPage.IsUriLinkAtPoint(X, Y: Double): Boolean;
var
  Link: FPDF_LINK;
  Action: FPDF_ACTION;
begin
  Result := False;
  Link := FPDFLink_GetLinkAtPoint(Handle, X, Y);
  if Link <> nil then
  begin
    Action := FPDFLink_GetAction(Link);
    if (Action <> nil) and (FPDFAction_GetType(Action) = PDFACTION_URI) then
      Result := True;
  end;
end;

function TPdfPage.IsUriLinkAtPoint(X, Y: Double; var Uri: string): Boolean;
var
  Link: FPDF_LINK;
  Action: FPDF_ACTION;
begin
  Action := nil;
  Result := False;
  Link := FPDFLink_GetLinkAtPoint(Handle, X, Y);
  if Link <> nil then
  begin
    Action := FPDFLink_GetAction(Link);
    if (Action <> nil) and (FPDFAction_GetType(Action) = PDFACTION_URI) then
      Result := True;
  end;

  if Result then
    Uri := GetPdfActionUriPath(Action)
  else
    Uri := '';
end;

function TPdfPage.GetLinkAtPoint(X, Y: Double): TPdfAnnotation;
var
  Link: FPDF_LINK;
begin
  Link := FPDFLink_GetLinkAtPoint(Handle, X, Y);
  if Link <> nil then
  begin
    Result := Annotations.FindLink(Link);
    if (Result <> nil) and (Result.LinkType = altUnsupported) then
      Result := nil;
  end
  else
    Result := nil;
end;

function TPdfPage.GetWebLinkCount: Integer;
begin
  if BeginWebLinks then
  begin
    Result := FPDFLink_CountWebLinks(FPageLinkHandle);
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
    Len := FPDFLink_GetURL(FPageLinkHandle, LinkIndex, nil, 0) - 1; // including #0 terminator
    if Len > 0 then
    begin
      SetLength(Result, Len);
      FPDFLink_GetURL(FPageLinkHandle, LinkIndex, PWideChar(Result), Len + 1); // including #0 terminator
    end;
  end;
end;

function TPdfPage.GetWebLinkRectCount(LinkIndex: Integer): Integer;
begin
  if BeginWebLinks then
    Result := FPDFLink_CountRects(FPageLinkHandle, LinkIndex)
  else
    Result := 0;
end;

function TPdfPage.GetWebLinkRect(LinkIndex, RectIndex: Integer): TPdfRect;
begin
  if BeginWebLinks then
    FPDFLink_GetRect(FPageLinkHandle, LinkIndex, RectIndex, Result.Left, Result.Top, Result.Right, Result.Bottom)
  else
    Result := TPdfRect.Empty;
end;

function TPdfPage.IsWebLinkAtPoint(X, Y: Double): Boolean;
var
  LinkIndex, RectIndex: Integer;
  Pt: TPdfPoint;
begin
  Result := True;
  Pt.X := X;
  Pt.Y := Y;
  for LinkIndex := 0 to GetWebLinkCount - 1 do
    for RectIndex := 0 to GetWebLinkRectCount(LinkIndex) - 1 do
      if GetWebLinkRect(LinkIndex, RectIndex).PtIn(Pt) then
        Exit;
  Result := False;
end;

function TPdfPage.IsWebLinkAtPoint(X, Y: Double; var URL: string): Boolean;
var
  LinkIndex, RectIndex: Integer;
  Pt: TPdfPoint;
begin
  Result := True;
  Pt.X := X;
  Pt.Y := Y;
  for LinkIndex := 0 to GetWebLinkCount - 1 do
  begin
    for RectIndex := 0 to GetWebLinkRectCount(LinkIndex) - 1 do
    begin
      if GetWebLinkRect(LinkIndex, RectIndex).PtIn(Pt) then
      begin
        URL := GetWebLinkURL(LinkIndex);
        Exit;
      end;
    end;
  end;
  Result := False;
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
  {$IFDEF MSWINDOWS}
  if GetKeyState(VK_SHIFT) < 0 then
    Result := Result or FWL_EVENTFLAG_ShiftKey;
  if GetKeyState(VK_CONTROL) < 0 then
    Result := Result or FWL_EVENTFLAG_ControlKey;
  {$ENDIF MSWINDOWS}
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

function TPdfPage.FormEventMouseWheel(const Shift: TShiftState; WheelDelta: Integer; PageX, PageY: Double): Boolean;
var
  Pt: TFSPointF;
  WheelX, WheelY: Integer;
begin
  if IsValidForm then
  begin
    Pt.X := PageX;
    Pt.Y := PageY;
    WheelX := 0;
    WheelY := 0;
    if ssShift in Shift then
      WheelX := WheelDelta
    else
      WheelY := WheelDelta;
    Result := FORM_OnMouseWheel(FDocument.FForm, FPage, GetMouseModifier(Shift), @Pt, WheelX, WheelY) <> 0;
  end
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

function TPdfPage.FormEventRButtonDown(const Shift: TShiftState; PageX, PageY: Double): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnRButtonDown(FDocument.FForm, FPage, GetMouseModifier(Shift), PageX, PageY) <> 0
  else
    Result := False;
end;

function TPdfPage.FormEventRButtonUp(const Shift: TShiftState; PageX, PageY: Double): Boolean;
begin
  if IsValidForm then
    Result := FORM_OnRButtonUp(FDocument.FForm, FPage, GetMouseModifier(Shift), PageX, PageY) <> 0
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

function TPdfPage.FormEventKillFocus: Boolean;
begin
  if IsValidForm then
    Result := FORM_ForceToKillFocus(FDocument.FForm) <> 0
  else
    Result := False;
end;

function TPdfPage.FormGetFocusedText: string;
var
  ByteLen: LongWord;
begin
  if IsValidForm then
  begin
    ByteLen := FORM_GetFocusedText(FDocument.FForm, FPage, nil, 0); // UTF 16 including #0 terminator in byte size
    if ByteLen <= 2 then // WideChar(#0) => empty string
      Result := ''
    else
    begin
      SetLength(Result, ByteLen div SizeOf(WideChar) - 1);
      FORM_GetFocusedText(FDocument.FForm, FPage, PWideChar(Result), ByteLen);
    end;
  end
  else
    Result := '';
end;

function TPdfPage.FormGetSelectedText: string;
var
  ByteLen: LongWord;
begin
  if IsValidForm then
  begin
    ByteLen := FORM_GetSelectedText(FDocument.FForm, FPage, nil, 0); // UTF 16 including #0 terminator in byte size
    if ByteLen <= 2 then // WideChar(#0) => empty string
      Result := ''
    else
    begin
      SetLength(Result, ByteLen div SizeOf(WideChar) - 1);
      FORM_GetSelectedText(FDocument.FForm, FPage, PWideChar(Result), ByteLen);
    end;
  end
  else
    Result := '';
end;

function TPdfPage.FormReplaceSelection(const ANewText: string): Boolean;
begin
  if IsValidForm then
  begin
    FORM_ReplaceSelection(FDocument.FForm, FPage, PWideChar(ANewText));
    Result := True;
  end
  else
    Result := False;
end;

function TPdfPage.FormReplaceAndKeepSelection(const ANewText: string): Boolean;
begin
  if IsValidForm then
  begin
    FORM_ReplaceAndKeepSelection(FDocument.FForm, FPage, PWideChar(ANewText));
    Result := True;
  end
  else
    Result := False;
end;

function TPdfPage.FormSelectAllText: Boolean;
begin
  if IsValidForm then
    Result := FORM_SelectAllText(FDocument.FForm, FPage) <> 0
  else
    Result := False;
end;

function TPdfPage.FormCanUndo: Boolean;
begin
  if IsValidForm then
    Result := FORM_CanUndo(FDocument.FForm, FPage) <> 0
  else
    Result := False;
end;

function TPdfPage.FormCanRedo: Boolean;
begin
  if IsValidForm then
    Result := FORM_CanRedo(FDocument.FForm, FPage) <> 0
  else
    Result := False;
end;

function TPdfPage.FormUndo: Boolean;
begin
  if IsValidForm then
    Result := FORM_Undo(FDocument.FForm, FPage) <> 0
  else
    Result := False;
end;

function TPdfPage.FormRedo: Boolean;
begin
  if IsValidForm then
    Result := FORM_Redo(FDocument.FForm, FPage) <> 0
  else
    Result := False;
end;

function TPdfPage.HasFormFieldAtPoint(X, Y: Double): TPdfFormFieldType;
begin
  Result := TPdfFormFieldType(FPDFPage_HasFormFieldAtPoint(FDocument.FForm, FPage, X, Y));
  if (Result < Low(TPdfFormFieldType)) or (Result > High(TPdfFormFieldType)) then
    Result := fftUnknown;
end;

function TPdfPage.GetHandle: FPDF_PAGE;
begin
  Open;
  Result := FPage;
end;

function TPdfPage.IsLoaded: Boolean;
begin
  Result := FPage <> nil;
end;

function TPdfPage.GetTextHandle: FPDF_TEXTPAGE;
begin
  if BeginText then
    Result := FTextHandle
  else
    Result := nil;
end;

function TPdfPage.GetFormFields: TPdfFormFieldList;
begin
  Result := Annotations.FormFields;
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

{ TPdfAttachmentList }

constructor TPdfAttachmentList.Create(ADocument: TPdfDocument);
begin
  inherited Create;
  FDocument := ADocument;
end;

function TPdfAttachmentList.GetCount: Integer;
begin
  FDocument.CheckActive;
  Result := FPDFDoc_GetAttachmentCount(FDocument.Handle);
end;

function TPdfAttachmentList.GetItem(Index: Integer): TPdfAttachment;
var
  Attachment: FPDF_ATTACHMENT;
begin
  FDocument.CheckActive;
  Attachment := FPDFDoc_GetAttachment(FDocument.Handle, Index);
  if Attachment = nil then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['Index']);
  Result.FDocument := FDocument;
  Result.FHandle := Attachment;
end;

procedure TPdfAttachmentList.Delete(Index: Integer);
begin
  FDocument.CheckActive;
  if FPDFDoc_DeleteAttachment(FDocument.Handle, Index) = 0 then
    raise EPdfException.CreateResFmt(@RsPdfCannotDeleteAttachmnent, [Index]);
end;

function TPdfAttachmentList.Add(const Name: string): TPdfAttachment;
begin
  FDocument.CheckActive;
  Result.FDocument := FDocument;
  Result.FHandle := FPDFDoc_AddAttachment(FDocument.Handle, PWideChar(Name));
  if Result.FHandle = nil then
    raise EPdfException.CreateResFmt(@RsPdfCannotAddAttachmnent, [Name]);
end;

function TPdfAttachmentList.IndexOf(const Name: string): Integer;
begin
  for Result := 0 to Count - 1 do
    if Items[Result].Name = Name then
      Exit;
  Result := -1;
end;

{ TPdfAttachment }

function TPdfAttachment.GetName: string;
var
  ByteLen: LongWord;
begin
  CheckValid;
  ByteLen := FPDFAttachment_GetName(Handle, nil, 0); // UTF 16 including #0 terminator in byte size
  if ByteLen <= 2 then
    Result := ''
  else
  begin
    SetLength(Result, ByteLen div SizeOf(WideChar) - 1);
    FPDFAttachment_GetName(FHandle, PWideChar(Result), ByteLen);
  end;
end;

procedure TPdfAttachment.CheckValid;
begin
  if FDocument <> nil then
    FDocument.CheckActive;
end;

procedure TPdfAttachment.SetContent(ABytes: PByte; Count: Integer);
begin
  CheckValid;
  if FPDFAttachment_SetFile(FHandle, FDocument.Handle, ABytes, Count) = 0 then
    raise EPdfException.CreateResFmt(@RsPdfCannotSetAttachmentContent, [Name]);
end;

procedure TPdfAttachment.SetContent(const Value: RawByteString);
begin
  if Value = '' then
    SetContent(nil, 0)
  else
    SetContent(PByte(PAnsiChar(Value)), Length(Value) * SizeOf(AnsiChar));
end;

procedure TPdfAttachment.SetContent(const Value: string; Encoding: TEncoding = nil);
begin
  CheckValid;
  if Value = '' then
    SetContent(nil, 0)
  else if (Encoding = nil) or (Encoding = TEncoding.UTF8) then
    SetContent(UTF8Encode(Value))
  else
    SetContent(Encoding.GetBytes(Value));
end;

procedure TPdfAttachment.SetContent(const ABytes: TBytes; Index: NativeInt; Count: Integer);
var
  Len: NativeInt;
begin
  CheckValid;

  Len := Length(ABytes);
  if Index >= Len then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['Index', Index]);
  if Index + Count > Len then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['Count', Count]);

  if Count = 0 then
    SetContent(nil, 0)
  else
    SetContent(@ABytes[Index], Count);
end;

procedure TPdfAttachment.SetContent(const ABytes: TBytes);
begin
  SetContent(ABytes, 0, Length(ABytes));
end;

procedure TPdfAttachment.LoadFromStream(Stream: TStream);
var
  StreamPos, StreamSize: Int64;
  Buf: PByte;
  Count: Integer;
begin
  CheckValid;

  StreamPos := Stream.Position;
  StreamSize := Stream.Size;
  Count := StreamSize - StreamPos;
  if Count = 0 then
    SetContent(nil, 0)
  else
  begin
    if Stream is TCustomMemoryStream then // direct access to the memory
    begin
      SetContent(PByte(TCustomMemoryStream(Stream).Memory) + StreamPos, Count);
      Stream.Position := StreamSize; // simulate the ReadBuffer call
    end
    else
    begin
      if Count = 0 then
        SetContent(nil, 0)
      else
      begin
        GetMem(Buf, Count);
        try
          Stream.ReadBuffer(Buf^, Count);
          SetContent(Buf, Count);
        finally
          FreeMem(Buf);
        end;
      end;
    end;
  end;
end;

procedure TPdfAttachment.LoadFromFile(const FileName: string);
var
  Stream: TFileStream;
begin
  CheckValid;

  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

function TPdfAttachment.HasKey(const Key: string): Boolean;
begin
  CheckValid;
  Result := FPDFAttachment_HasKey(FHandle, PAnsiChar(UTF8Encode(Key))) <> 0;
end;

function TPdfAttachment.GetValueType(const Key: string): TPdfObjectType;
begin
  CheckValid;
  Result := TPdfObjectType(FPDFAttachment_GetValueType(FHandle, PAnsiChar(UTF8Encode(Key))));
end;

procedure TPdfAttachment.SetKeyValue(const Key, Value: string);
begin
  CheckValid;
  if FPDFAttachment_SetStringValue(FHandle, PAnsiChar(UTF8Encode(Key)), PWideChar(Value)) = 0 then
    raise EPdfException.CreateRes(@RsPdfAttachmentContentNotSet);
end;

function TPdfAttachment.GetKeyValue(const Key: string): string;
var
  ByteLen: LongWord;
  Utf8Key: UTF8String;
begin
  CheckValid;
  Utf8Key := UTF8Encode(Key);
  ByteLen := FPDFAttachment_GetStringValue(FHandle, PAnsiChar(Utf8Key), nil, 0);
  if ByteLen = 0 then
    raise EPdfException.CreateRes(@RsPdfAttachmentContentNotSet);

  if ByteLen <= 2 then
    Result := ''
  else
  begin
    SetLength(Result, (ByteLen div SizeOf(WideChar) - 1));
    FPDFAttachment_GetStringValue(FHandle, PAnsiChar(Utf8Key), PWideChar(Result), ByteLen);
  end;
end;

function TPdfAttachment.GetContentSize: Integer;
var
  OutBufLen: LongWord;
begin
  CheckValid;
  if FPDFAttachment_GetFile(FHandle, nil, 0, OutBufLen) = 0 then
    Result := 0
  else
    Result := Integer(OutBufLen);
end;

function TPdfAttachment.HasContent: Boolean;
var
  OutBufLen: LongWord;
begin
  CheckValid;
  Result := FPDFAttachment_GetFile(FHandle, nil, 0, OutBufLen) <> 0;
end;

procedure TPdfAttachment.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  CheckValid;

  Stream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TPdfAttachment.SaveToStream(Stream: TStream);
var
  Size: Integer;
  OutBufLen: LongWord;
  StreamPos: Int64;
  Buf: PByte;
begin
  Size := ContentSize;

  if Size > 0 then
  begin
    if Stream is TCustomMemoryStream then // direct access to the memory
    begin
      StreamPos := Stream.Position;
      if StreamPos + Size > Stream.Size then
        Stream.Size := StreamPos + Size; // allocate enough memory
      Stream.Position := StreamPos;

      FPDFAttachment_GetFile(FHandle, PByte(TCustomMemoryStream(Stream).Memory) + StreamPos, Size, OutBufLen);
      Stream.Position := StreamPos + Size; // simulate Stream.WriteBuffer
    end
    else
    begin
      GetMem(Buf, Size);
      try
        FPDFAttachment_GetFile(FHandle, Buf, Size, OutBufLen);
        Stream.WriteBuffer(Buf^, Size);
      finally
        FreeMem(Buf);
      end;
    end;
  end;
end;

procedure TPdfAttachment.GetContent(var Value: string; Encoding: TEncoding);
var
  Size: Integer;
  OutBufLen: LongWord;
  Buf: PByte;
begin
  Size := ContentSize;
  if Size <= 0 then
    Value := ''
  else if Encoding = TEncoding.Unicode then // no conversion needed
  begin
    SetLength(Value, Size div SizeOf(WideChar));
    FPDFAttachment_GetFile(FHandle, PWideChar(Value), Size, OutBufLen);
  end
  else
  begin
    if Encoding = nil then
      Encoding := TEncoding.UTF8;

    GetMem(Buf, Size);
    try
      FPDFAttachment_GetFile(FHandle, Buf, Size, OutBufLen);
      SetLength(Value, TEncodingAccess(Encoding).GetMemCharCount(Buf, Size));
      if Value <> '' then
        TEncodingAccess(Encoding).GetMemChars(Buf, Size, PWideChar(Value), Length(Value));
    finally
      FreeMem(Buf);
    end;
  end;
end;

procedure TPdfAttachment.GetContent(var Value: RawByteString);
var
  Size: Integer;
  OutBufLen: LongWord;
begin
  Size := ContentSize;

  if Size <= 0 then
    Value := ''
  else
  begin
    SetLength(Value, Size);
    FPDFAttachment_GetFile(FHandle, PAnsiChar(Value), Size, OutBufLen);
  end;
end;

procedure TPdfAttachment.GetContent(Buffer: PByte);
var
  OutBufLen: LongWord;
begin
  FPDFAttachment_GetFile(FHandle, Buffer, ContentSize, OutBufLen);
end;

procedure TPdfAttachment.GetContent(var ABytes: TBytes);
var
  Size: Integer;
  OutBufLen: LongWord;
begin
  Size := ContentSize;

  if Size <= 0 then
    ABytes := nil
  else
  begin
    SetLength(ABytes, Size);
    FPDFAttachment_GetFile(FHandle, @ABytes[0], Size, OutBufLen);
  end;
end;

function TPdfAttachment.GetContentAsBytes: TBytes;
begin
  GetContent(Result);
end;

function TPdfAttachment.GetContentAsRawByteString: RawByteString;
begin
  GetContent(Result);
end;

function TPdfAttachment.GetContentAsString(Encoding: TEncoding): string;
begin
  GetContent(Result, Encoding);
end;

{ TPdfAnnotationList }

constructor TPdfAnnotationList.Create(APage: TPdfPage);
begin
  inherited Create;
  FPage := APage;
  FItems := TObjectList.Create;
end;

destructor TPdfAnnotationList.Destroy;
begin
  FreeAndNil(FFormFields);
  FreeAndNil(FItems); // closes all annotations
  inherited Destroy;
end;

procedure TPdfAnnotationList.CloseAnnotations;
begin
  FreeAndNil(FFormFields);
  FreeAndNil(FItems); // closes all annotations
  FItems := TObjectList.Create;
end;

function TPdfAnnotationList.GetCount: Integer;
begin
  Result := FPDFPage_GetAnnotCount(FPage.Handle);
end;

function TPdfAnnotationList.GetItem(Index: Integer): TPdfAnnotation;
var
  Annot: FPDF_ANNOTATION;
begin
  FPage.FDocument.CheckActive;

  if (Index < 0) or (Index >= FItems.Count) or (FItems[Index] = nil) then
  begin
    Annot := FPDFPage_GetAnnot(FPage.Handle, Index);
    if Annot = nil then
      raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['Index']);

    while FItems.Count <= Index do
      FItems.Add(nil);
    FItems[Index] := TPdfAnnotation.Create(FPage, Annot);
  end;
  Result := FItems[Index] as TPdfAnnotation;
end;

procedure TPdfAnnotationList.DestroyingItem(Item: TPdfAnnotation);
var
  Index: Integer;
begin
  if (Item <> nil) and (FItems <> nil) then
  begin
    Index := FItems.IndexOf(Item);
    if Index <> -1 then
      FItems.List[Index] := nil; // Bypass the Items[] setter to not destroy the Item twice
  end;
end;

procedure TPdfAnnotationList.DestroyingFormField(FormField: TPdfFormField);
begin
  if FFormFields <> nil then
    FFormFields.DestroyingItem(FormField);
end;

function TPdfAnnotationList.GetFormFields: TPdfFormFieldList;
begin
  if FFormFields = nil then
    FFormFields := TPdfFormFieldList.Create(Self);
  Result := FFormFields;
end;

function TPdfAnnotationList.GetAnnotationsLoaded: Boolean;
begin
  Result := FItems.Count > 0;
end;

function TPdfAnnotationList.NewTextAnnotation(const Text: string; const R: TPdfRect): Boolean;
var
  Annot: FPDF_ANNOTATION;
  SingleR: FS_RECTF;
begin
  FPage.FDocument.CheckActive;
  SingleR.left := R.Left;
  SingleR.right := R.Right;
  // Page coordinates are upside down
  if R.Top < R.Bottom then
  begin
    SingleR.top := R.Bottom;
    SingleR.bottom := R.Top;
  end
  else
  begin
    SingleR.top := R.Top;
    SingleR.bottom := R.Bottom;
  end;


  Annot := FPDFPage_CreateAnnot(FPage.Handle, FPDF_ANNOT_TEXT);
  Result := Annot <> nil;
  if Result then
  begin
    FPDFAnnot_SetRect(Annot, @SingleR);
    FPDFAnnot_SetStringValue(Annot, 'Contents', PWideChar(Text));
  end;
end;

function TPdfAnnotationList.FindLink(Link: FPDF_LINK): TPdfAnnotation;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := Items[I];
    if (Result.IsLink) and (FPDFAnnot_GetLink(Result.Handle) = Link) then
      Exit;
  end;
  Result := nil;
end;


{ TPdfFormFieldList }

constructor TPdfFormFieldList.Create(AAnnotations: TPdfAnnotationList);
var
  I: Integer;
begin
  inherited Create;
  FItems := TList.Create;

  for I := 0 to AAnnotations.Count - 1 do
    if AAnnotations[I].IsFormField then
      FItems.Add(AAnnotations[I].FormField);
end;

destructor TPdfFormFieldList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TPdfFormFieldList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TPdfFormFieldList.GetItem(Index: Integer): TPdfFormField;
begin
  Result := TObject(FItems[Index]) as TPdfFormField;
end;

procedure TPdfFormFieldList.DestroyingItem(Item: TPdfFormField);
begin
  if (Item <> nil) and (FItems <> nil) then
    FItems.Extract(Item);
end;


{ TPdfAnnotation }

constructor TPdfAnnotation.Create(APage: TPdfPage; AHandle: FPDF_ANNOTATION);
var
  Action: FPDF_ACTION;
begin
  inherited Create;
  FPage := APage;
  FHandle := AHandle;

  FSubType := FPDFAnnot_GetSubtype(FHandle);
  FLinkType := altUnsupported;
  case FSubType of
    FPDF_ANNOT_WIDGET,
    FPDF_ANNOT_XFAWIDGET:
      FFormField := TPdfFormField.Create(Self);

    FPDF_ANNOT_LINK:
      begin
        Action := GetPdfLinkAction;
        if Action <> nil then
          FLinkType := TPdfAnnotationLinkType(FPDFAction_GetType(Action))
        else
        begin
          // If we have a Dest-Link then we treat it like a Goto Action-Link (see GetLinkGotoDestination)
          FLinkDest := FPDFLink_GetDest(FPage.FDocument.Handle, FPDFAnnot_GetLink(Handle));
          if FLinkDest <> nil then
            FLinkType := altGoto;
        end;
      end;
  end;
end;

destructor TPdfAnnotation.Destroy;
begin
  FreeAndNil(FFormField);
  if FHandle <> nil then
  begin
    FPDFPage_CloseAnnot(FHandle);
    FHandle := nil;
  end;
  if FPage.FAnnotations <> nil then
    FPage.FAnnotations.DestroyingItem(Self);
  inherited Destroy;
end;

function TPdfAnnotation.GetPdfLinkAction: FPDF_ACTION;
var
  Link: FPDF_LINK;
begin
  Result := nil;
  if FSubType = FPDF_ANNOT_LINK then
  begin
    Link := FPDFAnnot_GetLink(Handle);
    if Link <> nil then
      Result := FPDFLink_GetAction(Link);
  end;
end;

function TPdfAnnotation.IsLink: Boolean;
begin
  Result := FSubType = FPDF_ANNOT_LINK;
end;

function TPdfAnnotation.IsFormField: Boolean;
begin
  Result := FFormField <> nil;
end;

function TPdfAnnotation.GetFormField: TPdfFormField;
begin
  if FFormField = nil then
    raise EPdfException.CreateRes(@RsPdfAnnotationNotAFormFieldError);
  Result := FFormField;
end;

function TPdfAnnotation.GetAnnotationRect: TPdfRect;
var
  R: FS_RECTF;
begin
  if FPDFAnnot_GetRect(Handle, @R) <> 0 then
    Result := TPdfRect.New(R.left, R.top, R.right, R.bottom)
  else
    Result := TPdfRect.Empty;
end;

function TPdfAnnotation.GetLinkUri: string;
begin
  if LinkType = altURI then
    Result := FPage.GetPdfActionUriPath(GetPdfLinkAction)
  else
    Result := '';
end;

function TPdfAnnotation.GetLinkFileName: string;
begin
  if LinkType in [altRemoteGoto, altLaunch, altEmbeddedGoto] then // PDFium documentation is missing the PDFACTION_EMBEDDEDGOTO part.
    Result := FPage.GetPdfActionFilePath(GetPdfLinkAction)
  else
    Result := '';
end;

function TPdfAnnotation.GetLinkGotoDestination(var LinkGotoDestination: TPdfLinkGotoDestination; ARemoteDocument: TPdfDocument): Boolean;
var
  Action: FPDF_ACTION;
  Dest: FPDF_DEST;
  Doc: TPdfDocument;
  PageIndex: Integer;
  HasXVal, HasYVal, HasZoomVal: FPDF_BOOL;
  X, Y, Zoom: FS_FLOAT;
  ViewKind: TPdfLinkGotoDestinationViewKind;
  NumViewParams: LongWord;
  ViewParams: TPdfFloatArray;
begin
  Result := False;

  Action := GetPdfLinkAction;
  if ((Action <> nil) or (FLinkDest <> nil)) and (LinkType in [altGoto, altRemoteGoto, altEmbeddedGoto]) then
  begin
    Doc := FPage.FDocument;
    if LinkType = altRemoteGoto then
    begin
      // For RemoteGoto the FPDFAction_GetDest function must be called with the remote document
      if ARemoteDocument <> nil then
        raise EPdfException.CreateRes(@RsPdfAnnotationLinkRemoteGotoRequiresRemoteDocument);
      ARemoteDocument.CheckActive;

      Doc := ARemoteDocument;
    end;

    // If we have a Dest-Link instead of a Goto Action-Link we treat it as if it was a Goto Action-Link
    if FLinkDest <> nil then
      Dest := FLinkDest
    else
      Dest := FPDFAction_GetDest(Doc.Handle, Action);

    // Extract the information
    if Dest <> nil then
    begin
      PageIndex := FPDFDest_GetDestPageIndex(Doc.Handle, Dest);
      if PageIndex <> -1 then
      begin
        if FPDFDest_GetLocationInPage(Dest, HasXVal, HasYVal, HasZoomVal, X, Y, Zoom) <> 0 then
        begin
          SetLength(ViewParams, 4); // max. 4 params
          NumViewParams := 4;
          ViewKind := TPdfLinkGotoDestinationViewKind(FPDFDest_GetView(Dest, @NumViewParams, @ViewParams[0]));
          if NumViewParams > 4 then // range check
            NumViewParams := 4;
          SetLength(ViewParams, NumViewParams);

          LinkGotoDestination := TPdfLinkGotoDestination.Create(
            PageIndex,
            HasXVal <> 0, HasYVal <> 0, HasZoomVal <> 0,
            X, Y, Zoom,
            ViewKind, ViewParams
          );
          Result := True;
        end;
      end;
    end;
  end;
end;

{ TPdfFormField }

constructor TPdfFormField.Create(AAnnotation: TPdfAnnotation);
begin
  inherited Create;
  FAnnotation := AAnnotation;
  FPage := FAnnotation.FPage;
  FHandle := FAnnotation.Handle;
end;

destructor TPdfFormField.Destroy;
begin
  FAnnotation.FFormField := nil;
  FAnnotation.FPage.Annotations.DestroyingFormField(Self);
  inherited Destroy;
end;

function TPdfFormField.IsXFAFormField: Boolean;
begin
  Result := IS_XFA_FORMFIELD(FPDFAnnot_GetFormFieldType(FPage.FDocument.FormHandle, Handle));
end;

function TPdfFormField.GetReadOnly: Boolean;
begin
  Result := fffReadOnly in Flags;
end;

function TPdfFormField.GetFlags: TPdfFormFieldFlags;
var
  FormFlags: Integer;
begin
  FormFlags := FPDFAnnot_GetFormFieldFlags(FPage.FDocument.FormHandle, Handle);

  Result := [];
  if FormFlags <> FPDF_FORMFLAG_NONE then
  begin
    if FormFlags and FPDF_FORMFLAG_READONLY <> 0 then
      Include(Result, fffReadOnly);
    if FormFlags and FPDF_FORMFLAG_REQUIRED <> 0 then
      Include(Result, fffRequired);
    if FormFlags and FPDF_FORMFLAG_NOEXPORT <> 0 then
      Include(Result, fffNoExport);

    if FormFlags and FPDF_FORMFLAG_TEXT_MULTILINE <> 0 then
      Include(Result, fffTextMultiLine);
    if FormFlags and FPDF_FORMFLAG_TEXT_PASSWORD <> 0 then
      Include(Result, fffTextPassword);

    if FormFlags and FPDF_FORMFLAG_CHOICE_COMBO <> 0 then
      Include(Result, fffChoiceCombo);
    if FormFlags and FPDF_FORMFLAG_CHOICE_EDIT <> 0 then
      Include(Result, fffChoiceEdit);
    if FormFlags and FPDF_FORMFLAG_CHOICE_MULTI_SELECT <> 0 then
      Include(Result, fffChoiceMultiSelect);
  end;
end;

function TPdfFormField.GetName: string;
var
  Len: Integer;
begin
  Len := FPDFAnnot_GetFormFieldName(FPage.FDocument.FormHandle, Handle, nil, 0) div SizeOf(WideChar) - 1;
  if Len > 0 then
  begin
    SetLength(Result, Len);
    FPDFAnnot_GetFormFieldName(FPage.FDocument.FormHandle, Handle, PWideChar(Result), (Len + 1) * SizeOf(WideChar));
  end
  else
    Result := '';
end;

function TPdfFormField.GetAlternateName: string;
var
  Len: Integer;
begin
  Len := FPDFAnnot_GetFormFieldAlternateName(FPage.FDocument.FormHandle, Handle, nil, 0) div SizeOf(WideChar) - 1;
  if Len > 0 then
  begin
    SetLength(Result, Len);
    FPDFAnnot_GetFormFieldAlternateName(FPage.FDocument.FormHandle, Handle, PWideChar(Result), (Len + 1) * SizeOf(WideChar));
  end
  else
    Result := '';
end;

function TPdfFormField.GetFieldType: TPdfFormFieldType;
begin
  Result := TPdfFormFieldType(FPDFAnnot_GetFormFieldType(FPage.FDocument.FormHandle, Handle));
  if (Result < Low(TPdfFormFieldType)) or (Result > High(TPdfFormFieldType)) then
    Result := fftUnknown;
end;

function TPdfFormField.GetValue: string;
var
  Len: Integer;
begin
  Len := FPDFAnnot_GetFormFieldValue(FPage.FDocument.FormHandle, Handle, nil, 0) div SizeOf(WideChar) - 1;
  if Len > 0 then
  begin
    SetLength(Result, Len);
    FPDFAnnot_GetFormFieldValue(FPage.FDocument.FormHandle, Handle, PWideChar(Result), (Len + 1) * SizeOf(WideChar));
  end
  else
    Result := '';
end;

function TPdfFormField.GetExportValue: string;
var
  Len: Integer;
begin
  Len := FPDFAnnot_GetFormFieldExportValue(FPage.FDocument.FormHandle, Handle, nil, 0) div SizeOf(WideChar) - 1;
  if Len > 0 then
  begin
    SetLength(Result, Len);
    FPDFAnnot_GetFormFieldExportValue(FPage.FDocument.FormHandle, Handle, PWideChar(Result), (Len + 1) * SizeOf(WideChar));
  end
  else
    Result := '';
end;

function TPdfFormField.GetOptionCount: Integer;
begin
  Result := FPDFAnnot_GetOptionCount(FPage.FDocument.FormHandle, Handle);
  if Result < 0 then // annotation types that don't support options will return -1
    Result := 0;
end;

function TPdfFormField.GetOptionLabel(Index: Integer): string;
var
  Len: Integer;
begin
  Len := FPDFAnnot_GetOptionLabel(FPage.FDocument.FormHandle, Handle, Index, nil, 0) div SizeOf(WideChar) - 1;
  if Len > 0 then
  begin
    SetLength(Result, Len);
    FPDFAnnot_GetOptionLabel(FPage.FDocument.FormHandle, Handle, Index, PWideChar(Result), (Len + 1) * SizeOf(WideChar));
  end
  else
    Result := '';
end;

function TPdfFormField.IsOptionSelected(OptionIndex: Integer): Boolean;
begin
  Result := FPDFAnnot_IsOptionSelected(FPage.FDocument.FormHandle, Handle, OptionIndex) <> 0;
end;

function TPdfFormField.GetChecked: Boolean;
begin
  Result := FPDFAnnot_IsChecked(FPage.FDocument.FormHandle, Handle) <> 0;
end;

function TPdfFormField.GetControlCount: Integer;
begin
  Result := FPDFAnnot_GetFormControlCount(FPage.FDocument.FormHandle, Handle);
end;

function TPdfFormField.GetControlIndex: Integer;
begin
  Result := FPDFAnnot_GetFormControlIndex(FPage.FDocument.FormHandle, Handle);
end;

function TPdfFormField.BeginEditFormField: FPDF_ANNOTATION;
var
  AnnotPageIndex: Integer;
begin
  FPage.FDocument.CheckActive;

  // Obtain the currently focused form field/annotation so that we can restore the focus after
  // editing our form field.
  if FORM_GetFocusedAnnot(FPage.FDocument.FormHandle, AnnotPageIndex, Result) = 0 then
    Result := nil;
end;

procedure TPdfFormField.EndEditFormField(LastFocusedAnnot: FPDF_ANNOTATION);
begin
  // Restore the focus to the form field/annotation that had the focus before changing our form field.
  // If no previous form field was focused, kill the focus.
  if LastFocusedAnnot <> nil then
  begin
    if FORM_SetFocusedAnnot(FPage.FDocument.FormHandle, Handle) = 0 then
      FORM_ForceToKillFocus(FPage.FDocument.FormHandle);
    FPDFPage_CloseAnnot(LastFocusedAnnot);
  end
  else
    FORM_ForceToKillFocus(FPage.FDocument.FormHandle);
end;

procedure TPdfFormField.SetValue(const Value: string);
var
  LastFocusedAnnot: FPDF_ANNOTATION;
begin
  FPage.FDocument.CheckActive;

  if not ReadOnly then
  begin
    LastFocusedAnnot := BeginEditFormField();
    try
      if FORM_SetFocusedAnnot(FPage.FDocument.FormHandle, Handle) <> 0 then
      begin
        FORM_SelectAllText(FPage.FDocument.FormHandle, FPage.Handle);
        FORM_ReplaceSelection(FPage.FDocument.FormHandle, FPage.Handle, PWideChar(Value));
      end;
    finally
      EndEditFormField(LastFocusedAnnot);
    end;
  end;
end;

function TPdfFormField.SelectComboBoxOption(OptionIndex: Integer): Boolean;
begin
  Result := SelectListBoxOption(OptionIndex, True);
end;

function TPdfFormField.SelectListBoxOption(OptionIndex: Integer; Selected: Boolean): Boolean;
var
  LastFocusedAnnot: FPDF_ANNOTATION;
begin
  FPage.FDocument.CheckActive;

  Result := False;
  if not ReadOnly then
  begin
    LastFocusedAnnot := BeginEditFormField();
    try
      if FORM_SetFocusedAnnot(FPage.FDocument.FormHandle, Handle) <> 0 then
        Result := FORM_SetIndexSelected(FPage.FDocument.FormHandle, FPage.Handle, OptionIndex, Ord(Selected <> False)) <> 0;
    finally
      EndEditFormField(LastFocusedAnnot);
    end;
  end;
end;

procedure TPdfFormField.SetChecked(const Value: Boolean);
var
  LastFocusedAnnot: FPDF_ANNOTATION;
begin
  FPage.FDocument.CheckActive;

  if not ReadOnly and (FieldType in [fftCheckBox, fftRadioButton, fftXFACheckBox]) then
  begin
    if Value <> Checked then
    begin
      LastFocusedAnnot := BeginEditFormField();
      try
        if FORM_SetFocusedAnnot(FPage.FDocument.FormHandle, Handle) <> 0 then
        begin
          // Toggle the RadioButton/Checkbox by emulating "pressing the space bar".
          FORM_OnKeyDown(FPage.FDocument.FormHandle, FPage.Handle, Ord(' '), 0);
          FORM_OnChar(FPage.FDocument.FormHandle, FPage.Handle, Ord(' '), 0);
          FORM_OnKeyUp(FPage.FDocument.FormHandle, FPage.Handle, Ord(' '), 0);
        end;
      finally
        EndEditFormField(LastFocusedAnnot);
      end;
    end;
  end;
end;


{ TPdfLinkGotoDestination }

constructor TPdfLinkGotoDestination.Create(APageIndex: Integer; AXValid, AYValid, AZoomValid: Boolean;
  AX, AY, AZoom: Single; AViewKind: TPdfLinkGotoDestinationViewKind; const AViewParams: TPdfFloatArray);
begin
  inherited Create;
  FPageIndex := APageIndex;

  FXValid := AXValid;
  FYValid := AYValid;
  FZoomValid := AZoomValid;

  FX := AX;
  FY := AY;
  FZoom := AZoom;

  FViewKind := AViewKind;
  FViewParams := AViewParams;
end;


{ TPdfLinkInfo }

constructor TPdfLinkInfo.Create(ALinkAnnotation: TPdfAnnotation; const AWebLinkUrl: string);
begin
  inherited Create;
  FLinkAnnotation := ALinkAnnotation;
  FWebLinkUrl := AWebLinkUrl;
end;

function TPdfLinkInfo.IsAnnontation: Boolean;
begin
  Result := FLinkAnnotation <> nil;
end;

function TPdfLinkInfo.IsWebLink: Boolean;
begin
  Result := FLinkAnnotation = nil;
end;

function TPdfLinkInfo.GetLinkFileName: string;
begin
  if FLinkAnnotation <> nil then
    Result := FLinkAnnotation.LinkFileName;
end;

function TPdfLinkInfo.GetLinkType: TPdfAnnotationLinkType;
begin
  if FLinkAnnotation <> nil then
    Result := FLinkAnnotation.LinkType
  else if FWebLinkUrl <> '' then
    Result := altURI
  else
    Result := altUnsupported;
end;

function TPdfLinkInfo.GetLinkUri: string;
begin
  if FLinkAnnotation <> nil then
    Result := FLinkAnnotation.LinkUri
  else
    Result := FWebLinkUrl;
end;

function TPdfLinkInfo.GetLinkGotoDestination(var LinkGotoDestination: TPdfLinkGotoDestination;
  ARemoteDocument: TPdfDocument): Boolean;
begin
  if FLinkAnnotation <> nil then
    Result := FLinkAnnotation.GetLinkGotoDestination(LinkGotoDestination, ARemoteDocument)
  else
    Result := False;
end;

{ TPdfPageWebLinksInfo }

constructor TPdfPageWebLinksInfo.Create(APage: TPdfPage);
begin
  inherited Create;
  FPage := APage;
  GetPageWebLinks;
end;

procedure TPdfPageWebLinksInfo.GetPageWebLinks;
var
  LinkIndex, LinkCount: Integer;
  RectIndex, RectCount: Integer;
begin
  if FPage <> nil then
  begin
    LinkCount := FPage.GetWebLinkCount;
    SetLength(FWebLinksRects, LinkCount);
    for LinkIndex := 0 to LinkCount - 1 do
    begin
      RectCount := FPage.GetWebLinkRectCount(LinkIndex);
      SetLength(FWebLinksRects[LinkIndex], RectCount);
      for RectIndex := 0 to RectCount - 1 do
        FWebLinksRects[LinkIndex][RectIndex] := FPage.GetWebLinkRect(LinkIndex, RectIndex);
    end;
  end;
end;

function TPdfPageWebLinksInfo.GetWebLinkIndex(X, Y: Double): Integer;
var
  RectIndex: Integer;
  Pt: TPdfPoint;
begin
  if FPage <> nil then
  begin
    Pt.X := X;
    Pt.Y := Y;
    for Result := 0 to Length(FWebLinksRects) - 1 do
      for RectIndex := 0 to Length(FWebLinksRects[Result]) - 1 do
        if FWebLinksRects[Result][RectIndex].PtIn(Pt) then
          Exit;
  end;
  Result := -1;
end;

function TPdfPageWebLinksInfo.GetCount: Integer;
begin
  Result := Length(FWebLinksRects);
end;

function TPdfPageWebLinksInfo.GetRect(Index: Integer): TPdfRectArray;
begin
  Result := FWebLinksRects[Index];
end;

function TPdfPageWebLinksInfo.GetURL(Index: Integer): string;
begin
  Result := FPage.GetWebLinkURL(Index);
end;

function TPdfPageWebLinksInfo.IsWebLinkAt(X, Y: Double): Boolean;
begin
  Result := GetWebLinkIndex(X, Y) <> -1;
end;

function TPdfPageWebLinksInfo.IsWebLinkAt(X, Y: Double; var Url: string): Boolean;
var
  Index: Integer;
begin
  Index := GetWebLinkIndex(X, Y);
  Result := Index <> -1;
  if Result then
    Url := FPage.GetWebLinkURL(Index)
  else
    Url := '';
end;


{ TPdfDocumentPrinter }

constructor TPdfDocumentPrinter.Create;
begin
  inherited Create;
  FFitPageToPrintArea := True;
end;

function TPdfDocumentPrinter.IsPortraitOrientation(AWidth, AHeight: Integer): Boolean;
begin
  Result := AHeight > AWidth;
end;

procedure TPdfDocumentPrinter.GetPrinterBounds;
begin
  FPaperSize.cx := GetDeviceCaps(FPrinterDC, PHYSICALWIDTH);
  FPaperSize.cy := GetDeviceCaps(FPrinterDC, PHYSICALHEIGHT);

  FPrintArea.cx := GetDeviceCaps(FPrinterDC, HORZRES);
  FPrintArea.cy := GetDeviceCaps(FPrinterDC, VERTRES);

  FMargins.X := GetDeviceCaps(FPrinterDC, PHYSICALOFFSETX);
  FMargins.Y := GetDeviceCaps(FPrinterDC, PHYSICALOFFSETY);
end;

function TPdfDocumentPrinter.BeginPrint(const AJobTitle: string): Boolean;
begin
  Inc(FBeginPrintCounter);
  if FBeginPrintCounter = 1 then
  begin
    Result := PrinterStartDoc(AJobTitle);
    if Result then
    begin
      FPrinterDC := GetPrinterDC;

      GetPrinterBounds;
      FPrintPortraitOrientation := IsPortraitOrientation(FPaperSize.cx, FPaperSize.cy);
    end
    else
    begin
      FPrinterDC := 0;
      Dec(FBeginPrintCounter);
    end;
  end
  else
    Result := True;
end;

procedure TPdfDocumentPrinter.EndPrint;
begin
  Dec(FBeginPrintCounter);
  if FBeginPrintCounter = 0 then
  begin
    if FPrinterDC <> 0 then
    begin
      FPrinterDC := 0;
      PrinterEndDoc;
    end;
  end;
end;

function TPdfDocumentPrinter.Print(ADocument: TPdfDocument): Boolean;
begin
  if ADocument <> nil then
    Result := Print(ADocument, 0, ADocument.PageCount - 1)
  else
    Result := False;
end;

function TPdfDocumentPrinter.Print(ADocument: TPdfDocument; AFromPageIndex, AToPageIndex: Integer): Boolean;
var
  PageIndex: Integer;
  WasPageLoaded: Boolean;
  PdfPage: TPdfPage;
  PagePortraitOrientation: Boolean;
  X, Y, W, H: Integer;
  PrintedPageNum, PrintPageCount: Integer;
begin
  Result := False;
  if ADocument = nil then
    Exit;

  if AFromPageIndex < 0 then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['FromPage', AFromPageIndex]);
  if (AToPageIndex < AFromPageIndex) or (AToPageIndex >= ADocument.PageCount) then
    raise EPdfArgumentOutOfRange.CreateResFmt(@RsArgumentsOutOfRange, ['ToPage', AToPageIndex]);

  PrintedPageNum := 0;
  PrintPageCount := AToPageIndex - AFromPageIndex + 1;

  if BeginPrint then
  begin
    try
      if ADocument.FForm <> nil then
        FORM_DoDocumentAAction(ADocument.FForm, FPDFDOC_AACTION_WP); // BeforePrint

      for PageIndex := AFromPageIndex to AToPageIndex do
      begin
        PdfPage := nil;
        WasPageLoaded := ADocument.IsPageLoaded(PageIndex);
        try
          PdfPage := ADocument.Pages[PageIndex];
          PagePortraitOrientation := IsPortraitOrientation(Trunc(PdfPage.Width), Trunc(PdfPage.Height));

          if FitPageToPrintArea then
          begin
            X := 0;
            Y := 0;
            W := FPrintArea.cx;
            H := FPrintArea.cy;
          end
          else
          begin
            X := -FMargins.X;
            Y := -FMargins.Y;
            W := FPaperSize.cx;
            H := FPaperSize.cy;
          end;

          if PagePortraitOrientation <> FPrintPortraitOrientation then
          begin
            SwapInts(X, Y);
            SwapInts(W, H);
          end;

          // Print page
          PrinterStartPage;
          try
            if (W > 0) and (H > 0) then
              InternPrintPage(PdfPage, X, Y, W, H);
          finally
            PrinterEndPage;
          end;
          Inc(PrintedPageNum);
          if Assigned(OnPrintStatus) then
            OnPrintStatus(Self, PrintedPageNum, PrintPageCount);
        finally
          if not WasPageLoaded and (PdfPage <> nil) then
            PdfPage.Close; // release memory
        end;
        if ADocument.FForm <> nil then
          FORM_DoDocumentAAction(ADocument.FForm, FPDFDOC_AACTION_DP); // AfterPrint
      end;
    finally
      EndPrint;
    end;
    Result := True;
  end;
end;

procedure TPdfDocumentPrinter.InternPrintPage(APage: TPdfPage; X, Y, Width, Height: Double);

  function RoundToInt(Value: Double): Integer;
  var
    F: Double;
  begin
    Result := Trunc(Value);
    F := Frac(Value);
    if F < 0 then
    begin
      if F <= -0.5 then
        Result := Result - 1;
    end
    else if F >= 0.5 then
      Result := Result + 1;
  end;

var
  PageWidth, PageHeight: Double;
  PageScale, PrintScale: Double;
  ScaledWidth, ScaledHeight: Double;
begin
  PageWidth := APage.Width;
  PageHeight := APage.Height;

  PageScale := PageHeight / PageWidth;
  PrintScale := Height / Width;

  ScaledWidth := Width;
  ScaledHeight := Height;
  if PageScale > PrintScale then
    ScaledWidth := Width * (PrintScale / PageScale)
  else
    ScaledHeight := Height * (PageScale / PrintScale);

  X := X + (Width - ScaledWidth) / 2;
  Y := Y + (Height - ScaledHeight) / 2;

  APage.Draw(
    FPrinterDC,
    RoundToInt(X), RoundToInt(Y), RoundToInt(ScaledWidth), RoundToInt(ScaledHeight),
    prNormal, [proPrinting, proAnnotations]
  );
end;

initialization
  {$IFDEF FPC}
  InitCriticalSection(PDFiumInitCritSect);
  InitCriticalSection(FFITimersCritSect);
  {$ELSE}
  InitializeCriticalSectionAndSpinCount(PDFiumInitCritSect, 4000);
  InitializeCriticalSectionAndSpinCount(FFITimersCritSect, 4000);
  {$ENDIF FPC}

finalization
  {$IFDEF FPC}
  DoneCriticalSection(FFITimersCritSect);
  DoneCriticalSection(PDFiumInitCritSect);
  {$ELSE}
  DeleteCriticalSection(FFITimersCritSect);
  DeleteCriticalSection(PDFiumInitCritSect);
  {$ENDIF FPC}

end.
