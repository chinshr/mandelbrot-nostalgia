###############################################################################
#  
#  Makefile  (UNIX)
#
#  Copyright (c) Borland International, All Rights Reserved.
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

# UNIX	
OBJEXT = .o
OBJOUTPARAM = -o $*$(OBJEXT)	

# Main

CC = `getplatform cc`    
LD = `getplatform ld`    
LIBS = `getplatform lib` 
INCS = `getplatform inc` 

SOBJ = fractal$(OBJEXT) $(INTF)_s$(OBJEXT) $(INTF)sm$(OBJEXT)

.c.o:
	$(CC) -g -c $< $(INCS) $(OBJOUTPARAM)

all: server

server: $(SOBJ)
	$(LD) -g -o $(SERV) $(SOBJ) $(LIBS)

clean:
	-rm $(SERV) 
	-rm *_c.* 
	-rm *_s.*
	-rm $(INTF)sm.c 
	-rm *$(OBJEXT)









