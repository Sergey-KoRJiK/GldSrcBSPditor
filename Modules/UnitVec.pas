unit UnitVec;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses SysUtils, Windows, Classes, Graphics, OpenGL, EXTOpengl32Glew32;

const EPSILON: Single = 1E-6;
const inv16: Single = 0.0625;
const inv255: Single = 1.0/255.0;
const CRLF = #13#10; // = "/r + /n" // Windows OS
const LFCR = #10#13; // = "/n + /r" // Mac OS
const CR = #13; // = "/r"
const LF = #10; // = "/n" // Unix OS
const SpaceChar: Char = ' ';

type AGLuint = array of GLuint;
type tColor4fv = array[0..3] of GLfloat;

//*****************************************************************************
type tVec2f = record
    x, y: Single;
  end;
type PVec2f = ^tVec2f;
type AVec2f = array of tVec2f;

type tVec3f = record
    x, y, z: Single;
  end;
type PVec3f = ^tVec3f;
type AVec3f = array of tVec3f;

type tVec3d = record
    x, y, z: Double;
  end;
type PVec3d = ^tVec3d;
type AVec3d = array of tVec3d;

type tBBOXf = record
    vMin, vMax: tVec3f;
  end;
type PBBOXf = ^tBBOXf;
type ABBOXf = array of tBBOXf;

type tTexBBOXf = record
    vMin, vMax: tVec2f;
  end;
type PTexBBOXf = ^tTexBBOXf;

type tVec3s = record
    x, y, z: SmallInt;
  end;
type PVec3s = ^tVec3s;
type AVec3s = array of tVec3s;

type tBBOXs = record
    nMin, nMax: tVec3s;
  end;
type PBBOXs = ^tBBOXs;
type ABBOXs = array of tBBOXs;

type tRay = record
    Start, Dir: tVec3f;
  end;
type PRay = ^tRay;
type ARay = array of tRay;


type tRGB888 = record
    r, g, b: Byte;
  end;
type PRGB888 = ^tRGB888;
type ARGB888 = array of tRGB888;


type tPixelIndexes = Array[0..32767] of Byte;
type PPixelIndexes = ^tPixelIndexes;

type pRGBArray = ^TRGBArray;
  TRGBArray = ARRAY[0..32767] OF TRGBTriple;


type AByte = array of Byte;
type AInt = array of Integer;
type ADWORD = array of DWORD;
type AWORD = array of WORD;
type ASmallInt = array of SmallInt;
type AByteBool = array of ByteBool;

const
  SizeOfRGB888 = SizeOf(tRGB888);
  SizeOfVec3f = SizeOf(tVec3f);
  //
  VEC_ORT_X: tVec3f = (x: 1; y: 0; z: 0;);
  VEC_ORT_Y: tVec3f = (x: 0; y: 1; z: 0;);
  VEC_ORT_Z: tVec3f = (x: 0; y: 0; z: 1;);
  VEC_ZERO: tVec3f = (x: 0; y: 0; z: 0);
  VEC_ONE: tVec3f = (x: 1; y: 1; z: 1);
  VEC_INF_P: tVec3f = (x: +1/0; y: +1/0; z: +1/0);
  VEC_INF_N: tVec3f = (x: -1/0; y: -1/0; z: -1/0);
  RGB888_BLACK: tRGB888 = (r: 0; g: 0; b: 0);
  RGB888_WHITE: tRGB888 = (r: 255; g: 255; b: 255);
  //
  WhiteColor4f: tColor4fv = (1.0, 1.0, 1.0, 1.0);
  RedColor4f: tColor4fv = (0.8, 0.1, 0.1, 0.5);


procedure ZeroFillChar(const Buffer: PByte; const SizeBuffer: Integer);

procedure SignInvertVec3f(const lpSrc, lpDest: PVec3f); // Vec:= Vec*(-1)
function NormalizeVec3f(const lpVec: PVec3f): Boolean;
procedure Vec3fToVec3s(const lpVec3f: PVec3f; const lpVec3s: PVec3s);
procedure TranslateVertexArray(const Vertex, lpOffset: PVec3f; const Count: Integer);

function FloatToStrFixed(const Value: Single): String;
function VecToStr(const Vec3f: tVec3f): String; overload;
function VecToStr(const Vec3s: tVec3s): String; overload;
function VecToStr(const Vec3f: tVec3f; const Precission, Digits: Integer): String; overload;
function StrToVec(const Str: String; const Vec: PVec3f): Boolean;

procedure GetBBOX(const Vertex: AVec3f; const lpBBOXf: PBBOXf;
  const CountVertex: Integer);
procedure GetTexBBOX(const TexCoords: AVec2f; const lpTexBBOXf: PTexBBOXf;
  const CountCoords: Integer);

function TestPointInBBOX(const BBOXf: tBBOXf; const Point: tVec3f): Boolean;
function TestIntersectionTwoBBOX(const BBOX1f, BBOX2f: tBBOXf): Boolean;

procedure GetOriginByBBOX(const BBOXf: tBBOXf; const lpOrigin: PVec3f);
procedure TranslateBBOXf(const BBOXf: tBBOXf; const OffsetVec: tVec3f);

procedure GetSizeBBOXs(const BBOXs: tBBOXs; const lpSize: PVec3f);
procedure GetSizeBBOXf(const BBOXf: tBBOXf; const lpSize: PVec3f);

procedure RGB888toTRGBTriple(const lpRGBColor: PRGB888; var BGRColor: TRGBTriple);
procedure TRGBTripleToRGB888(const BGRColor: TRGBTriple; const lpRGBColor: PRGB888);
function LightMapToStr(const LightMap: tRGB888): String;

function BoolToStrYesNo(const boolValue: Boolean): String;

procedure CopyBytes(const lpSrc, lpDest: PByte; const CountCopyBytes: Integer);
procedure FillLightmaps(const FillColor: tRGB888; const lpDest: PRGB888; const CountDest: Integer);


implementation


procedure ZeroFillChar(const Buffer: PByte; const SizeBuffer: Integer);
asm
  // EAX -> Buffer Pointer
  // EDX -> Buffer Size in Bytes
  {$R-}
  cmp EDX, $00000000
  jle @@BadLen
  push ECX
  push EBX
  xor EBX, EBX
  xor ECX, ECX
  //
@@Looper:
    mov byte ptr [EAX + ECX], BL
    inc ECX
    cmp ECX, EDX
    jl @@Looper
  ////
  pop EBX
  pop ECX
  //
@@BadLen:
  {$R+}
end;


procedure Vec3fToVec3s(const lpVec3f: PVec3f; const lpVec3s: PVec3s);
asm
  {$R-}
  // round X component
  fld tVec3f[EAX].x
  fistp tVec3s[EDX].x
  // round Y component
  fld tVec3f[EAX].y
  fistp tVec3s[EDX].y
  // round Z component
  fld tVec3f[EAX].z
  fistp tVec3s[EDX].z
  {$R+}
end;

function NormalizeVec3f(const lpVec: PVec3f): Boolean;
var
  tmp: GLfloat;
begin
  {$R-}
  tmp:=Sqr(lpVec.x) + Sqr(lpVec.y) + Sqr(lpVec.z);
  // 0.0 = 0x00000000; PInteger(@tmp)^ is equal c++: int i = *(int*)&x;
  if (PInteger(@tmp)^ > 0) then
    begin
      tmp:=1.0/Sqrt(tmp);
      lpVec.x:=lpVec.x*tmp;
      lpVec.y:=lpVec.y*tmp;
      lpVec.z:=lpVec.z*tmp;
      Result:=True;
    end
  else
    begin
      lpVec^:=VEC_ZERO;
      Result:=False;
    end;
  {$R+}
end;

procedure SignInvertVec3f(const lpSrc, lpDest: PVec3f);
asm
  {$R-}
  // lpVec.x
  fld dword ptr [lpSrc + $00]
  fchs // sign invert
  fstp dword ptr [lpDest + $00]

  // lpVec.y
  fld dword ptr [lpSrc + $04]
  fchs // sign invert
  fstp dword ptr [lpDest + $04]
  
  // lpVec.z
  fld dword ptr [lpSrc + $08]
  fchs // sign invert
  fstp dword ptr [lpDest + $08]
  {$R+}
end;

procedure TranslateVertexArray(const Vertex, lpOffset: PVec3f; const Count: Integer);
asm
  // EAX -> Pointer on Vertex[0] (tVec3f)
  // EDX -> Pointer on tVec3f
  // ECX -> Pointer on Count of Vertex
  {$R-}
  cmp ECX, $00000000
  jle @@BadLen // if array length <= 0 - Exit
  //
  fld tVec3f[EDX].z
  fld tVec3f[EDX].y
  fld tVec3f[EDX].x
  // st0..2 = lpOffset.xyz;
  // Now no need EDX
  xor EDX, EDX // zeros, use it for local offset for Vertex array
@@Looper:
    // Correct X Component
    fld tVec3f[EAX + EDX].x
    fadd st(0), st(1)
    fstp tVec3f[EAX + EDX].x
    // Correct Y Component
    fld tVec3f[EAX + EDX].y
    fadd st(0), st(2)
    fstp tVec3f[EAX + EDX].y
    // Correct Z Component
    fld tVec3f[EAX + EDX].z
    fadd st(0), st(3)
    fstp tVec3f[EAX + EDX].z
    //
    add EDX, 12 // inc EDX by SizeOf(tVec3f)
    dec ECX
    //
    cmp ECX, $00000000
    jg @@Looper
  ////
  // Clear Stack:
  fstp st
  fstp st
  fstp st
  //
@@BadLen:
  {$R+}
end;


function FloatToStrFixed(const Value: Single): String;
begin
  {$R-}
  DecimalSeparator:='.';
  Result:=FloatToStrF(Value, ffGeneral, 6, 6);
  DecimalSeparator:=',';
  {$R+}
end;

function VecToStr(const Vec3f: tVec3f): String; overload;
var
  tmpStr: String;
begin
  {$R-}
  Result:='(';
  tmpStr:=FloatToStrFixed(Vec3f.x);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ','
  else Result:=Result + ' ' + tmpStr + ',';
  tmpStr:=FloatToStrFixed(Vec3f.y);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ','
  else Result:=Result + ' ' + tmpStr + ',';
  tmpStr:=FloatToStrFixed(Vec3f.z);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ')'
  else Result:=Result + ' ' + tmpStr + ')';
  {$R+}
end;

function VecToStr(const Vec3s: tVec3s): String; overload;
var
  tmpStr: String;
begin
  {$R-}
  Result:='(';
  tmpStr:=IntToStr(Vec3s.x);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ','
  else Result:=Result + ' ' + tmpStr + ',';
  tmpStr:=IntToStr(Vec3s.y);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ','
  else Result:=Result + ' ' + tmpStr + ',';
  tmpStr:=IntToStr(Vec3s.z);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ')'
  else Result:=Result + ' ' + tmpStr + ')';
  {$R+}
end;

function VecToStr(const Vec3f: tVec3f; const Precission, Digits: Integer): String; overload;
var
  tmpStr: String;
begin
  {$R-}
  DecimalSeparator:='.';
  //
  Result:='(';
  tmpStr:=FloatToStrF(Vec3f.x, ffGeneral, Precission, Digits);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ','
  else Result:=Result + ' ' + tmpStr + ',';
  tmpStr:=FloatToStrF(Vec3f.y, ffGeneral, Precission, Digits);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ','
  else Result:=Result + ' ' + tmpStr + ',';
  tmpStr:=FloatToStrF(Vec3f.z, ffGeneral, Precission, Digits);
  if (tmpStr[1] = '-') then Result:=Result + tmpStr + ')'
  else Result:=Result + ' ' + tmpStr + ')';
  //
  DecimalSeparator:=',';
  {$R+}
end;

function StrToVec(const Str: String; const Vec: PVec3f): Boolean;
var
  n: Integer;
  tmp: TStringList;
begin
  {$R-}
  StrToVec:=False;
  n:=Length(Str);
  if (n < 5) then Exit;

  tmp:=TStringList.Create;
  tmp.Delimiter:=' ';
  tmp.DelimitedText:=Str;
  if (tmp.Count <> 3) then
    begin
      tmp.Clear;
      tmp.Destroy;
      Exit;
    end;

  Vec.x:=StrToFloatDef(tmp.Strings[0], 1/0);
  Vec.y:=StrToFloatDef(tmp.Strings[1], 1/0);
  Vec.z:=StrToFloatDef(tmp.Strings[2], 1/0);

  tmp.Clear;
  tmp.Destroy;
  StrToVec:=True;
  {$R+}
end;

procedure GetBBOX(const Vertex: AVec3f; const lpBBOXf: PBBOXf;
  const CountVertex: Integer);
var
  i: Integer;
begin
  {$R-}
  lpBBOXf.vMin:=Vertex[0];
  lpBBOXf.vMax:=Vertex[0];
  if (CountVertex = 1) then Exit;
  for i:=1 to CountVertex-1 do
    begin
      if (Vertex[i].x < lpBBOXf.vMin.x) then lpBBOXf.vMin.x:=Vertex[i].x;
      if (Vertex[i].y < lpBBOXf.vMin.y) then lpBBOXf.vMin.y:=Vertex[i].y;
      if (Vertex[i].z < lpBBOXf.vMin.z) then lpBBOXf.vMin.z:=Vertex[i].z;

      if (Vertex[i].x > lpBBOXf.vMax.x) then lpBBOXf.vMax.x:=Vertex[i].x;
      if (Vertex[i].y > lpBBOXf.vMax.y) then lpBBOXf.vMax.y:=Vertex[i].y;
      if (Vertex[i].z > lpBBOXf.vMax.z) then lpBBOXf.vMax.z:=Vertex[i].z;
    end;
  {$R+}
end;


procedure GetTexBBOX(const TexCoords: AVec2f; const lpTexBBOXf: PTexBBOXf;
  const CountCoords: Integer);
var
  i: Integer;
begin
  {$R-}
  lpTexBBOXf.vMin:=TexCoords[0];
  lpTexBBOXf.vMax:=TexCoords[0];
  if (CountCoords = 1) then Exit;
  for i:=1 to (CountCoords - 1) do
    begin
      if (TexCoords[i].x < lpTexBBOXf.vMin.x) then lpTexBBOXf.vMin.x:=TexCoords[i].x;
      if (TexCoords[i].x > lpTexBBOXf.vMax.x) then lpTexBBOXf.vMax.x:=TexCoords[i].x;

      if (TexCoords[i].y < lpTexBBOXf.vMin.y) then lpTexBBOXf.vMin.y:=TexCoords[i].y;
      if (TexCoords[i].y > lpTexBBOXf.vMax.y) then lpTexBBOXf.vMax.y:=TexCoords[i].y;
    end;
  {$R+}
end;

function TestPointInBBOX(const BBOXf: tBBOXf; const Point: tVec3f): Boolean;
begin
  {$R-}
  if (Point.x <= BBOXf.vMin.x) then
    begin
      TestPointInBBOX:=False;
      Exit;
    end;
  if (Point.y <= BBOXf.vMin.y) then
    begin
      TestPointInBBOX:=False;
      Exit;
    end;
  if (Point.z <= BBOXf.vMin.z) then
    begin
      TestPointInBBOX:=False;
      Exit;
    end;

  if (Point.x >= BBOXf.vMax.x) then
    begin
      TestPointInBBOX:=False;
      Exit;
    end;
  if (Point.y >= BBOXf.vMax.y) then
    begin
      TestPointInBBOX:=False;
      Exit;
    end;
  if (Point.z >= BBOXf.vMax.z) then
    begin
      TestPointInBBOX:=False;
      Exit;
    end;

  TestPointInBBOX:=True;
  {$R+}
end;


function TestIntersectionTwoBBOX(const BBOX1f, BBOX2f: tBBOXf): Boolean;
begin
  {$R-}
  if ((BBOX1f.vMax.x < BBOX2f.vMin.x) or (BBOX1f.vMin.x > BBOX2f.vMax.x)) then
    begin
      TestIntersectionTwoBBOX:=False;
      Exit;
    end;
  if ((BBOX1f.vMax.y < BBOX2f.vMin.y) or (BBOX1f.vMin.y > BBOX2f.vMax.y)) then
    begin
      TestIntersectionTwoBBOX:=False;
      Exit;
    end;
  if ((BBOX1f.vMax.z < BBOX2f.vMin.z) or (BBOX1f.vMin.z > BBOX2f.vMax.z)) then
    begin
      TestIntersectionTwoBBOX:=False;
      Exit;
    end;
  TestIntersectionTwoBBOX:=True;
  {$R+}
end;


procedure TranslateBBOXf(const BBOXf: tBBOXf; const OffsetVec: tVec3f);
asm
  // EAX -> Pointer on tBBOXs
  // EAX -> Pointer on tVec3f
  {$R-}
  fld OffsetVec.z
  fld OffsetVec.y
  fld OffsetVec.x
  // st0..2 = Offset.xyz;

  // 1. Translate nMin Vector
  // 1.1. Correct X Component
  fld BBOXf.vMin.x
  // st0 = nMix.x; st1..3 = Offset.xyz;
  fadd st(0), st(1)
  fstp BBOXf.vMin.x
  // 1.2. Correct Y Component
  fld BBOXf.vMin.y
  fadd st(0), st(2)
  fstp BBOXf.vMin.y
  // 1.3. Correct Z Component
  fld BBOXf.vMin.z
  fadd st(0), st(3)
  fstp BBOXf.vMin.z
  // st0..2 = Offset.xyz;

  // 2. Translate nMax Vector
  // 2.1. Correct X Component
  fadd BBOXf.vMax.x
  fstp BBOXf.vMax.x
  // st0..1 = Offset.yz;
  // 2.2. Correct Y Component
  fadd BBOXf.vMax.y
  fstp BBOXf.vMax.y
  // st0 = Offset.z;
  // 2.3. Correct Z Component
  fadd BBOXf.vMax.z
  fstp BBOXf.vMax.z
  // BBOX Translate Complite
  {$R+}
end;

procedure GetOriginByBBOX(const BBOXf: tBBOXf; const lpOrigin: PVec3f);
begin
  {$R-}
  lpOrigin.x:=(BBOXf.vMin.x + BBOXf.vMax.x)*0.5;
  lpOrigin.y:=(BBOXf.vMin.y + BBOXf.vMax.y)*0.5;
  lpOrigin.z:=(BBOXf.vMin.z + BBOXf.vMax.z)*0.5;
  {$R+}
end;

procedure GetSizeBBOXs(const BBOXs: tBBOXs; const lpSize: PVec3f);
begin
  {$R-}
  lpSize.x:=(BBOXs.nMax.x - BBOXs.nMin.x);
  lpSize.y:=(BBOXs.nMax.y - BBOXs.nMin.y);
  lpSize.z:=(BBOXs.nMax.z - BBOXs.nMin.z);
  {$R+}
end;

procedure GetSizeBBOXf(const BBOXf: tBBOXf; const lpSize: PVec3f);
begin
  {$R-}
  lpSize.x:=(BBOXf.vMax.x - BBOXf.vMin.x);
  lpSize.y:=(BBOXf.vMax.y - BBOXf.vMin.y);
  lpSize.z:=(BBOXf.vMax.z - BBOXf.vMin.z);
  {$R+}
end;


procedure RGB888toTRGBTriple(const lpRGBColor: PRGB888; var BGRColor: TRGBTriple);
begin
  {$R-}
  BGRColor.rgbtRed:=lpRGBColor.r;
  BGRColor.rgbtGreen:=lpRGBColor.g;
  BGRColor.rgbtBlue:=lpRGBColor.b;
  {$R+}
end;

procedure TRGBTripleToRGB888(const BGRColor: TRGBTriple; const lpRGBColor: PRGB888);
begin
  {$R-}
  lpRGBColor.r:=BGRColor.rgbtRed;
  lpRGBColor.g:=BGRColor.rgbtGreen;
  lpRGBColor.b:=BGRColor.rgbtBlue;
  {$R+}
end;

function LightMapToStr(const LightMap: tRGB888): String;
begin
  {$R-}
  Result:='( ' + IntToStr(LightMap.r) + ', ' + IntToStr(LightMap.g) +
    ', ' + IntToStr(LightMap.b) + ')';
  {$R+}
end;

function BoolToStrYesNo(const boolValue: Boolean): String;
const
  StrYes: String = 'Yes';
  StrNo: String = 'No';
begin
  if (boolValue) then Result:=StrYes else Result:=StrNo;
end;


procedure CopyBytes(const lpSrc, lpDest: PByte; const CountCopyBytes: Integer);
var
  i: Integer;
begin
  {$R-}
  for i:=0 to (CountCopyBytes - 1) do
    begin
      AByte(lpDest)[i]:=AByte(lpSrc)[i];
    end;
  {$R+}
end;

procedure FillLightmaps(const FillColor: tRGB888; const lpDest: PRGB888; const CountDest: Integer);
var
  i: Integer;
begin
  {$R-}
  for i:=0 to (CountDest - 1) do
    begin
      ARGB888(lpDest)[i]:=FillColor;
    end;
  {$R+}
end;

end.
