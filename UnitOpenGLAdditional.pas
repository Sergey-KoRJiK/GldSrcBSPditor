unit UnitOpenGLAdditional;

// Copyright (c) 2019 Sergey Smolovsky, Belarus

interface

uses SysUtils, Windows, Classes, OpenGL, EXTOpengl32Glew32, UnitVec;

const
  //"Очистка буфера цвета, глубины"
  glBufferClearBits = GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT;
  
  OrdW = Ord('W');
  OrdS = Ord('S');
  OrdA = Ord('A');
  OrdD = Ord('D');
  OrdF = Ord('F');

procedure SetDCPixelFormat(const InHDC: HDC);
// важная функция определения и установки формата пикселя

function GenListOrts(): GLuint;
function GenListCubeWireframe(const lpColor4fv: Pointer): GLuint; // кубик 2x2x2

procedure InitGL();


implementation


procedure SetDCPixelFormat(const InHDC: HDC);
var
  pfd: TPixelFormatDescriptor;
  nPixelFormat: Integer;
begin
  {$R-}
  FillChar(pfd, SizeOf(pfd), 0);
  pfd.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  pfd.cDepthBits:=32;

  nPixelFormat:=ChoosePixelFOrmat(InHDC, @pfd); //забираем формат пикселя с hdc
  SetPixelFormat(InHDC, nPixelFormat, @pfd); // устанавливаем формат пикселя в hdc
  {$R+}
end;


function GenListOrts(): GLuint;
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
begin
  {$R-}
  Result:=glGenLists(1);
  if (Result = 0) then Exit;  

  glNewList(Result, GL_COMPILE);
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);

  glVertexPointer(3, GL_SHORT, 0, @OrtsVertexies[0]);
  glColorPointer(3, GL_FLOAT, 0, @OrtsColors[0]);

  glLineWidth(LineOrstWidth);
  glDrawArrays(GL_LINES, 0, 6);

  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glEndList();	//=========================================================
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


procedure InitGL();
begin
  {$R-}
  glEnable(GL_TEXTURE_2D); // Enable Textures
  glEnable(GL_DEPTH_TEST);  // Enable Depth Buffer
  glEnable(GL_CULL_FACE); // Enable Face Normal Test
  glCullFace(GL_FRONT); // which Face side render, Front or Back
  glPolygonMode(GL_BACK, GL_FILL); // GL_FILL, GL_LINE, GL_POINT
  
  glDepthMask ( GL_TRUE ); // Enable Depth Test
  glDepthFunc(GL_LEQUAL);  // type of Depth Test
  glEnable(GL_NORMALIZE); // automatic Normalize

  glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
  glEnable(GL_COLOR_MATERIAL);

  glShadeModel(GL_POLYGON_SMOOTH); // Interpolation color type
  // GL_FLAT - Color dont interpolated, GL_SMOOTH - linear interpolate
  // GL_POLYGON_SMOOTH

  glAlphaFunc(GL_GEQUAL, 0.1);
  glEnable(GL_ALPHA_TEST);

  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  
  // point border smooth
  glEnable(GL_POINT_SMOOTH);
  glHint(GL_POINT_SMOOTH_HINT, GL_NICEST); //GL_FASTEST/GL_NICEST
  // line border smooth
  glEnable(GL_LINE_SMOOTH);
  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
  // polygon border smooth
  //glEnable(GL_POLYGON_SMOOTH);
  glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
  // 
  glHint(GL_Perspective_Correction_Hint, GL_NICEST); //}

  glClearStencil(0);
  glClearDepth(1);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  {$R+}
end;

end.

