unit UnitUserTypes;

interface

uses
  Windows;

type tColor4fv = array[0..3] of Single;

type tVec2f = packed record
    x, y: Single;
  end;
type PVec2f = ^tVec2f;
type AVec2f = array of tVec2f;

type tVec3f = packed record
    x, y, z: Single;
  end;
type PVec3f = ^tVec3f;
type AVec3f = array of tVec3f;

type tMat3f = array[0..8] of Single;
type PMat3f = ^tMat3f;

type tMat4f = array[0..15] of Single;
type PMat4f = ^tMat4f;

type tVec3d = packed record
    x, y, z: Double;
  end;
type PVec3d = ^tVec3d;
type AVec3d = array of tVec3d;

type tBBOXf = packed record
    vMin, vMax: tVec3f;
  end;
type PBBOXf = ^tBBOXf;
type ABBOXf = array of tBBOXf;

type tTexBBOXf = packed record
    vMin, vMax: tVec2f;
  end;
type PTexBBOXf = ^tTexBBOXf;

type tVec2b = packed record
    x, y: Byte;
  end;
type PVec2b = ^tVec2b;
type AVec2b = array of tVec2b;

type tVec2s = packed record
    x, y: SmallInt;
  end;
type PVec2s = ^tVec2s;
type AVec2s = array of tVec2s;

type tVec3s = packed record
    x, y, z: SmallInt;
  end;
type PVec3s = ^tVec3s;
type AVec3s = array of tVec3s;

type tVec3i = packed record
    x, y, z: Integer;
  end;
type PVec3i = ^tVec3i;
type AVec3i = array of tVec3i;

type tVec4b = packed record
    x, y, z, w: Byte;
  end;
type PVec4b = ^tVec4b;
type AVec4b = ^tVec4b;

type tBBOXs = packed record
    nMin, nMax: tVec3s;
  end;
type PBBOXs = ^tBBOXs;
type ABBOXs = array of tBBOXs;

type tRay = packed record
    Start, Dir: tVec3f; // Dir must be normalized
  end;
type PRay = ^tRay;
type ARay = array of tRay;

type tPlane = packed record
    Normal: tVec3f;
    Dist: Single; //dot(Normal, PointOnPlane) = Dist
  end;
type PPlane = ^tPlane;
type APlane = array of tPlane;

type tPolygon3f = packed record
    // Plane section:
    Plane: tPlane;
    // Vertex section:
    CountVertecies: Integer;
    CountTriangles: Integer;  // = CountVertecies - 2
    Vertecies: AVec3f;        // size = CountVertecies
    // Edge section:
    // FanEdges[i] = Vertecies[i + 1] - Vertecies[0];
    FanEdges: AVec3f;     // size = CountVertecies - 1
  end;
type PPolygon3f = ^tPolygon3f;
type APolygon3f = array of tPolygon3f;


type tRGB888 = packed record
    r, g, b: Byte;
  end;
type PRGB888 = ^tRGB888;
type ARGB888 = array of tRGB888;

type tRGBA8888 = packed record
    r, g, b, a: Byte;
  end;
type PRGBA8888 = ^tRGBA8888;
type ARGBA8888 = array of tRGBA8888;


type tPixelIndexes = Array[0..32767] of Byte;
type PPixelIndexes = ^tPixelIndexes;

type pRGBArray = ^TRGBArray;
  TRGBArray = ARRAY[0..32767] OF TRGBTriple;

type pRGBAArray = ^TRGBAArray;
  TRGBAArray = ARRAY[0..32767] OF TRGBQuad;


type APointer = array of Pointer;
type AByte = array of Byte;
type AInt = array of Integer;
type ASingle = array of Single;
type ADWORD = array of DWORD;
type AWORD = array of WORD;
type ASmallInt = array of SmallInt;
type AByteBool = array of ByteBool;
type AString = array of String;

const
  VEC_ORT_X: tVec3f = (x: 1; y: 0; z: 0;);
  VEC_ORT_Y: tVec3f = (x: 0; y: 1; z: 0;);
  VEC_ORT_Z: tVec3f = (x: 0; y: 0; z: 1;);
  VEC_ZERO: tVec3f = (x: 0; y: 0; z: 0);
  VEC_ONE: tVec3f = (x: 1; y: 1; z: 1);
  VEC_INF_P: tVec3f = (x: +1/0; y: +1/0; z: +1/0);
  VEC_INF_N: tVec3f = (x: -1/0; y: -1/0; z: -1/0);
  //
  VEC2B_ZEROS: tVec2b = (x: 0; y: 0);
  VEC2B_ORT_X: tVec2b = (x: 1; y: 0);
  VEC2B_ORT_Y: tVec2b = (x: 0; y: 1);
  //
  BBOX_ZERO: tBBOXf = (vMin: (x: 0; y: 0; z: 0); vMax: (x: 0; y: 0; z: 0));
  TEX_BBOX_ZERO: tTexBBOXf = (vMin: (x: 0; y: 0); vMax: (x: 0; y: 0));
  //
  RGB888_BLACK: tRGB888 = (r:   0; g:   0; b:   0);
  RGB888_WHITE: tRGB888 = (r: 255; g: 255; b: 255);
  RGBA8888_BLACK: tRGBA8888 = (r:   0; g:   0; b:   0; a: 255);
  RGBA8888_WHITE: tRGBA8888 = (r: 255; g: 255; b: 255; a: 255);
  RGBA8888_BLACK_TRANSPARENT: tRGBA8888 = (r:   0; g:   0; b:   0; a:   0);
  //
  WhiteColor4f: tColor4fv = (1.0, 1.0, 1.0, 1.0);
  BlackColor4f: tColor4fv = (0.0, 0.0, 0.0, 1.0);
  RedColor4f: tColor4fv = (0.8, 0.1, 0.1, 0.5);
  PinkColor4f: tColor4fv = (1.0, 0.0, 1.0, 0.5);
  //
  ZerosMat3f: tMat3f = (
    0.0, 0.0, 0.0,
    0.0, 0.0, 0.0,
    0.0, 0.0, 0.0
  );
  ZerosMat4f: tMat4f = (
    0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0
  );
  IdentityMat3f: tMat3f = (
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0
  );
  IdentityMat4f: tMat4f = (
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
  );


implementation


end.
