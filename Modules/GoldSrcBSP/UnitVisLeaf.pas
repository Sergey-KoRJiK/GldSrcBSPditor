unit UnitVisLeaf;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

interface

uses
  UnitUserTypes,
  UnitVec;

const
  CONTENTS_EMPTY: Integer           = -1;
  CONTENTS_SOLID: Integer           = -2;
  CONTENTS_WATER: Integer           = -3;
  CONTENTS_SLIME: Integer           = -4;
  CONTENTS_LAVA: Integer            = -5;
  CONTENTS_SKY: Integer             = -6;
  CONTENTS_ORIGIN: Integer          = -7;
  CONTENTS_CLIP: Integer            = -8;
  CONTENTS_CURRENT_0: Integer       = -9;
  CONTENTS_CURRENT_90: Integer      = -10;
  CONTENTS_CURRENT_180: Integer     = -11;
  CONTENTS_CURRENT_270: Integer     = -12;
  CONTENTS_CURRENT_UP: Integer      = -13;
  CONTENTS_CURRENT_DOWN: Integer    = -14;
  CONTENTS_TRANSLUCENT: Integer     = -15;


type tVisLeaf = packed record
    nContents: Integer;
    nVisOffset: Integer;
    nBBOX: tBBOXs; //BBOX
    iFirstMarkSurface, nMarkSurfaces: SmallInt;
    nAmbientLevels: Integer;
  end;
type PVisLeaf = ^tVisLeaf;
type AVisLeaf = array of tVisLeaf;

type tVisLeafExt = record
    BaseLeaf: tVisLeaf;
    BBOX4f: tBBOX4f;
    SizeBBOX4f: tVec4f;
    CountPVS: Integer;
    CountWFaces: Integer;
    CountBModels: Integer;
    WFaceIndexes: AWord;
    BModelIndexes: AWord;
    PVS: AByteBool;
  end;
type PVisLeafExt = ^tVisLeafExt;
type AVisLeafExt = array of tVisLeafExt;


procedure FreeVisLeafExt(const lpLeafExt: PVisLeafExt);
function TestGoodLeafBBOX(const lpLeafExt: PVisLeafExt): Boolean;
function IsGoodLeafContents(const lpLeafExt: PVisLeafExt): Boolean;

function UnPackPVS(
  const PackedPVS: PByte; const UnPackedPVS: PByteBool; const CountPVS, PackedSize: Integer): Integer;


implementation


procedure FreeVisLeafExt(const lpLeafExt: PVisLeafExt);
begin
  {$R-}
  SetLength(lpLeafExt.WFaceIndexes, 0);
  SetLength(lpLeafExt.PVS, 0);
  SetLength(lpLeafExt.BModelIndexes, 0);
  lpLeafExt.CountPVS:=0;
  lpLeafExt.CountWFaces:=0;
  lpLeafExt.CountBModels:=0;
  lpLeafExt.BBOX4f:=BBOX_ZERO_4F;
  lpLeafExt.SizeBBOX4f:=VEC_ZERO_4F;
  {$R+}
end;


function TestGoodLeafBBOX(const lpLeafExt: PVisLeafExt): Boolean;
begin
  {$R-}
  TestGoodLeafBBOX:=False;
  with lpLeafExt.BaseLeaf do
    begin
      if (nBBOX.nMin.x > nBBOX.nMax.x) then Exit;
      if (nBBOX.nMin.y > nBBOX.nMax.y) then Exit;
      if (nBBOX.nMin.z > nBBOX.nMax.z) then Exit;
    end;
  TestGoodLeafBBOX:=True;
  {$R+}
end;

function IsGoodLeafContents(const lpLeafExt: PVisLeafExt): Boolean;
begin
  {$R-}
  if ( (lpLeafExt.BaseLeaf.nContents > -1) and (lpLeafExt.BaseLeaf.nContents < -15) )
  then IsGoodLeafContents:=False else IsGoodLeafContents:=True;
  {$R+}
end;


function UnPackPVS(
  const PackedPVS: PByte; const UnPackedPVS: PByteBool; const CountPVS, PackedSize: Integer): Integer;
const
  bitLUT: array[0..15] of Integer = (
    $00000000, $00000001, $00000100, $00000101,
    $00010000, $00010001, $00010100, $00010101,
    $01000000, $01000001, $01000100, $01000101,
    $01010000, $01010001, $01010100, $01010101
  );
var
  i, j, n: Integer;
  tmp: Byte;
  PackPtr, UnpackPtr: PByte;
begin
  {$R-}
  n:=0;
  i:=0;
  PackPtr:=Pointer(PackedPVS);
  UnpackPtr:=Pointer(UnPackedPVS);
  while (n < PackedSize) do
    begin
      if (PackPtr^ = 0) then
        begin
          Inc(PackPtr);
          Inc(i);
          if (i >= PackedSize) then
            begin
              Result:=n;
              Exit;
            end;
          j:=(PackPtr^)*8;
          if ((n + j) > CountPVS) then
            begin
              ZeroFillChar(UnpackPtr, CountPVS - n);
              Result:=CountPVS;
              Exit;
            end;
          ZeroFillChar(UnpackPtr, j);
          Inc(n, j);
          Inc(UnpackPtr, j);
        end
      else
        begin
          if ((n + 8) > CountPVS) then
            begin
              tmp:=PackPtr^;
              for j:=0 to (CountPVS - n) do
                begin
                  UnpackPtr^:=tmp and $01;
                  tmp:=tmp shr 1;
                  Inc(UnpackPtr);
                end;
              Result:=CountPVS;
              Exit;
            end
          else
            begin
              PInteger(UnpackPtr)^:=bitLUT[PackPtr^ and $0F];
              Inc(UnpackPtr, 4);
              PInteger(UnpackPtr)^:=bitLUT[(PackPtr^ shr 4) and $0F];
              Inc(UnpackPtr, 4);
            end;
          Inc(n, 8);
        end;
      Inc(PackPtr);
      Inc(i);
    end;
  Result:=n;
  {$R+}
end;

end.
