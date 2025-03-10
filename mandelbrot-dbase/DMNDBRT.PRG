*********************************************************************
*
* Program   :    DMNDBRT.PRG
*
* Author    :    J�rgen Fe�lmeier
*
* Version   :    v1.1
*
* Date      :    11/17/1994
*
* Info      :    Draws MandelBrot Fractal in a dBASE Form.
*                To stop the MandelBrot while it is drawing, press
*                Esc and the Close Button, or Esc twice.
*
*********************************************************************

************************************************
***             Macrodefinition              ***
************************************************
#DEFINE RGB(r,g,b)        (BITOR(r,BITOR(BITLSHIFT(g,8),BITLSHIFT(b,16))))
#DEFINE MAKEWORD(c)       ASC(SUBSTR(c,1)) + BITLSHIFT(ASC(SUBSTR(c,2)),8)
#DEFINE PALETTEINDEX(i)   (BITOR(01000000,i))

************************************************
***              dBASE Settings              ***
************************************************
CREATE SESSION
SET TALK OFF
SET ECHO OFF
SET LDCHECK OFF
SET ESCAPE ON
SET PRECISION TO 19
SET ESCAPE ON

************************************************
***          Variable Declaration            ***
************************************************
PUBLIC cAppName,cAppVersion,cAppAuthor,oForm

************************************************
***                 Constants                ***
************************************************
cAppName           = "dMNDBRT"
cAppVersion        = "1.02.562"
cAppAuthor         = "J�rgen Fe�lmeier"

************************************************
***            Extern Prototypes             ***
************************************************
EXTERN CHANDLE  CreateDC(CSTRING, CSTRING, CSTRING, CSTRING) GDI.EXE
EXTERN CHANDLE  GetDC(CHANDLE) USER.EXE
EXTERN CVOID    GetClientRect(CHANDLE, CPTR) USER.EXE
EXTERN CLONG    SetPixel(CHANDLE,CINT,CINT,CLONG) GDI.EXE
EXTERN CHANDLE  GetObject(CHANDLE, CINT, CPTR) GDI.EXE
EXTERN CVOID    Yield(CVOID) KRNL386.EXE
EXTERN CINT     SaveDC(CHANDLE) GDI.EXE
EXTERN CHANDLE  RestoreDC(CHANDLE,CINT) GDI.EXE

************************************************
***                   Main                   ***
************************************************
oForm=NEW MNDBRTFORM()
oForm.Open()
RETURN


************************************************
***            Class Definition              ***
************************************************
CLASS MNDBRTFORM OF FORM
   * User defined Proberties
   THIS.iPixPerTurpinH    = 0
   THIS.iPixPerTurpinV    = 0
   THIS.EscPressed        = .F.
   THIS.AreaWidth         = 0
   THIS.AreaHeight        = 0
   THIS.iButtonBottomDist = 0
   THIS.iBorderBottomDist = 0
   THIS.hDC               = 0
   THIS.OldDC             = 0
   * FormProberties
   THIS.Text              = cAppName+" - "+cAppVersion
   THIS.HelpFile          = ""
   THIS.HelpId            = ""
   THIS.MDI               = .F.
   THIS.EscExit           = .T.
   THIS.Top               = 2.7646
   THIS.Left              = 22.5
   THIS.Width             = 45.666
   THIS.Height            = 14.7051
   THIS.OnOpen            = CLASS::Form_OnOpen
   THIS.OnSize            = CLASS::Form_OnSize
   THIS.OnLostFocus       = {; THIS.OldDC=SaveDC(THIS.hDC)}
   THIS.OnGotFocus        = {; RestoreDC(THIS.hDC,THIS.OldDC)}

   NEW RECTANGLE (THIS,"BORDER")
     THIS.BORDER.ColorNormal      = "N/W"
     THIS.BORDER.Text             = ""
     THIS.BORDER.Border           = .T.
     THIS.BORDER.Top              = 0.4111
     THIS.BORDER.Left             = 1
     THIS.BORDER.Width            = 43.5
     THIS.BORDER.Height           = 11
     THIS.BORDER.BorderStyle      = 2

   NEW PUSHBUTTON (THIS,"ACTIONBUTTON")
     THIS.ACTIONBUTTON.Group       = .T.
     THIS.ACTIONBUTTON.Height      = 2
     THIS.ACTIONBUTTON.Left        = 15
     THIS.ACTIONBUTTON.Top         = 12
     THIS.ACTIONBUTTON.UpBitmap    = "RESOURCE #1070"
     THIS.ACTIONBUTTON.FontName    = "Arial"
     THIS.ACTIONBUTTON.FontSize    = 8
     THIS.ACTIONBUTTON.Text        = "&Start"
     THIS.ACTIONBUTTON.Width       = 14
     THIS.ACTIONBUTTON.ColorNormal = "N/W"
     THIS.ACTIONBUTTON.FontBold    = .T.
     THIS.ACTIONBUTTON.Enabled     = .T.
     THIS.ACTIONBUTTON.Default     = .T.
     THIS.ACTIONBUTTON.OnClick     = CLASS::Start_OnClick

   NEW PAINTBOX (THIS,"DRAWAREA")
     THIS.DRAWAREA.Top            = 0.6465
     THIS.DRAWAREA.Left           = 1.666
     THIS.DRAWAREA.Width          = 42.167
     THIS.DRAWAREA.Height         = 10.5293

************************************************
***                  Methods                 ***
************************************************
   PROCEDURE Form_OnOpen
     LOCAL cRect
     cRect = SPACE(8)
     GetClientRect(THIS.DRAWAREA.hWnd,cRect)
   * Pixels in Width and Heigth of the area
     THIS.AreaWidth  = MAKEWORD(SUBSTR(cRect, 5)) - MAKEWORD(SUBSTR(cRect, 1))
     THIS.AreaHeight = MAKEWORD(SUBSTR(cRect, 7)) - MAKEWORD(SUBSTR(cRect, 3))
   * Calculation Pixels/Turpin
     THIS.iPixPerTurpinH=THIS.AreaWidth/THIS.DRAWAREA.WIDTH                    && Not used in
     THIS.iPixPerTurpinV=THIS.AreaHeight/THIS.DRAWAREA.HEIGHT                  && Code
     THIS.iButtonBottomDist=THIS.Height-THIS.ACTIONBUTTON.Height-THIS.ACTIONBUTTON.Top
     THIS.iBorderBottomDist=THIS.Height-THIS.BORDER.Height-THIS.BORDER.Top
   RETURN

   PROCEDURE Start_OnClick
   * Change Button Proberties
     Form.ACTIONBUTTON.Text     = "&Close"                           && Change Button
     Form.ACTIONBUTTON.UpBitmap = "RESOURCE #28"                     && to CLOSE
   * Following line is not working when ON ESCAPE is set at the same time  
   * Form.ACTIONBUTTON.Enabled  = .F.                                && Disable Button
     Form.ACTIONBUTTON.Default  = .F.
     Form.ACTIONBUTTON.OnClick  = CLASS::Close_OnClick
   * Draw the fractal
     ON ESCAPE Form.EscEvent()
     CLASS::DrawFractal()
   RETURN

   PROCEDURE Form_OnSize(nType, Width, Height)
     CLASS::SizeProberties(Width,Height)
   RETURN

   PROCEDURE Close_OnClick
     Form.Close()
   RETURN
   
   PROCEDURE DrawFractal
   LOCAL u,v,n,nmax,MaxColor                        && Integer
   LOCAL x,y,r,i,d,a,b,delta_a,delta_b,imag_u,;
         imag_o,real_u,real_o,xr,yi                 && Float
   LOCAL cRest                                      && Char
   * Evaluate
     cRect = SPACE(8)
     GetClientRect(Form.DRAWAREA.hWnd,cRect)
   * Pixels in Width and Heigth of the area again
     Form.AreaWidth  = MAKEWORD(SUBSTR(cRect, 5)) - MAKEWORD(SUBSTR(cRect, 1))
     Form.AreaHeight = MAKEWORD(SUBSTR(cRect, 7)) - MAKEWORD(SUBSTR(cRect, 3))
     MaxColor   = 6400                              && Try with other figures
   * Get a Display Context
     Form.hDC = GetDC(Form.DRAWAREA.hWnd)
     SaveDC(Form.hDC)
   * Begin Alogorythm
     n=0; nmax=24
     x=0; y=0; r=0; i=0; d=0; v=0; u=0; a=0; b=0; delta_a=0; delta_b=0
     imag_u=-1.25; imag_o=1.25; real_u=-2; real_o=0.5
     xr=0; yi=0
     delta_a=(real_o-real_u)/Form.AreaWidth
     delta_b=(imag_o-imag_u)/Form.AreaHeight
     b=imag_u-delta_b
     FOR u=0 TO Form.AreaHeight                                      && Line-loop
       b=b+delta_b
       a=real_u-delta_a
       FOR v=0 TO Form.AreaWidth                                     && Pixel-loop
         a=a+delta_a
         n=0; r=xr; i=yi; d=0
         DO WHILE ((d<4) .AND. (n<>nmax))                            && Iteration loop
           x=r; y=i
           r=x*x-y*y+a; i=2*x*y+b
           d=r*r+i*i
           n=n+1
         ENDDO
         IF n=nmax                                                   && IF maximum Iter.
           SetPixel(Form.hDC,v,u,0)                                  && THEN set black pixel
         ELSE
           SetPixel(Form.hDC,v,u,RGB((MaxColor-MOD(n,MaxColor)+1)^2,;&& ELSE a calc. with MOD
           (MaxColor-MOD(n,MaxColor)+1)^3,(MaxColor-MOD(n,MaxColor)+1)^4))
         ENDIF
         IF Form.EscPressed=.T.                                      && Check if ESC pressed
           RETURN
         ENDIF
       NEXT
     NEXT
     Form.ACTIONBUTTON.Enabled  = .T.
   RETURN

   PROCEDURE EscEvent
     Form.EscPressed=.T.
     Form.ACTIONBUTTON.Enabled  = .T.
   RETURN


   PROCEDURE SizeProberties(Width, Height)
   LOCAL TempHeight
     TempHeight               = Height-Form.iBorderBottomDist-Form.BORDER.Top-;
                                2*(Form.DRAWAREA.Top-Form.BORDER.Top)
     IF TempHeight>0.5
       Form.BORDER.Width      = Width-2*(Form.BORDER.Left)
       Form.BORDER.Height     = Height-Form.BORDER.Top-Form.iBorderBottomDist
       Form.DRAWAREA.Width    = Width-2*(Form.DRAWAREA.Left)
       Form.DRAWAREA.Height   = TempHeight
       Form.ACTIONBUTTON.Top  = Height-Form.iButtonBottomDist-;
                                Form.ACTIONBUTTON.Height
       Form.ACTIONBUTTON.Left = (Width-Form.ACTIONBUTTON.Width)/2
     ENDIF
   RETURN

ENDCLASS
************************************************
***               End Program                ***
************************************************
