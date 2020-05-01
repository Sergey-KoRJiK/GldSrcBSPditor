unit UnitVSync;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses SysUtils, Windows, Classes;

const
  MinSyncInterval: Integer = 16; // [millisecond], 16 ms = 62.5 FPS

type CVSyncManager = class
  private
    Interval: Integer; // [millisecond]
    DeltaTime, LastTime, CurrentTime: Int64; // [millisecond]
    TickPeriod: Int64; // [1 / second]
    CurrentTickCount: Int64; // [Tick]
  public
    property SyncInterval: Integer read Interval;
    property DeltaTimeMs: Int64 read DeltaTime;
    //
    constructor CreateVSyncManager(const SyncIntervalMillisecond: Integer);
    destructor DeleteVSyncManager();
    //
    procedure Synchronize();
  end;


implementation


constructor CVSyncManager.CreateVSyncManager(const SyncIntervalMillisecond: Integer);
begin
  {$R-}
  inherited;

  Self.Interval:=SyncIntervalMillisecond;
  if (Self.Interval < MinSyncInterval) then Self.Interval:=MinSyncInterval;

  QueryPerformanceFrequency(Self.TickPeriod);
  QueryPerformanceCounter(Self.CurrentTickCount);
  Self.CurrentTime:=(Self.CurrentTickCount*1000) div Self.TickPeriod;
  Self.LastTime:=Self.CurrentTime;
  Self.DeltaTime:=0;
  {$R+}
end;

destructor CVSyncManager.DeleteVSyncManager();
begin
  {$R-}
  inherited;
  {$R+}
end;

procedure CVSyncManager.Synchronize();
var
  tmpInt32: Integer;
begin
  {$R-}
  QueryPerformanceCounter(Self.CurrentTickCount);
  Self.CurrentTime:=(Self.CurrentTickCount*1000) div Self.TickPeriod;
  Self.DeltaTime:=Self.CurrentTime - Self.LastTime;
  Self.LastTime:=Self.CurrentTime;

  if ((Self.DeltaTime > $7FFFFFFF) or (Self.DeltaTime < 0)) then tmpInt32:=0
  else tmpInt32:=Self.DeltaTime;

  if (tmpInt32 < Self.Interval) then
    begin
      Sleep(Self.Interval - tmpInt32);
    end;
  {$R+}
end;

end.
