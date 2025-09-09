unit UnitLightEntity;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

interface

uses
  SysUtils,
  UnitUserTypes,
  UnitEntity;


const
  NONNAMED_STYLE_INDEX: ShortInt =    $00;

type tLightEntity = packed record
    Origin: tVec4f;
    Angles: tVec4f;
    EntityIndex: Integer;
    VisLeafIndex: Integer;
    TargetName: String;
    ClassName: String;
    LightStyleIndex: ShortInt;
  end;
type PLightEntity = ^tLightEntity;
type ALightEntity = array of tLightEntity;
type APLightEntity = array of PLightEntity;


type tLightStylePair = record
    Style: ShortInt;
    TargetName: String; // only one targetname per style
    CountLightEntities: Integer;
    LightEntityList: array of PLightEntity;
  end;
type PLightStylePair = ^tLightStylePair;
type ALightStylePair = array of tLightStylePair;


procedure FreeLightEntity(const LightEntity: PLightEntity);
procedure FreeLightStylePair(const Pair: PLightStylePair);

function FindLightStylePair(const PairList: PLightStylePair;
  const CountPairs: Integer; const StyleIndex: ShortInt): Integer; overload;
function FindLightStylePair(const PairList: PLightStylePair;
  const CountPairs: Integer; const SubStr: String): Integer; overload;

function ShowLightStylesTable(
  const lpLightStyles: PLightStylePair; const Count: Integer): String;

implementation


procedure FreeLightStylePair(const Pair: PLightStylePair);
begin
  {$R-}
  Pair.TargetName:='';
  SetLength(Pair.LightEntityList, 0);
  Pair.CountLightEntities:=0;
  Pair.Style:=-1;
  {$R+}
end;

procedure FreeLightEntity(const LightEntity: PLightEntity);
begin
  {$R-}
  LightEntity.Origin:=VEC_ZERO_4F;
  LightEntity.Angles:=VEC_ZERO_4F;
  LightEntity.EntityIndex:=0;
  LightEntity.VisLeafIndex:=0;
  LightEntity.TargetName:='';
  LightEntity.ClassName:='';
  LightEntity.LightStyleIndex:=-1;
  {$R+}
end;

function FindLightStylePair(const PairList: PLightStylePair;
  const CountPairs: Integer; const StyleIndex: ShortInt): Integer;
var
  i: Integer;
begin
  {$R-}
  if (StyleIndex < 0) then
    begin
      Result:=-1;
      Exit;
    end;

  for i:=0 to (CountPairs - 1) do
    begin
      if (ALightStylePair(PairList)[i].Style = StyleIndex) then
        begin
          Result:=i;
          Exit;
        end;
    end;

  Result:=-1;
  {$R+}
end;

function FindLightStylePair(const PairList: PLightStylePair;
  const CountPairs: Integer; const SubStr: String): Integer;
var
  i: Integer;
begin
  {$R-}
  for i:=0 to (CountPairs - 1) do
    begin
      if (Pos(SubStr, ALightStylePair(PairList)[i].TargetName) > 0) then
        begin
          Result:=i;
          Exit;
        end;
    end;

  Result:=-1;
  {$R+}
end;

function ShowLightStylesTable(
  const lpLightStyles: PLightStylePair; const Count: Integer): String;
var
  i: Integer;
begin
  {$R-}
  Result:='Format: <Style Index>, "Style name", <Count Light Entities>:' + LF;
  for i:=0 to (Count - 1) do
    begin
      Result:=Result + IntToStr(ALightStylePair(lpLightStyles)[i].Style)
        + ' "' + ALightStylePair(lpLightStyles)[i].TargetName
        + '" ' + IntToStr(ALightStylePair(lpLightStyles)[i].CountLightEntities) + LF
    end;
  {$R+}
end;

end.
