{$IFDEF FPC}
  {$MODE DelphiUnicode}
{$ENDIF FPC}

{$A8,B-,E-,F-,G+,H+,I+,J-,K-,M-,N-,P+,Q-,R-,S-,T-,U-,V+,X+,Z1}
{$STRINGCHECKS OFF}

unit PdfiumCtrl;

// Show invalidated paint regions. Don't enable this if you aren't trying to optimize the repainting
{.$DEFINE REPAINTTEST}

{$IFDEF FPC}
  {$DEFINE USE_PRINTCLIENT_WORKAROUND}
{$ELSE}
  {$IF CompilerVersion <= 20.0} // 2009 and older
    {$DEFINE USE_PRINTCLIENT_WORKAROUND}
  {$IFEND}
  {$IF CompilerVersion >= 21.0} // 2010+
    {$DEFINE VCL_HAS_TOUCH}
  {$IFEND}
{$ENDIF FPC}

interface

uses
  {$IFDEF FPC}
  LCLType, PrintersDlgs, Win32Extra,
  {$ENDIF FPC}
  Windows, Messages, ShellAPI, Types, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, PdfiumCore;

type
  TPdfControlLinkOptionType = (
    loAutoGoto,                        // Jumps in the document are allowed and automatically handled
    loAutoRemoteGotoReplaceDocument,   // Jumps to a remote document are allowed and automatically handled by replacing the loaded document
    loAutoOpenURI,                     // Jumps to URI are allowed and automatically handled by using ShellExecuteEx. Disables OnWebLinkClick if loTreatWebLinkAsUriAnnotationLink is set
    loAutoLaunch,                      // Allow executing/opening a program/file automatically by using ShellExecuteEx
    loAutoEmbeddedGotoReplaceDocument, // Jumps to an attached PDF document are allowed and automatically handled by replacing the loaded document

    loTreatWebLinkAsUriAnnotationLink, // OnAnnotationLinkClick also handles WebLinks
    loAlwaysDetectWebAndUriLink        // If if OnWebLinkClick and OnAnnotationLinkClick aren't assigned, URI and WebLinks are detected
  );
  TPdfControlLinkOptions = set of TPdfControlLinkOptionType;

const
  cPdfControlDefaultDrawOptions = [proAnnotations];
  cPdfControlDefaultLinkOptions = [loAutoGoto, loTreatWebLinkAsUriAnnotationLink, loAlwaysDetectWebAndUriLink];
  cPdfControlAllAutoLinkOptions = [loAutoGoto, loAutoRemoteGotoReplaceDocument, loAutoOpenURI,
                                   loAutoLaunch, loAutoEmbeddedGotoReplaceDocument];

type
  TPdfControlScaleMode = (
    smFitAuto,
    smFitWidth,
    smFitHeight,
    smZoom
  );

  TPdfControlWebLinkClickEvent = procedure(Sender: TObject; Url: string) of object;
  TPdfControlAnnotationLinkClickEvent = procedure(Sender: TObject; LinkInfo: TPdfLinkInfo; var Handled: Boolean) of object;
  TPdfControlRectArray = array of TRect;
  TPdfControlPdfRectArray = array of TPdfRect;

  TPdfControl = class(TCustomControl)
  private
    FDocument: TPdfDocument;
    FPageIndex: Integer;
    FRenderedPageIndex: Integer;
    FPageBitmap: HBITMAP;
    FDrawX: Integer;
    FDrawY: Integer;
    FDrawWidth: Integer;
    FDrawHeight: Integer;
    FRotation: TPdfPageRotation;
    {$IFDEF USE_PRINTCLIENT_WORKAROUND}
    FPrintClient: Boolean;
    {$ENDIF USE_PRINTCLIENT_WORKAROUND}
    FMousePressed: Boolean;
    FSelectionActive: Boolean;
    FAllowUserTextSelection: Boolean;
    FAllowUserPageChange: Boolean;
    FAllowFormEvents: Boolean;
    FBufferedPageDraw: Boolean;
    FSmoothScroll: Boolean;
    FScrollTimerActive: Boolean;
    FScrollTimer: Boolean;
    FChangePageOnMouseScrolling: Boolean;
    FSelStartCharIndex: Integer;
    FSelStopCharIndex: Integer;
    FMouseDownPt: TPoint;
    FCheckForTrippleClick: Boolean;
    FWebLinkInfo: TPdfPageWebLinksInfo;
    FDrawOptions: TPdfPageRenderOptions;
    FScaleMode: TPdfControlScaleMode;
    FZoomPercentage: Integer;
    FPageColor: TColor;
    FScrollMousePos: TPoint;
    FLinkOptions: TPdfControlLinkOptions;
    FHighlightTextRects: TPdfControlPdfRectArray;
    FHighlightText: string;
    FHighlightMatchCase: Boolean;
    FHighlightMatchWholeWord: Boolean;
    FFormOutputSelectedRects: TPdfRectArray;
    FFormFieldFocused: Boolean;
    FPageShadowSize: Integer;
    FPageShadowColor: TColor;
    FPageShadowPadding: Integer;
    FPageBorderColor: TColor;

    FOnWebLinkClick: TPdfControlWebLinkClickEvent;
    FOnAnnotationLinkClick: TPdfControlAnnotationLinkClickEvent;
    FOnPageChange: TNotifyEvent;
    FOnPaint: TNotifyEvent;
    FOnPrintDocument: TNotifyEvent;

    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMColorchanged(var Message: TMessage); message CM_COLORCHANGED;
    {$IFDEF USE_PRINTCLIENT_WORKAROUND}
    procedure WMPrintClient(var Message: TWMPrintClient); message WM_PRINTCLIENT;
    {$ENDIF USE_PRINTCLIENT_WORKAROUND}
    procedure CMMouseleave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure GetPageWebLinks;
    function GetCurrentPage: TPdfPage;
    function GetPageCount: Integer;
    procedure SetPageIndex(Value: Integer);
    function InternSetPageIndex(Value: Integer; ScrollTransition, InverseScrollTransition: Boolean): Boolean;
    procedure SetRotation(const Value: TPdfPageRotation);
    function SetSelStopCharIndex(X, Y: Integer): Boolean;
    function GetSelText: string;
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    procedure SetSelection(Active: Boolean; StartIndex, StopIndex: Integer);
    procedure SetScaleMode(const Value: TPdfControlScaleMode);
    procedure SetPageBorderColor(const Value: TColor);
    procedure SetPageShadowColor(const Value: TColor);
    procedure SetPageShadowPadding(const Value: Integer);
    procedure SetPageShadowSize(const Value: Integer);
    procedure AdjustDrawPos;
    procedure UpdatePageDrawInfo;
    procedure SetPageColor(const Value: TColor);
    procedure SetDrawOptions(const Value: TPdfPageRenderOptions);
    procedure InvalidateRectDiffs(const OldRects, NewRects: TPdfControlRectArray);
    procedure InvalidatePdfRectDiffs(const OldRects, NewRects: TPdfControlPdfRectArray);
    procedure StopScrollTimer;
    procedure DocumentLoaded;
    procedure DrawSelection(DC: HDC; Page: TPdfPage);
    procedure DrawHighlightText(DC: HDC; Page: TPdfPage);
    procedure DrawBorderAndShadow(DC: HDC);
    function InternPageToDevice(Page: TPdfPage; PageRect: TPdfRect): TRect;
    procedure SetZoomPercentage(Value: Integer);
    procedure DrawPage(DC: HDC; Page: TPdfPage; DirectDrawPage: Boolean);
    procedure CalcHighlightTextRects;
    procedure InitDocument;
    function ShellOpenFileName(const FileName: string; Launch: Boolean): Boolean;

    procedure FormInvalidate(Document: TPdfDocument; Page: TPdfPage; const PageRect: TPdfRect);
    procedure FormOutputSelectedRect(Document: TPdfDocument; Page: TPdfPage; const PageRect: TPdfRect);
    procedure FormGetCurrentPage(Document: TPdfDocument; var Page: TPdfPage);
    procedure FormFieldFocus(Document: TPdfDocument; Value: PWideChar; ValueLen: Integer; FieldFocused: Boolean);
    procedure ExecuteNamedAction(Document: TPdfDocument; NamedAction: TPdfNamedActionType);

    procedure DrawAlphaSelection(DC: HDC; Page: TPdfPage; const ARects: TPdfRectArray);
    procedure DrawFormOutputSelectedRects(DC: HDC; Page: TPdfPage);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;

    function LinkHandlingNeeded: Boolean;
    function IsClickableLinkAt(X, Y: Integer): Boolean;
    procedure WebLinkClick(const Url: string); virtual;
    procedure AnnotationLinkClick(LinkInfo: TPdfLinkInfo); virtual;
    procedure PageChange; virtual;
    procedure PageContentChanged(Closing: Boolean);
    procedure PageLayoutChanged;
    function IsPageValid: Boolean;
    function GetSelectionRects: TPdfControlRectArray;
    procedure DestroyWnd; override;

    property DrawX: Integer read FDrawX;
    property DrawY: Integer read FDrawY;
    property DrawWidth: Integer read FDrawWidth;
    property DrawHeight: Integer read FDrawHeight;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { InvalidatePage forces the page to be rendered again and invalidates the control. }
    procedure InvalidatePage;
    { PrintDocument uses OnPrintDocument to print. If OnPrintDocument is not assigned it does nothing. }
    procedure PrintDocument;

    procedure OpenWithDocument(Document: TPdfDocument); // takes ownership
    procedure LoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; Size: LongWord; Param: Pointer; const Password: UTF8String = '');
    procedure LoadFromActiveStream(Stream: TStream; const Password: UTF8String = ''); // Stream must not be released until the document is closed
    procedure LoadFromActiveBuffer(Buffer: Pointer; Size: Int64; const Password: UTF8String = ''); // Buffer must not be released until the document is closed
    procedure LoadFromBytes(const Bytes: TBytes; const Password: UTF8String = ''); overload; // The content of the Bytes array must not be changed until the document is closed
    procedure LoadFromBytes(const Bytes: TBytes; Index: Integer; Count: Integer; const Password: UTF8String = ''); overload; // The content of the Bytes array must not be changed until the document is closed
    procedure LoadFromStream(Stream: TStream; const Password: UTF8String = '');
    procedure LoadFromFile(const FileName: string; const Password: UTF8String = ''; LoadOption: TPdfDocumentLoadOption = dloDefault);
    procedure Close;

    function DeviceToPage(DeviceX, DeviceY: Integer): TPdfPoint; overload;
    function DeviceToPage(DeviceRect: TRect): TPdfRect; overload;
    function PageToDevice(PageX, PageY: Double): TPoint; overload;
    function PageToDevice(PageRect: TPdfRect): TRect; overload;
    function GetPageRect: TRect;

    procedure CopyFormTextToClipboard;
    procedure CutFormTextToClipboard;
    procedure PasteFormTextFromClipboard;
    procedure SelectAllFormText;

    procedure CopyToClipboard;
    procedure ClearSelection;
    procedure SelectAll;
    procedure SelectText(CharIndex, Count: Integer);
    function SelectWord(CharIndex: Integer): Boolean; // includes symbols like Chrome
    function SelectLine(CharIndex: Integer): Boolean;

    function GetTextInRect(const R: TRect): string;
    procedure HightlightText(const SearchText: string; MatchCase, MatchWholeWord: Boolean);
    procedure ClearHighlightText;

    function IsWebLinkAt(X, Y: Integer): Boolean; overload;
    function IsWebLinkAt(X, Y: Integer; var Url: string): Boolean; overload;
    function IsUriAnnotationLinkAt(X, Y: Integer): Boolean;
    function IsAnnotationLinkAt(X, Y: Integer): Boolean;
    function GetAnnotationLinkAt(X, Y: Integer): TPdfAnnotation;

    function GotoNextPage(ScrollTransition: Boolean = False): Boolean;
    function GotoPrevPage(ScrollTransition: Boolean = False): Boolean;
    function ScrollContent(XOffset, YOffset: Integer; Smooth: Boolean = False): Boolean; virtual;
    function ScrollContentTo(X, Y: Integer; Smooth: Boolean = False): Boolean;
    function GotoDestination(const LinkGotoDestination: TPdfLinkGotoDestination): Boolean;

    property Document: TPdfDocument read FDocument;
    property CurrentPage: TPdfPage read GetCurrentPage;

    property PageCount: Integer read GetPageCount;
    property PageIndex: Integer read FPageIndex write SetPageIndex;
    property SelStart: Integer read GetSelStart; // in CharIndex, not TextIndex (Length(SelText) may not be SelLength)
    property SelLength: Integer read GetSelLength; // in CharIndex, not TextIndex (Length(SelText) may not be SelLength)
    property SelText: string read GetSelText;

    property Canvas;
  published
    property ScaleMode: TPdfControlScaleMode read FScaleMode write SetScaleMode default smFitAuto;
    property ZoomPercentage: Integer read FZoomPercentage write SetZoomPercentage default 100;
    property PageColor: TColor read FPageColor write SetPageColor default clWhite;
    property Rotation: TPdfPageRotation read FRotation write SetRotation default prNormal;
    property BufferedPageDraw: Boolean read FBufferedPageDraw write FBufferedPageDraw default True;
    property AllowUserTextSelection: Boolean read FAllowUserTextSelection write FAllowUserTextSelection default True;
    property AllowUserPageChange: Boolean read FAllowUserPageChange write FAllowUserPageChange default True; // PgDn/PgUp
    property AllowFormEvents: Boolean read FAllowFormEvents write FAllowFormEvents default True;
    property DrawOptions: TPdfPageRenderOptions read FDrawOptions write SetDrawOptions default cPdfControlDefaultDrawOptions;
    property SmoothScroll: Boolean read FSmoothScroll write FSmoothScroll default False;
    property ScrollTimer: Boolean read FScrollTimer write FScrollTimer default True;
    property ChangePageOnMouseScrolling: Boolean read FChangePageOnMouseScrolling write FChangePageOnMouseScrolling default False;
    property LinkOptions: TPdfControlLinkOptions read FLinkOptions write FLinkOptions default cPdfControlDefaultLinkOptions;

    property PageBorderColor: TColor read FPageBorderColor write SetPageBorderColor default clNone;
    property PageShadowColor: TColor read FPageShadowColor write SetPageShadowColor default clNone;
    property PageShadowSize: Integer read FPageShadowSize write SetPageShadowSize default 4;
    property PageShadowPadding: Integer read FPageShadowPadding write SetPageShadowPadding default 44;

    { OnWebLinkClick is only called for WebLinks (URLs parsed from the document text). If OnAnnotationLinkClick is
      not assigned, OnWebLinkClick is also called URI link annontations for backward compatibility reasons. }
    property OnWebLinkClick: TPdfControlWebLinkClickEvent read FOnWebLinkClick write FOnWebLinkClick;
    { OnAnnotationLinkClick is called for all link annotation but not for WebLinks. }
    property OnAnnotationLinkClick: TPdfControlAnnotationLinkClickEvent read FOnAnnotationLinkClick write FOnAnnotationLinkClick;
    { OnPageChange is called if the current page is switched. }
    property OnPageChange: TNotifyEvent read FOnPageChange write FOnPageChange;
    { OnPrintDocument is called from PrintDocument }
    property OnPrintDocument: TNotifyEvent read FOnPrintDocument write FOnPrintDocument;

    property Align;
    property Anchors;
    property Color default clGray;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBackground default False;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    {$IFNDEF FPC}
    property OnMouseActivate;
    {$ENDIF ~FPC}
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnStartDock;
    property OnStartDrag;
    {$IFDEF VCL_HAS_TOUCH}
    property Touch;
    property OnGesture;
    {$ENDIF VCL_HAS_TOUCH}
  end;

  TPdfDocumentVclPrinter = class(TPdfDocumentPrinter)
  private
    FBeginDocCalled: Boolean;
    FPagePrinted: Boolean;
  protected
    function PrinterStartDoc(const AJobTitle: string): Boolean; override;
    procedure PrinterEndDoc; override;
    procedure PrinterStartPage; override;
    procedure PrinterEndPage; override;
    function GetPrinterDC: HDC; override;
  public
    { If AShowPrintDialog is false PrintDocument prints the document to the default printer.
      If AShowPrintDialog is true the print dialog is shown and the user can select the
      printer, page range and number of copies (if supported by the printer driver).
      Returns true if the page was send to the printer driver. }
    class function PrintDocument(ADocument: TPdfDocument; const AJobTitle: string; 
      AShowPrintDialog: Boolean = True; AllowPageRange: Boolean = True; 
      AParentWnd: HWND = 0): Boolean; static;
  end;

implementation

uses
  Math, Clipbrd, Character, Printers, StrUtils;

const
  cScrollTimerId = 1;
  cTrippleClickTimerId = 2;
  cScrollTimerInterval = 50;
  cDefaultScrollOffset = 25;

function IsWhitespace(Ch: Char): Boolean;
begin
  {$IFDEF FPC}
  Result := TCharacter.IsWhiteSpace(Ch);
  {$ELSE}
    {$IF CompilerVersion >= 25.0} // XE4
  Result := Ch.IsWhiteSpace;
    {$ELSE}
  Result := TCharacter.IsWhiteSpace(Ch);
    {$IFEND}
  {$ENDIF FPC}
end;

function VclAbortProc(Prn: HDC; Error: Integer): Bool; stdcall;
begin
  Application.ProcessMessages;
  Result := not Printer.Aborted;
end;

function FastVclAbortProc(Prn: HDC; Error: Integer): Bool; stdcall;
begin
  Result := not Printer.Aborted;
end;

{ TPdfDocumentVclPrinter }

function TPdfDocumentVclPrinter.PrinterStartDoc(const AJobTitle: string): Boolean;
begin
  Result := False;
  FPagePrinted := False;
  if not Printer.Printing then
  begin
    if AJobTitle <> '' then
      Printer.Title := AJobTitle;
    Printer.BeginDoc;
    FBeginDocCalled := Printer.Printing;
    Result := FBeginDocCalled;
  end;
  if Result and Printer.Printing then
  begin
    // The Printers.AbortProc function calls ProcessMessages. That not only slows down the performance
    // but it also allows the user to do things in the UI.
    SetAbortProc(GetPrinterDC, @FastVclAbortProc);
  end;
end;

procedure TPdfDocumentVclPrinter.PrinterEndDoc;
begin
  if Printer.Printing then
  begin
    SetAbortProc(GetPrinterDC, @VclAbortProc); // restore default behavior
    if FBeginDocCalled then
      Printer.EndDoc;
  end;
end;

procedure TPdfDocumentVclPrinter.PrinterStartPage;
begin
  // Printer has only "NewPage" and the very first page doesn't need a NewPage call because
  // Printer.BeginDoc already called Windows.StartPage.
  if (Printer.PageNumber > 1) or FPagePrinted then
    Printer.NewPage;
end;

procedure TPdfDocumentVclPrinter.PrinterEndPage;
begin
  FPagePrinted := True;
  // The VCL uses "NewPage". For the very last page Printer.EndDoc calls Windows.EndPage.
end;

function TPdfDocumentVclPrinter.GetPrinterDC: HDC;
begin
  Result := Printer.Canvas.Handle;
end;

class function TPdfDocumentVclPrinter.PrintDocument(ADocument: TPdfDocument;
  const AJobTitle: string; AShowPrintDialog, AllowPageRange: Boolean; AParentWnd: HWND): Boolean;
var
  PdfPrinter: TPdfDocumentVclPrinter;
  Dlg: TPrintDialog;
  FromPage, ToPage: Integer;
begin
  Result := False;
  if ADocument = nil then
    Exit;

  FromPage := 1;
  ToPage := ADocument.PageCount;
    
  if AShowPrintDialog then
  begin
    Dlg := TPrintDialog.Create(nil);
    try
      // Set the PrintDialog options
      if AllowPageRange then
      begin
        Dlg.MinPage := 1;
        Dlg.MaxPage := ADocument.PageCount;
        Dlg.Options := Dlg.Options + [poPageNums];
      end;

      // Show the PrintDialog
      {$IFDEF FPC}
      Result := Dlg.Execute;
      {$ELSE}
      if (AParentWnd = 0) or not IsWindow(AParentWnd) then
        Result := Dlg.Execute
      else
        Result := Dlg.Execute(AParentWnd);
      {$ENDIF FPC}

      if not Result then
        Exit;

      // Adjust print options
      if AllowPageRange and (Dlg.PrintRange = prPageNums) then
      begin
        FromPage := Dlg.FromPage;
        ToPage := Dlg.ToPage;
      end;      
    finally
      Dlg.Free;
    end;
  end;

  PdfPrinter := TPdfDocumentVclPrinter.Create;
  try
    if PdfPrinter.BeginPrint(AJobTitle) then
    begin
      try
        Result := PdfPrinter.Print(ADocument, FromPage - 1, ToPage - 1);
      finally
        PdfPrinter.EndPrint;
      end;
    end;
  finally
    PdfPrinter.Free;
  end;
end;

{ TPdfControl }

constructor TPdfControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];

  FScaleMode := smFitAuto;
  FZoomPercentage := 100;
  FPageColor := clWhite;
  FRotation := prNormal;
  FAllowUserTextSelection := True;
  FAllowUserPageChange := True;
  FAllowFormEvents := True;
  FDrawOptions := cPdfControlDefaultDrawOptions;
  FScrollTimer := True;
  FBufferedPageDraw := True;
  FLinkOptions := cPdfControlDefaultLinkOptions;

  FPageBorderColor := clNone;
  FPageShadowColor := clNone;
  FPageShadowSize := 4;
  FPageShadowPadding := 44;

  FDocument := TPdfDocument.Create;
  InitDocument;

  ParentDoubleBuffered := False;
  ParentBackground := False;
  ParentColor := False;
  TabStop := True;
  Color := clGray;
  Width := 130;
  Height := 180;
end;

destructor TPdfControl.Destroy;
begin
  if FPageBitmap <> 0 then
    DeleteObject(FPageBitmap);
  FDocument.Free;
  inherited Destroy;
end;

procedure TPdfControl.InitDocument;
begin
  FDocument.OnFormInvalidate := FormInvalidate;
  FDocument.OnFormOutputSelectedRect := FormOutputSelectedRect;
  FDocument.OnFormGetCurrentPage := FormGetCurrentPage;
  FDocument.OnFormFieldFocus := FormFieldFocus;
  FDocument.OnExecuteNamedAction := ExecuteNamedAction;
end;

procedure TPdfControl.DestroyWnd;
begin
  StopScrollTimer;
  if FCheckForTrippleClick then
    KillTimer(Handle, cTrippleClickTimerId);
  inherited DestroyWnd;
end;

{$IFDEF USE_PRINTCLIENT_WORKAROUND}
procedure TPdfControl.WMPrintClient(var Message: TWMPrintClient);
// Emulate Delphi 2010's TControlState.csPrintClient
var
  LastPrintClient: Boolean;
begin
  LastPrintClient := FPrintClient;
  try
    FPrintClient := True;
    inherited;
  finally
    FPrintClient := LastPrintClient;
  end;
end;
{$ENDIF USE_PRINTCLIENT_WORKAROUND}

procedure TPdfControl.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TPdfControl.DrawAlphaSelection(DC: HDC; Page: TPdfPage; const ARects: TPdfRectArray);
var
  Count: Integer;
  I: Integer;
  R: TRect;
  BmpDC: HDC;
  SelBmp: TBitmap;
  BlendFunc: TBlendFunction;
begin
  Count := Length(ARects);
  if Count > 0 then
  begin
    SelBmp := TBitmap.Create;
    try
      SelBmp.Canvas.Brush.Color := RGB(50, 142, 254);
      SelBmp.SetSize(100, 50);
      BlendFunc.BlendOp := AC_SRC_OVER;
      BlendFunc.BlendFlags := 0;
      BlendFunc.SourceConstantAlpha := 127;
      BlendFunc.AlphaFormat := 0;
      BmpDC := SelBmp.Canvas.Handle;
      for I := 0 to Count - 1 do
      begin
        R := InternPageToDevice(Page, ARects[I]);
        if RectVisible(DC, R) then
          AlphaBlend(DC, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top,
                     BmpDC, 0, 0, SelBmp.Width, SelBmp.Height,
                     BlendFunc);
      end;
    finally
      SelBmp.Free;
    end;
  end;
end;

procedure TPdfControl.DrawSelection(DC: HDC; Page: TPdfPage);
var
  Count: Integer;
  I: Integer;
  Rects: TPdfRectArray;
begin
  Count := Page.GetTextRectCount(SelStart, SelLength);
  if Count > 0 then
  begin
    SetLength(Rects, Count);
    for I := 0 to Count - 1 do
      Rects[I] := Page.GetTextRect(I);
    DrawAlphaSelection(DC, Page, Rects);
  end;
end;

procedure TPdfControl.DrawFormOutputSelectedRects(DC: HDC; Page: TPdfPage);
begin
  DrawAlphaSelection(DC, Page, FFormOutputSelectedRects);
end;

procedure TPdfControl.DrawHighlightText(DC: HDC; Page: TPdfPage);
var
  I: Integer;
  R: TRect;
  BmpDC: HDC;
  SelBmp: TBitmap;
  BlendFunc: TBlendFunction;
begin
  if FHighlightTextRects <> nil then
  begin
    SelBmp := TBitmap.Create;
    try
      SelBmp.Canvas.Brush.Color := RGB(254, 142, 50);
      SelBmp.SetSize(100, 50);
      BlendFunc.BlendOp := AC_SRC_OVER;
      BlendFunc.BlendFlags := 0;
      BlendFunc.SourceConstantAlpha := 127;
      BlendFunc.AlphaFormat := 0;
      BmpDC := SelBmp.Canvas.Handle;

      for I := 0 to Length(FHighlightTextRects) - 1 do
      begin
        R := InternPageToDevice(Page, FHighlightTextRects[I]);
        if RectVisible(DC, R) then
          AlphaBlend(DC, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top,
                     BmpDC, 0, 0, SelBmp.Width, SelBmp.Height,
                     BlendFunc);
      end;
    finally
      SelBmp.Free;
    end;
  end;
end;

procedure TPdfControl.DrawBorderAndShadow(DC: HDC);
var
  BorderBrush, ShadowBrush: HBRUSH;
begin
  // Draw page borders
  if PageBorderColor <> clNone then
  begin
    BorderBrush := CreateSolidBrush(ColorToRGB(PageBorderColor));
    FillRect(DC, Rect(FDrawX, FDrawY, FDrawX + FDrawWidth, FDrawY + 1), BorderBrush);                             // top border
    FillRect(DC, Rect(FDrawX, FDrawY, FDrawX + 1, FDrawY + FDrawHeight), BorderBrush);                            // left border
    FillRect(DC, Rect(FDrawX + FDrawWidth - 1, FDrawY, FDrawX + FDrawWidth, FDrawY + FDrawHeight), BorderBrush);  // right border
    FillRect(DC, Rect(FDrawX, FDrawY + FDrawHeight - 1, FDrawX + FDrawWidth, FDrawY + FDrawHeight), BorderBrush); // bottom border
    DeleteObject(BorderBrush);
  end;

  // Draw page shadow
  if (PageShadowColor <> clNone) and (PageShadowSize > 0) then
  begin
    ShadowBrush := CreateSolidBrush(ColorToRGB(PageShadowColor));
    FillRect(DC, Rect(FDrawX + FDrawWidth, FDrawY + PageShadowSize,
                          FDrawX + FDrawWidth + PageShadowSize, FDrawY + FDrawHeight + PageShadowSize),
             ShadowBrush); // right shadow
    FillRect(DC, Rect(FDrawX + PageShadowSize, FDrawY + FDrawHeight,
                          FDrawX + FDrawWidth + PageShadowSize, FDrawY + FDrawHeight + PageShadowSize),
             ShadowBrush); // bottom shadow
    DeleteObject(ShadowBrush);
  end;
end;

procedure TPdfControl.DrawPage(DC: HDC; Page: TPdfPage; DirectDrawPage: Boolean);

  procedure Draw(DC: HDC; X, Y: Integer; Page: TPdfPage);
  var
    PageBrush: HBRUSH;
    ColorRef: TColorRef;
  begin
    if PageColor = clDefault then
      ColorRef := ColorToRGB(Color)
    else
      ColorRef := ColorToRGB(PageColor);

    // Page.Draw doesn't paint the background if proPrinting is enabled.
    if proPrinting in FDrawOptions then
    begin
      PageBrush := CreateSolidBrush(ColorRef);
      FillRect(DC, Rect(X, Y, X + FDrawWidth, Y + FDrawHeight), PageBrush);
      DeleteObject(PageBrush);
    end;

    Page.Draw(DC, X, Y, FDrawWidth, FDrawHeight, Rotation, FDrawOptions, ColorRef);
  end;

var
  PageDC: HDC;
  OldPageBmp: HBITMAP;
  bmi: TBitmapInfo;
  BmpData: Windows.TBitmap;
  Bits: Pointer;
begin
  if DirectDrawPage then
  begin
    if FPageBitmap <> 0 then
    begin
      DeleteObject(FPageBitmap);
      FPageBitmap := 0;
    end;
    FRenderedPageIndex := -1;
    Draw(DC, FDrawX, FDrawY, Page);
  end
  else
  begin
    if (FPageBitmap = 0) or
       (GetObject(FPageBitmap, SizeOf(BmpData), @BmpData) <> SizeOf(BmpData)) or
       (FDrawWidth <> BmpData.bmWidth) or
       (FDrawHeight <> BmpData.bmHeight) then
    begin
      FRenderedPageIndex := -1; // force rendering
      if FPageBitmap <> 0 then
        DeleteObject(FPageBitmap);
      if GetDeviceCaps(DC, BITSPIXEL) = 32 then
        FPageBitmap := CreateCompatibleBitmap(DC, FDrawWidth, FDrawHeight)
      else
      begin
        FillChar(bmi, SizeOf(bmi), 0);
        bmi.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
        bmi.bmiHeader.biWidth := FDrawWidth;
        bmi.bmiHeader.biHeight := -FDrawHeight; // top-down
        bmi.bmiHeader.biPlanes := 1;
        bmi.bmiHeader.biBitCount := 32;
        bmi.bmiHeader.biCompression := BI_RGB;
        FPageBitmap := CreateDIBSection(DC, bmi, DIB_RGB_COLORS, Bits, 0, 0);
      end;
    end;

    PageDC := CreateCompatibleDC(DC);
    OldPageBmp := SelectObject(PageDC, FPageBitmap);
    try
      if FRenderedPageIndex <> PageIndex then
      begin
        FRenderedPageIndex := PageIndex;
        Draw(PageDC, 0, 0, Page);
      end;
      BitBlt(DC, FDrawX, FDrawY, FDrawWidth, FDrawHeight, PageDC, 0, 0, SRCCOPY);
    finally
      SelectObject(PageDC, OldPageBmp);
      DeleteDC(PageDC);
    end;
  end;
end;

procedure TPdfControl.Paint;
var
  Page: TPdfPage;
  DC, DrawDC: HDC;
  DrawBmp, OldDrawBmp: HBITMAP;
  Rgn: HRGN;
  DirectPageDraw: Boolean;
  WndR, ClipR: TRect;
begin
  DC := Canvas.Handle;
  {$IFDEF REPAINTTEST}
  FillRect(DC, ClientRect, GetStockObject(BLACK_BRUSH));
  GdiFlush;
  Sleep(70);
  {$ENDIF REPAINTTEST}

  if IsPageValid then
  begin
    DirectPageDraw := not BufferedPageDraw or
                      ((Int64(FDrawWidth) * FDrawHeight) > (Int64(Width) * Height)) and
                       (Int64(FDrawWidth) * FDrawHeight > 4096*2160); // 4K is too much for the system resources

    if DirectPageDraw or FSelectionActive or (FHighlightTextRects <> nil) then
    begin
      case GetClipBox(DC, ClipR) of
        NULLREGION:
          Exit; // nothing to paint
        ERROR:
          Windows.GetClientRect(Handle, ClipR);
      end;
      // Double buffer, minimal bitmap size
      DrawDC := CreateCompatibleDC(DC);
      DrawBmp := CreateCompatibleBitmap(DC, ClipR.Right - ClipR.Left, ClipR.Bottom - ClipR.Top);
      OldDrawBmp := SelectObject(DrawDC, DrawBmp);
      OffsetWindowOrgEx(DrawDC, ClipR.Left, ClipR.Top, nil);

      // copy the clipping region and adjust to the bitmap's device units
      Rgn := CreateRectRgn(0, 0, 1, 1);
      {$IFDEF USE_PRINTCLIENT_WORKAROUND}
      if FPrintClient then
      {$ELSE}
      if csPrintClient in ControlState then
      {$ENDIF USE_PRINTCLIENT_WORKAROUND}
      begin
        if GetClipRgn(DC, Rgn) = 1 then // application clip region
        begin
          OffsetRgn(Rgn, -ClipR.Left, -ClipR.Top);
          if SelectClipRgn(DrawDC, Rgn) = NULLREGION then
            Exit; // nothing to paint
        end;
      end
      else
      begin
        if GetRandomRgn(DC, Rgn, SYSRGN) = 1 then // system clip region, set by BeginPaint, in screen coordinates
        begin
          GetWindowRect(Handle, WndR);
          OffsetRgn(Rgn, -WndR.Left - ClipR.Left, -WndR.Top - ClipR.Top);
          SelectClipRgn(DrawDC, Rgn);
          if SelectClipRgn(DrawDC, Rgn) = NULLREGION then
            Exit; // nothing to paint
        end;
      end;
      DeleteObject(Rgn);
    end
    else
    begin
      DrawDC := DC;
      DrawBmp := 0;
      OldDrawBmp := 0;
    end;

    try
      // Draw borders
      FillRect(DrawDC, Rect(0, 0, Width, FDrawY), Brush.Handle);                                      // top bar
      FillRect(DrawDC, Rect(0, FDrawY, FDrawX, FDrawY + FDrawHeight), Brush.Handle);                  // left bar
      FillRect(DrawDC, Rect(FDrawX + FDrawWidth, FDrawY, Width, FDrawY + FDrawHeight), Brush.Handle); // right bar
      FillRect(DrawDC, Rect(0, FDrawY + FDrawHeight, Width, Height), Brush.Handle);                   // bottom bar

      // Draw the page
      Page := CurrentPage;
      DrawPage(DrawDC, Page, DirectPageDraw);
      // Draw the selection overlay
      if FSelectionActive then
        DrawSelection(DrawDC, Page);

      DrawFormOutputSelectedRects(DrawDC, Page);

      // Draw the highlighted text overlay
      DrawHighlightText(DrawDC, Page);

      DrawBorderAndShadow(DrawDC);

      // User painting
      if Assigned(FOnPaint) then
      begin
        Canvas.Handle := DrawDC;
        try
          FOnPaint(Self);
        finally
          Canvas.Handle := DC;
        end;
      end;

      if DrawDC <> DC then
        BitBlt(DC, 0, 0, Width, Height, DrawDC, 0, 0, SRCCOPY);
    finally
      if DrawBmp <> 0 then
      begin
        SelectObject(DrawDC, OldDrawBmp);
        DeleteObject(DrawBmp);
      end;
      if DrawDC <> DC then
        DeleteDC(DrawDC);
    end;
  end
  else
  begin
    // empty page
    if FPageBitmap <> 0 then
    begin
      DeleteObject(FPageBitmap);
      FPageBitmap := 0;
    end;
    FillRect(DC, Rect(0, 0, Width, Height), Brush.Handle);
    DrawBorderAndShadow(DC);
    if Assigned(FOnPaint) then
      FOnPaint(Self);
  end;
end;

procedure TPdfControl.PageContentChanged(Closing: Boolean);
begin
  FSelStartCharIndex := 0;
  FSelStopCharIndex := 0;
  FSelectionActive := False;
  CalcHighlightTextRects;
  GetPageWebLinks;
  PageLayoutChanged;
  if not Closing then
    PageChange;
end;

procedure TPdfControl.PageLayoutChanged;
begin
  FRenderedPageIndex := -1;
  UpdatePageDrawInfo;
  Invalidate;
end;

procedure TPdfControl.InvalidatePage;
var
  R: TRect;
begin
  FRenderedPageIndex := -1;
  if HandleAllocated then
  begin
    R := GetPageRect;
    InvalidateRect(Handle, @R, True);
  end;
end;

procedure TPdfControl.PrintDocument;
begin
  if Document.Active then
  begin
    if Assigned(FOnPrintDocument) then
      FOnPrintDocument(Self)
    else
      TPdfDocumentVclPrinter.PrintDocument(Document, ExtractFileName(Document.FileName));
  end;
end;

function TPdfControl.GetCurrentPage: TPdfPage;
begin
  if IsPageValid then
    Result := FDocument.Pages[PageIndex]
  else
    Result := nil;
end;

function TPdfControl.GetPageCount: Integer;
begin
  Result := FDocument.PageCount;
end;

procedure TPdfControl.SetPageIndex(Value: Integer);
begin
  InternSetPageIndex(Value, False, False);
end;

function TPdfControl.InternSetPageIndex(Value: Integer; ScrollTransition, InverseScrollTransition: Boolean): Boolean;
var
  ScrollInfo: TScrollInfo;
  ScrollY: Integer;
  OldPageIndex: Integer;
begin
  if Value >= PageCount then
    Value := PageCount - 1;
  if Value < 0 then
    Value := 0;

  if Value <> FPageIndex then
  begin
    ClearSelection;
    // Close the previous page to keep memory usage low (especially for large PDF files)
    if (FPageIndex >= 0) and (FPageIndex < PageCount) and FDocument.IsPageLoaded(FPageIndex) and
       not FDocument.Pages[FPageIndex].Annotations.AnnotationsLoaded then // Issue #28: Don't close the page if annotations are loaded
    begin
      FDocument.Pages[FPageIndex].Close;
    end;
    OldPageIndex := FPageIndex;
    FPageIndex := Value;
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    if ScrollTransition then
    begin
      // Keep the Scroll XOffset but scroll the page to the top or the bottom depending on the
      // PageIndex change.
      ScrollY := 0;
      ScrollInfo.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
      if GetScrollInfo(Handle, SB_VERT, ScrollInfo) then
      begin
        if InverseScrollTransition then
        begin
          if FPageIndex < OldPageIndex then
            ScrollY := 0
          else
            ScrollY := ScrollInfo.nMax {- Integer(ScrollInfo.nPage)};
        end
        else
        begin
          if FPageIndex > OldPageIndex then
            ScrollY := 0
          else
            ScrollY := ScrollInfo.nMax {- Integer(ScrollInfo.nPage)};
        end;
      end;
      if ScrollInfo.nPos <> ScrollY then
      begin
        ScrollInfo.fMask := SIF_POS;
        ScrollInfo.nPos := ScrollY;
        SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
      end;
    end
    else // Scroll to the page to the left/top corner
    begin
      ScrollInfo.fMask := SIF_POS;
      ScrollInfo.nPos := 0;
      SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
      SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
    end;
    PageContentChanged(False);
    Result := True;
  end
  else
    Result := False;
end;

function TPdfControl.GotoNextPage(ScrollTransition: Boolean): Boolean;
begin
  Result := PageIndex < PageCount - 1;
  if Result then
    InternSetPageIndex(PageIndex + 1, ScrollTransition, False);
end;

function TPdfControl.GotoPrevPage(ScrollTransition: Boolean): Boolean;
begin
  Result := PageIndex > 0;
  if Result then
    InternSetPageIndex(PageIndex - 1, ScrollTransition, False);
end;

procedure TPdfControl.PageChange;
begin
  if Assigned(FOnPageChange) then
    FOnPageChange(Self);
end;

function TPdfControl.IsPageValid: Boolean;
begin
  Result := FDocument.Active and (PageIndex < PageCount);
end;

procedure TPdfControl.DocumentLoaded;
begin
  FPageIndex := 0;
  PageContentChanged(False);
end;

procedure TPdfControl.OpenWithDocument(Document: TPdfDocument);
begin
  Close;
  if Document = nil then
    Exit;

  FreeAndNil(FDocument);
  FDocument := Document;
  InitDocument;
end;

procedure TPdfControl.LoadFromCustom(ReadFunc: TPdfDocumentCustomReadProc; Size: LongWord;
  Param: Pointer; const Password: UTF8String);
begin
  try
    FDocument.LoadFromCustom(ReadFunc, Size, Param, Password);
  finally
    DocumentLoaded;
  end;
end;

procedure TPdfControl.LoadFromActiveStream(Stream: TStream; const Password: UTF8String);
begin
  try
    FDocument.LoadFromActiveStream(Stream, Password);
  finally
    DocumentLoaded;
  end;
end;

procedure TPdfControl.LoadFromActiveBuffer(Buffer: Pointer; Size: Int64; const Password: UTF8String);
begin
  try
    FDocument.LoadFromActiveBuffer(Buffer, Size, Password);
  finally
    DocumentLoaded;
  end;
end;

procedure TPdfControl.LoadFromBytes(const Bytes: TBytes; Index, Count: Integer;
  const Password: UTF8String);
begin
  try
    FDocument.LoadFromBytes(Bytes, Index, Count, Password);
  finally
    DocumentLoaded;
  end;
end;

procedure TPdfControl.LoadFromBytes(const Bytes: TBytes; const Password: UTF8String);
begin
  try
    FDocument.LoadFromBytes(Bytes, Password);
  finally
    DocumentLoaded;
  end;
end;

procedure TPdfControl.LoadFromStream(Stream: TStream; const Password: UTF8String);
begin
  try
    FDocument.LoadFromStream(Stream, Password);
  finally
    DocumentLoaded;
  end;
end;

procedure TPdfControl.LoadFromFile(const FileName: string; const Password: UTF8String;
  LoadOption: TPdfDocumentLoadOption);
begin
  try
    FDocument.LoadFromFile(FileName, Password, LoadOption);
  finally
    DocumentLoaded;
  end;
end;

procedure TPdfControl.Close;
begin
  FDocument.Close;
  FPageIndex := 0;
  FFormFieldFocused := False;
  PageContentChanged(True);
end;

procedure TPdfControl.CMColorchanged(var Message: TMessage);
begin
  inherited;
  if PageColor = clDefault then
    PageLayoutChanged
  else
    Invalidate;
end;

procedure TPdfControl.Resize;
begin
  UpdatePageDrawInfo;
  inherited Resize;
end;

procedure TPdfControl.SetScaleMode(const Value: TPdfControlScaleMode);
begin
  if Value <> FScaleMode then
  begin
    FScaleMode := Value;
    UpdatePageDrawInfo;
    PageLayoutChanged;
  end;
end;

procedure TPdfControl.SetZoomPercentage(Value: Integer);
begin
  if Value < 1 then
    Value := 1
  else if Value > 10000 then
    Value := 10000;
  if Value <> FZoomPercentage then
  begin
    FZoomPercentage := Value;
    PageLayoutChanged;
  end;
end;

procedure TPdfControl.SetPageColor(const Value: TColor);
begin
  if Value <> FPageColor then
  begin
    FPageColor := Value;
    InvalidatePage;
  end;
end;

procedure TPdfControl.SetDrawOptions(const Value: TPdfPageRenderOptions);
begin
  if Value <> FDrawOptions then
  begin
    FDrawOptions := Value;
    InvalidatePage;
  end;
end;

procedure TPdfControl.SetRotation(const Value: TPdfPageRotation);
begin
  if Value <> FRotation then
  begin
    FRotation := Value;
    PageLayoutChanged;
  end;
end;

procedure TPdfControl.SetPageBorderColor(const Value: TColor);
begin
  if Value <> FPageBorderColor then
  begin
    FPageBorderColor := Value;
    InvalidatePage;
  end;
end;

procedure TPdfControl.SetPageShadowColor(const Value: TColor);
begin
  if Value <> FPageShadowColor then
  begin
    FPageShadowColor := Value;
    InvalidatePage;
  end;
end;

procedure TPdfControl.SetPageShadowPadding(const Value: Integer);
begin
  if Value <> FPageShadowPadding then
  begin
    FPageShadowPadding := Value;
    InvalidatePage;
  end;
end;

procedure TPdfControl.SetPageShadowSize(const Value: Integer);
begin
  if Value <> FPageShadowSize then
  begin
    FPageShadowSize := Value;
    InvalidatePage;
  end;
end;

function TPdfControl.GetPageRect: TRect;
begin
  Result := Rect(FDrawX, FDrawY, FDrawX + FDrawWidth, FDrawY + FDrawHeight);
end;

function TPdfControl.DeviceToPage(DeviceX, DeviceY: Integer): TPdfPoint;
var
  Page: TPdfPage;
begin
  Page := CurrentPage;
  if Page <> nil then
    Result := Page.DeviceToPage(FDrawX, FDrawY, FDrawWidth, FDrawHeight, DeviceX, DeviceY, Rotation)
  else
    Result := TPdfPoint.Empty;
end;

function TPdfControl.DeviceToPage(DeviceRect: TRect): TPdfRect;
var
  Page: TPdfPage;
begin
  Page := CurrentPage;
  if Page <> nil then
    Result := Page.DeviceToPage(FDrawX, FDrawY, FDrawWidth, FDrawHeight, DeviceRect, Rotation)
  else
    Result := TPdfRect.Empty;
end;

function TPdfControl.PageToDevice(PageX, PageY: Double): TPoint;
var
  Page: TPdfPage;
begin
  Page := CurrentPage;
  if Page <> nil then
    Result := Page.PageToDevice(FDrawX, FDrawY, FDrawWidth, FDrawHeight, PageX, PageY, Rotation)
  else
    Result := Point(0, 0);
end;

function TPdfControl.PageToDevice(PageRect: TPdfRect): TRect;
var
  Page: TPdfPage;
begin
  Page := CurrentPage;
  if Page <> nil then
    Result := Page.PageToDevice(FDrawX, FDrawY, FDrawWidth, FDrawHeight, PageRect, Rotation)
  else
    Result := Rect(0, 0, 0, 0);
end;

function TPdfControl.InternPageToDevice(Page: TPdfPage; PageRect: TPdfRect): TRect;
begin
  Result := Page.PageToDevice(FDrawX, FDrawY, FDrawWidth, FDrawHeight, PageRect, Rotation);
end;

function TPdfControl.SetSelStopCharIndex(X, Y: Integer): Boolean;
var
  PagePt: TPdfPoint;
  CharIndex: Integer;
  Active: Boolean;
  R: TRect;
  Page: TPdfPage;
begin
  Page := CurrentPage;
  if Page <> nil then
  begin
    PagePt := DeviceToPage(X, Y);
    CharIndex := Page.GetCharIndexAt(PagePt.X, PagePt.Y, MAXWORD, MAXWORD);
    Result := CharIndex >= 0;
    if not Result then
      CharIndex := FSelStopCharIndex;

    if FSelStartCharIndex <> CharIndex then
      Active := True
    else
    begin
      R := PageToDevice(Page.GetCharBox(FSelStartCharIndex));
      Active := PtInRect(R, FMouseDownPt) xor PtInRect(R, Point(X, Y));
    end;
    SetSelection(Active, FSelStartCharIndex, CharIndex);
  end
  else
    Result := False;
end;

procedure TPdfControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PagePt: TPdfPoint;
  CharIndex: Integer;
  Page: TPdfPage;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    StopScrollTimer;
    SetFocus;
    FMousePressed := True;
    FMouseDownPt := Point(X, Y); // used to find out if the selection must be cleared or not
  end;

  Page := CurrentPage;
  if Page <> nil then
  begin
    if AllowFormEvents then
    begin
      PagePt := DeviceToPage(X, Y);
      if Button = mbLeft then
      begin
        if Page.FormEventLButtonDown(Shift, PagePt.X, PagePt.Y) then
          Exit;
      end
      else if Button = mbRight then
      begin
        if Page.FormEventFocus(Shift, PagePt.X, PagePt.Y) then
          Exit;
        if Page.FormEventRButtonDown(Shift, PagePt.X, PagePt.Y) then
          Exit;
      end;
    end;

    if AllowUserTextSelection and not FFormFieldFocused then
    begin
      if Button = mbLeft then
      begin
        PagePt := DeviceToPage(X, Y);
        CharIndex := Page.GetCharIndexAt(PagePt.X, PagePt.Y, MAXWORD, MAXWORD);
        if FCheckForTrippleClick and (CharIndex >= SelStart) and (CharIndex < SelStart + SelLength) then
        begin
          FMousePressed := False;
          KillTimer(Handle, cTrippleClickTimerId);
          FCheckForTrippleClick := False;
          SelectLine(CharIndex);
        end
        else if ssDouble in Shift then
        begin
          FMousePressed := False;
          SelectWord(CharIndex);
          FCheckForTrippleClick := True;
          SetTimer(Handle, cTrippleClickTimerId, GetDoubleClickTime, nil);
        end
        else
        begin
          FCheckForTrippleClick := False;
          SetSelection(False, CharIndex, CharIndex);
        end;
      end;
    end;
  end;
end;

procedure TPdfControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PagePt: TPdfPoint;
  Url: string;
  Page: TPdfPage;
  LinkAnnotation: TPdfAnnotation;
  LinkInfo: TPdfLinkInfo;
begin
  inherited MouseUp(Button, Shift, X, Y);

  if AllowFormEvents and IsPageValid then
  begin
    PagePt := DeviceToPage(X, Y);
    Page := CurrentPage;
    if (Button = mbLeft) and Page.FormEventLButtonUp(Shift, PagePt.X, PagePt.Y) then
    begin
      if FMousePressed and (Button = mbLeft) then
      begin
        FMousePressed := False;
        StopScrollTimer;
      end;
      Exit;
    end;
    if (Button = mbRight) and Page.FormEventRButtonUp(Shift, PagePt.X, PagePt.Y) then
      Exit;
  end;

  if FMousePressed then
  begin
    if Button = mbLeft then
    begin
      FMousePressed := False;
      StopScrollTimer;
      if AllowUserTextSelection and not FFormFieldFocused then
        SetSelStopCharIndex(X, Y);
      if not FSelectionActive then
      begin
        if LinkHandlingNeeded then
        begin
          LinkAnnotation := GetAnnotationLinkAt(X, Y);
          LinkInfo := nil;
          if LinkAnnotation <> nil then
            LinkInfo := TPdfLinkInfo.Create(LinkAnnotation, '')
          else if IsWebLinkAt(X, Y, Url) then // If we have a Link Annotation and a WebLink, then the link annotation is prefered
          begin
            if loTreatWebLinkAsUriAnnotationLink in LinkOptions then
              LinkInfo := TPdfLinkInfo.Create(nil, Url)
            else
              WebLinkClick(Url);
          end;
          if LinkInfo <> nil then
          begin
            try
              AnnotationLinkClick(LinkInfo);
            finally
              LinkInfo.Free;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TPdfControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  PagePt: TPdfPoint;
  Style: NativeInt;
  NewCursor: TCursor;
  Page: TPdfPage;
  Proceed: Boolean;
begin
  inherited MouseMove(Shift, X, Y);
  NewCursor := Cursor;
  try
    if AllowFormEvents and IsPageValid then
    begin
      PagePt := DeviceToPage(X, Y);
      Page := CurrentPage;
      if Page.FormEventMouseMove(Shift, PagePt.X, PagePt.Y) then
      begin
        Proceed := False;
        case Page.HasFormFieldAtPoint(PagePt.X, PagePt.Y) of
          fftUnknown:
            // Could be a annotation link with a URL
            Proceed := True;
          fftTextField:
            NewCursor := crIBeam;
          fftComboBox,
          fftSignature:
            NewCursor := crHandPoint;
        else
          NewCursor := crDefault;
        end;
        if not Proceed then
          Exit;
      end;
    end;

    if AllowUserTextSelection and not FFormFieldFocused then
    begin
      if FMousePressed then
      begin
        // Auto scroll
        FScrollMousePos := Point(X, Y);
        Style := GetWindowLong(Handle, GWL_STYLE);
        if ((Style and WS_VSCROLL <> 0) and ((Y < 0) or (Y > Height))) or
           ((Style and WS_HSCROLL <> 0) and ((X < 0) or (X > Width))) then
        begin
          if ScrollTimer and not FScrollTimerActive then
          begin
            SetTimer(Handle, cScrollTimerId, cScrollTimerInterval, nil);
            FScrollTimerActive := True;
          end;
        end
        else
          StopScrollTimer;

        if SetSelStopCharIndex(X, Y) then
        begin
          if NewCursor <> crIBeam then
          begin
            NewCursor := crIBeam;
            Cursor := NewCursor;
            SetCursor(Screen.Cursors[Cursor]); // show the mouse cursor change immediately
          end;
        end;
      end
      else
      begin
        if IsPageValid then
        begin
          PagePt := DeviceToPage(X, Y);
          if IsClickableLinkAt(X, Y) then
            NewCursor := crHandPoint
          else if CurrentPage.GetCharIndexAt(PagePt.X, PagePt.Y, 5, 5) >= 0 then
            NewCursor := crIBeam
          else if Cursor <> crDefault then
            NewCursor := crDefault;
        end;
      end;
    end;
  finally
    if NewCursor <> Cursor then
      Cursor := NewCursor;
  end;
end;

procedure TPdfControl.CMMouseleave(var Message: TMessage);
begin
  if (Cursor = crIBeam) or (Cursor = crHandPoint) then
  begin
    if AllowUserTextSelection or Assigned(FOnWebLinkClick) or Assigned(FOnAnnotationLinkClick) or (LinkOptions <> []) then
      Cursor := crDefault;
  end;
  inherited;
end;

function TPdfControl.GetTextInRect(const R: TRect): string;
begin
  if IsPageValid then
    Result := CurrentPage.GetTextAt(DeviceToPage(R))
  else
    Result := '';
end;

procedure TPdfControl.CopyToClipboard;
begin
  Clipboard.AsText := GetSelText;
end;

procedure TPdfControl.CopyFormTextToClipboard;
var
  S: string;
begin
  if FFormFieldFocused and IsPageValid then
  begin
    S := CurrentPage.FormGetSelectedText;
    if S <> '' then
      Clipboard.AsText := S;
  end;
end;

procedure TPdfControl.CutFormTextToClipboard;
begin
  if FFormFieldFocused and IsPageValid then
  begin
    CopyFormTextToClipboard;
    CurrentPage.FormReplaceSelection('');
  end;
end;

procedure TPdfControl.PasteFormTextFromClipboard;
begin
  if FFormFieldFocused and IsPageValid then
  begin
    Clipboard.Open;
    try
      if Clipboard.HasFormat(CF_UNICODETEXT) or Clipboard.HasFormat(CF_TEXT) then
        CurrentPage.FormReplaceSelection(Clipboard.AsText);
    finally
      Clipboard.Close;
    end;
  end;
end;

procedure TPdfControl.SelectAllFormText;
begin
  if FFormFieldFocused and IsPageValid then
    CurrentPage.FormSelectAllText;
end;

function TPdfControl.GetSelText: string;
begin
  if FSelectionActive and IsPageValid then
    Result := CurrentPage.ReadText(SelStart, SelLength)
  else
    Result := '';
end;

function TPdfControl.GetSelLength: Integer;
begin
  if FSelectionActive and IsPageValid then
    Result := Abs(FSelStartCharIndex - FSelStopCharIndex) + 1
  else
    Result := 0;
end;

function TPdfControl.GetSelStart: Integer;
begin
  if FSelectionActive and IsPageValid then
    Result := Min(FSelStartCharIndex, FSelStopCharIndex)
  else
    Result := 0;
end;

function TPdfControl.GetSelectionRects: TPdfControlRectArray;
var
  Count: Integer;
  I: Integer;
  Page: TPdfPage;
begin
  if FSelectionActive and HandleAllocated then
  begin
    Page := CurrentPage;
    if Page <> nil then
    begin
      Count := Page.GetTextRectCount(SelStart, SelLength);
      SetLength(Result, Count);
      for I := 0 to Count - 1 do
        Result[I] := InternPageToDevice(Page, Page.GetTextRect(I));
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TPdfControl.InvalidateRectDiffs(const OldRects, NewRects: TPdfControlRectArray);

  function ContainsRect(const Rects: TPdfControlRectArray; const R: TRect): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to Length(Rects) - 1 do
      if (Rects[I].Left = R.Left) and (Rects[I].Top = R.Top) and (Rects[I].Right = R.Right) and (Rects[I].Bottom = R.Bottom) then
        Exit;
    Result := False;
  end;

var
  I: Integer;
begin
  if HandleAllocated then
  begin
    for I := 0 to Length(OldRects) - 1 do
      if not ContainsRect(NewRects, OldRects[I]) then
        InvalidateRect(Handle, @OldRects[I], True);

    for I := 0 to Length(NewRects) - 1 do
      if not ContainsRect(OldRects, NewRects[I]) then
        InvalidateRect(Handle, @NewRects[I], True);
  end;
end;

procedure TPdfControl.InvalidatePdfRectDiffs(const OldRects, NewRects: TPdfControlPdfRectArray);
var
  I: Integer;
  OldRs, NewRs: TPdfControlRectArray;
  Page: TPdfPage;
begin
  Page := CurrentPage;
  if (Page <> nil) and HandleAllocated then
  begin
    SetLength(OldRs, Length(OldRects));
    for I := 0 to Length(OldRects) - 1 do
      OldRs[I] := InternPageToDevice(Page, OldRects[I]);

    SetLength(NewRs, Length(NewRects));
    for I := 0 to Length(NewRects) - 1 do
      NewRs[I] := InternPageToDevice(Page, NewRects[I]);

    InvalidateRectDiffs(OldRs, NewRs);
  end;
end;

procedure TPdfControl.SetSelection(Active: Boolean; StartIndex, StopIndex: Integer);
var
  OldRects, NewRects: TPdfControlRectArray;
begin
  if (Active <> FSelectionActive) or (StartIndex <> FSelStartCharIndex) or (StopIndex <> FSelStopCharIndex) then
  begin
    OldRects := GetSelectionRects;

    FSelStartCharIndex := StartIndex;
    FSelStopCharIndex := StopIndex;
    FSelectionActive := Active and (FSelStartCharIndex >= 0) and (FSelStopCharIndex >= 0);

    NewRects := GetSelectionRects;
    InvalidateRectDiffs(OldRects, NewRects);
  end;
end;

procedure TPdfControl.ClearSelection;
begin
  SetSelection(False, 0, 0);
end;

procedure TPdfControl.SelectAll;
begin
  SelectText(0, -1);
end;

procedure TPdfControl.SelectText(CharIndex, Count: Integer);
begin
  if (Count = 0) or not IsPageValid then
    ClearSelection
  else
  begin
    if Count = -1 then
      SetSelection(True, 0, CurrentPage.GetCharCount - 1)
    else
      SetSelection(True, CharIndex, Min(CharIndex + Count - 1, CurrentPage.GetCharCount - 1));
  end;
end;

function TPdfControl.SelectWord(CharIndex: Integer): Boolean;
var
  Ch: WideChar;
  StartCharIndex, StopCharIndex, CharCount: Integer;
  Page: TPdfPage;
begin
  Result := False;
  Page := CurrentPage;
  if Page <> nil then
  begin
    ClearSelection;
    CharCount := Page.GetCharCount;
    if (CharIndex >= 0) and (CharIndex < CharCount) then
    begin
      while (CharIndex < CharCount) and IsWhiteSpace(Page.ReadChar(CharIndex)) do
        Inc(CharIndex);

      if CharIndex < CharCount then
      begin
        StartCharIndex := CharIndex - 1;
        while StartCharIndex >= 0 do
        begin
          Ch := Page.ReadChar(StartCharIndex);
          if IsWhiteSpace(Ch) then
            Break;
          Dec(StartCharIndex);
        end;
        Inc(StartCharIndex);

        StopCharIndex := CharIndex + 1;
        while StopCharIndex < CharCount do
        begin
          Ch := Page.ReadChar(StopCharIndex);
          if IsWhiteSpace(Ch) then
            Break;
          Inc(StopCharIndex);
        end;
        Dec(StopCharIndex);

        SetSelection(True, StartCharIndex, StopCharIndex);
        Result := True;
      end;
    end;
  end;
end;

function TPdfControl.SelectLine(CharIndex: Integer): Boolean;
var
  Ch: WideChar;
  StartCharIndex, StopCharIndex, CharCount: Integer;
  Page: TPdfPage;
begin
  Result := False;
  Page := CurrentPage;
  if Page <> nil then
  begin
    ClearSelection;
    CharCount := Page.GetCharCount;
    if (CharIndex >= 0) and (CharIndex < CharCount) then
    begin
      StartCharIndex := CharIndex - 1;
      while StartCharIndex >= 0 do
      begin
        Ch := Page.ReadChar(StartCharIndex);
        case Ch of
          #10, #13:
            Break;
        end;
        Dec(StartCharIndex);
      end;
      Inc(StartCharIndex);

      StopCharIndex := CharIndex + 1;
      while StopCharIndex < CharCount do
      begin
        Ch := Page.ReadChar(StopCharIndex);
        case Ch of
          #10, #13:
            Break;
        end;
        Inc(StopCharIndex);
      end;
      Dec(StopCharIndex);

      SetSelection(True, StartCharIndex, StopCharIndex);
      Result := True;
    end;
  end;
end;

procedure TPdfControl.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTTAB;
end;

procedure TPdfControl.KeyDown(var Key: Word; Shift: TShiftState);
var
  XOffset, YOffset: Integer;
  ScrollInfo: TScrollInfo;
begin
  inherited KeyDown(Key, Shift);
  XOffset := 0;
  YOffset := 0;
  case Key of
    Ord('C'), VK_INSERT:
      if AllowUserTextSelection then
      begin
        if Shift = [ssCtrl] then
        begin
          if FSelectionActive then
            CopyToClipboard;
          Key := 0;
        end
      end;

    Ord('A'):
      if AllowUserTextSelection then
      begin
        if Shift = [ssCtrl] then
        begin
          SelectAll;
          Key := 0;
        end;
      end;

    VK_LEFT, VK_RIGHT:
      begin
        if ssShift in Shift then
          XOffset := cDefaultScrollOffset * 2
        else
          XOffset := cDefaultScrollOffset;
        if Key = VK_LEFT then
          XOffset := -XOffset;
      end;

    VK_UP, VK_DOWN:
      begin
        if ssShift in Shift then
          YOffset := cDefaultScrollOffset * 2
        else
          YOffset := cDefaultScrollOffset;
        if Key = VK_UP then
          YOffset := -YOffset;
      end;

    VK_PRIOR, VK_NEXT:
      begin
        ScrollInfo.cbSize := SizeOf(ScrollInfo);
        ScrollInfo.fMask := SIF_PAGE or SIF_RANGE or SIF_POS;
        if AllowUserPageChange and (GetWindowLong(Handle, GWL_STYLE) and WS_VSCROLL = 0) then
        begin
          if Key = VK_NEXT then
            GotoNextPage(True)
          else
            GotoPrevPage(True);
        end
        else if GetScrollInfo(Handle, SB_VERT, ScrollInfo) then
        begin
          if Key = VK_NEXT then
          begin
            if AllowUserPageChange and (ScrollInfo.nPos >= ScrollInfo.nMax - Integer(ScrollInfo.nPage)) then
              GotoNextPage(True)
            else
              YOffset := ScrollInfo.nPage
          end
          else
          begin
            if AllowUserPageChange and (ScrollInfo.nPos = 0) then
              GotoPrevPage(True)
            else
              YOffset := -ScrollInfo.nPage;
          end;
        end;
      end;

    VK_HOME, VK_END:
      begin
        if ssCtrl in Shift then
        begin
          if Key = VK_HOME then
            InternSetPageIndex(0, True, True)
          else
            InternSetPageIndex(PageCount - 1, True, True);
        end
        else
        begin
          ScrollInfo.cbSize := SizeOf(ScrollInfo);
          ScrollInfo.fMask := SIF_RANGE;

          if ssShift in Shift then
          begin
            if GetScrollInfo(Handle, SB_HORZ, ScrollInfo) then
            begin
              if Key = VK_END then
                XOffset := ScrollInfo.nMax
              else
                XOffset := -ScrollInfo.nMax;
            end;
          end
          else
          begin
            if GetScrollInfo(Handle, SB_VERT, ScrollInfo) then
            begin
              if Key = VK_END then
                YOffset := ScrollInfo.nMax
              else
                YOffset := -ScrollInfo.nMax;
            end;
          end;
        end;
      end;
  end;

  if (XOffset <> 0) or (YOffset <> 0) then
  begin
    ScrollContent(XOffset, YOffset, SmoothScroll);
    Key := 0;
  end;
end;

procedure TPdfControl.WMKeyDown(var Message: TWMKeyDown);
var
  ShiftState: TShiftState;
begin
  if AllowFormEvents and IsPageValid and CurrentPage.FormEventKeyDown(Message.CharCode, Message.KeyData) then
  begin
    // PDFium doesn't handle Copy&Paste&Cut keyboard shortcuts in form fields
    case Message.CharCode of
      Ord('C'), Ord('X'), Ord('V'), VK_INSERT, VK_DELETE:
        begin
          ShiftState := KeyDataToShiftState(Message.KeyData);
          if ShiftState = [ssCtrl] then
          begin
            case Message.CharCode of
              Ord('C'), VK_INSERT:
                CopyFormTextToClipboard;
              Ord('X'):
                CutFormTextToClipboard;
              Ord('V'):
                PasteFormTextFromClipboard;
            end;
          end
          else if ShiftState = [ssShift] then
          begin
            case Message.CharCode of
              VK_INSERT:
                PasteFormTextFromClipboard;
              VK_DELETE:
                CutFormTextToClipboard;
            end;
          end;
        end;
    end;
    Exit;
  end;
  inherited;
end;

procedure TPdfControl.WMKeyUp(var Message: TWMKeyUp);
begin
  if AllowFormEvents and IsPageValid and CurrentPage.FormEventKeyUp(Message.CharCode, Message.KeyData) then
    Exit;
  inherited;
end;

procedure TPdfControl.WMChar(var Message: TWMChar);
begin
  if AllowFormEvents and IsPageValid and CurrentPage.FormEventKeyPress(Message.CharCode, Message.KeyData) then
    Exit;
  inherited;
end;

procedure TPdfControl.WMKillFocus(var Message: TWMKillFocus);
begin
  if AllowFormEvents and IsPageValid then
    CurrentPage.FormEventKillFocus;
  inherited;
end;

procedure TPdfControl.GetPageWebLinks;
var
  Page: TPdfPage;
begin
  FreeAndNil(FWebLinkInfo);
  Page := CurrentPage;
  if Page <> nil then
    FWebLinkInfo := TPdfPageWebLinksInfo.Create(Page);
end;

function TPdfControl.LinkHandlingNeeded: Boolean;
begin
  // If an event handler is assigned, we need link handling
  Result := Assigned(FOnAnnotationLinkClick) or Assigned(FOnWebLinkClick);
  if not Result then
  begin
    // If no event handler is assigned, we may need link handling depending on the loAutoXXX options.
    Result := LinkOptions * cPdfControlAllAutoLinkOptions <> [];
  end;
end;

function TPdfControl.IsClickableLinkAt(X, Y: Integer): Boolean;
var
  LinkAnnotation: TPdfAnnotation;
begin
  Result := False;
  if LinkHandlingNeeded then
  begin
    LinkAnnotation := GetAnnotationLinkAt(X, Y);
    if LinkAnnotation <> nil then
    begin
      if Assigned(FOnAnnotationLinkClick) then
        Result := True
      else
      begin
        case LinkAnnotation.LinkType of
          altGoto:
            Result := loAutoGoto in LinkOptions;
          altRemoteGoto:
            Result := loAutoRemoteGotoReplaceDocument in LinkOptions;
          altURI:
            Result := (loAutoOpenURI in LinkOptions) or (loAlwaysDetectWebAndUriLink in LinkOptions) or Assigned(FOnWebLinkClick); // Fallback to OnWebLinkClick for URIs
          altLaunch:
            Result := loAutoLaunch in LinkOptions;
          altEmbeddedGoto:
            Result := loAutoEmbeddedGotoReplaceDocument in LinkOptions;
        else
          Result := False;
        end;
      end;
    end
    else if IsWebLinkAt(X, Y) then
    begin
      if Assigned(FOnWebLinkClick) or (loAlwaysDetectWebAndUriLink in LinkOptions) then
        Result := True
      else if Assigned(FOnAnnotationLinkClick) and (loTreatWebLinkAsUriAnnotationLink in LinkOptions) then
        Result := True
      else if not Assigned(FOnAnnotationLinkClick) and (loTreatWebLinkAsUriAnnotationLink in LinkOptions) and (loAutoOpenURI in LinkOptions) then
        Result := True;
    end;
  end;
end;

function TPdfControl.IsWebLinkAt(X, Y: Integer): Boolean;
var
  PdfPt: TPdfPoint;
begin
  if (FWebLinkInfo <> nil) and IsPageValid then
  begin
    PdfPt := DeviceToPage(X, Y);
    Result := FWebLinkInfo.IsWebLinkAt(PdfPt.X, PdfPt.Y);
  end
  else
    Result := False;
end;

function TPdfControl.IsWebLinkAt(X, Y: Integer; var Url: string): Boolean;
var
  PdfPt: TPdfPoint;
begin
  Url := '';
  if (FWebLinkInfo <> nil) and IsPageValid then
  begin
    PdfPt := DeviceToPage(X, Y);
    Result := FWebLinkInfo.IsWebLinkAt(PdfPt.X, PdfPt.Y, Url);
  end
  else
    Result := False;
end;

function TPdfControl.IsUriAnnotationLinkAt(X, Y: Integer): Boolean;
var
  PdfPt: TPdfPoint;
begin
  if IsPageValid then
  begin
    PdfPt := DeviceToPage(X, Y);
    Result := CurrentPage.IsUriLinkAtPoint(PdfPt.X, PdfPt.Y);
  end
  else
    Result := False;
end;

function TPdfControl.IsAnnotationLinkAt(X, Y: Integer): Boolean;
begin
  Result := GetAnnotationLinkAt(X, Y) <> nil;
end;

function TPdfControl.GetAnnotationLinkAt(X, Y: Integer): TPdfAnnotation;
var
  PdfPt: TPdfPoint;
begin
  if IsPageValid then
  begin
    PdfPt := DeviceToPage(X, Y);
    Result := CurrentPage.GetLinkAtPoint(PdfPt.X, PdfPt.Y);
  end
  else
    Result := nil;
end;

function TPdfControl.ShellOpenFileName(const FileName: string; Launch: Boolean): Boolean;
var
  Info: TShellExecuteInfo;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  if HandleAllocated then
    Info.Wnd := Handle;
  if Launch then
    Info.lpVerb := nil
  else
    Info.lpVerb := 'open';
  Info.lpFile := PChar(FileName);
  Info.lpDirectory := PChar(ExtractFileDir(Document.FileName));
  Info.nShow := SW_NORMAL;
  Result := ShellExecuteEx(@Info);
end;

procedure TPdfControl.WebLinkClick(const Url: string);
begin
  if Assigned(FOnWebLinkClick) then
    FOnWebLinkClick(Self, Url);
end;

function TPdfControl.GotoDestination(const LinkGotoDestination: TPdfLinkGotoDestination): Boolean;
var
  X, Y: Double;
  //Zoom: Integer;
  Pt: TPoint;
begin
  Result := False;
  if Document.Active then
  begin
    X := 0;
    Y := 0;
    //Zoom := 100;
    if LinkGotoDestination.XValid then
      X := LinkGotoDestination.X;
    if LinkGotoDestination.YValid then
      Y := LinkGotoDestination.Y;
    //if Dest.ZoomValid then
    //  Zoom := Int(Dest.Zoom);

    if (LinkGotoDestination.PageIndex >= 0) and (LinkGotoDestination.PageIndex < Document.PageCount) then
    begin
      Pt := PageToDevice(X, Y);

      PageIndex := LinkGotoDestination.PageIndex;
      //ZoomPercentage := Zoom;
      ScrollContentTo(Pt.X, Pt.Y);
      Result := True;
    end;
  end;
end;

procedure TPdfControl.AnnotationLinkClick(LinkInfo: TPdfLinkInfo);
var
  Handled: Boolean;
  Dest: TPdfLinkGotoDestination;
  FileName: string;
  RemoteDoc: TPdfDocument;
  DestValid: Boolean;
  AttachmentIndex: Integer;
begin
  Handled := False;
  if not Document.Active then
    Exit;

  if Assigned(FOnAnnotationLinkClick) then
    FOnAnnotationLinkClick(Self, LinkInfo, Handled)
  else if Assigned(FOnWebLinkClick) and (LinkInfo.LinkType = altURI) and not (loAutoOpenURI in LinkOptions) then
  begin
    WebLinkClick(LinkInfo.LinkUri);
    Exit;
  end;

  if not Handled and Document.Active then
  begin
    case LinkInfo.LinkType of
      altGoto:
        if loAutoGoto in LinkOptions then
        begin
          if LinkInfo.GetLinkGotoDestination(Dest) then
            GotoDestination(Dest);
        end;

      altRemoteGoto:
        if loAutoRemoteGotoReplaceDocument in LinkOptions then
        begin
          Dest := nil;
          RemoteDoc := TPdfDocument.Create;
          try
            // Open the remote document
            RemoteDoc.LoadFromFile(LinkInfo.LinkFileName);
            // Get the link destination from the remote document
            DestValid := LinkInfo.GetLinkGotoDestination(Dest, RemoteDoc);
          except
            RemoteDoc.Free;
            raise;
          end;
          if DestValid then
          begin
            // Replace the current document with the remote document
            OpenWithDocument(RemoteDoc);
            GotoDestination(Dest);
          end;
        end;

      altURI:
        if loAutoOpenURI in LinkOptions then
          ShellOpenFileName(LinkInfo.LinkUri, False);

      altLaunch:
        if loAutoLaunch in LinkOptions then
          ShellOpenFileName(LinkInfo.LinkFileName, True);

      altEmbeddedGoto:
        if loAutoEmbeddedGotoReplaceDocument in LinkOptions then
        begin
          FileName := LinkInfo.LinkFileName;
          AttachmentIndex := Document.Attachments.IndexOf(FileName);
          if AttachmentIndex <> -1 then
          begin
            // Same as RemoteGoto but with a byte array
            Dest := nil;
            RemoteDoc := TPdfDocument.Create;
            try
              // Open the embedded document
              RemoteDoc.LoadFromBytes(Document.Attachments[AttachmentIndex].GetContentAsBytes);
              // Get the link destination from the remote document
              DestValid := LinkInfo.GetLinkGotoDestination(Dest, RemoteDoc);
            except
              RemoteDoc.Free;
              raise;
            end;
            if DestValid then
            begin
              // Replace the current document with the remote document
              OpenWithDocument(RemoteDoc);
              GotoDestination(Dest);
            end;
          end;
        end;
    end;
  end;
end;

procedure TPdfControl.UpdatePageDrawInfo;

  procedure GetWidthHeight(PageWidth, PageHeight: Double; DpiX, DpiY, MaxWidth, MaxHeight: Integer; var W, H: Integer);
  begin
    case ScaleMode of
      smFitAuto:
        begin
          W := Round(MaxHeight * (PageWidth / PageHeight));
          H := MaxHeight;
          if W > MaxWidth then
          begin
            W := MaxWidth;
            H := Round(MaxWidth * (PageHeight / PageWidth));
          end;
        end;

      smFitWidth:
        begin
          W := MaxWidth;
          H := Round(MaxWidth * (PageHeight / PageWidth));
        end;

      smFitHeight:
        begin
          W := Round(MaxHeight * (PageWidth / PageHeight));
          H := MaxHeight;
        end;

      smZoom: // PDFium's 100% is not AcrobatReader's 100%
        begin
          W := Round(PageWidth / 72 * DpiX * (ZoomPercentage / 100));
          H := Round(PageHeight / 72 * DpiY * (ZoomPercentage / 100));
        end;
    end;

    if (PageShadowColor <> clNone) and (PageShadowSize > 0) and (PageShadowPadding > 0) then
    begin
      W := W - (PageShadowPadding + PageShadowSize);
      H := H - (PageShadowPadding + PageShadowSize);
    end;
  end;

var
  Page: TPdfPage;
  MaxWidth, MaxHeight: Integer;
  W, H: Integer;
  PageWidth, PageHeight: Double;
  DpiX, DpiY: Integer;
  ScrollInfo: TScrollInfo;
  Style: NativeInt;
begin
  Page := CurrentPage;
  if (Page <> nil) and (Page.Width > 0) and (Page.Height > 0) and HandleAllocated then
  begin
    Style := GetWindowLong(Handle, GWL_STYLE);

    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_RANGE or SIF_PAGE;
    ScrollInfo.nMin := 0;

    // Take "Rotation" into account
    if Rotation in [prNormal, pr180] then
    begin
      PageWidth := Page.Width;
      PageHeight := Page.Height;
      DpiX := GetDeviceCaps(Canvas.Handle, LOGPIXELSX);
      DpiY := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);
    end
    else
    begin
      PageHeight := Page.Width;
      PageWidth := Page.Height;
      DpiY := GetDeviceCaps(Canvas.Handle, LOGPIXELSX);
      DpiX := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);
    end;


    MaxWidth := Width;
    MaxHeight := Height;
    GetWidthHeight(PageWidth, PageHeight, DpiX, DpiY, MaxWidth, MaxHeight, W, H);
    if W > MaxWidth then
    begin
      MaxHeight := MaxHeight - GetSystemMetrics(SM_CYHSCROLL);
      GetWidthHeight(PageWidth, PageHeight, DpiX, DpiY, MaxWidth, MaxHeight, W, H);
    end;
    if H > MaxHeight then
    begin
      MaxWidth := MaxWidth - GetSystemMetrics(SM_CXVSCROLL);
      GetWidthHeight(PageWidth, PageHeight, DpiX, DpiY, MaxWidth, MaxHeight, W, H);
    end;

    if W > MaxWidth then
    begin
      ScrollInfo.nMax := W;
      ScrollInfo.nPage := MaxWidth;
      SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
    end
    else
    begin
      if Style and WS_HSCROLL <> 0 then
      begin
        ShowScrollBar(Handle, SB_HORZ, False);
        RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME);
        InvalidateRect(Handle, nil, True);
      end;
    end;

    if H > MaxHeight then
    begin
      ScrollInfo.nMax := H;
      ScrollInfo.nPage := MaxHeight;
      SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
      ShowScrollBar(Handle, SB_VERT, True);
    end
    else
    begin
      if Style and WS_VSCROLL <> 0 then
      begin
        ShowScrollBar(Handle, SB_VERT, False);
        RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME);
        InvalidateRect(Handle, nil, True);
      end;
    end;

    FDrawWidth := W;
    FDrawHeight := H;
    AdjustDrawPos;
  end;
end;

procedure TPdfControl.AdjustDrawPos;
var
  ScrollInfo: TScrollInfo;
  X, Y, HPos, VPos: Integer;
  Style: NativeInt;
  MaxWidth: Integer;
  MaxHeight: Integer;
begin
  Style := GetWindowLong(Handle, GWL_STYLE);
  MaxWidth := Width;
  MaxHeight := Height;
  HPos := 0;
  VPos := 0;

  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_POS;
  if (Style and WS_HSCROLL <> 0) then
  begin
    MaxHeight := MaxHeight - GetSystemMetrics(SM_CXHSCROLL);
    if GetScrollInfo(Handle, SB_HORZ, ScrollInfo) then
      HPos := ScrollInfo.nPos;
  end;
  if (Style and WS_VSCROLL <> 0) then
  begin
    MaxWidth := MaxWidth - GetSystemMetrics(SM_CXVSCROLL);
    if GetScrollInfo(Handle, SB_VERT, ScrollInfo) then
      VPos := ScrollInfo.nPos;
  end;

  X := (MaxWidth - FDrawWidth) div 2;
  Y := (MaxHeight - FDrawHeight) div 2;
  if X < 0 then
    X := 0;
  if Y < 0 then
    Y := 0;

  Dec(X, HPos);
  Dec(Y, VPos);
  if (FDrawX <> X) or (FDrawY <> Y) then
  begin
    FDrawX := X;
    FDrawY := Y;
  end;
end;

function TPdfControl.ScrollContent(XOffset, YOffset: Integer; Smooth: Boolean): Boolean;
var
  ScrollInfo: TScrollInfo;
  X, Y: Integer;
  Style: NativeInt;
  Flags: UINT;
begin
  if Smooth then
    Update;

  Style := GetWindowLong(Handle, GWL_STYLE);
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_POS;

  // Vertical scroll
  if (YOffset <> 0) and (Style and WS_VSCROLL <> 0) and GetScrollInfo(Handle, SB_VERT, ScrollInfo) then
  begin
    Y := ScrollInfo.nPos;
    ScrollInfo.nPos := Y + YOffset;
    SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
    GetScrollInfo(Handle, SB_VERT, ScrollInfo); // let Windows do the range checking
    YOffset := Y - ScrollInfo.nPos;
  end
  else
    YOffset := 0;

  // Horizontal scroll
  if (XOffset <> 0) and (Style and WS_HSCROLL <> 0) and GetScrollInfo(Handle, SB_HORZ, ScrollInfo) then
  begin
    X := ScrollInfo.nPos;
    ScrollInfo.nPos := X + XOffset;
    SetScrollInfo(Handle, SB_HORZ, ScrollInfo, True);
    GetScrollInfo(Handle, SB_HORZ, ScrollInfo); // let Windows do the range checking
    XOffset := X - ScrollInfo.nPos;
  end
  else
    XOffset := 0;

  if (XOffset <> 0) or (YOffset <> 0) then
  begin
    AdjustDrawPos; // adjust DrawX/DrawY for ScrollWindowEx
    Flags := 0;
    if Smooth then
      Flags := Flags or SW_SMOOTHSCROLL or (150 shl 16);
    ScrollWindowEx(Handle, XOffset, YOffset, nil, nil, 0, nil, SW_INVALIDATE or Flags);
    UpdateWindow(Handle);
    Result := True;
  end
  else
    Result := False;
end;

function TPdfControl.ScrollContentTo(X, Y: Integer; Smooth: Boolean = False): Boolean;
var
  ScrollInfo: TScrollInfo;
  XOffset, YOffset: Integer;
begin
  XOffset := 0;
  YOffset := 0;
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_POS;
  if GetScrollInfo(Handle, SB_HORZ, ScrollInfo) then
    XOffset := X - ScrollInfo.nPos;
  if GetScrollInfo(Handle, SB_VERT, ScrollInfo) then
    YOffset := Y - ScrollInfo.nPos;
  Result := ScrollContent(XOffset, YOffset, Smooth);
end;

procedure TPdfControl.WMVScroll(var Message: TWMVScroll);
var
  ScrollInfo: TScrollInfo;
  Offset: Integer;
begin
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_ALL;
  GetScrollInfo(Handle, SB_VERT, ScrollInfo);
  Offset := 0;
  case Message.ScrollCode of
    SB_LINEUP:
      Offset := -cDefaultScrollOffset;
    SB_LINEDOWN:
      Offset := cDefaultScrollOffset;
    SB_PAGEUP:
      Offset := -ScrollInfo.nPage;
    SB_PAGEDOWN:
      Offset := ScrollInfo.nPage;
    SB_THUMBTRACK:
      Offset := ScrollInfo.nTrackPos - ScrollInfo.nPos;
  end;
  ScrollContent(0, Offset, SmoothScroll);
  Message.Result := 0;
end;

procedure TPdfControl.WMHScroll(var Message: TWMHScroll);
var
  ScrollInfo: TScrollInfo;
  Offset: Integer;
begin
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_ALL;
  GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
  Offset := 0;
  case Message.ScrollCode of
    SB_LINELEFT:
      Offset := -cDefaultScrollOffset;
    SB_LINERIGHT:
      Offset := cDefaultScrollOffset;
    SB_PAGELEFT:
      Offset := -ScrollInfo.nPage;
    SB_PAGERIGHT:
      Offset := ScrollInfo.nPage;
    SB_THUMBTRACK:
      Offset := ScrollInfo.nTrackPos - ScrollInfo.nPos;
  end;
  ScrollContent(Offset, 0, SmoothScroll);
  Message.Result := 0;
end;

function TPdfControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  PagePt: TPdfPoint;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);

  if not Result then
  begin
    if IsPageValid and AllowFormEvents then
    begin
      PagePt := DeviceToPage(MousePos.X, MousePos.Y);
      if CurrentPage.FormEventMouseWheel(Shift, WheelDelta, PagePt.X, PagePt.Y) then
        Exit;
    end;

    if ssCtrl in Shift then
    begin
      if ScaleMode = smZoom then
      begin
        ZoomPercentage := ZoomPercentage + (WheelDelta div WHEEL_DELTA) * 5;
        Result := True;
      end;
    end
    else
    begin
      if ssShift in Shift then
        Result := ScrollContent(-WheelDelta, 0, SmoothScroll)
      else
        Result := ScrollContent(0, -WheelDelta, SmoothScroll);

      if not Result and FChangePageOnMouseScrolling then
      begin
        if WheelDelta < 0 then
          GotoNextPage()
        else if PageIndex > 0 then
        begin
          GotoPrevPage();
          ScrollContentTo(0, MaxInt);
        end;
      end
      else
        Result := True;
    end;
  end;
end;

procedure TPdfControl.WMTimer(var Message: TWMTimer);
var
  XOffset, YOffset: Integer;
begin
  case Message.TimerID of
    cScrollTimerId:
      begin
        if FMousePressed and FScrollTimerActive then
        begin
          XOffset := 0;
          YOffset := 0;
          if FScrollMousePos.X < 0 then
            XOffset := -cDefaultScrollOffset
          else if FScrollMousePos.X >= Width then
            XOffset := cDefaultScrollOffset
          else if FScrollMousePos.Y < 0 then
            YOffset := -cDefaultScrollOffset
          else if FScrollMousePos.Y >= Height then
            YOffset := cDefaultScrollOffset;
          ScrollContent(XOffset, YOffset, SmoothScroll);
        end
        else
          StopScrollTimer;
      end;

    cTrippleClickTimerId:
      begin
        FCheckForTrippleClick := False;
        KillTimer(Handle, cTrippleClickTimerId);
      end;
  else
    inherited;
  end;
end;

procedure TPdfControl.StopScrollTimer;
begin
  if FScrollTimerActive then
  begin
    KillTimer(Handle, cScrollTimerId);
    FScrollTimerActive := False;
  end;
end;

procedure TPdfControl.HightlightText(const SearchText: string; MatchCase, MatchWholeWord: Boolean);
begin
  FHighlightText := SearchText;
  FHighlightMatchCase := MatchCase;
  FHighlightMatchWholeWord := MatchWholeWord;
  CalcHighlightTextRects;
end;

procedure TPdfControl.CalcHighlightTextRects;
var
  OldHighlightTextRects: TPdfControlPdfRectArray;
  Page: TPdfPage;
  CharIndex, CharCount, I, Count: Integer;
  Num: Integer;
begin
  OldHighlightTextRects := FHighlightTextRects;
  FHighlightTextRects := nil;
  if (FHighlightText <> '') and IsPageValid then
  begin
    Page := CurrentPage;
    Num := 0;
    if Page.BeginFind(FHighlightText, FHighlightMatchCase, FHighlightMatchWholeWord, False) then
    begin
      try
        while Page.FindNext(CharIndex, CharCount) do
        begin
          Count := Page.GetTextRectCount(CharIndex, CharCount);
          if Num + Count > Length(FHighlightTextRects) then
            SetLength(FHighlightTextRects, (Num + Count) * 2);
          for I := 0 to Count - 1 do
          begin
            FHighlightTextRects[Num] := Page.GetTextRect(I);
            Inc(Num);
          end;
        end;
      finally
        Page.EndFind;
      end;
    end;

    // truncate to the actual number
    if Num <> Length(FHighlightTextRects) then
      SetLength(FHighlightTextRects, Num);
  end;
  InvalidatePdfRectDiffs(OldHighlightTextRects, FHighlightTextRects);
end;

procedure TPdfControl.ClearHighlightText;
begin
  FHighlightText := '';
  InvalidatePdfRectDiffs(FHighlightTextRects, nil);
  FHighlightTextRects := nil;
end;

procedure TPdfControl.FormInvalidate(Document: TPdfDocument; Page: TPdfPage;
  const PageRect: TPdfRect);
var
  R: TRect;
begin
  FRenderedPageIndex := -1; // content has changed => render into the background bitmap
  FFormOutputSelectedRects := nil;
  if HandleAllocated then
  begin
    R := InternPageToDevice(Page, PageRect);
    InvalidateRect(Handle, @R, True);
  end;
end;

procedure TPdfControl.FormOutputSelectedRect(Document: TPdfDocument; Page: TPdfPage;
  const PageRect: TPdfRect);
begin
  if HandleAllocated then
  begin
    SetLength(FFormOutputSelectedRects, Length(FFormOutputSelectedRects) + 1);
    FFormOutputSelectedRects[Length(FFormOutputSelectedRects) - 1] := PageRect;
  end;
end;

procedure TPdfControl.FormGetCurrentPage(Document: TPdfDocument; var Page: TPdfPage);
begin
  Page := CurrentPage;
end;

procedure TPdfControl.FormFieldFocus(Document: TPdfDocument; Value: PWideChar;
  ValueLen: Integer; FieldFocused: Boolean);
begin
  ClearSelection;
  FFormFieldFocused := FieldFocused;
end;

procedure TPdfControl.ExecuteNamedAction(Document: TPdfDocument; NamedAction: TPdfNamedActionType);
begin
  case NamedAction of
    naPrint:
      PrintDocument;
    naNextPage:
      PageIndex := PageIndex + 1;
    naPrevPage:
      PageIndex := PageIndex - 1;
    naFirstPage:
      PageIndex := 0;
    naLastPage:
      PageIndex := Document.PageCount - 1;
  end;
end;

end.

