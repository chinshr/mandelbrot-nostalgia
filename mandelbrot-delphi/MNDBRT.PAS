(***************************************************************)
(* Programm:  MANDELBROT                                       *)
(* Version:   1.0                                              *)
(* Datum:     01.12.93                                         *)
(* Verfasser: JÅrgen Fe·lmeier                                 *)
(* Info:      Fractal aus Mandelbrotmenge                      *)
(***************************************************************)

program Mandelbrot (input,output);
uses Crt, Graph;

CONST
  MaxSpalten = 639;
  MaxZeilen  = 479;
  MaxColor   = 15;


VAR
  u,v,n,nmax : integer;
  x,y,r,i,d,a,b,delta_a,delta_b,
  imag_u,imag_o,real_u,real_o,xr,yi : real;
  ch : char;
  grDriver : Integer;
  grMode   : Integer;
  ErrCode  : Integer;

begin
  n:=0; nmax:=100;
  x:=0; y:=0; r:=0; i:=0; d:=0; v:=0; u:=0; a:=0; b:=0; delta_a:=0; delta_b:=0;
  imag_u:=-1.25;imag_o:=1.25;real_u:=-2;real_o:=0.5;
  xr:=0;yi:=0;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'c:\tp6\bgi');
  ErrCode := GraphResult;
  WriteLn(GraphErrorMsg(ErrCode));
  if ErrCode = grOk then
  begin
    ClearViewPort;
    delta_a:= (real_o-real_u)/MaxSpalten;
    delta_b:= (imag_o-imag_u)/MaxZeilen;
    b := imag_u-delta_b;
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
        end;
        if n=nmax then PutPixel(v,u,Black)
          else PutPixel(v,u,(n mod MaxColor)+1);
      end;
    end;
    ch := ' ';
    while ch<>#27 do
      ch := ReadKey;
    CloseGraph;
  end;
end.
