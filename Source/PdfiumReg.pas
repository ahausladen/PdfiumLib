unit PdfiumReg;

interface

procedure Register;

implementation

uses
  Classes,
  PdfiumCtrl;

procedure Register;
begin
    RegisterComponents('PdfiumLib', [TPdfControl] );
end;


end.
