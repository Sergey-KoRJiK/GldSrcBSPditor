unit Unit1;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Menus,
  ComCtrls,
  ExtCtrls,
  StdCtrls,
  Grids,
  ValEdit,
  {}
  Math,
  OpenGL,
  UnitOpenGLext,
  UnitUserTypes,
  UnitVec,
  {}
  UnitQueryPerformanceTimer,
	UnitRenderTimerManager,
	UnitRenderingContextManager,
  UnitOpenGLAdditional,
  UnitOpenGLFPSCamera,
	UnitShaderManager,
	UnitVertexBufferArrayManager,
  UnitMegatextureManager,
  UnitBasetextureManager,
  UnitOpenGLErrorManager,
  {}
  UnitMapHeader,
  UnitBSPstruct,
  UnitEntity,
  UnitTexture,
  UnitNode,
  UnitFace,
  UnitClipNode,
  UnitVisLeaf,
  UnitMarkSurface,
  UnitEdge,
  UnitBrushModel,
  UnitLightEntity;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    OptionsMenu: TMenuItem;
    HelpMenu: TMenuItem;
    AboutMenu: TMenuItem;
    ResetCameraMenu: TMenuItem;
    OpenDialogBsp: TOpenDialog;
    SaveDialogBsp: TSaveDialog;
    LoadMapMenu: TMenuItem;
    CloseMapMenu: TMenuItem;
    LineSplitOptionsMenu: TMenuItem;
    ShowHeaderMenu: TMenuItem;
    WireframeEntBrushesMenu: TMenuItem;
    SaveMapMenu: TMenuItem;
    ColorDialog: TColorDialog;
    SetSelectedFaceColorMenu: TMenuItem;
    LineSplitFileMenu: TMenuItem;
    OpenDialogBMP: TOpenDialog;
    SaveDialogBMP: TSaveDialog;
    RenderBBOXVisLeaf: TMenuItem;
    RenderMenu: TMenuItem;
    PanelRT: TPanel;
    PanelFaceInfo: TPanel;
    RadioGroupLmp: TRadioGroup;
    ButtonSaveLmp: TButton;
    ButtonLoadLmp: TButton;
    LabelCameraPos: TLabel;
    LabelCameraLeafId: TLabel;
    LabelStylePage: TLabel;
    LabelCameraFPS: TLabel;
    GroupBoxFaceInfo: TGroupBox;
    LabelFaceIndex: TStaticText;
    EditFaceIndex: TStaticText;
    LabelFaceBrushIndex: TStaticText;
    EditFaceBrushIndex: TStaticText;
    LabelFacePlaneIndex: TStaticText;
    EditFacePlaneIndex: TStaticText;
    LabelFaceCountVertex: TStaticText;
    EditFaceCountVertex: TStaticText;
    GroupBoxTextureInfo: TGroupBox;
    LabelTexName: TStaticText;
    EditTexName: TStaticText;
    EditTexSize: TStaticText;
    LabelTexSize: TStaticText;
    LabelFaceTexInfo: TStaticText;
    EditFaceTexInfo: TStaticText;
    ImagePreviewBT: TImage;
    GroupBoxLightmapInfo: TGroupBox;
    LabelLmpSize: TStaticText;
    EditLmpSize: TStaticText;
    LabelLmpStyle1: TStaticText;
    EditLmpStyle1: TStaticText;
    LabelLmpStyle2: TStaticText;
    EditLmpStyle2: TStaticText;
    EditLmpStyle3: TStaticText;
    LabelLmpStyle3: TStaticText;
    LmpPixelModeMenu: TMenuItem;
    SetWireframeFaceColorMenu: TMenuItem;
    WireframeHighlighEntBrushesMenu: TMenuItem;
    CloseMenu: TMenuItem;
    DisableLightmapsMenu: TMenuItem;
    DisableTexturesMenu: TMenuItem;
    ShowOpenGLInformationMenu: TMenuItem;
    GotoMenu: TMenuItem;
    GotoCamPosSubMenu: TMenuItem;
    GotoFaceIdSubmenu: TMenuItem;
    GotoVisLeafIdSubMenu: TMenuItem;
    GotoBModelIdSubMenu: TMenuItem;
    GotoEntTGNSubMenu: TMenuItem;
    CollisionMenu: TMenuItem;
    ButtonLoadTex: TButton;
    ButtonSaveTex: TButton;
    ButtonTexRebuildMips: TButton;
    LmpOverBrightMenu: TMenuItem;
    LmpOverBright1Menu: TMenuItem;
    LmpOverBright2Menu: TMenuItem;
    LmpOverBright4Menu: TMenuItem;
    RadioButtonMip0: TRadioButton;
    RadioButtonMip1: TRadioButton;
    RadioButtonMip2: TRadioButton;
    RadioButtonMip3: TRadioButton;
    StaticText1: TStaticText;
    DrawTriggersMenu: TMenuItem;
    ImportWAD3Menu: TMenuItem;
    OpenDialogWAD3: TOpenDialog;
    ExportTextureLumpWAD3: TMenuItem;
    SaveDialogWAD3: TSaveDialog;
    GroupBoxFacePlane: TGroupBox;
    LabelFacePlaneX: TStaticText;
    EditFacePlaneX: TStaticText;
    LabelFacePlaneY: TStaticText;
    EditFacePlaneY: TStaticText;
    LabelFacePlaneZ: TStaticText;
    EditFacePlaneZ: TStaticText;
    LabelFacePlaneD: TStaticText;
    EditFacePlaneD: TStaticText;
    LabelFacePlaneF: TStaticText;
    EditFacePlaneF: TStaticText;
    EditFaceEntityName: TStaticText;
    EditFaceEntityClass: TStaticText;
    LabeTexIndex: TStaticText;
    EditTexIndex: TStaticText;
    DrawFaceContourMenu: TMenuItem;
    GroupBoxFaceTexInfo: TGroupBox;
    LabelFaceTexSx: TStaticText;
    EditFaceTexSx: TStaticText;
    LabelFaceTexSy: TStaticText;
    EditFaceTexSy: TStaticText;
    LabelFaceTexSz: TStaticText;
    EditFaceTexSz: TStaticText;
    LabelFaceTexSShift: TStaticText;
    EditFaceTexSShift: TStaticText;
    LabelFaceTexTx: TStaticText;
    EditFaceTexTx: TStaticText;
    LabelFaceTexTy: TStaticText;
    EditFaceTexTy: TStaticText;
    LabelFaceTexTz: TStaticText;
    EditFaceTexTz: TStaticText;
    LabelFaceTexTShift: TStaticText;
    EditFaceTexTShift: TStaticText;
    LabelFaceTexFlags: TStaticText;
    EditFaceTexFlags: TStaticText;
    GroupBoxProfile: TGroupBox;
    LabelProfile1: TStaticText;
    LabelProfile2: TStaticText;
    LabelProfile3: TStaticText;
    LabelProfile4: TStaticText;
    LabelProfile5: TStaticText;
    LabelProfile6: TStaticText;
    ShowFaceVertexHistogramMenu: TMenuItem;
    GroupBoxFaceTexel: TGroupBox;
    LabelFaceTexUV: TStaticText;
    EditFaceTexUV: TStaticText;
    LabelFaceLmpUV: TStaticText;
    EditFaceLmpUV: TStaticText;
    TexPixelModeMenu: TMenuItem;
    DrawEntityBrushesMenu: TMenuItem;
    ButtonDeleteLmp: TButton;
    ButtonAddLmp: TButton;
    ShowLightStylesMenu: TMenuItem;
    SaveDialogDir: TSaveDialog;
    ButtonDeleteTex: TButton;
    function TestRequarementExtensions(): Boolean;
    procedure InitGL();
    procedure GetVisleafRenderList();
    procedure GetFaceRenderList();
    procedure CollisionProcess();
    procedure do_movement(const Offset: GLfloat);
    procedure GetFaceIndexByRay();
    procedure UpdateFaceVisualInfo();
    procedure ClearFaceVisualInfo();
    procedure GenerateLightmapMegatexture();
    procedure GenerateBasetextures();
    procedure UpdFaceDrawState();
    procedure DrawScence(Sender: TObject);
    //
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpMenuClick(Sender: TObject);
    procedure AboutMenuClick(Sender: TObject);
    procedure ResetCameraMenuClick(Sender: TObject);
    procedure LoadMapMenuClick(Sender: TObject);
    procedure CloseMapMenuClick(Sender: TObject);
    procedure ShowHeaderMenuClick(Sender: TObject);
    procedure WireframeEntBrushesMenuClick(Sender: TObject);
    procedure SaveMapMenuClick(Sender: TObject);
    procedure SetSelectedFaceColorMenuClick(Sender: TObject);
    procedure RenderBBOXVisLeafClick(Sender: TObject);
    procedure PanelRTResize(Sender: TObject);
    procedure PanelRTMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelRTMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PanelRTMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonSaveLmpClick(Sender: TObject);
    procedure ButtonLoadLmpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LmpPixelModeMenuClick(Sender: TObject);
    procedure SetWireframeFaceColorMenuClick(Sender: TObject);
    procedure WireframeHighlighEntBrushesMenuClick(Sender: TObject);
    procedure CloseMenuClick(Sender: TObject);
    procedure DisableLightmapsMenuClick(Sender: TObject);
    procedure DisableTexturesMenuClick(Sender: TObject);
    procedure ShowOpenGLInformationMenuClick(Sender: TObject);
    procedure GotoCamPosSubMenuClick(Sender: TObject);
    procedure GotoFaceIdSubmenuClick(Sender: TObject);
    procedure GotoVisLeafIdSubMenuClick(Sender: TObject);
    procedure GotoBModelIdSubMenuClick(Sender: TObject);
    procedure GotoEntTGNSubMenuClick(Sender: TObject);
    procedure CollisionMenuClick(Sender: TObject);
    procedure ButtonLoadTexClick(Sender: TObject);
    procedure ButtonSaveTexClick(Sender: TObject);
    procedure ButtonTexRebuildMipsClick(Sender: TObject);
    procedure LmpOverBright1MenuClick(Sender: TObject);
    procedure LmpOverBright2MenuClick(Sender: TObject);
    procedure LmpOverBright4MenuClick(Sender: TObject);
    procedure RadioButtonMip0Click(Sender: TObject);
    procedure RadioButtonMip1Click(Sender: TObject);
    procedure RadioButtonMip2Click(Sender: TObject);
    procedure RadioButtonMip3Click(Sender: TObject);
    procedure DrawTriggersMenuClick(Sender: TObject);
    procedure ImportWAD3MenuClick(Sender: TObject);
    procedure ExportTextureLumpWAD3Click(Sender: TObject);
    procedure DrawFaceContourMenuClick(Sender: TObject);
    procedure ShowFaceVertexHistogramMenuClick(Sender: TObject);
    procedure TexPixelModeMenuClick(Sender: TObject);
    procedure DrawEntityBrushesMenuClick(Sender: TObject);
    procedure ButtonDeleteLmpClick(Sender: TObject);
    procedure ButtonAddLmpClick(Sender: TObject);
    procedure ShowLightStylesMenuClick(Sender: TObject);
    procedure ButtonDeleteTexClick(Sender: TObject);
  private
    RenderContext: CRenderingContextManager;
    RenderTimer: CRenderTimerManager;
    ProfileTimer: CQueryPerformanceTimer;
    Camera: CFirtsPersonViewCamera;
    WorkArea: TRect;
    RenderRange: GLfloat;
    FaceSelectedColor: tColor4fv;
    FaceWireframeColor: tColor4fv;
    FaceDrawState: Integer;
    //
    MouseRay: tRay;
    MousePos, MouseLastPos: TPoint;
    isLeftMouseClicked, isRightMouseClicked: Boolean;
    PressedKeyW: ByteBool;
    PressedKeyS: ByteBool;
    PressedKeyA: ByteBool;
    PressedKeyD: ByteBool;
    PressedKeyShift: ByteBool;
    //
    procedure Idle(Sender: TObject; var Done: Boolean);
  public

  end;

const
  DefaultRenderRange: GLfloat = 10000.0;
  FieldOfView: GLfloat = 90.0;
  MouseFreq: GLfloat = (Pi/180.0)/4.0; // [radian per pixel]
  CameraSpeed: GLfloat = 256;
  CameraSpeedAcc: GLfloat = 4.0*256;
  RenderInfoDelayUpd: GLfloat = 0.25; // seconds
  //
  ClearColor: tColor4fv = (0.01, 0.01, 0.01, 0.0);
  LeafRenderColor: tColor4fv = (0.1, 0.1, 0.7, 1.0);
  LeafRenderSecondColor: tColor4fv = (0.1, 0.7, 0.1, 0.4);
  //
  FACEDRAW_ALL                = $00;
  FACEDRAW_LIGHTMAP_ONLY      = $01;
  FACEDRAW_BASETEXTURE_ONLY   = $02;
  //
  HelpStr: String = 'Rotate Camera: Left Mouse Button' + LF +
    'Move Camera forward/backward: keys W/S' + LF +
    'Step Camera Left/Right: keys A/D' + LF +
    'Orts: red X, blue Y, green Z' + LF +
    'Select Face: Right Mouse Button' + LF +
    'Change Lightmap Style Page: key F' + LF +
    'Additional info showed in bottom Status Bar';
  AboutStr: String = 'Copyright (c) 2020 Sergey-KoRJiK, Belarus' + LF +
    'github.com/Sergey-KoRJiK' + LF +
    'GoldSrc BSP Editor and Viewer' + LF +
    'Program version: 1.4.1' + LF +
    'Version of you OpenGL: ';
  MainFormCaption: String = 'GoldSrc BSP Editor and Viewer';


var
  LastError: GLenum;
  RenderFrameIterator: Byte = 0; // use for mark leaf/faces to render
  CameraLeafId: Integer = 0;
  CameraLastLeafId: Integer = 0;
  FirstSpawnEntityId: Integer = -1;
  lpCameraLeaf: PVisLeafExt = nil;
  //
  // Collision status
  CurrCollisionDepth: Integer;
  CurrCollisionFlag: Integer;
  CurrSlidePlaneId: Integer;
  PrevClipPlaneId: Integer = -1;
  CurrClipPlaneId: Integer = -1;
  CollisionInfo: tCollisionInfo;
  //
  // Render VisLeaf options
  FaceOcclusion: Boolean = False;
  BaseCubeLeafWireframeList: GLuint = 0;
  SecondCubeLeafWireframeList: GLuint = 0;
  StartOrts: GLuint = 0;
  // Lightmap Face options
  SelectedFaceIndex: Integer = -1;
  SelectedStyle: Integer = 0;
  SelectedMipmap: Integer = 0;
  CurrFaceExt: PFaceExt = nil;
  TraceInfo: tTraceInfo;
  //
  LightmapMegatexture: CMegatextureManager;
  BasetextureMng: CBasetextureManager;
  BaseThumbnailBMP: TBitmap;
  //
  FacesIndexToRender: Array[0..65535] of Byte;
  LeafIndexToRender: Array[0..65535] of Byte;
  BrushIndexToRender: Array[0..65535] of Byte;
  //
  isBspLoad: Boolean = False;
  Map: tMapBSP;


implementation

{$R *.dfm}


procedure TMainForm.FormCreate(Sender: TObject);
begin
  {$R-}
  Self.ProfileTimer:=CQueryPerformanceTimer.CreateTimer();

  Self.Caption:=MainFormCaption;
  Self.KeyPreview:=True;
  Self.isLeftMouseClicked:=False;
  Self.isRightMouseClicked:=False;
  Self.RenderRange:=DefaultRenderRange;
  Self.OpenDialogBsp.InitialDir:=GetCurrentDir;
  Self.OpenDialogBMP.InitialDir:=GetCurrentDir;
  Self.SaveDialogBsp.InitialDir:=GetCurrentDir;
  Self.SaveDialogBMP.InitialDir:=GetCurrentDir;
  //
  Self.PressedKeyW:=False;
  Self.PressedKeyS:=False;
  Self.PressedKeyA:=False;
  Self.PressedKeyD:=False;
  Self.PressedKeyShift:=False;
  Self.UpdFaceDrawState();
  //
  Self.ClearFaceVisualInfo();
  //
  Self.FaceSelectedColor[0]:=1.0;
  Self.FaceSelectedColor[1]:=0.1;
  Self.FaceSelectedColor[2]:=0.1;
  Self.FaceSelectedColor[3]:=0.3;
  //
  Self.FaceWireframeColor[0]:=1.0;
  Self.FaceWireframeColor[1]:=0.0;
  Self.FaceWireframeColor[2]:=0.0;
  Self.FaceWireframeColor[3]:=1.0;

  Self.DoubleBuffered:=True;
  Self.PanelRT.DoubleBuffered:=True;
  Self.PanelRT.HandleNeeded();
  Self.RenderContext:=CRenderingContextManager.CreateManager();
  if (Self.RenderContext.CreateRenderingContext(Self.PanelRT.Handle, 24) = False) then
    begin
      ShowMessage('Error create OpenGL context!');
      Self.RenderContext.DeleteRenderingContext();
      Self.RenderContext.DeleteManager();
      Self.ProfileTimer.DeleteTimer();
      Application.ShowMainForm:=False;
      Application.Terminate;
    end;
  Self.RenderContext.MakeCurrent();

  Self.WorkArea.Left:=Self.Left;
  Self.WorkArea.Top:=Self.Top;
  Self.WorkArea.Right:=Self.Width + Self.Left;
  Self.WorkArea.Bottom:=Self.Height + Self.Top;
  if (SystemParametersInfo(SPI_GETWORKAREA, 0, @Self.WorkArea, 0)) then
    begin
      Self.Left:=Self.WorkArea.Left;
      Self.Top:=Self.WorkArea.Top;
      Self.Width:=Self.WorkArea.Right - Self.Left;
      Self.Height:=Self.WorkArea.Bottom - Self.Top;
    end; //}

  // Setup OpenGL Extensions. Only after wglCreateContext work wglGetProcAddress
  LoadOpenGLExtensions();
  if (TestOpenGLVersion(1, 3)) then
    begin
      ShowMessage('Error: Current system OpenGL version: '
        + OpenGLVersionShort + '; Requarement minimum version: 1.3');
      Self.ProfileTimer.DeleteTimer();
      Application.ShowMainForm:=False;
      Application.Terminate();
    end;
  if (Self.TestRequarementExtensions() = False) then
    begin
      Self.ProfileTimer.DeleteTimer();
      Application.ShowMainForm:=False;
      Application.Terminate();
    end;
  Self.InitGL();
  glPolygonOffset(0.0, -1.0); // for draw decals and selection mode
  glClearColor(ClearColor[0], ClearColor[1], ClearColor[2], ClearColor[3]);

  BaseCubeLeafWireframeList:=GenListCubeWireframe(@LeafRenderColor[0]);
  SecondCubeLeafWireframeList:=GenListCubeWireframe(@LeafRenderSecondColor[0]);
  StartOrts:=GenListOrts();

  Self.Camera:=CFirtsPersonViewCamera.CreateNewCamera(
    DefaultCameraPos,
    DefaultCameraPolarAngle,
    DefaultCameraAzimutalAngle
  );
  BasetextureMng:=CBasetextureManager.CreateManager();
  LightmapMegatexture:=CMegatextureManager.CreateManager();
  //
  BaseThumbnailBMP:=TBitmap.Create();
  BaseThumbnailBMP.PixelFormat:=pf24bit;
  BaseThumbnailBMP.Width:=BASETEXTURE_PREVIEW_SIZE;
  BaseThumbnailBMP.Height:=BASETEXTURE_PREVIEW_SIZE;
  BaseThumbnailBMP.Canvas.Brush.Color:=clBlack;
  BaseThumbnailBMP.Canvas.Pen.Color:=clBlack;

  Self.PanelRTResize(Sender);
  Self.RenderTimer:=CRenderTimerManager.CreateManager();
  Application.OnIdle:=Self.Idle;

  if (ParamCount = 1) then
    begin
      isBspLoad:=LoadBSP30FromFile(ParamStr(1), @Map);
      if (isBspLoad = False) then
        begin
          ShowMessage('Error load Map: ' + LF
            + ShowLoadBSPMapError(Map.LoadState)
          );
          FreeMapBSP(@Map);
        end
      else
        begin
          Self.LoadMapMenu.Enabled:=False;
          Self.CloseMapMenu.Enabled:=True;
          Self.SaveMapMenu.Enabled:=True;
          Self.GotoFaceIdSubmenu.Enabled:=True;
          Self.GotoVisLeafIdSubMenu.Enabled:=True;
          Self.GotoBModelIdSubMenu.Enabled:=True;
          Self.GotoEntTGNSubMenu.Enabled:=True;
          Self.Caption:=ParamStr(1);

          FirstSpawnEntityId:=FindFirstSpawnEntity(@Map.Entities[0], Map.CountEntities);
          if (FirstSpawnEntityId >= 1) then
            begin
              Self.Camera.ResetCamera(
                Map.Entities[FirstSpawnEntityId].Origin,
                Map.Entities[FirstSpawnEntityId].Angles.x*AngleToRadian,
                Map.Entities[FirstSpawnEntityId].Angles.y*AngleToRadian - Pi/2
              );
            end;

          FillChar(FacesIndexToRender[0], Map.CountFaces, not RenderFrameIterator);
          FillChar(LeafIndexToRender[0], Map.CountVisLeafWithPVS, not RenderFrameIterator);
          FillChar(BrushIndexToRender[0], Map.CountBrushModels, not RenderFrameIterator);

          Self.GenerateBasetextures();
          Self.GenerateLightmapMegatexture();
        end;
    end;
  {$R+}
end;

function TMainForm.TestRequarementExtensions(): Boolean;
begin
  {$R-}
  // OpenGL 1.2
  if (IsExistExtension(GL_EXT_blend_minmax_str) = False) then
    begin
      ShowMessage(GL_EXT_blend_minmax_str + ' is not supported!');
      Result:=False;
      Exit;
    end; //}

  if (IsExistExtension(GL_EXT_blend_subtract_str) = False) then
    begin
      ShowMessage(GL_EXT_blend_subtract_str + ' is not supported!');
      Result:=False;
      Exit;
    end; //}

  if (IsExistExtension(GL_EXT_blend_color_str) = False) then
    begin
      ShowMessage(GL_EXT_blend_color_str + ' is not supported!');
      Result:=False;
      Exit;
    end; //}

  if (IsExistExtension(GL_EXT_bgra_str) = False) then
    begin
      ShowMessage(GL_EXT_bgra_str + ' is not supported!');
      Result:=False;
      Exit;
    end; //}

  if (IsExistExtension(GL_EXT_texture_edge_clamp_str) = False) then
    begin
      ShowMessage(GL_EXT_texture_edge_clamp_str + ' is not supported!');
      Result:=False;
      Exit;
    end; //}

  // OpenGL 1.3
  if (IsExistExtension(GL_ARB_texture_env_add_str) = False) then
    begin
      ShowMessage(GL_ARB_texture_env_add_str + ' is not supported!');
      Result:=False;
      Exit;
    end; //}

  if (IsExistExtension(GL_ARB_texture_env_combine_str) = False) then
    begin
      ShowMessage(GL_ARB_texture_env_combine_str + ' is not supported!');
      Result:=False;
      Exit;
    end; //}

  if (IsExistExtension(GL_ARB_multitexture_str) = False) then
    begin
      ShowMessage(GL_ARB_multitexture_str + ' is not supported!');
      Result:=False;
      Exit;
    end; //}

  Result:=True;
  {$R+}
end;

procedure TMainForm.InitGL();
begin
  {$R-}
  glEnable(GL_DEPTH_TEST);  // Enable Depth Buffer
  glEnable(GL_CULL_FACE); // Enable Face Normal Test
  glCullFace(GL_FRONT); // which Face side render, Front or Back
  glPolygonMode(GL_BACK, GL_FILL); // GL_FILL, GL_LINE, GL_POINT

  glPixelStorei(GL_UNPACK_ALIGNMENT, 1); // Support load textures per byte
  glPixelStorei(GL_PACK_ALIGNMENT, 1); // Support save textures per byte

  glDepthMask(GL_TRUE); // Enable Depth Test
  glDepthFunc(GL_LEQUAL);  // type of Depth Test
  glEnable(GL_NORMALIZE); // automatic Normalize

  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
  glEnable(GL_COLOR_MATERIAL);

  glShadeModel(GL_SMOOTH); // Interpolation color type
  // GL_FLAT - Color dont interpolated, GL_SMOOTH - linear interpolate

  glAlphaFunc(GL_GEQUAL, 0.1);
  glEnable(GL_ALPHA_TEST);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  
  // point border smooth
  glEnable(GL_POINT_SMOOTH);
  glHint(GL_POINT_SMOOTH_HINT, GL_NICEST); //GL_FASTEST/GL_NICEST
  // line border smooth
  glEnable(GL_LINE_SMOOTH);
  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  // polygon border smooth
  //glEnable(GL_POLYGON_SMOOTH);
  glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
  //
  glHint(GL_Perspective_Correction_Hint, GL_NICEST); //}
  {$R+}
end;

procedure TMainForm.GetVisleafRenderList();
begin
  {$R-}
  if (isBspLoad) then
    begin
      CameraLeafId:=GetLeafIndexByPointAsm(
        @Map.NodeExtList[Map.RootNodeIndex],
        Self.Camera.ViewPosition
      );
      FaceOcclusion:=Boolean(CameraLeafId > 0);

      if (CameraLeafId <> CameraLastLeafId) then
        begin
          lpCameraLeaf:=@Map.VisLeafExtList[CameraLeafId];
          Self.LabelCameraLeafId.Caption:='Camera in Leaf: ' + IntToStr(CameraLeafId);

          Inc(RenderFrameIterator);
          if (CameraLeafId > 0) then
            begin
              // Update visibility flags of VisLeafs
              SetBytesByBoolMask(
                @lpCameraLeaf.PVS[0],
                @LeafIndexToRender[0],
                lpCameraLeaf.CountPVS,
                RenderFrameIterator or ((not RenderFrameIterator) shl 8)
              );
            end
          else
            begin
              // Call only when camera go out from map, mean from leaf to space,
              FillChar(FacesIndexToRender[0], Map.CountFaces, RenderFrameIterator);
              FillChar(BrushIndexToRender[0], Map.CountBrushModels, RenderFrameIterator);
            end; //}
          CameraLastLeafId:=CameraLeafId;
          Self.GetFaceRenderList();
        end;
    end;
  {$R+}
end;

procedure TMainForm.GetFaceRenderList();
var
  i, j: Integer;
  tmpVisLeaf: PVisLeafExt;
begin
  {$R-}
  Self.ProfileTimer.TimerStart();
  if (FaceOcclusion) then
    begin
      for i:=0 to (lpCameraLeaf.CountPVS - 1) do
        begin
          // For each visible VisLeaf for lpCameraLeaf by PVS Table
          if (LeafIndexToRender[i] <> RenderFrameIterator) then Continue;

          // For each VisLeaf on Map
          // 1. Get visible World Brush faces for tmpVisLeaf
          tmpVisLeaf:=@Map.VisLeafExtList[i + 1];
          for j:=0 to (tmpVisLeaf.CountWFaces - 1) do
            begin
              FacesIndexToRender[tmpVisLeaf.WFaceIndexes[j]]:=RenderFrameIterator;
            end; //}

          // 2. Get visible Entity Brushes for tmpVisLeaf
          if (Self.DrawEntityBrushesMenu.Checked = False) then Continue;
          for j:=0 to (tmpVisLeaf.CountBModels - 1) do
            begin
              BrushIndexToRender[tmpVisLeaf.BModelIndexes[j]]:=RenderFrameIterator;
            end;
        end; // End For each VisLeaf on Map
    end;
    
  // Hide Triggers
  if (not (Self.DrawTriggersMenu.Checked and Self.DrawEntityBrushesMenu.Checked)) then
    begin
      for i:=0 to (Map.CountBrushModels - 1) do
        begin
          if (BrushIndexToRender[i] <> RenderFrameIterator) then Continue;
          if (Map.BrushModelExtList[i].isAAATrigger) then
            begin
              BrushIndexToRender[i]:=not RenderFrameIterator;
            end;
        end;
    end;
  Self.ProfileTimer.TimerStop();
  Self.LabelProfile1.Caption:='FaceVis '
    + Self.ProfileTimer.GetStringMcsInterval();
  {$R+}
end;

procedure TMainForm.CollisionProcess();
var
  i: Integer;
  tmpVec: tVec4f;
  tmpStr: String;
  minDist: Single;
begin
  {$R-}
  if ((isBSPLoad = False) or (Self.CollisionMenu.Checked = False)) then Exit;

  CurrClipPlaneId:=-1;
  minDist:=FLOAT32_INF_POSITIVE;
  tmpVec.w:=0;
  for i:=0 to (Map.CountBrushModels - 1) do
    begin
      if (BrushIndexToRender[i] <> RenderFrameIterator) then Continue;
      
      tmpVec.x:=Self.Camera.ViewPosition.x -
        Map.BrushModelExtList[i].BaseBModel.Origin.x;
      tmpVec.y:=Self.Camera.ViewPosition.y -
        Map.BrushModelExtList[i].BaseBModel.Origin.y;
      tmpVec.z:=Self.Camera.ViewPosition.z -
        Map.BrushModelExtList[i].BaseBModel.Origin.z;

      GetCollisionInfo(
        @CollisionInfo,
        @Map.ClipNodeExtList[Map.BrushModelExtList[i].BaseBModel.iHull[1]],
        tmpVec,
      );
      if (minDist > CollisionInfo.fDistCanditate) then
        begin
          minDist:=CollisionInfo.fDistCanditate;
          CurrClipPlaneId:=CollisionInfo.iClipCandidate;
        end;

      if (CollisionInfo.State = CLIPCONTEST_SOLID) then Break;
    end;
  {something work wrong
  ... we want two variables for State each render frame: 
   1) prev value CollisionInfo.State
   2) next value CollisionInfo.State
  Then if:
   a) prev = EMPTY & next = SOLID, then "hit"
   b) prev = EMPTY & next = EMPTY, no "hit"
   c) prev = SOLID & next = SOLID, then we "stuck" and need step back
   d) prev = SOLID è next = EMPTY, then we "unstuck" from (c)
   
  (a): when it happen, we correct our trajectory and do collision test again
       until we got case (b), and we must never happen in cases (c,d)
   What i need do? what is efficitve alghorithm.. ?//}
  tmpStr:='List: ';
  if (CollisionInfo.State = CLIPCONTEST_EMPTY) then tmpStr:='No';
  if (CollisionInfo.State = CLIPCONTEST_SOLID) then tmpStr:='Yes';
  if ((CurrClipPlaneId < 0) and (PrevClipPlaneId >= 0)) then
    begin
      tmpStr:=tmpStr + ', Plane:'
        + PlaneToStr(Map.ClipNodeExtList[PrevClipPlaneId].Plane);
    end
  else
    begin
      PrevClipPlaneId:=CurrClipPlaneId;
    end;
  Self.Caption:=tmpStr;
  {$R+}
end;

procedure TMainForm.do_movement(const Offset: GLfloat);
begin
  {$R-}
  if (Self.PressedKeyW) then Self.Camera.StepForward(Offset);
  if (Self.PressedKeyS) then Self.Camera.StepBackward(Offset);
  if (Self.PressedKeyA) then Self.Camera.StepLeft(Offset);
  if (Self.PressedKeyD) then Self.Camera.StepRight(Offset);
  {$R+}
end;

procedure TMainForm.GetFaceIndexByRay();
var
  i, j: Integer;
  WDist, EDist: Single;
  WIndex, EIndex: Integer;
  WTraceInfo, ETraceInfo: tTraceInfo;
begin
  {$R-}
  SelectedFaceIndex:=-1;
  CurrFaceExt:=nil;
  if (isBspLoad = False) then Exit;

  WDist:=Self.RenderRange + 1;
  EDist:=WDist;
  WIndex:=-1;
  EIndex:=-1;
  // Dist start at value > 0;
  // if Dist = 0, face on zNear plane
  // if Dist < 0, face behind zNear plane, ignore it
  // so, we can use fast integer compare technique for positives Float-32 IEEE-754;

  Self.ProfileTimer.TimerStart();
  for i:=0 to (Map.CountFaces - 1) do
    begin
      // reject non-visible faces by PVS
      if (FacesIndexToRender[i] <> RenderFrameIterator) then Continue;

      WTraceInfo.t:=WDist;
      // Ray-Plane intersection with get intersection point on plane
      //if (not GetRayPlaneIntersection(
      if (not GetRayPlaneIntersectionASM(
                Map.FaceExtList[i].Polygon.Plane,
                Self.MouseRay,
                @WTraceInfo)
          ) then Continue; //}
      if (not TestPointInsidePolygon(
                Map.FaceExtList[i].Polygon,
                WTraceInfo.Point)
          ) then Continue;
      WDist:=WTraceInfo.t;
      WIndex:=i; //}
    end;
  if (Self.DrawEntityBrushesMenu.Checked) then
    begin
      for i:=1 to (Map.CountBrushModels - 1) do
        begin
          if (BrushIndexToRender[i] <> RenderFrameIterator) then Continue;
          for j:=Map.BrushModelExtList[i].BaseBModel.iFirstFace to
            Map.BrushModelExtList[i].iLastFace do
            begin
              ETraceInfo.t:=EDist;
              if (not GetRayPlaneIntersectionASM(
                    Map.FaceExtList[j].Polygon.Plane,
                    Self.MouseRay,
                    @ETraceInfo)
              ) then Continue; //}
              if (not TestPointInsidePolygon(
                    Map.FaceExtList[j].Polygon,
                    ETraceInfo.Point)
              ) then Continue;
              EDist:=ETraceInfo.t;
              EIndex:=j;
            end;
        end;
    end;
  if (EDist < WDist) then
    begin
      SelectedFaceIndex:=EIndex;
      TraceInfo:=ETraceInfo;
    end
  else
    begin
      SelectedFaceIndex:=WIndex;
      TraceInfo:=WTraceInfo;
    end;
  Self.ProfileTimer.TimerStop();
  Self.LabelProfile2.Caption:='SelectF '
    + Self.ProfileTimer.GetStringMcsInterval();

  if (SelectedFaceIndex >= 0) then
    begin
      CurrFaceExt:=@Map.FaceExtList[SelectedFaceIndex];
      Self.UpdateFaceVisualInfo();
    end
  else
    begin
      Self.ClearFaceVisualInfo();
    end;
  {$R+}
end;

procedure TMainForm.GenerateLightmapMegatexture();
var
  i, iVisLeaf, iFace, iStyle, iBrushModel: Integer;
  tmpSize: tVec2s;
  MegaMemError: eMegaMemError;
  lpVisLeafExt: PVisLeafExt;
  lpFaceExt: PFaceExt;
  lpBrushModelExt: PBrushModelExt;
  lpLightmapBase, lpLightmapAdd: PRGB888;
begin
  {$R-}
  if (LightmapMegatexture.AllocNewMegaTexture(@MegaMemError) = False) then
    begin
      ShowMessage(GetMegaMemErrorInfo(MegaMemError));
      LightmapMegatexture.Clear();
      Exit;
    end;

  // 1. Create dummy lightmap texture
  LightmapMegatexture.ReserveTexture(MEGATEXTURE_DUMMY_SIZE);
  LightmapMegatexture.UpdateCurrentBufferFromArray(
    MEGATEXTURE_DUMMY_MEGAID,
    MEGATEXTURE_DUMMY_REGIONID,
    @MEGATEXTURE_DUMMY_DATA[0],
    nil
  );

  // 2. Process Faces without lightmaps - create dummy white 2x2 lightmap
  for iFace:=0 to (Map.CountFaces - 1) do
    begin
      lpFaceExt:=@Map.FaceExtList[iFace];
      if (lpFaceExt.isDummyLightmaps) then
        begin
          lpFaceExt.LmpMegaId:=MEGATEXTURE_DUMMY_MEGAID;
          lpFaceExt.LmpRegionId:=MEGATEXTURE_DUMMY_REGIONID;
        end;
  end;

  // 3. Process World Face's with lightmaps
  for iVisLeaf:=1 to Map.CountVisLeafWithPVS do
    begin
      lpVisLeafExt:=@Map.VisLeafExtList[iVisLeaf];
      for i:=0 to (lpVisLeafExt.BaseLeaf.nMarkSurfaces - 1) do
        begin
          iFace:=lpVisLeafExt.WFaceIndexes[i];
          lpFaceExt:=@Map.FaceExtList[iFace];

          if (lpFaceExt.isDummyLightmaps) then Continue;

          tmpSize.x:=lpFaceExt.LmpSize.x*lpFaceExt.CountLightStyles;
          tmpSize.y:=lpFaceExt.LmpSize.y;
          if (LightmapMegatexture.IsCanReserveTexture(tmpSize) = False) then
            begin
              LightmapMegatexture.UpdateTextureFromCurrentBuffer();
              if (LightmapMegatexture.AllocNewMegaTexture(@MegaMemError) = False) then
                begin
                  ShowMessage(GetMegaMemErrorInfo(MegaMemError));
                  LightmapMegatexture.Clear();
                  Exit;
                end;
            end;

          lpFaceExt.LmpMegaId:=LightmapMegatexture.CurrentMegatextureIndex;
          lpFaceExt.LmpRegionId:=LightmapMegatexture.ReserveTexture(lpFaceExt.LmpSize);
          LightmapMegatexture.UpdateCurrentBufferFromArray(
            lpFaceExt.LmpMegaId,
            lpFaceExt.LmpRegionId,
            @lpFaceExt.Lightmaps[0],
            nil
          );
          LightmapMegatexture.UpdateTextureCoords(
            lpFaceExt.LmpMegaId,
            lpFaceExt.LmpRegionId,
            @lpFaceExt.LmpCoords[0],
            @lpFaceExt.LmpMegaCoords[0],
            lpFaceExt.Polygon.CountVertecies
          );
          for iStyle:=1 to (lpFaceExt.CountLightStyles - 1) do
            begin
              LightmapMegatexture.ReserveTexture(lpFaceExt.LmpSize);
              lpLightmapBase:=@lpFaceExt.Lightmaps[0];
              lpLightmapAdd:=lpLightmapBase;
              Inc(lpLightmapAdd, iStyle*lpFaceExt.LmpSquare);
              LightmapMegatexture.UpdateCurrentBufferFromArray(
                lpFaceExt.LmpMegaId,
                lpFaceExt.LmpRegionId + iStyle,
                lpLightmapBase,
                lpLightmapAdd
              );
              LightmapMegatexture.UpdateTextureCoords(
                lpFaceExt.LmpMegaId,
                lpFaceExt.LmpRegionId + iStyle,
                @lpFaceExt.LmpCoords[0],
                @lpFaceExt.LmpMegaCoords[iStyle*lpFaceExt.Polygon.CountVertecies],
                lpFaceExt.Polygon.CountVertecies
              );
            end;
        end;
    end;

  // 4. Process Entity Face's with lightmaps
  for iBrushModel:=1 to (Map.CountBrushModels - 1) do
    begin
      lpBrushModelExt:=@Map.BrushModelExtList[iBrushModel];
      for iFace:=lpBrushModelExt.BaseBModel.iFirstFace to lpBrushModelExt.iLastFace do
        begin
          lpFaceExt:=@Map.FaceExtList[iFace];

          if (lpFaceExt.isDummyLightmaps) then Continue;

          tmpSize.x:=lpFaceExt.LmpSize.x*lpFaceExt.CountLightStyles;
          tmpSize.y:=lpFaceExt.LmpSize.y;
          if (LightmapMegatexture.IsCanReserveTexture(tmpSize) = False) then
            begin
              LightmapMegatexture.UpdateTextureFromCurrentBuffer();
              if (LightmapMegatexture.AllocNewMegaTexture(@MegaMemError) = False) then
                begin
                  ShowMessage(GetMegaMemErrorInfo(MegaMemError));
                  LightmapMegatexture.Clear();
                  Exit;
                end;
            end;

          lpFaceExt.LmpMegaId:=LightmapMegatexture.CurrentMegatextureIndex;
          lpFaceExt.LmpRegionId:=LightmapMegatexture.ReserveTexture(lpFaceExt.LmpSize);
          LightmapMegatexture.UpdateCurrentBufferFromArray(
            lpFaceExt.LmpMegaId,
            lpFaceExt.LmpRegionId,
            @lpFaceExt.Lightmaps[0],
            nil
          );
          LightmapMegatexture.UpdateTextureCoords(
            lpFaceExt.LmpMegaId,
            lpFaceExt.LmpRegionId,
            @lpFaceExt.LmpCoords[0],
            @lpFaceExt.LmpMegaCoords[0],
            lpFaceExt.Polygon.CountVertecies
          );
          for iStyle:=1 to (lpFaceExt.CountLightStyles - 1) do
            begin
              LightmapMegatexture.ReserveTexture(lpFaceExt.LmpSize);
              lpLightmapBase:=@lpFaceExt.Lightmaps[0];
              lpLightmapAdd:=lpLightmapBase;
              Inc(lpLightmapAdd, iStyle*lpFaceExt.LmpSquare);
              LightmapMegatexture.UpdateCurrentBufferFromArray(
                lpFaceExt.LmpMegaId,
                lpFaceExt.LmpRegionId + iStyle,
                lpLightmapBase,
                lpLightmapAdd
              );
              LightmapMegatexture.UpdateTextureCoords(
                lpFaceExt.LmpMegaId,
                lpFaceExt.LmpRegionId + iStyle,
                @lpFaceExt.LmpCoords[0],
                @lpFaceExt.LmpMegaCoords[iStyle*lpFaceExt.Polygon.CountVertecies],
                lpFaceExt.Polygon.CountVertecies
              );
            end;
        end;
    end;

  LightmapMegatexture.UpdateTextureFromCurrentBuffer();
  LightmapMegatexture.UnbindMegatexture2D();
  {$R+}
end;

procedure TMainForm.GenerateBasetextures();
var
  i: Integer;
begin
  {$R-}
  for i:=0 to (Map.TextureLump.nCountTextures - 1) do
    begin
      BasetextureMng.AppendBasetexture(Map.TextureLump.Wad3Textures[i]);
    end;
                 
  for i:=0 to (Map.CountFaces - 1) do
    begin
      Map.FaceExtList[i].TexRenderId:=
        BasetextureMng.GetBasetextureIdByName(Map.FaceExtList[i].TexName);
      if (Map.FaceExtList[i].TexRenderId < 0) then
        begin
          Map.FaceExtList[i].TexRenderId:=BASETEXTURE_DUMMY_ID;
        end
      else
        begin
          Map.FaceExtList[i].isDummyTexture:=False;
        end;
    end;

  BasetextureMng.UnbindBasetexture();
  {$R+}
end;

procedure TMainForm.UpdFaceDrawState();
begin
  {$R-}
  Self.FaceDrawState:=FACEDRAW_ALL;
  if (Self.DisableTexturesMenu.Checked) then
    begin
      Self.FaceDrawState:=Self.FaceDrawState or FACEDRAW_LIGHTMAP_ONLY;
    end;
  if (Self.DisableLightmapsMenu.Checked) then
    begin
      Self.FaceDrawState:=Self.FaceDrawState or FACEDRAW_BASETEXTURE_ONLY;
    end;
  {$R+}
end;


procedure TMainForm.DrawScence(Sender: TObject);
var
  i, j: Integer;
begin
  {$R-}
  Self.RenderTimer.UpdDeltaTime();
  if (Self.PressedKeyShift) then
    begin
      do_movement(CameraSpeedAcc*Self.RenderTimer.DeltaTime);
    end
  else
    begin
      do_movement(CameraSpeed*Self.RenderTimer.DeltaTime);
    end;
  Self.CollisionProcess();
  Self.GetVisleafRenderList();
  Self.Camera.glModelViewUpdate;
  glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);

  if (isBspLoad) then
    begin
      LightmapMegatexture.UnbindMegatexture2D();
      BasetextureMng.UnbindBasetexture();
      //
      glAlphaFunc(GL_GEQUAL, 0.5);
      case (Self.FaceDrawState) of
        FACEDRAW_ALL:
          begin
            PreRenderFaces(True, True, True);
            // Render World Brush Faces
            for i:=0 to (Map.CountFaces - 1) do
              begin
                if (FacesIndexToRender[i] <> RenderFrameIterator) then Continue;
                //
                BasetextureMng.BindBasetexture(Map.FaceExtList[i].TexRenderId);
                LightmapMegatexture.BindMegatexture2D(Map.FaceExtList[i].LmpMegaId);
                //
                if (SelectedStyle < Map.FaceExtList[i].CountLightStyles)
                then RenderFaceLmpBT(@Map.FaceExtList[i], SelectedStyle)
                else RenderFaceLmpBT(@Map.FaceExtList[i], 0);
              end;
            // Render EntBrush Faces
            if (Self.DrawEntityBrushesMenu.Checked) then
              begin
                if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_LINE);
                for i:=1 to (Map.CountBrushModels - 1) do
                  begin
                    if (BrushIndexToRender[i] <> RenderFrameIterator) then Continue;
                    //
                    for j:=Map.BrushModelExtList[i].BaseBModel.iFirstFace to
                      Map.BrushModelExtList[i].iLastFace do
                      begin
                        BasetextureMng.BindBasetexture(Map.FaceExtList[j].TexRenderId);
                        LightmapMegatexture.BindMegatexture2D(Map.FaceExtList[j].LmpMegaId);
                        //
                        if (SelectedStyle < Map.FaceExtList[j].CountLightStyles)
                        then RenderFaceLmpBT(@Map.FaceExtList[j], SelectedStyle)
                        else RenderFaceLmpBT(@Map.FaceExtList[j], 0);
                      end;
                  end;
                if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_FILL);
              end;
            //
            PostRenderFaces(True, True, True);
            LightmapMegatexture.UnbindMegatexture2D();
            BasetextureMng.UnbindBasetexture();
          end;
        FACEDRAW_LIGHTMAP_ONLY:
          begin
            PreRenderFaces(True, False, True);
            // Render World Brush Faces
            for i:=0 to (Map.CountFaces - 1) do
              begin
                if (FacesIndexToRender[i] <> RenderFrameIterator) then Continue;
                //
                LightmapMegatexture.BindMegatexture2D(Map.FaceExtList[i].LmpMegaId);
                //
                if (SelectedStyle < Map.FaceExtList[i].CountLightStyles)
                then RenderFaceLmp(@Map.FaceExtList[i], SelectedStyle)
                else RenderFaceLmp(@Map.FaceExtList[i], 0);
              end;
            // Render EntBrush Faces
            if (Self.DrawEntityBrushesMenu.Checked) then
              begin
                if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_LINE);
                for i:=1 to (Map.CountBrushModels - 1) do
                  begin
                    if (BrushIndexToRender[i] <> RenderFrameIterator) then Continue;
                    //
                    for j:=Map.BrushModelExtList[i].BaseBModel.iFirstFace to
                      Map.BrushModelExtList[i].iLastFace do
                      begin
                        LightmapMegatexture.BindMegatexture2D(Map.FaceExtList[j].LmpMegaId);
                        //
                        if (SelectedStyle < Map.FaceExtList[j].CountLightStyles)
                        then RenderFaceLmp(@Map.FaceExtList[j], SelectedStyle)
                        else RenderFaceLmp(@Map.FaceExtList[j], 0);
                      end;
                  end;
                if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_FILL);
              end;
            //
            PostRenderFaces(True, False, True);
            LightmapMegatexture.UnbindMegatexture2D();
          end;
        FACEDRAW_BASETEXTURE_ONLY:
          begin
            PreRenderFaces(True, True, False);
            // Render World Brush Faces
            for i:=0 to (Map.CountFaces - 1) do
              begin
                if (FacesIndexToRender[i] <> RenderFrameIterator) then Continue;
                //
                BasetextureMng.BindBasetexture(Map.FaceExtList[i].TexRenderId);
                RenderFaceBT(@Map.FaceExtList[i])
              end;
            // Render EntBrush Faces
            if (Self.DrawEntityBrushesMenu.Checked) then
              begin
                if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_LINE);
                for i:=1 to (Map.CountBrushModels - 1) do
                  begin
                    if (BrushIndexToRender[i] <> RenderFrameIterator) then Continue;
                    //
                    for j:=Map.BrushModelExtList[i].BaseBModel.iFirstFace to
                      Map.BrushModelExtList[i].iLastFace do
                      begin
                        BasetextureMng.BindBasetexture(Map.FaceExtList[j].TexRenderId);
                        RenderFaceBT(@Map.FaceExtList[j])
                      end;
                  end;
                if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_FILL);
              end;
            //
            PostRenderFaces(True, True, False);
            BasetextureMng.UnbindBasetexture();
          end;
      end;
      glAlphaFunc(GL_GEQUAL, 0.1); //}
      
      //////////////////////////////////////////////////////////////////////////
      // Render Highlight Wireframe for EntBrush Faces
      if (Self.WireframeHighlighEntBrushesMenu.Checked and Self.DrawEntityBrushesMenu.Checked) then
        begin
          glPolygonMode(GL_BACK, GL_LINE);
          PreRenderFaces(True, False, False);
          for i:=1 to (Map.CountBrushModels - 1) do
            begin
              if (BrushIndexToRender[i] <> RenderFrameIterator) then Continue;
              //
              for j:=Map.BrushModelExtList[i].BaseBModel.iFirstFace to
                Map.BrushModelExtList[i].iLastFace do
                begin
                  RenderFaceCustomColor4f(@Map.FaceExtList[j], @Self.FaceWireframeColor[0]);
                end;
            end;
          PostRenderFaces(True, False, False);
          glPolygonMode(GL_BACK, GL_FILL);
        end; //}

      //////////////////////////////////////////////////////////////////////////
      // Render Faces Edge-Contour in Dark-Gray color
      if (Self.DrawFaceContourMenu.Checked) then
        begin
          glPolygonMode(GL_BACK, GL_LINE);
          PreRenderFaces(True, False, False);
          glColor3f(0.5, 0.5, 0.5);
          for i:=0 to (Map.CountFaces - 1) do
            begin
              if (FacesIndexToRender[i] <> RenderFrameIterator) then Continue;
              RenderFaceContourOnly(@Map.FaceExtList[i]);
            end;
          if (Self.DrawEntityBrushesMenu.Checked) then
            begin
              for i:=1 to (Map.CountBrushModels - 1) do
                begin
                  if (BrushIndexToRender[i] <> RenderFrameIterator) then Continue;
                  for j:=Map.BrushModelExtList[i].BaseBModel.iFirstFace to
                    Map.BrushModelExtList[i].iLastFace do
                    begin
                      RenderFaceContourOnly(@Map.FaceExtList[j]);
                    end;
                end;
            end;
          PostRenderFaces(True, False, False);
          glPolygonMode(GL_BACK, GL_FILL);
        end;

      // Render Selected Face
      if (SelectedFaceIndex >= 0) then
        begin
          glEnable(GL_POLYGON_OFFSET);
          PreRenderFaces(True, False, False);
          RenderFaceCustomColor4f(CurrFaceExt, @Self.FaceSelectedColor[0]);
          PostRenderFaces(True, False, False);
          glDisable(GL_POLYGON_OFFSET);
        end; //}

      //////////////////////////////////////////////////////////////////////////
      // Render "Camera VisLeaf"
      if ((Self.RenderBBOXVisLeaf.Checked) and (CameraLeafId > 0)) then
        begin
          glPushMatrix();
          glTranslatef(
            lpCameraLeaf.BBOX4f.vMin.x,
            lpCameraLeaf.BBOX4f.vMin.y,
            lpCameraLeaf.BBOX4f.vMin.z
          );
          glScalef(
            lpCameraLeaf.SizeBBOX4f.x,
            lpCameraLeaf.SizeBBOX4f.y,
            lpCameraLeaf.SizeBBOX4f.z
          );
          glCallList(BaseCubeLeafWireframeList);
          glPopMatrix();

          // Render other VisLeafs
          for i:=1 to (lpCameraLeaf.CountPVS - 1) do
            begin
              if (LeafIndexToRender[i] <> RenderFrameIterator) then Continue;

              glPushMatrix();
              glTranslatef(
                Map.VisLeafExtList[i].BBOX4f.vMin.x,
                Map.VisLeafExtList[i].BBOX4f.vMin.y,
                Map.VisLeafExtList[i].BBOX4f.vMin.z
              );
              glScalef(
                Map.VisLeafExtList[i].SizeBBOX4f.x,
                Map.VisLeafExtList[i].SizeBBOX4f.y,
                Map.VisLeafExtList[i].SizeBBOX4f.z
              );
              glCallList(SecondCubeLeafWireframeList);
              glPopMatrix();
            end; //}
        end;

      // Render BBOX of Entity "worldspawn" (total Map BBOX)
      glPushMatrix();
      glTranslatef(
        Map.MapBBOX4f.vMin.x,
        Map.MapBBOX4f.vMin.y,
        Map.MapBBOX4f.vMin.z
      );
      glScalef(
        Map.MapBBOX4fSize.x,
        Map.MapBBOX4fSize.y,
        Map.MapBBOX4fSize.z
      );
      glCallList(SecondCubeLeafWireframeList);
      glPopMatrix();
    end;

  glCallList(StartOrts);

  Self.RenderContext.SwapBuffers();

  if (Self.RenderTimer.ElaspedTime >= RenderInfoDelayUpd) then
    begin
      Self.RenderTimer.ResetCounter();
      Self.LabelCameraFPS.Caption:='FPS: ' + Self.RenderTimer.GetStringFPS();
      Self.LabelCameraPos.Caption:=VecToStr(Self.Camera.ViewPosition);
    end;
  {$R+}
end;

procedure TMainForm.Idle(Sender: TObject; var Done: Boolean);
begin
  {$R-}
  Done:=False;
  Self.DrawScence(Sender);
  {$R+}
end;  // *)

procedure TMainForm.PanelRTResize(Sender: TObject);
begin
  {$R-}
  if (Self.Camera <> nil) then
    begin
      Self.Camera.SetProjMatrix(
        Self.PanelRT.ClientWidth,
        Self.PanelRT.ClientHeight,
        FieldOfView,
        Self.RenderRange
      );
      Self.Camera.glProjectionAndViewPortUpdate();
    end;
  {$R+}
end;

procedure TMainForm.PanelRTMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {$R-}
  Self.MousePos.X:=X;
  Self.MousePos.Y:=Y;

  if (mbLeft = Button) then Self.isLeftMouseClicked:=True;
  if (mbRight = Button) then
    begin
      Self.isRightMouseClicked:=True;
      Self.Camera.GetTraceLineByMouseClick(Self.MousePos, @Self.MouseRay);
      Self.GetFaceIndexByRay();
    end;
  {$R+}
end;

procedure TMainForm.PanelRTMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  {$R-}
  Self.MousePos.X:=X;
  Self.MousePos.Y:=Y;
  if (Self.isLeftMouseClicked) then
    begin
      if (Self.MousePos.X <> Self.MouseLastPos.X) then
        begin
          // MouseFreq -> [radian / pixel]
          // (X - Self.mdx) -> [pixel]
          // (X - Self.mdx)*MouseFreq -> [pixel]*[radian / pixel] -> [radian]
          Self.Camera.UpDateViewDirectionByMouseX((Self.MousePos.X - Self.MouseLastPos.X)*MouseFreq);
        end; //}
      if (Self.MousePos.Y <> Self.MouseLastPos.Y) then
        begin
          Self.Camera.UpDateViewDirectionByMouseY((Self.MouseLastPos.Y - Self.MousePos.Y)*MouseFreq);
        end; //}
    end;
  Self.MouseLastPos:=Self.MousePos;
  {$R+}
end;

procedure TMainForm.PanelRTMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {$R-}
  if (mbLeft = Button) then Self.isLeftMouseClicked:=False;
  if (mbRight = Button) then Self.isRightMouseClicked:=False;
  {$R+}
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {$R-}
  if (Key = Byte('W')) then Self.PressedKeyW:=True;
  if (Key = Byte('S')) then Self.PressedKeyS:=True;
  if (Key = Byte('A')) then Self.PressedKeyA:=True;
  if (Key = Byte('D')) then Self.PressedKeyD:=True;
  if (Key = KEYBOARD_SHIFT) then Self.PressedKeyShift:=True;

  if (isBspLoad = False) then Exit;

  if (Key = Byte('F')) then
    begin
      Inc(SelectedStyle);
      if (SelectedStyle > 3) then SelectedStyle:=0;

      Self.LabelStylePage.Caption:='Style page (0..3): '
        + IntToStr(SelectedStyle);
    end;
  {$R+}
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {$R-}
  if (Key = Byte('W')) then Self.PressedKeyW:=False;
  if (Key = Byte('S')) then Self.PressedKeyS:=False;
  if (Key = Byte('A')) then Self.PressedKeyA:=False;
  if (Key = Byte('D')) then Self.PressedKeyD:=False;
  if (Key = KEYBOARD_SHIFT) then Self.PressedKeyShift:=False;
  {$R+}
end;

procedure TMainForm.UpdateFaceVisualInfo();
var
  i: Integer;
  lpTexInfo: PTexInfo;
  UV: tVec2f;
begin
  {$R-}
  if (SelectedFaceIndex < 0) then
    begin
      Self.ClearFaceVisualInfo();
      Exit;
    end;

  Self.EditFaceIndex.Caption:=' ' + IntToStr(SelectedFaceIndex);
  if (CurrFaceExt.BrushId = 0) then
    begin
      Self.EditFaceBrushIndex.Caption:=' World';
      Self.EditFaceEntityName.Caption:=' ';
      Self.EditFaceEntityClass.Caption:=' worldspawn';
    end
  else
    begin
      Self.EditFaceBrushIndex.Caption:=' *' + IntToStr(CurrFaceExt.BrushId);
      i:=FindEntityByBModelIndex(@Map.Entities[0], Map.CountEntities, CurrFaceExt.BrushId);
      if (i >= 0) then
        begin
          Self.EditFaceEntityName.Caption:=' ' + Map.Entities[i].TargetName;
          Self.EditFaceEntityClass.Caption:=' ' + Map.Entities[i].ClassName;
        end;
    end;
  Self.EditFacePlaneIndex.Caption:=' ' + IntToStr(CurrFaceExt.BaseFace.iPlane);
  Self.EditFaceCountVertex.Caption:=' ' + IntToStr(CurrFaceExt.Polygon.CountVertecies);
  Self.EditFaceTexInfo.Caption:=' ' + IntToStr(CurrFaceExt.BaseFace.iTextureInfo);

  Self.EditFacePlaneX.Caption:=' ' + FloatToStrFixed(CurrFaceExt.Polygon.Plane.Normal.x);
  Self.EditFacePlaneY.Caption:=' ' + FloatToStrFixed(CurrFaceExt.Polygon.Plane.Normal.y);
  Self.EditFacePlaneZ.Caption:=' ' + FloatToStrFixed(CurrFaceExt.Polygon.Plane.Normal.z);
  Self.EditFacePlaneD.Caption:=' ' + FloatToStrFixed(CurrFaceExt.Polygon.Plane.Dist);
  Self.EditFacePlaneF.Caption:=' ' + PlaneTypeToStrExt(
    Map.PlaneLump[CurrFaceExt.PlaneIndex].AxisType
  );

  lpTexInfo:=@Map.TexInfoLump[CurrFaceExt.BaseFace.iTextureInfo];
  Self.EditFaceTexSx.Caption:=' ' + FloatToStr(lpTexInfo.vS.x);
  Self.EditFaceTexSy.Caption:=' ' + FloatToStr(lpTexInfo.vS.y);
  Self.EditFaceTexSz.Caption:=' ' + FloatToStr(lpTexInfo.vS.z);
  Self.EditFaceTexSShift.Caption:=' ' + FloatToStr(lpTexInfo.fSShift);
  Self.EditFaceTexTx.Caption:=' ' + FloatToStr(lpTexInfo.vT.x);
  Self.EditFaceTexTy.Caption:=' ' + FloatToStr(lpTexInfo.vT.y);
  Self.EditFaceTexTz.Caption:=' ' + FloatToStr(lpTexInfo.vT.z);
  Self.EditFaceTexTShift.Caption:=' ' + FloatToStr(lpTexInfo.fTShift);
  Self.EditFaceTexFlags.Caption:=' 0x' + IntToHex(lpTexInfo.nFlags, 8);

  Self.EditTexIndex.Caption:=' ' + IntToStr(CurrFaceExt.Wad3TextureIndex);
  Self.EditTexName.Caption:=' ' + PAnsiChar(CurrFaceExt.TexName);
  Self.EditTexSize.Caption:=' ' +
    IntToStr(Map.TextureLump.Wad3Textures[CurrFaceExt.Wad3TextureIndex].nWidth)
    + 'x' +
    IntToStr(Map.TextureLump.Wad3Textures[CurrFaceExt.Wad3TextureIndex].nHeight);

  Self.EditLmpSize.Caption:=' (Approx.) ' + IntToStr(CurrFaceExt.LmpSize.x) + 'x' +
    IntToStr(CurrFaceExt.LmpSize.y);
  Self.EditLmpStyle1.Caption:='';
  Self.EditLmpStyle2.Caption:='';
  Self.EditLmpStyle3.Caption:='';
  if (CurrFaceExt.CountLightStyles > 0) then
    begin
      Self.EditLmpSize.Caption:=' ' + IntToStr(CurrFaceExt.LmpSize.x) + 'x' +
        IntToStr(CurrFaceExt.LmpSize.y);
      if (CurrFaceExt.BaseFace.nStyles[1] >= 0) then
        begin
          i:=FindLightStylePair(
            @Map.LightStylesList[0],
            Map.CountLightStyles,
            CurrFaceExt.BaseFace.nStyles[1]
          );
          Self.EditLmpStyle1.Caption:=' ' + IntToStr(CurrFaceExt.BaseFace.nStyles[1]) +
            ': ' + Map.LightStylesList[i].TargetName;
        end;
      if (CurrFaceExt.BaseFace.nStyles[2] >= 0) then
        begin
          i:=FindLightStylePair(
            @Map.LightStylesList[0],
            Map.CountLightStyles,
            CurrFaceExt.BaseFace.nStyles[2]
          );
          Self.EditLmpStyle2.Caption:=' ' + IntToStr(CurrFaceExt.BaseFace.nStyles[2]) +
            ': ' + Map.LightStylesList[i].TargetName;
        end;
      if (CurrFaceExt.BaseFace.nStyles[3] >= 0) then
        begin
          i:=FindLightStylePair(
            @Map.LightStylesList[0],
            Map.CountLightStyles,
            CurrFaceExt.BaseFace.nStyles[3]
          );
          Self.EditLmpStyle3.Caption:=' ' + IntToStr(CurrFaceExt.BaseFace.nStyles[3]) +
            ': ' + Map.LightStylesList[i].TargetName;
        end;
    end;

  Self.RadioGroupLmp.Items.Clear();
  for i:=0 to (CurrFaceExt.CountLightStyles - 1) do
    begin
      Self.RadioGroupLmp.Items.Append('Style ' + IntToStr(i));
    end;
  Self.RadioGroupLmp.ItemIndex:=SelectedStyle;

  if (BasetextureMng.DrawThumbnailToBitmap(
        BaseThumbnailBMP,
        CurrFaceExt.TexRenderId,
        SelectedMipmap
      ) = False) then
    begin
      BaseThumbnailBMP.Canvas.FillRect(BaseThumbnailBMP.Canvas.ClipRect);
    end;
  Self.ImagePreviewBT.Canvas.Draw(0, 0, BaseThumbnailBMP);

  GetTexureCoordST(TraceInfo.Point.Vec3f, lpTexInfo^, UV);
  Self.EditFaceTexUV.Caption:=FloatToStrFixed(UV.x) + ' ' + FloatToStrFixed(UV.y);
  UV.x:=(UV.x*inv16 - CurrFaceExt.LmpMin.x + 0.5);
  UV.y:=(UV.y*inv16 - CurrFaceExt.LmpMin.y + 0.5);
  Self.EditFaceLmpUV.Caption:=FloatToStrFixed(UV.x) + ' ' + FloatToStrFixed(UV.y);

  Self.Update();
  {$R+}
end;

procedure TMainForm.ClearFaceVisualInfo();
begin
  {$R-}
  Self.EditFaceIndex.Caption:='';
  Self.EditFaceBrushIndex.Caption:='';
  Self.EditFaceEntityName.Caption:=' Entity Targetname';
  Self.EditFaceEntityClass.Caption:=' Entity Classname';
  Self.EditFacePlaneIndex.Caption:='';
  Self.EditFaceCountVertex.Caption:='';
  Self.EditFaceTexInfo.Caption:='';

  Self.EditFacePlaneX.Caption:='';
  Self.EditFacePlaneY.Caption:='';
  Self.EditFacePlaneZ.Caption:='';
  Self.EditFacePlaneD.Caption:='';
  Self.EditFacePlaneF.Caption:='';

  Self.EditFaceTexSx.Caption:='';
  Self.EditFaceTexSy.Caption:='';
  Self.EditFaceTexSz.Caption:='';
  Self.EditFaceTexSShift.Caption:='';
  Self.EditFaceTexTx.Caption:='';
  Self.EditFaceTexTy.Caption:='';
  Self.EditFaceTexTz.Caption:='';
  Self.EditFaceTexTShift.Caption:='';
  Self.EditFaceTexFlags.Caption:='';

  Self.EditTexIndex.Caption:='';
  Self.EditTexName.Caption:='';
  Self.EditTexSize.Caption:='';
  Self.ImagePreviewBT.Canvas.Brush.Color:=clBlack;
  Self.ImagePreviewBT.Canvas.FillRect(Self.ImagePreviewBT.Canvas.ClipRect);

  Self.EditLmpSize.Caption:='';
  Self.EditLmpStyle1.Caption:='';
  Self.EditLmpStyle2.Caption:='';
  Self.EditLmpStyle3.Caption:='';

  Self.EditFaceTexUV.Caption:='';
  Self.EditFaceLmpUV.Caption:='';

  Self.RadioGroupLmp.Items.Clear();
  Self.RadioButtonMip0.Checked:=True;
  Self.Update();
  {$R+}
end;


procedure TMainForm.ButtonSaveLmpClick(Sender: TObject);
var
  LmpBitmap: TBitmap;
begin
  {$R-}
  if (SelectedFaceIndex < 0) then Exit;
  if (Self.RadioGroupLmp.ItemIndex >= CurrFaceExt.CountLightStyles) then Exit;
  if (Self.RadioGroupLmp.ItemIndex < 0) then Exit;
  if (CurrFaceExt.CountLightmaps <= 0) then Exit;

  if (Self.SaveDialogBMP.Execute) then
    begin
      LmpBitmap:=TBitmap.Create();
      LmpBitmap.PixelFormat:=pf24bit;
      LmpBitmap.Width:=CurrFaceExt.LmpSize.X;
      LmpBitmap.Height:=CurrFaceExt.LmpSize.Y;
      //
      CopyRGB888toBitmap(
        @CurrFaceExt.Lightmaps[CurrFaceExt.LmpSquare*Self.RadioGroupLmp.ItemIndex],
        LmpBitmap
      );  
      //
      LmpBitmap.SaveToFile(Self.SaveDialogBMP.FileName);
      LmpBitmap.Destroy(); //}
    end;
  {$R+}
end;

procedure TMainForm.ButtonLoadLmpClick(Sender: TObject);
var
  LmpBitmap: TBitmap;
begin
  {$R-}
  if (SelectedFaceIndex < 0) then Exit;
  if (Self.RadioGroupLmp.ItemIndex >= CurrFaceExt.CountLightStyles) then Exit;
  if (Self.RadioGroupLmp.ItemIndex < 0) then Exit;
  if (CurrFaceExt.CountLightmaps <= 0) then Exit;

  Self.OpenDialogBMP.Title:='Load lightmap with style index '
    + IntToStr(Self.RadioGroupLmp.ItemIndex);
  if (Self.OpenDialogBMP.Execute) then
    begin
      LmpBitmap:=TBitmap.Create();
      LmpBitmap.LoadFromFile(Self.OpenDialogBMP.FileName);
      if ((LmpBitmap.Width <> CurrFaceExt.LmpSize.X)
        or (LmpBitmap.Height <> CurrFaceExt.LmpSize.Y)) then
        begin
          ShowMessage('Error! Loaded Bitmap have difference size:' + LF +
            'Bitmap size (X, Y): (' + IntToStr(LmpBitmap.Width) + '; ' +
            IntToStr(LmpBitmap.Height) + ')' + LF +
            'Requarement size (X, Y): (' + IntToStr(CurrFaceExt.LmpSize.X) +
            LF + '; ' + IntToStr(CurrFaceExt.LmpSize.Y) + ')');
          Exit;
        end;

      if (Self.RadioGroupLmp.ItemIndex = 0) then
        begin
          CopyBitmapToRGB888(LmpBitmap, @CurrFaceExt.Lightmaps[0]);
          LightmapMegatexture.UpdateTextureFromArray(
            CurrFaceExt.LmpMegaId,
            CurrFaceExt.LmpRegionId,
            @CurrFaceExt.Lightmaps[0],
            nil
          );
        end
      else
        begin
          CopyBitmapToRGB888(
            LmpBitmap,
            @CurrFaceExt.Lightmaps[CurrFaceExt.LmpSquare*Self.RadioGroupLmp.ItemIndex]
          );
          LightmapMegatexture.UpdateTextureFromArray(
            CurrFaceExt.LmpMegaId,
            CurrFaceExt.LmpRegionId + Self.RadioGroupLmp.ItemIndex,
            @CurrFaceExt.Lightmaps[0],
            @CurrFaceExt.Lightmaps[CurrFaceExt.LmpSquare*Self.RadioGroupLmp.ItemIndex]
          );
        end;
      Self.UpdateFaceVisualInfo();
    end;
  {$R+}
end;

procedure TMainForm.ButtonDeleteLmpClick(Sender: TObject);
var
  i: Integer;
begin
  {$R-}
  if (SelectedFaceIndex < 0) then Exit;
  if (Self.RadioGroupLmp.ItemIndex >= CurrFaceExt.CountLightStyles) then Exit;
  if (Self.RadioGroupLmp.ItemIndex < 0) then Exit;
  if (CurrFaceExt.CountLightmaps <= 0) then Exit;


  // Remove lightmap from face do not resolve lightmap Megatextures
  if (Self.RadioGroupLmp.ItemIndex = 0) then
    begin
      // Remove all lightmaps, include all styles
      i:=MessageDlg(
            'Rremoving the zero lightmap style will be followed by the complete'
            + ' removal of all other styles for this Face. Do you want continue'
            + ' "delete all lightmap styles"?',
            mtWarning, [mbYes, mbNo], 0
          );
      if (i <> mrYes) then Exit;

      SetLength(CurrFaceExt.Lightmaps, 0);
      CurrFaceExt.CountLightmaps:=0;
      CurrFaceExt.CountLightStyles:=0;
      PDWORD(@CurrFaceExt.BaseFace.nStyles)^:=$FFFFFFFF;
      CurrFaceExt.LmpMegaId:=MEGATEXTURE_DUMMY_MEGAID;
      CurrFaceExt.LmpRegionId:=MEGATEXTURE_DUMMY_REGIONID;
      CurrFaceExt.isDummyLightmaps:=True;
      SetLength(CurrFaceExt.LmpMegaCoords, CurrFaceExt.Polygon.CountVertecies);
      for i:=0 to (CurrFaceExt.Polygon.CountVertecies - 1) do
        begin
          CurrFaceExt.LmpMegaCoords[i]:=VEC_ZERO_2F;
        end;
    end
  else
    begin
      // Remove current style, with shift "upper" styles down
      Dec(CurrFaceExt.CountLightStyles);
      CurrFaceExt.CountLightmaps:=CurrFaceExt.LmpSquare*CurrFaceExt.CountLightStyles;
      for i:=Self.RadioGroupLmp.ItemIndex to (CurrFaceExt.CountLightStyles - 1) do
        begin
          CurrFaceExt.BaseFace.nStyles[i]:=CurrFaceExt.BaseFace.nStyles[i + 1];
        end;
      CurrFaceExt.BaseFace.nStyles[CurrFaceExt.CountLightStyles]:=-1;
      for i:=Self.RadioGroupLmp.ItemIndex*CurrFaceExt.LmpSquare to
        (CurrFaceExt.CountLightmaps - 1) do
        begin
          CurrFaceExt.Lightmaps[i]:=CurrFaceExt.Lightmaps[i + CurrFaceExt.LmpSquare];
        end;
      SetLength(CurrFaceExt.Lightmaps, CurrFaceExt.CountLightmaps);
      for i:=Self.RadioGroupLmp.ItemIndex*CurrFaceExt.Polygon.CountVertecies to
        (CurrFaceExt.CountLightStyles*CurrFaceExt.Polygon.CountVertecies) do
        begin
          CurrFaceExt.LmpMegaCoords[i]:=CurrFaceExt.LmpMegaCoords[i + CurrFaceExt.Polygon.CountVertecies];
        end;
      SetLength(CurrFaceExt.LmpMegaCoords, CurrFaceExt.Polygon.CountVertecies*CurrFaceExt.CountLightStyles);
    end;
    
  // Rebuild light entities and styles
  RebuildEntityLightStylesList(@Map);
  Self.UpdateFaceVisualInfo();
  {$R+}
end;

procedure TMainForm.ButtonAddLmpClick(Sender: TObject);
var
  i, j: Integer;
begin
  {$R-}
  if (SelectedFaceIndex < 0) then Exit;

  if (CurrFaceExt.CountLightStyles <= 0) then
    begin
      // Case when no lightmap data to face - then add zero style, but if face
      // don't contain special texture (texinfo flags = 0)
      if (Map.TexInfoLump[CurrFaceExt.BaseFace.iTextureInfo].nFlags <> 0) then
        begin
          ShowMessage(
            'Face reference to Texture with special bsp flag for no lightmaps!' + LF +
            'Sorry, creation lightmaps for flagged textures unsupported in current program version.'
          );
          Exit;
        end;
      if ((CurrFaceExt.LmpSize.x <= 2) or (CurrFaceExt.LmpSize.y <= 2) or
        (CurrFaceExt.LmpSize.x >= MEGATEXTURE_SIZE) or
        (CurrFaceExt.LmpSize.y >= MEGATEXTURE_SIZE)) then
        begin
          ShowMessage(
            'Face contain invalid size for adding lightmaps: ' +
            IntToStr(CurrFaceExt.LmpSize.x) + 'x' + IntToStr(CurrFaceExt.LmpSize.y) + LF +
            'size must be great or equal 2x2 and less then ' +
            IntToStr(MEGATEXTURE_SIZE) + 'x' + IntToStr(MEGATEXTURE_SIZE) + '!'
          );
          Exit;
        end;

      CurrFaceExt.CountLightStyles:=1;
      CurrFaceExt.CountLightmaps:=CurrFaceExt.LmpSquare;
      CurrFaceExt.BaseFace.nStyles[0]:=0;
      CurrFaceExt.isDummyLightmaps:=False;
      SetLength(CurrFaceExt.Lightmaps, CurrFaceExt.CountLightmaps);
      SetLength(CurrFaceExt.LmpMegaCoords, CurrFaceExt.Polygon.CountVertecies);
      ZeroFillChar(@CurrFaceExt.Lightmaps[0], CurrFaceExt.CountLightmaps);
      
      LightmapMegatexture.Clear();
      Self.GenerateLightmapMegatexture();
      Self.UpdateFaceVisualInfo();
      Exit;
    end;

  if (CurrFaceExt.CountLightStyles = 4) then
    begin
      ShowMessage('Face already have all 4 light styles, cannot add more!');
      Exit;
    end;

  // case where CurrFaceExt.CountLightStyles = 1..3, where we can add only named styles
  i:=StrToIntDef(InputBox(
    'Add new lightmap to Face...',
    'Please, select light style for add in Face from Table:' + LF
    + ShowLightStylesTable(@Map.LightStylesList[0], Map.CountLightStyles),
    '-1'), -1
  );
  j:=FindLightStylePair(@Map.LightStylesList[0], Map.CountLightStyles, i);
  if (j < 0) then
    begin
      ShowMessage('Invalid style input!');
      Exit;
    end;

  Inc(CurrFaceExt.CountLightStyles);
  CurrFaceExt.BaseFace.nStyles[CurrFaceExt.CountLightStyles - 1]:=i;
  Inc(CurrFaceExt.CountLightmaps, CurrFaceExt.LmpSquare);
  SetLength(CurrFaceExt.Lightmaps, CurrFaceExt.CountLightmaps);
  SetLength(CurrFaceExt.LmpMegaCoords,
    CurrFaceExt.CountLightStyles*CurrFaceExt.Polygon.CountVertecies);

  LightmapMegatexture.Clear();
  Self.GenerateLightmapMegatexture();
  Self.UpdateFaceVisualInfo();
  {$R+}
end;

procedure TMainForm.ButtonLoadTexClick(Sender: TObject);
var
  i: Integer;
  CurrWad3Texture: PWad3Texture;
begin
  {$R-}
  if (SelectedFaceIndex < 0) then Exit;

  Self.OpenDialogBMP.Title:='Load texture from Bitmap of MipIndex ' + IntToStr(SelectedMipmap);
  if (Self.OpenDialogBMP.Execute) then
    begin
      CurrWad3Texture:=@Map.TextureLump.Wad3Textures[CurrFaceExt.Wad3TextureIndex];
      if (CurrFaceExt.isDummyTexture) then
        begin
          CurrWad3Texture.PaletteColors:=256;
          AllocTexture(CurrWad3Texture);
          AllocPalette(CurrWad3Texture);
          if (UpdateTextureFromBitmap(Self.OpenDialogBMP.FileName, CurrWad3Texture, 0)) then
            begin
              CurrFaceExt.TexName:=@CurrWad3Texture.szName;
              CurrFaceExt.isDummyTexture:=False;
              BasetextureMng.AppendBasetexture(CurrWad3Texture^);
              for i:=0 to (Map.CountFaces - 1) do
                begin
                  Map.FaceExtList[i].TexRenderId:=BasetextureMng.GetBasetextureIdByName(
                    Map.FaceExtList[i].TexName
                  );
                  if (Map.FaceExtList[i].TexRenderId < 0) then
                    begin
                      Map.FaceExtList[i].TexRenderId:=BASETEXTURE_DUMMY_ID;
                    end
                  else
                    begin
                      Map.FaceExtList[i].isDummyTexture:=False;
                    end;
                end;

              if (BasetextureMng.DrawThumbnailToBitmap(
                    BaseThumbnailBMP,
                    CurrFaceExt.TexRenderId,
                    SelectedMipmap
                  ) = False) then
                begin
                  BaseThumbnailBMP.Canvas.FillRect(BaseThumbnailBMP.Canvas.ClipRect);
                end;
              Self.ImagePreviewBT.Canvas.Draw(0, 0, BaseThumbnailBMP);
              Self.Update();
            end
          else
            begin
              ShowMessage('Error create new texture: Cannot open and read Bitmap file!');
              FreeTextureAndPalette(CurrWad3Texture);
            end;
        end
      else
        begin
          if (UpdateTextureFromBitmap(Self.OpenDialogBMP.FileName, CurrWad3Texture, SelectedMipmap)) then
            begin
              BasetextureMng.UpdateBasetexture(CurrWad3Texture^, CurrFaceExt.TexRenderId);
              if (BasetextureMng.DrawThumbnailToBitmap(
                    BaseThumbnailBMP,
                    CurrFaceExt.TexRenderId,
                    SelectedMipmap
                  ) = False) then
                begin
                  BaseThumbnailBMP.Canvas.FillRect(BaseThumbnailBMP.Canvas.ClipRect);
                end;
              Self.ImagePreviewBT.Canvas.Draw(0, 0, BaseThumbnailBMP);
              Self.Update();
            end
          else
            begin
              ShowMessage('Error load texture: Cannot open and read Bitmap file'
                + LF + 'or Bitmap have invalid size!');
            end;
        end;
    end;
  {$R+}
end;

procedure TMainForm.ButtonSaveTexClick(Sender: TObject);
begin
  {$R-}
  if ((SelectedFaceIndex < 0) or (CurrFaceExt.isDummyTexture)) then Exit;

  if (Self.SaveDialogBMP.Execute) then
    begin
      SaveTextureToBitmap(Self.SaveDialogBMP.FileName,
        @Map.TextureLump.Wad3Textures[CurrFaceExt.Wad3TextureIndex],
        SelectedMipmap
      );
    end;
  {$R+}
end;

procedure TMainForm.ButtonTexRebuildMipsClick(Sender: TObject);
begin
  {$R-}
  if ((SelectedFaceIndex < 0) or (CurrFaceExt.isDummyTexture)) then Exit;
  RebuildMipMaps(@Map.TextureLump.Wad3Textures[CurrFaceExt.Wad3TextureIndex]);
  BasetextureMng.UpdateBasetexture(
    Map.TextureLump.Wad3Textures[CurrFaceExt.Wad3TextureIndex],
    CurrFaceExt.TexRenderId
  );
  {$R+}
end;

procedure TMainForm.ButtonDeleteTexClick(Sender: TObject);
var
  CurrWad3Texture: PWad3Texture;
begin
  {$R-}
  if ((SelectedFaceIndex < 0) or (CurrFaceExt.isDummyTexture)) then Exit;

  BasetextureMng.DeleteBasetexture(CurrFaceExt.TexRenderId);
  CurrWad3Texture:=@Map.TextureLump.Wad3Textures[CurrFaceExt.Wad3TextureIndex];
  FreeTextureAndPalette(CurrWad3Texture);
  CurrWad3Texture.nOffsets[0]:=0;
  CurrWad3Texture.nOffsets[1]:=0;
  CurrWad3Texture.nOffsets[2]:=0;
  CurrWad3Texture.nOffsets[3]:=0;

  Self.UpdateFaceVisualInfo();
  {$R+}
end;



procedure TMainForm.RadioButtonMip0Click(Sender: TObject);
begin
  {$R+}
  SelectedMipmap:=0;
  if ((SelectedFaceIndex < 0) or (CurrFaceExt.isDummyTexture)) then Exit;
  if (BasetextureMng.DrawThumbnailToBitmap(
        BaseThumbnailBMP,
        CurrFaceExt.TexRenderId,
        SelectedMipmap
      ) = False) then
    begin
      BaseThumbnailBMP.Canvas.FillRect(BaseThumbnailBMP.Canvas.ClipRect);
    end;
  Self.ImagePreviewBT.Canvas.Draw(0, 0, BaseThumbnailBMP);
  Self.Update();
  {$R+}
end;

procedure TMainForm.RadioButtonMip1Click(Sender: TObject);
begin
  {$R+}
  SelectedMipmap:=1;
  if ((SelectedFaceIndex < 0) or (CurrFaceExt.isDummyTexture)) then Exit;
  if (BasetextureMng.DrawThumbnailToBitmap(
        BaseThumbnailBMP,
        CurrFaceExt.TexRenderId,
        SelectedMipmap
      ) = False) then
    begin
      BaseThumbnailBMP.Canvas.FillRect(BaseThumbnailBMP.Canvas.ClipRect);
    end;
  Self.ImagePreviewBT.Canvas.Draw(0, 0, BaseThumbnailBMP);
  Self.Update();
  {$R+}
end;

procedure TMainForm.RadioButtonMip2Click(Sender: TObject);
begin
  {$R+}
  SelectedMipmap:=2;
  if ((SelectedFaceIndex < 0) or (CurrFaceExt.isDummyTexture)) then Exit;
  if (BasetextureMng.DrawThumbnailToBitmap(
        BaseThumbnailBMP,
        CurrFaceExt.TexRenderId,
        SelectedMipmap
      ) = False) then
    begin
      BaseThumbnailBMP.Canvas.FillRect(BaseThumbnailBMP.Canvas.ClipRect);
    end;
  Self.ImagePreviewBT.Canvas.Draw(0, 0, BaseThumbnailBMP);
  Self.Update();
  {$R+}
end;

procedure TMainForm.RadioButtonMip3Click(Sender: TObject);
begin
  {$R+}
  SelectedMipmap:=3;
  if ((SelectedFaceIndex < 0) or (CurrFaceExt.isDummyTexture)) then Exit;
  if (BasetextureMng.DrawThumbnailToBitmap(
        BaseThumbnailBMP,
        CurrFaceExt.TexRenderId,
        SelectedMipmap
      ) = False) then
    begin
      BaseThumbnailBMP.Canvas.FillRect(BaseThumbnailBMP.Canvas.ClipRect);
    end;
  Self.ImagePreviewBT.Canvas.Draw(0, 0, BaseThumbnailBMP);
  Self.Update();
  {$R+}
end;


procedure TMainForm.LoadMapMenuClick(Sender: TObject);
begin
  {$R-}
  if (Self.OpenDialogBsp.Execute) then
    begin
      isBspLoad:=LoadBSP30FromFile(Self.OpenDialogBsp.FileName, @Map);
      if (isBspLoad = False) then
        begin
          ShowMessage('Error load Map: ' + LF
            + ShowLoadBSPMapError(Map.LoadState)
          );
          FreeMapBSP(@Map);
        end
      else
        begin
          Self.LoadMapMenu.Enabled:=False;
          Self.CloseMapMenu.Enabled:=True;
          Self.SaveMapMenu.Enabled:=True;
          Self.GotoFaceIdSubmenu.Enabled:=True;
          Self.GotoVisLeafIdSubMenu.Enabled:=True;
          Self.GotoBModelIdSubMenu.Enabled:=True;
          Self.GotoEntTGNSubMenu.Enabled:=True;
          Self.Caption:=Self.OpenDialogBsp.FileName;

          FirstSpawnEntityId:=FindFirstSpawnEntity(@Map.Entities[0], Map.CountEntities);
          if (FirstSpawnEntityId >= 1) then
            begin
              Self.Camera.ResetCamera(
                Map.Entities[FirstSpawnEntityId].Origin,
                Map.Entities[FirstSpawnEntityId].Angles.x*AngleToRadian,
                Map.Entities[FirstSpawnEntityId].Angles.y*AngleToRadian - Pi/2
              );
            end;

          FillChar(FacesIndexToRender[0], Map.CountFaces, not RenderFrameIterator);
          FillChar(LeafIndexToRender[0], Map.CountVisLeafWithPVS, not RenderFrameIterator);
          FillChar(BrushIndexToRender[0], Map.CountBrushModels, not RenderFrameIterator);

          Self.GenerateBasetextures();
          Self.GenerateLightmapMegatexture();
        end;
    end;
  {$R+}
end;

procedure TMainForm.CloseMapMenuClick(Sender: TObject);
begin
  {$R-}
  Self.Camera.ResetCamera(
    DefaultCameraPos,
    DefaultCameraPolarAngle,
    DefaultCameraAzimutalAngle
  );

  isBspLoad:=False;
  Self.Caption:=MainFormCaption;

  Self.LoadMapMenu.Enabled:=True;
  Self.SaveMapMenu.Enabled:=False;
  Self.CloseMapMenu.Enabled:=False;
  Self.GotoFaceIdSubmenu.Enabled:=False;
  Self.GotoVisLeafIdSubMenu.Enabled:=False;
  Self.GotoBModelIdSubMenu.Enabled:=False;
  Self.GotoEntTGNSubMenu.Enabled:=False;

  Self.LmpPixelModeMenu.Checked:=False;
  Self.TexPixelModeMenu.Checked:=False;

  FreeMapBSP(@Map);

  CameraLeafId:=0;
  CameraLastLeafId:=0;
  FirstSpawnEntityId:=0;
  SelectedFaceIndex:=-1;
  SelectedStyle:=0;
  SelectedMipmap:=0;
  lpCameraLeaf:=nil;
  CurrFaceExt:=nil;

  Self.LabelCameraLeafId.Caption:='No map load';
  Self.LabelStylePage.Caption:='Style page (0..3): 0';
  Self.ClearFaceVisualInfo();

  LightmapMegatexture.Clear();
  BasetextureMng.Clear();
  {$R+}
end;

procedure TMainForm.SaveMapMenuClick(Sender: TObject);
begin
  {$R-}
  if (isBspLoad = False) then Exit;

  if (Self.SaveDialogBsp.Execute) then
    begin
      SaveBSP30ToFile(Self.SaveDialogBsp.FileName, @Map);
    end;
  {$R+}
end;

procedure TMainForm.ResetCameraMenuClick(Sender: TObject);
begin
  {$R-}
  if (isBspLoad) then
    begin
      if (FirstSpawnEntityId >= 1) then
        begin
          Self.Camera.ResetCamera(
            Map.Entities[FirstSpawnEntityId].Origin,
            Map.Entities[FirstSpawnEntityId].Angles.x*AngleToRadian,
            Map.Entities[FirstSpawnEntityId].Angles.y*AngleToRadian - Pi/2
          );
        end
      else
        begin
          Self.Camera.ResetCamera(
            DefaultCameraPos,
            DefaultCameraPolarAngle,
            DefaultCameraAzimutalAngle
          );
        end;
    end
  else
    begin
      Self.Camera.ResetCamera(
        DefaultCameraPos,
        DefaultCameraPolarAngle,
        DefaultCameraAzimutalAngle
      );
    end;
  {$R+}
end;

procedure TMainForm.ShowHeaderMenuClick(Sender: TObject);
begin
  {$R-}
  if (isBspLoad) then
    begin
      ShowMessage(ShowMapHeaderInfo(Map.MapHeader) + LF
        + 'Count textures: ' + IntToStr(Map.TextureLump.nCountTextures) + LF
        + 'Entities (with "worldspawn"): ' + IntToStr(Map.CountEntities) + LF
        + 'Count VisLeafs with PVS: ' + IntToStr(Map.CountVisLeafWithPVS) + LF
        + 'Max count vertecies per Face: ' + IntToStr(Map.MaxVerteciesPerFace) + LF
        + 'Avg count vertecies per Face: '
          + FloatToStrF(Map.AvgVerteciesPerFace/Map.CountFaces, ffFixed, 2, 2) + LF
        + 'Total Face triangles on Map: ' + IntToStr(Map.TotalTrianglesCount) + LF
        + 'Count generated ' + IntToStr(MEGATEXTURE_SIZE) + 'x'
          + IntToStr(MEGATEXTURE_SIZE)
          + ' Lightmap 2D Megatextures: '
          + IntToStr(LightmapMegatexture.CountMegatextures) + LF
        + 'Max lightmap size in Megatexture: '
          + IntToStr(LightmapMegatexture.MaxRegionSizeX) + 'x'
          + IntToStr(LightmapMegatexture.MaxRegionSizeY) + LF
        + 'Max possible lightmap size on map: '
          + IntToStr(Map.MaxLightmapSize.x) + 'x' + IntToStr(Map.MaxLightmapSize.y)
      );
    end;
  {$R+}
end;

procedure TMainForm.ShowFaceVertexHistogramMenuClick(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  {$R-}
  if (isBspLoad) then
    begin
      s:='';
      for i:=0 to (HISTOGRAM_FACE_VERTEX_SIZE - 1) do
        begin
          s:=s + IntToStr(i) + ': '
            + FloatToStrF(100*Map.FaceVertexHist[i]/Map.CountFaces, ffFixed, 4, 2)
            + '%; ' + IntToStr(Map.FaceVertexHist[i])
            + '; ' + FloatToStrF(100*Map.WindingHist[i]/Map.CountFaces, ffFixed, 4, 2)
            + '%; ' + IntToStr(Map.WindingHist[i]) + LF;
        end;
      ShowMessage(
          'Vertex per Face histogram (first value - count of vertex per face,' + LF
        + 'second and third value - % from all faces and count of faces, ' + LF
        + 'four and five value - same with remove colinear vertex)' + LF
        + s
        + 'Faces with count of vertex >= ' + IntToStr(HISTOGRAM_FACE_VERTEX_SIZE)
        + ': ' + FloatToStrF(100*Map.FaceVertexHistOutOfRangeCnt/Map.CountFaces, ffFixed, 4, 2)
        + '%; ' + IntToStr(Map.FaceVertexHistOutOfRangeCnt)
        + '; ' + FloatToStrF(100*Map.WindingHistOutOfRangeCnt/Map.CountFaces, ffFixed, 4, 2)
        + '%; ' + IntToStr(Map.WindingHistOutOfRangeCnt) + LF
        + 'Total count of faces on map: ' + IntToStr(Map.CountFaces)
      );
    end;
  {$R+}
end;

procedure TMainForm.ShowLightStylesMenuClick(Sender: TObject);
begin
  {$R-}
  ShowMessage('Light styles on map, '
    + ShowLightStylesTable(@Map.LightStylesList[0], Map.CountLightStyles)
  );
  {$R+}
end;

procedure TMainForm.ShowOpenGLInformationMenuClick(Sender: TObject);
begin
  {$R-}
  ShowMessage(
    'GL_VERSION: ' + OpenGLVersion + LF +
    'GL_VENDOR: ' + OpenGLVendor + LF +
    'GL_RENDERER: ' + OpenGLRenderer + LF +
    'GL_EXTENSIONS: ' + LF + OpenGLExtArbList
  );
  {$R+}
end;

procedure TMainForm.CollisionMenuClick(Sender: TObject);
begin
  {$R+}
  Self.CollisionMenu.Checked:=not Self.CollisionMenu.Checked;
  {$R-}
end;


procedure TMainForm.WireframeEntBrushesMenuClick(Sender: TObject);
begin
  {$R-}
  Self.WireframeEntBrushesMenu.Checked:=not Self.WireframeEntBrushesMenu.Checked;
  {$R+}
end;

procedure TMainForm.WireframeHighlighEntBrushesMenuClick(Sender: TObject);
begin
  {$R-}
  Self.WireframeHighlighEntBrushesMenu.Checked:=not Self.WireframeHighlighEntBrushesMenu.Checked;
  {$R+}
end;

procedure TMainForm.DrawFaceContourMenuClick(Sender: TObject);
begin
  {$R-}
  Self.DrawFaceContourMenu.Checked:=not Self.DrawFaceContourMenu.Checked;
  {$R+}
end;


procedure TMainForm.SetSelectedFaceColorMenuClick(Sender: TObject);
begin
  {$R-}
  Self.ColorDialog.Color:=RGB(
    Round(Self.FaceSelectedColor[0]*255),
    Round(Self.FaceSelectedColor[1]*255),
    Round(Self.FaceSelectedColor[2]*255)
  );
  if (Self.ColorDialog.Execute) then
    begin
      Self.FaceSelectedColor[0]:=GetRValue(Self.ColorDialog.Color)*inv255;
      Self.FaceSelectedColor[1]:=GetGValue(Self.ColorDialog.Color)*inv255;
      Self.FaceSelectedColor[2]:=GetBValue(Self.ColorDialog.Color)*inv255;
    end;
  {$R+}
end;

procedure TMainForm.SetWireframeFaceColorMenuClick(Sender: TObject);
begin
  {$R-}
  Self.ColorDialog.Color:=RGB(
    Round(Self.FaceWireframeColor[0]*255),
    Round(Self.FaceWireframeColor[1]*255),
    Round(Self.FaceWireframeColor[2]*255)
  );
  if (Self.ColorDialog.Execute) then
    begin
      Self.FaceWireframeColor[0]:=GetRValue(Self.ColorDialog.Color)*inv255;
      Self.FaceWireframeColor[1]:=GetGValue(Self.ColorDialog.Color)*inv255;
      Self.FaceWireframeColor[2]:=GetBValue(Self.ColorDialog.Color)*inv255;
    end;
  {$R+}
end;

procedure TMainForm.RenderBBOXVisLeafClick(Sender: TObject);
begin
  {$R-}
  Self.RenderBBOXVisLeaf.Checked:=not Self.RenderBBOXVisLeaf.Checked;
  {$R+}
end;

procedure TMainForm.DrawTriggersMenuClick(Sender: TObject);
begin
  {$R-}
  Self.DrawTriggersMenu.Checked:=not Self.DrawTriggersMenu.Checked;
  Self.GetFaceRenderList();
  {$R+}
end;

procedure TMainForm.DrawEntityBrushesMenuClick(Sender: TObject);
begin
  {$R-}
  Self.DrawEntityBrushesMenu.Checked:=not Self.DrawEntityBrushesMenu.Checked;
  Self.GetFaceRenderList();
  {$R+}
end;


procedure TMainForm.LmpPixelModeMenuClick(Sender: TObject);
begin
  {$R-}
  LightmapMegatexture.SetFiltrationMode(Self.LmpPixelModeMenu.Checked);
  Self.LmpPixelModeMenu.Checked:=not Self.LmpPixelModeMenu.Checked;
  {$R+}
end;

procedure TMainForm.TexPixelModeMenuClick(Sender: TObject);
begin
  {$R-}
  BasetextureMng.SetFiltrationMode(Self.TexPixelModeMenu.Checked);
  Self.TexPixelModeMenu.Checked:=not Self.TexPixelModeMenu.Checked;
  {$R+}
end;

procedure TMainForm.DisableLightmapsMenuClick(Sender: TObject);
begin
  {$R-}
  Self.DisableLightmapsMenu.Checked:=not Self.DisableLightmapsMenu.Checked;
  Self.UpdFaceDrawState();
  {$R+}
end;

procedure TMainForm.DisableTexturesMenuClick(Sender: TObject);
begin
  {$R-}
  Self.DisableTexturesMenu.Checked:=not Self.DisableTexturesMenu.Checked;
  Self.UpdFaceDrawState();
  {$R+}
end;


procedure TMainForm.LmpOverBright1MenuClick(Sender: TObject);
begin
  {$R-}
  LightmapMegatexture.SetOverbrightMode(1);
  Self.LmpOverBright1Menu.Checked:=True;
  Self.LmpOverBright2Menu.Checked:=False;
  Self.LmpOverBright4Menu.Checked:=False;
  {$R+}
end;

procedure TMainForm.LmpOverBright2MenuClick(Sender: TObject);
begin
  {$R-}
  LightmapMegatexture.SetOverbrightMode(2);
  Self.LmpOverBright1Menu.Checked:=False;
  Self.LmpOverBright2Menu.Checked:=True;
  Self.LmpOverBright4Menu.Checked:=False;
  {$R+}
end;

procedure TMainForm.LmpOverBright4MenuClick(Sender: TObject);
begin
  {$R-}
  LightmapMegatexture.SetOverbrightMode(4);
  Self.LmpOverBright1Menu.Checked:=False;
  Self.LmpOverBright2Menu.Checked:=False;
  Self.LmpOverBright4Menu.Checked:=True;
  {$R+}
end;


procedure TMainForm.GotoCamPosSubMenuClick(Sender: TObject);
var
  tmpVec: tVec4f;
begin
  {$R-}
  if (StrToVec(InputBox('Go to...', 'Position [X Y Z]', '0 0 0'), @tmpVec)) then
    begin
      Self.Camera.ViewPosition:=tmpVec;
    end;
  {$R+}
end;

procedure TMainForm.GotoFaceIdSubmenuClick(Sender: TObject);
var
  tmpFaceId: Integer;
  tmpPolyPtr: PPolygon3f;
  tmpVec: tVec4f;
begin
  {$R-}
  if (Unit1.isBspLoad = False) then Exit;

  tmpFaceId:=StrToIntDef(InputBox('Go to...', 'Face Id', '-1'), -1);
  if (tmpFaceId >=0) and (tmpFaceId < Map.CountFaces) then
    begin
      tmpPolyPtr:=@Map.FaceExtList[tmpFaceId].Polygon;
      tmpVec.x:=tmpPolyPtr.Center.x + tmpPolyPtr.Plane.Normal.x;
      tmpVec.y:=tmpPolyPtr.Center.y + tmpPolyPtr.Plane.Normal.y;
      tmpVec.z:=tmpPolyPtr.Center.z + tmpPolyPtr.Plane.Normal.z;
      Self.Camera.ViewPosition:=tmpVec;
    end;
  {$R+}
end;

procedure TMainForm.GotoVisLeafIdSubMenuClick(Sender: TObject);
var
  tmpVisLeafId: Integer;
  tmpVec: tVec4f;
begin
  {$R-}
  if (Unit1.isBspLoad = False) then Exit;

  tmpVisLeafId:=StrToIntDef(InputBox('Go to...', 'VisLeaf Id', '0'), -1);
  if (tmpVisLeafId > 0) and (tmpVisLeafId < Map.CountVisLeafWithPVS) then
    begin
      GetCenterBBOX4f(Map.VisLeafExtList[tmpVisLeafId].BBOX4f, @tmpVec);
      Self.Camera.ViewPosition:=tmpVec;
    end;
  {$R+}
end;

procedure TMainForm.GotoBModelIdSubMenuClick(Sender: TObject);
var
  tmpBModelId: Integer;
  tmpVec: tVec4f;
begin
  {$R-}
  if (Unit1.isBspLoad = False) then Exit;

  tmpBModelId:=StrToIntDef(InputBox('Go to...', 'BModel Id', '0'), -1);
  if (tmpBModelId >= 0) and (tmpBModelId < Map.CountBrushModels) then
    begin
      GetCenterBBOX4f(Map.BrushModelExtList[tmpBModelId].ShiftBBOX4f, @tmpVec);
      Self.Camera.ViewPosition:=tmpVec;
    end;
  {$R+}
end;

procedure TMainForm.GotoEntTGNSubMenuClick(Sender: TObject);
var
  tmpTGN: String;
  EntId: Integer;
begin
  {$R-}
  if (Unit1.isBspLoad = False) then Exit;

  tmpTGN:=InputBox('Go to...', 'Entity targetname', '');
  if (tmpTGN <> '') then
    begin
      EntId:=FindEntityByTargetName(
        @Map.Entities[0],
        Map.CountEntities,
        tmpTGN
      );
      if ((EntId > 0) and (EntId < Map.CountEntities)) then
        begin
          Self.Camera.ResetCamera(
            Map.Entities[EntId].Origin,
            Map.Entities[EntId].Angles.x*AngleToRadian,
            Map.Entities[EntId].Angles.y*AngleToRadian - Pi/2
          );
        end;
    end;
  {$R+}
end;

procedure TMainForm.ImportWAD3MenuClick(Sender: TObject);
var
  WAD3: tTextureLump;
  i, j, k, replaceCount: Integer;
begin
  {$R-}
  if (isBspLoad = False) then Exit;

  WAD3.nCountTextures:=0;
  WAD3.Wad3Textures:=nil;
  if (Self.OpenDialogWAD3.Execute) then
    begin
      if (LoadTextureLumpFromWAD3(Self.OpenDialogWAD3.FileName, @WAD3)) then
        begin
          replaceCount:=0;
          for i:=0 to (WAD3.nCountTextures - 1) do
            begin
              for j:=0 to (Map.TextureLump.nCountTextures - 1) do
                begin
                  if ((WAD3.Wad3Textures[i].nWidth <> Map.TextureLump.Wad3Textures[j].nWidth)
                    or (WAD3.Wad3Textures[i].nHeight <> Map.TextureLump.Wad3Textures[j].nHeight)
                    ) then Continue;

                  if (CompareTextureNames(
                      @WAD3.Wad3Textures[i].szName,
                      @Map.TextureLump.Wad3Textures[j].szName)) then
                    begin
                      if (Map.TextureLump.Wad3Textures[j].MipData[0] = nil) then
                        begin
                          Map.TextureLump.Wad3Textures[j].PaletteColors:=WAD3.Wad3Textures[i].PaletteColors;
                          AllocTexture(@Map.TextureLump.Wad3Textures[j]);
                          AllocPalette(@Map.TextureLump.Wad3Textures[j]);
                          CopyPixelData(@WAD3.Wad3Textures[i], @Map.TextureLump.Wad3Textures[j]);
                          BasetextureMng.AppendBasetexture(Map.TextureLump.Wad3Textures[j]);
                        end
                      else
                        begin
                          CopyPixelData(@WAD3.Wad3Textures[i], @Map.TextureLump.Wad3Textures[j]);
                          k:=BasetextureMng.GetBasetextureIdByName(
                            @Map.TextureLump.Wad3Textures[j].szName
                          );
                          BasetextureMng.UpdateBasetexture(Map.TextureLump.Wad3Textures[j], k);
                        end;
                      Inc(replaceCount);
                    end;
                end;
            end;
          //
          for i:=0 to (Map.CountFaces - 1) do
            begin
              Map.FaceExtList[i].TexRenderId:=BasetextureMng.GetBasetextureIdByName(
                Map.FaceExtList[i].TexName
              );
              if (Map.FaceExtList[i].TexRenderId < 0) then
                begin
                  Map.FaceExtList[i].TexRenderId:=BASETEXTURE_DUMMY_ID;
                end
              else
                begin
                  Map.FaceExtList[i].isDummyTexture:=False;
                end;
            end;
          //
          ShowMessage('Loaded ' + IntToStr(WAD3.nCountTextures) + ' Textures.'
            + LF + 'Updated ' + IntToStr(replaceCount) + ' Textures.'
          );
        end
      else
        begin
          ShowMessage('Error open WAD3 File !');
        end;
    end;
  FreeTextureLump(@WAD3);
  {$R+}
end;

procedure TMainForm.ExportTextureLumpWAD3Click(Sender: TObject);
var
  CountSave: Integer;
begin
  {$R-}
  if (isBspLoad = False) then Exit;

  if (Self.SaveDialogWAD3.Execute) then
    begin
      CountSave:=SaveTextureLumpToWAD3(Self.SaveDialogWAD3.FileName, @Map.TextureLump);
      if (CountSave > 0) then ShowMessage('Saved ' + IntToStr(CountSave) + ' textures to WAD3')
      else ShowMessage('Map dont have exists textures for save!');
    end;
  {$R+}
end;


procedure TMainForm.HelpMenuClick(Sender: TObject);
begin
  {$R-}
  ShowMessage(HelpStr);
  {$R+}
end;

procedure TMainForm.AboutMenuClick(Sender: TObject);
begin
  {$R-}
  ShowMessage(AboutStr + Opengl.glGetString(GL_VERSION));
  {$R+}
end;

procedure TMainForm.CloseMenuClick(Sender: TObject);
begin
  {$R-}
  Self.Close();
  {$R+}
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$R-}
  glDeleteLists(BaseCubeLeafWireframeList, 1);
  glDeleteLists(SecondCubeLeafWireframeList, 1);
  glDeleteLists(StartOrts, 1);

  FreeMapBSP(@Map);
  LightmapMegatexture.DeleteManager();
  BasetextureMng.DeleteManager();
  BaseThumbnailBMP.Destroy();

  Self.Camera.DeleteCamera();
  Self.RenderTimer.DeleteManager();

  Self.RenderContext.DeleteRenderingContext();
  Self.RenderContext.DeleteManager();

  Self.ProfileTimer.DeleteTimer();
  {$R+}
end;

end.
