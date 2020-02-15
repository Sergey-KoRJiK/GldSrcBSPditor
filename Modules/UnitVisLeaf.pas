unit UnitVisLeaf;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  UnitVec;

const
  CONTENTS_EMPTY: Integer = -1;
  CONTENTS_SOLID: Integer = -2;
  CONTENTS_WATER: Integer = -3;
  CONTENTS_SLIME: Integer = -4;
  CONTENTS_LAVA: Integer = -5;
  CONTENTS_SKY: Integer = -6;
  CONTENTS_ORIGIN: Integer = -7;
  CONTENTS_CLIP: Integer = -8;
  CONTENTS_CURRENT_0: Integer = -9;
  CONTENTS_CURRENT_90: Integer = -10;
  CONTENTS_CURRENT_180: Integer = -11;
  CONTENTS_CURRENT_270: Integer = -12;
  CONTENTS_CURRENT_UP: Integer = -13;
  CONTENTS_CURRENT_DOWN: Integer = -14;
  CONTENTS_TRANSLUCENT: Integer = -15;

type tVisLeaf = record
    nContents: Integer;
    nVisOffset: Integer;
    nMin, nMax: tVec3s; //BBOX
    iFirstMarkSurface, nMarkSurfaces: SmallInt;
    nAmbientLevels: array[0..3] of Byte;
  end;
type PVisLeaf = ^tVisLeaf;
type AVisLeaf = array of tVisLeaf;

type tVisLeafInfo = record
    BBOXf: tBBOXf;
    BBOXs: tBBOXs;
    SizeBBOXf: tVec3f;
    CountFaces: Integer;
    FaceIndexes: AInt;
    CountBrushFace: Integer;
    BrushFaceIndexes: AInt;
    CountPVS: Integer;
    PVS: AByteBool;
  end;
type PVisLeafInfo = ^tVisLeafInfo;
type AVisLeafInfo = array of tVisLeafInfo;

const
  SizeOfVisLeaf = SizeOf(tVisLeaf);
  

function TestGoodLeafBBOX(const Leaf: tVisLeaf): Boolean;
function IsGoodLeafContents(const Leaf: tVisLeaf): Boolean;

function TestPointInVisLeaf(const Leaf: tVisLeaf; const Point: tVec3f): boolean; overload;
function TestPointInVisLeaf(const Leaf: tVisLeaf; const Point: tVec3s): boolean; overload;


implementation


function TestGoodLeafBBOX(const Leaf: tVisLeaf): Boolean;
begin
  {$R-}
  TestGoodLeafBBOX:=False;
  with Leaf do
    begin
      if (nMin.x > nMax.x) then Exit;
      if (nMin.y > nMax.y) then Exit;
      if (nMin.z > nMax.z) then Exit;
    end;
  TestGoodLeafBBOX:=True;
  {$R+}
end;

function IsGoodLeafContents(const Leaf: tVisLeaf): Boolean;
begin
  {$R-}
  if ( (Leaf.nContents > -1) and (Leaf.nContents < -15) )
  then IsGoodLeafContents:=False else IsGoodLeafContents:=True;
  {$R+}
end;

function TestPointInVisLeaf(const Leaf: tVisLeaf; const Point: tVec3f): boolean; overload;
begin
  {$R-}
  TestPointInVisLeaf:=False;
  with Leaf do
    begin
      if (Point.x < nMin.x) then Exit;
      if (Point.y < nMin.y) then Exit;
      if (Point.z < nMin.z) then Exit;
      if (Point.x > nMax.x) then Exit;
      if (Point.y > nMax.y) then Exit;
      if (Point.z > nMax.z) then Exit;
    end;
  TestPointInVisLeaf:=True;
  {$R+}
end;

function TestPointInVisLeaf(const Leaf: tVisLeaf; const Point: tVec3s): boolean; overload;
begin
  {$R-}
  TestPointInVisLeaf:=False;
  with Leaf do
    begin
      if (Point.x < nMin.x) then Exit;
      if (Point.y < nMin.y) then Exit;
      if (Point.z < nMin.z) then Exit;
      if (Point.x > nMax.x) then Exit;
      if (Point.y > nMax.y) then Exit;
      if (Point.z > nMax.z) then Exit;
    end;
  TestPointInVisLeaf:=True;
  {$R+}
end;

end.
