program GoldSrcViewer;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

uses
  Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  UnitOpenGLAdditional in 'UnitOpenGLAdditional.pas',
  UnitOpenGLFPSCamera in 'UnitOpenGLFPSCamera.pas',
  EXTOpengl32Glew32 in 'EXTOpengl32Glew32.pas',
  UnitVec in 'Modules\UnitVec.pas',
  UnitBSPstruct in 'Modules\UnitBSPstruct.pas',
  UnitEntity in 'Modules\UnitEntity.pas',
  UnitPlane in 'Modules\UnitPlane.pas',
  UnitTexture in 'Modules\UnitTexture.pas',
  UnitMapHeader in 'Modules\UnitMapHeader.pas',
  UnitNode in 'Modules\UnitNode.pas',
  UnitFace in 'Modules\UnitFace.pas',
  UnitVisLeaf in 'Modules\UnitVisLeaf.pas',
  UnitMarkSurface in 'Modules\UnitMarkSurface.pas',
  UnitEdge in 'Modules\UnitEdge.pas',
  UnitBrushModel in 'Modules\UnitBrushModel.pas',
  UnitRayTraceOpenGL in 'UnitRayTraceOpenGL.pas',
  Unit2 in 'Unit2.pas' {FaceToolForm},
  UnitVSync in 'UnitVSync.pas';

{$R *.res}
var
  MainForm: TMainForm;
  
begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
