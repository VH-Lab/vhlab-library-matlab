/*=================================================================
 *
 * SLIDINGWINDOW.C	Performs dot discrimination for dotdiscriminator.
 *  2005-12-07, Steve Van Hooser, vanhooser@neuro.duke.edu
 * The calling syntax is:
 *
 *		[W] = SLIDINGWINDOW(Y,T0,T1,TE)
 *
 *  Computes values of sliding window along a data vector Y
 *  starting at T0 and ending at T1+TE.  TE is the width of the window.
 *  Look at the corresponding M-code, slidingwindow.m, for help.
 *
 *=================================================================*/
#include <math.h>
#include "mex.h"

#define	Y_IN	prhs[0] 
#define T0 	prhs[1]
#define T1 	prhs[2]
#define TE 	prhs[3]
#define	W_OUT	plhs[0]

#if !defined(MAX)
#define MAX(A, B)   ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B)   ((A) < (B) ? (A) : (B))
#endif

static void slidingwindow(double y[],int ylen, int t0, int t1, int te, double *w[],int *Wlen)
{
	int i;
	double currWindowVal = 0, windLen = te;

	*Wlen = (t1-t0)+1;
	(*w) = (double*)malloc((*Wlen)*sizeof(double));

	/* sum up the first window */
	for (i=t0; i<(t0+te);i++) {currWindowVal += y[i];}

	/* now slide the window along, adding onto the end and subtracting the beginning */
	for (i=t0+te;i<(t1+te);i++) {
		(*w)[i-(t0+te)] = currWindowVal / windLen;
		currWindowVal += y[i] - y[i-(t0+te)];
	}
	(*w)[t1-t0] = currWindowVal / windLen; /* add the last point */
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] )
     
{ 
    double *y,*t0_,*t1_,*te_,*w,*neww; 
    int ylen, t0, t1, te,wlen,i;
    
    /* this is an internal function...let's dispense with argument checking*/
    /*   assumptions:  t1>t0, t1+te<=length of Y */

    if (nrhs<4) mexErrMsgTxt("Error in SLIDINGWINDOW:  four input arguments required.");
 
    y=mxGetPr(Y_IN);
    ylen = MAX(mxGetM(Y_IN),mxGetN(Y_IN));
	/*mexPrintf("Size of y: %d\n",numY);*/
    t0_=mxGetPr(T0); t1_=mxGetPr(T1);te_=mxGetPr(TE);
    /* subtract 1 from t0, t1 to convert to C array indexing */
    t0 = (int)t0_[0]-1; t1 = (int)t1_[0]-1; te = (int)te_[0];
    if (t0>t1) mexErrMsgTxt("T0 must be less than or equal to T1.");
    if (t1+te>ylen) mexErrMsgTxt("T1+TE must be less than or equal to length of Y");
    /*mexPrintf("Starting mex file.\n");*/
    slidingwindow(y,ylen,t0,t1,te,&w,&wlen); 
    /*mexPrintf("Done with slidingwindow.\n");*/
    /* Create a matrix for the return argument */ 
    if (mxGetM(Y_IN)>mxGetN(Y_IN)) {
	    W_OUT = mxCreateDoubleMatrix(wlen, 1, mxREAL); 
    } else {
	    W_OUT = mxCreateDoubleMatrix(1, wlen, mxREAL); 
    }
    neww = mxGetPr(W_OUT);
    /* copy the data into the new matrix */
    for (i=0;i<wlen;i++) {neww[i]=w[i];}
    free(w);
}


