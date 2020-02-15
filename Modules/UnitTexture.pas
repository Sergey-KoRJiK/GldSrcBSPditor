unit UnitTexture;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  Graphics,
  OpenGL,
  EXTOpengl32Glew32,
  UnitVec;

const
  MAX_TEXTURE_NAME = 16;

type tMipTex = record
    szName: array[0..MAX_TEXTURE_NAME-1] of Char;
    nWidth, nHeight: Integer;
    nOffsets: array[0..3] of Integer;
  end;
type AMipTex = array of tMipTex;

type tPalette = array[0..255] of tRGB888;
const PALETTE_SIZE = 256*3;

type tWad3Texture = record
    Name: String;
    Palette: tPalette;
    MipSize: array[0..3] of Integer;
    MipWidth: array[0..3] of Integer;
    MipHeight: array[0..3] of Integer;
    MipData: array[0..3] of AByte;
    RawPadding: Word;
  end;
type PWad3Texture = ^tWad3Texture;
type AWad3Texture = array of tWad3Texture;

type tTextureLump = record
    nCountTextures: DWORD;
    OffsetsToMipTex: AInt; // length = nCountTextures
    MipTexInfos: AMipTex; // length = nCountTextures
    Wad3Textures: AWad3Texture; // length = nCountTextures
  end;

const
  SizeOfMipTex = SizeOf(tMipTex);


function GetCorrectTextureName(const MipTex: tMipTex): String;
procedure AllocTexture(const MipTex: tMipTex; var Texture: tWad3Texture);


//*****************************************************************************
type tTexInfo = record
    vS: tVec3f;
    fSShift: Single;
    vT: tVec3f;
    fTShift: Single;
    iMipTex: DWORD;
    nFlags: DWORD; // usually = 0
  end;
type PTexInfo = ^tTexInfo;
type ATexInfo = array of tTexInfo;

const
  SizeOfTexInfo = SizeOf(tTexInfo);


function GetTexureCoordS(const Point: tVec3f; const TexInfo: tTexInfo): Single;
function GetTexureCoordT(const Point: tVec3f; const TexInfo: tTexInfo): Single;
procedure GetTexureCoordST(const Point: tVec3f; const TexInfo: tTexInfo; const TexCoord: tVec2f);


implementation


function GetCorrectTextureName(const MipTex: tMipTex): String;
var
  i, len: Integer;
  tmp: String;
begin
  {$R-}
  len:=0;
  while (len < MAX_TEXTURE_NAME) do
    begin
      if (Byte(MipTex.szName[len]) = 0) then break;
      Inc(len);
    end;
  SetLength(tmp, len);
  for i:=1 to len do
    begin
      tmp[i]:=MipTex.szName[i-1];
    end;
  Result:=tmp;
  {$R+}
end;

procedure AllocTexture(const MipTex: tMipTex; var Texture: tWad3Texture);
begin
  {$R-}
  Texture.MipWidth[0]:=MipTex.nWidth;
  Texture.MipHeight[0]:=MipTex.nHeight;
  Texture.MipSize[0]:=Texture.MipWidth[0]*Texture.MipHeight[0];

  Texture.MipWidth[1]:=MipTex.nWidth div 2;
  Texture.MipHeight[1]:=MipTex.nHeight div 2;
  Texture.MipSize[1]:=Texture.MipWidth[1]*Texture.MipHeight[1];

  Texture.MipWidth[2]:=MipTex.nWidth div 4;
  Texture.MipHeight[2]:=MipTex.nHeight div 4;
  Texture.MipSize[2]:=Texture.MipWidth[2]*Texture.MipHeight[2];

  Texture.MipWidth[3]:=MipTex.nWidth div 8;
  Texture.MipHeight[3]:=MipTex.nHeight div 8;
  Texture.MipSize[3]:=Texture.MipWidth[3]*Texture.MipHeight[3];

  SetLength(Texture.MipData[0], Texture.MipSize[0]);
  SetLength(Texture.MipData[1], Texture.MipSize[1]);
  SetLength(Texture.MipData[2], Texture.MipSize[2]);
  SetLength(Texture.MipData[3], Texture.MipSize[3]);
  {$R+}
end;


//*****************************************************************************
function GetTexureCoordS(const Point: tVec3f; const TexInfo: tTexInfo): Single;
asm
  {$R-}
  //Result:=Dot(@Point, @TexInfo.vS) + TexInfo.fSShift;
  fld Point.x
  fmul TexInfo.vS.x
  fld Point.y
  fmul TexInfo.vS.y
  faddp
  fld Point.z
  fmul TexInfo.vS.z
  faddp
  fadd TexInfo.fSShift
  {$R+}
end;

function GetTexureCoordT(const Point: tVec3f; const TexInfo: tTexInfo): Single;
asm
  {$R-}
  //Result:=Dot(@Point, @TexInfo.vT) + TexInfo.fTShift;
  fld Point.x
  fmul TexInfo.vT.x
  fld Point.y
  fmul TexInfo.vT.y
  faddp
  fld Point.z
  fmul TexInfo.vT.z
  faddp
  fadd TexInfo.fTShift
  {$R+}
end;

procedure GetTexureCoordST(const Point: tVec3f; const TexInfo: tTexInfo; const TexCoord: tVec2f);
asm
  {$R-}
  //TexCoord.x:=Dot(@Point, @TexInfo.vS) + TexInfo.fSShift;
  //TexCoord.y:=Dot(@Point, @TexInfo.vT) + TexInfo.fTShift;
  //
  fld Point.z
  fld Point.y
  fld Point.x
  // st0..2 = Point.xyz

  // Get TexCoord.x (S)
  fld TexInfo.vS.x
  // st0 = vS.x; st1..3 = Point.xyz
  fmul st, st(1)
  fld TexInfo.vS.y
  // st0 = vS.y; st1 = vS.x*Point.x; st2..4 = Point.xyz
  fmul st, st(3)
  faddp st(1), st
  // st0 = vS.xy*Point.xy; st1..3 = Point.xyz
  fld TexInfo.vS.z
  // st0 = vS.z; st1 = vS.xy*Point.xy; st2..4 = Point.xyz
  fmul st, st(4)
  faddp st(1), st
  // st0 = vS.xyz*Point.xyz; st1..3 = Point.xyz
  fadd TexInfo.fSShift
  fstp TexCoord.x
  // st0..2 = Point.xyz

  // Get TexCoord.y (T)
  fmul TexInfo.vT.x
  // st0 = vT.x*Point.x; st1..2 = Point.yz
  fxch st(1)
  fmul TexInfo.vT.y
  // st0 = vT.y*Point.y; st1 = vT.x*Point.x; st2 = Point.z
  fxch st(2)
  fmul TexInfo.vT.z
  // st0 = vT.z*Point.z; st1 = vT.x*Point.x; st2 = vT.y*Point.y;
  faddp
  faddp
  fadd TexInfo.fTShift
  fstp TexCoord.y
  {$R+}
end;

end.
 