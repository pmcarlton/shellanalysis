/* @(#) $Id: meantimesstd.c,v 1.4 2005/04/05 18:19:10 eric Exp $ */
/* $Name: release-remote-4-2-9 $ */

/* should calculate mean and std of each section. */

#include "IWInclude.h"

int main(int argc, char* argv[])
{
    int nxyz[3] ;
    int mxyz[3] = { 1, 1, 1 };
    char label[80] = "label";
    char nname[80];
    int count;
    float mmm[3];
    int Pixeltype;
    int h, i, j, k;
    float acc, themean, outputval, globalmean;
    float* src;
    static int init=1;
    float* xysec;
    float datum;
    int Numwaves;
    int Zsecs;
    float wvls[IW_MAX_WAVE];
    FILE* printout;
    char *uname;
    char tmpname[80];
    int now;

    /*
     * Open a new file using the name specified on the command line or
     * a default value if one was not specified.
     */

    IMOpen(1, argv[1] ,"ro");
    IMRdHdr(1, nxyz, mxyz, &Pixeltype, &mmm[0], &mmm[1], &mmm[2]);
    IMRtWav(1, &Numwaves, wvls);
    Zsecs=nxyz[2]/Numwaves;

    if(init){
        xysec=(float*)malloc(nxyz[0]*nxyz[1]*sizeof(float));
        init=0;
    }


    now=getpid();
    uname=getenv("LOGNAME");
    sprintf(tmpname,"/tmp/secvals.%s.%s.txt",argv[2],uname);
    printout=fopen(tmpname,"w");
    for (h=0;h<=0;h++) { //do 1st wave only
        printf("wave %i ",h);
        globalmean=0;
        for (i=0;i<Zsecs;i++) {
        acc=0;
            IMRdSec(1,xysec);
            for (j=0;j<(nxyz[0]*nxyz[1]);j++) {
                    acc+=xysec[j];
            }
            themean=acc/j;
            globalmean+=themean;
            acc=0;
            for (j=0;j<(nxyz[0]*nxyz[1]);j++) {
                acc+=((xysec[j]-themean)*(xysec[j]-themean));
            }
            outputval=acc/j;
            fprintf(printout,"%.4f\n",outputval);
        }
        globalmean/=i;
    }
    fprintf(printout,"%.4f\n",globalmean);
    fclose(printout);
    return 0;
}
