unit UnitEdge;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes;

type tEdge = record
    v0, v1: WORD;
  end;
type PEdge = ^tEdge;
type AEdge = array of tEdge;

type tSurfEdge = Integer;
type PSurfEdge = ^tSurfEdge;
type ASurfEdge = array of tSurfEdge;

const
  SizeOfEdge = SizeOf(tEdge);
  SizeOfSurfEdge = SizeOf(tSurfEdge);
  

implementation


end.
 