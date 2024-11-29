unit PdfiumCtrl32;

interface

uses
  Classes, Graphics,
  //
  GR32_Image,
  PdfiumCore;

const
  cPdfControlDefaultDrawOptions = [proAnnotations];

type
  TPdfControlScaleMode = (
    smFitAuto,
    smFitWidth,
    smFitHeight,
    smZoom
  );
  
  TPdfControl32 = class(TCustomImgView32)
  private
    FDocument: TPdfDocument;
    FScaleMode: TPdfControlScaleMode;
    FRotation: TPdfPageRotation;
    FZoomPercentage: word;

    FPageColor: TColor;
    FPageBorderColor: TColor;
    FPageShadowColor: TColor;
    FPageShadowSize: integer;
    FPageShadowPadding: integer;

    FPageIndex: word;

    FIsPageRenderingNeeded: boolean;
    FIsPageFrameRenderingNeeded: boolean;

    FDrawWidth: integer;
    FDrawHeight: integer;
    FPageDrawX: integer;
    FPageDrawY: integer;
    FPageDrawWidth: integer;
    FPageDrawHeight: integer;

    FDrawOptions: TPdfPageRenderOptions;

    FOnPrintDocument: TNotifyEvent;

    procedure FSetScaleMode(const Value: TPdfControlScaleMode); reintroduce;
    procedure FSetRotation(const Value: TPdfPageRotation);
    procedure FSetZoomPercentage(Value: word);

    procedure FSetPageColor(const Value: TColor);
    procedure FSetPageBorderColor(const Value: TColor);
    procedure FSetPageShadowColor(const Value: TColor);
    procedure FSetPageShadowSize(const Value: integer);
    procedure FSetPageShadowPadding(const Value: integer);
    procedure FSetDrawOptions(const Value: TPdfPageRenderOptions);

    procedure FSetPageIndex(Value: word);
    function FGetPageCount: word;
    function FGetCurrentPage: TPdfPage;
    function FIsPageValid: boolean;

    procedure FInitDocument;
    procedure FOnDocumentLoaded;
    procedure FOnPageContentChanged(Closing: boolean);
    procedure FPageLayoutChanged;
    procedure FUpdatePageDrawInfo;
    function FHasPageShadow: boolean;
    function FHasPageBorder: boolean;
    procedure FRenderPage;
    procedure FRenderPageFrame;

    procedure FOnFormInvalidate(Document: TPdfDocument; Page: TPdfPage; const PageRect: TPdfRect);

  protected
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Resize; override;

    { InvalidatePage forces the page to be rendered again and invalidates the control. }
    procedure InvalidatePage;

    { PrintDocument uses OnPrintDocument to print. If OnPrintDocument is not assigned it does nothing. }
    procedure PrintDocument;

    procedure LoadFromFile(
      const FileName: string; const Password: UTF8String = '';
      LoadOption: TPdfDocumentLoadOption = dloDefault);

    function GotoNextPage: boolean;
    function GotoPrevPage: boolean;

    procedure Close;

    property PageIndex: word read FPageIndex write FSetPageIndex;
    property PageCount: word read FGetPageCount;
    property CurrentPage: TPdfPage read FGetCurrentPage;

  published
    property Document: TPdfDocument read FDocument;
    property ScaleMode: TPdfControlScaleMode read FScaleMode write FSetScaleMode default smFitAuto;
    property Rotation: TPdfPageRotation read FRotation write FSetRotation default prNormal;
    property ZoomPercentage: word read FZoomPercentage write FSetZoomPercentage default 100;

    property PageColor: TColor read FPageColor write FSetPageColor default clWhite;
    property PageBorderColor: TColor read FPageBorderColor write FSetPageBorderColor default clNone;
    property PageShadowColor: TColor read FPageShadowColor write FSetPageShadowColor default clNone;
    property PageShadowSize: integer read FPageShadowSize write FSetPageShadowSize default 4;
    property PageShadowPadding: integer read FPageShadowPadding write FSetPageShadowPadding default 44;

    property DrawOptions: TPdfPageRenderOptions read FDrawOptions write FSetDrawOptions default cPdfControlDefaultDrawOptions;

    property Color default clGray;

    { OnPrintDocument is called from PrintDocument }
    property OnPrintDocument: TNotifyEvent read FOnPrintDocument write FOnPrintDocument;
  end;

implementation

uses
  LCLType, LCLIntf;

////////////////////////////////////////////////////////////////////////////////
// TPdfControl32

constructor TPdfControl32.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FScaleMode := smFitAuto;
  FZoomPercentage := 100;
  FPageColor := clWhite;
  FRotation := prNormal;

  FPageBorderColor := clNone;
  FPageShadowColor := clNone;
  FPageShadowSize := 4;
  FPageShadowPadding := 44;

  FDrawOptions := cPdfControlDefaultDrawOptions;

  ParentColor := false;
  Color := clGray;

  TabStop := true;

  FDocument := TPdfDocument.Create;
  FInitDocument;
end;


destructor TPdfControl32.Destroy;
begin
  //
end;


procedure TPdfControl32.FSetScaleMode(const Value: TPdfControlScaleMode);
begin
  if (Value <> FScaleMode) then
  begin
    FScaleMode := Value;
    FPageLayoutChanged;
  end;
end;


procedure TPdfControl32.FSetRotation(const Value: TPdfPageRotation);
begin
  if (Value <> FRotation) then
  begin
    FRotation := Value;
    FPageLayoutChanged;
  end;
end;


procedure TPdfControl32.FSetZoomPercentage(Value: word);
begin
  if (Value < 1) then
    Value := 1
  else if (Value > 1000) then
    Value := 1000;

  if (Value <> FZoomPercentage) then
  begin
    FZoomPercentage := Value;
    FPageLayoutChanged;
  end;
end;


procedure TPdfControl32.FSetPageColor(const Value: TColor);
begin
  if (Value <> FPageColor) then
  begin
    FPageColor := Value;
    InvalidatePage;
  end;
end;

procedure TPdfControl32.FSetPageBorderColor(const Value: TColor);
begin
  if (Value <> FPageBorderColor) then
  begin
    FPageBorderColor := Value;
    InvalidatePage;
  end;
end;


procedure TPdfControl32.FSetPageShadowColor(const Value: TColor);
begin
  if (Value <> FPageShadowColor) then
  begin
    FPageShadowColor := Value;
    InvalidatePage;
  end;
end;


procedure TPdfControl32.FSetPageShadowSize(const Value: integer);
begin
  if (Value <> FPageShadowSize) then
  begin
    FPageShadowSize := Value;
    InvalidatePage;
  end;
end;


procedure TPdfControl32.FSetPageShadowPadding(const Value: integer);
begin
  if (Value <> FPageShadowPadding) then
  begin
    FPageShadowPadding := Value;
    InvalidatePage;
  end;
end;


procedure TPdfControl32.FSetPageIndex(Value: word);
begin
  if (Value >= PageCount) then
    Value := PageCount - 1;

  if (Value = FPageIndex) then
    exit;

  // Close the previous page to keep memory usage low (especially for large PDF files)
  if ((FPageIndex < PageCount) and FDocument.IsPageLoaded(FPageIndex) and
     not FDocument.Pages[FPageIndex].Annotations.AnnotationsLoaded) then
  begin
    // TODO: check if this issue was fixed in Pdf library
    FDocument.Pages[FPageIndex].Close;
  end;
  FPageIndex := Value;

  // TODO: PageContentChanged(false);
end;


procedure TPdfControl32.FSetDrawOptions(const Value: TPdfPageRenderOptions);
begin
  if (Value <> FDrawOptions) then
  begin
    FDrawOptions := Value;
    InvalidatePage;
  end;
end;

function TPdfControl32.FGetPageCount: word;
begin
  Result := FDocument.PageCount;
end;


function TPdfControl32.FGetCurrentPage: TPdfPage;
begin
  if (FIsPageValid) then
    Result := FDocument.Pages[PageIndex]
  else
    Result := nil;
end;


function TPdfControl32.FIsPageValid: boolean;
begin
  Result := (FDocument.Active and (PageIndex < PageCount));
end;


procedure TPdfControl32.FInitDocument;
begin
  FDocument.OnFormInvalidate := FOnFormInvalidate;
//  FDocument.OnFormOutputSelectedRect := FDoFormOutputSelectedRect;
//  FDocument.OnFormGetCurrentPage := FDoFormGetCurrentPage;
//  FDocument.OnFormFieldFocus := FDoFormFieldFocus;
//  FDocument.OnExecuteNamedAction := FDoExecuteNamedAction;
end;


procedure TPdfControl32.FOnFormInvalidate(Document: TPdfDocument; Page: TPdfPage; const PageRect: TPdfRect);
begin
  WriteLn('// TODO: FOnFormInvalidate()');
end;


procedure TPdfControl32.InvalidatePage;
begin
  // TODO:
end;

procedure TPdfControl32.LoadFromFile(
  const FileName: string; const Password: UTF8String = '';
  LoadOption: TPdfDocumentLoadOption = dloDefault);
begin
  try
    FDocument.LoadFromFile(FileName, Password, LoadOption);
  finally
    FOnDocumentLoaded;
  end;
end;


procedure TPdfControl32.FOnDocumentLoaded;
begin
  FPageIndex := 0;
  FOnPageContentChanged(false);
end;


procedure TPdfControl32.FOnPageContentChanged(Closing: boolean);
begin
  { // TODO:
    FSelStartCharIndex := 0;
    FSelStopCharIndex := 0;
    FSelectionActive := False;
    CalcHighlightTextRects;
    GetPageWebLinks;
  }
  FPageLayoutChanged;
  if (not Closing) then
    // TODO: PageChange
    ;
end;


function TPdfControl32.GotoNextPage: boolean;
begin
  Result := (PageIndex < PageCount - 1);
  if (Result) then
    PageIndex := PageIndex + 1;
end;


function TPdfControl32.GotoPrevPage: boolean;
begin
  Result := (PageIndex > 0);
  if (Result) then
    PageIndex := PageIndex - 1;
end;


procedure TPdfControl32.PrintDocument;
begin
  if (Document.Active) then
  begin
    if (Assigned(FOnPrintDocument)) then
      FOnPrintDocument(Self)
    else
      // TODO: TPdfDocumentVclPrinter.PrintDocument(Document, ExtractFileName(Document.FileName))
      ;
  end;
end;


procedure TPdfControl32.FPageLayoutChanged;
begin
  FUpdatePageDrawInfo;
  FIsPageRenderingNeeded := true;
  Invalidate;
end;


procedure TPdfControl32.FUpdatePageDrawInfo;
var
  page: TPdfPage;
  pageWidth, pageHeight: double;
  DpiX, DpiY: Integer;
  maxWidth, maxHeight: integer;

  procedure NGetWidthHeight(out W, H: integer);
  begin
    case ScaleMode of
      smFitAuto:
        begin
          W := Round(MaxHeight * (PageWidth / PageHeight));
          H := MaxHeight;
          if (W > MaxWidth) then
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
  end;

begin
  page := CurrentPage;
  if ((page = nil) or (page.Width <= 0) or (page.Height <= 0)) then
    exit;

  // Take "Rotation" into account
  if (Rotation in [prNormal, pr180]) then
  begin
    pageWidth := page.Width;
    pageHeight := page.Height;
    dpiX := GetDeviceCaps(Bitmap.Handle, LOGPIXELSX);
    dpiY := GetDeviceCaps(Bitmap.Handle, LOGPIXELSY);
  end
  else
  begin
    pageHeight := page.Width;
    pageWidth := page.Height;
    dpiY := GetDeviceCaps(Bitmap.Handle, LOGPIXELSX);
    dpiX := GetDeviceCaps(Bitmap.Handle, LOGPIXELSY);
  end;

  maxWidth := Width;
  maxHeight := Height;

  NGetWidthHeight(FDrawWidth, FDrawHeight);

  if (FHasPageShadow) then
  begin
    FPageDrawX := PageShadowPadding div 2;
    FPageDrawY := PageShadowPadding div 2;
    FPageDrawWidth := FDrawWidth - (PageShadowPadding + PageShadowSize);
    FPageDrawHeight := FDrawHeight - (PageShadowPadding + PageShadowSize);
  end
  else
  begin
    FPageDrawX := 0;
    FPageDrawY := 0;
    FPageDrawWidth := FDrawWidth;
    FPageDrawHeight := FDrawHeight;
  end;
end;


function TPdfControl32.FHasPageShadow: boolean;
begin
  Result := ((PageShadowColor <> clNone) and (PageShadowSize > 0) and (PageShadowPadding > 0));
end;


function TPdfControl32.FHasPageBorder: boolean;
begin
  Result := (PageBorderColor <> clNone);
end;


procedure TPdfControl32.Resize;
begin
  FUpdatePageDrawInfo;
  FIsPageRenderingNeeded := true;

  inherited;
end;


procedure TPdfControl32.Paint;
begin
  if (FIsPageRenderingNeeded) then
  begin
    FIsPageRenderingNeeded := false;
    FRenderPage;
    FIsPageFrameRenderingNeeded := true;
  end;

  if (FIsPageFrameRenderingNeeded) then
  begin
    FIsPageFrameRenderingNeeded := false;
    FRenderPageFrame;
  end;

  inherited;
end;


procedure TPdfControl32.FRenderPage;
var
  color: TColor;
  colorRef: TColorRef;
  pdfBitmap: TPdfBitmap;
begin
  Bitmap.SetSize(FDrawWidth, FDrawHeight);

  if (not FIsPageValid) then
  begin
    Bitmap.Clear(Brush.Color);
    exit;
  end;

  if (PageColor = clDefault) then
    color := self.Color
  else
    color := PageColor;

  colorRef := ColorToRGB(color);

  // Page.Draw doesn't paint the background if proPrinting is enabled.
  if (proPrinting in FDrawOptions) then
    Bitmap.Clear(color);

  pdfBitmap := TPdfBitmap.Create(FDrawWidth, FDrawHeight, bfBGRx, Bitmap.Bits, 4 * Bitmap.Width);
  try
    CurrentPage.Draw(
      pdfBitmap,
      FPageDrawX, FPageDrawY, FPageDrawWidth, FPageDrawHeight,
      Rotation, FDrawOptions,
      colorRef);
  finally
    pdfBitmap.Free;
  end;

  // Draw borders
  Bitmap.FillRectS(0, 0, FDrawWidth, FPageDrawY, Brush.Color); // top bar
  Bitmap.FillRectS(0, FPageDrawY, FPageDrawX, FPageDrawY + FPageDrawHeight, Brush.Color); // left bar
  Bitmap.FillRectS(
    FPageDrawX + FPageDrawWidth, FPageDrawY, FDrawWidth, FPageDrawY + FPageDrawHeight,
    Brush.Color); // right bar
  Bitmap.FillRectS(0, FPageDrawY + FPageDrawHeight, FDrawWidth, FDrawHeight, Brush.Color); // bottom bar
end;


procedure TPdfControl32.FRenderPageFrame;
begin
  // Draw page border
  if (FHasPageBorder) then
  begin
    Bitmap.FillRectS (
      FPageDrawX, FPageDrawY, FPageDrawX + FPageDrawWidth, FPageDrawY + 1,
      PageBorderColor);
    Bitmap.FillRectS(
      FPageDrawX, FPageDrawY, FPageDrawX + 1, FPageDrawY + FPageDrawHeight,
      PageBorderColor);
    Bitmap.FillRectS(
      FPageDrawX + FPageDrawWidth - 1, FPageDrawY,
      FPageDrawX + FPageDrawWidth, FPageDrawY + FPageDrawHeight,
      PageBorderColor);
    Bitmap.FillRectS(
      FPageDrawX, FPageDrawY + FPageDrawHeight - 1,
      FPageDrawX + FPageDrawWidth, FPageDrawY + FPageDrawHeight,
      PageBorderColor);
  end;

  // Draw page shadow
  if (FHasPageShadow) then
  begin
    // right shadow
    Bitmap.FillRectS(
      FPageDrawX + FPageDrawWidth, FPageDrawY + PageShadowSize,
      FPageDrawX + FPageDrawWidth + PageShadowSize, FPageDrawY + FPageDrawHeight + PageShadowSize,
      PageShadowColor);
    // bottom shadow
    Bitmap.FillRectS(
      FPageDrawX + PageShadowSize, FPageDrawY + FPageDrawHeight,
      FPageDrawX + FPageDrawWidth + PageShadowSize, FPageDrawY + FPageDrawHeight + PageShadowSize,
      PageShadowColor);
  end;
end;


procedure TPdfControl32.Close;
begin
  FDocument.Close;
  FPageIndex := 0;
// TODO:  FFormFieldFocused := false;
  FOnPageContentChanged(true);
end;

end.
