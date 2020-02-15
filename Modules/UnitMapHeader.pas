unit UnitMapHeader;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  UnitVec,
  {}
  UnitEntity,
  UnitPlane,
  UnitTexture,
  UnitNode,
  UnitFace,
  UnitVisLeaf,
  UnitMarkSurface,
  UnitEdge,
  UnitBrushModel;

const
  MAP_HEADER_SIZE = 124; // Bytes
  MAP_VERSION =       $0000001E; // 30
  HEADER_LUMPS =      15;
  LUMP_ENTITIES	= 	   0;
  LUMP_PLANES	= 		   1;
  LUMP_TEXTURES =		   2;
  LUMP_VERTICES	= 	   3;
  LUMP_VISIBILITY	=	   4;
  LUMP_NODES =  			 5;
  LUMP_TEXINFO =  		 6;
  LUMP_FACES =  			 7;
  LUMP_LIGHTING	=   	 8;
  LUMP_CLIPNODES =     9;
  LUMP_LEAVES	=   		10;
  LUMP_MARKSURFACES	= 11;
  LUMP_EDGES =  			12;
  LUMP_SURFEDGES =  	13;
  LUMP_BRUSHES	=   	14;


type tInfoLump = record
    nOffset: Integer;
    nLength: Integer;
  end;
type PInfoLump = ^tInfoLump;
type AInfoLump = array of tInfoLump;

type tMapHeader = record
    nVersion: Integer;
    LumpsInfo: array[0..HEADER_LUMPS-1] of tInfoLump;
  end;
type PMapHeader = ^tMapHeader;


function ShowElement(const IntoLump: tInfoLump; const Size: Integer): String;
function ShowMapHeaderInfo(const MapHeader: tMapHeader): String;
function GetEOFbyHeader(const Header: tMapHeader): Integer;


implementation


function ShowElement(const IntoLump: tInfoLump; const Size: Integer): String;
begin
  {$R-}
  if (Size > 0) then
    begin
      Result:='   ' +
      IntToHex(IntoLump.nOffset, 8) + '    #   ' +
      IntToStr(IntoLump.nLength) + '/' +
      IntToStr(IntoLump.nLength div Size) + CRLF;
    end
  else
    begin
      Result:='   ' +
      IntToHex(IntoLump.nOffset, 8) + '    #   ' +
      IntToStr(IntoLump.nLength) + CRLF;
    end;
  {$R+}
end;

function ShowMapHeaderInfo(const MapHeader: tMapHeader): String;
begin
  {$R-}
  with MapHeader do
    begin
      Result:=
      'Size of Header = 124 bytes' + CRLF +
      'Version of BSP = ' + IntToStr(nVersion) + CRLF +
      '####################################################' + CRLF +
      '# Lump type     #  Offset (hex) # Size/Count (dec) #' + CRLF +
      '####################################################' + CRLF +
      '# ENTITIES      #' + ShowElement(LumpsInfo[LUMP_ENTITIES], 0) +
      '# PLANES        #' + ShowElement(LumpsInfo[LUMP_PLANES], SizeOfPlane) +
      '# TEXTURES      #' + ShowElement(LumpsInfo[LUMP_TEXTURES], 0) +
      '# VERTICES      #' + ShowElement(LumpsInfo[LUMP_VERTICES], SizeOfVec3f) +
      '# VISIBILITY    #' + ShowElement(LumpsInfo[LUMP_VISIBILITY], 0) +
      '# NODES         #' + ShowElement(LumpsInfo[LUMP_NODES], SizeOfNode) +
      '# TEXINFO       #' + ShowElement(LumpsInfo[LUMP_TEXINFO], SizeOfTexInfo) +
      '# FACES         #' + ShowElement(LumpsInfo[LUMP_FACES], SizeOfFace) +
      '# LIGHTING      #' + ShowElement(LumpsInfo[LUMP_LIGHTING], SizeOfRGB888) +
      '# LEAVES        #' + ShowElement(LumpsInfo[LUMP_LEAVES], SizeOfVisLeaf) +
      '# MARKSURFACES  #' + ShowElement(LumpsInfo[LUMP_MARKSURFACES], SizeOfMarkSurface) +
      '# EDGES         #' + ShowElement(LumpsInfo[LUMP_EDGES], SizeOfEdge) +
      '# SURFEDGES     #' + ShowElement(LumpsInfo[LUMP_SURFEDGES], SizeOfSurfEdge) +
      '# BRUSHES       #' + ShowElement(LumpsInfo[LUMP_BRUSHES], SizeOfBrushModel) +
      '####################################################';
    end;
  {$R+}
end;

function GetEOFbyHeader(const Header: tMapHeader): Integer;
var
  i, tmp: Integer;
begin
  {$R-}
  Result:=0;
  for i:=0 to (HEADER_LUMPS - 1) do
    begin
      tmp:=Header.LumpsInfo[i].nOffset + Header.LumpsInfo[i].nLength;
      if tmp>Result then Result:=tmp;
    end;
  {$R+}
end;

end.
 