# ---------------------------------------------------------------------------
VERSION = BCB.01
# ---------------------------------------------------------------------------
!ifndef BCB
BCB = $(MAKEDIR)\..
!endif
# ---------------------------------------------------------------------------
########### Entera 4.0 Specific Changes Begins 
# ---------------------------------------------------------------------------
INTF=fractal
ODELIB=oden40
ENTOBJFILES = $(INTF)_s.obj fractalsm.obj
ENTLIBFILES = $(ODELIB).lib
# ---------------------------------------------------------------------------
########### Entera 4.0 Specific Changes Ends
# ---------------------------------------------------------------------------
PROJECT = fracsrv.exe
OBJFILES = fractal.obj 
RESFILES = 
RESDEPEN = 
LIBFILES =
DEFFILE =
# ---------------------------------------------------------------------------
########### Entera 4.0 Changes - Added -DWIN32,$(ODEDIR)\<path>
# ---------------------------------------------------------------------------
CFLAG1 = -Od -Hc -w -Ve -r- -k -y -v -vi- -DWIN32 -c -a4 -b- -w-par -w-inl -Vx -Ve -x
CFLAG2 = -I$(BCB)\include;$(BCB)\include\vcl;$(ODEDIR)\include;$(ODEDIR)\dceinc \
  -H=$(BCB)\lib\vcld.csm
PFLAGS = -AWinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE \
   -U$(BCB)\lib\obj;$(BCB)\lib -I$(BCB)\include;$(BCB)\include\vcl -v -$Y -$W \
   -$O- -JPHNV -M
RFLAGS = -i$(BCB)\include;$(BCB)\include\vcl
LFLAGS = -L$(BCB)\lib\obj;$(BCB)\lib;$(ODEDIR)\lib\borland; -aa -Tpe \
  -x -v
IFLAGS =
LINKER = ilink32
# ---------------------------------------------------------------------------
########### Entera 4.0 Changes Ends
# ---------------------------------------------------------------------------
ALLOBJ = c0w32.obj $(OBJFILES)
ALLRES = $(RESFILES)
ALLLIB = $(LIBFILES) vcl.lib import32.lib cp32mt.lib $(ODEDIR)/lib/oden40.lib $(ODEDIR)\LIB\COMPAT.LIB $(ODEDIR)/lib/w32pthd.lib
# ---------------------------------------------------------------------------
.autodepend

# ---------------------------------------------------------------------------
########### Entera 4.0 Changes - Added ENTOBJFILES,ENTLIBFILES
# ---------------------------------------------------------------------------

$(PROJECT): $(ENTOBJFILES) $(OBJFILES) $(RESDEPEN) $(DEFFILE)
    $(BCB)\BIN\$(LINKER) @&&!
    $(LFLAGS) +
    $(ENTOBJFILES) $(ALLOBJ), +
    $(PROJECT),, +
    $(ENTLIBFILES) $(ALLLIB), +
    $(DEFFILE), +
    $(ALLRES)
!

# ---------------------------------------------------------------------------
########### Entera 4.0 Changes Ends
# ---------------------------------------------------------------------------

.pas.hpp:
    $(BCB)\BIN\dcc32 $(PFLAGS) { $** }

.pas.obj:
    $(BCB)\BIN\dcc32 $(PFLAGS) { $** }

.cpp.obj:
    $(BCB)\BIN\bcc32 $(CFLAG1) $(CFLAG2) -o$* $*

.c.obj:
    $(BCB)\BIN\bcc32 $(CFLAG1) $(CFLAG2) -o$* $**

.rc.res:
    $(BCB)\BIN\brcc32 $(RFLAGS) $<

# ---------------------------------------------------------------------------
########### Entera 4.0 Changes - Rule for building $(INTF)_c.c from $(INTF).idl
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
########### Entera 4.0 Changes ends
# ---------------------------------------------------------------------------


#-----------------------------------------------------------------------------
