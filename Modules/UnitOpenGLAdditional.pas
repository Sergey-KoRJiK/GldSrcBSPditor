unit UnitOpenGLAdditional;

// Copyright (c) 2019 Sergey-KoRJiK, Belarus
// github.com/Sergey-KoRJiK

interface

uses 
	SysUtils, 
	Windows, 
	Classes, 
	OpenGL,
  UnitOpenGLext;

const
  LineOrtsLength = 50;
  LineOrtsOffset = 0;
  LineOrstWidth: GLfloat = 1.5;
  OrtsColorSaturation = 0.6; // from 0 (b/w) to 1 (default)

  OrtsVertexies: array[0..17] of GLshort = (
    LineOrtsOffset, 0, 0,    LineOrtsLength + LineOrtsOffset, 0, 0,
    0, LineOrtsOffset, 0,    0, LineOrtsLength + LineOrtsOffset, 0,
    0, 0, LineOrtsOffset,    0, 0, LineOrtsLength + LineOrtsOffset
  );

  OrtMainColor = (1 + 2*OrtsColorSaturation)/3;
  OrtSecondColor = (1 - OrtsColorSaturation)/3;
  OrtsColors: array[0..17] of GLfloat = (
    OrtMainColor, OrtSecondColor, OrtSecondColor,
    OrtMainColor, OrtSecondColor, OrtSecondColor,
    OrtSecondColor, OrtSecondColor, OrtMainColor,
    OrtSecondColor, OrtSecondColor, OrtMainColor,
    OrtSecondColor, OrtMainColor, OrtSecondColor,
    OrtSecondColor, OrtMainColor, OrtSecondColor
  );


function GenListOrts(): GLuint;
function GenListCubeWireframe(const lpColor4fv: Pointer): GLuint; // cube 2x2x2


implementation


procedure glEnableClientState(cap: GLenum); stdcall; external opengl32;
procedure glDisableClientState(cap: GLenum); stdcall; external opengl32;

function GenListOrts(): GLuint; 
begin
  {$R-}
  Result:=glGenLists(1);
  if (Result = 0) then Exit;  

  glNewList(Result, GL_COMPILE);
  glBegin(GL_LINES);
    glColor3fv(@OrtsColors[0]);
    glVertex3sv(@OrtsVertexies[0]);
    glColor3fv(@OrtsColors[3]);
    glVertex3sv(@OrtsVertexies[3]);

    glColor3fv(@OrtsColors[6]);
    glVertex3sv(@OrtsVertexies[6]);
    glColor3fv(@OrtsColors[9]);
    glVertex3sv(@OrtsVertexies[9]);

    glColor3fv(@OrtsColors[12]);
    glVertex3sv(@OrtsVertexies[12]);
    glColor3fv(@OrtsColors[15]);
    glVertex3sv(@OrtsVertexies[15]);
  glEnd(); //} 
  glEndList();
  {$R+}
end;

function GenListCubeWireframe(const lpColor4fv: Pointer): GLuint;
const
  CubeVertecies: array[0..23] of GLfloat = (
    0, 0, 0,    0, 0, 1,    0, 1, 1,    0, 1, 0,
    1, 0, 0,    1, 0, 1,    1, 1, 1,    1, 1, 0
  );
  CubeIndeches: array[0..29] of GLubyte = (
    0, 1, 2, 3, 0,
    4, 5, 6, 7, 4,
    0, 5, 2, 7, 0,
    1, 6, 3, 4 ,1,
    0, 2, 6, 4, 0,
    1, 3, 7, 5, 1
  );
begin
  Result:=glGenLists(1);
  if (Result = 0) then Exit;

  glNewList(Result, GL_COMPILE);

  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0, @CubeVertecies[0]);

  glColor4fv(lpColor4fv);
  glLineWidth(2.0);
  glDrawElements(GL_LINE_STRIP, 30, GL_UNSIGNED_BYTE, @CubeIndeches[0]);

  glDisableClientState(GL_VERTEX_ARRAY);
	glEndList();
end;




end.

