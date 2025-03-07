###############################################################################
#  
#  dcc.mak (Win32)
#
#  usage: make -f delphi.mak [<options>]
#
#  Copyright (c) 1998 Inprise Corporation, All Rights Reserved.
#
###############################################################################

# The interface name
INTF = fractal

# Client name
CLNT = Fractal

INCS = -u$(ODEDIR)\delphi

all: client

client : $(INTF)_c.pas $(CLNT).dpr
  dcc32 $(CLNT).dpr

clean_client :
  del $(CLNT).exe

clean :
  -del $(CLNT).exe
  -del *.dcu
  -del *.dsk
  -del *.str
  -del *.opt
  -del *.dof
  -del *.scc
  -del *_c.pas
  -del *_hc.pas
  -del *.~??
  -del *.log





