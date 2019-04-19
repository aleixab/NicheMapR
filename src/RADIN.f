      SUBROUTINE RADIN
C     NICHEMAPR: SOFTWARE FOR BIOPHYSICAL MECHANISTIC NICHE MODELLING

C     COPYRIGHT (C) 2018 MICHAEL R. KEARNEY AND WARREN P. PORTER

C     THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY 
C     IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY 
C     THE FREE SOFTWARE FOUNDATION, EITHER VERSION 3 OF THE LICENSE, OR (AT
C      YOUR OPTION) ANY LATER VERSION.

C     THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C     WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF 
C     MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU 
C     GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C     YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE 
C     ALONG WITH THIS PROGRAM. IF NOT, SEE HTTP://WWW.GNU.ORG/LICENSES/.

C     COMPUTES LONGWAVE RADIATION ABSORBED

      IMPLICIT NONE

      DOUBLE PRECISION A1,A2,A3,A4,A4B,A5,A6,ABSAN,ABSSB,AL,AMASS,ANDENS
      DOUBLE PRECISION AREF,ASIL,ASILN,ASILP,ATOT,BREF,CREF,DEPSUB
      DOUBLE PRECISION EMISAN,EMISSB,EMISSK,F12,F13,F14,F15,F16,F21,F23
      DOUBLE PRECISION F24,F25,F26,F31,F32,F41,F42,F51,F52,F61,FATOBJ
      DOUBLE PRECISION FATOSB,FATOSK,FLSHCOND,FLUID,FSKY,G,HRN,IR1,IR2
      DOUBLE PRECISION IR3,IR4,IR5,IR6,PCTDIF,PHI,PHIMAX,PHIMIN,PTCOND
      DOUBLE PRECISION PTCOND_ORIG,QCOND,QCONV,QIRIN,QIROBJ,QIROUT
      DOUBLE PRECISION QIRSKY,QIRSUB,QMETAB,QRESP,QSEVAP,QSOL,QSOLAR
      DOUBLE PRECISION QSOLR,RELHUM,RH,RHO1_3,RHREF,SHADE,SIDEX,SIG
      DOUBLE PRECISION SUBTK,TA,TALOC,TANNUL,TIME,TKOBJ,TKSKY,TKSUB,TOBJ
      DOUBLE PRECISION TQSOL,TRANS1,TREF,TSKY,TSKYC,TSUB,TSUBST,TWING
      DOUBLE PRECISION VEL,VLOC,VREF,WC,WQSOL,Z,ZEN

      INTEGER IHOUR,MICRO,NM,WINGMOD,WINGCALC

      DIMENSION HRN(25),QSOL(25),RH(25),RHREF(25),TALOC(25),TIME(25)
      DIMENSION TREF(25),TSKYC(25),TSUB(25),VLOC(25),VREF(25),Z(25)

      COMMON/ENVAR1/QSOL,RH,TSKYC,TIME,TALOC,TREF,RHREF,HRN
      COMMON/ENVAR2/TSUB,VREF,Z,TANNUL,VLOC
      COMMON/FUN1/QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT,QCONV,QCOND
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG
      COMMON/FUN5/WC,ZEN,PCTDIF,ABSSB,ABSAN,ASILN,FATOBJ,NM
      COMMON/WDSUB1/ANDENS,ASILP,EMISSB,EMISSK,FLUID,G,IHOUR
      COMMON/WDSUB2/QSOLR,TOBJ,TSKY,MICRO
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51
     &,SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52
     &,F61,TQSOL,A1,A2,A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26
     &,WINGCALC,WINGMOD
      COMMON/WSOLAR/ASIL,SHADE

      TKSKY=TSKY+273.15
      TKSUB=TSUBST+273.15

      IF(WINGMOD.EQ.2)THEN
C      CURRENTLY ASSUMING POSTURE IS PARALLEL TO THE GROUND AND THAT THE 
C      VIEW THROUGH SURFACES 5 AND 6 ARE HALF GROUND AND HALF SKY
       TKOBJ = TWING + 273.15
C      TOP OF THORAX IR
       IR1=EMISAN*SIG*A2*F12*TKOBJ**4
       IR2=EMISAN*SIG*A2*F32*TKOBJ**4
       IR3=EMISAN*SIG*A2*F42*TKSKY**4
       IR4=EMISAN*SIG*A2*F52*((TKSKY+TKSUB)/2.)**4
       IR5=EMISAN*SIG*A2*F52*((TKSKY+TKSUB)/2.)**4
C      BOTTOM OF THORAX IR
       IR6=EMISAN*1*ATOT*EMISSB*SIG*TKSUB**4
       QIRIN=IR1+IR2+IR3+IR4+IR5+IR6
      ELSE
       TKOBJ=TSUBST+273.15
       FSKY=FATOSK-FATOBJ
       IF(FSKY.LT.0.000) THEN
        FSKY=0.0
       ENDIF
       QIROBJ=EMISAN*FATOBJ*ATOT*EMISSB*SIG*TKOBJ**4
       QIRSKY=EMISAN*FSKY*ATOT*EMISSK*SIG*TKSKY**4
       QIRSUB=EMISAN*FATOSB*ATOT*EMISSB*SIG*TKSUB**4
       QIRIN=QIRSKY+QIRSUB+QIROBJ
      ENDIF

      RETURN
      END