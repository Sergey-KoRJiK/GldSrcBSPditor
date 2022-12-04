unit UnitNode;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus

interface

uses
  Windows,
  UnitUserTypes,
  UnitVec,
  UnitPlane;
  

type tNode = packed record
    iPlane: DWORD;
    iChildren: array[0..1] of SmallInt;
    nBBOX: tBBOXs;
    firstFace, nFaces: WORD;
  end;
type PNode = ^tNode;
type ANode = array of tNode;

type tNodeExt = record
    BaseNode: tNode;
    //
    Plane: tPlaneBSP;
    BBOXf: tBBOXf;
    //
    IsFrontNode: Boolean;
    IsBackNode: Boolean;
    FrontIndex: Integer;
    BackIndex: Integer;
    // Make Node tree as "doubly linked list" by primary address
    lpFrontNodeExt: Pointer;
    lpBackNodeExt: Pointer;
    lpFrontLeafExt: Pointer;
    lpBackLeafExt: Pointer;
  end;
type PNodeExt = ^tNodeExt;
type ANodeExt = array of tNodeExt;


function isLeafChildrenId0(const lpNodeExt: PNodeExt): Boolean;
function isLeafChildrenId1(const lpNodeExt: PNodeExt): Boolean;
function GetIndexLeafChildrenId0(const lpNodeExt: PNodeExt): Integer;
function GetIndexLeafChildrenId1(const lpNodeExt: PNodeExt): Integer;

function GetLeafIndexByPoint(const NodeExtList: PNodeExt; const Point: tVec3f;
  const RootIndex: Integer): Integer;


implementation


function isLeafChildrenId0(const lpNodeExt: PNodeExt): Boolean;
begin
  {$R-}
  if (lpNodeExt.BaseNode.iChildren[0] <= 0) then isLeafChildrenId0:=True
  else isLeafChildrenId0:=False;
  {$R+}
end;

function isLeafChildrenId1(const lpNodeExt: PNodeExt): Boolean;
begin
  {$R-}
  if (lpNodeExt.BaseNode.iChildren[1] <= 0) then isLeafChildrenId1:=True
  else isLeafChildrenId1:=False;
  {$R+}
end;

function GetIndexLeafChildrenId0(const lpNodeExt: PNodeExt): Integer;
begin
  {$R-}
  GetIndexLeafChildrenId0:=Integer(SmallInt(-lpNodeExt.BaseNode.iChildren[0] - 1));
  {$R+}
end;

function GetIndexLeafChildrenId1(const lpNodeExt: PNodeExt): Integer;
begin
  {$R-}
  GetIndexLeafChildrenId1:=Integer(SmallInt(-lpNodeExt.BaseNode.iChildren[1] - 1));
  {$R+}
end;


function GetLeafIndexByPoint(const NodeExtList: PNodeExt; const Point: tVec3f;
  const RootIndex: Integer): Integer;
var
  lpNodeExt: PNodeExt;
begin
  {$R-}
  Result:=0;
  lpNodeExt:=NodeExtList;
  Inc(lpNodeExt, RootIndex);

  // Walk in Binary Tree
  //while (TestPointInBBOX(lpNodeExt.BBOXf, Point)) do
  while (lpNodeExt <> nil) do
    begin
      if (isPointInFrontPlaneSpace(@lpNodeExt.Plane, Point)) then
        begin
          // Front plane part + Point on plane
          if (lpNodeExt.IsFrontNode) then
            begin
              // Next Front Child is Node
              lpNodeExt:=lpNodeExt.lpFrontNodeExt;
            end
          else
            begin
              // Next Front Child is Leaf
              Result:=lpNodeExt.FrontIndex;
              Exit;
            end;
        end
      else
        begin
          // Back plane part
          if (lpNodeExt.IsBackNode) then
            begin
              // Next Back Child is Node
              lpNodeExt:=lpNodeExt.lpBackNodeExt;
            end
          else
            begin
              // Next Back Child is Leaf
              Result:=lpNodeExt.BackIndex;
              Exit;
            end;
        end;
    end;
  {$R+}
end;

end.
