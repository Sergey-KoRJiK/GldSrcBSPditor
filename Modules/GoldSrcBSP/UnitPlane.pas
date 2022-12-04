unit UnitPlane;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus

interface

uses
  UnitVec,
  UnitUserTypes;

const
  PLANE_X =      0;
  PLANE_Y =      1;
  PLANE_Z =      2;
  PLANE_ANY_X =  3;
  PLANE_ANY_Y =  4;
  PLANE_ANY_Z =  5;

type tPlaneBSP = record
    vNormal: tVec3f;
    fDist: Single;
    AxisType: Integer;
  end;
type PPlaneBSP = ^tPlaneBSP;
type APlaneBSP = array of tPlaneBSP;

const
  PLANEBSP_NULL: tPlaneBSP = (vNormal: (x: 0.0; y: 0.0; z: 0.0); fDist: 0.0; AxisType: 5);
  

function isPointInFrontPlaneSpace(const Plane: PPlaneBSP; const Point: tVec3f): Boolean; overload;
function isPointInFrontPlaneSpaceFull(const Plane: PPlaneBSP; const Point: tVec3f): Boolean; overload;
// Full test use only Dot(Normal, Point);
// other test use fast test by AxisType and if failure fast tests - use Full Test.

function GetPlaneByPoints(const V0, V1, V2: tVec3f; const Plane: PPlaneBSP): Boolean; overload;
// Normal = Cross(V2 - V0, V1 - V0), if Normal is zeros -> return False;

function GetPlaneTypeByNormal(const Normal: tVec3f): Integer;

procedure TranslatePlane(const SrcPlane, DstPlane: PPlaneBSP; const Offset: Single); overload;
procedure TranslatePlane(const SrcPlane, DstPlane: PPlaneBSP; const OffsetVec: tVec3f); overload;
// First, translate plane by add Offset to Plane.fDist
// Second, translate plane by project OffsetVec on Plane.Normal and add this
// project result to Plane.fDist

function PlaneToStr(const PlaneBSP: tPlaneBSP): String;
function PlaneToStrExt(const PlaneBSP: tPlaneBSP): String;

implementation


function isPointInFrontPlaneSpace(const Plane: PPlaneBSP; const Point: tVec3f): Boolean;
begin
  {$R-}
  if (Plane.AxisType = PLANE_X) then
    begin
      if (PInteger(@Plane.vNormal.x)^ >= 0) then
        begin
          Result:=Boolean(Point.x >= Plane.fDist);
          Exit;
        end
      else
        begin
          Result:=Boolean(Point.x <= -Plane.fDist);
          Exit;
        end;
    end;

  if (Plane.AxisType = PLANE_Y) then
    begin
      if (PInteger(@Plane.vNormal.y)^ >= 0) then
        begin
          Result:=Boolean(Point.y >= Plane.fDist);
          Exit;
        end
      else
        begin
          Result:=Boolean(Point.y <= -Plane.fDist);
          Exit;
        end;
    end;

  if (Plane.AxisType = PLANE_Z) then
    begin
      if (PInteger(@Plane.vNormal.z)^ >= 0) then
        begin
          Result:=Boolean(Point.z >= Plane.fDist);
          Exit;
        end
      else
        begin
          Result:=Boolean(Point.z <= -Plane.fDist);
          Exit;
        end;
    end;

  Result:=Boolean(
    ( Plane.vNormal.x*Point.x +
      Plane.vNormal.y*Point.y +
      Plane.vNormal.z*Point.z ) >= Plane.fDist
  );
  {$R+}
end;



function isPointInFrontPlaneSpaceFull(const Plane: PPlaneBSP; const Point: tVec3f): Boolean;
begin
  {$R-}
  isPointInFrontPlaneSpaceFull:=Boolean(
    ( Plane.vNormal.x*Point.x +
      Plane.vNormal.y*Point.y +
      Plane.vNormal.z*Point.z ) >= Plane.fDist
  );
  {$R+}
end;

function GetPlaneByPoints(const V0, V1, V2: tVec3f; const Plane: PPlaneBSP): Boolean;
var
  Edge1, Edge2: tVec3f;
begin
  {$R-}
  // Get Edges
  Edge1.x:=V1.x - V0.x;
  Edge1.y:=V1.y - V0.y;
  Edge1.z:=V1.z - V0.z;

  Edge2.x:=V2.x - V0.x;
  Edge2.y:=V2.y - V0.y;
  Edge2.z:=V2.z - V0.z;

  // Get Normal by Cross(Edge2, Edge1);
  Plane.vNormal.x:=Edge2.y*Edge1.z - Edge2.z*Edge1.y;
  Plane.vNormal.y:=Edge2.z*Edge1.x - Edge2.x*Edge1.z;
  Plane.vNormal.z:=Edge2.x*Edge1.y - Edge2.y*Edge1.x;

  // Normalize plane end check if normal is zeros
  if (NormalizeVec3f(@Plane.vNormal) = False) then
    begin
      // Triple Points V0..2 is bad, belong to both line.
      GetPlaneByPoints:=False;
      Exit;
    end;

  // Get fourth parameter of Plane Equation
  Plane.fDist:=Plane.vNormal.x*V0.x + Plane.vNormal.y*V0.y + Plane.vNormal.z*V0.z;

  // dont get AxisType, set default
  Plane.AxisType:=PLANE_ANY_Z;
  Result:=True;
  {$R+}
end;

function GetPlaneTypeByNormal(const Normal: tVec3f): Integer;
var
  maxf: Single;
  axis: Integer;
begin
  {$R-}
  // based on GitHub, Valve Source SDK 2013, vbsp, map.cpp:
  // |x| = abs(x), N = Plane Normal;
  // 0-2 are axial planes
  //   PLANE_X: Integer =    0; // vbsp (map.cpp) set when |N.x| = 0x3f800000;
  //   PLANE_Y: Integer =    1; // vbsp (map.cpp) set when |N.y| = 0x3f800000;
  //   PLANE_Z: Integer =    2; // vbsp (map.cpp) set when |N.z| = 0x3f800000;
  // 3-5 are non-axial planes snapped to the nearest
  //   PLANE_ANYX: Integer = 3; // vbsp (map.cpp) set when |N.x| >= Max(|N.y|, |N.z|);
  //   PLANE_ANYY: Integer = 4; // vbsp (map.cpp) set when |N.y| >= Max(|N.x|, |N.z|);
  //   PLANE_ANYZ: Integer = 5; // vbsp (map.cpp) set in other "non-axial plane" cases

  if (Abs(Normal.x) = 1.0) then
    begin
      Result:=PLANE_X;
      Exit;
    end;

  if (Abs(Normal.y) = 1.0) then
    begin
      Result:=PLANE_Y;
      Exit;
    end;

  if (Abs(Normal.z) = 1.0) then
    begin
      Result:=PLANE_Z;
      Exit;
    end;

  maxf:=Abs(Normal.x);
  axis:=0;
  if (maxf > Normal.y) then
    begin
      maxf:=Abs(Normal.y);
      axis:=1;
    end;
  if (maxf > Abs(Normal.z)) then axis:=2;

  case (axis) of
    0: Result:=PLANE_ANY_X;
    1: Result:=PLANE_ANY_Y;
  else
    Result:=PLANE_ANY_Z;
  end;
  {$R+}
end;

procedure TranslatePlane(const SrcPlane, DstPlane: PPlaneBSP; const Offset: Single);
begin
  {$R-}
  DstPlane.fDist:=SrcPlane.fDist + Offset;
  {$R+}
end;

procedure TranslatePlane(const SrcPlane, DstPlane: PPlaneBSP; const OffsetVec: tVec3f);
begin
  {$R-}
  DstPlane.fDist:=SrcPlane.fDist +
    OffsetVec.x*SrcPlane.vNormal.x +
    OffsetVec.y*SrcPlane.vNormal.y +
    OffsetVec.z*SrcPlane.vNormal.z;
  {$R+}
end;


function PlaneToStr(const PlaneBSP: tPlaneBSP): String;
begin
  {$R-}
  Result:='[' + VecToStr(PlaneBSP.vNormal) + ', ' + FloatToStrFixed(PlaneBSP.fDist) + ']';
  {$R+}
end;

function PlaneToStrExt(const PlaneBSP: tPlaneBSP): String;
begin
  {$R-}
  Result:='[Normal: ' + VecToStr(PlaneBSP.vNormal) +
    ', fDist: ' + FloatToStrFixed(PlaneBSP.fDist) +
    ', Axis type: ';
  case (PlaneBSP.AxisType) of
    PLANE_X: Result:=Result + 'PLANE_X]';
    PLANE_Y: Result:=Result + 'PLANE_Y]';
    PLANE_Z: Result:=Result + 'PLANE_Z]';
    PLANE_ANY_X: Result:=Result + 'PLANE_ANY_X]';
    PLANE_ANY_Y: Result:=Result + 'PLANE_ANY_Y]';
    PLANE_ANY_Z: Result:=Result + 'PLANE_ANY_Z]';
  else
    Result:=Result + 'Unknown]';
  end;
  {$R+}
end;

end.
