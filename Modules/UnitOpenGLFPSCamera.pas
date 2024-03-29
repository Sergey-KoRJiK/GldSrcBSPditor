unit UnitOpenGLFPSCamera;

// Copyright (c) 2019 Sergey-KoRJiK, Belarus

// First Person View OpenGL Camera class
// All angle values in radians

interface

uses
  SysUtils,
  Windows,
  Classes,
  OpenGL,
  UnitUserTypes,
  UnitVec;

const
  CameraPolarAngleMax: GLfloat = Pi*0.5;
  CameraPolarAngleMin: GLfloat = -Pi*0.5;
  AngleToRadian: GLfloat = Pi/180.0;
  RadianToAngle: GLfloat = 180.0/Pi;
  Pi360: GLfloat = Pi/360.0;

const
  FieldOfViewMin: GLfloat = 45.0;
  FieldOfViewMax: GLfloat = 120.0;
  zFarMin: GLfloat = 2.0;
  zNear: GLfloat = 1.0;

const
  // Camera see at that pos to Axis origin.
  DefaultCameraPos: tVec3f = (X: 50.0; Y: 50.0; Z: 50.0);
  DefaultCameraPolarAngle: GLfloat = -0.523599;
  DefaultCameraAzimutalAngle: GLfloat = 0.785398;

type CFirtsPersonViewCamera = class
  private
    CModelMat4f: tMat4f;
    CProjMat4f: tMat4f;
    //
    CSizeX, CSizeY, CAspectRation: GLfloat;
    CFieldOfView, CZFar: GLfloat;
    CWidth, CHeight: GLint;
    // prefix N for vectors mean Normalized
    CPos, CNDir, CNUp, CNSide: tVec3f; // (Dir, Side, Up) is orthogonal basis
    CAlpha, CBetta: GLfloat;
    // Alpha angle make rotate around CNup and change CNDir and CNSide
    // Betta angle make rotate around CNSide and change CNup and CNDir
    //
    FSin, FCos, FCosDivAspect: GLfloat;
    //
    procedure WrapCAlpha();
    procedure ClampPolarAngle();
    procedure SetViewPosition(const Pos: tVec3f);
    procedure RebuildModelView();
    procedure UpdateModelViewTranslate();
  public
    property AzimutalAngle: GLfloat read CAlpha;  // [radian]
    property PolarAngle: GLfloat read CBetta;     // [radian]
    property ViewPosition: tVec3f read CPos write SetViewPosition;
    property ViewDirection: tVec3f read CNDir;
    property UpVector: tVec3f read CNUp;
    property SideVector: tVec3f read CNSide;
    property DistToAxis: GLfloat read CModelMat4f[14]; // camera distance to Axis origin
    // Camera CNDir with DistToAxis give Camera Plane equation
    //
    property FieldOfView: GLfloat read CFieldOfView;
    property ScreenWidth: GLint read CWidth;
    property ScreenHeight: GLint read CHeight;
    property zFar: GLfloat read CZFar;
    //
    constructor CreateNewCamera(const Pos: tVec3f; const PolarAngle, AzimutalAngle: GLfloat);
    destructor DeleteCamera();
    //
    procedure ResetCamera(const Pos: tVec3f; const PolarAngle, AzimutalAngle: GLfloat);
    procedure StepForward(const Dist: GLfloat);
    procedure StepBackward(const Dist: GLfloat);
    procedure StepLeft(const Dist: GLfloat);
    procedure StepRight(const Dist: GLfloat);
    //
    procedure UpdateViewDirectionByMouseX(const AzimutalOffset: GLfloat); // [radian]
    procedure UpdateViewDirectionByMouseY(const PolarOffset: GLfloat);    // [radian]
    //
    // Fideld Of View in degrees.
    procedure SetProjMatrix(const ScreenWidth, ScreenHeight: GLint; FieldOfView, zFar: GLfloat);
    //
    procedure glModelViewUpdate();  // set to OpenGL movelview matrix
    procedure glProjectionAndViewPortUpdate(); // set to OpenGL viewport and project matrix
    //
    // Get mouse ray by click on screen.
    // Mouse pos in windows coordinates, X from 0 to Width, Y from 0 to Height;
    // Mouse ray start at camera pos, ray dir is normalized.
    procedure GetTraceLineByMouseClick(const MousePosWinCoord: TPoint; const Ray: PRay);
  end;
  

implementation


constructor CFirtsPersonViewCamera.CreateNewCamera(const Pos: tVec3f;
  const PolarAngle, AzimutalAngle: GLfloat);
begin
  {$R-}
  inherited;

  Self.CNSide.z:=0.0;
  Self.CModelMat4f:=IdentityMat4f;
  Self.ResetCamera(Pos, PolarAngle, AzimutalAngle);

  Self.CProjMat4f:=ZerosMat4f;
  Self.CProjMat4f[11]:=-1.0;
  Self.SetProjMatrix(-1, -1, -1, -1);

  Self.FSin:=0.0;
  Self.FCos:=0.0;
  Self.FCosDivAspect:=0.0;
  {$R+}
end;

procedure CFirtsPersonViewCamera.WrapCAlpha();
asm
  {$R-}
  // check (abs(Angle) < 2*pi)
  push ebx
  mov ebx, CFirtsPersonViewCamera[EAX].CAlpha
  shl ebx, 1
  shr ebx, 1
  cmp ebx, $40C90FDB // 2*pi as dword is $40C90FDB
  pop ebx
  jl @@NoWrap  // jump to exit if (abs(Angle) < 2*pi)

  // stack is null;
  fldpi
  // st0 = pi;
  fld st(0)
  // st0 = pi; st1 = pi;
  faddp st(1), st(0)
  // st0 = 2*pi;
  fld CFirtsPersonViewCamera[EAX].CAlpha
  // st0 = Angle, st1 = 2*pi;
  fprem1  // returns the remainder of division without rounding
  // st0 = Angle fmod 2*pi; st1 = 2*pi;
  fstp CFirtsPersonViewCamera[EAX].CAlpha
  // st0 = 2*pi;
  fstp st(0)
  // stack is null;

@@NoWrap:
  {$R+}
end;

procedure CFirtsPersonViewCamera.ClampPolarAngle();
asm
  {$R-}
  push ebx
  push edx
  mov ebx, CFirtsPersonViewCamera[EAX].CBetta
  mov edx, ebx
  shl ebx, 1
  shr ebx, 1
  cmp ebx, $3FC90FDB // 0.5*Pi as dword is $3FC90FDB; -0.5*Pi = $BFC90FDB
  jle @@NoClamp  // jump to exit if (abs(Angle) <= 0.5*pi)

  cmp edx, ebx
  jne @@ClampToMin // if ebx <> edx -> CBetta is neg, need clamp to Min
  // ebx = edx -> CBetta is positive, need clamp to Max
  mov edx, $3FC90FDB
  mov CFirtsPersonViewCamera[EAX].CBetta, edx
  jmp @@NoClamp // go to exit

@@ClampToMin:
  mov edx, $BFC90FDB
  mov CFirtsPersonViewCamera[EAX].CBetta, edx

@@NoClamp:
  pop edx
  pop ebx
  {$R+}
end;

procedure CFirtsPersonViewCamera.SetViewPosition(const Pos: tVec3f);
begin
  {$R-}
  Self.CPos:=Pos;

  Self.UpdateModelViewTranslate();
  {$R+}
end;

procedure CFirtsPersonViewCamera.RebuildModelView();
begin
  {$R-}
  Self.CModelMat4f[0]:=Self.CNSide.x;
  Self.CModelMat4f[4]:=Self.CNSide.y;

  Self.CModelMat4f[1]:=Self.CNUp.x;
  Self.CModelMat4f[5]:=Self.CNUp.y;
  Self.CModelMat4f[9]:=Self.CNUp.z;

  Self.CModelMat4f[2]:=-Self.CNDir.x;
  Self.CModelMat4f[6]:=-Self.CNDir.y;
  Self.CModelMat4f[10]:=-Self.CNDir.z;

  Self.CModelMat4f[12]:=-Self.CPos.x*Self.CNSide.x - Self.CPos.y*Self.CNSide.y;
  Self.CModelMat4f[13]:=-Self.CPos.x*Self.CNUp.x - Self.CPos.y*Self.CNUp.y
    - Self.CPos.z*Self.CNUp.z;
  Self.CModelMat4f[14]:=Self.CPos.x*Self.CNDir.x + Self.CPos.y*Self.CNDir.y +
    Self.CPos.z*Self.CNDir.z;
  {$R+}
end;

procedure CFirtsPersonViewCamera.UpdateModelViewTranslate();
begin
  {$R-}
  Self.CModelMat4f[12]:=-Self.CPos.x*Self.CNSide.x - Self.CPos.y*Self.CNSide.y;
  Self.CModelMat4f[13]:=-Self.CPos.x*Self.CNUp.x - Self.CPos.y*Self.CNUp.y
    - Self.CPos.z*Self.CNUp.z;
  Self.CModelMat4f[14]:=Self.CPos.x*Self.CNDir.x + Self.CPos.y*Self.CNDir.y +
    Self.CPos.z*Self.CNDir.z;
  {$R+}
end;

procedure CFirtsPersonViewCamera.ResetCamera(const Pos: tVec3f;
  const PolarAngle, AzimutalAngle: GLfloat);
begin
  {$R-}
  Self.CPos:=Pos;

  Self.CAlpha:=AzimutalAngle;
  Self.WrapCAlpha();
  // 
  Self.CNSide.x:=-Cos(Self.CAlpha);
  Self.CNSide.y:=Sin(Self.CAlpha);

  Self.CBetta:=PolarAngle;
  Self.ClampPolarAngle();
  //
  Self.CNDir.z:=Sin(Self.CBetta);
  Self.CNUp.z:=Cos(Self.CBetta);
  //
  Self.CNDir.x:=-Self.CNSide.y*Self.CNUp.z;
  Self.CNDir.y:=Self.CNSide.x*Self.CNUp.z;
  //
  Self.CNUp.x:=Self.CNSide.y*Self.CNDir.z;
  Self.CNUp.y:=-Self.CNSide.x*Self.CNDir.z;

  Self.RebuildModelView();
  {$R+}
end;

procedure CFirtsPersonViewCamera.StepForward(const Dist: GLfloat);
begin
  {$R-}
  Self.CPos.x:=Self.CPos.x + Self.CNDir.x*Dist;
  Self.CPos.y:=Self.CPos.y + Self.CNDir.y*Dist;
  Self.CPos.z:=Self.CPos.z + Self.CNDir.z*Dist;

  Self.UpdateModelViewTranslate();
  {$R+}
end;

procedure CFirtsPersonViewCamera.StepBackward(const Dist: GLfloat);
begin
  {$R-}
  Self.CPos.x:=Self.CPos.x - Self.CNDir.x*Dist;
  Self.CPos.y:=Self.CPos.y - Self.CNDir.y*Dist;
  Self.CPos.z:=Self.CPos.z - Self.CNDir.z*Dist;

  Self.UpdateModelViewTranslate();
  {$R+}
end;

procedure CFirtsPersonViewCamera.StepLeft(const Dist: GLfloat);
begin
  {$R-}
  Self.CPos.x:=Self.CPos.x - Self.CNSide.x*Dist;
  Self.CPos.y:=Self.CPos.y - Self.CNSide.y*Dist;

  Self.UpdateModelViewTranslate();
  {$R+}
end;

procedure CFirtsPersonViewCamera.StepRight(const Dist: GLfloat);
begin
  {$R-}
  Self.CPos.x:=Self.CPos.x + Self.CNSide.x*Dist;
  Self.CPos.y:=Self.CPos.y + Self.CNSide.y*Dist;

  Self.UpdateModelViewTranslate();
  {$R+}
end;


procedure CFirtsPersonViewCamera.UpdateViewDirectionByMouseX(const AzimutalOffset: GLfloat);
begin
  {$R-}
  Self.CAlpha:=Self.CAlpha + AzimutalOffset;
  Self.WrapCAlpha();
  //
  Self.CNSide.x:=-Cos(Self.CAlpha);
  Self.CNSide.y:=Sin(Self.CAlpha);

  Self.CNDir.x:=-Self.CNSide.y*Self.CNUp.z;
  Self.CNDir.y:=Self.CNSide.x*Self.CNUp.z;
  //
  Self.CNUp.x:=Self.CNSide.y*Self.CNDir.z;
  Self.CNUp.y:=-Self.CNSide.x*Self.CNDir.z;

  Self.RebuildModelView();
  {$R+}
end;

procedure CFirtsPersonViewCamera.UpdateViewDirectionByMouseY(const PolarOffset: GLfloat);
begin
  {$R-}
  Self.CBetta:=Self.CBetta + PolarOffset;
  Self.ClampPolarAngle();
  //
  Self.CNDir.z:=Sin(Self.CBetta);
  Self.CNUp.z:=Cos(Self.CBetta);
  //
  Self.CNDir.x:=-Self.CNSide.y*Self.CNUp.z;
  Self.CNDir.y:=Self.CNSide.x*Self.CNUp.z;
  //
  Self.CNUp.x:=Self.CNSide.y*Self.CNDir.z;
  Self.CNUp.y:=-Self.CNSide.x*Self.CNDir.z;

  Self.RebuildModelView();
  {$R+}
end;

procedure CFirtsPersonViewCamera.SetProjMatrix(const ScreenWidth, ScreenHeight: GLint;
  FieldOfView, zFar: GLfloat);
begin
  {$R-}
  Self.CFieldOfView:=FieldOfView;
  if (Self.CFieldOfView < FieldOfViewMin) then Self.CFieldOfView:=FieldOfViewMin;
  if (Self.CFieldOfView > FieldOfViewMax) then Self.CFieldOfView:=FieldOfViewMax;

  Self.CWidth:=ScreenWidth;
  Self.CHeight:=ScreenHeight;
  if (Self.CWidth <= 1) then Self.CWidth:=1;
  if (Self.CHeight <= 1) then Self.CHeight:=1;
  Self.CAspectRation:=Self.CWidth/Self.CHeight;

  Self.CZFar:=zFar;
  if (Self.CZFar < zFarMin) then Self.CZFar:=zFarMin;

  Self.FSin:=Sin(Self.CFieldOfView*Pi360);
  Self.FCos:=Cos(Self.CFieldOfView*Pi360);
  Self.FCosDivAspect:=Self.FCos/Self.CAspectRation;

  Self.CSizeY:=Self.FSin/Self.FCos;
  Self.CSizeX:=Self.CAspectRation*Self.CSizeY;

  Self.CProjMat4f[0]:=1.0/Self.CSizeX;
  Self.CProjMat4f[5]:=1.0/Self.CSizeY;
  Self.CProjMat4f[10]:=(Self.CZFar + 1.0)/(1.0 - Self.CZFar);
  Self.CProjMat4f[14]:=2.0*Self.CZFar/(1.0 - Self.CZFar);
  {$R+}
end;

procedure CFirtsPersonViewCamera.glModelViewUpdate();
begin
  {$R-}
  glMatrixMode(GL_MODELVIEW);
  glLoadMatrixf(@Self.CModelMat4f[0]);
  {$R+}
end;

procedure CFirtsPersonViewCamera.glProjectionAndViewPortUpdate();
begin
  {$R-}
  glViewport(0, 0, Self.CWidth, Self.CHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadMatrixf(@Self.CProjMat4f[0]);
  {$R+}
end;

procedure CFirtsPersonViewCamera.GetTraceLineByMouseClick(const MousePosWinCoord: TPoint;
  const Ray: PRay);
var
  x, y: GLfloat;
begin
  {$R-}
  x:=Self.CSizeX*(2.0*MousePosWinCoord.X/Self.CWidth - 1.0);
  y:=Self.CSizeY*(1.0 - 2.0*MousePosWinCoord.Y/Self.CHeight);

  Ray.Dir.x:=x*Self.CNSide.x + y*Self.CNUp.x + Self.CNDir.x;
  Ray.Dir.y:=x*Self.CNSide.y + y*Self.CNUp.y + Self.CNDir.y;
  Ray.Dir.z:=y*Self.CNUp.z + Self.CNDir.z;
  NormalizeVec3f(@Ray.Dir);

  Ray.Start:=Self.CPos;
  {$R+}
end;

destructor CFirtsPersonViewCamera.DeleteCamera();
begin
  {$R-}
  inherited;
  {$R+}
end;

end.
