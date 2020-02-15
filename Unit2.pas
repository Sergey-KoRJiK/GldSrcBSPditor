unit Unit2;

// Copyright (c) 2020 Sergey Smolovsky, Belarus

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  {}
  UnitVec,
  UnitPlane,
  UnitFace,
  UnitBSPStruct;

type
  TFaceToolForm = class(TForm)
    OpenDialogBMP: TOpenDialog;
    SaveDialogBMP: TSaveDialog;
    MemoFaceInfo: TMemo;
    RadioGroupLmp: TRadioGroup;
    ButtonSaveLmp: TButton;
    ButtonLoadLmp: TButton;
    procedure FormCreate(Sender: TObject);
    //
    procedure UpdateFaceVisualInfo();
    procedure ClearFaceVisualInfo();
    procedure ButtonSaveLmpClick(Sender: TObject);
    procedure ButtonLoadLmpClick(Sender: TObject);
  private
    { Private declarations }
  public
    lpMap: PMapBSP;
    FaceSelectedIndex: Integer;
    SelectedStyle: Integer;
    CurrFace: PFace;
    CurrFaceInfo: PFaceInfo;
  end;

var
  FaceToolForm: TFaceToolForm;


implementation

{$R *.dfm}


procedure TFaceToolForm.FormCreate(Sender: TObject);
begin
  {$R-}
  Self.FaceSelectedIndex:=-1;
  Self.SelectedStyle:=0;
  Self.CurrFace:=nil;
  Self.CurrFaceInfo:=nil;
  Self.lpMap:=nil;
  {$R+}
end;

procedure TFaceToolForm.UpdateFaceVisualInfo();
const
  StyleStr: array[0..3] of String = (
    'Style[0]',
    'Style[1]',
    'Style[2]',
    'Style[3]'
  );
var
  i: Integer;
begin
  {$R-}
  if (Self.FaceSelectedIndex < 0) then
    begin
      Self.ClearFaceVisualInfo();
      Exit;
    end;

  Self.MemoFaceInfo.Lines.Clear();
  Self.MemoFaceInfo.Lines.BeginUpdate();
  Self.MemoFaceInfo.Lines.Append('Face Index:  ' + IntToStr(Self.FaceSelectedIndex));
  Self.MemoFaceInfo.Lines.Append('Texture: ' + Self.CurrFaceInfo.TexName);
  //
  Self.MemoFaceInfo.Lines.Append('Lightmap Width:  ' + IntToStr(Self.CurrFaceInfo.LmpSize.X));
  Self.MemoFaceInfo.Lines.Append('Lightmap Height: ' + IntToStr(Self.CurrFaceInfo.LmpSize.Y));
  //
  Self.MemoFaceInfo.Lines.Append('Count Styles: ' + IntToStr(Self.CurrFaceInfo.CountLightStyles));
  Self.MemoFaceInfo.Lines.Append('Style[0]: ' + IntToStr(Self.CurrFace.nStyles[0])
    + '; Unique: ' + BoolToStrYesNo(Self.CurrFaceInfo.isUniqueLmp[0]));
  Self.MemoFaceInfo.Lines.Append('Style[1]: ' + IntToStr(Self.CurrFace.nStyles[1])
    + '; Unique: ' + BoolToStrYesNo(Self.CurrFaceInfo.isUniqueLmp[1]));
  Self.MemoFaceInfo.Lines.Append('Style[2]: ' + IntToStr(Self.CurrFace.nStyles[2])
    + '; Unique: ' + BoolToStrYesNo(Self.CurrFaceInfo.isUniqueLmp[2]));
  Self.MemoFaceInfo.Lines.Append('Style[3]: ' + IntToStr(Self.CurrFace.nStyles[3])
    + '; Unique: ' + BoolToStrYesNo(Self.CurrFaceInfo.isUniqueLmp[3]));
  //
  Self.MemoFaceInfo.Lines.Append('');
  Self.MemoFaceInfo.Lines.Append('TexInfo Index:  ' + IntToStr(Self.CurrFace.iTextureInfo));
  Self.MemoFaceInfo.Lines.Append('Texture Index:  ' + IntToStr(Self.CurrFaceInfo.Wad3TextureIndex));
  Self.MemoFaceInfo.Lines.Append('Plane Index:    ' + IntToStr(Self.CurrFace.iPlane));
  Self.MemoFaceInfo.Lines.Append('VisLeaf Index:  ' + IntToStr(Self.CurrFaceInfo.VisLeafId));
  Self.MemoFaceInfo.Lines.Append('EntBrush Index: ' + IntToStr(Self.CurrFaceInfo.BrushId));
  //
  Self.MemoFaceInfo.Lines.EndUpdate();

  Self.RadioGroupLmp.Items.Clear();
  for i:=0 to (Self.CurrFaceInfo.CountLightStyles - 1) do
    begin
      Self.RadioGroupLmp.Items.Append(StyleStr[i]);
    end;
  Self.RadioGroupLmp.ItemIndex:=Self.SelectedStyle;
  {$R+}
end;

procedure TFaceToolForm.ClearFaceVisualInfo();
begin
  {$R-}
  Self.FaceSelectedIndex:=-1;
  Self.CurrFace:=nil;
  Self.CurrFaceInfo:=nil;
  Self.SelectedStyle:=0;

  Self.MemoFaceInfo.Lines.Clear();
  Self.RadioGroupLmp.Items.Clear();
  {$R+}
end;

procedure TFaceToolForm.ButtonSaveLmpClick(Sender: TObject);
begin
  {$R-}
  if (Self.FaceSelectedIndex < 0) then Exit;
  if (Self.RadioGroupLmp.ItemIndex >= Self.CurrFaceInfo.CountLightStyles) then Exit;
  if (Self.RadioGroupLmp.ItemIndex < 0) then Exit;

  if (Self.SaveDialogBMP.Execute) then
    begin
      SaveLightmapToBitmap(
        Self.SaveDialogBMP.FileName,
        Self.CurrFaceInfo,
        Self.RadioGroupLmp.ItemIndex
      );
    end;
  {$R+}
end;

procedure TFaceToolForm.ButtonLoadLmpClick(Sender: TObject);
var
  isLoaded: tErrLmpBitmap;
begin
  {$R-}
  if (Self.FaceSelectedIndex < 0) then Exit;
  if (Self.RadioGroupLmp.ItemIndex >= Self.CurrFaceInfo.CountLightStyles) then Exit;
  if (Self.RadioGroupLmp.ItemIndex < 0) then Exit;

  if (Self.OpenDialogBMP.Execute) then
    begin
      isLoaded:=LoadLightmapFromBitmap(
        Self.OpenDialogBMP.FileName,
        Self.CurrFaceInfo,
        Self.RadioGroupLmp.ItemIndex
      );

      if (isLoaded <> elbNoError) then
        begin
          ShowMessage(ShowErrorLoadLightmapFromBitmap(isLoaded));
        end
      else
        begin
          CreateLightmapTexture(Self.CurrFaceInfo, Self.RadioGroupLmp.ItemIndex);
          Self.UpdateFaceVisualInfo();
        end;
    end;
  {$R+}
end;

end.
