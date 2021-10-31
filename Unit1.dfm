object MainForm: TMainForm
  Left = 334
  Top = 54
  Width = 791
  Height = 644
  Caption = 'MainForm'
  Color = 2105376
  Font.Charset = ANSI_CHARSET
  Font.Color = clSilver
  Font.Height = -13
  Font.Name = 'Script'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 16
  object LabelCameraPos: TLabel
    Left = 116
    Top = 560
    Width = 205
    Height = 17
    AutoSize = False
    Caption = 'Pos: (XXX,XXX; YYY,YYY; ZZZ,ZZZ)'
  end
  object LabelCameraLeafId: TLabel
    Left = 324
    Top = 560
    Width = 141
    Height = 17
    AutoSize = False
    Caption = 'Camera in Leaf: XXXXX'
  end
  object LabelStylePage: TLabel
    Left = 464
    Top = 560
    Width = 121
    Height = 17
    AutoSize = False
    Caption = 'Style page (0..3): 0'
  end
  object LabelCameraFPS: TLabel
    Left = 4
    Top = 560
    Width = 109
    Height = 17
    AutoSize = False
    Caption = 'FPS: XXXX,X'
  end
  object PanelRT: TPanel
    Left = 0
    Top = 0
    Width = 585
    Height = 553
    BevelOuter = bvNone
    Caption = 'Panel Render Target'
    Color = clBlack
    Ctl3D = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clSilver
    Font.Height = -13
    Font.Name = 'Script'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    OnMouseDown = PanelRTMouseDown
    OnMouseMove = PanelRTMouseMove
    OnMouseUp = PanelRTMouseUp
    OnResize = PanelRTResize
  end
  object PanelFaceInfo: TPanel
    Left = 592
    Top = 0
    Width = 177
    Height = 545
    BevelOuter = bvNone
    Ctl3D = False
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 1
    object RadioGroupLmp: TRadioGroup
      Left = 0
      Top = 464
      Width = 177
      Height = 57
      Caption = ' Save\Load Lightmaps '
      Columns = 2
      Font.Charset = ANSI_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Script'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object ButtonSaveLmp: TButton
      Left = 89
      Top = 522
      Width = 88
      Height = 22
      Caption = 'Save'
      TabOrder = 1
      OnClick = ButtonSaveLmpClick
    end
    object ButtonLoadLmp: TButton
      Left = 1
      Top = 522
      Width = 88
      Height = 22
      Caption = 'Load'
      TabOrder = 2
      OnClick = ButtonLoadLmpClick
    end
    object GroupBoxFaceInfo: TGroupBox
      Left = 0
      Top = 2
      Width = 177
      Height = 121
      Caption = ' Selected Face information '
      Font.Charset = ANSI_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Script'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      object LabelFaceIndex: TStaticText
        Left = 0
        Top = 20
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Face Index'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object EditFaceIndex: TStaticText
        Left = 88
        Top = 20
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = '  No selected'
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
      end
      object LabelFaceBrushIndex: TStaticText
        Left = 0
        Top = 40
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Entity Brush '
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object EditFaceBrushIndex: TStaticText
        Left = 88
        Top = 40
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = '  No selected'
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
      end
      object LabelFacePlaneIndex: TStaticText
        Left = 0
        Top = 60
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Plane Index'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
      end
      object EditFacePlaneIndex: TStaticText
        Left = 88
        Top = 60
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = '  No selected'
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
      end
      object LabelFaceCountVertex: TStaticText
        Left = 0
        Top = 80
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Count vertex'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 6
      end
      object EditFaceCountVertex: TStaticText
        Left = 88
        Top = 80
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = '  No selected'
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 7
      end
      object LabelFaceTexInfo: TStaticText
        Left = 0
        Top = 100
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' TexInfo Index'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 8
      end
      object EditFaceTexInfo: TStaticText
        Left = 88
        Top = 100
        Width = 89
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = '  No selected'
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 9
      end
    end
    object GroupBoxTextureInfo: TGroupBox
      Left = 0
      Top = 128
      Width = 177
      Height = 221
      Caption = 'Selected Texture '
      Font.Charset = ANSI_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Script'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      object ImagePreviewBT: TImage
        Tag = 4
        Left = 24
        Top = 84
        Width = 128
        Height = 128
      end
      object LabelTexName: TStaticText
        Left = 0
        Top = 20
        Width = 49
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Name'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object EditTexName: TStaticText
        Left = 48
        Top = 20
        Width = 129
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' *** No selected ***'
        Color = clBlack
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 1
      end
      object EditTexSize: TStaticText
        Left = 48
        Top = 40
        Width = 129
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' No selected'
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
      end
      object LabelTexSize: TStaticText
        Left = 0
        Top = 40
        Width = 49
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Size'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
      object LabelTexWAD: TStaticText
        Left = 0
        Top = 60
        Width = 49
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' WAD'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
      end
      object EditTexWAD: TStaticText
        Left = 48
        Top = 60
        Width = 129
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' No selected'
        Color = clBlack
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 5
      end
    end
    object GroupBoxLightmapInfo: TGroupBox
      Left = 0
      Top = 354
      Width = 177
      Height = 101
      Caption = ' Selected Lightmap '
      Font.Charset = ANSI_CHARSET
      Font.Color = clGray
      Font.Height = -13
      Font.Name = 'Script'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      object LabelLmpSize: TStaticText
        Left = 0
        Top = 20
        Width = 49
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Size'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object EditLmpSize: TStaticText
        Left = 48
        Top = 20
        Width = 129
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' No selected'
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
      end
      object LabelLmpStyle1: TStaticText
        Left = 0
        Top = 40
        Width = 49
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Style 1'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object EditLmpStyle1: TStaticText
        Left = 48
        Top = 40
        Width = 129
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' No selected'
        Color = clBlack
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        TabOrder = 3
      end
      object LabelLmpStyle2: TStaticText
        Left = 0
        Top = 60
        Width = 49
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Style 2'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
      end
      object EditLmpStyle2: TStaticText
        Left = 48
        Top = 60
        Width = 129
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' No selected'
        Color = clBlack
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        TabOrder = 5
      end
      object EditLmpStyle3: TStaticText
        Left = 48
        Top = 80
        Width = 129
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' No selected'
        Color = clBlack
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        TabOrder = 6
      end
      object LabelLmpStyle3: TStaticText
        Left = 0
        Top = 80
        Width = 49
        Height = 20
        AutoSize = False
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = sbsSingle
        Caption = ' Style 3'
        Font.Charset = ANSI_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Script'
        Font.Style = []
        ParentFont = False
        TabOrder = 7
      end
    end
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
      object CloseMenu: TMenuItem
        Caption = 'Close'
        OnClick = CloseMenuClick
      end
    end
    object OptionsMenu: TMenuItem
      Caption = 'Options'
      object ResetCameraMenu: TMenuItem
        Caption = 'Reset Camera'
        OnClick = ResetCameraMenuClick
      end
      object ShowOpenGLInformationMenu: TMenuItem
        Caption = 'Show OpenGL Information'
        OnClick = ShowOpenGLInformationMenuClick
      end
      object LineSplitOptionsMenu: TMenuItem
        Caption = '-'
      end
      object GotoMenu: TMenuItem
        Caption = 'Go to...'
        object GotoCamPosSubMenu: TMenuItem
          Caption = 'Coordinates'
          OnClick = GotoCamPosSubMenuClick
        end
        object GotoFaceIdSubmenu: TMenuItem
          Caption = 'Face Id'
          Enabled = False
          OnClick = GotoFaceIdSubmenuClick
        end
        object GotoVisLeafIdSubMenu: TMenuItem
          Caption = 'Visleaf Id'
          Enabled = False
          OnClick = GotoVisLeafIdSubMenuClick
        end
        object GotoBModelIdSubMenu: TMenuItem
          Caption = 'Brush Model Id'
          Enabled = False
          OnClick = GotoBModelIdSubMenuClick
        end
        object GotoEntTGNSubMenu: TMenuItem
          Caption = 'Entity Targetname'
          Enabled = False
          OnClick = GotoEntTGNSubMenuClick
        end
      end
      object RenderMenu: TMenuItem
        Caption = 'Render'
        object WireframeEntBrushesMenu: TMenuItem
          Caption = 'Wireframe Entity Brushes'
          OnClick = WireframeEntBrushesMenuClick
        end
        object WireframeHighlighEntBrushesMenu: TMenuItem
          Caption = 'Wireframe Highligh Entity Brushes'
          OnClick = WireframeHighlighEntBrushesMenuClick
        end
        object RenderBBOXVisLeaf: TMenuItem
          Caption = 'Draw BBOX VisLeaf'
          OnClick = RenderBBOXVisLeafClick
        end
        object LmpPixelModeMenu: TMenuItem
          Caption = 'Pixelate Lightmaps'
          OnClick = LmpPixelModeMenuClick
        end
        object DisableLightmapsMenu: TMenuItem
          Caption = 'Disable Lightmaps'
          OnClick = DisableLightmapsMenuClick
        end
        object DisableTexturesMenu: TMenuItem
          Caption = 'Disable Textures'
          OnClick = DisableTexturesMenuClick
        end
      end
      object FaceCullingMenu: TMenuItem
        Caption = 'Face Culling'
        object OcclusionMenu: TMenuItem
          Caption = 'Occlusion'
          OnClick = OcclusionMenuClick
        end
      end
      object CollisionMenu: TMenuItem
        Caption = 'Enable Collision'
        Enabled = False
        OnClick = CollisionMenuClick
      end
      object SetSelectedFaceColorMenu: TMenuItem
        Caption = 'Set Selected Face Color'
        OnClick = SetSelectedFaceColorMenuClick
      end
      object SetWireframeFaceColorMenu: TMenuItem
        Caption = 'Set Wireframe Highlitght Color'
        OnClick = SetWireframeFaceColorMenuClick
      end
      object ShowHeaderMenu: TMenuItem
        Caption = 'Show Header'
        OnClick = ShowHeaderMenuClick
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
