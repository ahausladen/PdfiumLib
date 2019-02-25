unit PdfiumCtrlHelper;

interface

uses PdfiumCtrl, Winapi.Windows;

type
  TPdfControlHelper = class helper for PdfiumCtrl.TPdfControl
  public
    function CalcZoom: Integer;
  end;

  TPdfControl = class(PdfiumCtrl.TPdfControl)
  public
    function ScrollContent(XOffset, YOffset: Integer; Smooth: Boolean = False): Boolean; override;
  end;

implementation

function TPdfControlHelper.CalcZoom: Integer;
var
  DrawWidth: Integer;
begin
  with Self do
    DrawWidth := FDrawWidth; // hack - access to private
  Result := Round(DrawWidth / (CurrentPage.Width / 72 * GetDeviceCaps(Canvas.Handle, LOGPIXELSX)) * 100);
end;

function TPdfControl.ScrollContent(XOffset, YOffset: Integer; Smooth: Boolean): Boolean;
var
  ScrollInfo: TScrollInfo;
  Style: NativeInt;
begin
  inherited ScrollContent(XOffset, YOffset, Smooth);

  Style := GetWindowLong(Handle, GWL_STYLE);
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_POS or SIF_RANGE or SIF_PAGE;

  if (Style and WS_VSCROLL <> 0) and GetScrollInfo(Handle, SB_VERT, ScrollInfo) then
  begin
    if ScrollInfo.nPos = 0 then
      GotoPrevPage(True);
    if ScrollInfo.nPos >= ScrollInfo.nMax - ScrollInfo.nMin - ScrollInfo.nPage then
      GotoNextPage(True);
  end
  else
  begin
    if YOffset < 0 then
      GotoPrevPage(True);
    if YOffset > 0 then
      GotoNextPage(True);
  end;
end;

end.
