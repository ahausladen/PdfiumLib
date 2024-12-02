program PdfiumLibExample;

{$IFDEF FPC}
  {$MODE DelphiUnicode}
{$ENDIF FPC}

uses
{$IFDEF UNIX}
  cthreads,
{$ENDIF}
  Interfaces, Forms,
  MainFrm32 in 'MainFrm32.pas' {frmMain},
  PdfiumCore in '..\Source\PdfiumCore.pas',
  PdfiumCtrl32 in '..\Source\PdfiumCtrl32.pas',
  PdfiumLib in '..\Source\PdfiumLib.pas';

//{$R *.res}

begin
  Application.Initialize;
//  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
