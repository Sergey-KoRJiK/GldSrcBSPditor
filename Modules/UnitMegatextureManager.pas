unit UnitMegatextureManager;

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
  MEGATEXTURE_VOLUME_SIZE = 64;     // depth of 3D texture, minimum for OpenGL
  MEGATEXTURE_MAX_COUNT = 1024;     // max count of megatextures
  MEGATEXTURE_3D_MAX_COUNT = 16;    // MEGATEXTURE_MAX_COUNT / MEGATEXTURE_VOLUME_SIZE
  MEGATEXTURE_MAX_REGIONS = 16384;  // max count of texture regions per one megatexture
  MEGATEXTURE_STEP = 1/256;         // pixel step size by s, t.
  MEGATEXTURE_STEP_3D = 1/64;       // pixel step size by r.
  MEGATEXTURE_STEP_3D_HALF = 1/128; // r-coord offset for correct pixel sampling
  //
  MEGATEXTURE_DUMMY_MEGAID = 0;
  MEGATEXTURE_DUMMY_REGIONID = 0;
  MEGATEXTURE_DUMMY_SIZE: TPoint = (X: 2; Y: 2);
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
    iCount3D: Integer;        // iCountPages / MEGATEXTURE_VOLUME_SIZE
    iPageIndex: Integer;      // iCountPages - 1
    iTotalTextures: Integer;  // Counter of total inserted textures
    // List of 32-bit Pointers
    PageList: array[0..MEGATEXTURE_MAX_COUNT-1] of PMegatexture;
    CurrPixelBuff: array[0..MEGATEXTURE_MEMSIZE-1] of tRGB888;
    CurrPage: PMegatexture; // temporary page iterator
    CurrRegion: PSubRegion; // temporary regiomn iterator
    // List of OpenGL 3D Textures Id
    Page3DList: array[0..MEGATEXTURE_3D_MAX_COUNT-1] of GLuint;
    CurrBindedMegatextureIndex: Integer;
    // List of reserved heights in current page
    ScanLine: array[0..MEGATEXTURE_SIZE-1] of SmallInt;
    //
    bLinearFilter: Boolean;
    bEnable: Boolean;
    //
    procedure ClearReservedArea();
    function GetRegion(const MegatextureId, SubRegionId: Integer): tSubRegion;
    function GetRegionCount(const MegatextureId: Integer): Integer;
  public
    property CountMegatextures: Integer read iCountPages;
    property CountMegatextures3D: Integer read iCount3D;
    property TotalInsertedTextures: Integer read iTotalTextures;
    property CurrentMegatextureIndex: Integer read iPageIndex;
    property IsMinAndMagLinearFiltering: Boolean read bLinearFilter;
    property IsEnableToRender: Boolean read bEnable;
    //
    property CountOfRegions[const MegatextureId: Integer]: Integer read GetRegionCount;
    property TextureRegion[const MegatextureId, SubRegionId: Integer]: tSubRegion read GetRegion;
    //
    constructor CreateManager();
    destructor DeleteManager();
    //
    procedure Clear();
    function AllocNewMegatexture(const ErrorInfo: PMegaMemError): Boolean;
    //
    function IsCanReserveTexture(const Size: TPoint): Boolean;
    function ReserveTexture(const Size: TPoint): Integer; // Return SubRegion id
    //
    function UpdateTextureFromArray(const MegatextureId, SubRegionId: Integer;
      const SrcBase, SrcAdd: PRGB888): Boolean;
    function UpdateCurrentBufferFromArray(const MegatextureId, SubRegionId: Integer;
      const SrcBase, SrcAdd: PRGB888): Boolean;
    function UpdateTextureFromCurrentBuffer(): Boolean;
    //
    procedure BindMegatexture3D(const MegatextureIndex: Integer);
    procedure UnbindMegatexture3D();
    //
    function UpdateTextureCoords(const MegatextureId, SubRegionId: Integer;
      const CoordSrc: PVec2f; const CoordDest: PVec3f;
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
  Self.iCount3D:=0;
  Self.iPageIndex:=-1;
  Self.iTotalTextures:=0;
  Self.CurrBindedMegatextureIndex:=-1;
  Self.CurrPage:=nil;
  Self.CurrRegion:=nil;
  Self.bLinearFilter:=True;
  Self.bEnable:=True;
  ZeroFillChar(@Self.PageList[0], MEGATEXTURE_MAX_COUNT*4);
  ZeroFillChar(@Self.Page3DList[0], MEGATEXTURE_3D_MAX_COUNT*4);
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
  ZeroFillDWORD(@Self.ScanLine[0], MEGATEXTURE_SIZE shr 1);
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
      Result.bMin:=VEC2B_ZEROS;
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
        end;
    end;
  for i:=0 to (Self.iCount3D - 1) do
    begin
      if (Self.Page3DList[i] <> 0) then glDeleteTextures(1, @Self.Page3DList[i]);
      Self.Page3DList[i]:=0;
    end;
  //
  Self.ClearReservedArea;
  Self.iCountPages:=0;
  Self.iCount3D:=0;
  Self.iPageIndex:=-1;
  Self.iTotalTextures:=0;
  Self.CurrBindedMegatextureIndex:=-1;
  Self.CurrPage:=nil;
  Self.CurrRegion:=nil;
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
      if ((Self.iPageIndex mod MEGATEXTURE_VOLUME_SIZE) = 0) then
        begin
          Inc(Self.iCount3D);
          glGenTextures(1, @Self.Page3DList[Self.iCount3D - 1]);
          if (Self.Page3DList[Self.iCount3D - 1] = 0) then
            begin
              if (ErrorInfo <> nil) then ErrorInfo^:=mmeOutOfGPUMemory;
              Result:=False;
              Exit;
            end;

          glActiveTextureARB(GL_TEXTURE1);
          glEnable(GL_TEXTURE_3D);
          glBindTexture(GL_TEXTURE_3D, Self.Page3DList[Self.iCount3D - 1]);
          //  GL_CLAMP_TO_EDGE / GL_REPEAT
          glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
          glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
          glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
          // GL_LINEAR / GL_NEAREST
          if (Self.bLinearFilter) then
            begin
              glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
              glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            end
          else
            begin
              glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
              glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
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
          glTexImage3DExt(
            GL_TEXTURE_3D, 0, GL_RGB8,
            MEGATEXTURE_SIZE, MEGATEXTURE_SIZE, MEGATEXTURE_VOLUME_SIZE,
            0,
            GL_RGB, GL_UNSIGNED_BYTE,
            nil
          );
          //
          glBindTexture(GL_TEXTURE_3D, 0); //}
        end;

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


function CMegatextureManager.IsCanReserveTexture(const Size: TPoint): Boolean;
var
  i, j: SmallInt;
  best, best2: SmallInt;
begin
  {$R-}
  if ((Size.X < 2) or (Size.Y < 2) or (Size.X > MEGATEXTURE_SIZE)
    or (Size.Y > MEGATEXTURE_SIZE)) then
    begin
      // We only work with sizes from 2x2 to 128x128
      Result:=False;
      Exit;
    end;

  if (Self.CurrPage.CountRegions = 0) then
    begin
      // In this case this is first region and it's always start at (0, 0)
      // and we reject input sizes out of range [2x2 .. 128x128].
      // Thus we can put him at (0, 0)
      Result:=True;
      Exit;
    end;

  best:=MEGATEXTURE_SIZE;
	for i:=0 to (MEGATEXTURE_SIZE - Size.X - 1) do
    begin
		  best2:=0;
		  for j:=0 to (Size.X - 1) do
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
		  if (j = Size.X) then
		    begin
          // this is a valid spot
          best:=best2;
		    end;
	  end;

	Result:=((best + Size.Y) <= MEGATEXTURE_SIZE);
  {$R+}
end;

function CMegatextureManager.ReserveTexture(const Size: TPoint): Integer;
var
  Pos: TPoint;
  i, j: Integer;
  best, best2: Integer;
begin
  {$R-}
  if ((Size.X < 2) or (Size.Y < 2) or (Size.X > MEGATEXTURE_SIZE)
    or (Size.Y > MEGATEXTURE_SIZE)) then
    begin
      // We only work with sizes from 2x2 to 128x128
      Result:=-1;
      Exit;
    end;

  if (Self.CurrPage.CountRegions = 0) then
    begin
      // In this case this is first region and it's always start at (0, 0)
      // and we reject input sizes out of range [2x2 .. 128x128].
      // Thus we can put him at (0, 0), do it:
      Self.CurrPage.CountRegions:=1;
      Self.CurrPage.FirstRegionMax.x:=Byte(Size.X - 1);
      Self.CurrPage.FirstRegionMax.y:=Byte(Size.Y - 1);
      for i:=0 to (Size.X - 1) do
        begin
		      Self.ScanLine[i]:=Size.Y;
        end;
      Inc(Self.iTotalTextures);

      Result:=0;
      Exit;
    end;

  best:=MEGATEXTURE_SIZE;
	for i:=0 to (MEGATEXTURE_SIZE - Size.X - 1) do
    begin
		  best2:=0;
		  for j:=0 to (Size.X - 1) do
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
		  if (j = Size.X) then
		    begin
          // this is a valid spot
			    Pos.X:=i;
			    Pos.Y:=best2;
          best:=best2;
		    end;
	  end;

  // Check if put region get out of megatexture size range.
	if ((best + Size.Y) > MEGATEXTURE_SIZE) then
    begin
		  Result:=-1;
      Exit;
    end;

  // Update ScanLine
  Inc(best, Size.Y);
	for i:=0 to (Size.X - 1) do
    begin
		  Self.ScanLine[Pos.X + i]:=best;
    end;

  Self.CurrRegion.bMin.x:=Pos.X;
  Self.CurrRegion.bMin.y:=Pos.Y;
  Self.CurrRegion.bMax.x:=(Size.X - 1) + Pos.X;
  Self.CurrRegion.bMax.y:=(Size.Y - 1) + Pos.Y;
  Inc(Self.CurrRegion);
  Inc(Self.CurrPage.CountRegions);
  Inc(Self.iTotalTextures);

  Result:=Self.CurrPage.CountRegions - 1;
  {$R+}
end;


function CMegatextureManager.UpdateTextureFromArray(const MegatextureId, SubRegionId: Integer;
  const SrcBase, SrcAdd: PRGB888): Boolean;
var
  i, area: Integer;
  r, g, b: Integer;
  PtrSrcBase, PtrSrcAdd, PtrDest: PRGB888;
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

  RenderId:=Self.Page3DList[MegatextureId div MEGATEXTURE_VOLUME_SIZE];
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
      SubRegion.bMin:=VEC2B_ZEROS;
      SubRegion.bMax:=Self.PageList[MegatextureId].FirstRegionMax;
    end
  else
    begin
      SubRegion:=Self.PageList[MegatextureId].Regions[SubRegionId - 1];
    end;

  if (SrcAdd <> nil) then
    begin
      // Dest.rgb = SrcBase.rgb + SrcAdd.rgb;
      area:=(SubRegion.bMax.x - SubRegion.bMin.x + 1)*(SubRegion.bMax.y - SubRegion.bMin.y + 1);
      PtrDest:=SysGetMem(area*SizeOf(tRGB888));
      if (PtrDest = nil) then
        begin
          Result:=False;
          Exit;
        end;
        
      PtrSrcBase:=SrcBase;
      PtrSrcAdd:=SrcAdd;
      for i:=0 to (area - 1) do
        begin
          r:=PtrSrcBase.r + PtrSrcAdd.r;
          g:=PtrSrcBase.g + PtrSrcAdd.g;
          b:=PtrSrcBase.b + PtrSrcAdd.b;
          if (r > 255) then PtrDest.r:=255 else PtrDest.r:=r;
          if (g > 255) then PtrDest.g:=255 else PtrDest.g:=g;
          if (b > 255) then PtrDest.b:=255 else PtrDest.b:=b;
          //
          Inc(PtrSrcBase);
          Inc(PtrSrcAdd);
          Inc(PtrDest);
        end;
      Dec(PtrDest, area);

      glActiveTextureARB(GL_TEXTURE1);
      glEnable(GL_TEXTURE_3D);
      glBindTexture(GL_TEXTURE_3D, RenderId);
      glTexSubImage3DEXT(
        GL_TEXTURE_3D, 0,
        SubRegion.bMin.x,
        SubRegion.bMin.y,
        MegatextureId mod MEGATEXTURE_VOLUME_SIZE,
        (SubRegion.bMax.x - SubRegion.bMin.x + 1),
        (SubRegion.bMax.y - SubRegion.bMin.y + 1),
        1,
        GL_RGB, GL_UNSIGNED_BYTE,
        PtrDest
      );
      glBindTexture(GL_TEXTURE_3D, 0);

      SysFreeMem(PtrDest);
    end
  else
    begin
      // Dest.rgb = SrcBase.rgb;
      glActiveTextureARB(GL_TEXTURE1);
      glEnable(GL_TEXTURE_3D);
      glBindTexture(GL_TEXTURE_3D, RenderId);
      glTexSubImage3DEXT(
        GL_TEXTURE_3D, 0,
        SubRegion.bMin.x,
        SubRegion.bMin.y,
        MegatextureId mod MEGATEXTURE_VOLUME_SIZE,
        (SubRegion.bMax.x - SubRegion.bMin.x + 1),
        (SubRegion.bMax.y - SubRegion.bMin.y + 1),
        1,
        GL_RGB, GL_UNSIGNED_BYTE,
        SrcBase
      );
      glBindTexture(GL_TEXTURE_3D, 0);
    end;

  Result:=True;
  {$R+}
end;

function CMegatextureManager.UpdateCurrentBufferFromArray(const MegatextureId, SubRegionId: Integer;
  const SrcBase, SrcAdd: PRGB888): Boolean;
var
  i, j, border: Integer;
  r, g, b: Integer;
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
      SubRegion.bMin:=VEC2B_ZEROS;
      SubRegion.bMax:=Self.PageList[MegatextureId].FirstRegionMax;
    end
  else
    begin
      SubRegion:=Self.PageList[MegatextureId].Regions[SubRegionId - 1];
    end;

  PtrSrcBase:=SrcBase;
  PtrDest:=@Self.CurrPixelBuff[SubRegion.bMin.y*MEGATEXTURE_SIZE + SubRegion.bMin.x];
  border:=MEGATEXTURE_SIZE - (SubRegion.bMax.x - SubRegion.bMin.x + 1);
  if (SrcAdd <> nil) then
    begin
      // Dest.rgb = SrcBase.rgb + SrcAdd.rgb;
      PtrSrcAdd:=SrcAdd;
      for i:=0 to (SubRegion.bMax.y - SubRegion.bMin.y) do
        begin
          for j:=0 to (SubRegion.bMax.x - SubRegion.bMin.x) do
            begin
              r:=PtrSrcBase.r + PtrSrcAdd.r;
              g:=PtrSrcBase.g + PtrSrcAdd.g;
              b:=PtrSrcBase.b + PtrSrcAdd.b;
              if (r > 255) then PtrDest.r:=255 else PtrDest.r:=r;
              if (g > 255) then PtrDest.g:=255 else PtrDest.g:=g;
              if (b > 255) then PtrDest.b:=255 else PtrDest.b:=b;
              //
              Inc(PtrSrcBase);
              Inc(PtrSrcAdd);
              Inc(PtrDest);
            end;
          Inc(PtrDest, border);
        end;
    end
  else
    begin
      // Dest.rgb = SrcBase.rgb;
      for i:=0 to (SubRegion.bMax.y - SubRegion.bMin.y) do
        begin
          for j:=0 to (SubRegion.bMax.x - SubRegion.bMin.x) do
            begin
              PtrDest^:=PtrSrcBase^;
              //
              Inc(PtrSrcBase);
              Inc(PtrDest);
            end;
          Inc(PtrDest, border);
        end; 
    end;

  Result:=True;
  {$R+}
end;

function CMegatextureManager.UpdateTextureFromCurrentBuffer(): Boolean;
var
  RenderId: GLuint;
begin
  {$R-}
  if (Self.iPageIndex < 0) then
    begin
      Result:=False;
      Exit;
    end;

  RenderId:=Self.Page3DList[Self.iPageIndex div MEGATEXTURE_VOLUME_SIZE];
  if (RenderId = 0) then
    begin
      Result:=False;
      Exit;
    end;

  glActiveTextureARB(GL_TEXTURE1);
  glEnable(GL_TEXTURE_3D);
  glBindTexture(GL_TEXTURE_3D, RenderId);
  glTexSubImage3DEXT(
    GL_TEXTURE_3D, 0,
    0, 0, Self.iPageIndex mod MEGATEXTURE_VOLUME_SIZE,
    MEGATEXTURE_SIZE, MEGATEXTURE_SIZE, 1,
    GL_RGB, GL_UNSIGNED_BYTE,
    @Self.CurrPixelBuff[0]
  );
  glBindTexture(GL_TEXTURE_3D, 0);

  Result:=True;
  {$R+}
end;

procedure CMegatextureManager.BindMegatexture3D(const MegatextureIndex: Integer);
var
  MetagextureIndex3D: Integer;
begin
  {$R-}
  MetagextureIndex3D:=MegatextureIndex div MEGATEXTURE_VOLUME_SIZE;
  if ((MetagextureIndex3D >= 0) and (MetagextureIndex3D < Self.iCount3D) and (Self.bEnable)) then
    begin
      if (MetagextureIndex3D <> Self.CurrBindedMegatextureIndex) then
        begin
          Self.CurrBindedMegatextureIndex:=MetagextureIndex3D;
          glActiveTextureARB(GL_TEXTURE1);
          glBindTexture(GL_TEXTURE_3D, Self.Page3DList[Self.CurrBindedMegatextureIndex]);
        end;
    end
  else
    begin
      Self.CurrBindedMegatextureIndex:=-1;
      glActiveTextureARB(GL_TEXTURE1);
      glBindTexture(GL_TEXTURE_3D, 0);
    end;
  {$R+}
end;

procedure CMegatextureManager.UnbindMegatexture3D();
begin
  {$R-}
  Self.CurrBindedMegatextureIndex:=-1;
  glActiveTextureARB(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_3D, 0);
  {$R+}
end;


function CMegatextureManager.UpdateTextureCoords(
  const MegatextureId, SubRegionId: Integer;
  const CoordSrc: PVec2f; const CoordDest: PVec3f;
  const CountTexCoords: Integer): Boolean;
var
  i, RenderId: Integer;
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
      CurrSubRegion.bMin:=VEC2B_ZEROS;
      CurrSubRegion.bMax:=Self.PageList[MegatextureId].FirstRegionMax;
    end
  else
    begin
      CurrSubRegion:=Self.PageList[MegatextureId].Regions[SubRegionId - 1];
    end;

  RenderId:=MegatextureId mod MEGATEXTURE_VOLUME_SIZE;
  for i:=0 to (CountTexCoords - 1) do
    begin
      AVec3f(CoordDest)[i].x:=(AVec2f(CoordSrc)[i].x + CurrSubRegion.bMin.x)*MEGATEXTURE_STEP;
      AVec3f(CoordDest)[i].y:=(AVec2f(CoordSrc)[i].y + CurrSubRegion.bMin.y)*MEGATEXTURE_STEP;
      AVec3f(CoordDest)[i].z:=RenderId*MEGATEXTURE_STEP_3D + MEGATEXTURE_STEP_3D_HALF;
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
      for i:=0 to (Self.iCount3D - 1) do
        begin
          glBindTexture(GL_TEXTURE_3D, Self.Page3DList[i]);
          // GL_LINEAR / GL_NEAREST
          glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
          glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        end;
    end
  else
    begin
      for i:=0 to (Self.iCount3D - 1) do
        begin
          glBindTexture(GL_TEXTURE_3D, Self.Page3DList[i]);
          // GL_LINEAR / GL_NEAREST
          glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
          glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        end;
    end;
  glBindTexture(GL_TEXTURE_3D, 0);
  {$R+}
end;

procedure CMegatextureManager.SetLightmapState(const isEnable: Boolean);
begin
  {$R-}
  Self.bEnable:=isEnable;
  if (isEnable = False) then Self.UnbindMegatexture3D();
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
      for i:=0 to (Self.iCount3D - 1) do
        begin
          glBindTexture(GL_TEXTURE_3D, Self.Page3DList[i]);
          glTexEnvf(GL_TEXTURE_ENV, GL_RGB_SCALE, ScaleRGB);
        end;
      glBindTexture(GL_TEXTURE_3D, 0);
    end;
  {$R+}
end;

end.
