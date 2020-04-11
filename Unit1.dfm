object MainForm: TMainForm
  Left = 380
  Top = 215
  Width = 752
  Height = 533
  Caption = 'MainForm'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Calibri'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 455
    Width = 736
    Height = 19
    Panels = <
      item
        Text = 'Pos: (X Y Z)'
        Width = 155
      end
      item
        Text = 'Camera Leaf id:'
        Width = 120
      end
      item
        Text = 'Style page (0..3): 0'
        Width = 110
      end>
  end
  object MainMenu1: TMainMenu
    Left = 8
    Top = 8
    object FileMenu: TMenuItem
      Caption = 'File'
      object LoadMapMenu: TMenuItem
        Caption = 'Load Map'
        OnClick = LoadMapMenuClick
      end
      object CloseMapMenu: TMenuItem
        Caption = 'Close Map'
        Enabled = False
        OnClick = CloseMapMenuClick
      end
      object SaveMapMenu: TMenuItem
        Caption = 'Save Map'
        Enabled = False
        OnClick = SaveMapMenuClick
      end
      object LineSplitFileMenu: TMenuItem
        Caption = '-'
      end
      object SaveallLightmapsMenu: TMenuItem
        Caption = 'Save all Lightmaps'
        Enabled = False
        OnClick = SaveallLightmapsMenuClick
      end
      object LoadallLightmapsMenu: TMenuItem
        Caption = 'Load all Lightmaps'
        Enabled = False
        OnClick = LoadallLightmapsMenuClick
      end
    end
    object OptionsMenu: TMenuItem
      Caption = 'Options'
      object ResetCameraMenu: TMenuItem
        Caption = 'Reset Camera'
        OnClick = ResetCameraMenuClick
      end
      object LineSplitOptionsMenu: TMenuItem
        Caption = '-'
      end
      object ShowHeader1: TMenuItem
        Caption = 'Show Header'
        OnClick = ShowHeader1Click
      end
      object WireframeWorldBrushesMenu: TMenuItem
        Caption = 'Wireframe WorldBrushes'
        OnClick = WireframeWorldBrushesMenuClick
      end
      object WireframeEntBrushesMenu: TMenuItem
        Caption = 'Wireframe EntBrushes'
        OnClick = WireframeEntBrushesMenuClick
      end
      object ShowWorldBrushesMenu: TMenuItem
        Caption = 'Render WorldBrushes'
        Checked = True
        OnClick = ShowWorldBrushesMenuClick
      end
      object ShowEntBrushesMenu: TMenuItem
        Caption = 'Render EntBrushes'
        Checked = True
        OnClick = ShowEntBrushesMenuClick
      end
      object WallhackRenderModeMenu: TMenuItem
        Caption = 'Wallhack Render mode'
        OnClick = WallhackRenderModeMenuClick
      end
      object PixelModeMenu: TMenuItem
        Caption = 'Quad pixel Render mode'
        OnClick = PixelModeMenuClick
      end
      object SetSelectedFaceColor1: TMenuItem
        Caption = 'Set Selected Face Color'
        OnClick = SetSelectedFaceColor1Click
      end
      object NoPVSMenu: TMenuItem
        Caption = 'Render without PVS'
        OnClick = NoPVSMenuClick
      end
      object RenderBBOXVisLeaf1: TMenuItem
        Caption = 'Render BBOX VisLeaf'
        Checked = True
        OnClick = RenderBBOXVisLeaf1Click
      end
    end
    object ToolBarMenu: TMenuItem
      Caption = 'Tools'
      object ToolFaceMenu: TMenuItem
        Caption = 'Face Tool'
        OnClick = ToolFaceMenuClick
      end
    end
    object HelpMenu: TMenuItem
      Caption = 'Help'
      OnClick = HelpMenuClick
    end
    object AboutMenu: TMenuItem
      Caption = 'About'
      OnClick = AboutMenuClick
    end
  end
  object OpenDialogBsp: TOpenDialog
    Filter = 'Gold Src Bsp v30|*.bsp'
    Left = 40
    Top = 8
  end
  object SaveDialogBsp: TSaveDialog
    Filter = 'Gold Src Bsp v30|*.bsp'
    Left = 72
    Top = 8
  end
  object ColorDialog: TColorDialog
    Left = 104
    Top = 8
  end
  object OpenDialogBMP: TOpenDialog
    Filter = 'Bitmap 24-bit|*.bmp'
    Left = 40
    Top = 40
  end
  object SaveDialogBMP: TSaveDialog
    Filter = 'Bitmap 24-bit|*.bmp'
    Left = 72
    Top = 40
  end
end
