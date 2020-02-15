unit UnitBSPstruct;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  Graphics,
  Math,
  OpenGL,
  EXTOpengl32Glew32,
  UnitVec,
  UnitEntity,
  UnitPlane,
  UnitTexture,
  UnitMapHeader,
  UnitNode,
  UnitFace,
  UnitVisLeaf,
  UnitMarkSurface,
  UnitEdge,
  UnitBrushModel;


//*****************************************************************************
type eLoadMapErrors = (erNoErrors = 0, erFileNotExists, erMinSize, erBadVersion,
  erBadEOFbyHeader, erNoEntData, erNoPlanes, erNoTextures, erNoVertex,
  erNoNodes, erNoTexInfos, erNoFaces, erNoLight, erNoLeaf, erNoMarkSurface,
  erNoEdge, erNoSurfEdge, erNoBrushes, erNoPVS);

type tMapBSP = record
    LoadState: eLoadMapErrors;
    MapHeader: tMapHeader; // BSP

    SizeEndData: Integer;
    EntDataLump: String; // BSP
    CountEntities: Integer;
    Entities: AEntity;

    PlaneLump: APlane;  // BSP
    CountPlanes: Integer;

    TextureLump: tTextureLump; // BSP

    VertexLump: AVec3f; // BSP
    CountVertices: Integer;

    PackedVisibility: AByte; // BSP
    SizePackedVisibility: Integer;
    CountVisLeafWithPVS: Integer;

    NodeLump: ANode; // BSP
    NodeInfos: ANodeInfo;
    CountNodes: Integer;
    RootIndex: Integer;

    TexInfoLump: ATexInfo; // BSP
    CountTexInfos: Integer;

    FaceLump: AFace; // BSP
    FaceInfos: AFaceInfo;
    CountFaces: Integer;

    LightingLump: ARGB888; // BSP
    CountUnpackedLightMaps: Integer;
    CountPackedLightmaps: Integer;

    ClipNodeRawData: AByte;
    SizeClipNodes: Integer;

    LeafLump: AVisLeaf; // BSP
    VisLeafInfos: AVisLeafInfo;
    CountLeafs: Integer;

    MarkSurfaceLump: AMarkSurface; // BSP
    CountMarkSurfaces: Integer;

    EdgeLump: AEdge; // BSP
    CountEdges: Integer;

    SurfEdgeLump: ASurfEdge; // BSP
    CountSurfEdges: Integer;

    ModelLump: ABrushModel; // BSP
    ModelInfos: ABrushModelInfo;
    CountBrushModels: Integer;
  end;
type PMapBSP = ^tMapBSP;

procedure FreeMapBSP(const Map: PMapBSP);
procedure SetZerosLumpSize(const Map: PMapBSP);

procedure SaveBSP30ToFile(const FileName: String; const Map: PMapBSP);
function LoadBSP30FromFile(const FileName: String; const Map: PMapBSP): boolean;
function ShowLoadBSPMapError(const LoadMapErrorType: eLoadMapErrors): String;

procedure UpdateFaceInfo(const Map: PMapBSP; const FaceId: Integer);
procedure UpdateBrushFaceIndex(const Map: PMapBSP);
procedure UpdateVisLeafFaceIndex(const Map: PMapBSP);
procedure UpDateVisLeafInfo(const Map: PMapBSP; const VisLeafId: Integer);
procedure UpDateNodeInfo(const Map: PMapBSP; const NodeInfoId: Integer);
procedure UpDateEntityInfo(const Map: PMapBSP; const EntityId: Integer);
procedure UpdateVisLeafEntBrushes(const Map: PMapBSP; const VisLeafId: Integer);

function GetLeafIndexByPoint(const NodeInfos: ANodeInfo; const Point: tVec3f;
  const RootIndex: Integer): Integer;
function UnPackPVS(const PackedPVS: AByte; var UnPackedPVS: AByteBool;
  const CountPVS, PackedSize: Integer): Integer;


implementation


//*****************************************************************************
procedure FreeMapBSP(const Map: PMapBSP);
var
  i, j: Integer;
begin
  {$R-}
  Map.SizeEndData:=0;
  Map.EntDataLump:='';
  Map.CountEntities:=0;
  SetLength(Map.Entities, 0);

  Map.CountPlanes:=0;
  SetLength(Map.PlaneLump, 0);

  Setlength(Map.TextureLump.MipTexInfos, 0);
  SetLength(Map.TextureLump.OffsetsToMipTex, 0);
  for i:=0 to Map.TextureLump.nCountTextures-1 do
    begin
      SetLength(Map.TextureLump.Wad3Textures[i].MipData[0], 0);
      SetLength(Map.TextureLump.Wad3Textures[i].MipData[1], 0);
      SetLength(Map.TextureLump.Wad3Textures[i].MipData[2], 0);
      SetLength(Map.TextureLump.Wad3Textures[i].MipData[3], 0);
    end;
  SetLength(Map.TextureLump.Wad3Textures, 0);
  Map.TextureLump.nCountTextures:=0;

  Map.CountVertices:=0;
  SetLength(Map.VertexLump, 0);

  Map.SizePackedVisibility:=0;
  Map.CountVisLeafWithPVS:=0;
  SetLength(Map.PackedVisibility, 0);

  Map.CountNodes:=0;
  SetLength(Map.NodeLump, 0);
  SetLength(Map.NodeInfos, 0);

  Map.CountTexInfos:=0;
  SetLength(Map.TexInfoLump, 0);

  SetLength(Map.FaceLump, 0);
  for i:=0 to (Map.CountFaces - 1) do
    begin
      SetLength(Map.FaceInfos[i].Vertex, 0);
      SetLength(Map.FaceInfos[i].TexCoords, 0);
      SetLength(Map.FaceInfos[i].LmpCoords, 0);
      //
      glDeleteTextures(4, @Map.FaceInfos[i].LmpPages[0]);
      //
      for j:=0 to 3 do
        begin
          SetLength(Map.FaceInfos[i].Lightmaps[j], 0);
        end;
    end;
  SetLength(Map.FaceInfos, 0);
  Map.CountFaces:=0;

  Map.CountPackedLightmaps:=0;
  Map.CountUnpackedLightmaps:=0;
  SetLength(Map.LightingLump, 0);

  SetLength(Map.ClipNodeRawData, 0);
  Map.SizeClipNodes:=0;

  SetLength(Map.LeafLump, 0);
  for i:=0 to Map.CountLeafs-1 do
    begin
      SetLength(Map.VisLeafInfos[i].FaceIndexes, 0);
      SetLength(Map.VisLeafInfos[i].BrushFaceIndexes, 0);
      SetLength(Map.VisLeafInfos[i].PVS, 0);
    end;
  SetLength(Map.VisLeafInfos, 0);
  Map.CountLeafs:=0;

  Map.CountMarkSurfaces:=0;
  SetLength(Map.MarkSurfaceLump, 0);

  Map.CountEdges:=0;
  SetLength(Map.EdgeLump, 0);

  Map.CountSurfEdges:=0;
  SetLength(Map.SurfEdgeLump, 0);

  SetLength(Map.ModelLump, 0);
  SetLength(Map.ModelInfos, 0);
  Map.CountBrushModels:=0;
  {$R+}
end;

procedure SetZerosLumpSize(const Map: PMapBSP);
begin
  {$R-}
  with Map^, MapHeader do
    begin
      SizeEndData:=           0;
      CountPlanes:=           0;
      CountVertices:=         0;
      SizePackedVisibility:=  0;
      CountNodes:=            0;
      CountTexInfos:=         0;
      CountFaces:=            0;
      CountPackedLightmaps:=  0;
      CountUnpackedLightmaps:=0;
      CountLeafs:=            0;
      CountMarkSurfaces:=     0;
      CountEdges:=            0;
      CountSurfEdges:=        0;
      CountBrushModels:=      0;
      SizeClipNodes:=         0;
    end;
  {$R+}
end;

procedure SaveBSP30ToFile(const FileName: String; const Map: PMapBSP);
const
  PaddingByte: Byte = 0;
var
  i, j, k: Integer;
  CurrentFileOffset: Integer;
  MapFile: File;
  //
  lpFaceInfo: PFaceInfo;
begin
  {$R-}
  AssignFile(MapFile, FileName);
  Rewrite(MapFile, 1);

  // Write null header, it will be rewrite at end of saving map
  CurrentFileOffset:=0;
  Seek(MapFile, CurrentFileOffset);
  ZeroFillChar(@Map.MapHeader.LumpsInfo[0], MAP_HEADER_SIZE - 4);
  BlockWrite(MapFile, Map.MapHeader, MAP_HEADER_SIZE);
  Inc(CurrentFileOffset, MAP_HEADER_SIZE);
  // MAP_HEADER_SIZE = 124 bytes, multiple by 4, dont need add padding


  // Save Plane lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_PLANES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_PLANES].nLength:=Map.CountPlanes*SizeOfPlane;
  //
  BlockWrite(MapFile, (@Map.PlaneLump[0])^, Map.MapHeader.LumpsInfo[LUMP_PLANES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_PLANES].nLength);
  // SizeOfPlane = 20 bytes, multiple by 4, dont need add padding


  // Save VisLeaf lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_LEAVES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_LEAVES].nLength:=Map.CountLeafs*SizeOfVisLeaf;
  //
  BlockWrite(MapFile, (@Map.LeafLump[0])^, Map.MapHeader.LumpsInfo[LUMP_LEAVES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_LEAVES].nLength);
  // SizeOfVisLeaf = 28 bytes, multiple by 4, dont need add padding


  // Save Vertex lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_VERTICES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_VERTICES].nLength:=Map.CountVertices*SizeOfVec3f;
  //
  BlockWrite(MapFile, (@Map.VertexLump[0])^, Map.MapHeader.LumpsInfo[LUMP_VERTICES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_VERTICES].nLength);
  // SizeOfVec3f = 12 bytes, multiple by 4, dont need add padding


  // Save Node lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_NODES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_NODES].nLength:=Map.CountNodes*SizeOfNode;
  //
  BlockWrite(MapFile, (@Map.NodeLump[0])^, Map.MapHeader.LumpsInfo[LUMP_NODES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_NODES].nLength);
  // SizeOfVec3f = 24 bytes, multiple by 4, dont need add padding


  // Save TexInfo lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nLength:=Map.CountTexInfos*SizeOfTexInfo;
  //
  BlockWrite(MapFile, (@Map.TexInfoLump[0])^, Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nLength);
  // SizeOfTexInfo = 40 bytes, multiple by 4, dont need add padding


  // Create Lightmap lump for saving Faces (get offsets in Lightmap lump)
  SetLength(Map.LightingLump, Map.CountUnpackedLightmaps);
  k:=0;
  for i:=0 to (Map.CountFaces - 1) do
    begin
      lpFaceInfo:=@Map.FaceInfos[i];
      if (lpFaceInfo.CountLightStyles = 0) then
        begin
          Map.FaceLump[i].nLightmapOffset:=-1;
          Continue;
        end;
      //
      Map.FaceLump[i].nLightmapOffset:=k*3;
      for j:=0 to (lpFaceInfo.CountLightStyles - 1) do
        begin
          if (lpFaceInfo.isUniqueLmp[j]) then
            begin
              FillLightmaps(
                lpFaceInfo.lpFirstLightmap[j]^,
                @Map.LightingLump[k],
                lpFaceInfo.LmpSquare
              );
            end
          else
            begin
              CopyBytes(
                PByte(lpFaceInfo.lpFirstLightmap[j]),
                PByte(@Map.LightingLump[k]),
                lpFaceInfo.LmpSquare*SizeOfRGB888
              );
            end;
          Inc(k, lpFaceInfo.LmpSquare);
        end;
    end;

  // Save Face Lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_FACES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_FACES].nLength:=Map.CountFaces*SizeOfFace;
  //
  BlockWrite(MapFile, (@Map.FaceLump[0])^, Map.MapHeader.LumpsInfo[LUMP_FACES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_FACES].nLength);
  // SizeOfFace = 20 bytes, multiple by 4, dont need add padding


  // Save ClipNode lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_CLIPNODES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_CLIPNODES].nLength:=Map.SizeClipNodes;
  //
  BlockWrite(MapFile, (@Map.ClipNodeRawData[0])^, Map.SizeClipNodes);
  Inc(CurrentFileOffset, Map.SizeClipNodes);
  // SizeOfClipNodes = 8 bytes, multiple by 4, dont need add padding


  // Save MarkSurface lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength:=Map.CountMarkSurfaces*SizeOfMarkSurface;
  //
  BlockWrite(MapFile, (@Map.MarkSurfaceLump[0])^, Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength);
  // SizeOfMarkSurface = 2 bytes, don't multiple by 4, need add padding
  //
  k:=0; // use this variable as padding fill value
  if ((Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength mod 4) <> 0) then
    begin
      Seek(MapFile, CurrentFileOffset);
      BlockWrite(MapFile, (@k)^, 2);
      Inc(CurrentFileOffset, 2);
    end;


  // Save SurfEdge lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nLength:=Map.CountSurfEdges*SizeOfSurfEdge;
  //
  BlockWrite(MapFile, (@Map.SurfEdgeLump[0])^, Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nLength);
  // SizeOfSurfEdge = 4 bytes, multiple by 4, dont need add padding


  // Save Edge lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_EDGES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength:=Map.CountEdges*SizeOfEdge;
  //
  BlockWrite(MapFile, (@Map.EdgeLump[0])^, Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength);
  // SizeOfEdge = 4 bytes, multiple by 4, dont need add padding


  // Save Brush Model lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nLength:=Map.CountBrushModels*SizeOfBrushModel;
  //
  BlockWrite(MapFile, (@Map.ModelLump[0])^, Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nLength);
  // SizeOfBrushModel = 64 bytes, multiple by 4, dont need add padding


  // Save Lightmap lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength:=Map.CountUnpackedLightmaps*SizeOfRGB888;
  //
  BlockWrite(MapFile, (@Map.LightingLump[0])^, Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength);
  SetLength(Map.LightingLump, 0);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength);
  //
  // SizeOfRGB888 = 3 bytes, don't multiple by 4, need add padding
  //
  k:=0; // use this variable as padding fill value
  i:=(Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength mod 4);
  if (i <> 0) then
    begin
      Seek(MapFile, CurrentFileOffset);
      BlockWrite(MapFile, (@k)^, 4 - i);
      Inc(CurrentFileOffset, 4 - i);
    end;


  // Save PVS lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_VISIBILITY].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_VISIBILITY].nLength:=Map.SizePackedVisibility;
  //
  BlockWrite(MapFile, (@Map.PackedVisibility[0])^, Map.SizePackedVisibility);
  Inc(CurrentFileOffset, Map.SizePackedVisibility);
  //
  // PVS is bytes array, don't multiple by 4, need add padding
  //
  k:=0; // use this variable as padding fill value
  i:=(Map.SizePackedVisibility mod 4);
  if (i <> 0) then
    begin
      Seek(MapFile, CurrentFileOffset);
      BlockWrite(MapFile, (@k)^, 4 - i);
      Inc(CurrentFileOffset, 4 - i);
    end;


  // Save Entity lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_ENTITIES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_ENTITIES].nLength:=Map.SizeEndData;
  //
  BlockWrite(MapFile, (@Map.EntDataLump[1])^, Map.SizeEndData);
  Inc(CurrentFileOffset, Map.SizeEndData);
  //
  // EntData is bytes array, don't multiple by 4, need add padding
  //
  k:=0; // use this variable as padding fill value
  i:=(Map.SizeEndData mod 4);
  if (i <> 0) then
    begin
      Seek(MapFile, CurrentFileOffset);
      BlockWrite(MapFile, (@k)^, 4 - i);
      Inc(CurrentFileOffset, 4 - i);
    end;


  // Save Texutre lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_TEXTURES].nOffset:=CurrentFileOffset;
  //
  BlockWrite(MapFile, Map.TextureLump.nCountTextures, SizeOf(Integer));
  BlockWrite(MapFile, (@Map.TextureLump.OffsetsToMipTex[0])^, Map.TextureLump.nCountTextures*SizeOf(Integer));

  // Save MipTex
  for i:=0 to (Map.TextureLump.nCountTextures - 1) do
    begin
      Seek(MapFile, CurrentFileOffset + Map.TextureLump.OffsetsToMipTex[i]);
      BlockWrite(MapFile, (@Map.TextureLump.MipTexInfos[i])^, SizeOfMipTex);
    end;

  // Save PixelData
  for i:=0 to (Map.TextureLump.nCountTextures - 1) do
    begin
      if (Map.TextureLump.MipTexInfos[i].nOffsets[0] <= 0) then Continue;
      j:=CurrentFileOffset + Map.TextureLump.OffsetsToMipTex[i];

      // Save Mip0
      Seek(MapFile, j + Map.TextureLump.MipTexInfos[i].nOffsets[0]);
      BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i].MipData[0][0])^, Map.TextureLump.Wad3Textures[i].MipSize[0]);

      // Save Mip1
      Seek(MapFile, j + Map.TextureLump.MipTexInfos[i].nOffsets[1]);
      BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i].MipData[1][0])^, Map.TextureLump.Wad3Textures[i].MipSize[1]);

      // Save Mip2
      Seek(MapFile, j + Map.TextureLump.MipTexInfos[i].nOffsets[2]);
      BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i].MipData[2][0])^, Map.TextureLump.Wad3Textures[i].MipSize[2]);

      // Save Mip3
      Seek(MapFile, j + Map.TextureLump.MipTexInfos[i].nOffsets[3]);
      BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i].MipData[3][0])^, Map.TextureLump.Wad3Textures[i].MipSize[3]);
      
      // Save Palette
      Seek(MapFile, j + Map.TextureLump.MipTexInfos[i].nOffsets[3] + Map.TextureLump.Wad3Textures[i].MipSize[3]);
      BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i].RawPadding)^, SizeOf(Word));
      Seek(MapFile, j + Map.TextureLump.MipTexInfos[i].nOffsets[3] + Map.TextureLump.Wad3Textures[i].MipSize[3] + 2);
      BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i].Palette[0])^, PALETTE_SIZE);
    end;
  k:=FileSize(MapFile);
  Map.MapHeader.LumpsInfo[LUMP_TEXTURES].nLength:=k - CurrentFileOffset;

  // Save Map Header
  Seek(MapFile, 0);
  BlockWrite(MapFile, Map.MapHeader, MAP_HEADER_SIZE);
  
  // Make file size multiple by 4
  k:=0; // use this variable as padding fill value
  i:=(FileSize(MapFile) mod 4);
  if (i <> 0) then
    begin
      Seek(MapFile, FileSize(MapFile));
      BlockWrite(MapFile, (@k)^, 4 - i);
    end;

  CloseFile(MapFile);
  {$R+}
end;

function LoadBSP30FromFile(const FileName: String; const Map: PMapBSP): boolean;
var
  i, j, k, MapFileSize: Integer;
  MapFile: File;
  tmpList: TStringList;
  tmpEntityLump: String;
begin
  {$R-}
  LoadBSP30FromFile:=False;
  Map.LoadState:=erNoErrors;
  if (FileExists(FileName) = False) then
    begin
      Map.LoadState:=erFileNotExists;
      Exit;
    end;

  AssignFile(MapFile, FileName);
  Reset(MapFile, 1);

  MapFileSize:=FileSize(MapFile);
  if (MapFileSize < MAP_HEADER_SIZE) then
    begin
      Map.LoadState:=erMinSize;
      CloseFile(MapFile);
      Exit;
    end;

  BlockRead(MapFile, Map.MapHeader, MAP_HEADER_SIZE);
  if (Map.MapHeader.nVersion <> MAP_VERSION) then
    begin
      Map.LoadState:=erBadVersion;
      CloseFile(MapFile);
      Exit;
    end;
  {if (GetEOFbyHeader(Map.MapHeader) < MapFileSize) then
    begin
      Map.LoadState:=erBadEOFbyHeader;
      CloseFile(MapFile);
      Exit;
    end; //}

  // Set Lump Sizes
  with Map^, MapHeader do
    begin
      SizeEndData:=           LumpsInfo[LUMP_ENTITIES].nLength;
      CountPlanes:=           LumpsInfo[LUMP_PLANES].nLength div SizeOfPlane;
      CountVertices:=         LumpsInfo[LUMP_VERTICES].nLength div SizeOfVec3f;
      SizePackedVisibility:=  LumpsInfo[LUMP_VISIBILITY].nLength;
      CountNodes:=            LumpsInfo[LUMP_NODES].nLength div SizeOfNode;
      CountTexInfos:=         LumpsInfo[LUMP_TEXINFO].nLength div SizeOfTexInfo;
      CountFaces:=            LumpsInfo[LUMP_FACES].nLength div SizeOfFace;
      CountPackedLightmaps:=  LumpsInfo[LUMP_LIGHTING].nLength div SizeOfRGB888;
      CountLeafs:=            LumpsInfo[LUMP_LEAVES].nLength div SizeOfVisLeaf;
      CountMarkSurfaces:=     LumpsInfo[LUMP_MARKSURFACES].nLength div SizeOfMarkSurface;
      CountEdges:=            LumpsInfo[LUMP_EDGES].nLength div SizeOfEdge;
      CountSurfEdges:=        LumpsInfo[LUMP_SURFEDGES].nLength div SizeOfSurfEdge;
      CountBrushModels:=      LumpsInfo[LUMP_BRUSHES].nLength div SizeOfBrushModel;
      SizeClipNodes:=         LumpsInfo[LUMP_CLIPNODES].nLength;
    end;

  // Read EntData
  if (Map.SizeEndData > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_ENTITIES].nOffset);
      SetLength(Map.EntDataLump, Map.SizeEndData);
      BlockRead(MapFile, (@Map.EntDataLump[1])^, Map.SizeEndData);
      tmpEntityLump:=Map.EntDataLump;

      FixEntityStrEndToWin(tmpEntityLump, Map.SizeEndData);
      tmpList:=SplitEntDataByRow(tmpEntityLump, Map.SizeEndData);
      Map.CountEntities:=GetEntityList(tmpList, Map.Entities);
      if (tmpList <> nil) then
        begin
          tmpList.Clear;
          tmpList.Destroy;
        end;
      tmpEntityLump:='';
    end
  else
    begin
      Map.LoadState:=erNoEntData;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read Planes
  if (Map.CountPlanes > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_PLANES].nOffset);
      SetLength(Map.PlaneLump, Map.CountPlanes);
      BlockRead(MapFile, (@Map.PlaneLump[0])^, Map.MapHeader.LumpsInfo[LUMP_PLANES].nLength);
    end
  else
    begin
      Map.LoadState:=erNoPlanes;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read Textures
  if (Map.MapHeader.LumpsInfo[LUMP_TEXTURES].nLength > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_TEXTURES].nOffset);
      BlockRead(MapFile, Map.TextureLump.nCountTextures, SizeOf(Integer));
      //
      SetLength(Map.TextureLump.OffsetsToMipTex, Map.TextureLump.nCountTextures);
      BlockRead(MapFile, (@Map.TextureLump.OffsetsToMipTex[0])^, Map.TextureLump.nCountTextures*SizeOf(Integer));
      //
      SetLength(Map.TextureLump.MipTexInfos, Map.TextureLump.nCountTextures);
      j:=Map.MapHeader.LumpsInfo[LUMP_TEXTURES].nOffset;

      // Read MipTex
      for i:=0 to (Map.TextureLump.nCountTextures - 1) do
        begin
          Seek(MapFile, j + Map.TextureLump.OffsetsToMipTex[i]);
          BlockRead(MapFile, (@Map.TextureLump.MipTexInfos[i])^, SizeOf(tMipTex));
        end;

      SetLength(Map.TextureLump.Wad3Textures, Map.TextureLump.nCountTextures);
      // Read PixelData
      for i:=0 to (Map.TextureLump.nCountTextures - 1) do
        begin
          Map.TextureLump.Wad3Textures[i].Name:=GetCorrectTextureName(Map.TextureLump.MipTexInfos[i]);

          if (Map.TextureLump.MipTexInfos[i].nOffsets[0] <= 0) then continue;
          k:=j + Map.TextureLump.OffsetsToMipTex[i];
          AllocTexture(Map.TextureLump.MipTexInfos[i], Map.TextureLump.Wad3Textures[i]);

          // Read Mip0
          Seek(MapFile, k + Map.TextureLump.MipTexInfos[i].nOffsets[0]);
          BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i].MipData[0][0])^, Map.TextureLump.Wad3Textures[i].MipSize[0]);

          // Read Mip1
          Seek(MapFile, k + Map.TextureLump.MipTexInfos[i].nOffsets[1]);
          BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i].MipData[1][0])^, Map.TextureLump.Wad3Textures[i].MipSize[1]);

          // Read Mip2
          Seek(MapFile, k + Map.TextureLump.MipTexInfos[i].nOffsets[2]);
          BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i].MipData[2][0])^, Map.TextureLump.Wad3Textures[i].MipSize[2]);

          // Read Mip3
          Seek(MapFile, k + Map.TextureLump.MipTexInfos[i].nOffsets[3]);
          BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i].MipData[3][0])^, Map.TextureLump.Wad3Textures[i].MipSize[3]);

          // Read Palette
          Seek(MapFile, k + Map.TextureLump.MipTexInfos[i].nOffsets[3] + Map.TextureLump.Wad3Textures[i].MipSize[3]);
          BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i].RawPadding)^, SizeOf(Word));
          Seek(MapFile, k + Map.TextureLump.MipTexInfos[i].nOffsets[3] + Map.TextureLump.Wad3Textures[i].MipSize[3] + 2);
          BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i].Palette[0])^, PALETTE_SIZE);
        end;
    end
  else
    begin
      Map.LoadState:=erNoTextures;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read Vertecies
  if (Map.CountVertices > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_VERTICES].nOffset);
      SetLength(Map.VertexLump, Map.CountVertices);
      BlockRead(MapFile, (@Map.VertexLump[0])^, Map.MapHeader.LumpsInfo[LUMP_VERTICES].nLength);
    end
  else
    begin
      Map.LoadState:=erNoVertex;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read PVS
  if (Map.SizePackedVisibility > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_VISIBILITY].nOffset);
      SetLength(Map.PackedVisibility, Map.SizePackedVisibility);
      BlockRead(MapFile, (@Map.PackedVisibility[0])^, Map.SizePackedVisibility);
    end
  else
    begin
      Map.LoadState:=erNoPVS;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read Nodes
  if (Map.CountNodes > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_NODES].nOffset);
      SetLength(Map.NodeLump, Map.CountNodes);
      BlockRead(MapFile, (@Map.NodeLump[0])^, Map.MapHeader.LumpsInfo[LUMP_NODES].nLength);
    end
  else
    begin
      Map.LoadState:=erNoNodes;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read TexInfos
  if (Map.CountTexInfos > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nOffset);
      SetLength(Map.TexInfoLump, Map.CountTexInfos);
      BlockRead(MapFile, (@Map.TexInfoLump[0])^, Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nLength);
    end
  else
    begin
      Map.LoadState:=erNoTexInfos;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read Faces
  if (Map.CountFaces > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_FACES].nOffset);
      SetLength(Map.FaceLump, Map.CountFaces);
      BlockRead(MapFile, (@Map.FaceLump[0])^, Map.MapHeader.LumpsInfo[LUMP_FACES].nLength);
    end
  else
    begin
      Map.LoadState:=erNoFaces;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read Lighting
  if (Map.CountPackedLightmaps > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nOffset);
      SetLength(Map.LightingLump, Map.CountPackedLightmaps);
      BlockRead(MapFile, (@Map.LightingLump[0])^, Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength);
    end
  else
    begin
      Map.LoadState:=erNoLight;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read ClipNodes
  if (Map.SizeClipNodes > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_CLIPNODES].nOffset);
      SetLength(Map.ClipNodeRawData, Map.SizeClipNodes);
      BlockRead(MapFile, (@Map.ClipNodeRawData[0])^, Map.SizeClipNodes);
    end;

  // Read VisLeaves
  if (Map.CountLeafs > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_LEAVES].nOffset);
      SetLength(Map.LeafLump, Map.CountLeafs);
      BlockRead(MapFile, (@Map.LeafLump[0])^, Map.MapHeader.LumpsInfo[LUMP_LEAVES].nLength);
    end
  else
    begin
      Map.LoadState:=erNoLeaf;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read MarkSurfaces
  if (Map.CountMarkSurfaces > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nOffset);
      SetLength(Map.MarkSurfaceLump, Map.CountMarkSurfaces);
      BlockRead(MapFile, (@Map.MarkSurfaceLump[0])^, Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength);
    end
  else
    begin
      Map.LoadState:=erNoMarkSurface;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read Edges
  if (Map.CountEdges > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_EDGES].nOffset);
      SetLength(Map.EdgeLump, Map.CountEdges);
      BlockRead(MapFile, (@Map.EdgeLump[0])^, Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength);
    end
  else
    begin
      Map.LoadState:=erNoEdge;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read SurfEdges
  if (Map.CountSurfEdges > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nOffset);
      SetLength(Map.SurfEdgeLump, Map.CountSurfEdges);
      BlockRead(MapFile, (@Map.SurfEdgeLump[0])^, Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nLength);
    end
  else
    begin
      Map.LoadState:=erNoSurfEdge;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  // Read Brush Models
  if (Map.CountBrushModels > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nOffset);
      SetLength(Map.ModelLump, Map.CountBrushModels);
      BlockRead(MapFile, (@Map.ModelLump[0])^, Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nLength);

      // in any map must be one "zero's" BrushModel, that contain total info about map
      // And we can get count of VisLeafs that need in PVS data, for correct read PVS data
      Map.CountVisLeafWithPVS:=Map.ModelLump[0].nVisLeafs;
      Map.RootIndex:=Map.ModelLump[0].iNode;
    end
  else
    begin
      Map.LoadState:=erNoBrushes;
      CloseFile(MapFile);
      SetZerosLumpSize(Map);
      Exit;
    end;

  CloseFile(MapFile);
  LoadBSP30FromFile:=True;

  // UpDate Planes
  for i:=0 to (Map.CountPlanes - 1) do
    begin
      Map.PlaneLump[i].AxisType:=GetPlaneTypeByNormal(Map.PlaneLump[i].vNormal);
    end;

  // UpDate Face Info
  Map.CountUnpackedLightmaps:=0;
  SetLength(Map.FaceInfos, Map.CountFaces);
  for i:=0 to (Map.CountFaces - 1) do
    begin
      UpDateFaceInfo(Map, i);
    end;
  SetLength(Map.LightingLump, 0);
  UpdateBrushFaceIndex(Map);

  // Create Binary Tree
  SetLength(Map.VisLeafinfos, Map.CountLeafs);
  for i:=0 to (Map.CountLeafs - 1) do
    begin
      UpDateVisLeafInfo(Map, i);
    end;
  UpdateVisLeafFaceIndex(Map);
  
  SetLength(Map.NodeInfos, Map.CountNodes);
  for i:=0 to (Map.CountNodes - 1) do
    begin
      UpDateNodeInfo(Map, i);
    end;

  // Update Eintities VisLeaf and BrushModels
  SetLength(Map.ModelInfos, Map.CountBrushModels);
  for i:=0 to (Map.CountBrushModels - 1) do
    begin
      Map.ModelInfos[i].BBOXf.vMin:=Map.ModelLump[i].vMin;
      Map.ModelInfos[i].BBOXf.vMax:=Map.ModelLump[i].vMax;
    end;
  for i:=0 to (Map.CountEntities - 1) do
    begin
      UpDateEntityInfo(Map, i);
    end;

  // Update Entity Brushes for VisLeafs
  for i:=0 to (Map.CountLeafs - 1) do
    begin
      UpdateVisLeafEntBrushes(Map, i);
    end;
  {$R+}
end;

function ShowLoadBSPMapError(const LoadMapErrorType: eLoadMapErrors): String;
begin
  {$R-}
  Result:='';
  case LoadMapErrorType of
    erNoErrors : Result:='No Errors in load Map File';
    erFileNotExists : Result:='Map File Not Exists';
    erMinSize : Result:='Map File have size less then size of Header';
    erBadVersion : Result:='Map File have bad BSP version';
    erBadEOFbyHeader : Result:='Size of Map File less then contained in Header';
    erNoEntData : Result:='Map File not have Entity lump';
    erNoTextures : Result:='Map File not have Texture lump';
    erNoPlanes : Result:='Map File not have Plane lump';
    erNoVertex : Result:='Map File not have Vertex lump';
    erNoNodes : Result:='Map File not have Node lump';
    erNoLeaf : Result:='Map File not have VisLeaf lump';
    erNoTexInfos : Result:='Map File not have TexInfo lump';
    erNoFaces : Result:='Map File not have Face lump';
    erNoEdge : Result:='Map File not have Edge lump';
    erNoSurfEdge : Result:='Map File not have SurfEdge lump';
    erNoMarkSurface : Result:='Map File not have MarkSurface lump';
    erNoBrushes : Result:='Map File not have ModelBrush lump';
    erNoLight : Result:='Map File not have Lighting lump';
    erNoPVS : Result:='Map File not have PVS lump';
  end;
  {$R+}
end;

procedure UpdateFaceInfo(const Map: PMapBSP; const FaceId: Integer);
var
  lpFace: PFace;
  lpFaceInfo: PFaceInfo;
  lpTexInfo: PTexInfo;
  i, EdgeIndex: Integer;
  LmpMin, LmpMax: TPoint;
begin
  {$R-}
  lpFace:=@Map.FaceLump[FaceId];
  lpFaceInfo:=@Map.FaceInfos[FaceId];
  lpTexInfo:=@Map.TexInfoLump[lpFace.iTextureInfo];
  lpFaceInfo.Wad3TextureIndex:=lpTexInfo.iMipTex;

  lpFaceInfo.TexName:=Map.TextureLump.Wad3Textures[lpFaceInfo.Wad3TextureIndex].Name;

  lpFaceInfo.Plane:=Map.PlaneLump[lpFace.iPlane];
  if (lpFace.nPlaneSides <> 0) then
    begin
      SignInvertVec3f(@lpFaceInfo.Plane.vNormal, @lpFaceInfo.Plane.vNormal);
    end;

  lpFaceInfo.CountVertex:=lpFace.nSurfEdges;
  lpFaceInfo.CountTriangles:=lpFaceInfo.CountVertex - 2;
  SetLength(lpFaceInfo.Vertex, lpFaceInfo.CountVertex);
  SetLength(lpFaceInfo.TexCoords, lpFaceInfo.CountVertex);
  SetLength(lpFaceInfo.LmpCoords, lpFaceInfo.CountVertex);

  lpFaceInfo.BrushId:=0; // WorldBrush
  lpFaceInfo.VisLeafId:=0; // Null Node

  // Get Vertecies
  for i:=0 to (lpFace.nSurfEdges - 1) do
    begin
      EdgeIndex:=Map.SurfEdgeLump[lpFace.iFirstSurfEdge + DWORD(i)];
      if (EdgeIndex >= 0) then
        begin
          lpFaceInfo.Vertex[i]:=Map.VertexLump[Map.EdgeLump[EdgeIndex].v0];
        end
      else
        begin
          lpFaceInfo.Vertex[i]:=Map.VertexLump[Map.EdgeLump[-EdgeIndex].v1];
        end;
    end;
  GetBBOX(lpFaceInfo.Vertex, @lpFaceInfo.BBOX, lpFaceInfo.CountVertex);

  // Get Vertecies textures coordinates
  for i:=0 to (lpFaceInfo.CountVertex - 1) do
    begin
      GetTexureCoordST(lpFaceInfo.Vertex[i], lpTexInfo^, lpFaceInfo.TexCoords[i]);
    end;
  GetTexBBOX(lpFaceInfo.TexCoords, @lpFaceInfo.TexBBOX, lpFaceInfo.CountVertex);

  // GoldSrc use Quake 2 Method of determinant lightmap size based on Floor() and Ceil()
  LmpMin.X:=Floor(lpFaceInfo.TexBBOX.vMin.x*inv16);
  LmpMax.X:=Ceil(lpFaceInfo.TexBBOX.vMax.x*inv16);
  LmpMin.Y:=Floor(lpFaceInfo.TexBBOX.vMin.y*inv16);
  LmpMax.Y:=Ceil(lpFaceInfo.TexBBOX.vMax.y*inv16);

  // Lightmap samples stored in corner of samples, instead center of samples
  // so lightmap size need increment by one
  lpFaceInfo.LmpSize.X:=LmpMax.X - LmpMin.X + 1;
  lpFaceInfo.LmpSize.Y:=LmpMax.Y - LmpMin.Y + 1;
  lpFaceInfo.LmpSquare:=lpFaceInfo.LmpSize.X*lpFaceInfo.LmpSize.Y;  

  // Normalize texture coordinatex
  for i:=0 to (lpFaceInfo.CountVertex - 1) do
    begin
      lpFaceInfo.LmpCoords[i].x:=(lpFaceInfo.TexCoords[i].x*inv16 - LmpMin.X + 0.5)/(lpFaceInfo.LmpSize.X);
      lpFaceInfo.LmpCoords[i].y:=(lpFaceInfo.TexCoords[i].y*inv16 - LmpMin.Y + 0.5)/(lpFaceInfo.LmpSize.Y); //}
    end;

  lpFaceInfo.OffsetLmp:=lpFace.nLightmapOffset;
  if (lpFaceInfo.OffsetLmp >= 0) then lpFaceInfo.OffsetLmp:=lpFaceInfo.OffsetLmp div SizeOfRGB888;

  // how much we can read lightmaps pages? from min 0 to max 4 pages
  lpFaceInfo.CountLightStyles:=0;
  if (lpFace.nStyles[0] <> $FF) then Inc(lpFaceInfo.CountLightStyles);
  if ((lpFace.nStyles[1] <> $FF) and (lpFace.nStyles[1] <> $00)) then Inc(lpFaceInfo.CountLightStyles);
  if ((lpFace.nStyles[2] <> $FF) and (lpFace.nStyles[2] <> $00)) then Inc(lpFaceInfo.CountLightStyles);
  if ((lpFace.nStyles[3] <> $FF) and (lpFace.nStyles[3] <> $00)) then Inc(lpFaceInfo.CountLightStyles);

  // Unpack Lightmaps, create Render Textures
  for i:=0 to (lpFaceInfo.CountLightStyles - 1) do
    begin
      lpFaceInfo.lpFirstLightmap[i]:=@Map.LightingLump[lpFaceInfo.OffsetLmp + i*lpFaceInfo.LmpSquare];
      SetLength(lpFaceInfo.Lightmaps[i], lpFaceInfo.LmpSquare);
      //
      CopyBytes(
        PByte(lpFaceInfo.lpFirstLightmap[i]),
        PByte(@lpFaceInfo.Lightmaps[i][0]),
        lpFaceInfo.LmpSquare*SizeOfRGB888
      );

      lpFaceInfo.lpFirstLightmap[i]:=@lpFaceInfo.Lightmaps[i][0];
      UpdateFaceUniqueLightmaps(lpFaceInfo, i);
      CreateLightmapTexture(lpFaceInfo, i);
      Inc(Map.CountUnpackedLightmaps, lpFaceInfo.LmpSquare);
    end;
  {$R+}
end;

procedure UpdateBrushFaceIndex(const Map: PMapBSP);
var
  lpBrush: PBrushModel;
  i, j: Integer;
begin
  {$R-}
  if (Map.CountBrushModels = 1) then Exit;
  for i:=1 to Map.CountBrushModels-1 do
    begin
      lpBrush:=@Map.ModelLump[i];
      if (lpBrush.nFaces <= 0) then continue;
      for j:=0 to Map.CountFaces-1 do
        begin
          if ((j >= lpBrush.iFirstFace) and (j < (lpBrush.iFirstFace + lpBrush.nFaces)))
            then Map.FaceInfos[j].BrushId:=i;
        end;
    end;
  {$R+}
end;

procedure UpdateVisLeafFaceIndex(const Map: PMapBSP);
var
  lpVisLeafInfo: PVisLeafInfo;
  i, j, k: Integer;
begin
  {$R-}
  if (Map.CountLeafs = 1) then Exit;
  for i:=1 to Map.CountLeafs-1 do
    begin
      lpVisLeafInfo:=@Map.VisLeafInfos[i];
      if (lpVisLeafInfo.CountFaces <= 0) then continue;
      for j:=0 to lpVisLeafInfo.CountFaces-1 do
        begin
          for k:=0 to Map.CountFaces-1 do
            if (k = lpVisLeafInfo.FaceIndexes[j]) then
              Map.FaceInfos[k].VisLeafId:=i;
        end;
    end;
  {$R+}
end;

procedure UpDateVisLeafInfo(const Map: PMapBSP; const VisLeafId: Integer);
var
  lpVisLeaf: PVisLeaf;
  lpVisLeafInfo: PVisLeafInfo;
  i: Integer;
begin
  {$R-}
  lpVisLeaf:=@Map.LeafLump[VisLeafId];
  lpVisLeafInfo:=@Map.VisLeafInfos[VisLeafId];

  // Get Final Faces Indecies
  lpVisLeafInfo.CountFaces:=lpVisLeaf.nMarkSurfaces;
  SetLength(lpVisLeafInfo.FaceIndexes, lpVisLeafInfo.CountFaces);
  for i:=0 to (lpVisLeafInfo.CountFaces - 1) do
    begin
      lpVisLeafInfo.FaceIndexes[i]:=Map.MarkSurfaceLump[lpVisLeaf.iFirstMarkSurface + i];
    end;

  // Get Final PVS Data
  lpVisLeafInfo.CountPVS:=0;
  SetLength(lpVisLeafInfo.PVS, 0);
  if ((lpVisLeaf.nVisOffset >= 0) and (VisLeafId <> 0)) then
    begin
      lpVisLeafInfo.CountPVS:=Map.CountVisLeafWithPVS;
      UnPackPVS(@Map.PackedVisibility[lpVisLeaf.nVisOffset], lpVisLeafInfo.PVS,
        Map.CountVisLeafWithPVS, Map.SizePackedVisibility);
    end; //}

  // Get BBOXf
  lpVisLeafInfo.BBOXf.vMin.x:=lpVisLeaf.nMin.x;
  lpVisLeafInfo.BBOXf.vMin.y:=lpVisLeaf.nMin.y;
  lpVisLeafInfo.BBOXf.vMin.z:=lpVisLeaf.nMin.z;
  lpVisLeafInfo.BBOXf.vMax.x:=lpVisLeaf.nMax.x;
  lpVisLeafInfo.BBOXf.vMax.y:=lpVisLeaf.nMax.y;
  lpVisLeafInfo.BBOXf.vMax.z:=lpVisLeaf.nMax.z;

  // Get BBOXs
  lpVisLeafInfo.BBOXs.nMin:=lpVisLeaf.nMin;
  lpVisLeafInfo.BBOXs.nMax:=lpVisLeaf.nMax;

  // Get Size BBOXf
  GetSizeBBOXf(lpVisLeafInfo.BBOXf, @lpVisLeafInfo.SizeBBOXf);
  {$R+}
end;

procedure UpdateVisLeafEntBrushes(const Map: PMapBSP; const VisLeafId: Integer);
var
  lpVisLeafInfo: PVisLeafInfo;
  i, j, k, n: Integer;
begin
  {$R-}
  if (VisLeafId = 0) then Exit;
  lpVisLeafInfo:=@Map.VisLeafInfos[VisLeafId];

  lpVisLeafInfo.CountBrushFace:=0;
  j:=0;
  for i:=1 to (Map.CountBrushModels - 1) do
    begin
      if (TestIntersectionTwoBBOX(lpVisLeafInfo.BBOXf, Map.ModelInfos[i].BBOXf)) then
        begin
          n:=Map.ModelLump[i].nFaces;
          Inc(j, n);
          SetLength(lpVisLeafInfo.BrushFaceIndexes, j);

          for k:=0 to (n - 1) do
            begin
              lpVisLeafInfo.BrushFaceIndexes[j - n + k]:=Map.ModelLump[i].iFirstFace + k;
            end;
        end;
    end;
  lpVisLeafInfo.CountBrushFace:=j;
  {$R+}
end;

function UnPackPVS(const PackedPVS: AByte; var UnPackedPVS: AByteBool;
  const CountPVS, PackedSize: Integer): Integer;
var
  i, j: Integer;
begin
  {$R-}
  Result:=0;
  SetLength(UnPackedPVS, Result);

  i:=0;
  while ((i < PackedSize) and (Result <= CountPVS))do
    begin
      if (PackedPVS[i] = 0) then
        begin
          // UnPack data
          Inc(i);
          j:=0;
          while (j < PackedPVS[i]) do
            begin
              Inc(Result, 8);
              SetLength(UnPackedPVS, Result);
              UnPackedPVS[Result-1]:=ByteBool(False);
              UnPackedPVS[Result-2]:=ByteBool(False);
              UnPackedPVS[Result-3]:=ByteBool(False);
              UnPackedPVS[Result-4]:=ByteBool(False);
              UnPackedPVS[Result-5]:=ByteBool(False);
              UnPackedPVS[Result-6]:=ByteBool(False);
              UnPackedPVS[Result-7]:=ByteBool(False);
              UnPackedPVS[Result-8]:=ByteBool(False);
              Inc(j);
            end;
        end
      else
        begin
          // No need UnPack
          Inc(Result, 8);
          SetLength(UnPackedPVS, Result);
          UnPackedPVS[Result-1]:=ByteBool(((PackedPVS[i] shr 7) and $01) <> 0);
          UnPackedPVS[Result-2]:=ByteBool(((PackedPVS[i] shr 6) and $01) <> 0);
          UnPackedPVS[Result-3]:=ByteBool(((PackedPVS[i] shr 5) and $01) <> 0);
          UnPackedPVS[Result-4]:=ByteBool(((PackedPVS[i] shr 4) and $01) <> 0);
          UnPackedPVS[Result-5]:=ByteBool(((PackedPVS[i] shr 3) and $01) <> 0);
          UnPackedPVS[Result-6]:=ByteBool(((PackedPVS[i] shr 2) and $01) <> 0);
          UnPackedPVS[Result-7]:=ByteBool(((PackedPVS[i] shr 1) and $01) <> 0);
          UnPackedPVS[Result-8]:=ByteBool((PackedPVS[i] and $01) <> 0);
        end;
      Inc(i);
    end;

  SetLength(UnPackedPVS, CountPVS);
  {$R+}
end;

procedure UpDateNodeInfo(const Map: PMapBSP; const NodeInfoId: Integer);
var
  lpNode: PNode;
  lpNodeInfo: PNodeInfo;
begin
  {$R-}
  lpNode:=@Map.NodeLump[NodeInfoId];
  lpNodeInfo:=@Map.NodeInfos[NodeInfoId];

  // UpDate Plane Info
  lpNodeInfo.Plane:=Map.PlaneLump[lpNode.iPlane];

  // UpDate BBOXf
  lpNodeInfo.BBOXf.vMin.x:=lpNode.nMin.x;
  lpNodeInfo.BBOXf.vMin.y:=lpNode.nMin.y;
  lpNodeInfo.BBOXf.vMin.z:=lpNode.nMin.z;
  lpNodeInfo.BBOXf.vMax.x:=lpNode.nMax.x;
  lpNodeInfo.BBOXf.vMax.y:=lpNode.nMax.y;
  lpNodeInfo.BBOXf.vMax.z:=lpNode.nMax.z;

  lpNodeInfo.BBOXs.nMin:=lpNode.nMin;
  lpNodeInfo.BBOXs.nMax:=lpNode.nMax;

  // Update Front Child
  if isLeafChildrenId0(lpNode) then
    begin
      lpNodeInfo.IsFrontNode:=False;
      lpNodeInfo.FrontIndex:=GetIndexLeafChildrenId0(lpNode);
      lpNodeInfo.lpFrontLeafInfo:=@Map.VisLeafInfos[lpNodeInfo.FrontIndex];
    end
  else
    begin
      lpNodeInfo.IsFrontNode:=True;
      lpNodeInfo.FrontIndex:=lpNode.iChildren[0];
      lpNodeInfo.lpFrontNodeInfo:=@Map.NodeInfos[lpNodeInfo.FrontIndex];
    end;

  // UpDate Back Child
  if isLeafChildrenId1(lpNode) then
    begin
      lpNodeInfo.IsBackNode:=False;
      lpNodeInfo.BackIndex:=GetIndexLeafChildrenId1(lpNode);
      lpNodeInfo.lpBackLeafInfo:=@Map.VisLeafInfos[lpNodeInfo.BackIndex];
    end
  else
    begin
      lpNodeInfo.IsBackNode:=True;
      lpNodeInfo.BackIndex:=lpNode.iChildren[1];
      lpNodeInfo.lpBackNodeInfo:=@Map.NodeInfos[lpNodeInfo.BackIndex];
    end;
  {$R+}
end;

function GetLeafIndexByPoint(const NodeInfos: ANodeInfo; const Point: tVec3f;
  const RootIndex: Integer): Integer;
var
  lpNodeInfo: PNodeInfo;
begin
  {$R-}
  Result:=0;
  lpNodeInfo:=@NodeInfos[RootIndex];

  // Walk in Binary Tree
  while (TestPointInBBOX(lpNodeInfo.BBOXf, Point)) do
    begin
      if (isPointInFrontPlaneSpace(@lpNodeInfo.Plane, Point)) then
        begin
          // Front plane part + Point on plane
          if (lpNodeInfo.IsFrontNode) then
            begin
              // Next Front Child is Node
              lpNodeInfo:=lpNodeInfo.lpFrontNodeInfo;
            end
          else
            begin
              // Next Front Child is Leaf
              Result:=lpNodeInfo.FrontIndex;
              Exit;
            end;
        end
      else
        begin
          // Back plane part
          if (lpNodeInfo.IsBackNode) then
            begin
              // Next Back Child is Node
              lpNodeInfo:=lpNodeInfo.lpBackNodeInfo;
            end
          else
            begin
              // Next Back Child is Leaf
              Result:=lpNodeInfo.BackIndex;
              Exit;
            end;
        end;
    end;
  {$R+}
end;

procedure UpDateEntityInfo(const Map: PMapBSP; const EntityId: Integer);
var
  lpEntity: PEntity;
  tmpStr: String;
  i: Integer;
  isHaveOrigin: Boolean;
  //
  lpModel: PBrushModel;
  lpModelInfo: PBrushModelInfo;
begin
  {$R-}
  lpEntity:=@Map.Entities[EntityId];

  // UpDate VisLeaf Id
  tmpStr:='';
  lpEntity.VisLeaf:=0;
  isHaveOrigin:=False;
  lpEntity.Origin:=VEC_ZERO;
  lpEntity.Angles:=VEC_ZERO;
  for i:=0 to lpEntity.CountPairs-1 do
    begin
      if (lpEntity.Pairs[i].Key = 'origin') then
        begin
          tmpStr:=lpEntity.Pairs[i].Value;
          isHaveOrigin:=True;
        end;
    end;
  if (StrToVec(tmpStr, @lpEntity.Origin)) then
    begin
      lpEntity.VisLeaf:=GetLeafIndexByPoint(Map.NodeInfos, lpEntity.Origin, Map.RootIndex);
    end;

  tmpStr:='';
  for i:=0 to lpEntity.CountPairs-1 do
    begin
      if (lpEntity.Pairs[i].Key = 'angles') then
        begin
          tmpStr:=lpEntity.Pairs[i].Value;
        end;
    end;
  StrToVec(tmpStr, @lpEntity.Angles);

  // Update BrushModel Id
  lpEntity.BrushModel:=-1;
  tmpStr:='';
  for i:=0 to lpEntity.CountPairs-1 do
    begin
      if (lpEntity.Pairs[i].Key = 'model') then
        tmpStr:=lpEntity.Pairs[i].Value;
    end;
  if (tmpStr <> '') then
    if (tmpStr[1] = '*') then
      begin
        Delete(tmpStr, 1, 1);
        lpEntity.BrushModel:=StrToIntDef(tmpStr, -1);

        if (lpEntity.BrushModel > 0) then
          begin
            lpModel:=@Map.ModelLump[lpEntity.BrushModel];
            lpModelInfo:=@Map.ModelInfos[lpEntity.BrushModel];

            lpModelInfo.EntityId:=EntityId;
            lpModelInfo.isBrushWithEntityOrigin:=isHaveOrigin;
            lpModelInfo.Origin:=lpEntity.Origin;

            if (isHaveOrigin = False) then
              begin
                GetOriginByBBOX(lpModelInfo.BBOXf, @lpEntity.Origin);
                lpEntity.VisLeaf:=GetLeafIndexByPoint(Map.NodeInfos, lpEntity.Origin, Map.RootIndex);
                lpModelInfo.Origin:=lpEntity.Origin;
              end
            else
              begin
                TranslateBBOXf(lpModelInfo.BBOXf, lpEntity.Origin);
                for i:=lpModel.iFirstFace to (lpModel.nFaces + lpModel.iFirstFace - 1) do
                  begin
                    TranslateVertexArray(
                      @Map.FaceInfos[i].Vertex[0],
                      @lpEntity.Origin,
                      Map.FaceInfos[i].CountVertex
                    );
                  end;
              end;
          end;
      end;
  {$R+}
end;

end.
