unit UnitVisLeaf;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus

interface

uses
  UnitUserTypes;

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
    BBOXf: tBBOXf;
    SizeBBOXf: tVec3f;
    CountPVS: Integer;
    WFaceIndexes: AInt;
    PVS: AByteBool;
  end;
type PVisLeafExt = ^tVisLeafExt;
type AVisLeafExt = array of tVisLeafExt;


procedure FreeVisLeafExt(const lpLeafExt: PVisLeafExt);
function TestGoodLeafBBOX(const lpLeafExt: PVisLeafExt): Boolean;
function IsGoodLeafContents(const lpLeafExt: PVisLeafExt): Boolean;
function UnPackPVS(const PackedPVS: AByte; var UnPackedPVS: AByteBool;
  const CountPVS, PackedSize: Integer): Integer;


implementation


procedure FreeVisLeafExt(const lpLeafExt: PVisLeafExt);
begin
  {$R-}
  SetLength(lpLeafExt.WFaceIndexes, 0);
  SetLength(lpLeafExt.PVS, 0);
  lpLeafExt.CountPVS:=0;
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


function UnPackPVS(const PackedPVS: AByte; var UnPackedPVS: AByteBool;
  const CountPVS, PackedSize: Integer): Integer;
var
  i, j: Integer;
begin
  {$R-}
  Result:=0;
  SetLength(UnPackedPVS, 0);

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

end.
