/*-------------------------------------------------------------------------------- 
 *
 *  fractal.h
 *
 *  Server code for calculating a mandelbrot set
 *
 *  Copyright (c) 1998  Inprise Corporation. All Rights Reserved.
 *
 *--------------------------------------------------------------------------------*/

#ifndef _fractal_h_
#define _fractal_h_

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <sys/timeb.h>

#include <ode.h>
#include <dceinc.h>
#if defined(_AIX41) || defined(sun)
#       include <dce/pthread.h>
#else
#       include <pthread.h>
#endif

#include "fractal_s.h"

#define OK  1
#define NOK 0


signed32 new_fractal(
		     client_data_t client_data,
		     hndl_t *handle
);

signed32 delete_fractal(
			hndl_t handle
);

fractal_t* retrieve_fractal(
			    hndl_t handle
);

signed32 accumulate_time(
			 struct timeb st,
			 struct timeb et
);

signed32 log_client_data(
			 client_data_t cd
);


#endif /* _fractal_h_*/
