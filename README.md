Copyright (c) 2020 Sergey Smolovsky, Belarus
e-mail: sergeysmol4444@yandex.ru

# This program created for Edit Lightmaps of GldSrc BSP. 
Support import and export Lightmap textures on Face to Bitmap for each Styles on Face. 
Requirements: OpenGL 1.3+; CPU x86 + FPU x87; ~128MB RAM; ~32MB GPU RAM; Win 2000 or great;

The main goal - Color\Pixel Correction of calculated light after light compiler
(bad color, bad black pixel, ... for fun color change). 
For make it:
 - Load BSP Map;
 - Use 3d camera fo find interested Lightmaps;
 - Select Face;
 - Choose Style and save to Bitmap.
 - open Bitmap on any Image tool, that support Bitmap.
 - save with same size of textures
 - import Bitmap
 - go File->Save BSP.
 
Camera help:
view by left mouse botton
move Forward\Backward by keys W\S
step Left\Right by keys A\D.
If camera get out from current Leaf (showed in bottom toolbar)
render is disabled. 
Don't support camera collision with Faces.

Select Face: click by right mouse button on 2d window on interest 
visible lightmap. And on right Face toolbar showed Face info and
tools for choose Lightmap Style and export\import Ligthmaps.
Import Lightmap must be have equal size of Face lightmap W\H.

LICENSE of this project in [thirdpartylegalnotices.txt](https://github.com/Sergey-KoRJiK/GldSrcBSPditor/blob/master/LICENSES/thirdpartylegalnotices.txt) and [Half Life 1 SDK LICENSE](https://github.com/Sergey-KoRJiK/GldSrcBSPditor/blob/master/LICENSES/LICENSE%20HALF-LIFE%20SDK.txt)


# About Code:
Form live start at "procedure TMainForm.FormCreate(Sender: TObject);" in Unit1.pas, where construct opengl renderer and custom managers
live and render in "procedure TMainForm.Idle(Sender: TObject; var Done: Boolean);" and "procedure TMainForm.PanelRTResize(Sender: TObject);"
and dead in "procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);"
"procedure TMainForm.LoadMapMenuClick(Sender: TObject);" and "procedure TMainForm.CloseMapMenuClick(Sender: TObject);" - live of BSP map.
LoadBSP30FromFile called from Modules/GoldSrcBSP/UnitBSPstruct.pas and that it's main file of GoldSrc map definition,
each pas file in same folder incapsulate one or more BSP lump.
UnitOpenGLext.pas contain OpenGL extenstion to 4.6 of default build-in Delphi 7 OpenGL 1.0.
UnitOpenGLFPSCamera.pas contain class of player view camera and generation projection matrix.
UnitMegatextureManager.pas contin manager for quake2-style lightmap megatexture packing and management.
UnitQueryPerformanceTimer.pas contain class that incapsulate WinAPI QueryPerformanceCounter for time measurement.
UnitRenderingContextManager.pas incapsulate in class wglCreateContext and free method of it.
UnitRescaling2D.pas used for preview selected face textures in middle-left status bar.
UnitVec.pas and UnitUserTypes.pas contain based types and routine functions, used by all project .pas code-files.
