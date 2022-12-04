unit UnitVec;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  Graphics,
  UnitUserTypes;

const
  inv16: Single = 0.0625;
  inv255: Single = 1.0/255.0;
  CR = #$0D; // = "/r"
  LF = #$0A; // = "/n" // Unix OS
  KEYBOARD_SHIFT = $10;


procedure ZeroFillChar(const Buffer: PByte; const SizeBuffer: Integer);
procedure ZeroFillDWORD(const Buffer: PByte; const SizeBuffer: Integer);
procedure FillChar255(const Buffer: PByte; const SizeBuffer: Integer);
procedure ZeroFill16K(const Buffer: Pointer);
procedure ZeroFill64K(const Buffer: Pointer);

function NormalizeVec3f(const lpVec: PVec3f): Boolean;
procedure Vec3fToVec3s(const lpVec3f: PVec3f; const lpVec3s: PVec3s);
procedure Vec3dToVec3i(const lpVec3d: PVec3d; const lpVec3i: PVec3i);
function DotVec3f(const VecA, VecB: tVec3f): Extended;
procedure CrossVec3f(const VecA, VecB, VecRes: PVec3f);
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
function TestPointInBBOXOffset(const BBOXf: tBBOXf;
  const Point, Offset: tVec3f): Boolean;
function TestIntersectionTwoBBOX(const BBOX1f, BBOX2f: tBBOXf): Boolean;
function TestIntersectionTwoBBOXOffset(const BBOX1f, BBOX2f: tBBOXf;
  const OffsetVec: tVec3f): Boolean;

procedure GetOriginByBBOX(const BBOXf: tBBOXf; const lpOrigin: PVec3f);
procedure TranslateBBOXf(const BBOXf: tBBOXf; const OffsetVec: tVec3f);

procedure GetSizeBBOXf(const BBOXf: tBBOXf; const lpSize: PVec3f);
procedure GetCenterBBOXf(const BBOXf: tBBOXf; const lpCenter: PVec3f);

procedure RGB888toTRGBTriple(const lpRGBColor: PRGB888; var BGRColor: TRGBTriple);
procedure TRGBTripleToRGB888(const BGRColor: TRGBTriple; const lpRGBColor: PRGB888);
procedure RGBA8888toTRGBQuad(const lpRGBAColor: PRGBA8888; var BGRAColor: TRGBQuad);
procedure TRGBQuadToRGBA8888(const BGRColor: TRGBQuad; const lpRGBAColor: PRGBA8888);
function LightMapToStr(const LightMap: tRGB888): String;

function BoolToStrYesNo(const boolValue: Boolean): String;

procedure CopyBytes(const lpSrc, lpDest: PByte; const CountCopyBytes: Integer);

// this function fill lpDest array by first or second byte of Value, depend of
// lpBoolMask array. 3 and 4 bytes (bits 16..31) of Value will be ignored.
procedure SetBytesByBoolMask(const lpBoolMask, lpDest: PByte;
  const CountCopyBytes: Integer; const Value: DWORD);

procedure FillLightmaps(const lpDest, FillColor: PRGB888; const CountDest: Integer);

function CompareString(const Str1, Str2: String; CompareSize: Integer): Boolean;

procedure FreePolygon(const Poly: PPolygon3f);
procedure UpdatePolyEdges(const Poly: PPolygon3f);
procedure GetPolyCenter(const Poly: PPolygon3f; const vCenter: PVec3f);

// Return triangle index of intersection exists, or -1 of not exists
// uvt.xyz = (u, v, t); u, v is normalized barycentric; t is ray value;
function GetRayPolygonIntersection(const Poly: PPolygon3f; const Ray: tRay;
  const uvt: PVec3f): Integer;


procedure CopyBitmapToRGB888(const Src: TBitmap; const Dest: PRGB888);
procedure CopyRGB888toBitmap(const Src: PRGB888; const Dest: TBitmap);


implementation


procedure ZeroFillChar(const Buffer: PByte; const SizeBuffer: Integer);
asm
  // EAX -> Buffer Pointer
  // EDX -> Buffer Size in Bytes
  {$R-}
  push EDI

  mov EDI, EAX { Point EDI to destination }
  xor EAX, EAX

  mov ECX, EDX
  sar ECX, 2
  js  @@exit

  REP stosd   { Fill dwords }

  mov ECX, EDX
  and ECX, 3
  REP stosb   { Fill remainder 0-3 bytes }

@@exit:
  pop EDI
  {$R+}
end;

procedure ZeroFillDWORD(const Buffer: PByte; const SizeBuffer: Integer);
asm
  // EAX -> Buffer Pointer
  // EDX -> Buffer Size in Bytes
  {$R-}
  push EDI

  mov EDI, EAX { Point EDI to destination }
  xor EAX, EAX

  mov ECX, EDX
  sar ECX, 2
  js  @@exit

  REP stosd   { Fill dwords }

@@exit:
  pop EDI
  {$R+}
end;

procedure FillChar255(const Buffer: PByte; const SizeBuffer: Integer);
asm
  // EAX -> Buffer Pointer
  // EDX -> Buffer Size in Bytes
  {$R-}
  push EDI

  mov EDI, EAX { Point EDI to destination }
  mov EAX, $FFFFFFFF

  mov ECX, EDX
  sar ECX, 2
  js  @@exit

  REP stosd   { Fill count DIV 4 dwords }

  mov ECX, EDX
  and ECX, 3
  REP stosb   { Fill count MOD 4 bytes }

@@exit:
  pop EDI
  {$R+}
end;

procedure ZeroFill16K(const Buffer: Pointer);
asm
  {$R-}
  // EAX = Buffer
  push EDI
  mov EDI, EAX
  xor EAX, EAX // Filler EAX = 0
  mov ECX, $00001000 // $1000 = 4096 = 16384 / 4;
  rep stosd
  // rep:
  // 1. MOV [EDX], EAX
  // 2. EDI = EDI + 4
  // 3. ECX = ECX - 1
  // 4. if (ECX <> 0) go to step 1.
  pop EDI
  {$R+}
end;

procedure ZeroFill64K(const Buffer: Pointer);
asm
  {$R-}
  // EAX = Buffer
  push EDI
  mov EDI, EAX
  xor EAX, EAX // Filler EAX = 0
  mov ECX, $00004000 // $4000 = 16384 = 65536 / 4;
  rep stosd
  // rep:
  // 1. MOV [EDX], EAX
  // 2. EDI = EDI + 4
  // 3. ECX = ECX - 1
  // 4. if (ECX <> 0) go to step 1.
  pop EDI
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

procedure Vec3dToVec3i(const lpVec3d: PVec3d; const lpVec3i: PVec3i);
asm
  {$R-}
  // round X component
  fld tVec3d[EAX].x
  fistp tVec3i[EDX].x
  // round Y component
  fld tVec3d[EAX].y
  fistp tVec3i[EDX].y
  // round Z component
  fld tVec3d[EAX].z
  fistp tVec3i[EDX].z
  {$R+}
end;

function NormalizeVec3f(const lpVec: PVec3f): Boolean;
var
  tmp: Single;
begin
  {$R-}
  tmp:=Sqr(lpVec.x) + Sqr(lpVec.y) + Sqr(lpVec.z);
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

function DotVec3f(const VecA, VecB: tVec3f): Extended;
asm
  {$R-}
  fld VecA.x
  fmul VecB.x
  fld VecA.y
  fmul VecB.y
  faddp
  fld VecA.z
  fmul VecB.z
  faddp
  {$R+}
end;

procedure CrossVec3f(const VecA, VecB, VecRes: PVec3f);
begin
  // VecRes = [VecA, VecB];
  {$R-}
  VecRes.x:=VecA.y*VecB.z - VecA.z*VecB.y;
  VecRes.z:=VecA.x*VecB.y - VecA.y*VecB.x;
  VecRes.y:=VecA.z*VecB.x - VecA.x*VecB.z;
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
  if (Point.x < BBOXf.vMin.x) then
    begin
      Result:=False;
      Exit;
    end;
  if (Point.y < BBOXf.vMin.y) then
    begin
      Result:=False;
      Exit;
    end;
  if (Point.z < BBOXf.vMin.z) then
    begin
      Result:=False;
      Exit;
    end;

  if (Point.x > BBOXf.vMax.x) then
    begin
      Result:=False;
      Exit;
    end;
  if (Point.y > BBOXf.vMax.y) then
    begin
      Result:=False;
      Exit;
    end;
  if (Point.z > BBOXf.vMax.z) then
    begin
      Result:=False;
      Exit;
    end;

  Result:=True;
  {$R+}
end;

function TestPointInBBOXOffset(const BBOXf: tBBOXf;
  const Point, Offset: tVec3f): Boolean;
begin
  {$R-}
  if ((Point.x + Offset.x) < BBOXf.vMin.x) then
    begin
      Result:=False;
      Exit;
    end;
  if ((Point.y + Offset.y) < BBOXf.vMin.y) then
    begin
      Result:=False;
      Exit;
    end;
  if ((Point.z + Offset.z)< BBOXf.vMin.z) then
    begin
      Result:=False;
      Exit;
    end;

  if ((Point.x + Offset.x) > BBOXf.vMax.x) then
    begin
      Result:=False;
      Exit;
    end;
  if ((Point.y + Offset.y) > BBOXf.vMax.y) then
    begin
      Result:=False;
      Exit;
    end;
  if ((Point.z + Offset.z) > BBOXf.vMax.z) then
    begin
      Result:=False;
      Exit;
    end;

  Result:=True;
  {$R+}
end;


function TestIntersectionTwoBBOX(const BBOX1f, BBOX2f: tBBOXf): Boolean;
begin
  {$R-}
  if ((BBOX1f.vMax.x < BBOX2f.vMin.x) or (BBOX1f.vMin.x > BBOX2f.vMax.x)) then
    begin
      Result:=False;
      Exit;
    end;
  if ((BBOX1f.vMax.y < BBOX2f.vMin.y) or (BBOX1f.vMin.y > BBOX2f.vMax.y)) then
    begin
      Result:=False;
      Exit;
    end;
  if ((BBOX1f.vMax.z < BBOX2f.vMin.z) or (BBOX1f.vMin.z > BBOX2f.vMax.z)) then
    begin
      Result:=False;
      Exit;
    end;
  Result:=True;
  {$R+}
end;

function TestIntersectionTwoBBOXOffset(const BBOX1f, BBOX2f: tBBOXf;
  const OffsetVec: tVec3f): Boolean;
begin
  {$R-}
  if ( ((BBOX1f.vMax.x + OffsetVec.x) < BBOX2f.vMin.x)
    or ((BBOX1f.vMin.x + OffsetVec.x) > BBOX2f.vMax.x)) then
    begin
      Result:=False;
      Exit;
    end;
  if ( ((BBOX1f.vMax.y + OffsetVec.y) < BBOX2f.vMin.y)
    or ((BBOX1f.vMin.y + OffsetVec.y) > BBOX2f.vMax.y)) then
    begin
      Result:=False;
      Exit;
    end;
  if ( ((BBOX1f.vMax.z + OffsetVec.z) < BBOX2f.vMin.z)
    or ((BBOX1f.vMin.z + OffsetVec.z) > BBOX2f.vMax.z)) then
    begin
      Result:=False;
      Exit;
    end;
  Result:=True;
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

procedure GetSizeBBOXf(const BBOXf: tBBOXf; const lpSize: PVec3f);
begin
  {$R-}
  lpSize.x:=(BBOXf.vMax.x - BBOXf.vMin.x);
  lpSize.y:=(BBOXf.vMax.y - BBOXf.vMin.y);
  lpSize.z:=(BBOXf.vMax.z - BBOXf.vMin.z);
  {$R+}
end;

procedure GetCenterBBOXf(const BBOXf: tBBOXf; const lpCenter: PVec3f);
begin
  {$R-}
  lpCenter.x:=(BBOXf.vMax.x + BBOXf.vMin.x)*0.5;
  lpCenter.y:=(BBOXf.vMax.y + BBOXf.vMin.y)*0.5;
  lpCenter.z:=(BBOXf.vMax.z + BBOXf.vMin.z)*0.5;
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

procedure RGBA8888toTRGBQuad(const lpRGBAColor: PRGBA8888; var BGRAColor: TRGBQuad);
begin
  {$R-}
  BGRAColor.rgbRed:=lpRGBAColor.r;
  BGRAColor.rgbGreen:=lpRGBAColor.g;
  BGRAColor.rgbBlue:=lpRGBAColor.b;
  BGRAColor.rgbReserved:=lpRGBAColor.a;
  {$R+}
end;

procedure TRGBQuadToRGBA8888(const BGRColor: TRGBQuad; const lpRGBAColor: PRGBA8888);
begin
  {$R-}
  lpRGBAColor.r:=BGRColor.rgbRed;
  lpRGBAColor.g:=BGRColor.rgbGreen;
  lpRGBAColor.b:=BGRColor.rgbBlue;
  lpRGBAColor.a:=BGRColor.rgbReserved;
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
asm
  {$R-}
  cmp ECX, 0    // ECX = CountCopyBytes
  jle @@exitcopy
  push ESI
  push EDI
  mov ESI, EAX  // lpSrc to ESI
  mov EDI, EDX  // lpDest to EDI
  mov EDX, ECX
  sar ECX, 2
  //
  rep movsd   { Copy count DIV 4 dwords }
  //
  mov ECX, EDX
  and ECX, 3
  REP movsb   { Copy count MOD 4 bytes }
  //
  pop EDI
  pop ESI
@@exitcopy:
  {$R+}
end;

procedure SetBytesByBoolMask(const lpBoolMask, lpDest: PByte;
  const CountCopyBytes: Integer; const Value: DWORD);
{var
  i: Integer; //}
asm
  {$R-}
  {for i:=0 to (CountCopyBytes - 1) do
    begin
      if (AByteBool(lpBoolMask)[i]) then
        begin
          AByte(lpDest)[i]:=Value;
        end
      else
        begin
          AByte(lpDest)[i]:=(Value shr 8);
        end;
    end; //}
  //
  // EAX = lpBoolMask; EDX = lpDest; ECX = CountCopyBytes;
  // Value in Stack as dword [EBP + 8]
  //
  cmp ECX, 0
  jle @@exitfill
  push ESI
  push EDI
  mov ESI, EAX
  mov EDI, EDX
  //
  xor EAX, EAX
  mov EDX, Value  // DL for True case, DH for False case
  //
@@fillloop:
  lodsb
  cmp al, 0
  je @@casefalse
  mov al, dl
  stosb
  loop @@fillloop
@@casefalse:
  mov al, dh
  stosb
  loopz @@fillloop
  //
  pop EDI
  pop ESI
@@exitfill:
  {$R+}
end;

procedure FillLightmaps(const lpDest, FillColor: PRGB888; const CountDest: Integer);
var
  i: Integer;
begin
  {$R-}
  for i:=0 to (CountDest - 1) do
    begin
      ARGB888(lpDest)[i]:=FillColor^;
    end;
  {$R+}
end;

function CompareString(const Str1, Str2: String; CompareSize: Integer): Boolean;
var
  i: Integer;
begin
  {$R-}
  if ((Length(Str1) < CompareSize) or (Length(Str2) < CompareSize)) then
    begin
      Result:=False;
      Exit;
    end;

  for i:=1 to CompareSize do
    begin
      if (Str1[i] <> Str2[i]) then
        begin
          Result:=False;
          Exit;
        end;
    end;

  Result:=True;
  {$R+}
end;


procedure FreePolygon(const Poly: PPolygon3f);
begin
  {$R-}
  Poly.Plane.Normal:=VEC_ZERO;
  Poly.Plane.Dist:=0.0;
  Poly.CountVertecies:=0;
  Poly.CountTriangles:=0;
  {$R+}
end;

procedure UpdatePolyEdges(const Poly: PPolygon3f);
var
  i: Integer;
begin
  {$R-}
  Poly.CountTriangles:=Poly.CountVertecies - 2;
  if (Poly.CountTriangles < 1) then Exit;

  SetLength(Poly.FanEdges, Poly.CountVertecies - 1);
  // Get fan edges
  for i:=1 to (Poly.CountVertecies - 1) do
    begin
      Poly.FanEdges[i - 1].x:=Poly.Vertecies[i].x - Poly.Vertecies[0].x;
      Poly.FanEdges[i - 1].y:=Poly.Vertecies[i].y - Poly.Vertecies[0].y;
      Poly.FanEdges[i - 1].z:=Poly.Vertecies[i].z - Poly.Vertecies[0].z;
    end;
  {$R+}
end;

procedure GetPolyCenter(const Poly: PPolygon3f; const vCenter: PVec3f);
var
  i: Integer;
begin
  {$R-}
  if (Poly.CountTriangles <= 0) then Exit;

  vCenter^:=VEC_ZERO;
  for i:=0 to (Poly.CountVertecies - 1) do
    begin
      vCenter.x:=vCenter.x + Poly.Vertecies[i].x;
      vCenter.y:=vCenter.y + Poly.Vertecies[i].y;
      vCenter.z:=vCenter.z + Poly.Vertecies[i].z;
    end;
  vCenter.x:=vCenter.x/Poly.CountVertecies;
  vCenter.y:=vCenter.y/Poly.CountVertecies;
  vCenter.z:=vCenter.z/Poly.CountVertecies;
  {$R+}
end;

function GetRayPolygonIntersection(const Poly: PPolygon3f; const Ray: tRay;
  const uvt: PVec3f): Integer; // uvt.xyz = (u, v, t);
var
  tmp: Single;
  tvec, pvec, qvec: tVec3f;
  i: Integer;
begin
  {$R-}
  // Based on: Moller, Tomas; Trumbore, Ben (1997). "Fast, Minimum Storage
  // Ray-Triangle Intersection". Journal of Graphics Tools. 2: 2128.

  // u, v - normalized barycentric coordinates on Poly triangle;
  // t - ray value;
  //
  // PointOnPolyTriangle = Origin + FanEdge0*u + FanEdge1*v;
  // where Origin = Poly.Vertecies[0];
  // FunEdge0 = FunEdges[i]; FunEdge1 = FunEdges[i + 1];
  // i = function return value "triangle index";
  // Triangle[i] -> vertecies {0, i, i + 1};
  //
  // PoitnOnRay = rayStart + rayDir*t;

  // Ray Dir and Poly Normal must be normalized
  tmp:=Ray.Dir.X*Poly.Plane.Normal.x + Ray.Dir.Y*Poly.Plane.Normal.y
    + Ray.Dir.Z*Poly.Plane.Normal.z;

  // Test that ray "see" Front Face of Polygon
  // Use fast integer compare technique for positives Float-32 IEEE-754;
  if (PInteger(@tmp)^ > 0) then
    begin
      Result:=-1;
      Exit;
    end;

  // Calculate distance from vert0 to ray origin
  tvec.x:=Ray.Start.x - Poly.Vertecies[0].x;
  tvec.y:=Ray.Start.y - Poly.Vertecies[0].y;
  tvec.z:=Ray.Start.z - Poly.Vertecies[0].z;

  for i:=0 to (Poly.CountTriangles - 1) do
    begin
      pvec.x:=Ray.Dir.y*Poly.FanEdges[i + 1].z - Ray.Dir.z*Poly.FanEdges[i + 1].y;
      pvec.y:=Ray.Dir.z*Poly.FanEdges[i + 1].x - Ray.Dir.x*Poly.FanEdges[i + 1].z;
      pvec.z:=Ray.Dir.x*Poly.FanEdges[i + 1].y - Ray.Dir.y*Poly.FanEdges[i + 1].x;

      tmp:=Poly.FanEdges[i].x*pvec.x + Poly.FanEdges[i].y*pvec.y
        + Poly.FanEdges[i].z*pvec.z;
      // tmp ~ triangle Area. If tmp is near zero, triangle is degenerate;
      // Use fast integer compare technique for positives Float-32 IEEE-754;
      if ((PInteger(@tmp)^ and $7FFFFFFF) = 0) then Continue;
      tmp:=1.0/tmp;

      // Calculate normalazed U baricentric coordinate and test bounds;
      uvt.x:=(tvec.x*pvec.x + tvec.y*pvec.y + tvec.z*pvec.z)*tmp;

      // Test U value on boundary [0..1];
      // Use fast integer compare technique for positives Float-32 IEEE-754;
      if (PInteger(@uvt.x)^ < 0) then Continue;
      if (PInteger(@uvt.x)^ > $3F800000) then Continue;

      qvec.x:=tvec.y*Poly.FanEdges[i].z - tvec.z*Poly.FanEdges[i].y;
      qvec.y:=tvec.z*Poly.FanEdges[i].x - tvec.x*Poly.FanEdges[i].z;
      qvec.z:=tvec.x*Poly.FanEdges[i].y - tvec.y*Poly.FanEdges[i].x;

      // Calculate normalazed V baricentric coordinate and test bounds
      uvt.y:=(Ray.Dir.x*qvec.x + Ray.Dir.y*qvec.y + Ray.Dir.z*qvec.z)*tmp;

      // Test V value on boundary [0..1];
      // Use fast integer compare technique for positives Float-32 IEEE-754;
      if (PInteger(@uvt.y)^ < 0) then Continue;
      if ((uvt.x + uvt.y) > 1.0) then Continue;

      // Calculate RayValue trace parameter and test zero boundary
      uvt.z:=(Poly.FanEdges[i + 1].x*qvec.x + Poly.FanEdges[i + 1].y*qvec.y
        + Poly.FanEdges[i + 1].z*qvec.z)*tmp;

      // Use fast integer compare technique for positives Float-32 IEEE-754;
      if (PInteger(@uvt.z)^ < 0 ) then Continue;

      Result:=i;
      Exit;
    end;

  Result:=-1;
  {$R+}
end;


procedure CopyRGB888toBitmap(const Src: PRGB888; const Dest: TBitmap);
var
  i, j: Integer;
  p: pRGBArray;
  PtrPage: PRGB888;
begin
  {$R-}
  Dest.PixelFormat:=pf24bit;
  PtrPage:=Src;
  for i:=0 to (Dest.Height - 1) do
    begin
      p:=Dest.ScanLine[i];
      for j:=0 to (Dest.Width - 1) do
        begin
          RGB888toTRGBTriple(PtrPage, p^[j]);
          Inc(PtrPage);
        end;
    end;
  {$R+}
end;

procedure CopyBitmapToRGB888(const Src: TBitmap; const Dest: PRGB888);
var
  i, j: Integer;
  p: pRGBArray;
  PtrPage: PRGB888;
begin
  {$R-}
  Src.PixelFormat:=pf24bit;
  PtrPage:=Dest;
  for i:=0 to (Src.Height - 1) do
    begin
      p:=Src.ScanLine[i];
      for j:=0 to (Src.Width - 1) do
        begin
          TRGBTripleToRGB888(p^[j], PtrPage);
          Inc(PtrPage);
        end;
    end;
  {$R+}
end;

end.
