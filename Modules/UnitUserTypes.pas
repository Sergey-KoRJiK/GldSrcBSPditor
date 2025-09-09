unit UnitUserTypes;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

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

type tVec4f = packed record
  case Byte of
    0: (Vec3f: tVec3f; pad: DWORD;);
    1: (x, y, z, w: Single;);
    2: (v: array[0..3] of Single;);
  end;
type PVec4f = ^tVec4f;
type AVec4f = array of tVec4f;


type tMat3f = array[0..8] of Single;
type PMat3f = ^tMat3f;

type tMat4f = array[0..15] of Single;
type PMat4f = ^tMat4f;

type tVec3d = packed record
    x, y, z: Double;
  end;
type PVec3d = ^tVec3d;
type AVec3d = array of tVec3d;

type tBBOX4f = packed record
    vMin, vMax: tVec4f;
  end;
type PBBOX4f = ^tBBOX4f;
type ABBOX4f = array of tBBOX4f;

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
    Start, Dir: tVec4f; // Dir must be normalized
  end; // 32 Bytes
type PRay = ^tRay;
type ARay = array of tRay;

// Plane equation dot(Normal, PointOnPlane) = Dist
type tPlane = record
    Normal: tVec3f;
    Dist: Single;
    AxisType: Integer;
  end; // 20 Bytes
type PPlane = ^tPlane;
type APlane = array of tPlane;

// Each row is 16-bytes full XMM-register
type tPlanePacket = packed record
    Nx: array[0..3] of Single;
    Ny: array[0..3] of Single;
    Nz: array[0..3] of Single;
    fD: array[0..3] of Single;
  end; // 64 Bytes
type PPlanePacket = ^tPlanePacket;
type APlanePacket = array of tPlanePacket;

type tPolygon3f = packed record
    // Plane section:
    Plane         : tPlane; // difference with original BSP plane, equal only normal
    Center        : tVec4f;
    // Vertex section:
    CountVertecies: Integer;
    CountTriangles: Integer;// = CountVertecies - 2
    Vertecies     : AVec4f; // size = CountVertecies
    //
    CountPackets  : Integer;
    CountPlanes   : Integer;  // Count of non-colinears planes
    SidePlanes    : APlanePacket; // size = Ceil(CountVertecies/4)
  end;
type PPolygon3f = ^tPolygon3f;
type APolygon3f = array of tPolygon3f;


type tTraceInfo = packed record
    Point: tVec4f;  // Intersection point
    t: Single;      // ray value of intersection point
    u, v: Single;   // barycentric coordinates of intersection point
    iTriangle: Integer;     // Triangle id of Face polygon
  end; // 32 Bytes
type PTraceInfo = ^tTraceInfo;
type ATraceInfo = array of tTraceInfo;


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


type PByteBool = ^ByteBool;

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
  inv16: Single = 0.0625;
  inv255: Single = 1.0/255.0;
  CR = #$0D; // = "/r"
  LF = #$0A; // = "/n" // Unix OS
  KEYBOARD_SHIFT = $10;
  //
  FLOAT32_INF_POSITIVE: Single = +1/0;
  FLOAT32_INF_NEGATIVE: Single = -1/0;
  VEC_ORT_X: tVec3f = (x: 1; y: 0; z: 0;);
  VEC_ORT_Y: tVec3f = (x: 0; y: 1; z: 0;);
  VEC_ORT_Z: tVec3f = (x: 0; y: 0; z: 1;);
  VEC_ZERO_2F: tVec2f = (x: 0; y: 0);
  VEC_ZERO_3F: tVec3f = (x: 0; y: 0; z: 0);
  VEC_ZERO_4F: tVec4f = (x: 0; y: 0; z: 0; w: 0);
  VEC_ONE: tVec3f = (x: 1; y: 1; z: 1);
  VEC_INF_P: tVec3f = (x: +1/0; y: +1/0; z: +1/0);
  VEC_INF_N: tVec3f = (x: -1/0; y: -1/0; z: -1/0);
  //
  VE_ZERO_2B: tVec2b = (x: 0; y: 0);
  VEC2B_ORT_X: tVec2b = (x: 1; y: 0);
  VEC2B_ORT_Y: tVec2b = (x: 0; y: 1);
  //
  VEC_ZERO_2S: tVec2s = (x: 0; y: 0);
  //
  BBOX_ZERO_4F: tBBOX4f = (vMin: (x: 0; y: 0; z: 0; w: 0); vMax: (x: 0; y: 0; z: 0; w: 0));
  TEX_BBOX_ZERO: tTexBBOXf = (vMin: (x: 0; y: 0); vMax: (x: 0; y: 0));
  //
  RGB888_BLACK: tRGB888 = (r:   0; g:   0; b:   0);
  RGB888_WHITE: tRGB888 = (r: 255; g: 255; b: 255);
  RGBA8888_BLACK: tRGBA8888 = (r:   0; g:   0; b:   0; a: 255);
  RGBA8888_WHITE: tRGBA8888 = (r: 255; g: 255; b: 255; a: 255);
  RGBA8888_BLACK_TRANSPARENT: tRGBA8888 = (r:   0; g:   0; b:   0; a:   0);
  //
  // packed lightmaps in BSP in linear space???
  GOLDSRC_LIGHTMAP_GAMMA_ADJAST = 2.2;
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
  // Plane axis type
  PLANE_X =      0;
  PLANE_Y =      1;
  PLANE_Z =      2;
  PLANE_ANY_X =  3;
  PLANE_ANY_Y =  4;
  PLANE_ANY_Z =  5;
  //
  PLANEBSP_NULL: tPlane = (
    Normal: (x: 0.0; y: 0.0; z: 0.0);
    Dist: 0.0;
    AxisType: PLANE_ANY_Z
  );

// Gamma = 1.0/GOLDSRC_LIGHTMAP_GAMMA_ADJAST
const GAMMA_LUT: array[0..255] of Byte = (
      0,  21,  28,  34,  39,  43,  46,  50,  53,  56,  59,  61,  64,  66,  68,  70,
     72,  74,  76,  78,  80,  82,  84,  85,  87,  89,  90,  92,  93,  95,  96,  98,
     99, 101, 102, 103, 105, 106, 107, 109, 110, 111, 112, 114, 115, 116, 117, 118,
    119, 120, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135,
    136, 137, 138, 139, 140, 141, 142, 143, 144, 144, 145, 146, 147, 148, 149, 150,
    151, 151, 152, 153, 154, 155, 156, 156, 157, 158, 159, 160, 160, 161, 162, 163,
    164, 164, 165, 166, 167, 167, 168, 169, 170, 170, 171, 172, 173, 173, 174, 175,
    175, 176, 177, 178, 178, 179, 180, 180, 181, 182, 182, 183, 184, 184, 185, 186,
    186, 187, 188, 188, 189, 190, 190, 191, 192, 192, 193, 194, 194, 195, 195, 196,
    197, 197, 198, 199, 199, 200, 200, 201, 202, 202, 203, 203, 204, 205, 205, 206,
    206, 207, 207, 208, 209, 209, 210, 210, 211, 212, 212, 213, 213, 214, 214, 215,
    215, 216, 217, 217, 218, 218, 219, 219, 220, 220, 221, 221, 222, 223, 223, 224,
    224, 225, 225, 226, 226, 227, 227, 228, 228, 229, 229, 230, 230, 231, 231, 232,
    232, 233, 233, 234, 234, 235, 235, 236, 236, 237, 237, 238, 238, 239, 239, 240,
    240, 241, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246, 246, 247, 247, 248,
    248, 249, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 254, 255, 255
  );


implementation


end.
