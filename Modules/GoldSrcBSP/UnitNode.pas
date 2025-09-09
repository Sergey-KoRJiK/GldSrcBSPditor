unit UnitNode;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

interface

uses
  Windows,
  UnitUserTypes,
  UnitVec;
  

type tNode = packed record
    iPlane: DWORD;
    iChildren: array[0..1] of SmallInt;
    nBBOX: tBBOXs;
    firstFace, nFaces: WORD;
  end;  // 24 Bytes
type PNode = ^tNode;
type ANode = array of tNode;

type tNodeExt = packed record
    BaseNode  : tNode; // 24 Bytes
    Plane     : tPlane; // 16 Bytes
    //
    // if Index = $FFFF then child is Node, else - child is Leaf
    FrontIndex: Word;
    BackIndex : Word;
    // Make Node tree as "depth-way linked list" by primary address
    lpFrontNodeExt: Pointer;
    lpBackNodeExt: Pointer;
  end; // 
type PNodeExt = ^tNodeExt;
type ANodeExt = array of tNodeExt;


function GetLeafIndexByPointAsm(const RootNodeExt: PNodeExt; const Point: tVec4f): Integer;


implementation


function GetLeafIndexByPointAsm(const RootNodeExt: PNodeExt; const Point: tVec4f): Integer;
asm
  {$R-}
  // EAX = RootNodeExt; EDX = Point; Result to EAX (AX)
  PUSH    EDX
  FLD     tVec4f[EDX].x
  FLD     tVec4f[EDX].y
  FLD     tVec4f[EDX].z
  // FPU x87 Stack = st0..i (i from 0 to 7) = (st0 = ..., st1 = ..., ... ect.):
  // st0..2 = (Point.z, Point.y, Point.x)
  //
@@LoopLeaf:
  TEST    EAX, EAX
  JZ    @@NullExit
  //
  // Plane-Point test part, N = Normal (Nx = Normal.x, ... ect.), P = Point:
  FLD     tNodeExt[EAX].Plane.Dist
  FLD     tNodeExt[EAX].Plane.Normal.x  // st0..4 = (Nx, Dist, Pz, Py, Px)
  FMUL    ST(0), ST(4)
  FLD     tNodeExt[EAX].Plane.Normal.y  // st0..5 = (Ny, Nx*Px, Dist, Pz, Py, Px)
  FMUL    ST(0), ST(4)
  FLD     tNodeExt[EAX].Plane.Normal.z  // st0..6 = (Nz, Ny*Py, Nx*Px, Dist, Pz, Py, Px)
  FMUL    ST(0), ST(4)
  FADDP   ST(1), ST(0)
  FADDP   ST(1), ST(0)                  // st0..4 = (DotVec(N, P), Dist, Pz, Py, Px)
  FCOMIP  ST(0), ST(1)
  FSTP    ST(0)                         // st0..2 = (Pz, Py, Px)
  // EFLAGS: if (DotVec(N, P) >= Dist) then CF = 0 (cc=AE), else CF = 1 (cc=B).
  // if (CF = 0) then "Point in Front part of plane space or lie on plane",
  // else "Point in Back part of plane space". Normal of plane look to Front space.
  //
  JB    @@BackPlanePart
  // Front plane part + point on plane
  MOV      DX, tNodeExt[EAX].FrontIndex
  CMP      DX, $FFFF
  JNZ    @@ChildIsLeaf
  // Front is Node
  MOV     EAX, tNodeExt[EAX].lpFrontNodeExt
  JMP   @@LoopLeaf
@@BackPlanePart:
  // Back plane part
  MOV      DX, tNodeExt[EAX].BackIndex
  CMP      DX, $FFFF
  JNZ    @@ChildIsLeaf
  // Back is Node
  MOV     EAX, tNodeExt[EAX].lpBackNodeExt
  JMP   @@LoopLeaf

@@ChildIsLeaf:
  // Child is Leaf
  MOVZX   EAX, DX
  POP     EDX
  FSTP    ST(0)
  FSTP    ST(0)
  FSTP    ST(0)
  RET
@@NullExit:
  XOR     EAX, EAX
  {$R+}
end;

end.
