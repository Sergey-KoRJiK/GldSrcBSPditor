unit Unit1;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

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
  {}
  OpenGL,
  EXTOpengl32Glew32,
  {}
  UnitOpenGLAdditional,
  UnitOpenGLFPSCamera,
  UnitRayTraceOpenGL,
  UnitVSync,
  {}
  UnitVec,
  UnitMapHeader,
  UnitBSPstruct,
  UnitEntity,
  UnitPlane,
  UnitTexture,
  UnitNode,
  UnitFace,
  UnitVisLeaf,
  UnitMarkSurface,
  UnitEdge,
  UnitBrushModel;

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
    ShowHeader1: TMenuItem;
    ShowWorldBrushesMenu: TMenuItem;
    ShowEntBrushesMenu: TMenuItem;
    WireframeWorldBrushesMenu: TMenuItem;
    WireframeEntBrushesMenu: TMenuItem;
    WallhackRenderModeMenu: TMenuItem;
    StatusBar: TStatusBar;
    SaveMapMenu: TMenuItem;
    PixelModeMenu: TMenuItem;
    ColorDialog: TColorDialog;
    SetSelectedFaceColor1: TMenuItem;
    LineSplitFileMenu: TMenuItem;
    SaveallLightmapsMenu: TMenuItem;
    LoadallLightmapsMenu: TMenuItem;
    OpenDialogBMP: TOpenDialog;
    SaveDialogBMP: TSaveDialog;
    NoPVSMenu: TMenuItem;
    RenderBBOXVisLeaf1: TMenuItem;
    ToolBarMenu: TMenuItem;
    ToolFaceMenu: TMenuItem;
    //
    procedure UpdateOpenGLViewport(const zFar: GLdouble);
    procedure GetFrustum();
    function isNotFaceFrustumIntersection(const lpFaceInfo: PFaceInfo): Boolean;
    function isNotFrustumBBoxIntersection(const BBOXf: tBBOXf): Boolean;
    procedure GetRenderList();
    procedure do_movement(const Offset: GLfloat);
    procedure GetMouseClickRay(const X, Y: Integer);
    procedure GetFaceIndexByRay();
    //
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpMenuClick(Sender: TObject);
    procedure AboutMenuClick(Sender: TObject);
    procedure ResetCameraMenuClick(Sender: TObject);
    procedure LoadMapMenuClick(Sender: TObject);
    procedure CloseMapMenuClick(Sender: TObject);
    procedure ShowHeader1Click(Sender: TObject);
    procedure ShowWorldBrushesMenuClick(Sender: TObject);
    procedure ShowEntBrushesMenuClick(Sender: TObject);
    procedure WireframeWorldBrushesMenuClick(Sender: TObject);
    procedure WireframeEntBrushesMenuClick(Sender: TObject);
    procedure WallhackRenderModeMenuClick(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure SaveMapMenuClick(Sender: TObject);
    procedure PixelModeMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure SetSelectedFaceColor1Click(Sender: TObject);
    procedure SaveallLightmapsMenuClick(Sender: TObject);
    procedure LoadallLightmapsMenuClick(Sender: TObject);
    procedure NoPVSMenuClick(Sender: TObject);
    procedure RenderBBOXVisLeaf1Click(Sender: TObject);
    procedure ToolFaceMenuClick(Sender: TObject);
  private
    { Private declarations }
  public
    HRC: HGLRC; // OpenGL
    VSyncManager: CVSyncManager;
    Camera: CFirtsPersonViewCamera;
    FrustumVertecies: array[0..7] of tVec3d;
    FrustumPlanes: array[0..5] of tPlane;
    FrustumDot: GLfloat;
    FieldOfView: GLdouble;
    //
    RayTracer: CRayTracer;
    MouseRay: tRay;
    isLeftMouseClicked, isRightMouseClicked: Boolean;
    mdx, mdy: Integer; // Mouse offsets
    //
    tickCount: Integer; // Counter for wait output info
    PressedKeys: array[0..1023] of Boolean;
    //
    isCanRender: Boolean;
    StartOrts: GLuint;
    //***
    Bsp30: tMapBSP;
    isBspLoad: Boolean;
    //
    CameraLeafId, CameraLastLeafId: Integer;
    FirstSpawnEntityId: Integer;
    lpCameraLeaf: PVisLeafInfo;
    //
    FacesIndexToRender: AByteBool;
    BrushIndexToRender: AByteBool;
    LeafIndexToRender: AByteBool;
    // Render VisLeaf options
    BaseCubeLeafWireframeList: GLuint;
    SecondCubeLeafWireframeList: GLuint;
    // Lightmap Face options
    RenderFaceInfo: tRenderFaceInfo;
    SelectedFaceIndex: Integer;
    FaceSelectedColor: tColor4fv;
  end;

const
  MaxRender: GLdouble = 4000.0;
  ClearColor: tColor4fv = (0.94, 0.94, 0.97, 1.0);
  LeafRenderColor: tColor4fv = (0.1, 0.1, 0.7, 1.0);
  LeafRenderSecondColor: tColor4fv = (0.1, 0.7, 0.1, 0.1);
  MAX_TICKCOUNT: Integer = 10;
  //
  MouseFreq: GLfloat = (Pi/180.0)/4.0; // [radian per pixel]
  CameraSpeed: GLfloat = 0.2;
  //
  HelpStr: String = 'Rotate Camera: Left Mouse Button' + LF +
    'Move Camera forward/backward: keys W/S' + LF +
    'Step Camera Left/Right: keys A/D' + LF +
    'Orts: red X, blue Y, green Z' + LF +
    'Select Face: Right Mouse Button' + LF +
    'Change Lightmap Style Page: key F' + LF +
    'Additional info showed in bottom Status Bar';
  AboutStr: String = 'Copyright (c) 2020 Sergey Smolovsky, Belarus' + LF +
    'email: sergeysmol4444@mail.ru' + LF +
    'GoldSrc BSP Editor' + LF +
    'Program version: 1.0.3' + LF +
    'Version of you OpenGL: ';
  MainFormCaption: String = 'GoldSrc BSP Editor';


implementation

{$R *.dfm}

uses Unit2;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  {$R-}
  Self.Caption:=MainFormCaption;
  Self.tickCount:=MAX_TICKCOUNT;
  Self.FieldOfView:=90.0; // Camera FOV
  Self.KeyPreview:=True;
  Self.isLeftMouseClicked:=False;
  Self.isRightMouseClicked:=False;
  //
  Self.isBspLoad:=False;
  Self.isCanRender:=True;
  Self.CameraLeafId:=0;
  Self.CameraLastLeafId:=0;
  Self.FirstSpawnEntityId:=0;
  Self.lpCameraLeaf:=nil;
  Self.SelectedFaceIndex:=-1;
  //
  Self.RenderFaceInfo.lpFaceInfo:=nil;
  Self.RenderFaceInfo.Page:=0;
  Self.RenderFaceInfo.FilterMode:=GL_LINEAR;

  Self.VSyncManager:=CVSyncManager.CreateVSyncManager(MinSyncInterval);
  Self.RayTracer:=CRayTracer.CreateRayTracer();
  Self.Camera:=CFirtsPersonViewCamera.CreateNewCamera(
    DefaultCameraPos,
    DefaultCameraPolarAngle,
    DefaultCameraAzimutalAngle
  );

  SetDCPixelFormat(Self.Canvas.Handle);
  Self.HRC:=wglCreateContext(Self.Canvas.Handle);
  wglMakeCurrent(Self.Canvas.Handle, Self.HRC);

  InitGL();
  glClearColor(ClearColor[0], ClearColor[1], ClearColor[2], ClearColor[3]);
  Self.BaseCubeLeafWireframeList:=GenListCubeWireframe(@LeafRenderColor[0]);
  SecondCubeLeafWireframeList:=GenListCubeWireframe(@LeafRenderSecondColor[0]);
  Self.StartOrts:=GenListOrts();

  Self.FaceSelectedColor[0]:=1.0;
  Self.FaceSelectedColor[1]:=0.1;
  Self.FaceSelectedColor[2]:=0.1;
  Self.FaceSelectedColor[3]:=0.3;

  Self.UpdateOpenGLViewport(MaxRender);
  {$R+}
end;

procedure TMainForm.UpdateOpenGLViewport(const zFar: GLdouble);
begin
  {$R-}
  glViewport(0, 0, Self.ClientWidth, Self.ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(FieldOfView, Self.ClientWidth/Self.ClientHeight, 1, zFar);
  {$R+}
end;

procedure TMainForm.GetFrustum();
var
  Dot1, Dot2: Single;
begin
  {$R-}
  // Get Frustum Vertecies
  Self.RayTracer.UnProjectVertex(0, 0, 0, @FrustumVertecies[0]);
  Self.RayTracer.UnProjectVertex(0, Self.ClientHeight, 0, @FrustumVertecies[1]);
  Self.RayTracer.UnProjectVertex(Self.ClientWidth, Self.ClientHeight, 0, @FrustumVertecies[2]);
  Self.RayTracer.UnProjectVertex(Self.ClientWidth, 0, 0, @FrustumVertecies[3]);
  
  Self.RayTracer.UnProjectVertex(0, 0, 1, @FrustumVertecies[4]);
  Self.RayTracer.UnProjectVertex(0, Self.ClientHeight, 1, @FrustumVertecies[5]);
  Self.RayTracer.UnProjectVertex(Self.ClientWidth, Self.ClientHeight, 1, @FrustumVertecies[6]);
  Self.RayTracer.UnProjectVertex(Self.ClientWidth, 0, 1, @FrustumVertecies[7]);

  // Get Frustum Planes
  // 1. Near Plane
  Self.FrustumPlanes[0].vNormal:=Self.Camera.ViewDirection;
  Self.FrustumPlanes[0].fDist:=Self.Camera.DistToAxis;
  Self.FrustumPlanes[0].AxisType:=PLANE_ANY_Z;
  // 2. Far Plane
  SignInvertVec3f(@Self.FrustumPlanes[0].vNormal, @Self.FrustumPlanes[1].vNormal);
  Self.FrustumPlanes[1].fDist:=-(MaxRender + Self.FrustumPlanes[0].fDist);
  Self.FrustumPlanes[1].AxisType:=PLANE_ANY_Z;

  // 3. Left Plane
  GetPlaneByPoints(FrustumVertecies[0],
    FrustumVertecies[3],
    FrustumVertecies[4],
    @Self.FrustumPlanes[2]);
  // 4. Right Plane
  GetPlaneByPoints(FrustumVertecies[2],
    FrustumVertecies[1],
    FrustumVertecies[6],
    @Self.FrustumPlanes[3]);

  // 5. Top Plane
  GetPlaneByPoints(FrustumVertecies[0],
    FrustumVertecies[4],
    FrustumVertecies[1],
    @Self.FrustumPlanes[4]);
  // 6. Bottom Plane
  GetPlaneByPoints(FrustumVertecies[2],
    FrustumVertecies[6],
    FrustumVertecies[3],
    @Self.FrustumPlanes[5]);

  Dot1:=Self.FrustumPlanes[0].vNormal.x*Self.FrustumPlanes[2].vNormal.x +
    Self.FrustumPlanes[0].vNormal.y*Self.FrustumPlanes[2].vNormal.y +
    Self.FrustumPlanes[0].vNormal.z*Self.FrustumPlanes[2].vNormal.z;
  Dot2:=Self.FrustumPlanes[0].vNormal.x*Self.FrustumPlanes[4].vNormal.x +
    Self.FrustumPlanes[0].vNormal.y*Self.FrustumPlanes[4].vNormal.y +
    Self.FrustumPlanes[0].vNormal.z*Self.FrustumPlanes[4].vNormal.z;
  if (Dot1 > Dot2) then Self.FrustumDot:=Dot1 else Self.FrustumDot:=Dot2;
  {$R+}
end;

function TMainForm.isNotFaceFrustumIntersection(const lpFaceInfo: PFaceInfo): Boolean;
var
  i, j: Integer;
  tmpBool: Boolean;
begin
  {$R-}
  for i:=0 to 5 do
    begin
      tmpBool:=True;
      for j:=0 to (lpFaceInfo.CountVertex - 1) do
        begin
          if (isPointInFrontPlaneSpaceFull(@Self.FrustumPlanes[i],
            lpFaceInfo.Vertex[j])) then
            begin
              tmpBool:=False;
              Break;
            end; //}
        end;

      if (tmpBool = True) then
        begin
          Result:=True;
          Exit;
        end;
    end;
    
  Result:=False;
  {$R+}
end;

function TMainForm.isNotFrustumBBoxIntersection(const BBOXf: tBBOXf): Boolean;
label
  LabelBackX, LabelRightY, LabelLeftY, LabelUpZ, LabelDownZ, LabelFalseRet;
begin
  {$R-}
  // Front X, Normal = (1, 0, 0);
  if (Self.FrustumVertecies[0].x >= BBOXf.vMin.x) then goto LabelBackX;
  if (Self.FrustumVertecies[1].x >= BBOXf.vMin.x) then goto LabelBackX;
  if (Self.FrustumVertecies[2].x >= BBOXf.vMin.x) then goto LabelBackX;
  if (Self.FrustumVertecies[3].x >= BBOXf.vMin.x) then goto LabelBackX;
  if (Self.FrustumVertecies[4].x >= BBOXf.vMin.x) then goto LabelBackX;
  if (Self.FrustumVertecies[5].x >= BBOXf.vMin.x) then goto LabelBackX;
  if (Self.FrustumVertecies[6].x >= BBOXf.vMin.x) then goto LabelBackX;
  if (Self.FrustumVertecies[7].x < BBOXf.vMin.x) then
    begin
      Result:=True;
      Exit;
    end;

  // Back X, Normal = (-1, 0, 0):
LabelBackX:
  if (Self.FrustumVertecies[0].x <= BBOXf.vMax.x) then goto LabelRightY;
  if (Self.FrustumVertecies[1].x <= BBOXf.vMax.x) then goto LabelRightY;
  if (Self.FrustumVertecies[2].x <= BBOXf.vMax.x) then goto LabelRightY;
  if (Self.FrustumVertecies[3].x <= BBOXf.vMax.x) then goto LabelRightY;
  if (Self.FrustumVertecies[4].x <= BBOXf.vMax.x) then goto LabelRightY;
  if (Self.FrustumVertecies[5].x <= BBOXf.vMax.x) then goto LabelRightY;
  if (Self.FrustumVertecies[6].x <= BBOXf.vMax.x) then goto LabelRightY;
  if (Self.FrustumVertecies[7].x > BBOXf.vMax.x) then
    begin
      Result:=True;
      Exit;
    end;

  // Right Y, Normal = (0, 1, 0):
LabelRightY:
  if (Self.FrustumVertecies[0].y >= BBOXf.vMin.y) then goto LabelLeftY;
  if (Self.FrustumVertecies[1].y >= BBOXf.vMin.y) then goto LabelLeftY;
  if (Self.FrustumVertecies[2].y >= BBOXf.vMin.y) then goto LabelLeftY;
  if (Self.FrustumVertecies[3].y >= BBOXf.vMin.y) then goto LabelLeftY;
  if (Self.FrustumVertecies[4].y >= BBOXf.vMin.y) then goto LabelLeftY;
  if (Self.FrustumVertecies[5].y >= BBOXf.vMin.y) then goto LabelLeftY;
  if (Self.FrustumVertecies[6].y >= BBOXf.vMin.y) then goto LabelLeftY;
  if (Self.FrustumVertecies[7].y < BBOXf.vMin.y) then
    begin
      Result:=True;
      Exit;
    end;

  // Left Y, Normal = (0, -1, 0):
LabelLeftY:
  if (Self.FrustumVertecies[0].y <= BBOXf.vMax.y) then goto LabelDownZ;
  if (Self.FrustumVertecies[1].y <= BBOXf.vMax.y) then goto LabelDownZ;
  if (Self.FrustumVertecies[2].y <= BBOXf.vMax.y) then goto LabelDownZ;
  if (Self.FrustumVertecies[3].y <= BBOXf.vMax.y) then goto LabelDownZ;
  if (Self.FrustumVertecies[4].y <= BBOXf.vMax.y) then goto LabelDownZ;
  if (Self.FrustumVertecies[5].y <= BBOXf.vMax.y) then goto LabelDownZ;
  if (Self.FrustumVertecies[6].y <= BBOXf.vMax.y) then goto LabelDownZ;
  if (Self.FrustumVertecies[7].y > BBOXf.vMax.y) then
    begin
      Result:=True;
      Exit;
    end;

  // Down Z, Normal = (0, 0, 1):
LabelDownZ:
  if (Self.FrustumVertecies[0].z >= BBOXf.vMin.z) then goto LabelUpZ;
  if (Self.FrustumVertecies[1].z >= BBOXf.vMin.z) then goto LabelUpZ;
  if (Self.FrustumVertecies[2].z >= BBOXf.vMin.z) then goto LabelUpZ;
  if (Self.FrustumVertecies[3].z >= BBOXf.vMin.z) then goto LabelUpZ;
  if (Self.FrustumVertecies[4].z >= BBOXf.vMin.z) then goto LabelUpZ;
  if (Self.FrustumVertecies[5].z >= BBOXf.vMin.z) then goto LabelUpZ;
  if (Self.FrustumVertecies[6].z >= BBOXf.vMin.z) then goto LabelUpZ;
  if (Self.FrustumVertecies[7].z < BBOXf.vMin.z) then
    begin
      Result:=True;
      Exit;
    end;

  // Up Z, Normal = (0, 0, -1):
LabelUpZ:
  if (Self.FrustumVertecies[0].z <= BBOXf.vMax.z) then goto LabelFalseRet;
  if (Self.FrustumVertecies[1].z <= BBOXf.vMax.z) then goto LabelFalseRet;
  if (Self.FrustumVertecies[2].z <= BBOXf.vMax.z) then goto LabelFalseRet;
  if (Self.FrustumVertecies[3].z <= BBOXf.vMax.z) then goto LabelFalseRet;
  if (Self.FrustumVertecies[4].z <= BBOXf.vMax.z) then goto LabelFalseRet;
  if (Self.FrustumVertecies[5].z <= BBOXf.vMax.z) then goto LabelFalseRet;
  if (Self.FrustumVertecies[6].z <= BBOXf.vMax.z) then goto LabelFalseRet;
  if (Self.FrustumVertecies[7].z > BBOXf.vMax.z) then
    begin
      Result:=True;
      Exit;
    end;

LabelFalseRet:
  Result:=False;
  Exit;
  {$R+}
end;

procedure TMainForm.GetRenderList();
var
  i, j, k: Integer;
  tmpVisLeaf: PVisLeafInfo;
  //tmp: Single;
begin
  {$R-}
  ZeroFillChar(@Self.FacesIndexToRender[0], Self.Bsp30.CountFaces);
  ZeroFillChar(@Self.BrushIndexToRender[0], Self.Bsp30.CountFaces);
  if (Self.CameraLeafId <= 0) then Exit;

  for i:=0 to (Self.lpCameraLeaf.CountPVS - 1) do
    begin
      // For each VisLeaf on Map
      if (Self.LeafIndexToRender[i] = False) then Continue;

      // For each visible VisLeaf for lpCameraLeaf by PVS Table
      tmpVisLeaf:=@Self.Bsp30.VisLeafInfos[i + 1];

      // First test if VisLeaf touch Frustum
      if (isNotFrustumBBoxIntersection(tmpVisLeaf.BBOXf)) then Continue;

      // 1. Get visible worldbrush faces for tmpVisLeaf
      if (Self.ShowWorldBrushesMenu.Checked) then
        begin
          for j:=0 to (tmpVisLeaf.CountFaces - 1) do
            begin
              // test if Face Polygon intersect six Frustum Polygons
              k:=tmpVisLeaf.FaceIndexes[j];
              if (Self.isNotFaceFrustumIntersection(@Self.Bsp30.FaceInfos[k]) = False) then
                begin
                  {tmp:=Self.Bsp30.FaceInfos[k].Plane.vNormal.x*Self.FrustumPlanes[0].vNormal.x +
                    Self.Bsp30.FaceInfos[k].Plane.vNormal.y*Self.FrustumPlanes[0].vNormal.y +
                    Self.Bsp30.FaceInfos[k].Plane.vNormal.z*Self.FrustumPlanes[0].vNormal.z;

                  if (tmp <= FrustumDot) then  //}
                    Self.FacesIndexToRender[k]:=True;
                end;
            end;
        end;

      // 2. Get visible EntBrushes
      if (Self.ShowEntBrushesMenu.Checked) then
        begin
          for j:=0 to (tmpVisLeaf.CountBrushFace - 1) do
            begin
              k:=tmpVisLeaf.BrushFaceIndexes[j];

              // Entity Brush can cover more than one VisLeaf
              if (Self.BrushIndexToRender[k]) then Continue;

              // test if Face Polygon intersect six Frustum Polygons
              if (Self.isNotFaceFrustumIntersection(@Self.Bsp30.FaceInfos[k]) = False) then
                begin
                  {tmp:=Self.Bsp30.FaceInfos[k].Plane.vNormal.x*Self.FrustumPlanes[0].vNormal.x +
                    Self.Bsp30.FaceInfos[k].Plane.vNormal.y*Self.FrustumPlanes[0].vNormal.y +
                    Self.Bsp30.FaceInfos[k].Plane.vNormal.z*Self.FrustumPlanes[0].vNormal.z;

                  if (tmp <= FrustumDot) then  //}
                    Self.BrushIndexToRender[k]:=True;
                end;
            end;
        end;
    end; // End For each VisLeaf on Map
  {$R+}
end;

procedure TMainForm.do_movement(const Offset: GLfloat);
begin
  {$R-}
  if (Self.PressedKeys[OrdW]) then Self.Camera.StepForward(Offset);
  if (Self.PressedKeys[OrdS]) then Self.Camera.StepBackward(Offset);
  if (Self.PressedKeys[OrdA]) then Self.Camera.StepLeft(Offset);
  if (Self.PressedKeys[OrdD]) then Self.Camera.StepRight(Offset);

  if (Self.isBspLoad) then
    begin
      Self.CameraLeafId:=GetLeafIndexByPoint(Self.Bsp30.NodeInfos,
        Self.Camera.ViewPosition, Self.Bsp30.RootIndex);

      if (Self.CameraLeafId <> Self.CameraLastLeafId) then
        begin
          if (Self.CameraLeafId > 0) then
            begin
              Self.CameraLastLeafId:=Self.CameraLeafId;
              Self.lpCameraLeaf:=@Self.Bsp30.VisLeafInfos[Self.CameraLeafId];
            end
          else Self.CameraLeafId:=CameraLastLeafId;

          ZeroFillChar(@Self.LeafIndexToRender[0], Self.Bsp30.CountVisLeafWithPVS);
          CopyBytes(
            @Self.lpCameraLeaf.PVS[0],
            @Self.LeafIndexToRender[0],
            Self.lpCameraLeaf.CountPVS
          );
        end;

      Self.GetFrustum();
      Self.GetRenderList();
    end;
  {$R+}
end;

procedure TMainForm.GetMouseClickRay(const X, Y: Integer);
var
  tmpVertex3d: array[0..2] of GLdouble;
begin
  {$R-}
  // Get Start Ray Position
  Self.RayTracer.UnProjectVertex(X, Y, 0, @tmpVertex3d[0]);
  Self.MouseRay.Start.x:=tmpVertex3d[0];
  Self.MouseRay.Start.y:=tmpVertex3d[1];
  Self.MouseRay.Start.z:=tmpVertex3d[2];

  // Get End Ray Position and calculate Ray Dir
  Self.RayTracer.UnProjectVertex(X, Y, 1, @tmpVertex3d[0]);
  Self.MouseRay.Dir.x:=tmpVertex3d[0] - Self.MouseRay.Start.x;
  Self.MouseRay.Dir.y:=tmpVertex3d[1] - Self.MouseRay.Start.y;
  Self.MouseRay.Dir.z:=tmpVertex3d[2] - Self.MouseRay.Start.z;

  // Normalize Ray Dir
  NormalizeVec3f(@Self.MouseRay.Dir);
  {$R+}
end;

procedure TMainForm.GetFaceIndexByRay();
var
  i: Integer;
  Dist, tmpDist: GLfloat;
begin
  {$R-}
  Self.SelectedFaceIndex:=-1;
  if (Self.isBspLoad = False) then Exit;

  Dist:=MaxRender + 1;

  // WorldBrush Faces
  if (Self.ShowWorldBrushesMenu.Checked) then
    begin
      for i:=0 to (Self.Bsp30.CountFaces - 1) do
        begin
          if (Self.FacesIndexToRender[i] = False) then Continue;
          if (Self.Bsp30.FaceInfos[i].CountLightStyles > 0) then
            begin
              if (Self.RenderFaceInfo.Page >= Self.Bsp30.FaceInfos[i].CountLightStyles) then Continue;
            end;

          if (GetRayFaceIntersection(@Self.Bsp30.FaceInfos[i],
            Self.MouseRay, @tmpDist)) then
            begin
              if (tmpDist < Dist) then
                begin
                  Dist:=tmpDist;
                  Self.SelectedFaceIndex:=i;
                end;
            end;
        end;
    end;

  // EntityBrush Faces
  if (Self.ShowEntBrushesMenu.Checked) then
    begin
      for i:=0 to (Self.Bsp30.CountFaces - 1) do
        begin
          if (Self.BrushIndexToRender[i] = False) then Continue;
          if (Self.Bsp30.FaceInfos[i].CountLightStyles > 0) then
            begin
              if (Self.RenderFaceInfo.Page >= Self.Bsp30.FaceInfos[i].CountLightStyles) then Continue;
            end;

          if (GetRayFaceIntersection(@Self.Bsp30.FaceInfos[i],
            Self.MouseRay, @tmpDist)) then
            begin
              if (tmpDist < Dist) then
                begin
                  Dist:=tmpDist;
                  Self.SelectedFaceIndex:=i;
                end;
            end;
        end;
    end;

  if (Self.SelectedFaceIndex >= 0) then
    begin
      if (Assigned(Unit2.FaceToolForm)) then
        begin
          Unit2.FaceToolForm.FaceSelectedIndex:=Self.SelectedFaceIndex;
          Unit2.FaceToolForm.CurrFace:=@Self.Bsp30.FaceLump[Self.SelectedFaceIndex];
          Unit2.FaceToolForm.CurrFaceInfo:=@Self.Bsp30.FaceInfos[Self.SelectedFaceIndex];
          Unit2.FaceToolForm.UpdateFaceVisualInfo();
        end;
    end
  else
    begin
      if (Assigned(Unit2.FaceToolForm)) then
        begin
          Unit2.FaceToolForm.ClearFaceVisualInfo();
        end;
    end;
  {$R+}
end;


procedure TMainForm.FormPaint(Sender: TObject);
var
  i: Integer;
begin
  {$R-}
  Self.VSyncManager.Synchronize();
  do_movement(CameraSpeed*Self.VSyncManager.SyncInterval);
  
  Self.Camera.gluLookAtUpdate;
  Self.RayTracer.UpdateModelMatrix();
  glClear(glBufferClearBits);

  if (Self.isBspLoad) then
    begin
      if (Self.NoPVSMenu.Checked = False) then
        begin
          // Render World Brush Faces with lightmaps
          if (Self.WireframeWorldBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_LINE);
          for i:=0 to (Self.Bsp30.CountFaces - 1) do
            begin
              if (Self.FacesIndexToRender[i] = False) then Continue;

              Self.RenderFaceInfo.lpFaceInfo:=@Self.Bsp30.FaceInfos[i];
              RenderFaceLmp(Self.RenderFaceInfo);
            end;
          if (Self.WireframeWorldBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_FILL);

          // Render World Brush Faces without lightmaps
          glPolygonMode(GL_BACK, GL_LINE);
          for i:=0 to (Self.Bsp30.CountFaces - 1) do
            begin
              if (Self.FacesIndexToRender[i] = False) then Continue;

              RenderFaceNoLmp(@Self.Bsp30.FaceInfos[i]);
            end;
          glPolygonMode(GL_BACK, GL_FILL);

          // Render EntBrush Faces with lightmaps
          if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_LINE);
          for i:=1 to (Self.Bsp30.CountFaces - 1) do
            begin
              if (Self.BrushIndexToRender[i] = False) then Continue;

              Self.RenderFaceInfo.lpFaceInfo:=@Self.Bsp30.FaceInfos[i];
              RenderFaceLmp(Self.RenderFaceInfo);
            end;
          if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_FILL);

          // Render EntBrush Faces without lightmaps
          glPolygonMode(GL_BACK, GL_LINE);
          for i:=0 to (Self.Bsp30.CountFaces - 1) do
            begin
              if (Self.BrushIndexToRender[i] = False) then Continue;

              RenderFaceNoLmp(@Self.Bsp30.FaceInfos[i]);
            end;
          glPolygonMode(GL_BACK, GL_FILL);
        end
      else
        begin
          // Render all Faces with lightmaps
          if (Self.WireframeWorldBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_LINE);
          if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_LINE);
          for i:=0 to (Self.Bsp30.CountFaces - 1) do
            begin
              Self.RenderFaceInfo.lpFaceInfo:=@Self.Bsp30.FaceInfos[i];
              RenderFaceLmp(Self.RenderFaceInfo);
            end;
          if (Self.WireframeWorldBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_FILL);
          if (Self.WireframeEntBrushesMenu.Checked) then glPolygonMode(GL_BACK, GL_FILL);

          // Render all Faced without lightmaps
          glPolygonMode(GL_BACK, GL_LINE);
          for i:=0 to (Self.Bsp30.CountFaces - 1) do
            begin
              RenderFaceNoLmp(@Self.Bsp30.FaceInfos[i]);
            end;
          glPolygonMode(GL_BACK, GL_FILL);
        end;

      // Render Selected Face
      if (Self.SelectedFaceIndex >= 0) then
        begin
          glPushMatrix();
          glTranslatef(
            Self.Bsp30.FaceInfos[Self.SelectedFaceIndex].Plane.vNormal.x,
            Self.Bsp30.FaceInfos[Self.SelectedFaceIndex].Plane.vNormal.y,
            Self.Bsp30.FaceInfos[Self.SelectedFaceIndex].Plane.vNormal.z);
          Self.RenderFaceInfo.lpFaceInfo:=@Self.Bsp30.FaceInfos[Self.SelectedFaceIndex];
          RenderSelectedFace(Self.RenderFaceInfo, FaceSelectedColor);
          glPopMatrix();
        end; //}

      // Render "Camera VisLeaf"
      if ((Self.CameraLeafId > 0) and (Self.RenderBBOXVisLeaf1.Checked)) then
        begin
          glPushMatrix();
          glTranslatef(
            Self.lpCameraLeaf.BBOXf.vMin.x,
            Self.lpCameraLeaf.BBOXf.vMin.y,
            Self.lpCameraLeaf.BBOXf.vMin.z
          );
          glScalef(
            Self.lpCameraLeaf.SizeBBOXf.x,
            Self.lpCameraLeaf.SizeBBOXf.y,
            Self.lpCameraLeaf.SizeBBOXf.z
          );
          glCallList(Self.BaseCubeLeafWireframeList);
          glPopMatrix();

          // Render other VisLeafs
          for i:=1 to Self.lpCameraLeaf.CountPVS do
            begin
              if (Self.LeafIndexToRender[i - 1] = False) then Continue;
              if (i = Self.CameraLeafId) then Continue;

              glPushMatrix();
              glTranslatef(
                Self.Bsp30.VisLeafInfos[i].BBOXf.vMin.x,
                Self.Bsp30.VisLeafInfos[i].BBOXf.vMin.y,
                Self.Bsp30.VisLeafInfos[i].BBOXf.vMin.z
              );
              glScalef(
                Self.Bsp30.VisLeafInfos[i].SizeBBOXf.x,
                Self.Bsp30.VisLeafInfos[i].SizeBBOXf.y,
                Self.Bsp30.VisLeafInfos[i].SizeBBOXf.z
              );
              glCallList(Self.SecondCubeLeafWireframeList);
              glPopMatrix();
            end; //}
        end;
    end;

  glCallList(Self.StartOrts);

  if (Self.isCanRender) then
    begin
      InvalidateRect(Self.Handle, nil, False);
      SwapBuffers(Self.Canvas.Handle);
    end;

  Dec(Self.tickCount);
  if (Self.tickCount <= 0) then
    begin
      Self.tickCount:=MAX_TICKCOUNT;

      Self.StatusBar.Panels.Items[0].Text:=VecToStr(Self.Camera.ViewPosition);
      if (Self.isBspLoad) then
        begin
          Self.StatusBar.Panels.Items[1].Text:='Camera in Leaf: '
            + IntToStr(Self.CameraLeafId);
        end;
      Self.StatusBar.Update;
    end;
  {$R+}
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  {$R-}
  Self.UpdateOpenGLViewport(MaxRender);
  Self.RayTracer.UpdateViewPort();
  Self.RayTracer.UpdateProjectMatrix();
  {$R+}
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {$R-}
  if (mbLeft = Button) then Self.isLeftMouseClicked:=True;
  if (mbRight = Button) then
    begin
      Self.isRightMouseClicked:=True;
      Self.GetMouseClickRay(X, Y);
      Self.GetFaceIndexByRay();
    end;
  {$R+}
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  isViewDirChanged: Boolean;
begin
  {$R-}
  if (Self.isLeftMouseClicked) then
    begin
      isViewDirChanged:=False;
      if (X <> Self.mdx) then
        begin
          // MouseFreq -> [radian / pixel]
          // (X - Self.mdx) -> [pixel]
          // (X - Self.mdx)*MouseFreq -> [pixel]*[radian / pixel] -> [radian]
          Self.Camera.UpDateViewDirectionByMouseX((X - Self.mdx)*MouseFreq);
          isViewDirChanged:=True;
        end;
      if (Y <> Self.mdy) then
        begin
          Self.Camera.UpDateViewDirectionByMouseY((Self.mdy - Y)*MouseFreq);
          isViewDirChanged:=True;
        end;

      if (isViewDirChanged) then
        begin
          Self.GetFrustum();
          if (Self.isBspLoad) then
            begin
              Self.GetRenderList();
            end;
        end;
    end;
  Self.mdx:=X;
  Self.mdy:=Y;
  {$R+}
end;

procedure TMainForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
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
  if (Key < 1024) then Self.PressedKeys[Ord(Key)]:=True;

  if (Self.isBspLoad = False) then Exit;

  if (Ord(Key) = OrdF) then
    begin
      Inc(Self.RenderFaceInfo.Page);
      if (Self.RenderFaceInfo.Page > 3) then Self.RenderFaceInfo.Page:=0;

      if (Self.SelectedFaceIndex >= 0) then
        begin
          if (Self.RenderFaceInfo.Page >=
            Self.Bsp30.FaceInfos[Self.SelectedFaceIndex].CountLightStyles) then
            begin
              Self.SelectedFaceIndex:=-1;
              if (Assigned(Unit2.FaceToolForm)) then
                begin
                  Unit2.FaceToolForm.ClearFaceVisualInfo();
                end;
            end
        end;

      if (Assigned(Unit2.FaceToolForm)) then
        begin
          Unit2.FaceToolForm.SelectedStyle:=Self.RenderFaceInfo.Page;
          Unit2.FaceToolForm.UpdateFaceVisualInfo();
        end;

      Self.StatusBar.Panels.Items[2].Text:='Style page (0..3): '
        + IntToStr(Self.RenderFaceInfo.Page);
    end;
  {$R+}
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {$R-}
  if (Key < 1024) then Self.PressedKeys[Ord(Key)]:=False;
  {$R+}
end;

procedure TMainForm.FormClick(Sender: TObject);
begin
  {$R-}
  if (Self.isCanRender = False) then
    begin
      Self.isCanRender:=True;
      Self.Paint();
    end;
  {$R+}
end;


procedure TMainForm.LoadMapMenuClick(Sender: TObject);
begin
  {$R-}
  Self.isCanRender:=False;
  if (Self.OpenDialogBsp.Execute) then
    begin
      Self.isBspLoad:=LoadBSP30FromFile(Self.OpenDialogBsp.FileName, @Self.Bsp30);
      if (Self.isBspLoad = False) then
        begin
          ShowMessage('Error load Map: ' + LF
            + ShowLoadBSPMapError(Self.Bsp30.LoadState)
          );
          FreeMapBSP(@Self.Bsp30);
        end
      else
        begin
          Self.LoadMapMenu.Enabled:=False;
          Self.CloseMapMenu.Enabled:=True;
          Self.SaveMapMenu.Enabled:=True;
          Self.LoadallLightmapsMenu.Enabled:=True;
          Self.SaveallLightmapsMenu.Enabled:=True;
          Self.Caption:=Self.OpenDialogBsp.FileName;

          Self.FirstSpawnEntityId:=FindFirstSpawnEntity(Self.Bsp30.Entities,
            Self.Bsp30.CountEntities);
          if (Self.FirstSpawnEntityId >= 1) then
            begin
              Self.Camera.ResetCamera(
                Self.Bsp30.Entities[Self.FirstSpawnEntityId].Origin,
                Self.Bsp30.Entities[Self.FirstSpawnEntityId].Angles.x*AngleToRadian,
                Self.Bsp30.Entities[Self.FirstSpawnEntityId].Angles.y*AngleToRadian - Pi/2
              );
            end;

          SetLength(Self.FacesIndexToRender, Self.Bsp30.CountFaces);
          ZeroFillChar(@Self.FacesIndexToRender[0], Self.Bsp30.CountFaces);

          SetLength(Self.BrushIndexToRender, Self.Bsp30.CountFaces);
          ZeroFillChar(@Self.BrushIndexToRender[0], Self.Bsp30.CountFaces);

          SetLength(Self.LeafIndexToRender, Self.Bsp30.CountVisLeafWithPVS);
          ZeroFillChar(@Self.LeafIndexToRender[0], Self.Bsp30.CountVisLeafWithPVS);

          if (Assigned(Unit2.FaceToolForm)) then
            begin
              Unit2.FaceToolForm.lpMap:=@Self.Bsp30;
            end;
        end;
    end;
  Self.isCanRender:=True;
  Self.Paint();
  {$R+}
end;

procedure TMainForm.CloseMapMenuClick(Sender: TObject);
begin
  {$R-}
  Self.isBspLoad:=False;
  Self.Caption:=MainFormCaption;

  Self.LoadMapMenu.Enabled:=True;
  Self.SaveMapMenu.Enabled:=False;
  Self.CloseMapMenu.Enabled:=False;
  Self.LoadallLightmapsMenu.Enabled:=False;
  Self.SaveallLightmapsMenu.Enabled:=False;

  FreeMapBSP(@Self.Bsp30);
  SetLength(Self.FacesIndexToRender, 0);
  SetLength(Self.BrushIndexToRender, 0);
  SetLength(Self.LeafIndexToRender, 0);

  Self.CameraLeafId:=0;
  Self.CameraLastLeafId:=0;
  Self.FirstSpawnEntityId:=0;
  Self.SelectedFaceIndex:=-1;
  Self.lpCameraLeaf:=nil;

  Self.RenderFaceInfo.lpFaceInfo:=nil;
  Self.RenderFaceInfo.Page:=0;

  Self.StatusBar.Panels.Items[1].Text:='No map load';
  Self.StatusBar.Panels.Items[2].Text:='Style page (0..3): 0';

  if (Assigned(Unit2.FaceToolForm)) then
    begin
      Unit2.FaceToolForm.ClearFaceVisualInfo();
      Unit2.FaceToolForm.lpMap:=nil;
    end;
  {$R+}
end;

procedure TMainForm.SaveMapMenuClick(Sender: TObject);
begin
  {$R-}
  if (Self.isBspLoad = False) then Exit;

  Self.isCanRender:=False;
  if (Self.SaveDialogBsp.Execute) then
    begin
      SaveBSP30ToFile(Self.SaveDialogBsp.FileName, @Self.Bsp30);
    end;
  Self.isCanRender:=True;
  Self.Paint();
  {$R+}
end;

procedure TMainForm.SaveallLightmapsMenuClick(Sender: TObject);
const
  mfUnusedColor: TRGBTriple = (rgbtBlue: 255; rgbtGreen:   0; rgbtRed: 255);
  mfPageColor: array[0..3] of TRGBTriple = (
    (rgbtBlue:   0; rgbtGreen:   0; rgbtRed: 255),
    (rgbtBlue:   0; rgbtGreen: 255; rgbtRed:   0),
    (rgbtBlue: 255; rgbtGreen:   0; rgbtRed:   0),
    (rgbtBlue:   0; rgbtGreen: 255; rgbtRed: 255)
  );
var
  i, j, w, h, k: Integer;
  tmpBitmap, tmpFaceMap: TBitmap;
  pBmp, pFaceMap: pRGBArray;
  lpFaceInfo: PFaceInfo;
  FaceIndex, FacePageIndex: Integer;
begin
  {$R-}
  if (Self.isBspLoad = False) then Exit;
  Self.isCanRender:=False;

  if (Self.SaveDialogBMP.Execute) then
    begin
      w:=Round(Sqrt(Self.Bsp30.CountUnpackedLightmaps) + 1);
      h:=Round(Self.Bsp30.CountUnpackedLightmaps/w + 1);

      tmpBitmap:=TBitmap.Create();
      tmpBitmap.PixelFormat:=pf24bit;
      tmpBitmap.Width:=w;
      tmpBitmap.Height:=h;

      tmpFaceMap:=TBitmap.Create();
      tmpFaceMap.PixelFormat:=pf24bit;
      tmpFaceMap.Width:=w;
      tmpFaceMap.Height:=h;

      FaceIndex:=0;
      lpFaceInfo:=@Self.Bsp30.FaceInfos[FaceIndex];
      while (lpFaceInfo.CountLightStyles = 0) do
        begin
          Inc(FaceIndex);
          Inc(lpFaceInfo);
        end;

      k:=0;
      FacePageIndex:=0;
      for i:=0 to (h - 1) do
        begin
          pBmp:=tmpBitmap.ScanLine[i];
          pFaceMap:=tmpFaceMap.ScanLine[i];
          for j:=0 to (w - 1) do
            begin
              if (FaceIndex < Self.Bsp30.CountFaces) then
                begin
                  RGB888toTRGBTriple(@lpFaceInfo.Lightmaps[FacePageIndex][k], pBmp^[j]);
                  pFaceMap^[j]:=mfPageColor[FacePageIndex];

                  Inc(k);
                  if (k >= lpFaceInfo.LmpSquare) then
                    begin
                      k:=0;
                      Inc(FacePageIndex);
                    end;
                  if (FacePageIndex >= lpFaceInfo.CountLightStyles) then
                    begin
                      FacePageIndex:=0;
                      Inc(FaceIndex);
                      Inc(lpFaceInfo);
                    end;
                  while (lpFaceInfo.CountLightStyles = 0) do
                    begin
                      Inc(FaceIndex);
                      Inc(lpFaceInfo);
                    end;
                end
              else
                begin
                  pBmp^[j]:=mfUnusedColor;
                  pFaceMap^[j]:=mfUnusedColor;
                end;
            end;
        end;

      tmpBitmap.SaveToFile(Self.SaveDialogBMP.FileName + '.bmp');
      tmpBitmap.Destroy();
      tmpFaceMap.SaveToFile(Self.SaveDialogBMP.FileName + '_FaceMap.bmp');
      tmpFaceMap.Destroy();
    end;

  Self.isCanRender:=True;
  Self.Paint();
  {$R+}
end;

procedure TMainForm.LoadallLightmapsMenuClick(Sender: TObject);
var
  i, j, k: Integer;
  tmpBitmap: TBitmap;
  pBmp: pRGBArray;
  lpFaceInfo: PFaceInfo;
  FaceIndex, FacePageIndex: Integer;
begin
  {$R-}
  if (Self.isBspLoad = False) then Exit;
  Self.isCanRender:=False;

  if (Self.OpenDialogBMP.Execute) then
    begin
      tmpBitmap:=TBitmap.Create();
      tmpBitmap.LoadFromFile(Self.OpenDialogBMP.FileName);
      tmpBitmap.PixelFormat:=pf24bit;

      FaceIndex:=0;
      lpFaceInfo:=@Self.Bsp30.FaceInfos[FaceIndex];
      while (lpFaceInfo.CountLightStyles = 0) do
        begin
          Inc(FaceIndex);
          Inc(lpFaceInfo);
        end;

      k:=0;
      FacePageIndex:=0;
      for i:=0 to (tmpBitmap.Height - 1) do
        begin
          pBmp:=tmpBitmap.ScanLine[i];
          for j:=0 to (tmpBitmap.Width - 1) do
            begin
              if (FaceIndex < Self.Bsp30.CountFaces) then
                begin
                  TRGBTripleToRGB888(pBmp^[j], @lpFaceInfo.Lightmaps[FacePageIndex][k]);

                  Inc(k);
                  if (k >= lpFaceInfo.LmpSquare) then
                    begin
                      k:=0;
                      Inc(FacePageIndex);
                    end;
                  if (FacePageIndex >= lpFaceInfo.CountLightStyles) then
                    begin
                      FacePageIndex:=0;
                      Inc(FaceIndex);
                      Inc(lpFaceInfo);
                    end;
                  while (lpFaceInfo.CountLightStyles = 0) do
                    begin
                      Inc(FaceIndex);
                      Inc(lpFaceInfo);
                    end;
                end;
            end;
        end;
      tmpBitmap.Destroy();

      for i:=0 to (Self.Bsp30.CountFaces - 1) do
        begin
          lpFaceInfo:=@Self.Bsp30.FaceInfos[i];
          for j:=0 to (lpFaceInfo.CountLightStyles - 1) do
            begin
              CreateLightmapTexture(lpFaceInfo, j);
            end;
        end;
    end;

  Self.isCanRender:=True;
  Self.Paint();
  {$R+}
end;

procedure TMainForm.ResetCameraMenuClick(Sender: TObject);
begin
  {$R-}
  if (Self.isBspLoad) then
    begin
      if (Self.FirstSpawnEntityId >= 1) then
        begin
          Self.Camera.ResetCamera(
            Self.Bsp30.Entities[Self.FirstSpawnEntityId].Origin,
            Self.Bsp30.Entities[Self.FirstSpawnEntityId].Angles.x*AngleToRadian,
            Self.Bsp30.Entities[Self.FirstSpawnEntityId].Angles.y*AngleToRadian - Pi/2
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

procedure TMainForm.ShowHeader1Click(Sender: TObject);
begin
  {$R-}
  if (Self.isBspLoad) then
    begin
      ShowMessage(ShowMapHeaderInfo(Self.Bsp30.MapHeader) + LF
        + 'Entities (with "worldspawn") = ' + IntToStr(Self.Bsp30.CountEntities) + LF
        + 'Count VisLeafs with PVS = ' + IntToStr(Self.Bsp30.CountVisLeafWithPVS)
      );
    end;
  {$R+}
end;

procedure TMainForm.WireframeWorldBrushesMenuClick(Sender: TObject);
begin
  {$R-}
  Self.WireframeWorldBrushesMenu.Checked:=not Self.WireframeWorldBrushesMenu.Checked;
  {$R+}
end;

procedure TMainForm.WireframeEntBrushesMenuClick(Sender: TObject);
begin
  {$R-}
  Self.WireframeEntBrushesMenu.Checked:=not Self.WireframeEntBrushesMenu.Checked;
  {$R+}
end;

procedure TMainForm.ShowWorldBrushesMenuClick(Sender: TObject);
begin
  {$R-}
  Self.ShowWorldBrushesMenu.Checked:=not Self.ShowWorldBrushesMenu.Checked;
  Self.GetRenderList();
  {$R+}
end;

procedure TMainForm.ShowEntBrushesMenuClick(Sender: TObject);
begin
  {$R-}
  Self.ShowEntBrushesMenu.Checked:=not Self.ShowEntBrushesMenu.Checked;
  Self.GetRenderList();
  {$R+}
end;

procedure TMainForm.WallhackRenderModeMenuClick(Sender: TObject);
begin
  {$R-}
  if (Self.WallhackRenderModeMenu.Checked) then
    begin
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      Self.WallhackRenderModeMenu.Checked:=False;
    end
  else
    begin
      glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_SRC_COLOR);
      Self.WallhackRenderModeMenu.Checked:=True;
    end;
  {$R+}
end;

procedure TMainForm.PixelModeMenuClick(Sender: TObject);
begin
  {$R-}
  if (Self.PixelModeMenu.Checked) then
    begin
      Self.RenderFaceInfo.FilterMode:=GL_LINEAR;
      Self.PixelModeMenu.Checked:=False;
    end
  else
    begin
      Self.RenderFaceInfo.FilterMode:=GL_NEAREST;
      Self.PixelModeMenu.Checked:=True;
    end;
  {$R+}
end;

procedure TMainForm.SetSelectedFaceColor1Click(Sender: TObject);
begin
  {$R-}
  Self.isCanRender:=False;

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
  Self.isCanRender:=True;
  Self.Paint();
  {$R+}
end;

procedure TMainForm.NoPVSMenuClick(Sender: TObject);
begin
  {$R-}
  Self.NoPVSMenu.Checked:= not Self.NoPVSMenu.Checked;
  if (Self.isBspLoad = False) then Exit;

  Self.SelectedFaceIndex:=-1;
  if (Assigned(Unit2.FaceToolForm)) then
    begin
      Unit2.FaceToolForm.UpdateFaceVisualInfo();
    end;
  {$R+}
end;

procedure TMainForm.RenderBBOXVisLeaf1Click(Sender: TObject);
begin
  {$R-}
  Self.RenderBBOXVisLeaf1.Checked:=not Self.RenderBBOXVisLeaf1.Checked;
  {$R+}
end;


procedure TMainForm.ToolFaceMenuClick(Sender: TObject);
begin
  {$R-}
  FaceToolForm.Show;
  FaceToolForm.Update;
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

procedure TMainForm.FormShow(Sender: TObject);
begin
  {$R-}
  if (Assigned(FaceToolForm) = False) then
    begin
      FaceToolForm:=Unit2.TFaceToolForm.Create(Self);
    end;
  FaceToolForm.Show;
  FaceToolForm.Update;
  {$R+}
end;

procedure TMainForm.FormHide(Sender: TObject);
begin
  {$R-}
  if (Assigned(FaceToolForm)) then
    begin
      FaceToolForm.Hide;
    end;
  {$R+}
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$R-}
  glDeleteLists(Self.BaseCubeLeafWireframeList, 1);
  glDeleteLists(Self.SecondCubeLeafWireframeList, 1);
  glDeleteLists(Self.StartOrts, 1);

  FreeMapBSP(@Self.Bsp30);
  SetLength(Self.FacesIndexToRender, 0);
  SetLength(Self.BrushIndexToRender, 0);
  SetLength(Self.LeafIndexToRender, 0);

  Self.Camera.DeleteCamera();
  Self.RayTracer.DeleteRayTracer();
  Self.VSyncManager.DeleteVSyncManager();
  wglDeleteContext(Self.HRC);
  {$R+}
end;

end.
