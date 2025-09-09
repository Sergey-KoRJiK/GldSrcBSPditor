unit UnitMegatextureManager;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

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
  UnitVec;

const
  MEGATEXTURE_SIZE = 256;           // min 256 quad's 16x16 per one megatexture
  MEGATEXTURE_AREA = 256*256;       // 65536 pixels per one megatexture
  MEGATEXTURE_MEMSIZE = 256*256*1;  // 64K info per one megatexture
  MEGATEXTURE_MAX_COUNT = 1024;     // max count of megatextures
  MEGATEXTURE_MAX_REGIONS = 16384;  // max count of texture regions per one megatexture
  MEGATEXTURE_STEP = 1/MEGATEXTURE_SIZE; // pixel step size by s, t.
  //
  MEGATEXTURE_DUMMY_MEGAID = 0;
  MEGATEXTURE_DUMMY_REGIONID = 0;
  MEGATEXTURE_DUMMY_SIZE: tVec2s = (X: 2; Y: 2);
  MEGATEXTURE_DUMMY_DATA: array[0..3] of tRGB888 = (
    (r: 255; g: 255; b: 255),
    (r: 255; g: 255; b: 255),
    (r: 255; g: 255; b: 255),
    (r: 255; g: 255; b: 255)
  );

{ Single megatexture is struct with 256K size, desirable.
  Struct have pixel data "RGB888" of 2D 256x256 megatexture, with 192K size,
  and start at begining of struct.
  Other 64K of struct used for store additional data: region rectangle of
  each texture and count of regions.
  Each region is struct of 4 bytes: 2 bytes for region start position and
  2 bytes for end position.
  Two-bytes position and size is also struct of 2D vector of X and Y components,
  per 1 byte for each vector component (byte usef fully).
  Thus, we can store 16384 regions in 64K size - we assume that each texture have
  minimum size 2x2 (an example Quake/GoldSrc/Source Engine Lightmaps).
  All regions should not overlap each other, and for 2x2 textures that give
  full covering megatexture area with max 16384 regions.
  We assume that first region always start at position (0, 0): two byte zeros.
  Thus not need save this position explicitly, instead here we can store
  information about count of used regions, where max count = 16384 less then 64K.
}

type tSubRegion = packed record
    bMin, bMax: tVec2b;
  end;
type PSubRegion = ^tSubRegion;
type ASubRegion = array of tSubRegion;

const
  MEGATEXTURE_DUMMY_SUBREGION: tSubRegion = (
    bMin: (x: 0; y: 0); bMax: (x: 2; y: 2);
  );

type tMegatexture = packed record
    CountRegions: Word;
    FirstRegionMax: tVec2b;
    Regions: array[0..MEGATEXTURE_MAX_REGIONS-2] of tSubRegion;
  end;
type PMegatexture = ^tMegatexture;
type AMegatexture = array of tMegatexture;

const
  SUBREGION_NULL: tSubRegion = (bMin: (x: 0; y: 0); bMax: (x:   0; y:   0));
  SUBREGION_CLIP: tSubRegion = (bMin: (x: 0; y: 0); bMax: (x: 255; y: 255));

type
  eMegaMemError = (
    mmeNoError = 0,
    mmeOutOfRange = 1,
    mmeOutOfMemory = 2,
    mmeOutOfGPUMemory = 3
  );
  PMegaMemError = ^eMegaMemError;


type CMegatextureManager = class
  private
    iCountPages: Integer;     // Counter of pages
    iPageIndex: Integer;      // iCountPages - 1
    iTotalTextures: Integer;  // Counter of total inserted textures
    // List of 32-bit Pointers
    PageList: array[0..MEGATEXTURE_MAX_COUNT-1] of PMegatexture;
    CurrPixelBuff: array[0..MEGATEXTURE_MEMSIZE-1] of tRGB888;
    CurrPage: PMegatexture; // temporary page iterator
    CurrRegion: PSubRegion; // temporary regiomn iterator
    // List of OpenGL 2D Textures Id
    Page2DList: array[0..MEGATEXTURE_MAX_COUNT-1] of GLuint;
    CurrBindedMegatextureIndex: Integer;
    // List of reserved heights in current page
    ScanLine: array[0..MEGATEXTURE_SIZE-1] of SmallInt;
    //
    bLinearFilter: Boolean;
    bEnable: Boolean;
    vsMaxRegionSize: tVec2s;
    //
    procedure ClearReservedArea();
    function GetRegion(const MegatextureId, SubRegionId: Integer): tSubRegion;
    function GetRegionCount(const MegatextureId: Integer): Integer;
  public
    property CountMegatextures: Integer read iCountPages;
    property TotalInsertedTextures: Integer read iTotalTextures;
    property CurrentMegatextureIndex: Integer read iPageIndex;
    property IsMinAndMagLinearFiltering: Boolean read bLinearFilter;
    property IsEnableToRender: Boolean read bEnable;
    //
    property CountOfRegions[const MegatextureId: Integer]: Integer read GetRegionCount;
    property TextureRegion[const MegatextureId, SubRegionId: Integer]: tSubRegion read GetRegion;
    //
    property MaxRegionSize: tVec2s read vsMaxRegionSize;
    property MaxRegionSizeX: SmallInt read vsMaxRegionSize.x;
    property MaxRegionSizeY: SmallInt read vsMaxRegionSize.y;
    //
    constructor CreateManager();
    destructor DeleteManager();
    //
    procedure Clear();
    function AllocNewMegatexture(const ErrorInfo: PMegaMemError): Boolean;
    //
    function IsCanReserveTexture(const Size: tVec2s): Boolean;
    function ReserveTexture(const Size: tVec2s): Integer; // Return SubRegion id
    //
    function UpdateTextureFromArray(const MegatextureId, SubRegionId: Integer;
      const SrcBase, SrcAdd: PRGB888): Boolean;
    function UpdateCurrentBufferFromArray(const MegatextureId, SubRegionId: Integer;
      const SrcBase, SrcAdd: PRGB888): Boolean;
    function UpdateTextureFromCurrentBuffer(): Boolean;
    //
    procedure BindMegatexture2D(const MegatextureIndex: Integer);
    procedure UnbindMegatexture2D();
    //
    function UpdateTextureCoords(const MegatextureId, SubRegionId: Integer;
      const CoordSrc: PVec2f; const CoordDest: PVec2f;
      const CountTexCoords: Integer): Boolean;
    //
    procedure SetFiltrationMode(const isLinearFiltration: Boolean);
    procedure SetLightmapState(const isEnable: Boolean);
    procedure SetOverbrightMode(const ScaleRGB: Integer);
  end;


function GetMegaMemErrorInfo(const MegaMemError: eMegaMemError): String;


implementation


function GetMegaMemErrorInfo(const MegaMemError: eMegaMemError): String;
begin
  {$R-}
  case (MegaMemError) of
    mmeNoError:        Result:='No errors';
    mmeOutOfRange:     Result:='Error allocate new megatexture: reached max '
      + IntToStr(MEGATEXTURE_MAX_COUNT) + ' megatextures!';
    mmeOutOfMemory:    Result:='Error allocate new megatexture: Out of Memory!';
    mmeOutOfGPUMemory: Result:='Error allocate new megatexture: Out of GPU Memory!';
  else
    Result:='Unknow error';
  end;
  {$R+}
end;


constructor CMegatextureManager.CreateManager();
begin
  {$R-}
  Self.iCountPages:=0;
  Self.iPageIndex:=-1;
  Self.iTotalTextures:=0;
  Self.CurrBindedMegatextureIndex:=-1;
  Self.CurrPage:=nil;
  Self.CurrRegion:=nil;
  Self.bLinearFilter:=True;
  Self.bEnable:=True;
  Self.vsMaxRegionSize:=VEC_ZERO_2S;
  ZeroFillChar(@Self.PageList[0], MEGATEXTURE_MAX_COUNT*4);
  ZeroFillChar(@Self.Page2DList[0], MEGATEXTURE_MAX_COUNT*4);
  Self.ClearReservedArea;
  {$R+}
end;

destructor CMegatextureManager.DeleteManager();
begin
  {$R-}
  Self.Clear();
  {$R+}
end;


procedure CMegatextureManager.ClearReservedArea();
begin
  {$R-}
  ZeroFillChar(@Self.ScanLine[0], SizeOf(Self.ScanLine));
  {$R+}
end;

function CMegatextureManager.GetRegion(const MegatextureId, SubRegionId: Integer): tSubRegion;
begin
  {$R-}
  if ((MegatextureId < 0) or (MegatextureId >= Self.iCountPages)
    or (SubRegionId < 0)) then
    begin
      Result:=SUBREGION_NULL;
      Exit;
    end;

  if (SubRegionId >= Self.PageList[MegatextureId].CountRegions) then
    begin
      Result:=SUBREGION_NULL;
      Exit;
    end;

  if (SubRegionId = 0) then
    begin
      Result.bMin:=VE_ZERO_2B;
      Result.bMax:=PageList[MegatextureId].FirstRegionMax;
    end
  else
    begin
      Result:=Self.PageList[MegatextureId].Regions[SubRegionId - 1];
    end;
  {$R+}
end;

function CMegatextureManager.GetRegionCount(const MegatextureId: Integer): Integer;
begin
  {$R-}
  if ((MegatextureId < 0) or (MegatextureId >= Self.iCountPages)) then
    begin
      Result:=0;
    end
  else
    begin
      Result:=PageList[MegatextureId].CountRegions;
    end;
  {$R+}
end;


procedure CMegatextureManager.Clear();
var
  i: Integer;
begin
  {$R-}
  for i:=0 to (Self.iCountPages - 1) do
    begin
      if (Self.PageList[i] <> nil) then
        begin
          //VirtualFree(Self.PageList[i], 0, MEM_RELEASE);
          SysFreeMem(Self.PageList[i]);
          Self.PageList[i]:=nil;
          //
          if (Self.Page2DList[i] <> 0) then glDeleteTextures(1, @Self.Page2DList[i]);
          Self.Page2DList[i]:=0;
        end;
    end;
  //
  Self.ClearReservedArea;
  Self.iCountPages:=0;
  Self.iPageIndex:=-1;
  Self.iTotalTextures:=0;
  Self.CurrBindedMegatextureIndex:=-1;
  Self.CurrPage:=nil;
  Self.CurrRegion:=nil;
  Self.vsMaxRegionSize:=VEC_ZERO_2S;
  {$R+}
end;

function CMegatextureManager.AllocNewMegatexture(const ErrorInfo: PMegaMemError): Boolean;
var
  tmp: PMegatexture;
begin
  {$R-}
  if (Self.iCountPages >= MEGATEXTURE_MAX_COUNT) then
    begin
      if (ErrorInfo <> nil) then ErrorInfo^:=mmeOutOfRange;
      Result:=False;
      Exit;
    end;

  //tmp:=VirtualAlloc(nil, MEGATEXTURE_MEMSIZE, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
  tmp:=SysGetMem(MEGATEXTURE_MEMSIZE);
  if (tmp <> nil) then
    begin
      Inc(Self.iPageIndex);
      Inc(Self.iCountPages);
      //
      Self.CurrPage:=tmp;
      Self.CurrRegion:=@Self.CurrPage.Regions[0];
      Self.PageList[Self.iPageIndex]:=Self.CurrPage;
      Self.CurrPage.CountRegions:=0;
      Self.ClearReservedArea;

      // Create texture
          glGenTextures(1, @Self.Page2DList[Self.iPageIndex]);
          if (Self.Page2DList[Self.iPageIndex] = 0) then
            begin
              if (ErrorInfo <> nil) then ErrorInfo^:=mmeOutOfGPUMemory;
              Result:=False;
              Exit;
            end;

          glActiveTextureARB(GL_TEXTURE1);
          glEnable(GL_TEXTURE_2D);
          glBindTexture(GL_TEXTURE_2D, Self.Page2DList[Self.iPageIndex]);
          //  GL_CLAMP_TO_EDGE / GL_REPEAT
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
          // GL_LINEAR / GL_NEAREST
          if (Self.bLinearFilter) then
            begin
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            end
          else
            begin
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            end;
          //
          glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
          // Sample RGB, multiply by previous texunit result
          glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS);
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
          glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
          glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
          // Sample ALPHA, replace by previous texunit result
          glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PREVIOUS);
          glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
          glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
          glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA); //}
          {glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
          glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
          glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE); //}
          glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, 1.0);
          glTexEnvf(GL_TEXTURE_ENV, GL_ALPHA_SCALE, 1.0); //}
          //
          // Reserve GPU memory
          glTexImage2D(
            GL_TEXTURE_2D, 0, GL_RGB8,
            MEGATEXTURE_SIZE, MEGATEXTURE_SIZE,
            0,
            GL_RGB, GL_UNSIGNED_BYTE,
            nil
          );
          //
          glBindTexture(GL_TEXTURE_2D, 0); //}

      if (ErrorInfo <> nil) then ErrorInfo^:=mmeNoError;
      Result:=True;
    end
  else
    begin
      // Out of Memory
      if (ErrorInfo <> nil) then ErrorInfo^:=mmeOutOfMemory;
      Result:=False;
    end;
  {$R+}
end;


function CMegatextureManager.IsCanReserveTexture(const Size: tVec2s): Boolean;
var
  i, j: SmallInt;
  best, best2: SmallInt;
begin
  {$R-}
  if ((Size.x < 2) or (Size.y < 2) or (Size.x > MEGATEXTURE_SIZE)
    or (Size.y > MEGATEXTURE_SIZE)) then
    begin
      // We only work with sizes from 2x2 to 128x128
      Result:=False;
      Exit;
    end;

  if (Self.CurrPage.CountRegions = 0) then
    begin
      // In this case this is first region and it's always start at (0, 0)
      // and we reject input sizes out of range [2x2 .. 256x256].
      // Thus we can put him at (0, 0)
      Result:=True;
      Exit;
    end;

  best:=MEGATEXTURE_SIZE;
	for i:=0 to (MEGATEXTURE_SIZE - Size.x - 1) do
    begin
		  best2:=0;
		  for j:=0 to (Size.x - 1) do
		    begin
			    if (Self.ScanLine[i + j] >= best) then
            begin
              Break;
            end;
			    if (Self.ScanLine[i + j] > best2) then
            begin
              best2:=Self.ScanLine[i + j];
            end;
		    end;
		  if (j = Size.x) then
		    begin
          // this is a valid spot
          best:=best2;
		    end;
	  end;

	Result:=((best + Size.y) <= MEGATEXTURE_SIZE);
  {$R+}
end;

function CMegatextureManager.ReserveTexture(const Size: tVec2s): Integer;
var
  Pos: tVec2s;
  i, j: Integer;
  best, best2: Integer;
begin
  {$R-}
  if ((Size.x < 2) or (Size.y < 2) or (Size.x > MEGATEXTURE_SIZE)
    or (Size.y > MEGATEXTURE_SIZE)) then
    begin
      // We only work with sizes from 2x2 to 128x128
      Result:=-1;
      Exit;
    end;

  if (Self.CurrPage.CountRegions = 0) then
    begin
      // In this case this is first region and it's always start at (0, 0)
      // and we reject input sizes out of range [2x2 .. 256x256].
      // Thus we can put him at (0, 0), do it:
      Self.CurrPage.CountRegions:=1;
      Self.CurrPage.FirstRegionMax.x:=Byte(Size.x - 1);
      Self.CurrPage.FirstRegionMax.y:=Byte(Size.y - 1);
      for i:=0 to (Size.x - 1) do
        begin
		      Self.ScanLine[i]:=Size.y;
        end;
      Inc(Self.iTotalTextures);

      Result:=0;
      Exit;
    end;

  best:=MEGATEXTURE_SIZE;
	for i:=0 to (MEGATEXTURE_SIZE - Size.x - 1) do
    begin
		  best2:=0;
		  for j:=0 to (Size.x - 1) do
		    begin
			    if (Self.ScanLine[i + j] >= best) then
            begin
              Break;
            end;
			    if (Self.ScanLine[i + j] > best2) then
            begin
              best2:=Self.ScanLine[i + j];
            end;
		    end;
		  if (j = Size.x) then
		    begin
          // this is a valid spot
			    Pos.x:=i;
			    Pos.y:=best2;
          best:=best2;
		    end;
	  end;

  // Check if put region get out of megatexture size range.
	if ((best + Size.y) > MEGATEXTURE_SIZE) then
    begin
		  Result:=-1;
      Exit;
    end;

  // Update ScanLine
  Inc(best, Size.y);
	for i:=0 to (Size.x - 1) do
    begin
		  Self.ScanLine[Pos.x + i]:=best;
    end;

  Self.CurrRegion.bMin.x:=Pos.x;
  Self.CurrRegion.bMin.y:=Pos.y;
  Self.CurrRegion.bMax.x:=(Size.x - 1) + Pos.x;
  Self.CurrRegion.bMax.y:=(Size.y - 1) + Pos.y;
  if (Size.x > Self.vsMaxRegionSize.x) then Self.vsMaxRegionSize.x:=Size.x;
  if (Size.y > Self.vsMaxRegionSize.y) then Self.vsMaxRegionSize.y:=Size.y;
  Inc(Self.CurrRegion);
  Inc(Self.CurrPage.CountRegions);
  Inc(Self.iTotalTextures);

  Result:=Self.CurrPage.CountRegions - 1;
  {$R+}
end;


function CMegatextureManager.UpdateTextureFromArray(const MegatextureId, SubRegionId: Integer;
  const SrcBase, SrcAdd: PRGB888): Boolean;
var
  area: Integer;
  PtrDest: PRGB888;
  SubRegion: tSubRegion;
  RenderId: GLuint;
begin
  {$R-}
  if ((MegatextureId < 0) or (MegatextureId >= Self.iCountPages)
    or (SubRegionId < 0) or (SubRegionId >= MEGATEXTURE_MAX_REGIONS)) then
    begin
      Result:=False;
      Exit;
    end;

  RenderId:=Self.Page2DList[MegatextureId];
  if (RenderId = 0) then
    begin
      Result:=False;
      Exit;
    end;

  if (SubRegionId >= Self.PageList[MegatextureId].CountRegions) then
    begin
      Result:=False;
      Exit;
    end;

  if (SubRegionId = 0) then
    begin
      SubRegion.bMin:=VE_ZERO_2B;
      SubRegion.bMax:=Self.PageList[MegatextureId].FirstRegionMax;
    end
  else
    begin
      SubRegion:=Self.PageList[MegatextureId].Regions[SubRegionId - 1];
    end;

  area:=(SubRegion.bMax.x - SubRegion.bMin.x + 1)*(SubRegion.bMax.y - SubRegion.bMin.y + 1);
  PtrDest:=SysGetMem(area*SizeOf(tRGB888));
  if (PtrDest = nil) then
    begin
      Result:=False;
      Exit;
    end;
  // Dest.rgb = SrcBase.rgb + SrcAdd.rgb;
  // if SrcAdd = nil, then SrcBase copied to Dest
  SumTexturesRGB(SrcBase, SrcAdd, PtrDest, area);
  ApplyGammaToTextureRGB(PtrDest, PtrDest, area);

  glActiveTextureARB(GL_TEXTURE1);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, RenderId);
  glTexSubImage2D(
    GL_TEXTURE_2D, 0,
    SubRegion.bMin.x,
    SubRegion.bMin.y,
    (SubRegion.bMax.x - SubRegion.bMin.x + 1),
    (SubRegion.bMax.y - SubRegion.bMin.y + 1),
    GL_RGB, GL_UNSIGNED_BYTE,
    PtrDest
  );
  glBindTexture(GL_TEXTURE_2D, 0);
  SysFreeMem(PtrDest);
  
  Result:=True;
  {$R+}
end;

function CMegatextureManager.UpdateCurrentBufferFromArray(const MegatextureId, SubRegionId: Integer;
  const SrcBase, SrcAdd: PRGB888): Boolean;
var
  i, j: Integer;
  PtrSrcBase, PtrSrcAdd, PtrDest: PRGB888;
  SubRegion: tSubRegion;
begin
  {$R-}
  if ((MegatextureId < 0) or (MegatextureId >= Self.iCountPages)
    or (SubRegionId < 0) or (SubRegionId >= MEGATEXTURE_MAX_REGIONS)) then
    begin
      Result:=False;
      Exit;
    end;

  if (SubRegionId >= Self.PageList[MegatextureId].CountRegions) then
    begin
      Result:=False;
      Exit;
    end;

  if (SubRegionId = 0) then
    begin
      SubRegion.bMin:=VE_ZERO_2B;
      SubRegion.bMax:=Self.PageList[MegatextureId].FirstRegionMax;
    end
  else
    begin
      SubRegion:=Self.PageList[MegatextureId].Regions[SubRegionId - 1];
    end;

  PtrSrcBase:=SrcBase;
  PtrDest:=@Self.CurrPixelBuff[SubRegion.bMin.y*MEGATEXTURE_SIZE + SubRegion.bMin.x];
  j:=SubRegion.bMax.x - SubRegion.bMin.x + 1;
  if (SrcAdd <> nil) then
    begin
      // Dest.rgb = SrcBase.rgb + SrcAdd.rgb;
      PtrSrcAdd:=SrcAdd;
      for i:=0 to (SubRegion.bMax.y - SubRegion.bMin.y) do
        begin
          SumTexturesRGB(PtrSrcBase, PtrSrcAdd, PtrDest, j);
          Inc(PtrSrcBase, j);
          Inc(PtrSrcAdd, j);
          Inc(PtrDest, MEGATEXTURE_SIZE);
        end;
    end
  else
    begin
      // Dest.rgb = SrcBase.rgb;
      for i:=0 to (SubRegion.bMax.y - SubRegion.bMin.y) do
        begin
          CopyTexturesRGB(PtrSrcBase, PtrDest, j);
          Inc(PtrSrcBase, j);
          Inc(PtrDest, MEGATEXTURE_SIZE);
        end; 
    end;

  Result:=True;
  {$R+}
end;

function CMegatextureManager.UpdateTextureFromCurrentBuffer(): Boolean;
var
  RenderId: GLuint;
  PtrDest: PRGB888;
begin
  {$R-}
  if (Self.iPageIndex < 0) then
    begin
      Result:=False;
      Exit;
    end;

  RenderId:=Self.Page2DList[Self.iPageIndex];
  if (RenderId = 0) then
    begin
      Result:=False;
      Exit;
    end;

  PtrDest:=SysGetMem(MEGATEXTURE_AREA*SizeOf(tRGB888));
  if (PtrDest = nil) then
    begin
      Result:=False;
      Exit;
    end;
  ApplyGammaToTextureRGB(@Self.CurrPixelBuff[0], PtrDest, MEGATEXTURE_AREA);

  glActiveTextureARB(GL_TEXTURE1);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, RenderId);
  glTexSubImage2D(
    GL_TEXTURE_2D, 0,
    0, 0,
    MEGATEXTURE_SIZE, MEGATEXTURE_SIZE,
    GL_RGB, GL_UNSIGNED_BYTE,
    PtrDest
  );
  glBindTexture(GL_TEXTURE_2D, 0);
  SysFreeMem(PtrDest);

  Result:=True;
  {$R+}
end;

procedure CMegatextureManager.BindMegatexture2D(const MegatextureIndex: Integer);
begin
  {$R-}
  if ((MegatextureIndex >= 0) and (MegatextureIndex < Self.iCountPages) and (Self.bEnable)) then
    begin
      if (MegatextureIndex <> Self.CurrBindedMegatextureIndex) then
        begin
          Self.CurrBindedMegatextureIndex:=MegatextureIndex;
          glActiveTextureARB(GL_TEXTURE1);
          glBindTexture(GL_TEXTURE_2D, Self.Page2DList[Self.CurrBindedMegatextureIndex]);
        end;
    end
  else
    begin
      Self.CurrBindedMegatextureIndex:=-1;
      glActiveTextureARB(GL_TEXTURE1);
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
  {$R+}
end;

procedure CMegatextureManager.UnbindMegatexture2D();
begin
  {$R-}
  Self.CurrBindedMegatextureIndex:=-1;
  glActiveTextureARB(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D, 0);
  {$R+}
end;


function CMegatextureManager.UpdateTextureCoords(
  const MegatextureId, SubRegionId: Integer;
  const CoordSrc: PVec2f; const CoordDest: PVec2f;
  const CountTexCoords: Integer): Boolean;
var
  i: Integer;
  CurrSubRegion: tSubRegion;
begin
  {$R-}
  if ((MegatextureId < 0) or (MegatextureId >= Self.iCountPages)
    or (SubRegionId < 0) or (SubRegionId >= MEGATEXTURE_MAX_REGIONS)
    or (CountTexCoords <= 0)) then
    begin
      Result:=False;
      Exit;
    end;

  if (SubRegionId >= Self.PageList[MegatextureId].CountRegions) then
    begin
      Result:=False;
      Exit;
    end;

  if (SubRegionId = 0) then
    begin
      CurrSubRegion.bMin:=VE_ZERO_2B;
      CurrSubRegion.bMax:=Self.PageList[MegatextureId].FirstRegionMax;
    end
  else
    begin
      CurrSubRegion:=Self.PageList[MegatextureId].Regions[SubRegionId - 1];
    end;

  for i:=0 to (CountTexCoords - 1) do
    begin
      AVec2f(CoordDest)[i].x:=(AVec2f(CoordSrc)[i].x + CurrSubRegion.bMin.x)*MEGATEXTURE_STEP;
      AVec2f(CoordDest)[i].y:=(AVec2f(CoordSrc)[i].y + CurrSubRegion.bMin.y)*MEGATEXTURE_STEP;
    end; //}

  Result:=True;
  {$R+}
end;


procedure CMegatextureManager.SetFiltrationMode(const isLinearFiltration: Boolean);
var
  i: Integer;
begin
  {$R-}
  Self.bLinearFilter:=isLinearFiltration;
  glActiveTextureARB(GL_TEXTURE1);
  if (isLinearFiltration) then
    begin
      for i:=0 to (Self.iCountPages - 1) do
        begin
          glBindTexture(GL_TEXTURE_2D, Self.Page2DList[i]);
          // GL_LINEAR / GL_NEAREST
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        end;
    end
  else
    begin
      for i:=0 to (Self.iCountPages - 1) do
        begin
          glBindTexture(GL_TEXTURE_2D, Self.Page2DList[i]);
          // GL_LINEAR / GL_NEAREST
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        end;
    end;
  glBindTexture(GL_TEXTURE_2D, 0);
  {$R+}
end;

procedure CMegatextureManager.SetLightmapState(const isEnable: Boolean);
begin
  {$R-}
  Self.bEnable:=isEnable;
  if (isEnable = False) then Self.UnbindMegatexture2D();
  {$R+}
end;

procedure CMegatextureManager.SetOverbrightMode(const ScaleRGB: Integer);
var
  i: Integer;
begin
  {$R-}
  if ((ScaleRGB = 1) or (ScaleRGB = 2) or (ScaleRGB = 4)) then
    begin
      glActiveTextureARB(GL_TEXTURE1);
      for i:=0 to (Self.iCountPages - 1) do
        begin
          glBindTexture(GL_TEXTURE_2D, Self.Page2DList[i]);
          glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, ScaleRGB);
        end;
      glBindTexture(GL_TEXTURE_2D, 0);
    end;
  {$R+}
end;

end.
