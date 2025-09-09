unit UnitClipNode;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

interface

uses
  Windows,
  UnitUserTypes,
  UnitVec;

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
    Plane: tPlane;
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
    iClipCandidate: Integer; // ClipNode with plane, which closet to collide
    fDistCanditate: Single;
  end;
type PCollisionInfo = ^tCollisionInfo;


const
  CLIPCONTEST_EMPTY = -1;
  CLIPCONTEST_SOLID = -2;


procedure GetCollisionInfo(const CollisionInfo: PCollisionInfo;
  const ClipNodeExtList: PClipNodeExt; const Point: tVec4f);


implementation


procedure GetCollisionInfo(const CollisionInfo: PCollisionInfo;
  const ClipNodeExtList: PClipNodeExt; const Point: tVec4f);
var
  lpClipNodeExt: PClipNodeExt;
  tmpDist: Single;
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
  CollisionInfo.iClipCandidate:=-1;
  CollisionInfo.fDistCanditate:=FLOAT32_INF_POSITIVE;

  // Conception of BSP Tree work with convex volumes in leafs of tree.
  // And for easest way to determinate if a point inside in convex volume
  // we need find all "distances" between point and planes that form a volume.
  // We define that normals of places look outside from volume, then
  // if one or more planes give a positive "distance", then point outside from
  // volume, if any (must only one) "distance" = 0, then point start touch
  // a volume, and if all "distance" is negative, then point inside a volume.
  // Ok, now we know how detect point collision... But more interest, which
  // plane gave a collision for make a "slide" effect of move point on plane.
  // And answe is eazy - plane which give "distance = " zero or, for system
  // with non-zero time delay - plane with minimal "distance" (and where
  // next collision test give answer "point in volime").
  // So we always have two points: "current" and "predictable" positions and
  // repeat collision check until found it. Creteria for found:
  // "current" posotion outside volume and "predictable" position inside volume.
  // Then we use information about plane (with minimal distance on previous
  // calculate with "current" position) for calculate slide vector and distance.

  // Walk in Binary Tree
  while (lpClipNodeExt <> nil) do
    begin
      tmpDist:=GetPointPlaneDistanceFull(@lpClipNodeExt.Plane, Point);
      if (tmpDist >= 0) then
        begin
          // Front plane part + Point on plane
          CollisionInfo.iClipNode:=lpClipNodeExt.iClipNode;
          if (tmpDist < CollisionInfo.fDistCanditate) then
            begin
              CollisionInfo.fDistCanditate:=tmpDist;
              CollisionInfo.iClipCandidate:=CollisionInfo.iClipNode;
            end;
          if (lpClipNodeExt.IsFrontClipNode) then
            begin
              // Next Front Child is ClipNode
              lpClipNodeExt:=lpClipNodeExt.lpFrontClipNodeExt;
              CollisionInfo.iClipList[CollisionInfo.Depth]:=CollisionInfo.iClipNode;
              Inc(CollisionInfo.Depth);
            end
          else
            begin
              // Next Front Child is Collision state
              CollisionInfo.State:=lpClipNodeExt.FrontIndex;
              CollisionInfo.iClipList[CollisionInfo.Depth]:=-1;
              Exit;
            end;
        end
      else
        begin
          // Back plane part
          CollisionInfo.iClipNode:=lpClipNodeExt.iClipNode;
          if (lpClipNodeExt.IsBackClipNode) then
            begin
              // Next Back Child is ClipNode
              lpClipNodeExt:=lpClipNodeExt.lpBackClipNodeExt;
              CollisionInfo.iClipList[CollisionInfo.Depth]:=CollisionInfo.iClipNode;
              Inc(CollisionInfo.Depth);
            end
          else
            begin
              // Next Back Child is Collision state
              CollisionInfo.State:=lpClipNodeExt.BackIndex;
              CollisionInfo.iClipList[CollisionInfo.Depth]:=-1;
              Exit;
            end;
        end;
    end;
  {$R+}
end;

end.
