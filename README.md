Copyright (c) 2020 Sergey Smolovsky, Belarus
e-mail: sergeysmol4444@mail.ru

# This program created for Edit Lightmaps of GldSrc BSP. 
Support import and export Lightmap textures on Face to Bitmap for each Styles on Face. 

### For download compiled standalone tool, click [here](https://github.com/Sergey-KoRJiK/GldSrcBSPditor/raw/master/GoldSrcViewer.exe)

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
 
also tool contain import\export of all lightmaps in map to one big Bitmap.
It if u need global color correction for lightmaps.
 
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

In Option up toolbar u can select which Faces need render 
(World Brush\ Entity Brush) and select
render type (WallHack (XRay) or Default), select show/hode toolbars.

Valid VisLeaf showed as Blue BBOX.

LICENSE of this project in [thirdpartylegalnotices.txt](https://github.com/Sergey-KoRJiK/GldSrcBSPditor/blob/master/LICENSES/thirdpartylegalnotices.txt) 
