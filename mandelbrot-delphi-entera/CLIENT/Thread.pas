(*----------------------------------------------------------------------------
 *
 *  Thread.pas
 *
 *  Copyright (c) 1998 Inprise Corporation. All Rights Reserved.
 *
 *  Entera Samples Group
 *
 *----------------------------------------------------------------------------*)
unit Thread;

interface

uses
  Classes, ExtCtrls, SysUtils, Graphics, WinTypes, fractal_c, fractal_hc,
  oden40, odenconst40, StatsDlg, Dialogs;

type

{ TParentThread }

  TParentThread = class(TThread)
  private
    { Private declarations }
    FColorType: integer; // 1=Red, 2=Green, 3=Blue, 4=Colorful
    FMedium: TCanvas;
    FWidth: integer;
    FHeight: integer;
    FX: integer;
    FY: integer;
    FValue: Longint;
    FMndSet: mndset_t;
    FStartTime: TDateTime;
    FEndTime: TDateTime;
    FErrorMsg: String;
    procedure DoVisualUpdate;
    procedure DoUpdateTimeCaption;
    procedure DoClearImage;
    procedure DoUpdateMedium;
    function Time2String(Time : TDateTime) : string;
    procedure DoUpdateStats;
    procedure DoThreadDone;
  protected
    procedure Execute; override;
    procedure Calculate; virtual; abstract;
    procedure DrawPixel(x, y: integer; value: Longint);
    procedure UpdateTimeCaption;
    procedure UpdateMedium;
    procedure SetStartTime;
    procedure SetEndTime;
    procedure ClearImage;
    procedure UpdateStats; virtual; abstract;
    procedure InvokeShowError; virtual; abstract;
    procedure DoTerminate; override;
  public
    constructor Create(Medium: TCanvas;
                       Width, Height, ColorType: integer;
                       MndSet: mndset_t);
    procedure ThreadDone(Sender: TObject); virtual; abstract;
  end;

{ TLocalThread }

  TLocalThread = class(TParentThread)
  protected
    procedure Calculate; override;
    procedure UpdateStats; override;
    procedure InvokeShowError; override;
  public
    procedure ThreadDone(Sender: TObject); override;
  end;

{ TRemoteThread }

  TRemoteThread = class(TParentThread)
  private
    function DoConnect: boolean;
    function DoDisconnect: boolean;
    procedure DoShowError;
  protected
    FRpcAccu: TDateTime;
    FInitialRpcTime: TDateTime;
    FFractalHandle: Cardinal;
    FUsedHandles: Longint;
    FConnected: boolean;
    function Connect: boolean; virtual; abstract;
    function Disconnect: boolean; virtual; abstract;
    procedure ShowError; virtual; abstract;
    procedure UpdateStats; override;
    procedure InvokeShowError; override;
  end;

{ TEnteraThread }

  TEnteraThread = class(TRemoteThread)
  protected
    function Connect: boolean; override;
    function Disconnect: boolean; override;
    procedure ShowError; override;
    procedure Calculate; override;
  public
    procedure ThreadDone(Sender: TObject); override;
  end;


implementation

uses Main;

(*----------------------------------------------------------------------------
 *  TParentThread implementation
 *----------------------------------------------------------------------------*)

constructor TParentThread.Create(Medium: TCanvas; Width, Height, ColorType: integer; MndSet: mndset_t);
begin
  FMedium := Medium;
  FWidth:=Width;
  FHeight:=Height;
  FreeOnTerminate := True;
  FColorType:=ColorType;
  FMndSet:=MndSet;
  OnTerminate:=ThreadDone;
  inherited Create(False);
end;

procedure TParentThread.DoTerminate;
begin
  ThreadDone(Self);
  Synchronize(MainForm.ShowStats);
  inherited DoTerminate;
end;

procedure TParentThread.DrawPixel(x, y : integer; value: Longint);
begin
  FX:=x;
  FY:=y;
  FValue:=value;
  Synchronize( DoVisualUpdate );
end;

procedure TParentThread.DoThreadDone;
begin
  MainForm.ThreadDone(Self);
end;

procedure TParentThread.DoUpdateStats;
begin
  MainForm.ShowStats;
end;

procedure TParentThread.Execute;
begin
  { Place thread code here }
  ClearImage;
  Calculate;
end;

procedure TParentThread.DoVisualUpdate;
var
  Value: Longint;
begin
  case FColorType of
    1: Value:=RGB(FValue, 0, 0);
    2: Value:=RGB(0, FValue, 0);
    3: Value:=RGB(0, 0, FValue);
    4: Value:=RGB(FValue, FValue*2, FValue*3);
  end;
  FMedium.Pixels[FX, FY]:=Value;
end;

procedure TParentThread.DoUpdateTimeCaption;
begin
  MainForm.StatusBar.Panels[0].Text:=Time2String(FEndTime-FStartTime)+' secs.';
end;

procedure TParentThread.DoUpdateMedium;
begin
  MainForm.UpdateImage;
end;

procedure TParentThread.SetStartTime;
begin
  FStartTime:=Time;
end;

procedure TParentThread.SetEndTime;
begin
  FEndTime:=Time;
end;

function TParentThread.Time2String(Time : TDateTime) : string;
var
  Hour, Min, Sec, MSec: Word;
  TimeStr : string[25];
begin
  Hour:=0; Min:=0; Sec:=0; MSec:=0;
  DecodeTime(Time, Hour, Min, Sec, MSec);
  Str(Hour*3600+Min*60+Sec+MSec/1000:9:3, TimeStr);
  Result:=TimeStr;
end;

procedure TParentThread.UpdateTimeCaption;
begin
  Synchronize(DoUpdateTimeCaption);
end;

procedure TParentThread.UpdateMedium;
begin
  Synchronize(DoUpdateMedium);
end;

procedure TParentThread.DoClearImage;
var
  NewRect: TRect;
  XSize, YSize: string[5];
begin
  NewRect := Rect(0, 0, FWidth, FHeight);
  FMedium.Brush.Color := clWhite;
  FMedium.FillRect(NewRect);
end;

procedure TParentThread.ClearImage;
begin
  Synchronize(DoClearImage);
end;

(*----------------------------------------------------------------------------
 *  TLocalThread implementation
 *----------------------------------------------------------------------------*)

procedure TLocalThread.UpdateStats;
begin
  StatsDialog.TotalTime.Caption:=Trim(Time2String(FEndTime-FStartTime))+' secs.';
  StatsDialog.TotalRpcTime.Caption:='N/A';
  StatsDialog.TotalRpc.Caption:=Trim(IntToStr(FHeight));
  StatsDialog.AverageRpcTime.Caption:='N/A';
  StatsDialog.OpenServerHandles.Caption:='N/A';
  StatsDialog.InitialRpcTime.Caption:='N/A';
end;

procedure TLocalThread.ThreadDone;
begin
  UpdateStats;
  Synchronize(DoThreadDone);
end;

procedure TLocalThread.InvokeShowError;
begin
end;

procedure TLocalThread.Calculate;
var
  u,v,n,nmax : integer;
  x,y,r,i,d,a,b,delta_a,delta_b,
  imag_u,imag_o,real_u,real_o,xr,yi : double;
  Clr_R, Clr_G, Clr_B : word;
  Hour, Min, Sec, MSec: Word;
begin
  n:=0; nmax:=50;
  x:=0; y:=0; r:=0; i:=0; d:=0; v:=0; u:=0; a:=0; b:=0; delta_a:=0; delta_b:=0;

  real_u:=FMndSet.real_min;  real_o:=FMndSet.real_max;
  imag_u:=FMndSet.imag_min; imag_o:=FMndSet.imag_max;

  xr:=0;yi:=0;
  delta_a:= (real_o-real_u)/FWidth;
  delta_b:= (imag_o-imag_u)/FHeight;
  b := imag_u-delta_b;
  SetStartTime;
  for u := 0 to FHeight do
  begin
    b := b+delta_b;
    a := real_u-delta_a;
    for v := 0 to FWidth do
    begin
      a := a+delta_a;
      n := 0; r := xr; i :=yi; d := 0;
      while (d<4) and (n<>nmax) do
      begin
        x := r; y := i;
        r := x*x-y*y+a; i := 2*x*y+b;
        d := r*r+i*i;
        Inc(n);
      end;
      if n=nmax then DrawPixel(v, u, clBlack)
      else
      begin
        with FMedium do
        begin
          DrawPixel(v, u, n*10 );
        end;
      end;
    end;
    UpdateMedium;
  end;
  SetEndTime;
  UpdateTimeCaption;
end;

(*----------------------------------------------------------------------------
 *  TRemoteThread implementation
 *----------------------------------------------------------------------------*)

procedure TRemoteThread.DoShowError;
begin
  ShowError;
end;

function TRemoteThread.DoConnect : boolean;
begin
  Result:=Connect;
end;

function TRemoteThread.DoDisconnect : boolean;
begin
  Result:=Disconnect;
end;

procedure TRemoteThread.UpdateStats;
var
  Hour, Min, Sec, MSec: Word;
  AverageRpcTimeStr : string[25];
  RpcTimePercentStr : string[25];
  AverageRpcTime: Extended;
  RpcTimePercent: Extended;
begin
  Hour:=0; Min:=0; Sec:=0; MSec:=0;
  DecodeTime(FRpcAccu, Hour, Min, Sec, MSec);
  AverageRpcTime:=(Hour*3600+Min*60+Sec+MSec/1000)/(FHeight+1);
  Str(AverageRpcTime:9:3, AverageRpcTimeStr);

  if Abs(FEndTime-FStartTime)<>0 then
  begin
    RpcTimePercent:=FRpcAccu/(FEndTime-FStartTime)*100;
    Str(RpcTimePercent:9:1, RpcTimePercentStr);
  end;

  StatsDialog.TotalTime.Caption:=Trim(Time2String(FEndTime-FStartTime))+' secs.';
  StatsDialog.TotalRpcTime.Caption:=Trim(Time2String(FRpcAccu))+' secs. ('+Trim(RpcTimePercentStr)+'%)';
  StatsDialog.TotalRpc.Caption:=Trim(IntToStr(FHeight+1));
  StatsDialog.AverageRpcTime.Caption:=Trim(AverageRpcTimeStr)+' secs./RPC';
  StatsDialog.OpenServerHandles.Caption:=Trim(IntToStr(FUsedHandles));
  StatsDialog.InitialRpcTime.Caption:=Trim(Time2String(FInitialRpcTime))+' secs.';
end;

procedure TRemoteThread.InvokeShowError;
begin
  Synchronize(DoShowError);
end;

 (*----------------------------------------------------------------------------
 *  TEnteraThread implementation
 *----------------------------------------------------------------------------*)

procedure TEnteraThread.ThreadDone;
var
  cd: client_data_t;
begin
  if (0<>FFractalHandle) then
  begin
    cd:=close(FFractalHandle);
    FFractalHandle:=0;
  end;
  DoDisconnect;
  UpdateStats;
  Synchronize(DoThreadDone);
end;

function TEnteraThread.Connect : boolean;
var
  Dap : string;
  tmp : Pchar;
  errmsg : array[0..255] of Char;
begin
  Dap:=ExtractFilePath(ParamStr(0))+DAPFILE;
  tmp := stralloc(length(Dap)+1);
  StrpCopy(tmp, Dap);
  ode_cln_open_session(tmp, '', '');
  if (ode_cln_get_errnum<>ode_s_ok) then
  begin
    ode_cln_get_errstr(errmsg);
    MessageDlg(('Error ('+Dap+'): '+StrPas(errmsg)), MtError, [Mbok], 0);
    Result:=false;
    exit;
  end;
  StrDispose(tmp);
  FConnected:=true;
  Result:=FConnected;
end;

function TEnteraThread.Disconnect : boolean;
var
  errmsg : array[0..255] of Char;
begin
  ode_mem_release;
  if FConnected then
    ode_cln_close_session;
  Result:=true;
end;

procedure TEnteraThread.ShowError;
var
  errmsg : array[0..1024] of Char;
begin
  Suspend;
  if (ode_cln_get_errnum<>ode_s_ok) then
  begin
    ode_cln_get_errstr(errmsg);
    MessageDlg('RPC Error: '+Trim(StrPas(errmsg))+' with message: '+FErrorMsg, MtError, [Mbok], 0);
  end
  else
  begin
    MessageDlg('Error with message: '+FErrorMsg, MtError, [Mbok], 0);
  end;
  Disconnect;
  ThreadDone(self);
  Terminate;
end;

procedure TEnteraThread.Calculate;
var
  u, v, n : Longint;
  Clr_R, Clr_G, Clr_B : word;
  StartTime, EndTime : TDateTime;
  nmax: integer;
  outwidth: Longint;
  row: Variant;
  RpcStart, RpcEnd: TDateTime;
  InitialRpcStart, InitialRpcEnd: TDateTime;
  rc: Longint;
  cd: client_data_t;
begin
  nmax:=25;
  FRpcAccu:=0;
  FFractalHandle:=0;
  FUsedHandles:=0;
  if ( not DoConnect ) then Exit;
  row := VarArrayCreate([0, FWidth], varByte);

  SetStartTime;

  InitialRpcStart:=time;
  with cd do
  begin
    mndset:=FMndSet;
    iterations:=nmax;
    width:=FWidth;
    height:=FHeight;
  end;
    FFractalHandle:=open(cd);
  InitialRpcEnd:=time;
  FInitialRpcTime:=InitialRpcEnd-InitialRpcStart;
  FRpcAccu:=FRpcAccu+FInitialRpcTime;
  if FFractalHandle=0 then
  begin
      FErrorMsg:='A new fractal handle could not be obtained (possible cause: server is not running or is overloaded).';
      InvokeShowError;        // terminates the thread automatically
  end;

  for u := 0 to FHeight do
  begin
    RpcStart:=time;
    rc:=get_next(FFractalHandle, outwidth, row);
    RpcEnd:=time;
    FRpcAccu:=FRpcAccu+Abs(RpcEnd-RpcStart);
    if rc=0 then
    begin
      FErrorMsg:='Fractal handle mismatch (possible cause: server implementation error).';
      InvokeShowError;   // terminates the thread automatically
    end;
    for v := 0 to FWidth-1 do
    begin
      n:=row[v];
      if n=nmax then
        DrawPixel(v, u, clBlack)
      else
      begin
        DrawPixel(v, u, n*10 );
      end;
    end;
    UpdateMedium;
  end;
  SetEndTime;
  UpdateTimeCaption;
end;


end.
