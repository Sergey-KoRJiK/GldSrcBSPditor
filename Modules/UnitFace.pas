unit UnitFace;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  SysUtils,
  Windows,
  Classes,
  Graphics,
  OpenGL,
  EXTOpengl32Glew32,
  UnitVec,
  UnitPlane;

type tFace = record
    iPlane: WORD;
    nPlaneSides: WORD;
    iFirstSurfEdge: DWORD;
    nSurfEdges: WORD;
    iTextureInfo: WORD;
    nStyles: array[0..3] of Byte;
    nLightmapOffset: Integer;
  end;
type PFace = ^tFace;
type AFace = array of tFace;

type tFaceInfo = record
    Plane: tPlane;
    //
    LmpSize: TPoint;
    LmpSquare: Integer;
    CountLightStyles: Integer;
    OffsetLmp: Integer;
    //
    Lightmaps: array[0..3] of ARGB888;
    lpFirstLightmap: array[0..3] of PRGB888;
    LmpPages: array[0..3] of GLuint;
    //
    BrushId: Integer;
    VisLeafId: Integer;
    //
    BBOX: tBBOXf;
    TexBBOX: tTexBBOXf;
    Wad3TextureIndex: Integer;
    TexName: ShortString;
    //
    CountVertex: Integer;
    CountTriangles: Integer;
    Vertex: AVec3f;
    TexCoords: AVec2f;
    LmpCoords: AVec2f;
    //
    isUniqueLmp: array[0..3] of Boolean;
    UniqueRenderColor: array[0..3] of tColor4fv;
    UniqueHash: array[0..3] of Integer;
  end;
type PFaceInfo = ^tFaceInfo;
type AFaceInfo = array of tFaceInfo;

type tRenderFaceInfo = record
    lpFaceInfo: PFaceInfo;
    Page: Integer;
    FilterMode: GLint; // GL_LINEAR or GL_NEAREST
  end;
type PRenderFaceInfo = ^tRenderFaceInfo;


const
  SizeOfFace = SizeOf(tFace);

type tErrLmpBitmap = (
    elbNoError = 0,
    elbNoExist = 1,
    elbNotBitmap = 2,
    elbBadWidth = 3,
    elbBadHeight = 4,
    elbBadFaceInfo = 5
  );


procedure UpdateFaceUniqueLightmaps(const lpFaceInfo: PFaceInfo; const Page: Integer);

procedure SaveLightmapToBitmap(const FileName: String; const lpFaceInfo: PFaceInfo; const Page: Integer);
function LoadLightmapFromBitmap(const FileName: String; const lpFaceInfo: PFaceInfo; const Page: Integer): tErrLmpBitmap;
function ShowErrorLoadLightmapFromBitmap(const elbError: tErrLmpBitmap): String;

procedure CreateLightmapTexture(const lpFaceInfo: PFaceInfo; const Page: Integer);
procedure RenderFaceLmp(const RenderInfo: tRenderFaceInfo);
procedure RenderSelectedFace(const RenderInfo: tRenderFaceInfo; const lpColor: tColor4fv);

function GetRayFaceIntersection(const lpFaceInfo: PFaceInfo; const Ray: tRay; const RayValue: PSingle): Boolean;


implementation


procedure UpdateFaceUniqueLightmaps(const lpFaceInfo: PFaceInfo; const Page: Integer);
var
  i: Integer;
  pLightmap: PRGB888;
  tmpColor: tRGB888;
begin
  {$R-}
  lpFaceInfo.isUniqueLmp[Page]:=False;
  if (Page < 0) then Exit;
  if (Page >= lpFaceInfo.CountLightStyles) then Exit;

  pLightmap:=lpFaceInfo.lpFirstLightmap[Page];
  tmpColor:=pLightmap^;
  Inc(pLightmap);
  for i:=1 to (lpFaceInfo.LmpSquare - 1) do
    begin
      if (pLightmap.r <> tmpColor.r) then Exit;
      if (pLightmap.g <> tmpColor.g) then Exit;
      if (pLightmap.b <> tmpColor.b) then Exit;
      Inc(pLightmap);
    end;

  lpFaceInfo.isUniqueLmp[Page]:=True;
  //
  lpFaceInfo.UniqueHash[Page]:=tmpColor.r
    or (tmpColor.g shl 8)
    or (tmpColor.b shl 16);
  //
  lpFaceInfo.UniqueRenderColor[Page][0]:=tmpColor.r*inv255;
  lpFaceInfo.UniqueRenderColor[Page][1]:=tmpColor.g*inv255;
  lpFaceInfo.UniqueRenderColor[Page][2]:=tmpColor.b*inv255;
  lpFaceInfo.UniqueRenderColor[Page][3]:=1.0;
  {$R+}
end;

procedure SaveLightmapToBitmap(const FileName: String; const lpFaceInfo: PFaceInfo; const Page: Integer);
var
  TexBmp: TBitmap;
  i, j: Integer;
  p: pRGBArray;
  pLightmap: PRGB888;
begin
  {$R-}
  if (Page < 0) then Exit;
  if (Page > 3) then Exit;
  if (lpFaceInfo.OffsetLmp < 0) then Exit;
  if (Page > (lpFaceInfo.CountLightStyles - 1)) then Exit;

  TexBmp:=TBitmap.Create();
  TexBmp.PixelFormat:=pf24bit;
  TexBmp.Width:=lpFaceInfo.LmpSize.X;
  TexBmp.Height:=lpFaceInfo.LmpSize.Y;

  pLightmap:=lpFaceInfo.lpFirstLightmap[Page];
  if (lpFaceInfo.isUniqueLmp[Page]) then
    begin
      TexBmp.Canvas.Pen.Color:=RGB(pLightmap.r, pLightmap.g, pLightmap.b);
      TexBmp.Canvas.Brush.Color:=TexBmp.Canvas.Pen.Color;
      TexBmp.Canvas.FillRect(TexBmp.Canvas.ClipRect);
    end
  else
    begin
      for i:=0 to (lpFaceInfo.LmpSize.Y - 1) do
        begin
          p:=TexBmp.ScanLine[i];
          for j:=0 to (lpFaceInfo.LmpSize.X - 1) do
            begin
              RGB888toTRGBTriple(pLightmap, p^[j]);
              Inc(pLightmap);
            end;
        end;
    end;

  TexBmp.SaveToFile(FileName);
  TexBmp.Destroy();
  {$R+}
end;

function LoadLightmapFromBitmap(const FileName: String; const lpFaceInfo: PFaceInfo; const Page: Integer): tErrLmpBitmap;
var
  TexBmp: TBitmap;
  i, j: Integer;
  p: pRGBArray;
  pLightmap: PRGB888;
begin
  {$R-}
  if (Page < 0) then
    begin
      Result:=elbBadFaceInfo;
      Exit;
    end;
  if (Page > 3) then
    begin
      Result:=elbBadFaceInfo;
      Exit;
    end;
  if (lpFaceInfo.OffsetLmp < 0) then
    begin
      Result:=elbBadFaceInfo;
      Exit;
    end;
  if (Page > (lpFaceInfo.CountLightStyles - 1)) then
    begin
      Result:=elbBadFaceInfo;
      Exit;
    end;

  if (FileExists(FileName) = False) then
    begin
      Result:=elbNoExist;
      Exit;
    end;

  TexBmp:=TBitmap.Create();
  try
    TexBmp.LoadFromFile(FileName);
  except
    Result:=elbNotBitmap;
    TexBmp.Destroy();
    Exit;
  end;

  if (lpFaceInfo.LmpSize.X <> TexBmp.Width) then
    begin
      Result:=elbBadWidth;
      TexBmp.Destroy();
      Exit;
    end;
  if (lpFaceInfo.LmpSize.Y <> TexBmp.Height) then
    begin
      Result:=elbBadHeight;
      TexBmp.Destroy();
      Exit;
    end;

  TexBmp.PixelFormat:=pf24bit;
  pLightmap:=lpFaceInfo.lpFirstLightmap[Page];
  for i:=0 to (lpFaceInfo.LmpSize.Y - 1) do
    begin
      p:=TexBmp.ScanLine[i];
      for j:=0 to (lpFaceInfo.LmpSize.X - 1) do
        begin
          TRGBTripleToRGB888(p^[j], pLightmap);
          Inc(pLightmap);
        end;
    end;

  TexBmp.Destroy();
  Result:=elbNoError;
  UpdateFaceUniqueLightmaps(lpFaceInfo, Page);
  {$R+}
end;

function ShowErrorLoadLightmapFromBitmap(const elbError: tErrLmpBitmap): String;
begin
  {$R-}
  case (elbError) of
    elbNoError: Result:='No errors!';
    elbNoExist: Result:='File is not exists!';
    elbNotBitmap: Result:='File is not Bitmap!';
    elbBadWidth: Result:='Bitmap width must be equal current lightmap width!';
    elbBadHeight: Result:='Bitmap height must be equal current lightmap height!';
    elbBadFaceInfo: Result:='Procedure input param is invalid!';
  else
    Result:='Unknown error!';
  end;
  {$R+}
end;

procedure CreateLightmapTexture(const lpFaceInfo: PFaceInfo; const Page: Integer);
begin
  {$R-}
  glDeleteTextures(1, @lpFaceInfo.LmpPages[Page]);

  if (Page < 0) then Exit;
  if (Page >= lpFaceInfo.CountLightStyles) then Exit;
  if (lpFaceInfo.isUniqueLmp[Page]) then Exit;

  glGenTextures(1, @lpFaceInfo.LmpPages[Page]);
  if (lpFaceInfo.LmpPages[Page] = 0) then Exit;
  glBindTexture(GL_TEXTURE_2D, lpFaceInfo.LmpPages[Page]);

  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

  // GL_REPEAT / GL_CLAMP_TO_EDGE
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  // GL_NEAREST / GL_LINEAR
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

  glTexImage2D(GL_TEXTURE_2D, 0, 3, lpFaceInfo.LmpSize.X, lpFaceInfo.LmpSize.Y, 0,
    GL_RGB, GL_UNSIGNED_BYTE, lpFaceInfo.lpFirstLightmap[Page]);

  glBindTexture(GL_TEXTURE_2D, 0);
  {$R+}
end;

procedure RenderFaceLmp(const RenderInfo: tRenderFaceInfo);
var
  lpFaceInfo: PFaceInfo;
begin
  {$R-}
  if (RenderInfo.Page < 0) then Exit;
  lpFaceInfo:=RenderInfo.lpFaceInfo;
  if (RenderInfo.Page >= lpFaceInfo.CountLightStyles) then Exit;

  if (lpFaceInfo.isUniqueLmp[RenderInfo.Page] = False) then
    begin
      if (lpFaceInfo.LmpPages[RenderInfo.Page] = 0) then Exit;

      glEnableClientState(GL_VERTEX_ARRAY);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);

      glColor4fv(@WhiteColor4f[0]);
      glBindTexture(GL_TEXTURE_2D, lpFaceInfo.LmpPages[RenderInfo.Page]);

      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, RenderInfo.FilterMode);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, RenderInfo.FilterMode);

      glVertexPointer(3, GL_FLOAT, 0, @lpFaceInfo.Vertex[0].x);
      glTexCoordPointer(2, GL_FLOAT, 0, @lpFaceInfo.LmpCoords[0].x);
      glDrawArrays(GL_TRIANGLE_FAN, 0, lpFaceInfo.CountVertex);

      glBindTexture(GL_TEXTURE_2D, 0);
      glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      glDisableClientState(GL_VERTEX_ARRAY);
    end
  else
    begin
      glEnableClientState(GL_VERTEX_ARRAY);

      glColor4fv(@lpFaceInfo.UniqueRenderColor[RenderInfo.Page]);
      glBindTexture(GL_TEXTURE_2D, 0);

      glVertexPointer(3, GL_FLOAT, 0, @lpFaceInfo.Vertex[0].x);
      glDrawArrays(GL_TRIANGLE_FAN, 0, lpFaceInfo.CountVertex);

      glDisableClientState(GL_VERTEX_ARRAY);
    end;
  {$R+}
end;

procedure RenderSelectedFace(const RenderInfo: tRenderFaceInfo; const lpColor: tColor4fv);
var
  lpFaceInfo: PFaceInfo;
begin
  {$R-}
  if (RenderInfo.Page < 0) then Exit;
  lpFaceInfo:=RenderInfo.lpFaceInfo;
  if (RenderInfo.Page >= lpFaceInfo.CountLightStyles) then Exit;

  glEnableClientState(GL_VERTEX_ARRAY);

  glColor4fv(@lpColor[0]);
  glBindTexture(GL_TEXTURE_2D, 0);

  glVertexPointer(3, GL_FLOAT, 0, @lpFaceInfo.Vertex[0].x);
  glDrawArrays(GL_TRIANGLE_FAN, 0, lpFaceInfo.CountVertex);
  
  glDisableClientState(GL_VERTEX_ARRAY);
  {$R+}
end;


function GetRayFaceIntersection(const lpFaceInfo: PFaceInfo; const Ray: tRay; const RayValue: PSingle): Boolean;
var
  tmp, u, v: Single;
  Edge0, Edge1: tVec3f;
  tvec, pvec, qvec: tVec3f;
  i: Integer;
begin
  {$R-}
  // Based on: Moller, Tomas; Trumbore, Ben (1997). "Fast, Minimum Storage 
  // Ray-Triangle Intersection". Journal of Graphics Tools. 2: 21–28. 
  
  if (lpFaceInfo.CountLightStyles = 0) then
    begin
      Result:=False;
      Exit;
    end;
  
  tmp:=Ray.Dir.X*lpFaceInfo.Plane.vNormal.x + Ray.Dir.Y*lpFaceInfo.Plane.vNormal.y
    + Ray.Dir.Z*lpFaceInfo.Plane.vNormal.z;

  // Test that ray "see" Front Face of rectangle
  if (PInteger(@tmp)^ > 0) then
    begin
      Result:=False;
      Exit;
    end;

  // Calculate First Edge
  Edge1.x:=lpFaceInfo.Vertex[1].x - lpFaceInfo.Vertex[0].x;
  Edge1.y:=lpFaceInfo.Vertex[1].y - lpFaceInfo.Vertex[0].y;
  Edge1.z:=lpFaceInfo.Vertex[1].z - lpFaceInfo.Vertex[0].z;

  // Calculate distance from vert0 to ray origin
  tvec.x:=Ray.Start.x - lpFaceInfo.Vertex[0].x;
  tvec.y:=Ray.Start.y - lpFaceInfo.Vertex[0].y;
  tvec.z:=Ray.Start.z - lpFaceInfo.Vertex[0].z;

  for i:=0 to (lpFaceInfo.CountTriangles - 1) do
    begin
      // First Get Edges
      Edge0:=Edge1;
      Edge1.x:=lpFaceInfo.Vertex[i + 2].x - lpFaceInfo.Vertex[0].x;
      Edge1.y:=lpFaceInfo.Vertex[i + 2].y - lpFaceInfo.Vertex[0].y;
      Edge1.z:=lpFaceInfo.Vertex[i + 2].z - lpFaceInfo.Vertex[0].z;

      pvec.x:=Ray.Dir.y*Edge1.z - Ray.Dir.z*Edge1.y;
      pvec.y:=Ray.Dir.z*Edge1.x - Ray.Dir.x*Edge1.z;
      pvec.z:=Ray.Dir.x*Edge1.y - Ray.Dir.y*Edge1.x;

      tmp:=Edge0.x*pvec.x + Edge0.y*pvec.y + Edge0.z*pvec.z;
      // If tmp is near zero, ray lies in plane of triangle
      if ((PInteger(@tmp)^ and $7FFFFFFF) = 0) then Continue;

      // Calculate normalazed U baricentric coordinate and test bounds
      u:=(tvec.x*pvec.x + tvec.y*pvec.y + tvec.z*pvec.z)/tmp;
  
      if (PInteger(@u)^ < 0) then Continue;
      if (u > 1.0) then Continue;

      qvec.x:=tvec.y*Edge0.z - tvec.z*Edge0.y;
      qvec.y:=tvec.z*Edge0.x - tvec.x*Edge0.z;
      qvec.z:=tvec.x*Edge0.y - tvec.y*Edge0.x;

      // Calculate normalazed V baricentric coordinate and test bounds
      v:=(Ray.Dir.x*qvec.x + Ray.Dir.y*qvec.y + Ray.Dir.z*qvec.z)/tmp;

      if (PInteger(@v)^ < 0) then Continue;
      if ((u + v) > 1.0) then Continue;

      // Calculate RayValue trace parameter and test zero bound
      RayValue^:=(Edge1.x*qvec.x + Edge1.y*qvec.y + Edge1.z*qvec.z)/tmp;
      if (PInteger(RayValue)^ < 0 ) then Continue;

      Result:=True;
      Exit;
    end;

  Result:=False;
  {$R+}
end;

end.
