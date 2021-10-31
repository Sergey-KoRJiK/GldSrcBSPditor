unit UnitClipNode;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  Windows,
  UnitUserTypes,
  UnitPlane;

type tClipNode = packed record
    iPlane: Integer;
    iChildren: array[0..1] of SmallInt;
  end;
type PClipNode = ^tClipNode;
type ACLipNode = array of tClipNode;

type tClipNodeExt = record
    BaseClipNode: tClipNode;
    iClipNode: Integer;
    //
    Plane: tPlaneBSP;
    //
    IsFrontClipNode: Boolean;
    IsBackClipNode: Boolean;
    FrontIndex: Integer;
    BackIndex: Integer;
    // Make ClipNode tree as "doubly linked list" by primary address
    lpFrontClipNodeExt: Pointer;
    lpBackClipNodeExt: Pointer;
  end;
type PClipNodeExt = ^tClipNodeExt;
type AClipNodeExt = array of tClipNodeExt;


type tCollisionInfo = packed record
    lpClipTree: PClipNodeExt;
    iClipNode: Integer;
    State: Integer;
    Depth: Integer;
    iClipList: array[0..32767] of SmallInt; // Size = Depth; "neg-terminated"
  end;
type PCollisionInfo = ^tCollisionInfo;


const
  CLIPCONTEST_EMPTY = -1;
  CLIPCONTEST_SOLID = -2;


procedure GetCollisionInfo(const CollisionInfo: PCollisionInfo;
  const ClipNodeExtList: PClipNodeExt; const Point: tVec3f);


implementation


procedure GetCollisionInfo(const CollisionInfo: PCollisionInfo;
  const ClipNodeExtList: PClipNodeExt; const Point: tVec3f);
var
  lpClipNodeExt: PClipNodeExt;
begin
  {$R-}
  CollisionInfo.lpClipTree:=ClipNodeExtList;
  lpClipNodeExt:=CollisionInfo.lpClipTree;
  //
  CollisionInfo.State:=0;
  CollisionInfo.Depth:=1;
  CollisionInfo.iClipNode:=lpClipNodeExt.iClipNode;
  CollisionInfo.iClipList[0]:=CollisionInfo.iClipNode;
  CollisionInfo.iClipList[1]:=-1;

  // Walk in Binary Tree
  while (lpClipNodeExt <> nil) do
    begin
      if (isPointInFrontPlaneSpace(@lpClipNodeExt.Plane, Point)) then
        begin
          // Front plane part + Point on plane
          if (lpClipNodeExt.IsFrontClipNode) then
            begin
              // Next Front Child is ClipNode
              lpClipNodeExt:=lpClipNodeExt.lpFrontClipNodeExt;
              CollisionInfo.iClipNode:=lpClipNodeExt.iClipNode;
              CollisionInfo.iClipList[CollisionInfo.Depth]:=CollisionInfo.iClipNode;
              Inc(CollisionInfo.Depth);
            end
          else
            begin
              // Next Front Child is Collision state
              CollisionInfo.State:=lpClipNodeExt.FrontIndex;
              CollisionInfo.iClipNode:=lpClipNodeExt.iClipNode;
              CollisionInfo.iClipList[CollisionInfo.Depth]:=-1;
              Exit;
            end;
        end
      else
        begin
          // Back plane part
          if (lpClipNodeExt.IsBackClipNode) then
            begin
              // Next Back Child is ClipNode
              lpClipNodeExt:=lpClipNodeExt.lpBackClipNodeExt;
              CollisionInfo.iClipNode:=lpClipNodeExt.iClipNode;
              CollisionInfo.iClipList[CollisionInfo.Depth]:=CollisionInfo.iClipNode;
              Inc(CollisionInfo.Depth);
            end
          else
            begin
              // Next Back Child is Collision state
              CollisionInfo.State:=lpClipNodeExt.BackIndex;
              CollisionInfo.iClipNode:=lpClipNodeExt.iClipNode;
              CollisionInfo.iClipList[CollisionInfo.Depth]:=-1;
              Exit;
            end;
        end;
    end;
  {$R+}
end;

end.
