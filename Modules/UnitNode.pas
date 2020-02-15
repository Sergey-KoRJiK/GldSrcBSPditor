unit UnitNode;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  UnitVec,
  UnitPlane;

type tNode = record
    iPlane: DWORD;
    iChildren: array[0..1] of SmallInt;
    nMin, nMax: tVec3s; //BBOX
    firstFace, nFaces: WORD;
  end;
type PNode = ^tNode;
type ANode = array of tNode;

type tNodeInfo = record
    Plane: tPlane;
    BBOXf: tBBOXf;
    BBOXs: tBBOXs;
    IsFrontNode: Boolean;
    IsBackNode: Boolean;
    FrontIndex: Integer;
    BackIndex: Integer;
    // Primary Addres
    lpFrontNodeInfo: Pointer;
    lpBackNodeInfo: Pointer;
    lpFrontLeafInfo: Pointer;
    lpBackLeafInfo: Pointer;
  end;
type PNodeInfo = ^tNodeInfo;
type ANodeInfo = array of tNodeInfo;

const
  SizeOfNode = SizeOf(tNode);
  

function isLeafChildrenId0(const Node: PNode): Boolean;
function isLeafChildrenId1(const Node: PNode): Boolean;
function GetIndexLeafChildrenId0(const Node: PNode): Integer;
function GetIndexLeafChildrenId1(const Node: PNode): Integer;


implementation


function isLeafChildrenId0(const Node: PNode): Boolean;
begin
  {$R-}
  if (Node.iChildren[0] <= 0) then isLeafChildrenId0:=True
  else isLeafChildrenId0:=False;
  {$R+}
end;

function isLeafChildrenId1(const Node: PNode): Boolean;
begin
  {$R-}
  if (Node.iChildren[1] <= 0) then isLeafChildrenId1:=True
  else isLeafChildrenId1:=False;
  {$R+}
end;

function GetIndexLeafChildrenId0(const Node: PNode): Integer;
begin
  {$R-}
  GetIndexLeafChildrenId0:=Integer(SmallInt(-Node.iChildren[0] - 1));
  {$R+}
end;

function GetIndexLeafChildrenId1(const Node: PNode): Integer;
begin
  {$R-}
  GetIndexLeafChildrenId1:=Integer(SmallInt(-Node.iChildren[1] - 1));
  {$R+}
end;

end.
