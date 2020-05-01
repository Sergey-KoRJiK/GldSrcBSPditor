object FaceToolForm: TFaceToolForm
  Left = 1134
  Top = 269
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Face Tool'
  ClientHeight = 390
  ClientWidth = 209
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MemoFaceInfo: TMemo
    Left = 0
    Top = 0
    Width = 209
    Height = 233
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Lucida Sans Typewriter'
    Font.Style = []
    Lines.Strings = (
      'Face Info:')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object RadioGroupLmp: TRadioGroup
    Left = 0
    Top = 312
    Width = 209
    Height = 57
    Caption = ' Save\Load Lightmaps '
    Columns = 2
    TabOrder = 1
  end
  object ButtonSaveLmp: TButton
    Left = 1
    Top = 368
    Width = 104
    Height = 22
    Caption = 'Save'
    TabOrder = 2
    OnClick = ButtonSaveLmpClick
  end
  object ButtonLoadLmp: TButton
    Left = 105
    Top = 368
    Width = 104
    Height = 22
    Caption = 'Load'
    TabOrder = 3
    OnClick = ButtonLoadLmpClick
  end
  object ButtonDelFull: TButton
    Left = 1
    Top = 232
    Width = 104
    Height = 20
    Caption = 'Delete Lightmap'
    Enabled = False
    TabOrder = 4
    OnClick = ButtonDelFullClick
  end
  object ButtonDel1: TButton
    Left = 1
    Top = 251
    Width = 104
    Height = 20
    Caption = 'Delete Style 1'
    Enabled = False
    TabOrder = 5
    OnClick = ButtonDel1Click
  end
  object ButtonDel2: TButton
    Left = 1
    Top = 270
    Width = 104
    Height = 20
    Caption = 'Delete Style 2'
    Enabled = False
    TabOrder = 6
    OnClick = ButtonDel2Click
  end
  object ButtonDel3: TButton
    Left = 1
    Top = 289
    Width = 104
    Height = 20
    Caption = 'Delete Style 3'
    Enabled = False
    TabOrder = 7
    OnClick = ButtonDel3Click
  end
  object ButtonCreateMain: TButton
    Left = 105
    Top = 232
    Width = 104
    Height = 20
    Caption = 'Create Lightmap'
    Enabled = False
    TabOrder = 8
    OnClick = ButtonCreateMainClick
  end
  object ButtonNew1: TButton
    Left = 105
    Top = 251
    Width = 104
    Height = 20
    Caption = 'Create Style 1'
    Enabled = False
    TabOrder = 9
  end
  object ButtonNew2: TButton
    Left = 105
    Top = 270
    Width = 104
    Height = 20
    Caption = 'Create Style 2'
    Enabled = False
    TabOrder = 10
  end
  object ButtonNew3: TButton
    Left = 105
    Top = 289
    Width = 104
    Height = 20
    Caption = 'Create Style 3'
    Enabled = False
    TabOrder = 11
  end
  object OpenDialogBMP: TOpenDialog
    Filter = 'Bitmap 24-bit|*.bmp'
    Left = 64
    Top = 8
  end
  object SaveDialogBMP: TSaveDialog
    Filter = 'Bitmap 24-bit|*.bmp'
    Left = 96
    Top = 8
  end
end
