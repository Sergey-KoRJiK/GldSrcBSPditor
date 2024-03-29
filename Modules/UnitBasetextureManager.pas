unit UnitBasetextureManager;

interface

uses
  SysUtils,
  Windows,
  Classes,
  Graphics,
  OpenGL,
  UnitOpenGLext,
  UnitOpenGLErrorManager,
  UnitUserTypes,
  UnitVec,
  UnitTexture;

const
  BASETEXTURE_LODS          = 4;    // by WAD3 specification.
  BASETEXTURE_SIZE_MIN      = 16;   // minimal texture size is 16x16
  BASETEXTURE_AREA_MIN      = BASETEXTURE_SIZE_MIN*BASETEXTURE_SIZE_MIN; // 256
  BASETEXTURE_SIZE_MAX      = 1024;  // maximum texture size is 1024*1024
  BASETEXTURE_AREA_MAX      = BASETEXTURE_SIZE_MAX*BASETEXTURE_SIZE_MAX;
  BASETEXTURE_SIZE_MULT     = 16;   // Width and Height must be multible by 16
  BASETEXTURE_PALETTE_SIZE  = 256;  // Each texture stored as 8-bit indexed.
  BASETEXTURE_COUNT_MAX     = 4096; // Include first dummy texture
  BASETEXTURE_DUMMY_ID      = 0;    // Id of white 1x1 dummy texture
  BASETEXTURE_PREVIEW_SIZE  = 128;  // Size of additional square RGBA8888 Thumbnails
  BASETEXTURE_PREVIEW_AREA  = BASETEXTURE_PREVIEW_SIZE*BASETEXTURE_PREVIEW_SIZE;
  //
  BASETEXTURE_LOD_FACTOR    = 1.328125; // increased texture weight by WAD3 LODs
  // 1.328125 = 1 + 1/4 + 1/6 + 1/64; An example texture with size 128x128
  // have 16384 pixels, LOD 1..3 increase total pixels to 21760.


type tBasetexture = record
    Name: PTexName;     // Texture Name
    glId: GLuint;       // OpenGL texture index
    Size: tVec2s;       // Width and Height
    Pixels: Pointer;    // Unpacked 32-bit textures with alpha
    // Pixels consists of two blocks: four RGBA8888 Thumbnails and four RGBA8888 MipMaps
  end; // 16 Bytes
type PBasetexture = ^tBasetexture;
type ABasetextyre = array of tBasetexture;

type CBasetextureManager = class
  private
    iCountTextures: Integer;
    iBinded: Integer;
    ListBT: array[0..BASETEXTURE_COUNT_MAX-1] of tBasetexture;
    isEnable: Boolean;
    //
    procedure GenerateThumbnailTexture(const BasetextureId, Index, Offset: Integer);
  public
    property CountBasetextures: Integer read iCountTextures;
    property IsEnableToRender: Boolean read isEnable;
    //
    constructor CreateManager();
    destructor DeleteManager();
    //
    procedure Clear();
    function AppendBasetexture(const Basetexture: tWad3Texture): Boolean;
    function UpdateBasetexture(const Basetexture: tWad3Texture;
      const BasetextureId: Integer): Boolean;
    //
    function GetBasetextureIdByName(const TexName: PTexName): Integer;
    function DrawThumbnailToBitmap(const ThumbnailBitmap: TBitmap;
      const BasetextureId, MipIndex: Integer): Boolean;
    //
    procedure BindBasetexture(const BasetextureId: Integer);
    procedure UnbindBasetexture();
    //
    procedure SetBasetextureState(const isEnable: Boolean);
  end;


implementation


constructor CBasetextureManager.CreateManager();
var
  PtrDest: PRGBA8888;
begin
  {$R-}
  Self.iCountTextures:=1;
  Self.iBinded:=-1;
  ZeroFillChar(@Self.ListBT[0], SizeOf(tBasetexture)*BASETEXTURE_COUNT_MAX);
  Self.isEnable:=True;

  // Initialize dummy white texture. Only this texture don't have Thumbnail
  Self.ListBT[0].Name:=@TEXNAME_DUMMY;
  Self.ListBT[0].Size.x:=BASETEXTURE_SIZE_MIN;
  Self.ListBT[0].Size.y:=BASETEXTURE_SIZE_MIN;
  Self.ListBT[0].Pixels:=SysGetMem(Round(BASETEXTURE_AREA_MIN*BASETEXTURE_LOD_FACTOR)*SizeOf(tRGBA8888));
  FillChar255(PByte(Self.ListBT[0].Pixels), Round(BASETEXTURE_AREA_MIN*BASETEXTURE_LOD_FACTOR)*SizeOf(tRGBA8888));

  glGenTextures(1, @Self.ListBT[0].glId);
  if (Self.ListBT[0].glId > 0) then
    begin
      glActiveTextureARB(GL_TEXTURE0);
      glEnable(GL_TEXTURE_2D);
      glBindTexture(GL_TEXTURE_2D, Self.ListBT[0].glId);
      // GL_CLAMP_TO_EDGE / GL_REPEAT
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
      // GL_LINEAR_MIPMAP_LINEAR is Bilinear Filtration, exist only for MIN FILTER
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      // GL_REPLACE / GL_MODULATE / GL_ADD / GL_BLEND / GL_DECAL
      //glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
      glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
      glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
      glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE); //}
      //
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL_LOD, 0);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL_LOD, 3);
      // store white quad texture to GPU memory
      PtrDest:= Self.ListBT[0].Pixels;
      glTexImage2D(
        GL_TEXTURE_2D, 0, GL_RGBA,
        Self.ListBT[0].Size.x,
        Self.ListBT[0].Size.y,
        0,
        GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
      );
      Inc(PtrDest, BASETEXTURE_AREA_MIN);
      glTexImage2D(
        GL_TEXTURE_2D, 1, GL_RGBA,
        Self.ListBT[0].Size.x shr 1,
        Self.ListBT[0].Size.y shr 1,
        0,
        GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
      );
      Inc(PtrDest, BASETEXTURE_AREA_MIN shr 2);
      glTexImage2D(
        GL_TEXTURE_2D, 2, GL_RGBA,
        Self.ListBT[0].Size.x shr 2,
        Self.ListBT[0].Size.y shr 2,
        0,
        GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
      );
      Inc(PtrDest, BASETEXTURE_AREA_MIN shr 4);
      glTexImage2D(
        GL_TEXTURE_2D, 3, GL_RGBA,
        Self.ListBT[0].Size.x shr 3,
        Self.ListBT[0].Size.y shr 3,
        0,
        GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
      );
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
  {$R+}
end;

destructor CBasetextureManager.DeleteManager();
var
  i: Integer;
begin
  {$R-}
  for i:=0 to (Self.iCountTextures - 1) do
    begin
      if (Self.ListBT[i].glId <> 0) then
        begin
          glDeleteTextures(1, @Self.ListBT[i].glId);
        end;
      if (Self.ListBT[i].Pixels <> nil) then
        begin
          SysFreeMem(Self.ListBT[i].Pixels);
        end;
    end;
  {$R+}
end;

procedure CBasetextureManager.GenerateThumbnailTexture(const BasetextureId, Index, Offset: Integer);
var
  SrcX, SrcY, DstX, DstY: Integer;
  SrcOffset: Integer;
  ScaleXY: Single;
  SrcSize: TPoint;
  SrcData, DstData: PRGBA8888;
begin
  {$R-}
  SrcSize.X:=Self.ListBT[BasetextureId].Size.x shr Index;
  SrcSize.Y:=Self.ListBT[BasetextureId].Size.y shr Index;
  //
  DstData:=Self.ListBT[BasetextureId].Pixels;
  SrcData:=DstData;
  Inc(SrcData, 4*BASETEXTURE_PREVIEW_AREA + Offset);
  Inc(DstData, Index*BASETEXTURE_PREVIEW_AREA);
  //
  if ( SrcSize.X > SrcSize.Y) then
    begin
      ScaleXY:=(SrcSize.X - 1)/(BASETEXTURE_PREVIEW_SIZE - 1);
    end
  else
    begin
      ScaleXY:=(SrcSize.Y - 1)/(BASETEXTURE_PREVIEW_SIZE - 1);
    end;

  for DstY:=0 to (BASETEXTURE_PREVIEW_SIZE - 1) do
    begin
      SrcY:=Round(DstY*ScaleXY);
      if (SrcY < SrcSize.Y) then
        begin
          SrcOffset:=SrcY*SrcSize.X;
          for DstX:=0 to (BASETEXTURE_PREVIEW_SIZE - 1) do
            begin
              SrcX:=Round(DstX*ScaleXY);
              if (SrcX < SrcSize.X) then
                begin
                  DstData^:=ARGBA8888(SrcData)[SrcOffset + SrcX];
                end
              else
                begin
                  DstData^:=RGBA8888_BLACK;
                end;
              Inc(DstData);
            end;
        end
      else
        begin
          for DstX:=0 to (BASETEXTURE_PREVIEW_SIZE - 1) do
            begin
              DstData^:=RGBA8888_BLACK;
              Inc(DstData);
            end;
        end;
    end;
  {$R+}
end;


procedure CBasetextureManager.Clear();
var
  i: Integer;
begin
  {$R-}
  for i:=1 to (Self.iCountTextures - 1) do
    begin
      if (Self.ListBT[i].glId <> 0) then
        begin
          glDeleteTextures(1, @Self.ListBT[i].glId);
        end;
      if (Self.ListBT[i].Pixels <> nil) then
        begin
          SysFreeMem(Self.ListBT[i].Pixels);
        end;
    end;
  ZeroFillChar(@Self.ListBT[1], SizeOf(tBasetexture)*(BASETEXTURE_COUNT_MAX - 1));
  {$R+}
end;

function CBasetextureManager.AppendBasetexture(const Basetexture: tWad3Texture): Boolean;
var
  i: Integer;
  PtrDest: PRGBA8888;
begin
  {$R-}
  if ((Self.iCountTextures >= BASETEXTURE_COUNT_MAX)
    or (Basetexture.MipData[0] = nil)) then
    begin
      Result:=False;
      Exit;
    end;

  Self.ListBT[Self.iCountTextures].Name:=@Basetexture.szName[0];
  Self.ListBT[Self.iCountTextures].Size.x:=Basetexture.nWidth;
  Self.ListBT[Self.iCountTextures].Size.y:=Basetexture.nHeight;

  glGenTextures(1, @Self.ListBT[Self.iCountTextures].glId);
  if (Self.ListBT[Self.iCountTextures].glId = 0) then
    begin
      Result:=False;
      Exit;
    end;

  // Allocate and unpack Pixel Data
  Self.ListBT[Self.iCountTextures].Pixels:=SysGetMem(
    (4*BASETEXTURE_PREVIEW_AREA + Basetexture.TotalMipSize)*SizeOf(tRGBA8888)
  );
  PtrDest:=Self.ListBT[Self.iCountTextures].Pixels;
  Inc(PtrDest, 4*BASETEXTURE_PREVIEW_AREA);
  if (Self.ListBT[Self.iCountTextures].Name[0] = TEXNAME_SIGNATURE_TRANSPARENT) then
    begin
      for i:=0 to (Basetexture.TotalMipSize - 1) do
        begin
          if (AByte(Basetexture.MipData[0])[i] = $FF) then
            begin
              PDWORD(PtrDest)^:=$00000000;
            end
          else
            begin
              PRGB888(PtrDest)^:=ARGB888(Basetexture.Palette)[AByte(Basetexture.MipData[0])[i]];
              PtrDest.a:=255;
            end;
          Inc(PtrDest);
        end;
    end
  else
    begin
      for i:=0 to (Basetexture.TotalMipSize - 1) do
        begin
          PRGB888(PtrDest)^:=ARGB888(Basetexture.Palette)[AByte(Basetexture.MipData[0])[i]];
          PtrDest.a:=255;
          Inc(PtrDest);
        end;
    end;

  // Generate Thumbnail image
  Self.GenerateThumbnailTexture(Self.iCountTextures, 0, 0);
  Self.GenerateThumbnailTexture(Self.iCountTextures, 1, Basetexture.nOffsets[1] - MIPTEX_SIZE);
  Self.GenerateThumbnailTexture(Self.iCountTextures, 2, Basetexture.nOffsets[2] - MIPTEX_SIZE);
  Self.GenerateThumbnailTexture(Self.iCountTextures, 3, Basetexture.nOffsets[3] - MIPTEX_SIZE);

  glActiveTextureARB(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, Self.ListBT[Self.iCountTextures].glId);
  //  GL_CLAMP_TO_EDGE / GL_REPEAT
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  //  GL_LINEAR_MIPMAP_LINEAR is Bilinear Filtration, exist only for MIN FILTER
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // GL_REPLACE / GL_MODULATE / GL_ADD / GL_BLEND / GL_DECAL
  //glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
  glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE); //}
  //
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL_LOD, 0);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL_LOD, 3);
  //
  PtrDest:=Self.ListBT[Self.iCountTextures].Pixels;
  Inc(PtrDest, 4*BASETEXTURE_PREVIEW_AREA);
  glTexImage2D(
    GL_TEXTURE_2D, 0, GL_RGBA,
    Self.ListBT[Self.iCountTextures].Size.X,
    Self.ListBT[Self.iCountTextures].Size.Y,
    0,
    GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
  );
  Inc(PtrDest, Basetexture.MipSize[0]);
  glTexImage2D(
    GL_TEXTURE_2D, 1, GL_RGBA,
    Self.ListBT[Self.iCountTextures].Size.X shr 1,
    Self.ListBT[Self.iCountTextures].Size.Y shr 1,
    0,
    GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
  );
  Inc(PtrDest, Basetexture.MipSize[1]);
  glTexImage2D(
    GL_TEXTURE_2D, 2, GL_RGBA,
    Self.ListBT[Self.iCountTextures].Size.X shr 2,
    Self.ListBT[Self.iCountTextures].Size.Y shr 2,
    0,
    GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
  );
  Inc(PtrDest, Basetexture.MipSize[2]);
  glTexImage2D(
    GL_TEXTURE_2D, 3, GL_RGBA,
    Self.ListBT[Self.iCountTextures].Size.X shr 3,
    Self.ListBT[Self.iCountTextures].Size.Y shr 3,
    0,
    GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
  ); //}

  glBindTexture(GL_TEXTURE_2D, 0);
  Inc(Self.iCountTextures);
  Result:=True;
  {$R+}
end;

function CBasetextureManager.UpdateBasetexture(const Basetexture: tWad3Texture;
  const BasetextureId: Integer): Boolean;
var
  i: Integer;
  PtrDest: PRGBA8888;
begin
  {$R-}
  if ((BasetextureId < 1) or (BasetextureId >= Self.iCountTextures)) then
    begin
      Result:=False;
      Exit;
    end;

  if ((Self.ListBT[BasetextureId].Name <> @Basetexture.szName)
    or (Self.ListBT[BasetextureId].Size.x <> Basetexture.MipWidth[0])
    or (Self.ListBT[BasetextureId].Size.y <> Basetexture.MipHeight[0])) then
    begin
      Result:=False;
      Exit;
    end;

  // Unpack Pixel Data
  PtrDest:=Self.ListBT[BasetextureId].Pixels;
  Inc(PtrDest, 4*BASETEXTURE_PREVIEW_AREA);
  if (Self.ListBT[BasetextureId].Name[0] = TEXNAME_SIGNATURE_TRANSPARENT) then
    begin
      for i:=0 to (Basetexture.TotalMipSize - 1) do
        begin
          if (AByte(Basetexture.MipData[0])[i] = $FF) then
            begin
              PtrDest^:=RGBA8888_BLACK_TRANSPARENT;
            end
          else
            begin
              PRGB888(PtrDest)^:=ARGB888(Basetexture.Palette)[AByte(Basetexture.MipData[0])[i]];
              PtrDest.a:=255;
            end;
          Inc(PtrDest);
        end;
    end
  else
    begin
      for i:=0 to (Basetexture.TotalMipSize - 1) do
        begin
          PRGB888(PtrDest)^:=ARGB888(Basetexture.Palette)[AByte(Basetexture.MipData[0])[i]];
          PtrDest.a:=255;
          Inc(PtrDest);
        end;
    end;

  // Generate Thumbnail image
  Self.GenerateThumbnailTexture(BasetextureId, 0, 0);
  Self.GenerateThumbnailTexture(BasetextureId, 1, Basetexture.nOffsets[1] - MIPTEX_SIZE);
  Self.GenerateThumbnailTexture(BasetextureId, 2, Basetexture.nOffsets[2] - MIPTEX_SIZE);
  Self.GenerateThumbnailTexture(BasetextureId, 3, Basetexture.nOffsets[3] - MIPTEX_SIZE);

  glActiveTextureARB(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, Self.ListBT[BasetextureId].glId);
  //
  PtrDest:=Self.ListBT[BasetextureId].Pixels;
  Inc(PtrDest, 4*BASETEXTURE_PREVIEW_AREA);
  glTexSubImage2D(
    GL_TEXTURE_2D, 0,
    0, 0,
    Self.ListBT[BasetextureId].Size.X,
    Self.ListBT[BasetextureId].Size.Y,
    GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
  );
  Inc(PtrDest, Basetexture.MipSize[0]);
  glTexSubImage2D(
    GL_TEXTURE_2D, 1,
    0, 0,
    Self.ListBT[BasetextureId].Size.X shr 1,
    Self.ListBT[BasetextureId].Size.Y shr 1,
    GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
  );
  Inc(PtrDest, Basetexture.MipSize[1]);
  glTexSubImage2D(
    GL_TEXTURE_2D, 2,
    0, 0,
    Self.ListBT[BasetextureId].Size.X shr 2,
    Self.ListBT[BasetextureId].Size.Y shr 2,
    GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
  );
  Inc(PtrDest, Basetexture.MipSize[2]);
  glTexSubImage2D(
    GL_TEXTURE_2D, 3,
    0, 0,
    Self.ListBT[BasetextureId].Size.X shr 3,
    Self.ListBT[BasetextureId].Size.Y shr 3,
    GL_RGBA, GL_UNSIGNED_BYTE, PtrDest
  ); //}
  
  glBindTexture(GL_TEXTURE_2D, 0);
  Result:=True;
  {$R+}
end;

function CBasetextureManager.GetBasetextureIdByName(const TexName: PTexName): Integer;
var
  i: Integer;
begin
  {$R-}
  for i:=0 to (Self.iCountTextures - 1) do
    begin
      //if (CompareTextureNames(TexName, Self.ListBT[i].Name)) then
      if (TexName = Self.ListBT[i].Name) then
        begin
          Result:=i;
          Exit;
        end; //}
    end;
  Result:=-1;
  {$R+}
end;

function CBasetextureManager.DrawThumbnailToBitmap(const ThumbnailBitmap: TBitmap;
  const BasetextureId, MipIndex: Integer): Boolean;
var
  i, j: Integer;
  PtrSrc: PRGBA8888;
  PtrDest: pRGBArray;
begin
  {$R-}
  if ((BasetextureId < 1) or (BasetextureId >= Self.iCountTextures)
    or (ThumbnailBitmap.Width <> BASETEXTURE_PREVIEW_SIZE)
    or (ThumbnailBitmap.Height <> BASETEXTURE_PREVIEW_SIZE)
    or (MipIndex < 0) or (MipIndex > 3)) then
    begin
      Result:=False;
      Exit;
    end;

  ThumbnailBitmap.PixelFormat:=pf24bit;

  PtrSrc:=Self.ListBT[BasetextureId].Pixels;
  Inc(PtrSrc, MipIndex*BASETEXTURE_PREVIEW_AREA);
  for i:=0 to (BASETEXTURE_PREVIEW_SIZE - 1) do
    begin
      PtrDest:=ThumbnailBitmap.ScanLine[i];
      for j:=0 to (BASETEXTURE_PREVIEW_SIZE - 1) do
        begin
          PtrDest[j].rgbtRed:=PtrSrc.r;
          PtrDest[j].rgbtGreen:=PtrSrc.g;
          PtrDest[j].rgbtBlue:=PtrSrc.b;
          //
          Inc(PtrSrc);
        end;
    end;

  Result:=True;
  {$R+}
end;


procedure CBasetextureManager.BindBasetexture(const BasetextureId: Integer);
begin
  {$R-}
  if ((BasetextureId >= 0) and (BasetextureId < Self.iCountTextures) and (Self.isEnable)) then
    begin
      if (BasetextureId <> Self.iBinded) then
        begin
          Self.iBinded:=BasetextureId;
          glActiveTextureARB(GL_TEXTURE0);
          glBindTexture(GL_TEXTURE_2D, Self.ListBT[BasetextureId].glId);
        end;
    end
  else
    begin
      Self.iBinded:=-1;
      glActiveTextureARB(GL_TEXTURE0);
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
  {$R+}
end;

procedure CBasetextureManager.UnbindBasetexture();
begin
  {$R-}
  Self.iBinded:=-1;
  glActiveTextureARB(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, 0);
  {$R+}
end;

procedure CBasetextureManager.SetBasetextureState(const isEnable: Boolean);
begin
  {$R-}
  Self.isEnable:=isEnable;
  if (isEnable = False) then Self.UnbindBasetexture();
  {$R+}
end;


end.
