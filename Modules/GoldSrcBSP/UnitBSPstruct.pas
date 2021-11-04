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
  UnitUserTypes,
  UnitVec,
  UnitEntity,
  UnitPlane,
  UnitTexture,
  UnitMapHeader,
  UnitNode,
  UnitFace,
  UnitClipNode,
  UnitVisLeaf,
  UnitMarkSurface,
  UnitEdge,
  UnitBrushModel,
  UnitLightEntity;


type eLoadMapErrors = (
    erNoErrors = 0,
    erFileNotExists,
    erMinSize,
    erBadVersion,
    erBadEOFbyHeader,
    erNoEntData,
    erNoPlanes,
    erNoTextures,
    erNoVertex,
    erNoNodes,
    erNoTexInfos,
    erNoFaces,
    erNoLeaf,
    erNoMarkSurface,
    erNoEdge,
    erNoSurfEdge,
    erNoBrushes,
    erNoPVS
  );

type tMapBSP = record
    LoadState: eLoadMapErrors;
    MapHeader: tMapHeader;

    SizeEndData: Integer;
    EntDataLump: String; // Null-terminated dynamic array of AnsiChar's
    CountEntities: Integer;
    Entities: AEntity;

    CountLightStyles: Integer;
    LightStylesList: ALightStylePair;
    CountLightEntities: Integer;
    LightEntityList: ALightEntity;

    PlaneLump: APlaneBSP;
    CountPlanes: Integer;

    TextureLump: tTextureLump;

    VertexLump: AVec3f;
    CountVertices: Integer;

    PackedVisibility: AByte;
    SizePackedVisibility: Integer;
    CountVisLeafWithPVS: Integer;

    NodeExtList: ANodeExt;
    CountNodes: Integer;
    RootNodeIndex: Integer;

    TexInfoLump: ATexInfo;
    CountTexInfos: Integer;

    FaceExtList: AFaceExt;
    CountFaces: Integer;
    MaxVerteciesPerFace: Integer;
    AvgVerteciesPerFace: Integer;

    LightingLump: ARGB888;
    CountPackedLightmaps: Integer;

    ClipNodeExtList: AClipNodeExt;
    CountClipNodes: Integer;
    RootClipNodeIndex: array[0..2] of Integer;

    VisLeafExtList: AVisLeafExt;
    CountLeafs: Integer;

    MarkSurfaceLump: AMarkSurface;
    CountMarkSurfaces: Integer;

    EdgeIndexLump: AEdgeIndex;
    CountEdgeIndexes: Integer;

    SurfEdgeLump: ASurfEdge;
    CountSurfEdges: Integer;

    BrushModelExtList: ABrushModelExt;
    CountBrushModels: Integer;
    MapBBOX: tBBOXf;
    MapBBOXSize: tVec3f;
  end;
type PMapBSP = ^tMapBSP;


procedure FreeMapBSP(const Map: PMapBSP);
procedure SetZerosLumpSize(const Map: PMapBSP);

procedure SaveBSP30ToFile(const FileName: String; const Map: PMapBSP);
function LoadBSP30FromFile(const FileName: String; const Map: PMapBSP): boolean;
function ShowLoadBSPMapError(const LoadMapErrorType: eLoadMapErrors): String;

procedure UpdateFaceExt(const Map: PMapBSP; const FaceId: Integer);
procedure UpdateBrushModelExt(const Map: PMapBSP; const BrushModelId: Integer);
procedure UpdateVisLeafExt(const Map: PMapBSP; const VisLeafId: Integer);
procedure UpdateNodeExt(const Map: PMapBSP; const NodeId: Integer);
procedure UpdateClipNodeExt(const Map: PMapBSP; const ClipNodeId: Integer);
procedure UpdateEntityExt(const Map: PMapBSP; const EntityId: Integer);
procedure UpdateEntityLight(const Map: PMapBSP);


implementation


procedure FreeMapBSP(const Map: PMapBSP);
var
  i: Integer;
begin
  {$R-}
  Map.SizeEndData:=0;
  Map.EntDataLump:='';
  Map.CountEntities:=0;
  SetLength(Map.Entities, 0);

  for i:=0 to (Map.CountLightStyles - 1) do
    begin
      FreeLightStylePair(@Map.LightStylesList[i]);
    end;
  SetLength(Map.LightStylesList, 0);
  Map.CountLightStyles:=0;

  for i:=0 to (Map.CountLightEntities - 1) do
    begin
      FreeLightEntity(@Map.LightEntityList[i]);
    end;   
  SetLength(Map.LightEntityList, 0);
  Map.CountLightEntities:=0;

  Map.CountPlanes:=0;
  SetLength(Map.PlaneLump, 0);

  SetLength(Map.TextureLump.OffsetsToTexture, 0);
  for i:=0 to (Map.TextureLump.nCountTextures - 1) do
    begin
      FreeTextureAndPalette(Map.TextureLump.Wad3Textures[i]);
    end;
  SetLength(Map.TextureLump.Wad3Textures, 0);
  Map.TextureLump.nCountTextures:=0;

  Map.CountVertices:=0;
  SetLength(Map.VertexLump, 0);

  Map.SizePackedVisibility:=0;
  Map.CountVisLeafWithPVS:=0;
  SetLength(Map.PackedVisibility, 0);

  Map.CountNodes:=0;
  SetLength(Map.NodeExtList, 0);

  Map.CountTexInfos:=0;
  SetLength(Map.TexInfoLump, 0);

  for i:=0 to (Map.CountFaces - 1) do
    begin
      FreeFaceExt(@Map.FaceExtList[i]);
    end;
  SetLength(Map.FaceExtList, 0);
  Map.CountFaces:=0;
  Map.MaxVerteciesPerFace:=0;
  Map.AvgVerteciesPerFace:=0;
  
  Map.CountPackedLightmaps:=0;
  SetLength(Map.LightingLump, 0);

  SetLength(Map.ClipNodeExtList, 0);
  Map.CountClipNodes:=0;

  for i:=0 to (Map.CountLeafs - 1) do
    begin
      FreeVisLeafExt(@Map.VisLeafExtList[i]);
    end;
  SetLength(Map.VisLeafExtList, 0);
  Map.CountLeafs:=0;

  Map.CountMarkSurfaces:=0;
  SetLength(Map.MarkSurfaceLump, 0);

  Map.CountEdgeIndexes:=0;
  SetLength(Map.EdgeIndexLump, 0);

  Map.CountSurfEdges:=0;
  SetLength(Map.SurfEdgeLump, 0);

  for i:=0 to (Map.CountBrushModels - 1) do
    begin
      FreeBrushModelExt(@Map.BrushModelExtList[i]);
    end;
  SetLength(Map.BrushModelExtList, 0);
  Map.CountBrushModels:=0;
  {$R+}
end;

procedure SetZerosLumpSize(const Map: PMapBSP);
begin
  {$R-}
  with Map^, MapHeader do
    begin
      SizeEndData:=             0;
      CountPlanes:=             0;
      CountVertices:=           0;
      SizePackedVisibility:=    0;
      CountNodes:=              0;
      CountTexInfos:=           0;
      CountFaces:=              0;
      CountPackedLightmaps:=    0;
      CountLeafs:=              0;
      CountMarkSurfaces:=       0;
      CountEdgeIndexes:=        0;
      CountSurfEdges:=          0;
      CountBrushModels:=        0;
      CountClipNodes:=          0;
    end;
  {$R+}
end;

procedure SaveBSP30ToFile(const FileName: String; const Map: PMapBSP);
const
  PaddingByte: Byte = 0;
var
  i, j: Integer;
  CurrentFileOffset: Integer;
  MapFile: File;
  //
  //lpFaceInfo: PFaceInfo;
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
  Map.MapHeader.LumpsInfo[LUMP_PLANES].nLength:=Map.CountPlanes*SizeOf(tPlaneBSP);
  //
  BlockWrite(MapFile, (@Map.PlaneLump[0])^, Map.MapHeader.LumpsInfo[LUMP_PLANES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_PLANES].nLength);
  // SizeOfPlane = 20 bytes, multiple by 4, dont need add padding


  // Save VisLeaf lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_LEAVES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_LEAVES].nLength:=Map.CountLeafs*SizeOf(tVisLeaf);
  //
  for i:=0 to (Map.CountLeafs - 1) do
    begin
      BlockWrite(MapFile, (@Map.VisLeafExtList[i].BaseLeaf)^, SizeOf(tVisLeaf));
    end;
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_LEAVES].nLength);
  // SizeOfVisLeaf = 28 bytes, multiple by 4, dont need add padding


  // Save Vertex lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_VERTICES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_VERTICES].nLength:=Map.CountVertices*SizeOf(tVec3f);
  //
  BlockWrite(MapFile, (@Map.VertexLump[0])^, Map.MapHeader.LumpsInfo[LUMP_VERTICES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_VERTICES].nLength);
  // SizeOfVec3f = 12 bytes, multiple by 4, dont need add padding


  // Save Node lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_NODES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_NODES].nLength:=Map.CountNodes*SizeOf(tNode);
  //
  for i:=0 to (Map.CountNodes - 1) do
    begin
      BlockWrite(MapFile, (@Map.NodeExtList[i].BaseNode)^, SizeOf(tNode));
    end;
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_NODES].nLength);
  // SizeOfVec3f = 24 bytes, multiple by 4, dont need add padding


  // Save TexInfo lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nLength:=Map.CountTexInfos*SizeOf(tTexInfo);
  //
  BlockWrite(MapFile, (@Map.TexInfoLump[0])^, Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nLength);
  // SizeOfTexInfo = 40 bytes, multiple by 4, dont need add padding


  // Generate Lightmap Lump and Face lightmap offsets
  Map.CountPackedLightmaps:=0;
  for i:=0 to (Map.CountFaces - 1) do
    begin
      if (Map.FaceExtList[i].isDummyLightmaps) then Continue;
      Inc(Map.CountPackedLightmaps, Map.FaceExtList[i].CountLightmaps);
    end;
  SetLength(Map.LightingLump, Map.CountPackedLightmaps);
  j:=0; // Current lightmap offset in LightingLump array
  for i:=0 to (Map.CountFaces - 1) do
    begin
      if (Map.FaceExtList[i].isDummyLightmaps) then
        begin
          Map.FaceExtList[i].BaseFace.nLightmapOffset:=-1;
          Continue;
        end;
      //
      Map.FaceExtList[i].BaseFace.nLightmapOffset:=j*SizeOf(tRGB888);
      CopyBytes(
        @Map.FaceExtList[i].Lightmaps[0],
        @Map.LightingLump[j],
        Map.FaceExtList[i].CountLightmaps*SizeOf(tRGB888)
      );
      //
      Inc(j, Map.FaceExtList[i].CountLightmaps);
    end;

  // Save Face Lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_FACES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_FACES].nLength:=Map.CountFaces*SizeOf(tFace);
  //
  for i:=0 to (Map.CountFaces - 1) do
    begin
      BlockWrite(MapFile, (@Map.FaceExtList[i].BaseFace)^, SizeOf(tFace));
    end;
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_FACES].nLength);
  // SizeOfFace = 20 bytes, multiple by 4, dont need add padding


  // Save ClipNode lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_CLIPNODES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_CLIPNODES].nLength:=Map.CountClipNodes*SizeOf(tClipNode);
  //
  for i:=0 to (Map.CountClipNodes - 1) do
    begin
      BlockWrite(MapFile, (@Map.ClipNodeExtList[i].BaseClipNode)^, SizeOf(tClipNode));
    end;
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_CLIPNODES].nLength);
  // SizeOfClipNodes = 8 bytes, multiple by 4, dont need add padding


  // Save MarkSurface lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength:=Map.CountMarkSurfaces*SizeOf(tMarkSurface);
  //
  BlockWrite(MapFile, (@Map.MarkSurfaceLump[0])^, Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength);
  // SizeOfMarkSurface = 2 bytes, don't multiple by 4, need add padding
  //
  j:=0; // use this variable as padding fill value
  if ((Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength mod 4) <> 0) then
    begin
      Seek(MapFile, CurrentFileOffset);
      BlockWrite(MapFile, (@j)^, 2);
      Inc(CurrentFileOffset, 2);
    end;


  // Save SurfEdge lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nLength:=Map.CountSurfEdges*SizeOf(tSurfEdge);
  //
  BlockWrite(MapFile, (@Map.SurfEdgeLump[0])^, Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nLength);
  // SizeOfSurfEdge = 4 bytes, multiple by 4, dont need add padding


  // Save Edge lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_EDGES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength:=Map.CountEdgeIndexes*SizeOf(tEdgeIndex);
  //
  BlockWrite(MapFile, (@Map.EdgeIndexLump[0])^, Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength);
  // SizeOfEdgeIndex = 4 bytes, multiple by 4, dont need add padding


  // Save Brush Model lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nLength:=Map.CountBrushModels*SizeOf(tBrushModel);
  //
  for i:=0 to (Map.CountBrushModels - 1) do
    begin
      BlockWrite(MapFile, (@Map.BrushModelExtList[i].BaseBModel)^, SizeOf(tBrushModel));
    end;
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nLength);
  // SizeOfBrushModel = 64 bytes, multiple by 4, dont need add padding


  // Save Lightmap lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nOffset:=CurrentFileOffset;
  Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength:=Map.CountPackedLightmaps*SizeOf(tRGB888);
  //
  BlockWrite(MapFile, (@Map.LightingLump[0])^, Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength);
  Inc(CurrentFileOffset, Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength);
  //
  // SizeOfRGB888 = 3 bytes, don't multiple by 4, need add padding
  //
  j:=0; // use this variable as padding fill value
  i:=(Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength mod 4);
  if (i <> 0) then
    begin
      Seek(MapFile, CurrentFileOffset);
      BlockWrite(MapFile, (@j)^, 4 - i);
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
  j:=0; // use this variable as padding fill value
  i:=(Map.SizePackedVisibility mod 4);
  if (i <> 0) then
    begin
      Seek(MapFile, CurrentFileOffset);
      BlockWrite(MapFile, (@j)^, 4 - i);
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
  j:=0; // use this variable as padding fill value
  i:=(Map.SizeEndData mod 4);
  if (i <> 0) then
    begin
      Seek(MapFile, CurrentFileOffset);
      BlockWrite(MapFile, (@j)^, 4 - i);
      Inc(CurrentFileOffset, 4 - i);
    end;


  // Save Texutre lump
  Seek(MapFile, CurrentFileOffset);
  Map.MapHeader.LumpsInfo[LUMP_TEXTURES].nOffset:=CurrentFileOffset;
  //
  ZeroFillDWORD(@Map.TextureLump.OffsetsToTexture[0], Map.TextureLump.nCountTextures*SizeOf(Integer));
  BlockWrite(MapFile, Map.TextureLump.nCountTextures, SizeOf(Integer));
  BlockWrite(MapFile, (@Map.TextureLump.OffsetsToTexture[0])^,
    Map.TextureLump.nCountTextures*SizeOf(Integer)
  ); // first dummy write

  // Save Textures
  for i:=0 to (Map.TextureLump.nCountTextures - 1) do
    begin
      Map.TextureLump.OffsetsToTexture[i]:=FileSize(MapFile) - CurrentFileOffset;
      BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i])^, MIPTEX_SIZE);

      if (Map.TextureLump.Wad3Textures[i].nOffsets[0] = MIPTEX_SIZE) then
        begin
          // Save Pixel-Index Data
          BlockWrite(MapFile, (Map.TextureLump.Wad3Textures[i].MipData[0])^, Map.TextureLump.Wad3Textures[i].MipSize[0]);
          BlockWrite(MapFile, (Map.TextureLump.Wad3Textures[i].MipData[1])^, Map.TextureLump.Wad3Textures[i].MipSize[1]);
          BlockWrite(MapFile, (Map.TextureLump.Wad3Textures[i].MipData[2])^, Map.TextureLump.Wad3Textures[i].MipSize[2]);
          BlockWrite(MapFile, (Map.TextureLump.Wad3Textures[i].MipData[3])^, Map.TextureLump.Wad3Textures[i].MipSize[3]);
          // Save Palette
          BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i].PaletteColors)^, SizeOf(Word));
          BlockWrite(MapFile, (Map.TextureLump.Wad3Textures[i].Palette)^,
            Map.TextureLump.Wad3Textures[i].PaletteColors*SizeOf(tRGB888));
          // Add padding
          BlockWrite(MapFile, (@Map.TextureLump.Wad3Textures[i].Padding)^, SizeOf(Word));
        end;
    end;
  Map.MapHeader.LumpsInfo[LUMP_TEXTURES].nLength:=FileSize(MapFile) - CurrentFileOffset;
  //
  Seek(MapFile, CurrentFileOffset + SizeOf(Integer));
  BlockWrite(MapFile, (@Map.TextureLump.OffsetsToTexture[0])^,
    Map.TextureLump.nCountTextures*SizeOf(Integer)
  );

  // Save Map Header
  Seek(MapFile, 0);
  BlockWrite(MapFile, Map.MapHeader, MAP_HEADER_SIZE);
  
  // Make file size multiple by 4
  j:=0; // use this variable as padding fill value
  i:=(FileSize(MapFile) mod 4);
  if (i <> 0) then
    begin
      Seek(MapFile, FileSize(MapFile));
      BlockWrite(MapFile, (@j)^, 4 - i);
    end;

  CloseFile(MapFile);
  {$R+}
end;

function LoadBSP30FromFile(const FileName: String; const Map: PMapBSP): boolean;
var
  i, MapFileSize: Integer;
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
  Map.SizeEndData:=           Map.MapHeader.LumpsInfo[LUMP_ENTITIES].nLength;
  Map.CountPlanes:=           Map.MapHeader.LumpsInfo[LUMP_PLANES].nLength div SizeOf(tPlaneBSP);
  Map.CountVertices:=         Map.MapHeader.LumpsInfo[LUMP_VERTICES].nLength div SizeOf(tVec3f);
  Map.SizePackedVisibility:=  Map.MapHeader.LumpsInfo[LUMP_VISIBILITY].nLength;
  Map.CountNodes:=            Map.MapHeader.LumpsInfo[LUMP_NODES].nLength div SizeOf(tNode);
  Map.CountTexInfos:=         Map.MapHeader.LumpsInfo[LUMP_TEXINFO].nLength div SizeOf(tTexInfo);
  Map.CountFaces:=            Map.MapHeader.LumpsInfo[LUMP_FACES].nLength div SizeOf(tFace);
  Map.CountPackedLightmaps:=  Map.MapHeader.LumpsInfo[LUMP_LIGHTING].nLength div SizeOf(tRGB888);
  Map.CountLeafs:=            Map.MapHeader.LumpsInfo[LUMP_LEAVES].nLength div SizeOf(tVisLeaf);
  Map.CountMarkSurfaces:=     Map.MapHeader.LumpsInfo[LUMP_MARKSURFACES].nLength div SizeOf(tMarkSurface);
  Map.CountEdgeIndexes:=      Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength div SizeOf(tEdgeIndex);
  Map.CountSurfEdges:=        Map.MapHeader.LumpsInfo[LUMP_SURFEDGES].nLength div SizeOf(tSurfEdge);
  Map.CountBrushModels:=      Map.MapHeader.LumpsInfo[LUMP_BRUSHES].nLength div SizeOf(tBrushModel);
  Map.CountClipNodes:=        Map.MapHeader.LumpsInfo[LUMP_CLIPNODES].nLength div SizeOf(tClipNode);

  //////////////////////////////////////////////////////////////////////////////
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
      // UpDate Planes
      for i:=0 to (Map.CountPlanes - 1) do
        begin
          Map.PlaneLump[i].AxisType:=GetPlaneTypeByNormal(Map.PlaneLump[i].vNormal);
        end;
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
      SetLength(Map.TextureLump.OffsetsToTexture, Map.TextureLump.nCountTextures);
      BlockRead(MapFile, (@Map.TextureLump.OffsetsToTexture[0])^, Map.TextureLump.nCountTextures*SizeOf(Integer));
      //
      SetLength(Map.TextureLump.Wad3Textures, Map.TextureLump.nCountTextures);

      for i:=0 to (Map.TextureLump.nCountTextures - 1) do
        begin
          BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i])^, MIPTEX_SIZE);
          Map.TextureLump.Wad3Textures[i].szName[15]:=#0; // just protect ourselves

          Map.TextureLump.Wad3Textures[i].MipData[0]:=nil;
          if (Map.TextureLump.Wad3Textures[i].nOffsets[0] = MIPTEX_SIZE) then
            begin
              AllocTexture(Map.TextureLump.Wad3Textures[i]);
              // Read Pixel-Index Data
              BlockRead(MapFile, (Map.TextureLump.Wad3Textures[i].MipData[0])^, Map.TextureLump.Wad3Textures[i].MipSize[0]);
              BlockRead(MapFile, (Map.TextureLump.Wad3Textures[i].MipData[1])^, Map.TextureLump.Wad3Textures[i].MipSize[1]);
              BlockRead(MapFile, (Map.TextureLump.Wad3Textures[i].MipData[2])^, Map.TextureLump.Wad3Textures[i].MipSize[2]);
              BlockRead(MapFile, (Map.TextureLump.Wad3Textures[i].MipData[3])^, Map.TextureLump.Wad3Textures[i].MipSize[3]);
              // Read Palette
              BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i].PaletteColors)^, SizeOf(Word));
              AllocPalette(Map.TextureLump.Wad3Textures[i]);
              BlockRead(MapFile, (Map.TextureLump.Wad3Textures[i].Palette)^,
                Map.TextureLump.Wad3Textures[i].PaletteColors*SizeOf(tRGB888));
              // Read Padding
              BlockRead(MapFile, (@Map.TextureLump.Wad3Textures[i].Padding)^, SizeOf(Word));
            end;
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
      SetLength(Map.NodeExtList, Map.CountNodes);
      for i:=0 to (Map.CountNodes - 1) do
        begin
          BlockRead(MapFile, (@Map.NodeExtList[i].BaseNode)^, SizeOf(tNode));
        end;
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
      SetLength(Map.FaceExtList, Map.CountFaces);
      for i:=0 to (Map.CountFaces - 1) do
        begin
          BlockRead(MapFile, (@Map.FaceExtList[i].BaseFace)^, SizeOf(tFace));
        end;
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
    end;

  // Read ClipNodes
  if (Map.CountClipNodes > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_CLIPNODES].nOffset);
      SetLength(Map.ClipNodeExtList, Map.CountClipNodes);
      for i:=0 to (Map.CountClipNodes - 1) do
        begin
          BlockRead(MapFile, (@Map.ClipNodeExtList[i].BaseClipNode)^, SizeOf(tClipNode));
        end;
    end;

  // Read VisLeaves
  if (Map.CountLeafs > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_LEAVES].nOffset);
      SetLength(Map.VisLeafExtList, Map.CountLeafs);
      for i:=0 to (Map.CountLeafs - 1) do
        begin
          BlockRead(MapFile, (@Map.VisLeafExtList[i].BaseLeaf)^, SizeOf(tVisLeaf));
        end;
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
  if (Map.CountEdgeIndexes > 0) then
    begin
      Seek(MapFile, Map.MapHeader.LumpsInfo[LUMP_EDGES].nOffset);
      SetLength(Map.EdgeIndexLump, Map.CountEdgeIndexes);
      BlockRead(MapFile, (@Map.EdgeIndexLump[0])^, Map.MapHeader.LumpsInfo[LUMP_EDGES].nLength);
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
      SetLength(Map.BrushModelExtList, Map.CountBrushModels);
      FreeBrushModelExt(@Map.BrushModelExtList[0]);
      for i:=0 to (Map.CountBrushModels - 1) do
        begin
          BlockRead(MapFile, (@Map.BrushModelExtList[i].BaseBModel)^, SizeOf(tBrushModel));
        end;

      // in any map must be one "zero's" BrushModel, that contain total info about map
      // And we can get count of VisLeafs that need in PVS data, for correct read PVS data
      Map.CountVisLeafWithPVS:=Map.BrushModelExtList[0].BaseBModel.nVisLeafs;
      Map.RootNodeIndex:=Map.BrushModelExtList[0].BaseBModel.iHull[0];
      Map.RootClipNodeIndex[0]:=Map.BrushModelExtList[0].BaseBModel.iHull[1];
      Map.RootClipNodeIndex[1]:=Map.BrushModelExtList[0].BaseBModel.iHull[2];
      Map.RootClipNodeIndex[2]:=Map.BrushModelExtList[0].BaseBModel.iHull[3];
      //
      Map.MapBBOX:=Map.BrushModelExtList[0].BaseBModel.BBOXf;
      Map.MapBBOXSize.x:=Map.MapBBOX.vMax.x - Map.MapBBOX.vMin.x;
      Map.MapBBOXSize.y:=Map.MapBBOX.vMax.y - Map.MapBBOX.vMin.y;
      Map.MapBBOXSize.z:=Map.MapBBOX.vMax.z - Map.MapBBOX.vMin.z;
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

  // Update Face Info
  Map.MaxVerteciesPerFace:=0;
  Map.AvgVerteciesPerFace:=0;
  for i:=0 to (Map.CountFaces - 1) do
    begin
      UpdateFaceExt(Map, i);
    end;
  Map.CountPackedLightmaps:=0;
  SetLength(Map.LightingLump, 0);

  // Create Binary Tree
  for i:=0 to (Map.CountLeafs - 1) do
    begin
      UpdateVisLeafExt(Map, i);
    end;
  for i:=0 to (Map.CountNodes - 1) do
    begin
      UpdateNodeExt(Map, i);
    end;

  // Update BrushModels
  for i:=1 to (Map.CountBrushModels - 1) do
    begin
      UpdateBrushModelExt(Map, i);
    end;

  // Update Eintities and set for each Face "Entity and BrushModel ID's"
  for i:=0 to (Map.CountEntities - 1) do
    begin
      UpdateEntityExt(Map, i);
    end;

  // Find and parse light entities and styles
  UpdateEntityLight(Map);

  // Update ClipNode Tree
  for i:=0 to (Map.CountClipNodes - 1) do
    begin
      UpdateClipNodeExt(Map, i);
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
    erNoPVS : Result:='Map File not have PVS lump';
  end;
  {$R+}
end;

procedure UpdateFaceExt(const Map: PMapBSP; const FaceId: Integer);
var
  lpFaceExt: PFaceExt;
  lpTexInfo: PTexInfo;
  i, EdgeIndex: Integer;
  LmpMin, LmpMax: TPoint;
  w, h: Integer;
  OffsetLmp: Integer;
begin
  {$R-}
  lpFaceExt:=@Map.FaceExtList[FaceId];
  FreeFaceExt(lpFaceExt);

  lpTexInfo:=@Map.TexInfoLump[lpFaceExt.BaseFace.iTextureInfo];
  lpFaceExt.Wad3TextureIndex:=lpTexInfo.iMipTex;
  lpFaceExt.TexName:=@Map.TextureLump.Wad3Textures[lpFaceExt.Wad3TextureIndex].szName;

  lpFaceExt.PlaneIndex:=lpFaceExt.BaseFace.iPlane;
  lpFaceExt.PlaneAxisType:=Map.PlaneLump[lpFaceExt.PlaneIndex].AxisType;
  lpFaceExt.Polygon.Plane.Normal:=Map.PlaneLump[lpFaceExt.PlaneIndex].vNormal;
  lpFaceExt.Polygon.Plane.Dist:=Map.PlaneLump[lpFaceExt.PlaneIndex].fDist;
  if (lpFaceExt.BaseFace.nPlaneSides <> 0) then
    begin
      lpFaceExt.Polygon.Plane.Normal.x:=-lpFaceExt.Polygon.Plane.Normal.x;
      lpFaceExt.Polygon.Plane.Normal.y:=-lpFaceExt.Polygon.Plane.Normal.y;
      lpFaceExt.Polygon.Plane.Normal.z:=-lpFaceExt.Polygon.Plane.Normal.z;
    end;

  lpFaceExt.Polygon.CountVertecies:=lpFaceExt.BaseFace.nSurfEdges;
  Inc(Map.AvgVerteciesPerFace, lpFaceExt.Polygon.CountVertecies);
  SetLength(lpFaceExt.Polygon.Vertecies, lpFaceExt.Polygon.CountVertecies);
  SetLength(lpFaceExt.TexCoords, lpFaceExt.Polygon.CountVertecies);
  SetLength(lpFaceExt.LmpCoords, lpFaceExt.Polygon.CountVertecies);

  if (lpFaceExt.Polygon.CountVertecies > Map.MaxVerteciesPerFace) then
    begin
      Map.MaxVerteciesPerFace:=lpFaceExt.Polygon.CountVertecies;
    end;

  lpFaceExt.BrushId:=0; // WorldBrush
  lpFaceExt.VisLeafId:=0; // Null Node

  // Get Vertecies
  for i:=0 to (lpFaceExt.BaseFace.nSurfEdges - 1) do
    begin
      EdgeIndex:=Map.SurfEdgeLump[lpFaceExt.BaseFace.iFirstSurfEdge + DWORD(i)];
      if (EdgeIndex >= 0) then
        begin
          lpFaceExt.Polygon.Vertecies[i]:=Map.VertexLump[Map.EdgeIndexLump[EdgeIndex].v0];
        end
      else
        begin
          lpFaceExt.Polygon.Vertecies[i]:=Map.VertexLump[Map.EdgeIndexLump[-EdgeIndex].v1];
        end;
    end;
  UpdatePolyEdges(@lpFaceExt.Polygon);

  // Get Vertecies textures coordinates
  for i:=0 to (lpFaceExt.Polygon.CountVertecies - 1) do
    begin
      GetTexureCoordST(lpFaceExt.Polygon.Vertecies[i], lpTexInfo^, lpFaceExt.TexCoords[i]);
    end;
  GetTexBBOX(lpFaceExt.TexCoords, @lpFaceExt.TexBBOX, lpFaceExt.Polygon.CountVertecies);

  
  OffsetLmp:=lpFaceExt.BaseFace.nLightmapOffset;
  if (OffsetLmp >= 0) then
    begin
      OffsetLmp:=OffsetLmp div SizeOf(tRGB888);
    end;

  // how much we can read lightmaps pages? from min 0 to max 4 pages
  lpFaceExt.CountLightStyles:=0;
  if (lpFaceExt.BaseFace.nStyles[0] >= 0) then Inc(lpFaceExt.CountLightStyles);
  if (lpFaceExt.BaseFace.nStyles[1] > 0) then Inc(lpFaceExt.CountLightStyles);
  if (lpFaceExt.BaseFace.nStyles[2] > 0) then Inc(lpFaceExt.CountLightStyles);
  if (lpFaceExt.BaseFace.nStyles[3] > 0) then Inc(lpFaceExt.CountLightStyles);

  if ((lpFaceExt.CountLightStyles = 0) and (OffsetLmp >= 0)) then
    begin
      lpFaceExt.BaseFace.nStyles[0]:=0;
      Inc(lpFaceExt.CountLightStyles);
    end;

  // GoldSrc use Quake 2 Method of determinant lightmap size based on Floor() and Ceil()
  LmpMin.X:=Floor(lpFaceExt.TexBBOX.vMin.x*inv16);
  LmpMax.X:=Ceil(lpFaceExt.TexBBOX.vMax.x*inv16);
  LmpMin.Y:=Floor(lpFaceExt.TexBBOX.vMin.y*inv16);
  LmpMax.Y:=Ceil(lpFaceExt.TexBBOX.vMax.y*inv16);

  // Lightmap samples stored in corner of samples, instead center of samples
  // so lightmap size need increment by one
  lpFaceExt.LmpSize.X:=LmpMax.X - LmpMin.X + 1;
  lpFaceExt.LmpSize.Y:=LmpMax.Y - LmpMin.Y + 1;
  lpFaceExt.LmpSquare:=lpFaceExt.LmpSize.X*lpFaceExt.LmpSize.Y;
  lpFaceExt.CountLightmaps:=lpFaceExt.LmpSquare*lpFaceExt.CountLightStyles;

  // Normalize texture coordinatex and compute lightmap coordinates
  w:=Map.TextureLump.Wad3Textures[lpFaceExt.Wad3TextureIndex].nWidth;
  h:=Map.TextureLump.Wad3Textures[lpFaceExt.Wad3TextureIndex].nHeight;
  for i:=0 to (lpFaceExt.Polygon.CountVertecies - 1) do
    begin
      lpFaceExt.LmpCoords[i].x:=(lpFaceExt.TexCoords[i].x*inv16 - LmpMin.X + 0.5);
      lpFaceExt.LmpCoords[i].y:=(lpFaceExt.TexCoords[i].y*inv16 - LmpMin.Y + 0.5);
      lpFaceExt.TexCoords[i].x:=lpFaceExt.TexCoords[i].x/w;
      lpFaceExt.TexCoords[i].y:=lpFaceExt.TexCoords[i].y/h;
    end;

  if ((lpFaceExt.CountLightStyles > 0) and (Map.CountPackedLightmaps > 0)) then
    begin
      SetLength(
        lpFaceExt.LmpMegaCoords,
        lpFaceExt.Polygon.CountVertecies*lpFaceExt.CountLightStyles
      );
      SetLength(
        lpFaceExt.Lightmaps,
        lpFaceExt.CountLightmaps
      );
      CopyBytes(
        @Map.LightingLump[OffsetLmp],
        @lpFaceExt.Lightmaps[0],
        lpFaceExt.CountLightmaps*SizeOf(tRGB888)
      );
      lpFaceExt.isDummyLightmaps:=False;
    end
  else
    begin
      // For dummy white 2x2 lightmap
      SetLength(
        lpFaceExt.LmpMegaCoords,
        lpFaceExt.Polygon.CountVertecies
      );
      for i:=0 to (lpFaceExt.Polygon.CountVertecies - 1) do
        begin
          lpFaceExt.LmpMegaCoords[i].x:=0.0;
          lpFaceExt.LmpMegaCoords[i].y:=0.0;
        end;
      lpFaceExt.isDummyLightmaps:=True;
    end;

  if (Map.TextureLump.Wad3Textures[lpFaceExt.Wad3TextureIndex].MipSize[0] <= 0) then
    begin
      lpFaceExt.isDummyTexture:=True;
      i:=GetTexNameColorPairIndex(lpFaceExt.TexName);
      if (i >= 0) then
        begin
          lpFaceExt.RenderColor:=TEXNAMECOLOR_PAIRTABLE[i].Color;
        end
      else
        begin
          lpFaceExt.RenderColor:=WhiteColor4f;
        end;
    end
  else
    begin
      lpFaceExt.isDummyTexture:=False;
      lpFaceExt.RenderColor:=WhiteColor4f;
    end;

  // After loaded lightmaps, mark offset for RAW Face data to -1
  lpFaceExt.BaseFace.nLightmapOffset:=-1;
  {$R+}
end;

procedure UpdateBrushModelExt(const Map: PMapBSP; const BrushModelId: Integer);
var
  lpBrushModelExt: PBrushModelExt;
begin
  {$R-}
  lpBrushModelExt:=@Map.BrushModelExtList[BrushModelId];
  FreeBrushModelExt(lpBrushModelExt);

  lpBrushModelExt.iLastFace:=lpBrushModelExt.BaseBModel.iFirstFace
    + lpBrushModelExt.BaseBModel.nFaces - 1;
  {$R+}
end;

procedure UpdateVisLeafExt(const Map: PMapBSP; const VisLeafId: Integer);
var
  lpVisLeafExt: PVisLeafExt;
  i: Integer;
begin
  {$R-}
  lpVisLeafExt:=@Map.VisLeafExtList[VisLeafId];

  // Get Final Faces Indecies
  SetLength(lpVisLeafExt.WFaceIndexes, lpVisLeafExt.BaseLeaf.nMarkSurfaces);
  for i:=0 to (lpVisLeafExt.BaseLeaf.nMarkSurfaces - 1) do
    begin
      lpVisLeafExt.WFaceIndexes[i]:=Map.MarkSurfaceLump[lpVisLeafExt.BaseLeaf.iFirstMarkSurface + i];
    end;

  // Get Final PVS Data
  lpVisLeafExt.CountPVS:=0;
  SetLength(lpVisLeafExt.PVS, 0);
  if ((lpVisLeafExt.BaseLeaf.nVisOffset >= 0) and (VisLeafId <> 0)) then
    begin
      lpVisLeafExt.CountPVS:=Map.CountVisLeafWithPVS;
      UnPackPVS(@Map.PackedVisibility[lpVisLeafExt.BaseLeaf.nVisOffset], lpVisLeafExt.PVS,
        Map.CountVisLeafWithPVS, Map.SizePackedVisibility);
    end; //}

  // Get BBOXf
  lpVisLeafExt.BBOXf.vMin.x:=lpVisLeafExt.BaseLeaf.nBBOX.nMin.x;
  lpVisLeafExt.BBOXf.vMin.y:=lpVisLeafExt.BaseLeaf.nBBOX.nMin.y;
  lpVisLeafExt.BBOXf.vMin.z:=lpVisLeafExt.BaseLeaf.nBBOX.nMin.z;
  lpVisLeafExt.BBOXf.vMax.x:=lpVisLeafExt.BaseLeaf.nBBOX.nMax.x;
  lpVisLeafExt.BBOXf.vMax.y:=lpVisLeafExt.BaseLeaf.nBBOX.nMax.y;
  lpVisLeafExt.BBOXf.vMax.z:=lpVisLeafExt.BaseLeaf.nBBOX.nMax.z;

  // Get Size BBOXf
  GetSizeBBOXf(lpVisLeafExt.BBOXf, @lpVisLeafExt.SizeBBOXf);
  {$R+}
end;

procedure UpdateNodeExt(const Map: PMapBSP; const NodeId: Integer);
var
  lpNodeExt: PNodeExt;
begin
  {$R-}
  lpNodeExt:=@Map.NodeExtList[NodeId];

  // UpDate Plane Info
  lpNodeExt.Plane:=Map.PlaneLump[lpNodeExt.BaseNode.iPlane];

  // UpDate BBOXf
  lpNodeExt.BBOXf.vMin.x:=lpNodeExt.BaseNode.nBBOX.nMin.x;
  lpNodeExt.BBOXf.vMin.y:=lpNodeExt.BaseNode.nBBOX.nMin.y;
  lpNodeExt.BBOXf.vMin.z:=lpNodeExt.BaseNode.nBBOX.nMin.z;
  lpNodeExt.BBOXf.vMax.x:=lpNodeExt.BaseNode.nBBOX.nMax.x;
  lpNodeExt.BBOXf.vMax.y:=lpNodeExt.BaseNode.nBBOX.nMax.y;
  lpNodeExt.BBOXf.vMax.z:=lpNodeExt.BaseNode.nBBOX.nMax.z;

  // Update Front Child
  if isLeafChildrenId0(lpNodeExt) then
    begin
      lpNodeExt.IsFrontNode:=False;
      lpNodeExt.FrontIndex:=GetIndexLeafChildrenId0(lpNodeExt);
      lpNodeExt.lpFrontLeafExt:=@Map.VisLeafExtList[lpNodeExt.FrontIndex];
    end
  else
    begin
      lpNodeExt.IsFrontNode:=True;
      lpNodeExt.FrontIndex:=lpNodeExt.BaseNode.iChildren[0];
      lpNodeExt.lpFrontNodeExt:=@Map.NodeExtList[lpNodeExt.FrontIndex];
    end;

  // UpDate Back Child
  if isLeafChildrenId1(lpNodeExt) then
    begin
      lpNodeExt.IsBackNode:=False;
      lpNodeExt.BackIndex:=GetIndexLeafChildrenId1(lpNodeExt);
      lpNodeExt.lpBackLeafExt:=@Map.VisLeafExtList[lpNodeExt.BackIndex];
    end
  else
    begin
      lpNodeExt.IsBackNode:=True;
      lpNodeExt.BackIndex:=lpNodeExt.BaseNode.iChildren[1];
      lpNodeExt.lpBackNodeExt:=@Map.NodeExtList[lpNodeExt.BackIndex];
    end;
  {$R+}
end;

procedure UpdateClipNodeExt(const Map: PMapBSP; const ClipNodeId: Integer);
var
  lpClipNodeExt: PClipNodeExt;
begin
  {$R-}
  lpClipNodeExt:=@Map.ClipNodeExtList[ClipNodeId]; 

  // UpDate Plane and Id Info
  lpClipNodeExt.iClipNode:=ClipNodeId;
  lpClipNodeExt.Plane:=Map.PlaneLump[lpClipNodeExt.BaseClipNode.iPlane];

  // Update Front Child
  lpClipNodeExt.FrontIndex:=lpClipNodeExt.BaseClipNode.iChildren[0];
  if (lpClipNodeExt.BaseClipNode.iChildren[0] < 0) then
    begin
      lpClipNodeExt.IsFrontClipNode:=False;
    end
  else
    begin
      lpClipNodeExt.IsFrontClipNode:=True;
      lpClipNodeExt.lpFrontClipNodeExt:=@Map.ClipNodeExtList[lpClipNodeExt.FrontIndex];
    end;

  // UpDate Back Child
  lpClipNodeExt.BackIndex:=lpClipNodeExt.BaseClipNode.iChildren[1];
  if (lpClipNodeExt.BaseClipNode.iChildren[1] < 0) then
    begin
      lpClipNodeExt.IsBackClipNode:=False;
    end
  else
    begin
      lpClipNodeExt.IsBackClipNode:=True;
      lpClipNodeExt.lpBackClipNodeExt:=@Map.ClipNodeExtList[lpClipNodeExt.BackIndex];
    end;
  {$R+}
end;

procedure UpdateEntityExt(const Map: PMapBSP; const EntityId: Integer);
var
  lpEntity: PEntity;
  tmpStr: String;
  i: Integer;
  isHaveOrigin: Boolean;
  //
  lpModelExt: PBrushModelExt;
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
      lpEntity.VisLeaf:=GetLeafIndexByPoint(
        @Map.NodeExtList[0],
        lpEntity.Origin,
        Map.RootNodeIndex
      );
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
            lpModelExt:=@Map.BrushModelExtList[lpEntity.BrushModel];

            lpModelExt.EntityId:=EntityId;
            lpModelExt.isBrushWithEntityOrigin:=isHaveOrigin;
            lpModelExt.Origin:=lpEntity.Origin;

            if (isHaveOrigin = False) then
              begin
                GetOriginByBBOX(lpModelExt.BaseBModel.BBOXf, @lpEntity.Origin);
                lpEntity.VisLeaf:=GetLeafIndexByPoint(
                  @Map.NodeExtList[0],
                  lpEntity.Origin,
                  Map.RootNodeIndex
                );
                lpModelExt.Origin:=VEC_ZERO;
              end
            else
              begin
                for i:=lpModelExt.BaseBModel.iFirstFace to lpModelExt.iLastFace do
                  begin
                    TranslateVertexArray(
                      @Map.FaceExtList[i].Polygon.Vertecies[0],
                      @lpEntity.Origin,
                      Map.FaceExtList[i].Polygon.CountVertecies
                    );
                  end; //}
              end;
            for i:=lpModelExt.BaseBModel.iFirstFace to lpModelExt.iLastFace do
              begin
                Map.FaceExtList[i].BrushId:=lpEntity.BrushModel;
                Map.FaceExtList[i].EntityId:=EntityId;
              end;
          end;
      end;
  {$R+}
end;

procedure UpdateEntityLight(const Map: PMapBSP);
var
  StyleIndexList: AInt; // count if enter styles in faces
  i, j, k, PairIndex: Integer;
  lpFaceExt: PFaceExt;
  lpEntity: PEntity;
  lpLightEntity: PLightEntity;
begin
  {$R-}
  // Get total count if light entities;
  Map.CountLightEntities:=0;
  for i:=1 to (Map.CountEntities - 1) do
    begin
      if (CompareString(Map.Entities[i].ClassName, ClassNameLight, 5)) then
        begin
          Inc(Map.CountLightEntities);
        end;
    end;

  // Allocate mem for light entities and parse it.
  SetLength(Map.LightEntityList, Map.CountLightEntities);
  lpLightEntity:=@Map.LightEntityList[0];
  for i:=1 to (Map.CountEntities - 1) do
    begin
      lpEntity:=@Map.Entities[i];

      if (lpEntity.ClassName = ClassNameLight) then
        begin
          lpLightEntity.ClassName:=ClassNameLight;
          lpLightEntity.TargetName:=lpEntity.TargetName;
          lpLightEntity.Origin:=lpEntity.Origin;
          lpLightEntity.VisLeafIndex:=lpEntity.VisLeaf;
          lpLightEntity.EntityIndex:=i;

          lpLightEntity.LightStyleIndex:=NONNAMED_STYLE_INDEX;
          PairIndex:=GetPairIndexByKey(@lpEntity.Pairs[0], lpEntity.CountPairs, KeyLightStyle);
          if (PairIndex >= 0) then
            begin
              j:=StrToIntDef(lpEntity.Pairs[PairIndex].Value, -1);
              if (j < 0) then j:=-1;
              if (j > 127) then j:=-1;
              lpLightEntity.LightStyleIndex:=j;
            end;

          Inc(lpLightEntity);
          Continue;
        end;

      if (lpEntity.ClassName = ClassNameLightSpot) then
        begin
          lpLightEntity.ClassName:=ClassNameLightSpot;
          lpLightEntity.TargetName:=lpEntity.TargetName;
          lpLightEntity.Origin:=lpEntity.Origin;
          lpLightEntity.Angles:=lpEntity.Angles;
          lpLightEntity.VisLeafIndex:=lpEntity.VisLeaf;
          lpLightEntity.EntityIndex:=i;

          lpLightEntity.LightStyleIndex:=NONNAMED_STYLE_INDEX;
          PairIndex:=GetPairIndexByKey(@lpEntity.Pairs[0], lpEntity.CountPairs, KeyLightStyle);
          if (PairIndex >= 0) then
            begin
              j:=StrToIntDef(lpEntity.Pairs[PairIndex].Value, -1);
              if (j < 0) then j:=-1;
              if (j > 127) then j:=-1;
              lpLightEntity.LightStyleIndex:=j;
            end;

          Inc(lpLightEntity);
          Continue;
        end;

      if (lpEntity.ClassName = ClassNameLightEnv) then
        begin
          lpLightEntity.ClassName:=ClassNameLightEnv;
          lpLightEntity.TargetName:=lpEntity.TargetName;
          lpLightEntity.Origin:=lpEntity.Origin;
          lpLightEntity.VisLeafIndex:=lpEntity.VisLeaf;
          lpLightEntity.EntityIndex:=i;

          lpLightEntity.LightStyleIndex:=NONNAMED_STYLE_INDEX;
          PairIndex:=GetPairIndexByKey(@lpEntity.Pairs[0], lpEntity.CountPairs, KeyLightStyle);
          if (PairIndex >= 0) then
            begin
              j:=StrToIntDef(lpEntity.Pairs[PairIndex].Value, -1);
              if (j < 0) then j:=-1;
              if (j > 127) then j:=-1;
              lpLightEntity.LightStyleIndex:=j;
            end;

          Inc(lpLightEntity);
          Continue;
        end;
    end;

  // Next, find total number of unique lightstyles for Faces.
  // Ignare specific limits (32 max switchable lights and
  // that styles index start at 32 to 63). Make both case.
  SetLength(StyleIndexList, 128);
  FillChar(StyleIndexList[0], 128*SizeOf(Integer), 0);
  for i:=0 to (Map.CountFaces - 1) do
    begin
      lpFaceExt:=@Map.FaceExtList[i];

      if (lpFaceExt.BaseFace.nStyles[0] >= 0) then Inc(StyleIndexList[lpFaceExt.BaseFace.nStyles[0]]);
      if (lpFaceExt.BaseFace.nStyles[1] >= 0) then Inc(StyleIndexList[lpFaceExt.BaseFace.nStyles[1]]);
      if (lpFaceExt.BaseFace.nStyles[2] >= 0) then Inc(StyleIndexList[lpFaceExt.BaseFace.nStyles[2]]);
      if (lpFaceExt.BaseFace.nStyles[3] >= 0) then Inc(StyleIndexList[lpFaceExt.BaseFace.nStyles[3]]);
    end;

  // Get count of unique light styles
  Map.CountLightStyles:=0;
  for i:=0 to 127 do
    begin
      if (StyleIndexList[i] > 0) then Inc(Map.CountLightStyles);
    end;

  // set unique light styles indexes
  SetLength(Map.LightStylesList, Map.CountLightStyles);
  j:=0;
  for i:=0 to 127 do
    begin
      if (StyleIndexList[i] > 0) then
        begin
          Map.LightStylesList[j].Style:=i;
          Inc(j);
        end;
    end;

  // Next - get count of entities per style index
  FillChar(StyleIndexList[0], 128*SizeOf(Integer), 0);
  for i:=0 to (Map.CountLightEntities - 1) do
    begin
      lpLightEntity:=@Map.LightEntityList[i];

      if (lpLightEntity.LightStyleIndex < 0) then Continue;
      Inc(StyleIndexList[lpLightEntity.LightStyleIndex]);
    end;

  // Allocate mem with get count of entities
  for i:=0 to (Map.CountLightStyles - 1) do
    begin
      k:=StyleIndexList[Map.LightStylesList[i].Style];
      Map.LightStylesList[i].CountLightEntities:=k;
      SetLength(Map.LightStylesList[i].LightEntityList, k);
      Map.LightStylesList[i].TargetName:='';
    end;
  SetLength(StyleIndexList, 0);

  // Finally - contact entity light with LightStylesList by Style index
  for i:=0 to (Map.CountLightStyles - 1) do
    begin
      k:=0;
      for j:=0 to (Map.CountLightEntities - 1) do
        begin
          lpLightEntity:=@Map.LightEntityList[j];

          if (lpLightEntity.LightStyleIndex <> Map.LightStylesList[i].Style) then Continue;
          Map.LightStylesList[i].LightEntityList[k]:=lpLightEntity;

          if (k = 0) then Map.LightStylesList[i].TargetName:=lpLightEntity.TargetName;
          Inc(k);
        end;
    end;
  {$R+}
end;

end.

