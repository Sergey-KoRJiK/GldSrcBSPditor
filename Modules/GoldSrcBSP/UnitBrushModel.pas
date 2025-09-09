unit UnitBrushModel;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

interface

uses
  UnitUserTypes;

const
  MAX_HULLS = 4;
  // 0: Node+VisLeaf Hull
  // 1: ClipNode Player
  // 2: ClipNode unknown
  // 3: ClipNode Player crouch.
  HULL_SIZE: array[0..MAX_HULLS-1, 0..1] of tVec3f = (
    ((x:   0; y:   0; z:   0), (x:   0; y:   0; z:   0)),
    ((x: -16; y: -16; z: -36), (x:  16; y:  16; z:  36)), // 32x32x72
    ((x: -32; y: -32; z: -32), (x:  32; y:  32; z:  32)), // 64x64x64
    ((x: -16; y: -16; z: -18), (x:  16; y:  16; z:  18))  // 32x32x36
  );

type tBrushModel = packed record
    vMin: tVec3f;
    vMax: tVec3f;
    Origin: tVec3f;
    iHull: array[0..MAX_HULLS-1] of Integer;
    nVisLeafs: Integer; // Count visleaf for local Node tree (it's also CountPVS)
    iFirstFace, nFaces: Integer;
  end;
type PBrushModel = ^tBrushModel;
type ABrushModel = array of tBrushModel;

type tBrushModelExt = record
    BaseBModel: tBrushModel;
    Origin: tVec4f;
    ShiftBBOX4f: tBBOX4f;
    EntityId: Integer;
    iLastFace: Integer;
    isBrushWithEntityOrigin: Boolean;
    isAAATrigger: Boolean;
  end;
type PBrushModelExt = ^tBrushModelExt;
type ABrushModelExt = array of tBrushModelExt;


procedure FreeBrushModelExt(const lpBrushModelExt: PBrushModelExt);


implementation


procedure FreeBrushModelExt(const lpBrushModelExt: PBrushModelExt);
begin
  {$R-}
  lpBrushModelExt.isBrushWithEntityOrigin:=False;
  lpBrushModelExt.Origin:=VEC_ZERO_4F;
  lpBrushModelExt.EntityId:=0;
  lpBrushModelExt.iLastFace:=-1;
  lpBrushModelExt.ShiftBBOX4f:=BBOX_ZERO_4F;
  {$R+}
end;


end.
