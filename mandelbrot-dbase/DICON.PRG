** END HEADER -- do not remove this line*
* Generated on 11/21/94
*

CREATE SESSION
SET ECHO OFF
SET TALK OFF


PUBLIC Macro
PUBLIC TopPos,LeftPos
LOCAL oForm

Macro=""

oForm = NEW DICONFORM()
oForm.Open()
RETURN

CLASS DICONFORM OF FORM
   * Internal Porberties
   THIS.BitWidth       = 2.001
   THIS.BitHeight      = 0.7061
   THIS.HDistance      = 0.05
   THIS.VDistance      = 0.05
   THIS.FirstTop       = 3.7637
   THIS.FirstLeft      = 2.832
   * Form Proberties
   THIS.Top            = 0.7646
   THIS.Left           = 4.5
   THIS.Text           = "dICON"
   THIS.Width          = 96.833
   THIS.OnOpen         = {; CLASS::Form_OnOpen()}
   THIS.Height         = 23.2344
   THIS.HelpFile       = ""
   THIS.HelpId         = ""

   NEW RECTANGLE (THIS, "BIGBMPBORDER")
     THIS.BIGBMPBORDER.Top         = 1
     THIS.BIGBMPBORDER.Left        = 1.832
     THIS.BIGBMPBORDER.Border      = .T.
     THIS.BIGBMPBORDER.ColorNormal = "N/W"
     THIS.BIGBMPBORDER.BorderStyle = 1
     THIS.BIGBMPBORDER.Text        = ""
     THIS.BIGBMPBORDER.Width       = 66.668
     THIS.BIGBMPBORDER.Height      = 17.4697
     
   PROCEDURE Form_OnOpen
   LOCAL h,v
     TopPos=THIS.FirstTop
     LeftPos=THIS.FirstLeft
     FOR v=1 TO 8
       FOR h=1 TO 8
         Macro="BIGBIT"+ltrim(str(v))+"_"+ltrim(str(h))
         THIS.text=Macro
         NEW RECTANGLE (THIS, Macro)
           Macro="THIS."+Macro
           &Macro.Top         = TopPos
           &Macro.Left        = LeftPos
           &Macro.Border      = .F.
           &Macro.ColorNormal = "N/W"
           &Macro.Text        = ""
           &Macro.OldStyle    = .T.
           &Macro.Width       = 2.001
           &Macro.Height      = 0.7061
         LeftPos=LeftPos+THIS.BitWidth+THIS.HDistance
       NEXT
       LeftPos=THIS.FirstLeft
       TopPos=TopPos+THIS.BitHeight+THIS.VDistance
     NEXT
     Macro=""
   RETURN

ENDCLASS
