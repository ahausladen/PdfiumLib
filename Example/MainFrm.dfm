object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'PDFium Test'
  ClientHeight = 647
  ClientWidth = 780
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ListViewAttachments: TListView
    Left = 0
    Top = 600
    Width = 780
    Height = 47
    Align = alBottom
    Columns = <>
    TabOrder = 0
    ViewStyle = vsList
    Visible = False
    OnDblClick = ListViewAttachmentsDblClick
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 0
    Width = 780
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object btnAddAnnotation: TButton
      Left = 318
      Top = 0
      Width = 50
      Height = 25
      Caption = 'Annot'
      TabOrder = 5
      OnClick = btnAddAnnotationClick
    end
    object btnHighlight: TButton
      Left = 156
      Top = 0
      Width = 56
      Height = 25
      Caption = 'Highlight'
      TabOrder = 2
      OnClick = btnHighlightClick
    end
    object btnNext: TButton
      Left = 75
      Top = 0
      Width = 75
      Height = 25
      Caption = '>'
      TabOrder = 0
      OnClick = btnNextClick
    end
    object btnPrev: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 25
      Caption = '<'
      TabOrder = 1
      OnClick = btnPrevClick
    end
    object btnPrint: TButton
      Left = 268
      Top = 0
      Width = 50
      Height = 25
      Caption = 'Print'
      TabOrder = 4
      OnClick = btnPrintClick
    end
    object btnScale: TButton
      Left = 212
      Top = 0
      Width = 56
      Height = 25
      Caption = 'Scale'
      TabOrder = 3
      OnClick = btnScaleClick
    end
    object chkChangePageOnMouseScrolling: TCheckBox
      Left = 599
      Top = 4
      Width = 162
      Height = 17
      Caption = 'ChangePageOnMouseScrolling'
      TabOrder = 9
      OnClick = chkChangePageOnMouseScrollingClick
    end
    object chkLCDOptimize: TCheckBox
      Left = 378
      Top = 4
      Width = 79
      Height = 17
      Caption = 'LCDOptimize'
      TabOrder = 6
      OnClick = chkLCDOptimizeClick
    end
    object chkSmoothScroll: TCheckBox
      Left = 458
      Top = 4
      Width = 87
      Height = 17
      Caption = 'SmoothScroll'
      TabOrder = 7
      OnClick = chkSmoothScrollClick
    end
    object edtZoom: TSpinEdit
      Left = 544
      Top = 2
      Width = 49
      Height = 22
      MaxValue = 10000
      MinValue = 1
      TabOrder = 8
      Value = 100
      OnChange = edtZoomChange
    end
  end
  object PrintDialog1: TPrintDialog
    MinPage = 1
    MaxPage = 10
    Options = [poPageNums]
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
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofCreatePrompt, ofEnableSizing]
    Title = 'Save attachment'
    Left = 160
    Top = 32
  end
end
