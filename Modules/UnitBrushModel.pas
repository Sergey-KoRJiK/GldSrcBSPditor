unit UnitBrushModel;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  UnitVec;

type tBrushModel = record
    vMin, vMax: tVec3f;
    Origin: tVec3f;
    iNode: Integer;
    iClipNode0, iClipNode1: Integer;
    iSpecialNode: Integer;
    nVisLeafs: Integer;
    iFirstFace, nFaces: Integer;
  end;
type PBrushModel = ^tBrushModel;
type ABrushModel = array of tBrushModel;

type tBrushModelInfo = record
    isBrushWithEntityOrigin: Boolean;
    BBOXf: tBBOXf;
    Origin: tVec3f;
    EntityId: Integer;
  end;
type PBrushModelInfo = ^tBrushModelInfo;
type ABrushModelInfo = array of tBrushModelInfo;

const
  SizeOfBrushModel = SizeOf(tBrushModel);


function TestPointInBrush(const Brush: tBrushModel; const Point: tVec3f): boolean; overload;
function TestPointInBrush(const Brush: tBrushModel; const Point: tVec3s): boolean; overload;


implementation


function TestPointInBrush(const Brush: tBrushModel; const Point: tVec3f): boolean; overload;
begin
  {$R-}
  if (Point.x < Brush.vMin.x) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.y < Brush.vMin.y) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.z < Brush.vMin.z) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.x > Brush.vMax.x) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.y > Brush.vMax.y) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.z > Brush.vMax.z) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  TestPointInBrush:=True;
  {$R+}
end;

function TestPointInBrush(const Brush: tBrushModel; const Point: tVec3s): boolean; overload;
begin
  {$R-}
  if (Point.x < Brush.vMin.x) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.y < Brush.vMin.y) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.z < Brush.vMin.z) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.x > Brush.vMax.x) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.y > Brush.vMax.y) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  if (Point.z > Brush.vMax.z) then
    begin
      TestPointInBrush:=False;
      Exit;
    end;

  TestPointInBrush:=True;
  {$R+}
end;

end.
 