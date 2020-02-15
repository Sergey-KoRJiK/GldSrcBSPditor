unit UnitEntity;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  UnitVec;

const
  MAX_KEY_SIZE = 32;
  MAX_VALUE_SIZE = 200;

type tKeyValue = record
    Key: String[MAX_KEY_SIZE];
    Value: String[MAX_VALUE_SIZE]; //MAX_VALUE_SIZE
  end;
type PKeyValue = ^tKeyValue;
type AKeyValue = array of tKeyValue;

type tEntity = record
    CountPairs: Integer;
    Pairs: AKeyValue;
    ClassName: String;
    BrushModel: Integer; // if 0 -> no Brush Entity
    VisLeaf: Integer; // if 0 -> no have origin
    Origin: tVec3f; // if VisLeaf = 0 then not used
    Angles: tVec3f;
  end;
type PEntity = ^tEntity;
type AEntity = array of tEntity;


const
  ClassNameSpawnCT = 'info_player_start';
  ClassNameSpawnT = 'info_player_deathmatch';


procedure FixEntityStrEndToWin(var S: String; const SizeS: Integer);
function SplitEntDataByRow(const EntityData: String; const SizeEntityData: Integer): TStringList;
procedure ParseEntityPair(const StrPair: String; const Pair: PKeyValue);
function GetEntityList(const RawList: TStringList; var Entities: AEntity): Integer;
function FindFirstSpawnEntity(const Entities: AEntity; const Count: Integer): Integer;


implementation


procedure FixEntityStrEndToWin(var S: String; const SizeS: Integer);
var
  i: Integer;
begin
  {$R-}
  for i:=1 to SizeS do
    begin
      if (S[i] = CR) then S[i]:=SpaceChar;
    end;
  {$R+}
end;

function SplitEntDataByRow(const EntityData: String; const SizeEntityData: Integer): TStringList;
var
  i, j, RowCount: Integer;
  RowIndex: AInt;
  DebugStr: String;
begin
  {$R-}
  Result:=nil;
  if (SizeEntityData = 0) then Exit;

  Result:=TStringList.Create;
  RowCount:=0;
  for i:=1 to SizeEntityData do
    begin
      if (EntityData[i] = LF) then Inc(RowCount);
    end;

  if (RowCount <= 1) then
    begin
      Result.Append(EntityData);
      Exit;
    end;

  SetLength(RowIndex, RowCount);
  j:=0;
  for i:=0 to (SizeEntityData - 1) do
    begin
      if (EntityData[i] = LF) then
        begin
          RowIndex[j]:=i;
          Inc(j);
        end;
    end;

  DebugStr:=StringReplace(Copy(EntityData, 0, RowIndex[0]), LF, '', [rfReplaceAll]);
  Result.Append(DebugStr);
  for i:=0 to (RowCount - 2) do
    begin
      DebugStr:=StringReplace(
        Copy(EntityData, RowIndex[i], RowIndex[i + 1] - RowIndex[i]), LF, '', [rfReplaceAll]);
      Result.Append(DebugStr);
    end;
  SetLength(RowIndex, 0);
  {$R+}
end;

procedure ParseEntityPair(const StrPair: String; const Pair: PKeyValue);
var
  i, j, n: Integer;
  QuotesPos: array[0..3] of Integer;
begin
  {$R-}
  n:=Length(StrPair);

  j:=0;
  for i:=1 to n do
    begin
      if (StrPair[i] = '"') then Inc(j);
    end;

  if (j <> 4) then
    begin
      Pair.Key:='';
      Pair.Value:='';
    end
  else
    begin
      j:=0;
      for i:=1 to n do
        begin
          if (StrPair[i] = '"') then
            begin
              QuotesPos[j]:=i;
              Inc(j);
            end;
        end;

      if ((QuotesPos[1] - QuotesPos[0] - 1) > MAX_KEY_SIZE) then
        begin
          Pair.Key:=Copy(StrPair, QuotesPos[0] + 1, MAX_KEY_SIZE);
        end
      else
        begin
          Pair.Key:=Copy(StrPair, QuotesPos[0] + 1, QuotesPos[1] - QuotesPos[0] - 1);
        end;

      if ((QuotesPos[3] - QuotesPos[2] - 1) > MAX_KEY_SIZE) then
        begin
          Pair.Value:=Copy(StrPair, QuotesPos[2] + 1, MAX_KEY_SIZE);
        end
      else
        begin
          Pair.Value:=Copy(StrPair, QuotesPos[2] + 1, QuotesPos[3] - QuotesPos[2] - 1);
        end;
    end;
  {$R+}
end;

function GetEntityList(const RawList: TStringList; var Entities: AEntity): Integer;
var
  i, j, k: Integer;
  BraCount, KetCount: Integer;
  BraIndecies, KetIndecies: AInt;
begin
  {$R-}
  Result:=0;
  SetLength(Entities, 0);
  if (RawList <> nil) then
    begin
      BraCount:=0;
      KetCount:=0;
      for i:=0 to (RawList.Count - 1) do
        begin
          if (RawList.Strings[i] = '{') then Inc(BraCount);
          if (RawList.Strings[i] = '}') then Inc(KetCount);
        end;
      if (BraCount <> KetCount) then Exit;
      if (BraCount = 0) then Exit;
      Result:=BraCount;

      SetLength(Entities, Result);
      if (Result = 1) then
        begin
          // Parse One Entity
          Entities[0].BrushModel:=0;
          Entities[0].VisLeaf:=0;
          Entities[0].CountPairs:=RawList.Count - 2;
          Entities[0].Origin.x:=0;
          Entities[0].Origin.y:=0;
          Entities[0].Origin.z:=0;
          SetLength(Entities[0].Pairs, Entities[0].CountPairs);
          for i:=1 to (RawList.Count - 2) do
            begin
              ParseEntityPair(RawList.Strings[i], @Entities[0].Pairs[i - 1]);
            end;
          Exit;
        end;

      SetLength(BraIndecies, Result);
      SetLength(KetIndecies, Result);
      j:=0;
      k:=0;
      for i:=0 to (RawList.Count - 1) do
        begin
          if (RawList.Strings[i] = '{') then
            begin
              BraIndecies[j]:=i;
              Inc(j);
            end;
          if (RawList.Strings[i] = '}') then
            begin
              KetIndecies[k]:=i;
              Inc(k);
            end;
        end;

      for i:=0 to (Result - 1) do
        begin
          if (BraIndecies[i] > KetIndecies[i]) then
            begin
              SetLength(Entities, 0);
              SetLength(BraIndecies, 0);
              SetLength(KetIndecies, 0);
              Result:=0;
              Exit;
            end;
        end;

      for i:=0 to (Result - 1) do
        begin
          Entities[i].BrushModel:=0;
          Entities[i].VisLeaf:=0;
          Entities[i].CountPairs:=KetIndecies[i] - BraIndecies[i] - 1;
          Entities[0].Origin.x:=0;
          Entities[0].Origin.y:=0;
          Entities[0].Origin.z:=0;
          SetLength(Entities[i].Pairs, Entities[i].CountPairs);
          k:=0;
          for j:=(BraIndecies[i] + 1) to (KetIndecies[i] - 1) do
            begin
              ParseEntityPair(RawList.Strings[j], @Entities[i].Pairs[k]);
              Inc(k);
            end;

          for j:=0 to (Entities[i].CountPairs - 1) do
            begin
              if (Entities[i].Pairs[j].Key = 'classname') then
                begin
                  Entities[i].ClassName:=Entities[i].Pairs[j].Value;
                end;
            end;
        end;
    end;
  {$R+}
end;

function FindFirstSpawnEntity(const Entities: AEntity; const Count: Integer): Integer;
var
  i: Integer;
begin
  // First check that entities great then one
  if (Count <= 1) then
    begin
      Result:=-1;
      Exit;
    end;

  // First check CT/HL1 spawn
  for i:=1 to (Count - 1) do
    begin
      if (Entities[i].ClassName = ClassNameSpawnCT) then
        begin
          if (Entities[i].VisLeaf = 0) then Continue;
          Result:=i;
          Exit;
        end;
    end;

  // Next check T spawn
  for i:=1 to (Count - 1) do
    begin
      if (Entities[i].ClassName = ClassNameSpawnT) then
        begin
          if (Entities[i].VisLeaf = 0) then Continue;
          Result:=i;
          Exit;
        end;
    end;

  // if Bad then -1
  Result:=-1;
end;

end.
