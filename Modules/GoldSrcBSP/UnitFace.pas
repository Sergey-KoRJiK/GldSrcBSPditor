unit UnitFace;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

interface

uses
  SysUtils,
  Windows,
  Classes,
  Graphics,
  OpenGL,
  UnitOpenGLext,
  UnitUserTypes,
  UnitVec,
  UnitTexture;

type tFace = packed record
    iPlane: WORD;
    nPlaneSide: WORD;     // if non-zero, then inverse plane normal direction
    iFirstSurfEdge: DWORD;
    nSurfEdges: WORD;
    iTextureInfo: WORD;
    nStyles: array[0..3] of ShortInt;
    nLightmapOffset: Integer;
  end;
type PFace = ^tFace;
type AFace = array of tFace;


type tFaceExt = record
    BaseFace: tFace;
    //
    LmpSize, LmpMin, LmpMax: tVec2s;
    LmpSquare: Integer;   // LmpSize.x*LmpSize.y
    CountLightStyles: Integer;
    CountLightmaps: Integer; // = LmpSquare*CountLightStyles
    //
    Lightmaps: ARGB888;     // Size = CountLightmaps
    LmpMegaId: Integer;     // 3D Lightmap Megatexture Id
    LmpRegionId: Integer;   // Lightmap Region Id
    TexRenderId: Integer;   // 2D Basetexture Id
    RenderColor: tColor4fv; // Vertex highlight
    //
    BrushId: Integer;
    VisLeafId: Integer;
    EntityId: Integer;
    Wad3TextureIndex: Integer;
    TexName: PTexName;
    //
    PlaneIndex: Integer;
    Polygon: tPolygon3f; // Plane, Vertecies, BBOX, VertexCount
    TexCoords: AVec2f;
    LmpCoords: AVec2f;
    LmpMegaCoords: AVec2f;
    TexBBOX: tTexBBOXf;
    //
    isDummyLightmaps: Boolean;
    isDummyTexture: Boolean;
    isTriggerTexture: Boolean;
  end;
type PFaceExt = ^tFaceExt;
type AFaceExt = array of tFaceExt;


procedure FreeFaceExt(const lpFaceExt: PFaceExt);
procedure PreRenderFaces(const bEnableVertex, bEnableBaseTex, bEnableLmpTex: Boolean);
procedure RenderFaceVertexOnly(const lpFaceExt: PFaceExt);
procedure RenderFaceContourOnly(const lpFaceExt: PFaceExt);
procedure RenderFaceCustomColor4f(const lpFaceExt: PFaceExt; const CustomColor4fv: PGLfloat);
procedure RenderFaceLmpBT(const lpFaceExt: PFaceExt; const iStyle: Integer);
procedure RenderFaceLmp(const lpFaceExt: PFaceExt; const iStyle: Integer);
procedure RenderFaceBT(const lpFaceExt: PFaceExt);
procedure PostRenderFaces(const bDisableVertex, bDisableBaseTex, bDisableLmpTex: Boolean);


implementation


procedure FreeFaceExt(const lpFaceExt: PFaceExt);
begin
  {$R-}
  lpFaceExt.LmpSize.X:=0;
  lpFaceExt.LmpSize.Y:=0;
  lpFaceExt.LmpSquare:=0;
  lpFaceExt.CountLightStyles:=0;
  lpFaceExt.CountLightmaps:=0;
  //
  SetLength(lpFaceExt.Lightmaps, 0);
  lpFaceExt.LmpMegaId:=-1;
  lpFaceExt.LmpRegionId:=-1;
  lpFaceExt.TexRenderId:=-1;
  lpFaceExt.RenderColor:=WhiteColor4f;
  //
  lpFaceExt.BrushId:=0;
  lpFaceExt.VisLeafId:=0;
  lpFaceExt.EntityId:=0;
  lpFaceExt.Wad3TextureIndex:=0;
  lpFaceExt.TexName:=nil;
  //
  lpFaceExt.PlaneIndex:=0;
  FreePolygon(@lpFaceExt.Polygon);
  SetLength(lpFaceExt.TexCoords, 0);
  SetLength(lpFaceExt.LmpCoords, 0);
  SetLength(lpFaceExt.LmpMegaCoords, 0);
  //
  lpFaceExt.TexBBOX:=TEX_BBOX_ZERO;
  lpFaceExt.isDummyLightmaps:=False;
  lpFaceExt.isDummyTexture:=False;
  lpFaceExt.isTriggerTexture:=False;
  {$R+}
end;


procedure PreRenderFaces(const bEnableVertex, bEnableBaseTex, bEnableLmpTex: Boolean);
begin
  {$R-}
  if (bEnableVertex) then
    begin
      glEnableClientState(GL_VERTEX_ARRAY);
    end;
  if (bEnableBaseTex) then
    begin
      glClientActiveTextureARB(GL_TEXTURE0);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    end;
  if (bEnableLmpTex) then
    begin
      glClientActiveTextureARB(GL_TEXTURE1);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    end;
  {$R+}
end;

procedure RenderFaceVertexOnly(const lpFaceExt: PFaceExt);
begin
  {$R-}
  glVertexPointer(
    3, GL_FLOAT, SizeOf(tVec4f),
    @lpFaceExt.Polygon.Vertecies[0].x
  );
  //
  glDrawArrays(GL_TRIANGLE_FAN, 0, lpFaceExt.Polygon.CountVertecies);
  {$R+}
end;

procedure RenderFaceContourOnly(const lpFaceExt: PFaceExt);
begin
  {$R-}
  glVertexPointer(
    3, GL_FLOAT, SizeOf(tVec4f),
    @lpFaceExt.Polygon.Vertecies[0].x
  );
  //
  glDrawArrays(GL_LINE_LOOP, 0, lpFaceExt.Polygon.CountVertecies);
  {$R+}
end;

procedure RenderFaceCustomColor4f(const lpFaceExt: PFaceExt;
  const CustomColor4fv: PGLfloat);
begin
  {$R-}
  glColor4fv(CustomColor4fv);
  //
  glVertexPointer(
    3, GL_FLOAT, SizeOf(tVec4f),
    @lpFaceExt.Polygon.Vertecies[0].x
  );
  //
  glDrawArrays(GL_TRIANGLE_FAN, 0, lpFaceExt.Polygon.CountVertecies);
  {$R+}
end;

procedure RenderFaceLmpBT(const lpFaceExt: PFaceExt; const iStyle: Integer);
begin
  {$R-}
  glColor4fv(@lpFaceExt.RenderColor[0]);
  glVertexPointer(
    3, GL_FLOAT, SizeOf(tVec4f),
    @lpFaceExt.Polygon.Vertecies[0].x
  );
  glClientActiveTextureARB(GL_TEXTURE0);
  glTexCoordPointer(
    2, GL_FLOAT, 0,
    @lpFaceExt.TexCoords[0].x
  );
  glClientActiveTextureARB(GL_TEXTURE1);
  glTexCoordPointer(
    2, GL_FLOAT, 0,
    @lpFaceExt.LmpMegaCoords[iStyle*lpFaceExt.Polygon.CountVertecies]
  );
  glDrawArrays(GL_TRIANGLE_FAN, 0, lpFaceExt.Polygon.CountVertecies);
  {$R+}
end;

procedure RenderFaceLmp(const lpFaceExt: PFaceExt; const iStyle: Integer);
begin
  {$R-}
  glColor4fv(@lpFaceExt.RenderColor[0]);
  glVertexPointer(
    3, GL_FLOAT, SizeOf(tVec4f),
    @lpFaceExt.Polygon.Vertecies[0].x
  );
  glClientActiveTextureARB(GL_TEXTURE1);
  glTexCoordPointer(
    2, GL_FLOAT, 0,
    @lpFaceExt.LmpMegaCoords[iStyle*lpFaceExt.Polygon.CountVertecies]
  );
  glDrawArrays(GL_TRIANGLE_FAN, 0, lpFaceExt.Polygon.CountVertecies);
  {$R+}
end;

procedure RenderFaceBT(const lpFaceExt: PFaceExt);
begin
  {$R-}
  glColor4fv(@lpFaceExt.RenderColor[0]);
  glVertexPointer(
    3, GL_FLOAT, SizeOf(tVec4f),
    @lpFaceExt.Polygon.Vertecies[0].x
  );
  glClientActiveTextureARB(GL_TEXTURE0);
  glTexCoordPointer(
    2, GL_FLOAT, 0,
    @lpFaceExt.TexCoords[0].x
  );
  glDrawArrays(GL_TRIANGLE_FAN, 0, lpFaceExt.Polygon.CountVertecies);
  {$R+}
end;

procedure PostRenderFaces(const bDisableVertex, bDisableBaseTex, bDisableLmpTex: Boolean);
begin
  {$R-}
  if (bDisableLmpTex) then
    begin
      glClientActiveTextureARB(GL_TEXTURE1);
      glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    end;
  if ( bDisableBaseTex) then
    begin
      glClientActiveTextureARB(GL_TEXTURE0);
      glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    end;
  if (bDisableVertex) then
    begin
      glDisableClientState(GL_VERTEX_ARRAY);
    end;
  {$R+}
end;

end.
