unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, Gauges,
  About;

const
  APPTITLE   = 'Fractal 95';
  APPVERSION = '1.0.15';
  APPYEAR    = '1995';
  APPAUTHOR  = 'Jürgen Feßlmeier';

type
  TMainForm = class(TForm)
    ImageFrame: TPanel;
    Image: TPaintBox;
    FractalMenu: TMainMenu;
    Fractal1: TMenuItem;
    Help1: TMenuItem;
    Calculate: TMenuItem;
    About: TMenuItem;
    Quit1: TMenuItem;
    Exit: TMenuItem;
    ClearItem: TMenuItem;
    Panel1: TPanel;
    procedure ImageClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CalculateClick(Sender: TObject);
    procedure ExitClick(Sender: TObject);
    procedure ClearItemClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    public
      StatusText : string;
      procedure DrawFractal(Medium: TPaintBox);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

const
  GapInPixels  = 1;
  WinBorder    = 25;
  StatusHeight = 25;

procedure SetStatusText; Forward;
procedure ClearImage(Medium: TPaintBox); Forward;

procedure TMainForm.ImageClick(Sender: TObject);
begin
  DrawFractal(MainForm.Image);
end;

procedure TMainForm.DrawFractal(Medium: TPaintBox);
var
  u,v,n,nmax,MaxSpalten,
  MaxZeilen,MaxColor : integer;
  x,y,r,i,d,a,b,delta_a,delta_b,
  imag_u,imag_o,real_u,real_o,xr,yi : real;
  Clr_R, Clr_G, Clr_B : word;
  StartT, EndT : TDateTime;
  Hour, Min, Sec, MSec: Word;
  TimeStr : string[25];
begin
  MaxSpalten := Medium.Width;
  MaxZeilen  := Medium.Height;
  MaxColor   := 555;

  n:=0; nmax:=24;
  x:=0; y:=0; r:=0; i:=0; d:=0; v:=0; u:=0; a:=0; b:=0; delta_a:=0; delta_b:=0;
  imag_u:=-1.25;imag_o:=1.25;real_u:=-2;real_o:=0.5;
  xr:=0;yi:=0;
  delta_a:= (real_o-real_u)/MaxSpalten;
  delta_b:= (imag_o-imag_u)/MaxZeilen;
  b := imag_u-delta_b;
  ClearImage(Medium);
  MainForm.ClearItem.Enabled:=false;
  StartT:=Time;
  for u := 0 to MaxZeilen do
  begin
    b := b+delta_b;
    a := real_u-delta_a;
    for v := 0 to MaxSpalten do
    begin
      a := a+delta_a;
      n := 0; r := xr; i :=yi; d := 0;
      while (d<4) and (n<>nmax) do
      begin
        x := r; y := i;
        r := x*x-y*y+a; i := 2*x*y+b;
        d := r*r+i*i;
        Inc(n);
        Yield; (* API call *)
      end;
      if n=nmax then Medium.Canvas.Pixels[v,u]:=clBlack
       else
       begin
         Clr_R:=MaxColor-sqr((n mod MaxColor)+1);
         Clr_G:=MaxColor-sqr((n mod MaxColor)+1)*(n mod MaxColor)+1;
         Clr_B:=MaxColor-sqr(sqr((n mod MaxColor)+1));
         with Medium do
         begin
           Canvas.Pixels[v,u]:=RGB(Clr_R,Clr_G,Clr_B);
         end;
       end;
    end;
  end;
  EndT:=Time;
  Hour:=0;Min:=0;Sec:=0;MSec:=0;
  DecodeTime(EndT-StartT, Hour, Min, Sec, MSec);
  Str(Hour*3600+Min*60+Sec+MSec/1000:9:3,TimeStr);
  TimeStr:=' Time: '+TimeStr+' secs.';
  MainForm.StatusText:=TimeStr;
  SetStatusText;
  MainForm.ClearItem.Enabled:=true;
end;

procedure TMainForm.FormResize(Sender: TObject);
var
  XSize, YSize : string[5];
begin
  ImageFrame.Left:=GapInPixels;
  ImageFrame.Width:=MainForm.ClientWidth-GapInPixels*2-1;
  ImageFrame.Top:=GapInPixels+2;
  ImageFrame.Height:=MainForm.ClientHeight-GapInPixels*2-Panel1.Height-5;
  Str(ImageFrame.Width,XSize);
  Str(ImageFrame.Height,YSize);
  StatusText:=' '+XSize+' X '+YSize+' pixels';
  SetStatusText;
end;

procedure TMainForm.CalculateClick(Sender: TObject);
begin
  DrawFractal(Image);
end;

procedure TMainForm.ExitClick(Sender: TObject);
begin
  Close;
end;

procedure SetStatusText;
begin
  MainForm.Panel1.Caption:=MainForm.StatusText;
end;

procedure ClearImage(Medium: TPaintBox);
var
  NewRect: TRect;
  XSize, YSize: string[5];
begin
  NewRect := Rect(0, 0, Medium.Width, Medium.Height);
  Medium.Canvas.Brush.Color := clWhite;
  Medium.Canvas.FillRect(NewRect);
  Str(Medium.Width,XSize);
  Str(Medium.Height,YSize);
  MainForm.StatusText:=' '+XSize+' X '+YSize+' pixels.';
  SetStatusText;
end;

procedure TMainForm.ClearItemClick(Sender: TObject);
begin
  ClearImage(Image);
  ClearItem.Enabled:=false;
end;

procedure TMainForm.AboutClick(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

end.
