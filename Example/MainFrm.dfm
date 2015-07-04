object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'PDFium Test'
  ClientHeight = 647
  ClientWidth = 655
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnPrev: TButton
    Left = 0
    Top = 0
    Width = 75
    Height = 25
    Caption = '<'
    TabOrder = 0
    OnClick = btnPrevClick
  end
  object btnNext: TButton
    Left = 72
    Top = 0
    Width = 75
    Height = 25
    Caption = '>'
    TabOrder = 1
    OnClick = btnNextClick
  end
  object btnCopy: TButton
    Left = 153
    Top = 0
    Width = 75
    Height = 25
    Caption = 'Highlight'
    TabOrder = 2
    OnClick = btnCopyClick
  end
  object btnScale: TButton
    Left = 225
    Top = 0
    Width = 75
    Height = 25
    Caption = 'Scale'
    TabOrder = 3
    OnClick = btnScaleClick
  end
  object chkLCDOptimize: TCheckBox
    Left = 378
    Top = 4
    Width = 79
    Height = 17
    Caption = 'LCDOptimize'
    TabOrder = 4
    OnClick = chkLCDOptimizeClick
  end
  object chkSmoothScroll: TCheckBox
    Left = 458
    Top = 4
    Width = 87
    Height = 17
    Caption = 'SmoothScroll'
    TabOrder = 5
    OnClick = chkSmoothScrollClick
  end
  object edtZoom: TSpinEdit
    Left = 544
    Top = 2
    Width = 49
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 6
    Value = 100
    OnChange = edtZoomChange
  end
  object btnPrint: TButton
    Left = 297
    Top = 0
    Width = 75
    Height = 25
    Caption = 'Print'
    TabOrder = 7
    OnClick = btnPrintClick
  end
  object PrintDialog1: TPrintDialog
    Left = 96
    Top = 32
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'pdf'
    Filter = 'PDF file (*.pdf)|*.pdf'
    Title = 'Open PDF file'
    Left = 32
    Top = 32
  end
end
