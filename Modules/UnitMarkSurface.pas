unit UnitMarkSurface;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses SysUtils, Windows, Classes;

type tMarkSurface = Word;
type PMarkSurface = ^tMarkSurface;
type AMarkSurface = array of tMarkSurface;

const
  SizeOfMarkSurface = SizeOf(tMarkSurface);
  

implementation


end.
 