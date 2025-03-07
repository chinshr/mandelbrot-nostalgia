###############################################################################
#  
#  mscc.mak  (MS Dev Studio 4 & 5)
#
#  Copyright (c) 1998 Inprise Corporation. All Rights Reserved.
#
#  Make sure of the following before you run make:
#       - your $ODEDIR environment variable is set
#       - $ODEDIR/bin is in your path
#
###############################################################################

# The interface name
INTF = fractal

# Server exe name
SERV = fracsrv

# Main

CC = cl /nologo /W3 /GX /Zi /YX /Od /D "WIN32" /D "_CONSOLE" /FR /D "__WIN32__" $(INCS)
LD = link /DEBUG /DEBUGTYPE:BOTH
INCS = -I$(ODEDIR)/include -I$(ODEDIR)/DCEINC  
LIBS = /SUBSYSTEM:console /NOLOGO $(ODEDIR)/lib/oden40.lib $(ODEDIR)\LIB\COMPAT.LIB $(ODEDIR)/lib/w32pthd.lib

SOBJ = fractal.obj $(INTF)_s.obj $(INTF)sm.obj

.c.obj:
	$(CC) -c $< $(INCS) -Fo"$*.obj"

all: server

server: $(SOBJ)
	$(LD) /out:$(SERV).exe $(SOBJ) $(LIBS)

clean:
	-del $(SERV).exe 
	-del *_c.* 
	-del *_s.*
	-del $(INTF)_s.h
	-del $(INTF)sm.c 
	-del *.obj
	-del *.sbr 
	-del *.pch
	-del *.pdb








