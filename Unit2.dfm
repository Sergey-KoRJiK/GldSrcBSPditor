object FaceToolForm: TFaceToolForm
  Left = 1185
  Top = 218
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Face Tool'
  ClientHeight = 324
  ClientWidth = 212
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
    Top = 240
    Width = 209
    Height = 57
    Caption = ' Save\Load Lightmaps '
    Columns = 2
    TabOrder = 1
  end
  object ButtonSaveLmp: TButton
    Left = 1
    Top = 296
    Width = 104
    Height = 25
    Caption = 'Save'
    TabOrder = 2
    OnClick = ButtonSaveLmpClick
  end
  object ButtonLoadLmp: TButton
    Left = 105
    Top = 296
    Width = 104
    Height = 25
    Caption = 'Load'
    TabOrder = 3
    OnClick = ButtonLoadLmpClick
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
