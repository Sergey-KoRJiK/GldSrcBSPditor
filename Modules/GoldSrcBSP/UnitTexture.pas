unit UnitTexture;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus

interface

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  UnitUserTypes;

const
  MAX_TEXTURE_NAME = 16;
  MIPTEX_SIZE = 40;

type tTexName = array[0..MAX_TEXTURE_NAME-1] of Char;
type PTexName = ^tTexName; // Equivalent to null-terminated PAnsiChar

const
  TEXNAME_DUMMY: tTexName = (
    #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0
  );
  TEXNAME_SIGNATURE_TRANSPARENT = '{';

type tWad3Texture = record
    szName: tTexName;
    nWidth, nHeight: Integer;
    nOffsets: array[0..3] of Integer;
    // First 40 Bytes of Information finished here
    MipData: array[0..3] of PByte;
    PaletteColors: Word;
    Palette: PRGB888;
    Padding: Word;
    //
    TotalMipSize: Integer;
    MipSize: array[0..3] of Integer;
    MipWidth: array[0..3] of Integer;
    MipHeight: array[0..3] of Integer;
  end;
type PWad3Texture = ^tWad3Texture;
type AWad3Texture = array of tWad3Texture;

type tWad3Info = packed record
    nOffset: Integer;
    nSzCompress: Integer;
    nSzUnCompress: Integer;
    nType: Byte;
    nCompression: Byte;
    nPadding: Word;
    szName: tTexName;
  end; // 32 Bytes
type PWad3Info = ^tWad3Info;
type AWad3Info = array of tWad3Info;

const
  WAD3ID: array[0..3] of AnsiChar          = 'WAD3';
  WAD3TYPE_DECAL                    : Byte = $40;
  WAD3TYPE_CHACHED                  : Byte = $42;
  WAD3TYPE_TEXTURE                  : Byte = $43;
  WAD3TYPE_FONTS                    : Byte = $46;
  WAD3COMPRESS_NONE                 : Byte = $00;
  //
  TEXTURE_NULL: tWad3Texture = (
    szName: (#0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0, #0);
    nWidth: 0; nHeight: 0;
    nOffsets: (0, 0, 0, 0);
    MipData: (nil, nil, nil, nil);
    PaletteColors: 0;
    Palette: nil;
    Padding: 0;
    TotalMipSize: 0;
    MipSize: (0, 0, 0, 0);
    MipWidth: (0, 0, 0, 0);
    MipHeight: (0, 0, 0, 0);
  );

type tTextureLump = record
    nCountTextures: Integer;
    Wad3Textures: AWad3Texture; // length = nCountTextures
  end;
type PTextureLump = ^tTextureLump;
type ATextureLump = array of tTextureLump;
  

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
  TEXNAMEINDEX_AAATRIGGER = 0;


procedure AllocTexture(var Texture: tWad3Texture);
procedure AllocPalette(var Texture: tWad3Texture);
procedure FreeTextureAndPalette(var Texture: tWad3Texture);
procedure FreeTextureLump(var TextureLump: tTextureLump);

// only with MipMapLevel = 0 internal palette is updated
function UpdateTextureFromBitmap(const FileName: String; const lpTexture: PWad3Texture;
  const MipMapLevel: Integer): Boolean;
procedure SaveTextureToBitmap(const FileName: String; const lpTexture: PWad3Texture;
  const MipMapLevel: Integer);

procedure RebuildMipMaps(const lpTexture: PWad3Texture);  

function CompareTextureNames(const TexNameA, TexNameB: PTexName): Boolean;
function GetTexNameColorPairIndex(const TexName: PTexName): Integer;

function LoadTextureLumpFromWAD3(const FileName: String; const Lump: PTextureLump): Boolean;
function SaveTextureLumpToWAD3(const FileName: String; const Lump: PTextureLump): Integer;

function CopyPixelData(const Src, Dest: PWad3Texture): Boolean;


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


procedure AllocTexture(var Texture: tWad3Texture);
begin
  {$R-}
  Texture.MipWidth[0]:=Texture.nWidth;
  Texture.MipHeight[0]:=Texture.nHeight;
  Texture.MipSize[0]:=Texture.MipWidth[0]*Texture.MipHeight[0];
  Texture.TotalMipSize:=Texture.MipSize[0];

  Texture.MipWidth[1]:=Texture.nWidth shr 1;
  Texture.MipHeight[1]:=Texture.nHeight shr 1;
  Texture.MipSize[1]:=Texture.MipWidth[1]*Texture.MipHeight[1];
  Inc(Texture.TotalMipSize, Texture.MipSize[1]);

  Texture.MipWidth[2]:=Texture.nWidth shr 2;
  Texture.MipHeight[2]:=Texture.nHeight shr 2;
  Texture.MipSize[2]:=Texture.MipWidth[2]*Texture.MipHeight[2];
  Inc(Texture.TotalMipSize, Texture.MipSize[2]);

  Texture.MipWidth[3]:=Texture.nWidth shr 3;
  Texture.MipHeight[3]:=Texture.nHeight shr 3;
  Texture.MipSize[3]:=Texture.MipWidth[3]*Texture.MipHeight[3];
  Inc(Texture.TotalMipSize, Texture.MipSize[3]);

  Texture.MipData[0]:=SysGetMem(Texture.TotalMipSize);

  Texture.MipData[1]:=Texture.MipData[0];
  Inc(Texture.MipData[1], Texture.MipSize[0]);
  Texture.MipData[2]:=Texture.MipData[1];
  Inc(Texture.MipData[2], Texture.MipSize[1]);
  Texture.MipData[3]:=Texture.MipData[2];
  Inc(Texture.MipData[3], Texture.MipSize[2]);

  Texture.nOffsets[0]:=MIPTEX_SIZE;
  Texture.nOffsets[1]:=Texture.nOffsets[0] + Texture.MipSize[0];
  Texture.nOffsets[2]:=Texture.nOffsets[1] + Texture.MipSize[1];
  Texture.nOffsets[3]:=Texture.nOffsets[2] + Texture.MipSize[2];
  {$R+}
end;

procedure AllocPalette(var Texture: tWad3Texture);
begin
  {$R-}
  Texture.Palette:=SysGetMem(Texture.PaletteColors*SizeOf(tRGB888));
  {$R+}
end;

procedure FreeTextureAndPalette(var Texture: tWad3Texture);
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
  Texture.nOffsets[0]:=0;
  Texture.nOffsets[1]:=0;
  Texture.nOffsets[2]:=0;
  Texture.nOffsets[3]:=0;
  Texture.TotalMipSize:=0;
  Texture.MipSize[0]:=0;
  Texture.MipSize[1]:=0;
  Texture.MipSize[2]:=0;
  Texture.MipSize[3]:=0;
  Texture.MipWidth[0]:=0;
  Texture.MipWidth[1]:=0;
  Texture.MipWidth[2]:=0;
  Texture.MipWidth[3]:=0;
  Texture.MipHeight[0]:=0;
  Texture.MipHeight[1]:=0;
  Texture.MipHeight[2]:=0;
  Texture.MipHeight[3]:=0;

  if (Texture.Palette <> nil) then
    begin
      SysFreeMem(Texture.Palette);
    end;
  Texture.Palette:=nil;
  Texture.PaletteColors:=0;
  {$R+}
end;

procedure FreeTextureLump(var TextureLump: tTextureLump);
var
  i: Integer;
begin
  {$R-}
  TextureLump.nCountTextures:=0;
  for i:=0 to (Length(TextureLump.Wad3Textures) - 1) do
    begin
      FreeTextureAndPalette(TextureLump.Wad3Textures[i]);
    end;
  SetLength(TextureLump.Wad3Textures, 0);
  TextureLump.Wad3Textures:=nil;
  {$R+}
end;


function UpdateTextureFromBitmap(const FileName: String;
  const lpTexture: PWad3Texture; const MipMapLevel: Integer): Boolean;
var
  TexBmp: TBitmap;
  Palette: HPalette;
  PaletteSize, LogSize, i, j: Integer;
  LogPalette: PLogPalette;
  lpScanLineIndex, lpDest: PByte;
begin
  {$R-}
  if ((lpTexture = nil) or (lpTexture.MipData[0] = nil) or (FileName = '')
    or (MipMapLevel < 0) or (MipMapLevel > 4)) then
    begin
      Result:=False;
      Exit;
    end;

  TexBmp:=TBitmap.Create();
  try
    if FileExists(FileName) then
      TexBmp.LoadFromFile(FileName)
    else
      begin
        TexBmp.Destroy;
        Result:=False;
        Exit;
      end
  except
    TexBmp.Destroy;
    Result:=False;
    Exit;
  end;

  // Check if Bitmap size is equal texture size
  if ((TexBmp.Width <> lpTexture.MipWidth[MipMapLevel])
    or (TexBmp.Height <> lpTexture.Mipheight[MipMapLevel])) then
    begin
      TexBmp.Destroy;
      Result:=False;
      Exit;
    end;

  // Check if Palette exists and if it's 256-colored (8bpp)
  Palette:=TexBmp.Palette;
  if ((Palette = 0) or (TexBmp.PixelFormat <> pf8bit)) then
    begin
      TexBmp.Destroy;
      Result:=False;
      Exit;
    end;

  if (MipMapLevel = 0) then
    begin
      PaletteSize:=0;
      if (GetObject(Palette, SizeOf(PaletteSize), @PaletteSize) = 0) then
        begin
          TexBmp.Destroy;
          Result:=False;
          Exit;
        end;
      if (PaletteSize <> 256) then
        begin
          TexBmp.Destroy;
          Result:=False;
          Exit;
        end;

      LogSize:=SizeOf(TLogPalette) + (PaletteSize - 1)*SizeOf(TPaletteEntry);
      GetMem(LogPalette, LogSize);
      try
        LogPalette.palVersion:=$0300; // 256 colors
        LogPalette.palNumEntries:=PaletteSize;
        GetPaletteEntries(Palette, 0, PaletteSize, LogPalette.palPalEntry);
        for i:=0 to 255 do
          begin
            ARGB888(lpTexture.Palette)[i].r:=LogPalette.palPalEntry[i].peRed;
            ARGB888(lpTexture.Palette)[i].g:=LogPalette.palPalEntry[i].peGreen;
            ARGB888(lpTexture.Palette)[i].b:=LogPalette.palPalEntry[i].peBlue;
          end;
      finally
        FreeMem(LogPalette, LogSize);
        DeleteObject(Palette);
      end;
    end;

  lpDest:=lpTexture.MipData[MipMapLevel];
  for i:=0 to (TexBmp.Height - 1) do
    begin
      lpScanLineIndex:=TexBmp.ScanLine[i];
      for j:=0 to (TexBmp.Width - 1) do
        begin
          lpDest^:=lpScanLineIndex^;
          Inc(lpScanLineIndex);
          Inc(lpDest);
        end;
    end;

  TexBmp.Destroy();
  Result:=True;
  {$R+}
end;

procedure SaveTextureToBitmap(const FileName: String; const lpTexture: PWad3Texture;
  const MipMapLevel: Integer);
var
  TexBmp: TBitmap;
  Palette: HPalette;
  i, j: Integer;
  LogPalette: PLogPalette;
  lpScanLineIndex, lpSrc: PByte;
begin
  {$R-}
  if ((lpTexture = nil) or (lpTexture.MipData[0] = nil)
    or (MipMapLevel < 0) or (MipMapLevel > 4)) then Exit;

  TexBmp:=TBitmap.Create();
  TexBmp.Width:=lpTexture.MipWidth[MipMapLevel];
  TexBmp.Height:=lpTexture.MipHeight[MipMapLevel];
  TexBmp.PixelFormat:=pf8bit;

  LogPalette:=nil;
  try
    GetMem(LogPalette, sizeof(TLogPalette) + sizeof(TPaletteEntry)*256);
    LogPalette.palVersion:=3*256;
    LogPalette.palNumEntries:=256;
    for i:= 0 to 255 do
      begin
        LogPalette.palPalEntry[i].peRed:=ARGB888(lpTexture.Palette)[i].r;
        LogPalette.palPalEntry[i].peGreen:=ARGB888(lpTexture.Palette)[i].g;
        LogPalette.palPalEntry[i].peBlue:=ARGB888(lpTexture.Palette)[i].b;
      end;
    Palette:=CreatePalette(LogPalette^);
    if (Palette <> 0) then TexBmp.Palette:=Palette;
  finally
    FreeMem(LogPalette);
  end;

  lpSrc:=lpTexture.MipData[MipMapLevel];
  for i:=0 to (TexBmp.Height - 1) do
    begin
      lpScanLineIndex:=TexBmp.ScanLine[i];
      for j:=0 to (TexBmp.Width - 1) do
        begin
          lpScanLineIndex^:=lpSrc^;
          Inc(lpScanLineIndex);
          Inc(lpSrc);
        end;
    end;

  TexBmp.SaveToFile(FileName);
  TexBmp.Destroy();
  {$R+}
end;

procedure RebuildMipMaps(const lpTexture: PWad3Texture);
var
  i, j: Integer;
  Src, Dest: PByte;
begin
  {$R-}
  if ((lpTexture = nil) or (lpTexture.MipData[0] = nil)) then Exit;

  // Rebuild mipmap 1, scale = 1/2
  Src:=lpTexture.MipData[0];
  Dest:=lpTexture.MipData[1];
  for i:=0 to (lpTexture.MipHeight[1] - 1) do
    begin
      for j:=0 to (lpTexture.MipWidth[1] - 1) do
        begin
          Dest^:=Src^;
          Inc(Src, 2);
          Inc(Dest);
        end;
      Inc(Src, (2 - 1)*lpTexture.MipWidth[0]);
    end;

  // Rebuild mipmap 2, scale = 1/4
  Src:=lpTexture.MipData[0];
  Dest:=lpTexture.MipData[2];
  for i:=0 to (lpTexture.MipHeight[2] - 1) do
    begin
      for j:=0 to (lpTexture.MipWidth[2] - 1) do
        begin
          Dest^:=Src^;
          Inc(Src, 4);
          Inc(Dest);
        end;
      Inc(Src, (4 - 1)*lpTexture.MipWidth[0]);
    end;

  // Rebuild mipmap 3, scale = 1/8
  Src:=lpTexture.MipData[0];
  Dest:=lpTexture.MipData[3];
  for i:=0 to (lpTexture.MipHeight[3] - 1) do
    begin
      for j:=0 to (lpTexture.MipWidth[3] - 1) do
        begin
          Dest^:=Src^;
          Inc(Src, 8);
          Inc(Dest);
        end;
      Inc(Src, (8 - 1)*lpTexture.MipWidth[0]);
    end; //}
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


function LoadTextureLumpFromWAD3(const FileName: String; const Lump: PTextureLump): Boolean;
var
  i, k, fsz, OffsetInfo: Integer;
  Wad3File: File;
  Wad3Info: tWad3Info;
begin
  {$R-}
  if ((FileName = '') or (Lump = nil)) then
    begin
      Result:=False;
      Exit;
    end;

  AssignFile(Wad3File, FileName);
  Reset(Wad3File, 1);

  fsz:=FileSize(Wad3File);
  if (fsz < 12) then
    begin
      CloseFile(Wad3File);
      Result:=False;
      Exit;
    end;

  // Scan WAD3 Signature
  BlockRead(Wad3File, (@i)^, 4);
  if (i <> PInteger(@WAD3ID[0])^) then
    begin
      CloseFile(Wad3File);
      Result:=False;
      Exit;
    end;

  // Scan Count of Textures
  BlockRead(Wad3File, (@i)^, 4);
  if (i <= 0) then
    begin
      CloseFile(Wad3File);
      Result:=False;
      Exit;
    end;

  // Scan Offset to short textures information
  BlockRead(Wad3File, (@OffsetInfo)^, 4);
  if (fsz < (OffsetInfo + i*SizeOf(tWad3Info))) then
    begin
      CloseFile(Wad3File);
      Result:=False;
      Exit;
    end;

  FreeTextureLump(Lump^);
  Lump.nCountTextures:=i;
  SetLength(Lump.Wad3Textures, Lump.nCountTextures);
  k:=0;
  for i:=0 to (Lump.nCountTextures - 1) do
    begin
      Seek(Wad3File, OffsetInfo + i*SizeOf(tWad3Info));
      BlockRead(Wad3File, (@Wad3Info)^, SizeOf(tWad3Info));

      if ((Wad3Info.nOffset <= 0) or (Wad3Info.nType <> WAD3TYPE_TEXTURE)
        or (Wad3Info.nCompression <> WAD3COMPRESS_NONE)
        or (Wad3Info.nSzCompress <> Wad3Info.nSzUnCompress)
        or (fsz < (Wad3Info.nOffset + Wad3Info.nSzCompress))) then Continue;

      Seek(Wad3File, Wad3Info.nOffset);
      BlockRead(Wad3File, (@Lump.Wad3Textures[k])^, MIPTEX_SIZE);
      Lump.Wad3Textures[k].szName[15]:=#0; // Pre-save for null-terminated

      Lump.Wad3Textures[k].MipData[0]:=nil;
      if (Lump.Wad3Textures[k].nOffsets[0] = MIPTEX_SIZE) then
        begin
          AllocTexture(Lump.Wad3Textures[k]);
          // Read Pixel-Index Data
          BlockRead(Wad3File, (Lump.Wad3Textures[k].MipData[0])^, Lump.Wad3Textures[k].MipSize[0]);
          BlockRead(Wad3File, (Lump.Wad3Textures[k].MipData[1])^, Lump.Wad3Textures[k].MipSize[1]);
          BlockRead(Wad3File, (Lump.Wad3Textures[k].MipData[2])^, Lump.Wad3Textures[k].MipSize[2]);
          BlockRead(Wad3File, (Lump.Wad3Textures[k].MipData[3])^, Lump.Wad3Textures[k].MipSize[3]);
          // Read Palette
          BlockRead(Wad3File, (@Lump.Wad3Textures[k].PaletteColors)^, SizeOf(Word));
          AllocPalette(Lump.Wad3Textures[k]);
          BlockRead(Wad3File, (Lump.Wad3Textures[k].Palette)^,
            Lump.Wad3Textures[k].PaletteColors*SizeOf(tRGB888)
          );
          // Read Padding
          BlockRead(Wad3File, (@Lump.Wad3Textures[k].Padding)^, SizeOf(Word));

          Inc(k);
        end;
    end;
  Lump.nCountTextures:=k;
  SetLength(Lump.Wad3Textures, Lump.nCountTextures);

  CloseFile(Wad3File);
  Result:=Boolean(Lump.nCountTextures > 0);
  {$R+}
end;

function SaveTextureLumpToWAD3(const FileName: String; const Lump: PTextureLump): Integer;
var
  i, OffsetInfo, CountValid: Integer;
  Wad3File: File;
  Wad3Info: tWad3Info;
begin
  {$R-}
  if ((FileName = '') or (Lump = nil) or (Lump.nCountTextures <= 0)) then
    begin
      Result:=0;
      Exit;
    end;

  CountValid:=0;
  for i:=0 to (Lump.nCountTextures - 1) do
    begin
      if (Lump.Wad3Textures[i].MipData[0] <> nil) then Inc(CountValid);
    end;
  if (CountValid = 0) then
    begin
      Result:=0;
      Exit;
    end;

  AssignFile(Wad3File, FileName);
  Rewrite(Wad3File, 1);

  // Write "WAD3" 4-bytes signature, Number of textures and dummy offset
  BlockWrite(Wad3File, (@WAD3ID[0])^, 4);
  BlockWrite(Wad3File, (@CountValid)^, 4);
  BlockWrite(Wad3File, (@CountValid)^, 4);

  // Write Textures
  for i:=0 to (Lump.nCountTextures - 1) do
    begin
      if (Lump.Wad3Textures[i].MipData[0] = nil) then Continue;

      // Write Texture Info
      BlockWrite(Wad3File, (@Lump.Wad3Textures[i])^, MIPTEX_SIZE);
      // Write Pixel-Index four mipmaps
      BlockWrite(Wad3File, (Lump.Wad3Textures[i].MipData[0])^, Lump.Wad3Textures[i].MipSize[0]);
      BlockWrite(Wad3File, (Lump.Wad3Textures[i].MipData[1])^, Lump.Wad3Textures[i].MipSize[1]);
      BlockWrite(Wad3File, (Lump.Wad3Textures[i].MipData[2])^, Lump.Wad3Textures[i].MipSize[2]);
      BlockWrite(Wad3File, (Lump.Wad3Textures[i].MipData[3])^, Lump.Wad3Textures[i].MipSize[3]);
      // Write Palette
      BlockWrite(Wad3File, (@Lump.Wad3Textures[i].PaletteColors)^, SizeOf(Word));
      BlockWrite(Wad3File, (Lump.Wad3Textures[i].Palette)^,
        Lump.Wad3Textures[i].PaletteColors*SizeOf(tRGB888));
      // Write Padding
      BlockWrite(Wad3File, (@Lump.Wad3Textures[i].Padding)^, SizeOf(Word));
    end;
  OffsetInfo:=FileSize(Wad3File);
  Seek(Wad3File, 8);
  BlockWrite(Wad3File, (@OffsetInfo)^, 4);
  Seek(Wad3File, OffsetInfo);

  // Write Lump Infos
  Wad3Info.nOffset:=12;
  Wad3Info.nType:=WAD3TYPE_TEXTURE;
  Wad3Info.nCompression:=WAD3COMPRESS_NONE;
  Wad3Info.nPadding:=0;
  for i:=0 to (Lump.nCountTextures - 1) do
    begin
      if (Lump.Wad3Textures[i].MipData[0] = nil) then Continue;

      Wad3Info.szName:=Lump.Wad3Textures[i].szName;
      Wad3Info.nSzUnCompress:=Lump.Wad3Textures[i].TotalMipSize + MIPTEX_SIZE
        + 4 + Lump.Wad3Textures[i].PaletteColors*SizeOf(tRGB888);
      Wad3Info.nSzCompress:=Wad3Info.nSzUnCompress;
      //
      BlockWrite(Wad3File, (@Wad3Info)^, SizeOf(tWad3Info));
      Inc(Wad3Info.nOffset, Wad3Info.nSzCompress);
    end; 

  CloseFile(Wad3File);
  Result:=CountValid;
  {$R+}
end;

function CopyPixelData(const Src, Dest: PWad3Texture): Boolean;
var
  i: Integer;
  SrcIndex, DestIndex: PByte;
  SrcColor, DestColor: PRGB888;
begin
  {$R-}
  if ((Src = nil) or (Dest = nil) or (Src.PaletteColors <> Dest.PaletteColors)
    or (Src.nWidth <> Dest.nWidth) or (Src.nHeight <> Dest.nHeight)) then
    begin
      Result:=False;
      Exit;
    end;

  SrcIndex:=Src.MipData[0];
  DestIndex:=Dest.MipData[0];
  for i:=0 to (Src.TotalMipSize - 1) do
    begin
      DestIndex^:=SrcIndex^;
      Inc(SrcIndex);
      Inc(DestIndex);
    end;
    
  SrcColor:=Src.Palette;
  DestColor:=Dest.Palette;
  for i:=0 to (Src.PaletteColors - 1) do
    begin
      DestColor^:=SrcColor^;
      Inc(SrcColor);
      Inc(DestColor);
    end;
  Result:=True;
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
 
