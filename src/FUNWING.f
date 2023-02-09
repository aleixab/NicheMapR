      FUNCTION FUNWING (X)

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

C     SOLVES FOR THE TEMPERATURE OF A BUTTERFLY WING VIA ZBRENT

      IMPLICIT NONE

      DOUBLE PRECISION A1,A2,A3,A4,A4B,A5,A6,ABSAN,ABSMAX,ABSMIN,ABSSB
      DOUBLE PRECISION ACTHR,AHEIT,AIRVOL,AL,ALENTH,ALT,AMASS,ANDENS
      DOUBLE PRECISION AREA,AREF,ASEMAJR,ASIL,ASILN,ASILP,ATOT,AV,AWIDTH
      DOUBLE PRECISION BP,BREF,BSEMINR,CO2MOL,CREF,CSEMINR,CUSTOMGEOM
      DOUBLE PRECISION DELTAR,DEPSUB,EGGSHP,EMISAN,EMISSB,EMISSK,ENB
      DOUBLE PRECISION EXTREF,F12,F13,F14,F15,F16,F1SUB,F21,F23,F24,F25
      DOUBLE PRECISION F26,F31,F32,F41,F42,F51,F52,F61,FATCOND,FATOBJ
      DOUBLE PRECISION FATOSB,FATOSK,FLSHCOND,FLTYPE,FLUID,FUNWING,G
      DOUBLE PRECISION GEVAP,H2O_BALPAST,IR1,IR2,IR3,IR4,IR5,IR6,MR_1
      DOUBLE PRECISION MR_2,MR_3,NETQIR,NM,PDIF,PHI,PHIMAX,PHIMIN,PI
      DOUBLE PRECISION PTCOND,PTCOND_ORIG,QCOND,QCONV,QIN,QIRIN,QIROUT
      DOUBLE PRECISION QMETAB,QOUT,QRESP,QSEVAP,QSOLAR,QSOLR,QSWEAT,R,R1
      DOUBLE PRECISION RELHUM,RHO1_3,RINSUL,RQ,SHADE,SHP,SIDEX,SIG
      DOUBLE PRECISION SPHEAT,SUBTK,TA,TBASK,TC,TDIGPR,TEMERGE,TKOBJ
      DOUBLE PRECISION TKSKY,TKSKYSUB,TKSUB,TLUNG,TMAXPR,TMINPR,TOBJ
      DOUBLE PRECISION TPREF,TQSOL,TR,TRANS1,TSKIN,TSKY,TSUBST,TWING,VEL
      DOUBLE PRECISION VOL,WC,WEVAP,WQSOL,X,XTRY,ZEN,EGGPTCOND,POT
      
      INTEGER DEB1,GEOMETRY,IHOUR,LIVE,MICRO,NODNUM
      INTEGER WINGCALC,WINGMOD

      DIMENSION CUSTOMGEOM(8),SHP(3),EGGSHP(3)

      COMMON/ANPARMS/RINSUL,R1,AREA,VOL,FATCOND
      COMMON/BEHAV2/GEOMETRY,NODNUM,CUSTOMGEOM,SHP,EGGSHP
      COMMON/BEHAV3/ACTHR
      COMMON/ELLIPS/ASEMAJR,BSEMINR,CSEMINR
      COMMON/FUN1/QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT,QCONV,QCOND
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG,
     & EGGPTCOND,POT
      COMMON/FUN4/TSKIN,R,WEVAP,TR,ALT,BP,H2O_BALPAST
      COMMON/FUN5/WC,ZEN,PDIF,ABSSB,ABSAN,ASILN,FATOBJ,NM
      COMMON/FUN6/SPHEAT,ABSMAX,ABSMIN,LIVE
      COMMON/GUESS/XTRY
      COMMON/REVAP1/TLUNG,DELTAR,EXTREF,RQ,MR_1,MR_2,MR_3,DEB1
      COMMON/REVAP2/GEVAP,AIRVOL,CO2MOL
      COMMON/SOLN/ENB
      COMMON/TPREFR/TMAXPR,TMINPR,TDIGPR,TPREF,TBASK,TEMERGE
      COMMON/TREG/TC
      COMMON/WCONV/FLTYPE
      COMMON/WDSUB1/ANDENS,ASILP,EMISSB,EMISSK,FLUID,G,IHOUR
      COMMON/WDSUB2/QSOLR,TOBJ,TSKY,MICRO
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51,
     & SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52,F61,TQSOL,A1,A2,
     & A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26,WINGCALC,WINGMOD
      COMMON/WMET/QSWEAT
      COMMON/WSOLAR/ASIL,SHADE

      DATA PI/3.14159265/

      TC=X
      XTRY=X

C     GEOM FOR WING

C     FLAT PLATE
C     ASSUME A CUBE FOR THE MOMENT
      ALENTH=BREF/100.
      AWIDTH=CREF/100.
      AHEIT=0.01/100.
      ATOT=ALENTH*AWIDTH*2.+ALENTH*AHEIT*2.+AWIDTH*AHEIT*2.
      AREA=ATOT
      ASILN=ALENTH*AWIDTH
      ASILP=AWIDTH*AHEIT
      AL=ALENTH
      R=ALENTH/2.
      VOL=ALENTH*AWIDTH*AHEIT
      AV=ATOT/2

C     COMPUTING SURFACE TEMPERATURE AS DICTATED BY GEOMETRY

C     FLAT PLATE
      TSKIN=TC

C     LIMITING SKIN TEMPERATURE EXTREMES
C     IF(TSKIN.LT.-3.0) THEN
C      TSKIN=-3.00000
C     ENDIF

      CALL WINGS(RHO1_3,ABSAN,TRANS1,QSOLR,AREF,BREF,CREF,PHI,
     &F21,F31,F41,F51,F61,F12,F32,F42,F52,SIDEX,WQSOL,TQSOL,A1,A2,
     &A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26,ASILP)

C     COMPUTING LONG WAVE INFRARED ABSORBED
      TKSKY=TSKY+273.15
      TKSUB=TSUBST+273.15
      TKOBJ=TC+273.15

C     TOP OF WING IR
      IR1=EMISAN*SIG*(A2*F21*TKOBJ**4.-A1*F12*TKOBJ**4.)
      IR2=EMISAN*SIG*(A3*F31*TKOBJ**4.-A1*F13*TKOBJ**4.)
      IR3=EMISAN*SIG*(A4*F41*TKSKY**4.-A1*F14*TKOBJ**4.)
      IR4=EMISAN*SIG*(A5*F51*((TKSKY+TKSUB)/2.)**4.-A1*F15*TKOBJ**4.)
      IR5=EMISAN*SIG*(A6*F61*((TKSKY+TKSUB)/2.)**4.-A1*F16*TKOBJ**4.)
C     FORMULA FOR SURFACE OF A FINITE RECTANGLE TILTED RELATIVE TO AN INFINITE PLANE
C     IF PHI LE 90 THEN WING OBSCURED FROM SUBSTRATE BY BODY/OTHER WING SO MAKE F1SUB=0
      IF(PHI.LE.90)THEN
       F1SUB=0.
      ELSE
       F1SUB=(1.-COS((180.-PHI)*PI/180.))/2.
      ENDIF

C     BOTTOM OF WING IR
      TKSKYSUB=TKSUB*F1SUB+TKSKY*(1.-F1SUB)
      IR6=EMISAN*SIG*(A1*TKSKYSUB**4.-A1*TKOBJ**4.)
      NETQIR=IR1+IR2+IR3+IR4+IR5+IR6
      
      CALL CONV
      
      QIN=WQSOL+NETQIR
      QOUT=QCONV
      
C     FINDING THE DEVIATION FROM ZERO IN GUESSING THE SOLUTION
      ENB=QIN-QOUT
      FUNWING=ENB
      
      RETURN
      END