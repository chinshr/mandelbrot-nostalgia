(*----------------------------------------------------------------------------
 *
 *  Main.pas
 *
 *  Copyright (c) 1998 Inprise Corporation. All Rights Reserved.
 *
 *  Entera Samples Group
 *
 *----------------------------------------------------------------------------*)
unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, Gauges,
  About, ComCtrls, fractal_c, fractal_hc, oden40, odenconst40, ImgList, ToolWin, Thread;


type
  TMainForm = class(TForm)
      ImageFrame: TPanel;
      FractalMenu: TMainMenu;
      Fractal1: TMenuItem;
      Help1: TMenuItem;
      StartItem: TMenuItem;
      About: TMenuItem;
      Quit1: TMenuItem;
      Exit1: TMenuItem;
      StopItem: TMenuItem;
      StatusBar: TStatusBar;
      Options1: TMenuItem;
      Image: TPaintBox;
    N1: TMenuItem;
    ColorsItem: TMenuItem;
    RedItem: TMenuItem;
    GreenItem: TMenuItem;
    BlueItem: TMenuItem;
    ColorfulItem: TMenuItem;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    Red1: TMenuItem;
    Blue1: TMenuItem;
    Green1: TMenuItem;
    Colorful1: TMenuItem;
    StatisticsItem: TMenuItem;
    FocusedItem: TMenuItem;
    SaveAsItem: TMenuItem;
    N2: TMenuItem;
    SaveDialog1: TSaveDialog;
    Calculate1: TMenuItem;
    LocalItem: TMenuItem;
    RemoteItem: TMenuItem;
    Entera4Item: TMenuItem;
    CORBAItem: TMenuItem;
    CoolBar2: TCoolBar;
    ToolBar1: TToolBar;
    StartButton: TToolButton;
    SaveAsButton: TToolButton;
    ToolButton2: TToolButton;
    RemoteButton: TToolButton;
    StatisticsButton: TToolButton;
    FocusedButton: TToolButton;
    ColorsButton: TToolButton;
    PopupMenu2: TPopupMenu;
    Entera4x1: TMenuItem;
    CORBA1: TMenuItem;
      procedure FormResize(Sender: TObject);
      procedure StartItemClick(Sender: TObject);
      procedure Exit1Click(Sender: TObject);
      procedure StopItemClick(Sender: TObject);
      procedure AboutClick(Sender: TObject);
      procedure ThreadDone(Sender: TObject);
      procedure EnableControls;
      procedure DisableControls;
      procedure CalculateItemClick(Sender: TObject);
    procedure ImagePaint(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure RemoteButtonClick(Sender: TObject);
    procedure RedItemClick(Sender: TObject);
    procedure GreenItemClick(Sender: TObject);
    procedure BlueItemClick(Sender: TObject);
    procedure ColorfulItemClick(Sender: TObject);
    procedure ImageDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StatisticsItemClick(Sender: TObject);
    procedure StatisticsButtonClick(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FocusedButtonClick(Sender: TObject);
    procedure FocusedItemClick(Sender: TObject);
    procedure SaveAsItemClick(Sender: TObject);
    procedure LocalItemClick(Sender: TObject);
    procedure RemoteItemClick(Sender: TObject);
    procedure Entera4ItemClick(Sender: TObject);
    procedure CORBAItemClick(Sender: TObject);
    procedure Entera4x1Click(Sender: TObject);
    procedure CORBA1Click(Sender: TObject);
    procedure ColorsButtonClick(Sender: TObject);
    public
      Bitmap : TBitmap;
      Thread : TParentThread;
      StatusText : string;

      FMndSet: mndset_t;
      FFocus: TRect;
      FFocused: boolean;
      FDragging: boolean;

      procedure UpdateCaption;
      procedure UpdateImage;
      procedure PreparePicture;
      procedure StopThread;
      procedure ShowStats;
      procedure EnableFocus;
      procedure DisableFocus;
      procedure ResetMndSet;
  end;

const
  DAPFILE = 'fractal.dap';
  REMOTE_IMAGE_INDEX = 17;
  LOCAL_IMAGE_INDEX = 18;
  RED_IMAGE_INDEX = 13;
  GREEN_IMAGE_INDEX = 14;
  BLUE_IMAGE_INDEX = 15;
  COLORFUL_IMAGE_INDEX = 16;

var
  MainForm: TMainForm;

implementation

uses StatsDlg;

{$R *.DFM}

const
  GapInPixels  = 1;
  WinBorder    = 25;
  StatusHeight = 25;


procedure TMainForm.FormResize(Sender: TObject);
begin
  ImagePaint(Self);
  UpdateCaption;
end;

procedure TMainForm.StartItemClick(Sender: TObject);
var
  ColorType: integer;
  rw: double;
  ih: double;
begin
  DisableControls;
  PreparePicture;

  // Colors
  if RedItem.Checked then
    ColorType:=1;
  if GreenItem.Checked then
    ColorType:=2;
  if BlueItem.Checked then
    ColorType:=3;
  if ColorfulItem.Checked then
    ColorType:=4;

  // Focus
  if FFocused then
  begin
    with FMndSet do
    begin
      rw:=Abs(real_max-real_min);
      real_max:=real_min+(rw*FFocus.Right/Image.Width);
      real_min:=real_min+(rw*FFocus.Left/Image.Width);
      ih:=Abs(imag_max-imag_min);
      imag_max:=imag_min+(ih*FFocus.Bottom/Image.Height);
      imag_min:=imag_min+(ih*FFocus.Top/Image.Height);
    end;
    FFocused:=false;
  end;

  if (RemoteItem.Checked and Entera4Item.Checked) then
    Thread:=TEnteraThread.Create(Bitmap.Canvas, Image.Width, Image.Height, ColorType, FMndSet)
  else
    if (LocalItem.Checked) then
      Thread:=TLocalThread.Create(Bitmap.Canvas, Image.Width, Image.Height, ColorType, FMndSet);
end;

procedure TMainForm.ThreadDone(Sender: TObject);
begin
  DisableFocus;
  EnableControls;
end;

procedure TMainForm.EnableControls;
begin
  StartItem.Enabled:=true;
  StopItem.Enabled:=false;
  Entera4Item.Enabled:=true;
  StartButton.Enabled:=true;
  RemoteButton.Enabled:=true;
  ColorsButton.Enabled:=true;
  StartButton.Down:=false;
  ColorsItem.Enabled:=true;
  if nil<>Bitmap then
  begin
    SaveAsItem.Enabled:=true;
    SaveAsButton.Enabled:=true;
  end;
  if RemoteItem.Checked then
  begin
    RemoteButton.ImageIndex:=REMOTE_IMAGE_INDEX;
    RemoteButton.Tag:=1;
  end
  else
  begin
    RemoteButton.ImageIndex:=LOCAL_IMAGE_INDEX;
    RemoteButton.Tag:=0;
  end;
  if StatisticsItem.Checked then
    StatisticsButton.Down:=true
  else
    StatisticsButton.Down:=false;
end;

procedure TMainForm.DisableControls;
begin
  StartItem.Enabled:=false;
  StopItem.Enabled:=true;
  Entera4Item.Enabled:=false;
  RemoteButton.Enabled:=false;
  ColorsButton.Enabled:=false;
  StartButton.Down:=true;
  ColorsItem.Enabled:=false;
  if nil<>Bitmap then
  begin
    SaveAsItem.Enabled:=false;
    SaveAsButton.Enabled:=false;
  end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  StopThread;
  Close;
end;


procedure TMainForm.StopItemClick(Sender: TObject);
begin
  StopThread;
  EnableControls;
end;

procedure TMainForm.AboutClick(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.CalculateItemClick(Sender: TObject);
begin
  if Entera4Item.Checked then
  begin
    Entera4Item.Checked:=false;
    RemoteButton.Down:=false;
  end
  else
  begin
    Entera4Item.Checked:=true;
    RemoteButton.Down:=true;
  end;
  UpdateCaption;
end;

procedure TMainForm.UpdateCaption;
var
  XSize, YSize : string[5];
begin
  if (Entera4Item.Checked) then
    StatusBar.Panels[1].Text:='Remote'
  else
    StatusBar.Panels[1].Text:='Local';

  Str(Image.Width,XSize);
  Str(Image.Height,YSize);
  StatusBar.Panels[2].Text:=' '+XSize+' x '+YSize+' pixels';
end;

procedure TMainForm.PreparePicture;
begin
  if nil<>Bitmap then
    Bitmap.Destroy;
  Bitmap:=TBitmap.Create;
  Bitmap.Width:=Image.Width;
  Bitmap.Height:=Image.Height;
  Bitmap.HandleType:=bmDIB;
end;

procedure TMainForm.StopThread;
begin
  if not StartItem.Enabled then
  begin
    Thread.Suspend;
    Thread.Terminate;
    Thread.ThreadDone(TObject(MainForm));
  end;
end;

procedure TMainForm.ShowStats;
begin
  if StatisticsItem.Checked then
    StatsDialog.ShowModal;
end;

procedure TMainForm.ImagePaint(Sender: TObject);
begin
  Image.Canvas.Draw(0, 0, Bitmap);
  if FFocused then
    with Image.Canvas do
      DrawFocusRect( FFocus );
end;

procedure TMainForm.UpdateImage;
begin
  Image.Canvas.Draw(0, 0, Bitmap);
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
begin
  if StartButton.Down=true then
  begin
    StartItemClick(Sender);
  end
  else
  begin
    StopItemClick(Sender);
  end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  ResetMndSet;
  EnableControls;
end;

procedure TMainForm.RemoteButtonClick(Sender: TObject);
begin
  if RemoteButton.Tag=0 then
  begin
    RemoteButton.ImageIndex:=REMOTE_IMAGE_INDEX;
    RemoteButton.Tag:=1;
    RemoteItem.Checked:=true;
    LocalItem.Checked:=false;
    RemoteButton.Hint:='Remote';
  end
  else
  begin
    RemoteButton.ImageIndex:=LOCAL_IMAGE_INDEX;
    RemoteButton.Tag:=0;
    RemoteItem.Checked:=false;
    LocalItem.Checked:=true;
    RemoteButton.Hint:='Local';
  end;
  UpdateCaption;
end;

procedure TMainForm.RedItemClick(Sender: TObject);
begin
  RedItem.Checked:=true;
  GreenItem.Checked:=false;
  BlueItem.Checked:=false;
  ColorfulItem.Checked:=false;
  Red1.Checked:=true;
  Green1.Checked:=false;
  Blue1.Checked:=false;
  Colorful1.Checked:=false;
  ColorsButton.ImageIndex:=RED_IMAGE_INDEX;
end;

procedure TMainForm.GreenItemClick(Sender: TObject);
begin
  RedItem.Checked:=false;
  GreenItem.Checked:=true;
  BlueItem.Checked:=false;
  ColorfulItem.Checked:=false;
  Red1.Checked:=false;
  Green1.Checked:=true;
  Blue1.Checked:=false;
  Colorful1.Checked:=false;
  ColorsButton.ImageIndex:=GREEN_IMAGE_INDEX;
end;

procedure TMainForm.BlueItemClick(Sender: TObject);
begin
  RedItem.Checked:=false;
  GreenItem.Checked:=false;
  BlueItem.Checked:=true;
  ColorfulItem.Checked:=false;
  Red1.Checked:=false;
  Green1.Checked:=false;
  Blue1.Checked:=true;
  Colorful1.Checked:=false;
  ColorsButton.ImageIndex:=BLUE_IMAGE_INDEX;
end;

procedure TMainForm.ColorfulItemClick(Sender: TObject);
begin
  RedItem.Checked:=false;
  GreenItem.Checked:=false;
  BlueItem.Checked:=false;
  ColorfulItem.Checked:=true;
  Red1.Checked:=false;
  Green1.Checked:=false;
  Blue1.Checked:=false;
  Colorful1.Checked:=true;
  ColorsButton.ImageIndex:=COLORFUL_IMAGE_INDEX;
end;

procedure TMainForm.ImageDblClick(Sender: TObject);
begin
  StopItemClick(Sender);
  StartItemClick(Sender);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopThread;
end;

procedure TMainForm.StatisticsItemClick(Sender: TObject);
begin
  if StatisticsItem.Checked then
  begin
    StatisticsItem.Checked:=false;
    StatisticsButton.Down:=false;
  end
  else
  begin
    StatisticsItem.Checked:=true;
    StatisticsButton.Down:=true;
  end;
end;

procedure TMainForm.StatisticsButtonClick(Sender: TObject);
begin
  if StatisticsButton.Down then
  begin
    StatisticsItem.Checked:=true;
  end
  else
  begin
    StatisticsItem.Checked:=false;
  end;

end;

procedure TMainForm.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    if FFocused then
    begin
      with Image.Canvas do
        DrawFocusRect( FFocus );
      DisableFocus;
    end;
    FDragging:=true;
    FFocus.Left:=X;
    FFocus.Top:=Y;
    FFocus.Right:=X+1;
    FFocus.Bottom:=Y+1;
  end;
end;

procedure TMainForm.ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ssLeft in Shift then
  begin
    if FDragging then
      with Image.Canvas do
        DrawFocusRect( FFocus );
    FFocus.Right:=X;
    FFocus.Bottom:=Y;
    with Image.Canvas do
      DrawFocusRect( FFocus );
  end;
end;

procedure TMainForm.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then
  begin
    if FDragging then
      with Image.Canvas do
        DrawFocusRect( FFocus );
    FDragging:=false;
    FFocus.Right:=X;
    FFocus.Bottom:=Y;
    EnableFocus;
  end;
end;

procedure TMainForm.FocusedButtonClick(Sender: TObject);
begin
  if not FocusedButton.Down then
  begin
    ResetMndSet;
    DisableFocus;
  end;
end;

procedure TMainForm.FocusedItemClick(Sender: TObject);
begin
  if FocusedItem.Checked then
  begin
    FocusedItem.Checked:=false;
    ResetMndSet;
    DisableFocus;
  end
  else
  begin
    FocusedItem.Checked:=true;
    EnableFocus;
  end;
end;

procedure TMainForm.EnableFocus;
begin
  FFocused:=true;
  FocusedButton.Enabled:=true;
  FocusedButton.Down:=true;
  FocusedItem.Enabled:=true;
  FocusedItem.Checked:=true;
  FocusedButton.Hint:='Focused';
  ImagePaint(Self);
end;

procedure TMainForm.DisableFocus;
begin
  FFocused:=false;
  FocusedButton.Enabled:=false;
  FocusedItem.Enabled:=false;
  FocusedItem.Checked:=false;
  FocusedButton.Hint:='Unfocused';
  ImagePaint(Self);
end;

procedure TMainForm.ResetMndSet;
begin
  FMndSet.real_min:=-2.1;
  FMndSet.real_max:=1.1;
  FMndSet.imag_min:=-1.25;
  FMndSet.imag_max:=1.25;
end;

procedure TMainForm.SaveAsItemClick(Sender: TObject);
begin
  if nil<>Bitmap then
  begin
    SaveDialog1.DefaultExt := GraphicExtension(TBitmap);
    SaveDialog1.Filter := GraphicFilter(TBitmap);

    if SaveDialog1.Execute then
    begin
      Bitmap.SaveToFile(SaveDialog1.Filename);
    end;
  end;
end;

procedure TMainForm.LocalItemClick(Sender: TObject);
begin
  LocalItem.Checked:=true;
  RemoteItem.Checked:=false;
  RemoteButton.ImageIndex:=LOCAL_IMAGE_INDEX;
  RemoteButton.Tag:=0;
end;

procedure TMainForm.RemoteItemClick(Sender: TObject);
begin
  LocalItem.Checked:=false;
  RemoteItem.Checked:=true;
  RemoteButton.ImageIndex:=REMOTE_IMAGE_INDEX;
  RemoteButton.Tag:=1;
end;

procedure TMainForm.Entera4ItemClick(Sender: TObject);
begin
  RemoteItem.Checked:=true;
  Entera4Item.Checked:=true;
  CORBAItem.Checked:=false;
  Entera4x1.Checked:=true;
  CORBA1.Checked:=false;
end;

procedure TMainForm.CORBAItemClick(Sender: TObject);
begin
  RemoteItem.Checked:=true;
  Entera4Item.Checked:=false;
  CORBAItem.Checked:=true;
  Entera4x1.Checked:=false;
  CORBA1.Checked:=true;
end;

procedure TMainForm.Entera4x1Click(Sender: TObject);
begin
  RemoteItem.Checked:=true;
  Entera4Item.Checked:=true;
  CORBAItem.Checked:=false;
  Entera4x1.Checked:=true;
  CORBA1.Checked:=false;
  RemoteButton.ImageIndex:=REMOTE_IMAGE_INDEX;
  RemoteButton.Tag:=1;
end;

procedure TMainForm.CORBA1Click(Sender: TObject);
begin
  RemoteItem.Checked:=true;
  Entera4Item.Checked:=false;
  CORBAItem.Checked:=true;
  Entera4x1.Checked:=false;
  CORBA1.Checked:=true;
  RemoteButton.ImageIndex:=REMOTE_IMAGE_INDEX;
  RemoteButton.Tag:=1;
end;

procedure TMainForm.ColorsButtonClick(Sender: TObject);
begin
  if RedItem.Checked then
    GreenItemClick(Sender)
  else
    if GreenItem.Checked then
      BlueItemClick(Sender)
    else
      if BlueItem.Checked then
        ColorfulItemClick(Sender)
      else
        if ColorfulItem.Checked then
          RedItemClick(Sender);
end;

end.



