unit UnitTexture;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  Windows,
  UnitUserTypes;

const
  MAX_TEXTURE_NAME = 16;

type tTexName = array[0..MAX_TEXTURE_NAME-1] of Char;
type PTexName = ^tTexName; // Equivalent to null-terminated PAnsiChar

const
  TEXNAME_DUMMY: tTexName = (
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  );
  TEXNAME_SIGNATURE_TRANSPARENT = '{';

type tMipTex = record
    szName: tTexName;
    nWidth, nHeight: Integer;
    nOffsets: array[0..3] of Integer;
  end;
type PMipTex = ^tMipTex;
type AMipTex = array of tMipTex;

const
  MIPTEX_NULL: tMipTex = (
    szName: (#0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0);
    nWIdth: 0; nHeight: 0;
    nOffsets: (-1, -1, -1, -1);
  );

type tPalette = array[0..255] of tRGB888;
const PALETTE_SIZE = 256*3;

type tWad3Texture = record
    Name: PTexName; // PAnsiChar
    Palette: tPalette;
    MipSize: array[0..3] of Integer;
    MipWidth: array[0..3] of Integer;
    MipHeight: array[0..3] of Integer;
    MipData: array[0..3] of PByte;
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
  

type tTexNameColorPair = record
    Name: tTexName;
    Color: tColor4fv;
  end; // 32 Bytes (16*1 + 4*4)
type PTexNameColorPair = ^tTexNameColorPair;
type ATexNameColorPair = array of tTexNameColorPair;


const
  TEXNAMECOLOR_COUNTPAIRS = 2;
  TEXNAMECOLOR_PAIRTABLE: array[0..TEXNAMECOLOR_COUNTPAIRS-1] of tTexNameColorPair = (
    (Name: ('A','A','A','T','R','I','G','G','E','R', #0, #0, #0, #0, #0, #0); Color: (1.0, 0.7, 0.4, 0.5)),
    (Name: ('S','K','Y', #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0); Color: (0.8, 0.9, 0.9, 1.0))
  );


procedure AllocTexture(const MipTex: tMipTex; var Texture: tWad3Texture);
procedure FreeTexture(var Texture: tWad3Texture);
function CompareTextureNames(const TexNameA, TexNameB: PTexName): Boolean;
function GetTexNameColorPairIndex(const TexName: PTexName): Integer;


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


function GetTexureCoordS(const Point: tVec3f; const TexInfo: tTexInfo): Single;
function GetTexureCoordT(const Point: tVec3f; const TexInfo: tTexInfo): Single;
procedure GetTexureCoordST(const Point: tVec3f; const TexInfo: tTexInfo; const TexCoord: tVec2f);


implementation


procedure AllocTexture(const MipTex: tMipTex; var Texture: tWad3Texture);
var
  TotalSize: Integer;
begin
  {$R-}
  Texture.MipWidth[0]:=MipTex.nWidth;
  Texture.MipHeight[0]:=MipTex.nHeight;
  Texture.MipSize[0]:=Texture.MipWidth[0]*Texture.MipHeight[0];
  TotalSize:=Texture.MipSize[0];

  Texture.MipWidth[1]:=MipTex.nWidth div 2;
  Texture.MipHeight[1]:=MipTex.nHeight div 2;
  Texture.MipSize[1]:=Texture.MipWidth[1]*Texture.MipHeight[1];
  Inc(TotalSize, Texture.MipSize[1]);

  Texture.MipWidth[2]:=MipTex.nWidth div 4;
  Texture.MipHeight[2]:=MipTex.nHeight div 4;
  Texture.MipSize[2]:=Texture.MipWidth[2]*Texture.MipHeight[2];
  Inc(TotalSize, Texture.MipSize[2]);

  Texture.MipWidth[3]:=MipTex.nWidth div 8;
  Texture.MipHeight[3]:=MipTex.nHeight div 8;
  Texture.MipSize[3]:=Texture.MipWidth[3]*Texture.MipHeight[3];
  Inc(TotalSize, Texture.MipSize[3]);

  Texture.MipData[0]:=SysGetMem(TotalSize);

  Texture.MipData[1]:=Texture.MipData[0];
  Inc(Texture.MipData[1], Texture.MipSize[0]);
  Texture.MipData[2]:=Texture.MipData[1];
  Inc(Texture.MipData[2], Texture.MipSize[1]);
  Texture.MipData[3]:=Texture.MipData[2];
  Inc(Texture.MipData[3], Texture.MipSize[2]);
  {$R+}
end;

procedure FreeTexture(var Texture: tWad3Texture);
begin
  {$R-}
  if (Texture.MipData[0] <> nil) then
    begin
      SysFreeMem(Texture.MipData[0]);
    end;
  Texture.MipData[0]:=nil;
  Texture.MipData[1]:=nil;
  Texture.MipData[2]:=nil;
  Texture.MipData[3]:=nil;
  {$R+}
end;

function CompareTextureNames(const TexNameA, TexNameB: PTexName): Boolean;
var
  i: Integer;
begin
  {$R-}
  i:=0;
  while ((TexNameA[i] <> #0) and (TexNameB[i] <> #0) and (i < MAX_TEXTURE_NAME)) do
    begin
      if (TexNameA[i] <> TexNameB[i]) then
        begin
          Result:=False;
          Exit;
        end;
      Inc(i);
    end;
  Result:=(TexNameA[i] = TexNameB[i]);
  {$R+}
end;

function GetTexNameColorPairIndex(const TexName: PTexName): Integer;
var
  i: Integer;
  tmp: tTexName;
begin
  {$R-}
  FillChar(tmp, 16, #0);
  i:=0;
  // Make TexName UpperCase
  while ((TexName[i] <> #0) and (i < 15)) do
    begin
      tmp[i]:=TexName[i];
      if ((tmp[i] >= 'a') and (tmp[i] <= 'z')) then
        begin
          Dec(tmp[i], 32);
        end;
      Inc(i);
    end;

  for i:=0 to (TEXNAMECOLOR_COUNTPAIRS - 1) do
    begin
      if (CompareTextureNames(@TEXNAMECOLOR_PAIRTABLE[i].Name, @tmp)) then
        begin
          Result:=i;
          Exit;
        end;
    end;
  Result:=-1;
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
 