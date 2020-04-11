unit UnitVSync;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses SysUtils, Windows, Classes;

const
  DefaultSyncInterval: Integer = 17;

type CVSyncManager = class
  private
    Interval: Integer;
  public
    property SyncInterval: Integer read Interval;
    //
    constructor CreateVSyncManager(const SyncIntervalMillisecond: Integer);
    destructor DeleteVSyncManager();
    //
    procedure Synchronize(const deltaTimeMillisecond: Integer);
  end;


implementation


constructor CVSyncManager.CreateVSyncManager(const SyncIntervalMillisecond: Integer);
begin
  {$R-}
  inherited;

  Self.Interval:=SyncIntervalMillisecond;
  if (Self.Interval <= 0) then Self.Interval:=DefaultSyncInterval;

  {$R+}
end;

destructor CVSyncManager.DeleteVSyncManager();
begin
  {$R-}
  inherited;
  {$R+}
end;

procedure CVSyncManager.Synchronize(const deltaTimeMillisecond: Integer);
begin
  {$R-}
  if (deltaTimeMillisecond <= Self.Interval) then
    begin
      Sleep(Self.Interval - deltaTimeMillisecond);
    end;
  {$R+}
end;

end.
