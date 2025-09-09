unit UnitEdge;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

interface

type tEdgeIndex = record
    v0, v1: WORD;
  end;
type PEdgeIndex = ^tEdgeIndex;
type AEdgeIndex = array of tEdgeIndex;

type tSurfEdge = Integer;
type PSurfEdge = ^tSurfEdge;
type ASurfEdge = array of tSurfEdge;
  

implementation


end.
 