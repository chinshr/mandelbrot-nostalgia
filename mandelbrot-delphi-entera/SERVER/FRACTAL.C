/*-------------------------------------------------------------------------------- 
 *
 *  fractal.c
 *
 *  Server code for calculating a mandelbrot set
 *
 *  Copyright (c) 1998  Inprise Corporation. All Rights Reserved.
 *
 *--------------------------------------------------------------------------------*/
#include "fractal.h"


static pthread_mutex_t list_lock;

static fractal_t *anchor = NULL;
static server_data_t server_data;

/*
 * initialize_fractal();
 */
int initialize_fractal(int argc, char**argv) {
  pthread_mutex_init(&list_lock, pthread_mutexattr_default);
  anchor=NULL;
  server_data.handles=0;
  return OK;
}

/*
 * finalize_fractal();
 */
void finalize_fractal() {
  fractal_t *actual=anchor;
  fractal_t *next=NULL;

  if (NULL==actual)
    return;

  pthread_mutex_lock(&list_lock);
  while (actual!=NULL) {
    next=actual->next;
    ode_mem_free(actual);
    actual=next;
  }

  pthread_mutex_unlock(&list_lock);
  return;
}

/*-------------------------------------------------------------------------------- 
 *  RPC interface
 *--------------------------------------------------------------------------------*/

/*
 * open()
 */
hndl_t open(
	    client_data_t cd
	    ) {
  hndl_t handle;
  char svcname[128];
  char ifname[128];
  char opname[128];
  signed32 rc=0;
  fractal_t *actual=NULL;
  signed32 at=0;
  struct timeb st;
  struct timeb et;

  ftime(&st);

  server_data.rpc_requests++;
  server_data.bytes_received+=sizeof(client_data_t);
  server_data.bytes_sent+=sizeof(signed32);

  ode_svr_get_call_info(svcname, ifname, opname);
  if ( OK==(rc=new_fractal(cd, &handle)) ) {
    printf("Service\t\t<%s>\nInterface\t<%s>\nOperation\t<%s(%i, %i, %i, {%fl, %fl, %fl, %fl}, &%i)>\n\n", svcname, ifname, opname, cd.width, cd.height, cd.iterations, cd.mndset.real_min, cd.mndset.real_max, cd.mndset.imag_min, cd.mndset.imag_max, handle);
  }

  ftime(&et);
  at=accumulate_time(st, et);
  server_data.rpc_time+=at;
  
  if (OK!=rc) {
    handle=0;
  } else {
    actual=retrieve_fractal(handle);
    actual->client_data.rpc_requests++;
    actual->client_data.bytes_received+=sizeof(client_data_t);
    actual->client_data.bytes_sent+=sizeof(signed32);
    actual->client_data.rpc_time+=at;
  }
  return handle;
}

/*
 * close()
 */
client_data_t close(
		    hndl_t handle
	      ) {
  char svcname[128];
  char ifname[128];
  char opname[128];
  signed32 rc=0;
  fractal_t *actual=NULL;
  signed32 at=0;
  struct timeb st;
  struct timeb et;
  client_data_t cd;

  ftime(&st);

  server_data.rpc_requests++;
  server_data.bytes_received+=sizeof(signed32);
  server_data.bytes_sent+=sizeof(signed32);

  ode_svr_get_call_info(svcname, ifname, opname);
  printf("Service\t\t<%s>\nInterface\t<%s>\nOperation\t<%s(%i)>\n\n", svcname, ifname, opname, handle);

  ftime(&et);
  at=accumulate_time(st, et);
  server_data.rpc_time+=at;

  actual=retrieve_fractal(handle);
  if (NULL!=actual) {
    actual->client_data.rpc_requests++;
    actual->client_data.bytes_received+=sizeof(signed32);
    actual->client_data.bytes_sent+=sizeof(signed32);
    actual->client_data.rpc_time+=at;
    cd=actual->client_data;
  }

  rc=delete_fractal(handle); 

  return cd;
}

/*
 * get_next()
 */
signed32 get_next(
		  hndl_t handle,
		  signed32 *outwidth,
		  idl_byte **row
		  ) {
  idl_byte *p=NULL;
  fractal_t *actual=NULL;
  int v=0;
  idl_byte n=0;
  double d=0;
  signed32 at=0;
  struct timeb st;
  struct timeb et;

  ftime(&st);

  actual=retrieve_fractal(handle);

  if (NULL==actual)
    return NOK;

  *row=(idl_byte*)ode_mem_malloc( actual->width * sizeof(idl_byte) );
  p=*row;
  if (NULL==*row)
    return NOK;

  actual->b=actual->b+actual->delta_b;
  actual->a=actual->mndset.real_min-actual->delta_a;

  for (v=0; v<actual->width; v++) {
    actual->a=actual->a+actual->delta_a;
    n=0; actual->r=actual->xr; actual->i=actual->yi; d=0;
    while ( (d<4) && (n!=actual->iterator) ) {
      actual->x=actual->r;
      actual->y=actual->i;
      actual->r=actual->x*actual->x-actual->y*actual->y+actual->a;
      actual->i=2*actual->x*actual->y+actual->b;
      d=actual->r*actual->r+actual->i*actual->i;
      n++;
    }
    *p=n;

    p++;
  }
 
  *outwidth=actual->width;
  server_data.rpc_requests++;
  server_data.bytes_received+=sizeof(handle);
  server_data.bytes_sent+=sizeof(signed32)+(*outwidth*sizeof(idl_byte));

  ftime(&et);
  at=accumulate_time(st, et);
  server_data.rpc_time+=at;

  actual->client_data.rpc_requests++;
  actual->client_data.bytes_received+=sizeof(handle);
  actual->client_data.bytes_sent+=sizeof(signed32)+(*outwidth*sizeof(idl_byte));
  actual->client_data.rpc_time+=at;

  return n;
}

/*
 * query_server()
 */
signed32 query_server(
		      server_data_t   *sd
) {
  *sd=server_data;
  return OK;
}

/*-------------------------------------------------------------------------------- 
 *  Work functions
 *--------------------------------------------------------------------------------*/

/*
 * new_fractal();
 */
signed32 new_fractal(
		     client_data_t client_data,
		     hndl_t *handle
		     ) {
  fractal_t *actual=NULL;
  fractal_t *self=anchor;
  int i=0;

  actual=(fractal_t*)malloc(sizeof(fractal_t));
  if (NULL==actual)
    return NOK;

  /* Initialize new node */
  actual->handle=(hndl_t)actual;

  actual->width=client_data.width;
  actual->height=client_data.height;
  actual->iterator=client_data.iterations;

  actual->x=0;
  actual->y=0;
  actual->r=0;
  actual->i=0;
  actual->d=0;
  actual->v=0;
  actual->u=0;
  actual->a=0;
  actual->b=0;
  actual->mndset=client_data.mndset;
  actual->xr=0;
  actual->yi=0;
  actual->delta_a=(actual->mndset.real_max-actual->mndset.real_min)/actual->width;
  actual->delta_b=(actual->mndset.imag_max-actual->mndset.imag_min)/actual->height;
  actual->b=actual->mndset.imag_min-actual->delta_b;
  
  actual->next=NULL;

  /* lock mutex */
  pthread_mutex_lock(&list_lock);

  server_data.handles++;

  /* First element? */
  if (NULL==anchor) {
    anchor=actual;
    *handle=actual->handle;
    /* unlock mutex */
    pthread_mutex_unlock(&list_lock);
    return OK;
  }

  /* Search through list Append */
  while (self->next!=NULL) {
    self=self->next;
    i++;
  }
  self->next=actual;
  *handle=(hndl_t)actual->handle;
  pthread_mutex_unlock(&list_lock);

  return OK;
}

/*
 * delete_fractal()
 */
signed32 delete_fractal(hndl_t handle) {
  fractal_t *actual=anchor;
  fractal_t *previous=NULL;
  if (NULL==actual)
    return NOK;

  pthread_mutex_lock(&list_lock);
  while (actual!=NULL) {
    if (actual->handle==handle) {
      if (actual==anchor) {
	if (NULL==actual->next) {
	  ode_mem_free(actual);
	  anchor=NULL;
	  server_data.handles=0;
	  pthread_mutex_unlock(&list_lock);
	  return OK;
	}
	anchor=actual->next;
	ode_mem_free(actual);
	server_data.handles--;
	pthread_mutex_unlock(&list_lock);
	return OK;
      } else {
	if (NULL==previous) {
	  pthread_mutex_unlock(&list_lock);
	  return NOK;
	}
	if (NULL!=actual->next)
	  previous->next=actual->next;
	else 
	  previous->next=NULL;
	ode_mem_free(actual);
	server_data.handles--;
	pthread_mutex_unlock(&list_lock);
	return OK;
      }
    }
    previous=actual;
    actual=actual->next;
  }

  pthread_mutex_unlock(&list_lock);
  return NOK;
}

/*
 * retrieve_fractal()
 */
fractal_t* retrieve_fractal(hndl_t handle) {
  fractal_t *actual=anchor;

  pthread_mutex_lock(&list_lock);
  while (actual!=NULL) {
    if (handle==actual->handle) {
      pthread_mutex_unlock(&list_lock);
      return actual;
    }
    actual=actual->next;
  }
  
  pthread_mutex_unlock(&list_lock);
  return NULL;
}

/*
 * accumulate_time() - calculates accumulated time of each start and end time
 *                     in milli-seconds.
 */
signed32 accumulate_time(struct timeb st, struct timeb et) {
  long secs=0;
  short millis=0;
  long accu=0;

  if (st.time==et.time) {
    millis=et.millitm-st.millitm;
    secs=0;
  } else {
    millis=(1000-st.millitm) + (et.millitm);
    secs=et.time-(st.time+1);
  } 

  accu+=(secs*1000)+millis;
  return accu;
}

/*
 * log_client_data()
 */
signed32 log_client_data(client_data_t cd) {
  return OK;
}
