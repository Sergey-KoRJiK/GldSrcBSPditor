unit EXTOpengl32Glew32;

// Copyright (c) 2019 Sergey Smolovsky, Belarus

interface

uses SysUtils, Windows, OpenGL;

type PGLenum = ^GLenum;
type PPChar = ^PChar;

// OpenGL Extension 1.1 and 1.2
const
  GL_CLAMP_TO_EDGE = 33071;

  GL_VERTEX_ARRAY = 32884;
  GL_NORMAL_ARRAY = 32885;
  GL_COLOR_ARRAY = 32886;
  GL_INDEX_ARRAY = 32887;
  GL_TEXTURE_COORD_ARRAY = 32888;

procedure glEnableClientState(cap: GLenum); stdcall;
procedure glDisableClientState(cap: GLenum); stdcall;

procedure glNormalPointer(typed: GLenum; stride: GLsizei; const p: Pointer); stdcall;
procedure glVertexPointer(size: GLint; typed: GLenum; stride: GLsizei; const p: Pointer); stdcall;
procedure glColorPointer(size: GLint; typed: GLenum; stride: GLsizei; const p: Pointer); stdcall;
procedure glTexCoordPointer(size: GLint; typed: GLenum; stride: GLsizei; const p: Pointer); stdcall;

procedure glDrawArrays(mode: GLenum; first: GLint; count: GLsizei); stdcall;
procedure glDrawElements(mode: GLenum; count: GLsizei; typed :GLenum; const indices: Pointer); stdcall;

procedure glGenTextures(n: GLsizei; textures: PGLuint); stdcall;
procedure glDeleteTextures(n: GLsizei; textures: PGLuint); stdcall;
procedure glBindTexture(target:	GLenum; texture: GLuint); stdcall;


implementation

const gl  = 'opengl32.dll';

procedure glEnableClientState(cap: GLenum); stdcall; external gl;
procedure glDisableClientState(cap: GLenum); stdcall; external gl;

procedure glNormalPointer(typed: GLenum; stride: GLsizei; const p: Pointer); stdcall; external gl;
procedure glVertexPointer(size: GLint; typed: GLenum; stride: GLsizei; const p: Pointer); stdcall; external gl;
procedure glColorPointer(size: GLint; typed: GLenum; stride: GLsizei; const p: Pointer); stdcall; external gl;
procedure glTexCoordPointer(size: GLint; typed: GLenum; stride: GLsizei; const p: Pointer); stdcall; external gl;
  
procedure glDrawArrays(mode: GLenum; first: GLint; count: GLsizei); stdcall; external gl;
procedure glDrawElements(mode: GLenum; count: GLsizei; typed :GLenum; const indices: Pointer); stdcall; external gl;

procedure glGenTextures(n: GLsizei; textures: PGLuint); stdcall; external gl;
procedure glDeleteTextures(n: GLsizei; textures: PGLuint); stdcall; external gl;
procedure glBindTexture(target:	GLenum; texture: GLuint); stdcall; external gl;


end.
