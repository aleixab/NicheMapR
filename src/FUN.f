      FUNCTION FUN(X)

C     NICHEMAPR: SOFTWARE FOR BIOPHYSICAL MECHANISTIC NICHE MODELLING

C     COPYRIGHT (C) 2018 MICHAEL R. KEARNEY AND WARREN P. PORTER

C     THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C     IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C     THE FREE SOFTWARE FOUNDATION, EITHER VERSION 3 OF THE LICENSE, OR (AT
C     YOUR OPTION) ANY LATER VERSION.

C     THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C     WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C     MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C     GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C     YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C     ALONG WITH THIS PROGRAM. IF NOT, SEE HTTP://WWW.GNU.ORG/LICENSES/.

C     EQUATIONS FOR STEADY STATE HEAT BUDGET, USED TO FIND TB VIA ROOT
C     FINDING ALGORITHM ZBRENT

      IMPLICIT NONE

      DOUBLE PRECISION A,A1,A2,A3,A4,A4B,A5,A6,ABSMAX,ABSMIN,AIRVOL,AL
      DOUBLE PRECISION ALT,AMASS,ANDENS,AREA,AREF,ASEMAJR,ASIL,ASILP,ASQ
      DOUBLE PRECISION ATOT,B,BP,BREF,BSEMINR,BSQ,C,CO2MOL,CREF,CSEMINR
      DOUBLE PRECISION CSQ,CUSTOMGEOM,DELTAR,DEPSUB,EGGSHP,EMISAN,EMISSB
      DOUBLE PRECISION EMISSK,ENB,EXTREF,F12,F13,F14,F15,F16,F21,F23,F24
      DOUBLE PRECISION F25,F26,F31,F32,F41,F42,F51,F52,F61,FATCOND
      DOUBLE PRECISION FATOSB,FATOSK,FLSHCOND,FLTYPE,FLUID,FLYMETAB
      DOUBLE PRECISION FLYSPEED,FLYTIME,FUN,G,GEVAP,GN,H2O_BALPAST,MR_1
      DOUBLE PRECISION MR_2,MR_3,PHI,PHIMAX,PHIMIN,PI,PSIBODY,PTCOND
      DOUBLE PRECISION PTCOND_ORIG,QCOND,QCONV,QGENET,QIN,QIRIN,QIROUT
      DOUBLE PRECISION QMETAB,QOUT,QRESP,QSEVAP,QSOLAR,QSOLR,QSWEAT,R,R1
      DOUBLE PRECISION RELHUM,RFLESH,RHO1_3,RINSUL,RQ,RSKIN,S1,SHADE,SHP
      DOUBLE PRECISION SIDEX,SIG,SPHEAT,SUBTK,TA,TBASK,TC,TDIGPR,TEMERGE
      DOUBLE PRECISION TLUNG,TMAXPR,TMINPR,TOBJ,TPREF,TQSOL,TR,TRANS1
      DOUBLE PRECISION TSKIN,TSKY,TSUBST,TWING,VEL,VOL,WEVAP,WQSOL,X
      DOUBLE PRECISION XTRY
      
      DOUBLE PRECISION, DIMENSION(24) :: V,ED,WETMASS,WETSTORAGE,
     & CUMREPRO,HS,E_S,L_W,CUMBATCH,Q,V_BABY1,E_BABY1,WETGONAD,
     & E_H,EH_BABY1,SURVIV,VOLD,VPUP,EPUP,E_HPUP,
     & PAS,PBS,PCS,PDS,PGS,PJS,PMS,PRS,WETFOOD     
      DOUBLE PRECISION STAGE,RAINDRINK,EGGPTCOND,POT
      DOUBLE PRECISION POTFREEMASS,GUTFREEMASS,CO2FLUX,O2FLUX 

      INTEGER CLIMBING,DEB1,FLIGHT,FLYER,FLYTEST,GEOMETRY,IHOUR,LIVE
      INTEGER MICRO,NODNUM,WINGCALC,WINGMOD,CENSUS,VIVIPAROUS,PREGNANT,
     & RESET,DEADEAD,STARTDAY,DEAD,EGGMULT
      
      DIMENSION CUSTOMGEOM(8),SHP(3),EGGSHP(3)

      COMMON/ANPARMS/RINSUL,R1,AREA,VOL,FATCOND
      COMMON/BEHAV2/GEOMETRY,NODNUM,CUSTOMGEOM,SHP,EGGSHP
      COMMON/CLIMB/CLIMBING
      COMMON/ELLIPS/ASEMAJR,BSEMINR,CSEMINR
      COMMON/FLY/FLYTIME,FLYSPEED,FLYMETAB,FLIGHT,FLYER,FLYTEST
      COMMON/FUN1/QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT,QCONV,QCOND
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG,
     & EGGPTCOND,POT
      COMMON/FUN4/TSKIN,R,WEVAP,TR,ALT,BP,H2O_BALPAST
      COMMON/FUN6/SPHEAT,ABSMAX,ABSMIN,LIVE
      COMMON/GUESS/XTRY
      COMMON/REVAP1/TLUNG,DELTAR,EXTREF,RQ,MR_1,MR_2,MR_3,DEB1
      COMMON/REVAP2/GEVAP,AIRVOL,CO2MOL
      COMMON/SOLN/ENB
      COMMON/TPREFR/TMAXPR,TMINPR,TDIGPR,TPREF,TBASK,TEMERGE
      COMMON/TREG/TC
      COMMON/WATERPOT/PSIBODY      
      COMMON/WCONV/FLTYPE
      COMMON/WDSUB1/ANDENS,ASILP,EMISSB,EMISSK,FLUID,G,IHOUR
      COMMON/WDSUB2/QSOLR,TOBJ,TSKY,MICRO
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51,
     & SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52,F61,TQSOL,A1,A2,
     &A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26,WINGCALC,WINGMOD
      COMMON/WMET/QSWEAT
      COMMON/WSOLAR/ASIL,SHADE
      COMMON/DEBMOD/V,ED,WETMASS,WETSTORAGE,WETGONAD,WETFOOD,O2FLUX,
     & CO2FLUX,CUMREPRO,HS,E_S,L_W,CUMBATCH,Q,V_BABY1,E_BABY1,
     & E_H,STAGE,EH_BABY1,GUTFREEMASS,SURVIV,VOLD,VPUP,EPUP,E_HPUP,
     & RAINDRINK,POTFREEMASS,PAS,PBS,PCS,PDS,PGS,PJS,PMS,PRS,CENSUS,
     & RESET,DEADEAD,STARTDAY,DEAD,EGGMULT
      COMMON/VIVIP/VIVIPAROUS,PREGNANT

      DATA PI/3.14159265/

C     THE GUESSED VARIABLE, X, IS CORE TEMPERATURE (C); SEE SUB. MET
C     FOR DETAILED EXPLANATION OF CALCULATION OF SURF. TEMP., TSKIN,
C     FROM TC AND MASS
C     THIS ASSUMES UNIFORM BODY TEMPERATURE.

C     CONTROL OF BODY TEMPERATURE GUESSES FOR STABILITY PURPOSES
      IF(X.GT.100.)THEN
      X = 100.
      ELSE
C      IF(X.LT.-50.0)THEN
C       X=TA+0.1
C      ENDIF
      ENDIF

      TC = X
      XTRY = X

C     GET THE METABOLIC RATE
C     CHECKING FOR INANIMATE OBJECT
      IF(LIVE.EQ.0) THEN
C      INANIMATE
       QMETAB=0.0
       TC=X
      ELSE
C      ALIVE, BUT IS IT TOO COLD?
       IF(TC .GE. 0.0)THEN
        CALL MET
       ELSE
C       TOO COLD, SUPER LOW METABOLISM
        QMETAB = 0.0001
        TC = X
       ENDIF
      ENDIF

C     GET THE RESPIRATORY WATER LOSS
C     CHECKING FOR FLUID TYPE
      IF(FLTYPE.EQ.0.00)THEN
C      AIR
C      CALL FOR RESPIRATORY WATER & ENERGY LOSS
       IF(QMETAB.GE.0.000) THEN
        IF((DEB1.EQ.0).OR.(STAGE.GT.0))THEN ! NO RESPIRATORY HEAT EXCHANGE FOR EGGS
         CALL RESP
        ENDIF
       ELSE
C       NEGATIVE METABOLIC RATE. NO PHYSIOLOGICAL MEANING - DEAD.
        QRESP=0.00000
        QMETAB=0.00000
       ENDIF
      ENDIF

C     NET INTERNAL HEAT GENERATION
      QGENET=QMETAB-QRESP
C     NET INTERNAL HEAT GENERATION/UNIT VOLUME. USE FOR ESTIMATING SKIN TEMP.
      GN=QGENET/VOL
      IF(LIVE.EQ.0) THEN
       GN=0.
      ENDIF

C     COMPUTING SURFACE TEMPERATURE AS DICTATED BY GEOMETRY

C	  CHECKING FIRST IF AN EGG
      IF((DEB1.EQ.1).AND.(STAGE.LT.1).AND.(VIVIPAROUS.EQ.0))THEN
C      ELLIPSOID: DERIVED 24 OCTOBER, 1993  W. PORTER
       IF((GN.GT.0).AND.(TC.NE.0))THEN
       GN=GN+0.
       ENDIF
       A=ASEMAJR
       B=BSEMINR
       C=CSEMINR
       ASQ=A**2.
       BSQ=B**2.
       CSQ=C**2.
       TSKIN=TC-(GN/(2.*FLSHCOND))*((ASQ*BSQ*CSQ)/
     & (ASQ*BSQ+ASQ*CSQ+BSQ*CSQ))
C      COMPUTING AVERAGE TORSO TEMPERATURE FROM CORE TO SKIN
       TLUNG=(GN/(4.*FLSHCOND))*((ASQ*BSQ*CSQ)/
     & (ASQ*BSQ+ASQ*CSQ+BSQ*CSQ))+TSKIN
      ELSE

      IF(GEOMETRY.EQ.0)THEN
C      FLAT PLATE
       TSKIN=TC-G*R**2./(2.*FLSHCOND)
      ENDIF

C     FIRST SET AVERAGE BODY TEMPERATURE FOR ESTIMATION OF AVEARAGE LUNG TEMPERATURE
      IF(GEOMETRY.EQ.1) THEN
C      CYLINDER: FROM P. 270 BIRD, STEWART & LIGHTFOOT. 1960. TRANSPORT PHENOMENA.
C      TAVE = (GR**2/(8K)) + TSKIN, WHERE TSKIN = TCORE - GR**2/(4K)
C      NOTE:  THESE SHOULD ALL BE SOLVED SIMULTANEOUSLY.  THIS IS AN APPROXIMATION
C      USING CYLINDER GEOMETRY. SUBCUTANEOUS FAT IS ALLOWED IN CYLINDER & SPHERE
C      CALCULATIONS.
       RFLESH=R1-RINSUL
       TSKIN=TC-GN*RFLESH**2./(4.*FLSHCOND)
C      COMPUTING AVERAGE TORSO TEMPERATURE FROM CORE TO SKIN
       TLUNG = (GN*RFLESH**2.)/(8.*FLSHCOND)+TSKIN
      ENDIF

      IF(GEOMETRY.EQ.2) THEN
C      ELLIPSOID: DERIVED 24 OCTOBER, 1993  W. PORTER
       A=ASEMAJR
       B=BSEMINR
       C=CSEMINR
       ASQ=A**2.
       BSQ=B**2.
       CSQ=C**2.
       TSKIN=TC-(GN/(2.*FLSHCOND))*((ASQ*BSQ*CSQ)/
     & (ASQ*BSQ+ASQ*CSQ+BSQ*CSQ))
C      COMPUTING AVERAGE TORSO TEMPERATURE FROM CORE TO SKIN
       TLUNG=(GN/(4.*FLSHCOND))*((ASQ*BSQ*CSQ)/
     & (ASQ*BSQ+ASQ*CSQ+BSQ*CSQ))+TSKIN
      ENDIF

      IF(GEOMETRY.EQ.4)THEN
C      SPHERE:
       RFLESH = R1 - RINSUL
       RSKIN = R1
C      FAT LAYER, IF ANY
       S1=(QGENET/(4.*PI*FLSHCOND))*((RFLESH-RSKIN)/(RFLESH*RSKIN))
       TSKIN=TC-(GN*RFLESH**2.)/(6.*FLSHCOND)+S1
C      COMPUTING AVERAGE TORSO TEMPERATURE FROM CORE TO SKIN (12 BECAUSE TLUNG IS 1/2 THE TC-TSKIN DIFFERENCE, 6*AK1)
       TLUNG=(GN*RFLESH**2.)/(12.*FLSHCOND)+TSKIN
      ENDIF

      IF((GEOMETRY .EQ. 3).OR.(GEOMETRY.EQ.5))THEN
C      MODEL LIZARD/CUSTOM SHAPE AS CYLINDER
C      CYLINDER: FROM P. 270 BIRD, STEWART & LIGHTFOOT. 1960. TRANSPORT PHENOMENA.
C      TAVE = (GR**2/(8K)) + TSKIN, WHERE TSKIN = TCORE - GR**2/(4K)
C      NOTE:  THESE SHOULD ALL BE SOLVED SIMULTANEOUSLY.  THIS IS AN APPROXIMATION
C      USING CYLINDER GEOMETRY. SUBCUTANEOUS FAT IS ALLOWED IN CYLINDER & SPHERE
C      CALCULATIONS.
       RFLESH=R1-RINSUL
       TSKIN=TC-GN*RFLESH**2./(4.*FLSHCOND)
C      COMPUTING AVERAGE TORSO TEMPERATURE FROM CORE TO SKIN
       TLUNG=(GN*RFLESH**2.)/(8.*FLSHCOND)+TSKIN
      ENDIF
      ENDIF ! END CHECK IF EGG
C     LIMITING LUNG TEMPERATURE EXTREMES
      IF (TLUNG.GT.TC)THEN
       TLUNG=TC
      ENDIF
C     IF(TLUNG.LT.-3.)THEN
C      TLUNG=-3.
C     ENDIF
C
CC     LIMITING SKIN TEMPERATURE EXTREMES
C     IF(TSKIN.LT.-3.0)THEN
C      TSKIN=-3.
C     ENDIF

      CALL CONV
      CALL RESP
      CALL SEVAP
      CALL RADOUT
      CALL COND

      IF(FLTYPE.EQ.1.00) THEN
C      WATER ENVIRONMENT
       QSEVAP=0.
       WEVAP=0.
       QIRIN=0.
       QIROUT=0.
       QCOND=0.
      ENDIF

      QIN=QSOLAR+QIRIN+QMETAB
      QOUT=QRESP+QSEVAP+QIROUT+QCONV+QCOND
C     FINDING THE DEVIATION FROM ZERO IN GUESSING THE SOLUTION
      ENB=QIN-QOUT
      FUN=ENB

      RETURN
      END