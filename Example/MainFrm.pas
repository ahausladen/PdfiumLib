unit MainFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PdfiumCore, Vcl.ExtCtrls, Vcl.StdCtrls, PdfiumCtrl,
  Vcl.Samples.Spin;

type
  TfrmMain = class(TForm)
    btnPrev: TButton;
    btnNext: TButton;
    btnCopy: TButton;
    btnScale: TButton;
    chkLCDOptimize: TCheckBox;
    chkSmoothScroll: TCheckBox;
    edtZoom: TSpinEdit;
    btnPrint: TButton;
    PrintDialog1: TPrintDialog;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnScaleClick(Sender: TObject);
    procedure chkLCDOptimizeClick(Sender: TObject);
    procedure chkSmoothScrollClick(Sender: TObject);
    procedure edtZoomChange(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    { Private-Deklarationen }
    FCtrl: TPdfControl;
    procedure WebLinkClick(Sender: TObject; Url: string);
  public
    { Public-Deklarationen }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.TypInfo, Vcl.Printers;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  {$IFDEF CPUX64}
  PDFiumDllDir := ExtractFilePath(ParamStr(0)) + 'x64';
  {$ELSE}
  PDFiumDllDir := ExtractFilePath(ParamStr(0)) + 'x86';
  {$ENDIF CPUX64}

  FCtrl := TPdfControl.Create(Self);
  FCtrl.Align := alClient;
  FCtrl.Parent := Self;
  FCtrl.SendToBack; // put the control behind the buttons
  FCtrl.Color := clGray;
  FCtrl.ScaleMode := smFitWidth;
  FCtrl.PageColor := RGB(255, 255, 200);
  FCtrl.OnWebLinkClick := WebLinkClick;

  edtZoom.Value := FCtrl.ZoomPercentage;

  if FileExists(ParamStr(1)) then
    FCtrl.LoadFromFile(ParamStr(1))
  else if OpenDialog1.Execute(Handle) then
    FCtrl.LoadFromFile(OpenDialog1.FileName)
  else
  begin
    Application.ShowMainForm := False;
    Application.Terminate;
  end;
end;

procedure TfrmMain.btnPrevClick(Sender: TObject);
begin
  FCtrl.GotoPrevPage;
end;

procedure TfrmMain.btnNextClick(Sender: TObject);
begin
  FCtrl.GotoNextPage;
end;

procedure TfrmMain.btnCopyClick(Sender: TObject);
begin
  FCtrl.HightlightText('Delphi 2010', False, False);
end;

procedure TfrmMain.btnScaleClick(Sender: TObject);
begin
  if FCtrl.ScaleMode = High(FCtrl.ScaleMode) then
    FCtrl.ScaleMode := Low(FCtrl.ScaleMode)
  else
    FCtrl.ScaleMode := Succ(FCtrl.ScaleMode);
  Caption := GetEnumName(TypeInfo(TPdfControlScaleMode), Ord(FCtrl.ScaleMode));
end;

procedure TfrmMain.WebLinkClick(Sender: TObject; Url: string);
begin
  ShowMessage(Url);
end;

procedure TfrmMain.chkLCDOptimizeClick(Sender: TObject);
begin
  if chkLCDOptimize.Checked then
    FCtrl.DrawOptions := FCtrl.DrawOptions + [proLCDOptimized]
  else
    FCtrl.DrawOptions := FCtrl.DrawOptions - [proLCDOptimized];
end;

procedure TfrmMain.chkSmoothScrollClick(Sender: TObject);
begin
  FCtrl.SmoothScroll := chkSmoothScroll.Checked;
end;

procedure TfrmMain.edtZoomChange(Sender: TObject);
begin
  FCtrl.ZoomPercentage := edtZoom.Value;
end;

procedure TfrmMain.btnPrintClick(Sender: TObject);
begin
  if PrintDialog1.Execute(Handle) then
  begin
    Printer.BeginDoc;
    try
      FCtrl.CurrentPage.Draw(Printer.Canvas.Handle, 0, 0, Printer.PageWidth, Printer.PageHeight, prNormal, [proAnnotations, proPrinting]);
    finally
      Printer.EndDoc;
    end;
  end;
end;

end.
