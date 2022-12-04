program GoldSrcViewer;

// Copyright (c) 2020 Sergey-KoRJiK, Belarus

uses
  Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  UnitUserTypes in 'Modules\UnitUserTypes.pas',
  UnitVec in 'Modules\UnitVec.pas',
  UnitOpenGLext in 'Modules\UnitOpenGLext.pas',
  UnitOpenGLErrorManager in 'Modules\UnitOpenGLErrorManager.pas',
  UnitOpenGLAdditional in 'Modules\UnitOpenGLAdditional.pas',
  UnitOpenGLFPSCamera in 'Modules\UnitOpenGLFPSCamera.pas',
  UnitRenderingContextManager in 'Modules\UnitRenderingContextManager.pas',
  UnitShaderManager in 'Modules\UnitShaderManager.pas',
  UnitVertexBufferArrayManager in 'Modules\UnitVertexBufferArrayManager.pas',
  UnitMegatextureManager in 'Modules\UnitMegatextureManager.pas',
  UnitBasetextureManager in 'Modules\UnitBasetextureManager.pas',
  UnitQueryPerformanceTimer in 'Modules\UnitQueryPerformanceTimer.pas',
  UnitRenderTimerManager in 'Modules\UnitRenderTimerManager.pas',
  UnitMapHeader in 'Modules\GoldSrcBSP\UnitMapHeader.pas',
  UnitBSPstruct in 'Modules\GoldSrcBSP\UnitBSPstruct.pas',
  UnitEntity in 'Modules\GoldSrcBSP\UnitEntity.pas',
  UnitPlane in 'Modules\GoldSrcBSP\UnitPlane.pas',
  UnitTexture in 'Modules\GoldSrcBSP\UnitTexture.pas',
  UnitNode in 'Modules\GoldSrcBSP\UnitNode.pas',
  UnitFace in 'Modules\GoldSrcBSP\UnitFace.pas',
  UnitVisLeaf in 'Modules\GoldSrcBSP\UnitVisLeaf.pas',
  UnitMarkSurface in 'Modules\GoldSrcBSP\UnitMarkSurface.pas',
  UnitEdge in 'Modules\GoldSrcBSP\UnitEdge.pas',
  UnitBrushModel in 'Modules\GoldSrcBSP\UnitBrushModel.pas',
  UnitLightEntity in 'Modules\GoldSrcBSP\UnitLightEntity.pas',
  UnitRescaling2D in 'Modules\UnitRescaling2D.pas',
  UnitClipNode in 'Modules\GoldSrcBSP\UnitClipNode.pas';

{$R *.res}
var
  MainForm: TMainForm;
  
begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
