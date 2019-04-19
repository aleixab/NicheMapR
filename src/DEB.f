       SUBROUTINE DEB(HOUR)

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

C     IMPLEMENTATION OF KOOIJMAN'S KAPPA-RULE STANDARD DEB MODEL WITH METABOLIC
C     ACCELERATION INVOKED IF E_HJ != E_HP AND ABP (HEMIMETABOLOUS INSECT) MODEL
C     IF METAB_MODE=1. USES DOPRI5 ALGORITHM FOR INTEGRATION

      USE AACOMMONDAT
      IMPLICIT NONE
      
      EXTERNAL DGET_DEB,SOLOUT
      
      DOUBLE PRECISION A1,A2,A3,A4,A4B,A5,A6,ACTHR,AL,AMASS,ANDENS_DEB
      DOUBLE PRECISION ANNFOOD,AREF,ATOT,BREEDRAINTHRESH,BREEDTEMPTHRESH
      DOUBLE PRECISION BREF,CAUSEDEATH,CLUTCHA,CLUTCHB,CLUTCHENERGY
      DOUBLE PRECISION CLUTCHES,CLUTCHSIZE,CO2FLUX,CONTDEP,CONTH
      DOUBLE PRECISION CONTHOLE,CONTVOL,CONTW,CONTWET,CREF,CTMAX,CTMIN
      DOUBLE PRECISION CUMBATCH,CUMBATCH_INIT,CUMREPRO,CUMREPRO_INIT,D_V
      DOUBLE PRECISION DAYLENGTHFINISH,DAYLENGTHSTART,DEATHSTAGE
      DOUBLE PRECISION DEBFIRST,DEBQMET,DEBQMET_INIT,DELTA_DEB,DELTAR
      DOUBLE PRECISION DEPRESS,DEPSEL,DEPSUB,DRYFOOD,DSURVDT,DVDT,E_BABY
      DOUBLE PRECISION E_BABY_INIT,E_BABY1,E_EGG,E_G,E_H,E_H_INIT
      DOUBLE PRECISION E_H_PRES,E_H_START,E_HB,E_HE,E_HJ,E_HP,E_HPUP
      DOUBLE PRECISION E_HPUP_INIT,E_INIT,E_INIT_BABY,E_M,E_PRES
      DOUBLE PRECISION E_SCALED,ECTOINPUT,ED,EGGDRYFRAC,EGGSOIL,EH_BABY
      DOUBLE PRECISION EH_BABY_INIT,EH_BABY1,EMISAN,EPUP,EPUP_INIT,ES
      DOUBLE PRECISION ES_INIT,ES_PAST,ES_PRES,ESM,ETA_PA,ETAO,EXTREF,F
      DOUBLE PRECISION F12,F13,F14,F15,F16,F21,F23,F24,F25,F26,F31,F32
      DOUBLE PRECISION F41,F42,F51,F52,F61,FAECES,FATOSB,FATOSK
      DOUBLE PRECISION FECUNDITY,FLSHCOND,FOOD,FOODLIM,FUNCT,G,GH2OMET
      DOUBLE PRECISION GH2OMET_INIT,GUTFILL,GUTFREEMASS,GUTFULL,H_A
      DOUBLE PRECISION H_AREF,HALFSAT,HS,HS_INIT,HS_PRES,HRN,JM_JO,JMCO2
      DOUBLE PRECISION JMCO2_GM,JMH2O,JMH2O_GM,JMNWASTE,JMNWASTE_GM,JMO2
      DOUBLE PRECISION JMO2_GM,JOJE,JOJE_GM,JOJP,JOJP_GM,JOJV,JOJV_GM
      DOUBLE PRECISION JOJX,JOJX_GM,K_J,K_JREF,K_M,KAP,KAP_R,KAP_X
      DOUBLE PRECISION KAP_X_P,KAPPA,KAPPA_G,L_B,L_J,L_M,L_PRES,L_T
      DOUBLE PRECISION L_THRESH,LAMBDA,LAT,LENGTHDAY,LENGTHDAYDIR,LONGEV
      DOUBLE PRECISION M_V,MAXMASS,MINCLUTCH,MINED,MLO2,MLO2_INIT
      DOUBLE PRECISION MONMATURE,MONREPRO,MR_1,MR_2,MR_3,MU_AX,MU_E,MU_P
      DOUBLE PRECISION MU_V,MU_X,NEWCLUTCH,NWASTE,O2FLUX,ORIG_CLUTCHSIZE
      DOUBLE PRECISION ORIG_ESM,P_A,P_AM,P_B_PAST,P_C,P_D,P_G,P_J,P_M
      DOUBLE PRECISION P_MREF,P_MV,P_R,P_X,P_XM,P_XMREF,PHI,PHIMAX
      DOUBLE PRECISION PHIMIN,PI,POND_DEPTH,POTFREEMASS,PREVDAYLENGTH
      DOUBLE PRECISION PTCOND,PTCOND_ORIG,Q,Q_INIT,Q_PRES,QCOND,QCONV
      DOUBLE PRECISION QIRIN,QIROUT,QMETAB,QRESP,QSEVAP,QSOL,QSOLAR
      DOUBLE PRECISION RAINDRINK,RAINFALL,RELHUM,REPRO,RH,RHO1_3,RHREF
      DOUBLE PRECISION RQ,S_M,S_G,S_J,SC,SCALED_L,SIDEX,SIG,STAGE
      DOUBLE PRECISION STAGE_REC,STARVE,SUBTK,SURVIV,SURVIV_INIT
      DOUBLE PRECISION SURVIV_PRES,L_W,L_WREPRO,T_A,T_AH,T_AL,T_H,T_L
      DOUBLE PRECISION T_REF,TA,TALOC,TB,TBASK,TC,TCORES,TCORR,TDIGPR
      DOUBLE PRECISION TEMERGE,TESTCLUTCH,TIME,TLUNG,TMAXPR,TMINPR,TPREF
      DOUBLE PRECISION TQSOL,TRANS1,TREF,TSKYC,TSUBST,TWATER,TWING,V
      DOUBLE PRECISION V_BABY,V_BABY_INIT,V_BABY1,V_INIT,V_INIT_BABY,V_M
      DOUBLE PRECISION V_PRES,VDOT,VDOTREF,VEL,VOLD,VOLD_INIT,VPUP
      DOUBLE PRECISION VPUP_INIT,W_E,W_N,W_P,W_V,W_X,WETFOOD,WETGONAD
      DOUBLE PRECISION WETMASS,WETSTORAGE,WQSOL,X_FOOD,Y_EV_L,YEX,YPX
      DOUBLE PRECISION YXE,ZFACT,WORK,RPAR,RTOL,ATOL,YY,XEND,X
      DOUBLE PRECISION RAINMULT

      INTEGER AEST,AESTIVATE,AQUABREED,AQUASTAGE,AQUATIC,BATCH,BREEDACT
      INTEGER BREEDACTTHRES,BREEDING,BREEDTEMPCUM,BREEDVECT,CENSUS
      INTEGER COMPLETE,COMPLETION,CONTONLY,CONTYPE,COUNTDAY,COUNTER
      INTEGER CTKILL,CTMINCUM,CTMINTHRESH,DAYCOUNT,DEAD,DEADEAD,DEB1
      INTEGER DEHYDRATED,DOY,F1COUNT,FEEDING,FIRSTDAY,HOUR,I,INWATER
      INTEGER IYEAR,METAB_MODE,METAMORPH,NN,NYEAR,PHOTODIRF
      INTEGER PHOTODIRS,PHOTOFINISH,PHOTOSTART,PREGNANT,PREVDEAD,RESET
      INTEGER STAGES,STARTDAY,STARVING,VIVIPAROUS,WAITING,WETMOD
      INTEGER WINGCALC,WINGMOD
      INTEGER RAINHOUR
      
      CHARACTER*1 TRANST

      DIMENSION ACTHR(25),BREEDVECT(24),CUMBATCH(24),CUMREPRO(24)
      DIMENSION DEBFIRST(13),DEBQMET(24),DEPSEL(25),DRYFOOD(24)
      DIMENSION E_BABY1(24),E_H(24),E_HPUP(24),ECTOINPUT(127),ED(24)
      DIMENSION EGGSOIL(24),EH_BABY1(24),EPUP(24),ES(24),ETAO(4,3)
      DIMENSION FAECES(24),FOOD(50),GH2OMET(24),HS(24),HRN(25)
      DIMENSION JM_JO(4,4),MLO2(24),NWASTE(24),Q(24),REPRO(24),RHREF(25)
      DIMENSION STAGE_REC(25),SURVIV(24),L_W(24),TALOC(25),TCORES(25)
      DIMENSION TIME(25),TREF(25),V(24),V_BABY1(24),VOLD(24),VPUP(24)
      DIMENSION WETFOOD(24),WETGONAD(24),WETMASS(24),WETSTORAGE(24)

      DOUBLE PRECISION VSTI
      INTEGER IDID,IOUT,IPAR,ITOL,IWORK,NDGL,NRDENS,N,LIWORK,LWORK
      PARAMETER (NDGL=10,NRDENS=10)
      PARAMETER (LWORK=8*NDGL+5*NRDENS+21,LIWORK=NRDENS+21)
      DIMENSION ATOL(1),IWORK(LIWORK),RTOL(1),WORK(LWORK),YY(NDGL)
      DIMENSION IPAR(31),RPAR(34),VSTI(10)

      DATA PI/3.14159265/

      COMMON/ARRHEN/T_A,T_AL,T_AH,T_L,T_H,T_REF
      COMMON/BEHAV3/ACTHR
      COMMON/BODYTEMP/BREEDTEMPTHRESH,BREEDTEMPCUM
      COMMON/BREEDER/BREEDING,BREEDVECT
      COMMON/CONT/CONTH,CONTW,CONTVOL,CONTDEP,CONTHOLE,CONTWET,RAINMULT,
     & WETMOD,CONTONLY,CONTYPE,RAINHOUR
      COMMON/COUNTDAY/COUNTDAY,DAYCOUNT
      COMMON/CTMAXMIN/CTMAX,CTMIN,CTMINCUM,CTMINTHRESH,CTKILL
      COMMON/DAYSTORUN/NN
      COMMON/DEATH/CAUSEDEATH,DEATHSTAGE
      COMMON/DEBBABY/V_BABY,E_BABY,EH_BABY
      COMMON/DEBINIT1/V_INIT,E_INIT,CUMREPRO_INIT,CUMBATCH_INIT,
     & VOLD_INIT,VPUP_INIT,EPUP_INIT
      COMMON/DEBINIT2/ES_INIT,Q_INIT,HS_INIT,P_MREF,VDOTREF,H_AREF,
     & E_BABY_INIT,V_BABY_INIT,EH_BABY_INIT,K_JREF,S_G,SURVIV_INIT,
     & HALFSAT,X_FOOD,E_HPUP_INIT,P_XMREF
      COMMON/DEBINPUT/DEBFIRST,ECTOINPUT
      COMMON/DEBMASS/ETAO,JM_JO
      COMMON/DEBMOD/V,ED,WETMASS,WETSTORAGE,WETGONAD,WETFOOD,O2FLUX,
     & CO2FLUX,CUMREPRO,HS,ES,L_W,P_B_PAST,CUMBATCH,Q,V_BABY1,E_BABY1,
     & E_H,STAGE,EH_BABY1,GUTFREEMASS,SURVIV,VOLD,VPUP,EPUP,E_HPUP,
     & RAINDRINK,POTFREEMASS,CENSUS,RESET,DEADEAD,STARTDAY,DEAD
      COMMON/DEBMOD2/REPRO,ORIG_CLUTCHSIZE,NEWCLUTCH,ORIG_ESM,MINCLUTCH
      COMMON/DEBOUTT/FECUNDITY,CLUTCHES,MONREPRO,L_WREPRO,MONMATURE,
     & MINED,ANNFOOD,FOOD,LONGEV,COMPLETION,COMPLETE
      COMMON/DEBPAR1/CLUTCHSIZE,ANDENS_DEB,D_V,EGGDRYFRAC,W_E,MU_E,MU_V,
     & W_V,E_EGG,KAP_X,KAP_X_P,MU_X,MU_P,W_N,W_P,W_X,FUNCT
      COMMON/DEBPAR2/ZFACT,KAPPA,E_G,KAP_R,DELTA_DEB,E_H_START,MAXMASS,
     & E_INIT_BABY,V_INIT_BABY,E_H_INIT,E_HB,E_HP,E_HJ,ESM,LAMBDA,
     & BREEDRAINTHRESH,DAYLENGTHSTART,DAYLENGTHFINISH,LENGTHDAY,
     & LENGTHDAYDIR,PREVDAYLENGTH,LAT,CLUTCHA,CLUTCHB,E_HE,
     & AQUABREED,AQUASTAGE,PHOTODIRS,PHOTODIRF,
     & BREEDACTTHRES,METAMORPH,PHOTOSTART,PHOTOFINISH,BREEDACT,BATCH
      COMMON/DEBPAR3/METAB_MODE,STAGES,Y_EV_L
      COMMON/DEBPAR4/S_J,L_B,L_J
      COMMON/DEBRESP/MLO2,GH2OMET,DEBQMET,MLO2_INIT,GH2OMET_INIT,
     & DEBQMET_INIT,DRYFOOD,FAECES,NWASTE
      COMMON/DEPTHS/DEPSEL,TCORES
      COMMON/DOYMON/DOY
      COMMON/EGGSOIL/EGGSOIL
      COMMON/ENVAR1/QSOL,RH,TSKYC,TIME,TALOC,TREF,RHREF,HRN
      COMMON/FUN1/QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT,QCONV,QCOND
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG
      COMMON/GUT/GUTFULL,GUTFILL,FOODLIM
      COMMON/METDEP/DEPRESS,AESTIVATE,AEST,DEHYDRATED,STARVING
      COMMON/PONDDATA/INWATER,AQUATIC,TWATER,POND_DEPTH,FEEDING
      COMMON/RAINFALL/RAINFALL
      COMMON/REPYEAR/IYEAR,NYEAR
      COMMON/REVAP1/TLUNG,DELTAR,EXTREF,RQ,MR_1,MR_2,MR_3,DEB1
      COMMON/STAGE_R/STAGE_REC,F1COUNT,COUNTER
      COMMON/TPREFR/TMAXPR,TMINPR,TDIGPR,TPREF,TBASK,TEMERGE
      COMMON/TREG/TC
      COMMON/USROPT/TRANST
      COMMON/VIVIP/VIVIPAROUS,PREGNANT
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51,
     & SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52,F61,TQSOL,A1,A2,
     & A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26,WINGCALC,WINGMOD

C	  INITIALISE      
      PREVDEAD=0
      DEAD=0
      WAITING=0
      L_W(HOUR)=0.
      WETGONAD(HOUR)=0.
      WETSTORAGE(HOUR)=0.
      WETFOOD(HOUR)=0.
      WETMASS(HOUR)=0.
      MLO2(HOUR)=0.
      O2FLUX=0.
      CO2FLUX=0.
      V(HOUR)=0.
      E_H(HOUR)=0.
      CUMREPRO(HOUR)=0.
      CUMBATCH(HOUR)=0.
      VPUP(HOUR)=0.
      VOLD(HOUR)=0.
      ED(HOUR)=0.
      HS(HOUR)=0.
      SURVIV(HOUR)=1.
      ES(HOUR)=0.
      SC=0.
      KAP=KAPPA
      STARVE=0.
      IF(HOUR.EQ.1)THEN
       COMPLETE=0
      ENDIF

C     CHECK IF FIRST DAY OF SIMULATION
      IF((DAYCOUNT.EQ.1).AND.(HOUR.EQ.1))THEN
       FIRSTDAY=1
      ELSE
       FIRSTDAY=0
      ENDIF

C	  RESET CLUTCH SIZE AND MAXIMUM STOMACH ENERGY CONTENT (LATTER MAY BE REDUCED IF VIVIPAROUS)
      IF((HOUR.EQ.1).AND.(DAYCOUNT.EQ.1))THEN
       ORIG_CLUTCHSIZE=CLUTCHSIZE
       ORIG_ESM=ESM
      ELSE
       IF(PREGNANT.EQ.0)THEN
        CLUTCHSIZE = ORIG_CLUTCHSIZE
        ESM=ORIG_ESM
       ENDIF
      ENDIF

C	  CHECK IF DEAD OR SIMULATION STILL WAITING FOR START DAY TO OCCUR
      IF((DAYCOUNT.LT.STARTDAY).OR.((COUNTDAY.LT.STARTDAY).AND.
     &  (V_INIT.LE.3E-9)).OR.(DEADEAD.EQ.1))THEN
       DEAD=1
       GOTO 987
      ENDIF

C     CHECK IF START OF A NEW DAY
      IF(HOUR.EQ.1)THEN
       V_PRES = V_INIT
       E_PRES = E_INIT
       ES_PRES = ES_INIT
       MINED = E_PRES
       E_H_PRES = E_H_INIT
       Q_PRES = Q_INIT
       HS_PRES = HS_INIT
       SURVIV_PRES = SURVIV_INIT
      ELSE
       V_PRES = V(HOUR-1)
       E_PRES = ED(HOUR-1)
       ES_PRES = ES(HOUR-1)
       E_H_PRES = E_H(HOUR-1)
       Q_PRES = Q(HOUR-1)
       HS_PRES = HS(HOUR-1)
       SURVIV_PRES = SURVIV(HOUR-1)
      ENDIF

C     LENGTH IN MM
      L_W(HOUR) = V_PRES**(1./3.)/DELTA_DEB*10
      
C     FOR SIZE-DEPENDENT CLUTCH
      IF((CLUTCHA.GT.0).AND.(PREGNANT.EQ.0))THEN ! MAKE SURE CLUTCH SIZE DOESN'T INCREASE DURING PREGNANCY BECAUSE OTHERWISE GET JUMP UP IN MASS OF GONAD
       CLUTCHSIZE=FLOOR(CLUTCHA*(L_W(HOUR)/10)-CLUTCHB)
       NEWCLUTCH=CLUTCHSIZE
      ENDIF
      IF(CLUTCHSIZE.GT.ORIG_CLUTCHSIZE)THEN
       CLUTCHSIZE=ORIG_CLUTCHSIZE
       NEWCLUTCH=CLUTCHSIZE
      ENDIF

      E_H_START = E_H_INIT

C     SET BODY TEMPERATURE
      TB = MIN(CTMAX, TC) ! DON'T LET IT GO TOO HIGH

      IF((AQUABREED.EQ.1).OR.(AQUABREED.EQ.2))THEN
       CONTDEP=POND_DEPTH
       IF((STAGE.LT.STAGES-1).OR.((STAGE.EQ.0).AND.
     &  (AQUABREED.EQ.1)))THEN
        TB=TWATER
       ENDIF
      ENDIF

C     IF RUNNING AN AQUATIC ANIMAL (E.G. FROG), CHECK IF TERRESTRIAL BREEDER AND SET TB TO SOIL TEMP
      IF(E_H_PRES.LE.E_HB)THEN
       IF((AQUABREED.EQ.2).OR.(AQUABREED.EQ.4))THEN
        TB = EGGSOIL(HOUR)
       ENDIF
      ENDIF

C     ARRHENIUS TEMPERATURE CORRECTION FACTOR
C       TCORR = EXP(T_A*(1/(273.15+T_REF)-1/(273.15+TB)))/(1+EXP(T_AL ! EQUATION FROM ORIGINAL SCHOOLFIELD PAPER
C     & *(1/(273.15+TB)-1/T_L))+EXP(T_AH*(1/T_H-1/(273.15+TB))))
       TCORR = EXP(T_A/(273.15+T_REF)-T_A/(273.15+TB))*((1+EXP(T_AL/ ! THIS VERSION ALLOWS K_REF TO VARY FROM WHAT IS SPECIFIED AS A PARAMETER (USED IN DEBTOOL)
     &(273.15+T_REF)-T_AL/T_L)+EXP(T_AH/T_H-T_AH/(273.15+T_REF)))/(1+EXP
     &(T_AL/(273.15+TB)-T_AL/T_L)+EXP(T_AH/T_H-T_AH/(273.15+TB))))

C     METABOLIC ACCELERATION IF PRESENT
      S_M = 1.
      IF(E_HJ.NE.E_HB)THEN
       IF(E_H_PRES.LT.E_HB)THEN
        S_M = 1. ! -, MULTIPLICATION FACTOR FOR V AND {P_AM}
       ELSE
        IF(E_H_PRES.LT.E_HJ)THEN
         S_M = V_PRES ** (1. / 3.) / L_B
        ELSE
         S_M = L_J / L_B
        ENDIF
       ENDIF
      ENDIF
       
      IF(CLUTCHSIZE.LT.1)THEN
       CLUTCHSIZE=1
       NEWCLUTCH=CLUTCHSIZE
      ENDIF
      CLUTCHENERGY = E_EGG*CLUTCHSIZE

      X_FOOD = FOODLEVELS(DAYCOUNT)

      IF(PREGNANT.EQ.1)THEN
        F=FUNCT
       LAMBDA=LAMBDA-1./(24.*365.)
       IF(LAMBDA.LT.0)THEN
        LAMBDA=0.1
       ENDIF
      ELSE
       F=FUNCT
      ENDIF
      ! OPTION FOR SPECIFIC LIFE STAGES TO NOT BE FOOD LIMITED
      IF(INT(FOODLIM).EQ.0)THEN
       FUNCT=1.
       X_FOOD = HALFSAT*10000.
      ENDIF
C     IF(VIVIPAROUS.EQ.1)THEN
C      IF((CUMBATCH(HOUR)/CLUTCHENERGY).GT.1)THEN
C       ESM=ESM*0.5
C      ELSE
C       ESM=ESM*(1-(CUMBATCH(HOUR)/CLUTCHENERGY)*.5)
C      ENDIF
C      IF(ESM.LT.0)THEN
C       ESM=0
C      ENDIF
C     ENDIF
      IF((AESTIVATE.EQ.1).AND.(AQUATIC.EQ.1).AND.(POND_DEPTH.EQ.0).OR.
     & (DEHYDRATED.EQ.1))THEN
       AEST=1
      ELSE
       AEST=0
      ENDIF
      
C     TEMPERATURE CORRECTIONS AND COMPOUND PARAMETERS
      M_V = ANDENS_DEB/W_V
      P_MV = P_MREF*TCORR
      K_M = P_MV/E_G
      K_J = K_JREF*TCORR
      VDOT = VDOTREF*TCORR*S_M
      P_AM = P_MREF*TCORR*ZFACT/KAP*S_M
      P_XM = P_XMREF*TCORR*S_M
      H_A = H_AREF*TCORR
      IF(AEST.EQ.1)THEN
       P_MV = P_MV*DEPRESS
       K_M = P_MV/E_G
       K_J = K_J*DEPRESS
       VDOT=VDOT*DEPRESS
       P_AM = P_MREF*TCORR*ZFACT/KAP*DEPRESS
       P_XM = P_XMREF*TCORR*DEPRESS
       H_A = H_AREF*TCORR*DEPRESS
      ENDIF

C	  HARDWIRING IN FOR LOCUSTS AT THE MOMENT      
      IF((STAGE.EQ.3).AND.(LENGTHDAY.LE.11).AND.(METAB_MODE.EQ.1))THEN
       P_MV = P_MV*DEPRESS
       K_M = P_MV/E_G
       K_J = K_J*DEPRESS
       VDOT=VDOT*DEPRESS
       P_AM = P_MREF*TCORR*ZFACT/KAP*DEPRESS
       P_XM = P_XMREF*TCORR*DEPRESS
       H_A = H_AREF*TCORR*DEPRESS
      ENDIF 

      E_M = P_AM/VDOT
      G = E_G/(KAP*E_M)
      E_SCALED=E_PRES/E_M
      V_M=(KAP*P_AM/P_MV)**(3.)
      L_T = 0.
      L_PRES = V_PRES**(1./3.)
      L_M = V_M**(1./3.)
      SCALED_L = L_PRES/L_M
      KAPPA_G = (D_V*MU_V)/(W_V*E_G)
      YEX=KAP_X*MU_X/MU_E
      YXE=1/YEX
      YPX=KAP_X_P*MU_X/MU_P
      MU_AX=MU_E/YXE
      ETA_PA=YPX/MU_AX

C     CALL SUBROUTINE THAT ASSESSES PHOTOPERIOD CUES ON BREEDING
      CALL BREED(DOY,PHOTOSTART,PHOTOFINISH,LENGTHDAY,
     &DAYLENGTHSTART,DAYLENGTHFINISH,PHOTODIRS,PHOTODIRF,PREVDAYLENGTH,
     &LAT,FIRSTDAY,BREEDACT,BREEDACTTHRES,HOUR,
     &BREEDTEMPTHRESH,BREEDTEMPCUM,DAYCOUNT,DEAD,PREVDEAD,ACTHR(HOUR))

      BREEDVECT(HOUR)=BREEDING

C     CALL SUBROUTINE (FOR FROGS AT THIS STAGE) THAT ASSESSES IF USER WANTS CUMULATIVE RESETS OF DEVELOPMENT AFTER METAMORPHOSIS
      CALL DEVRESET(DEAD,E_H_PRES,E_HB,AQUABREED,BREEDING,CONTH,CONTDEP,
     &STAGE,AQUASTAGE,RESET,COMPLETE,WAITING,HOUR,STAGES,COMPLETION)

C     DIAPAUSE BEFORE POND FILL
      IF(AQUABREED.EQ.1)THEN
       IF((E_H_PRES.GT.E_HB).AND.(STAGE.LT.1))THEN
        IF(CONTDEP.LE.0.1)THEN
         WAITING=1
        ENDIF
       ENDIF
      ENDIF
C     NOW CHECKING TO SEE IF STARTING WITH EMBRYO, AND IF SO SETTING THE APPROPRIATE RESERVE DENSITY
      IF(HOUR.EQ.1)THEN
       IF(DAYCOUNT.EQ.1)THEN
        IF(E_H_PRES.LE.E_HB)THEN
C        E_PRES=E_EGG/V_PRES
         E_PRES=E_INIT
        ENDIF
       ENDIF
C      CHECKING TO SEE IF ANIMAL DIED RECENTLY AND NEEDS TO START AGAIN AS AN EMBRYO
       IF((DAYCOUNT.GT.1).AND.(DEAD.EQ.1))THEN
        IF(E_H_PRES.LE.E_HB)THEN
         E_PRES=E_EGG/DEBFIRST(3)
        ENDIF
       ENDIF
      ENDIF

C	  SETTING UP CALL TO DOPRI INTEGRATOR

C --- DIMENSION OF THE SYSTEM
      N=NDGL
C --- OUTPUT ROUTINE (AND DENSE OUTPUT) IS USED DURING INTEGRATION
      IOUT=0
C --- INITIAL VALUES AND ENDPOINT OF INTEGRATION
      RPAR(1)=DBLE(K_J)
      RPAR(2)=DBLE(P_AM)
      RPAR(3)=DBLE(K_M)
      RPAR(4)=DBLE(P_XM)
      RPAR(5)=DBLE(VDOT)
      RPAR(6)=DBLE(E_M)
      RPAR(7)=DBLE(L_M)
      RPAR(8)=DBLE(L_T)
      RPAR(9)=DBLE(KAP)
      RPAR(10)=DBLE(G)
      RPAR(11)=DBLE(M_V)
      RPAR(12)=DBLE(MU_E)
      RPAR(13)=DBLE(MU_V)
      RPAR(14)=DBLE(D_V)
      RPAR(15)=DBLE(W_V)
      RPAR(16)=DBLE(ACTHR(HOUR))
      RPAR(17)=DBLE(X_FOOD)
      RPAR(18)=DBLE(HALFSAT)
      RPAR(19)=DBLE(E_HP)
      RPAR(20)=DBLE(E_HB)
      RPAR(21)=DBLE(S_G)
      RPAR(22)=DBLE(H_A)
      RPAR(23)=DBLE(PREGNANT)
      RPAR(24)=DBLE(BATCH)
      RPAR(25)=DBLE(KAP_R)
      RPAR(26)=DBLE(LAMBDA)
      RPAR(27)=DBLE(BREEDING)
      RPAR(28)=DBLE(KAP_X)
      RPAR(29)=DBLE(WAITING)
      RPAR(30)=DBLE(F)
      RPAR(31)=DBLE(ESM)
      RPAR(32)=DBLE(METAB_MODE)
      RPAR(33)=DBLE(E_HJ)
      RPAR(34)=DBLE(P_MV)
      X=0.0D0
      YY(1)=0.0D0
      YY(2)=MAX(DBLE(V_PRES),0.)
      YY(3)=MAX(DBLE(E_PRES),0.)
      YY(4)=MAX(DBLE(E_H_PRES),0.)
      YY(5)=MAX(DBLE(ES_PRES),0.)
      YY(6)=MAX(DBLE(STARVE),0.)
      YY(7)=MAX(DBLE(Q_PRES),0.)
      YY(8)=MAX(DBLE(HS_PRES),0.)
      YY(9)=MAX(DBLE(CUMREPRO_INIT),0.)
      YY(10)=MAX(DBLE(CUMBATCH_INIT),0.)
      XEND=1.D+00
C --- REQUIRED (RELATIVE AND ABSOLUTE) TOLERANCE
      ITOL=0
      RTOL(1)=1.0D-3
      ATOL(1)=RTOL(1)
C --- DEFAULT VALUES FOR PARAMETERS
      DO 13 I=1,20
       IWORK(I)=0
       WORK(I)=0.D0
  13  CONTINUE
      !LWORK=8*NDGL+5*NRDENS+21,LIWORK=NRDENS+21
C --- DENSE OUTPUT IS USED FOR THE TWO POSITION COORDINATES 1 AND 2
      IWORK(5)=NRDENS
      IWORK(21)=1
      IWORK(22)=2
      IWORK(23)=3
      IWORK(24)=4
      IWORK(25)=5
C --- CALL OF THE SUBROUTINE DOPRI5
      CALL DOPRI5(N,DGET_DEB,X,YY,XEND,RTOL,ATOL,ITOL,SOLOUT,IOUT,
     & WORK,LWORK,IWORK,LIWORK,RPAR,IPAR,IDID,VSTI)
      V(HOUR)=MAX(YY(2),0.)
      ED(HOUR)=MAX(YY(3),0.)
      E_H(HOUR)=MAX(YY(4),0.)
      ES(HOUR)=MAX(YY(5),0.)
      IF(ES(HOUR).GT.(ESM*V(HOUR)))THEN
       ES(HOUR) = ESM*V(HOUR)
      ENDIF
      ES_INIT=ES(HOUR)
      ES_PAST=ES(HOUR)
      STARVE=MAX(YY(6),0.)
      Q(HOUR)=MAX(YY(7),0.)
      HS(HOUR)=MAX(YY(8),0.)
      CUMREPRO(HOUR)=MAX(YY(9),0.)
      CUMBATCH(HOUR)=MAX(YY(10),0.)
      CUMREPRO_INIT = CUMREPRO(HOUR)
      CUMBATCH_INIT = CUMBATCH(HOUR)
      E_SCALED=ED(HOUR)/E_M ! REDEFINE E_SCALED TO NEW ED(HOUR)
      IF(STARVE.GT.0)THEN
       STARVING = 1
      ELSE
       STARVING = 0
      ENDIF
      GUTFULL=ES(HOUR)/(ESM*V(HOUR))
      IF(GUTFULL.GT.1)THEN
       GUTFULL=1
      ENDIF      
      IF((E_H(HOUR).GT.E_HJ).AND.(E_H_PRES.LE.E_HJ))THEN
       L_J = V(HOUR)**(1./3.) ! METAMORPHOSIS HAS OCCURRED (ABJ MODEL)
      ENDIF
      IF((E_H(HOUR).GT.E_HB).AND.(E_H_PRES.LE.E_HB))THEN
       L_B = V(HOUR)**(1./3.) ! BIRTH LENGTH (NEEDED FOR ABJ MODEL)
      ENDIF
      
C     POWERS
      P_M = P_MV*V(HOUR)
      P_J = K_J*E_H(HOUR)
      IF(ES(HOUR).GT.0)THEN
       P_A = V(HOUR)**(2./3.)*P_AM*F
      ELSE
       P_A = 0
      ENDIF
C     EQUATION 2.20 DEB3
      P_C = (E_M*(VDOT/V(HOUR)**(1./3.)+K_M*(1+L_T/V(HOUR)**(1./3.)))*
     & (E_SCALED*G)/(E_SCALED+G))*V(HOUR)
      IF(METAB_MODE.EQ.1)THEN
       IF((P_A.GT.P_C).AND.(ED(HOUR).EQ.E_M))THEN
        P_A=P_C
       ENDIF
      ENDIF     
      IF(METAB_MODE.EQ.0)THEN
       P_R = (1.-KAP)*P_C-P_J
      ENDIF
      IF(METAB_MODE.EQ.1)THEN
       IF(E_H(HOUR).GT.E_HJ)THEN
        P_R = P_C-P_M*V(HOUR)-P_J ! NO KAPPA-RULE UNDER ABP MODEL - REPRODUCTION GETS WHAT IS LEFT FROM THE MOBILISATION FLUX AFTER MAINTENANCE IS PAID
        DVDT=0.
       ELSE
        P_R = (1.-KAP)*P_C-P_J
       ENDIF
      ENDIF     

      IF(E_H(HOUR).GE.E_HP)THEN
       P_D = P_M+P_J+(1-KAP_R)*P_R
      ELSE
       P_D = P_M+P_J+P_R
      ENDIF
      P_G = P_C-P_M-P_J-P_R
C     J FOOD EATEN PER HOUR
      P_X = P_A/KAP_X
C     TALLYING J FOOD EATEN PER YEAR
      FOOD(IYEAR)=FOOD(IYEAR)+P_X
C     TALLYING LIFETIME FOOD EATEN
      IF(IYEAR.EQ.NYEAR)THEN
       IF(HOUR.EQ.24)THEN
        DO 1 I=1,NYEAR
         ANNFOOD=ANNFOOD+FOOD(I)
1       CONTINUE
       ENDIF
      ENDIF
C    IF(AQUABREED.EQ.2)THEN
C     IF((E_H_PRES.GE.E_HB).AND.(STAGE.LT.1))THEN
C      IF(CONTDEP.LE.0.1)THEN
C       DE_HDT=0
C      ENDIF
C     ENDIF
C    ENDIF

C      H_W = ((H_A*(E_PRES/E_M)*VDOT)/(6*V_PRES**(1./3.)))**(1./3.)
      DSURVDT = -1*SURVIV_PRES*HS(HOUR)
      SURVIV(HOUR) = SURVIV_PRES+DSURVDT

      IF(COUNTDAY.EQ.365)THEN
       IF(HOUR.EQ.24)THEN
        SURV(IYEAR)=SURVIV(HOUR)
       ENDIF
      ENDIF

      IF(TB.LT.CTMIN)THEN
       CTMINCUM=CTMINCUM+1
      ELSE
       CTMINCUM=0
      ENDIF

C	  CHECK IF DIED, AND RECORD WHY

C     AVERAGE LONGEVITY IN YEARS
      IF(LONGEV.EQ.0)THEN
       IF(CTKILL.EQ.1)THEN
        IF((CTMINCUM.GT.CTMINTHRESH).OR.(TB.GT.CTMAX+2))THEN
         IF(RESET.GT.0)THEN
          DEAD=1
          IF(CTMINCUM.GT.CTMINTHRESH)THEN
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=1. ! COLD STRESS
            DEATHSTAGE=STAGE
            CTMINCUM=0
           ENDIF
          ELSE
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=2. ! HEAT STRESS
            DEATHSTAGE=STAGE
           ENDIF
          ENDIF
         ELSE
          CENSUS=COUNTDAY
          DEADEAD=1
          SURV(IYEAR)=SURVIV(HOUR)
          SURVIV(HOUR)=0.49
          IF(CTMINCUM.GT.CTMINTHRESH)THEN
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=1. ! COLD STRESS
            DEATHSTAGE=STAGE
            CTMINCUM=0
           ENDIF
          ELSE
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=2. ! HEAT STRESS
            DEATHSTAGE=STAGE
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       IF(SURVIV(HOUR).LT.0.5)THEN
        LONGEV=(DAYCOUNT+HOUR/24.)/365.
        NYEAR=IYEAR
        DEAD=1
        IF(RESET.EQ.0)THEN
         SURV(IYEAR)=SURVIV(HOUR)
         DEADEAD=1
         SURVIV(HOUR)=0.49
        ENDIF
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=5. ! OLD AGE
            DEATHSTAGE=STAGE
           ENDIF
       ENDIF
      ENDIF

      IF((ED(HOUR).LT.(P_MREF*ZFACT/KAP/VDOTREF)*0.1).AND.
     &(DEAD.EQ.0))THEN 
       DEAD=1
       LONGEV=(DAYCOUNT+HOUR/24.)/365.
       NYEAR=IYEAR
       IF(STAGE.GT.DEATHSTAGE)THEN
        CAUSEDEATH=4. ! STARVING
        DEATHSTAGE=STAGE
       ENDIF
       IF(RESET.EQ.0)THEN
        SURVIV(HOUR)=0.49
        DEADEAD=1
        CENSUS=COUNTDAY
       ENDIF
      ENDIF

C     FIND MIN VALUE OF ED FOR THE SIMULATION
      IF(ED(HOUR).LT.MINED)THEN
       MINED=ED(HOUR)
      ENDIF

C     LENGTH IN MM
      L_W(HOUR) = V(HOUR)**(1./3.)/DELTA_DEB*10

      TESTCLUTCH=FLOOR((CUMREPRO(HOUR)+CUMBATCH(HOUR))/E_EGG)
C     FOR VARIABLE CLUTCH SIZE FROM REPRO AND BATCH BUFFERS
      IF((MINCLUTCH.GT.0).AND.(FLOOR((CUMREPRO(HOUR)+CUMBATCH(HOUR))
     &   /E_EGG).GT.MINCLUTCH))THEN
       IF(TESTCLUTCH.LE.ORIG_CLUTCHSIZE)THEN ! MAKE SMALLEST CLUTCH ALLOWABLE FOR THIS REPRO EVENT
        CLUTCHSIZE=MINCLUTCH
        CLUTCHENERGY=CLUTCHSIZE*E_EGG
       ENDIF
      ENDIF
      
C	  DETERMINE LIFE STAGE
      
C     STD MODEL
      IF((METAB_MODE.EQ.0).AND.(E_HB.EQ.E_HJ))THEN   
       IF(E_H(HOUR).LE.E_HB)THEN
        STAGE=0
       ELSE   
        IF(E_H(HOUR).LT.E_HP)THEN
         STAGE=1
        ELSE
         STAGE=2
        ENDIF
       ENDIF
       IF(CUMBATCH(HOUR).GT.0)THEN
        IF(E_H(HOUR).GE.E_HP)THEN
         STAGE=3
        ELSE
         STAGE=STAGE
        ENDIF
       ENDIF
      ENDIF
      
C     ABJ MODEL
      IF((METAB_MODE.EQ.0).AND.(E_HB.NE.E_HJ))THEN  
       IF(E_H(HOUR).LE.E_HB)THEN
        STAGE=0
       ELSE
        IF(E_H(HOUR).LT.E_HJ)THEN
         STAGE=1
        ENDIF
        IF(E_H(HOUR).GE.E_HJ)THEN
          STAGE=2
        ENDIF
        IF(E_H(HOUR).GE.E_HP)THEN        
          STAGE=3
        ENDIF
       ENDIF
       IF(CUMBATCH(HOUR).GT.0)THEN
        IF(E_H(HOUR).GE.E_HP)THEN
         STAGE=4
        ELSE
         STAGE=STAGE
        ENDIF
       ENDIF
      ENDIF

      ! ABP MODEL
      IF(METAB_MODE.EQ.1)THEN
       IF((STAGE.GT.0).AND.(STAGE.LT.STAGES-1))THEN
C       LARVA, USE CRITICAL LENGTH THRESHOLDS
        L_THRESH=L_INSTAR(INT(STAGE))
       ENDIF
       IF(STAGE.EQ.0)THEN
        IF(E_H(HOUR).GE.E_HB)THEN
         STAGE=STAGE+1
        ENDIF
       ELSE
        IF(STAGE.LT.STAGES-1)THEN
         IF(V(HOUR)**(1./3.).GT.L_THRESH)THEN
          STAGE=STAGE+1
         ENDIF
        ENDIF
        IF(E_H(HOUR).GE.E_HP)THEN
         STAGE=STAGES-1
        ENDIF
       ENDIF
      ENDIF      

C	  REPRODUCTION

      IF(CUMBATCH(HOUR).GT.0)THEN
       IF(MONMATURE.EQ.0)THEN
        MONMATURE=(COUNTDAY+365*(IYEAR-1))/30.5
       ENDIF
      ENDIF
      
      IF((CUMBATCH(HOUR).GT.CLUTCHENERGY).OR.(PREGNANT.EQ.1))THEN
C      BATCH IS READY SO IF VIVIPAROUS, START GESTATION, ELSE DUMP IT
       IF(VIVIPAROUS.EQ.1)THEN
        IF((PREGNANT.EQ.0).AND.(BREEDING.EQ.1))THEN
         V_BABY=V_INIT_BABY
         E_BABY=E_INIT_BABY
         EH_BABY=0.
         PREGNANT=1
        ENDIF
        IF(HOUR.EQ.1)THEN
         V_BABY=V_BABY_INIT
         E_BABY=E_BABY_INIT
         EH_BABY=EH_BABY_INIT
        ENDIF
        IF(PREGNANT.EQ.1)THEN
        CALL DEB_BABY
        ENDIF
        IF(EH_BABY.GT.E_HB)THEN
         IF((TB .LT. TMINPR) .OR. (TB .GT. TMAXPR))THEN
          GOTO 898
         ENDIF
         CUMBATCH(HOUR) = 0
         CUMBATCH_INIT = CUMBATCH(HOUR)
         REPRO(HOUR)=1
         PREGNANT=0
         V_BABY=V_INIT_BABY
         E_BABY=E_INIT_BABY
         EH_BABY=0
         NEWCLUTCH=CLUTCHSIZE
         FEC(IYEAR)=FEC(IYEAR)+CLUTCHSIZE
         FECUNDITY=FECUNDITY+CLUTCHSIZE
         CLUTCHES=CLUTCHES+1
         IF(FECUNDITY.GE.CLUTCHSIZE)THEN
          MONREPRO=(COUNTDAY+365*(IYEAR-1))/30.5
          L_WREPRO=L_W(HOUR)
         ENDIF
         PREGNANT=0
         CLUTCHSIZE = ORIG_CLUTCHSIZE
        ENDIF
       ELSE
C      NOT VIVIPAROUS, SO LAY THE EGGS AT NEXT PERIOD OF ACTIVITY
        IF(BREEDRAINTHRESH.GT.0)THEN
         IF(RAINFALL.LT.BREEDRAINTHRESH)THEN
          GOTO 898
         ENDIF
        ENDIF
        IF((AQUABREED.EQ.1).AND.(POND_DEPTH.EQ.1))THEN
          GOTO 898
         ENDIF
        IF((TB .LT. TMINPR) .OR. (TB .GT. TMAXPR))THEN
         GOTO 898
        ENDIF
C       CHANGE BELOW TO ACTIVE OR NOT ACTIVE RATHER THAN DEPTH-BASED, IN CASE OF FOSSORIAL
        IF((TB .LT. TMINPR) .OR. (TB .GT. TMAXPR))THEN
         GOTO 898
        ENDIF
        TESTCLUTCH=REAL(FLOOR(CUMBATCH(HOUR)/E_EGG),8)
        IF(TESTCLUTCH.GT.CLUTCHSIZE)THEN
         CLUTCHSIZE=TESTCLUTCH
         NEWCLUTCH=CLUTCHSIZE
         CLUTCHENERGY=CLUTCHSIZE*E_EGG
        ENDIF
        CUMBATCH(HOUR) = CUMBATCH(HOUR)-CLUTCHENERGY
        CUMBATCH_INIT = CUMBATCH(HOUR)
        REPRO(HOUR)=1
        FEC(IYEAR)=FEC(IYEAR)+CLUTCHSIZE
        FECUNDITY=FECUNDITY+CLUTCHSIZE
        CLUTCHES=CLUTCHES+1
        IF(FECUNDITY.GE.CLUTCHSIZE)THEN
         MONREPRO=(COUNTDAY+365*(IYEAR-1))/30.5
         L_WREPRO=L_W(HOUR)
        ENDIF
         CLUTCHSIZE = ORIG_CLUTCHSIZE
       ENDIF
      ENDIF

898   CONTINUE

      IF((RESET.GT.0).AND.(RESET.NE.8))THEN
       FEC(IYEAR)=COMPLETION
      ENDIF

C     MASS BALANCE
 
      ! MOLAR FLUXES OF FOOD, STRUCTURE, RESERVE AND FAECES (MOL/HOUR)
      JOJX=P_A*ETAO(1,1)+P_D*ETAO(1,2)+P_G*ETAO(1,3) 
      JOJV=P_A*ETAO(2,1)+P_D*ETAO(2,2)+P_G*ETAO(2,3)
      JOJE=P_A*ETAO(3,1)+P_D*ETAO(3,2)+P_G*ETAO(3,3)
      JOJP=P_A*ETAO(4,1)+P_D*ETAO(4,2)+P_G*ETAO(4,3)

      ! NON-ASSIMILATION (I.E. GROWTH AND MAINTENANCE) MOLAR FLUXES AS ABOVE
      JOJX_GM=P_D*ETAO(1,2)+P_G*ETAO(1,3)
      JOJV_GM=P_D*ETAO(2,2)+P_G*ETAO(2,3)
      JOJE_GM=P_D*ETAO(3,2)+P_G*ETAO(3,3)
      JOJP_GM=P_D*ETAO(4,2)+P_G*ETAO(4,3)

      ! MOLAR FLUXES OF 'MINERALS', CO2, H2O, O2 AND NITROGENOUS WASTE (MOL/H)
      JMCO2=JOJX*JM_JO(1,1)+JOJV*JM_JO(1,2)+JOJE*JM_JO(1
     &    ,3)+JOJP*JM_JO(1,4)
      JMH2O=JOJX*JM_JO(2,1)+JOJV*JM_JO(2,2)+JOJE*JM_JO(
     &    2,3)+JOJP*JM_JO(2,4)
      JMO2=JOJX*JM_JO(3,1)+JOJV*JM_JO(3,2)+JOJE*JM_JO
     &    (3,3)+JOJP*JM_JO(3,4)
      JMNWASTE=JOJX*JM_JO(4,1)+JOJV*JM_JO(4,2)+JOJE*
     &    JM_JO(4,3)+JOJP*JM_JO(4,4)

      RQ = JMCO2/JMO2 ! RESPIRATORY QUOTIENT

      ! NON-ASSLIMILATION MOLAR FLUXES OF 'MINERALS', CO2, H2O, O2 AND NITROGENOUS WASTE (MOL/H)
      JMCO2_GM=JOJX_GM*JM_JO(1,1)+JOJV_GM*JM_JO(1,2)
     & +JOJE_GM*JM_JO(1,3)+JOJP_GM*JM_JO(1,4)
      JMH2O_GM=JOJX_GM*JM_JO(2,1)+JOJV_GM*JM_JO(2,2)
     & +JOJE_GM*JM_JO(2,3)+JOJP_GM*JM_JO(2,4)
      JMO2_GM=JOJX_GM*JM_JO(3,1)+JOJV_GM*JM_JO(3,2)
     & +JOJE_GM*JM_JO(3,3)+JOJP_GM*JM_JO(3,4)
      JMNWASTE_GM=JOJX_GM*JM_JO(4,1)+JOJV_GM*JM_JO(4,2)
     & +JOJE_GM*JM_JO(4,3)+JOJP_GM*JM_JO(4,4)

C     RESPIRATION IN ML/H, TEMPERATURE CORRECTED (INCLUDING SDA)

C     PV=nRT
C     T=273.15 #K
C     R=0.082058 #L*atm/mol*K
C     n=1 #mole
C     P=1 #atm
C     V=nRT/P=1*0.082058*273.15=22.41414
C     T=293.15
C     V=nRT/P=1*0.082058*293.15/1=24.0553
C     P_atm <- 1
C     R_const <- 0.082058
C     gas_cor <- R_const * T_REF / P_atm * (Tb + 273.15) / T_REF * 1000 # 1 mole to ml/h at Tb and atmospheric pressure

      IF(DEB1.EQ.1)THEN
       O2FLUX = -1*JMO2*(0.082058*(T_REF+273.15)*(TB+273.15)/
     &  (T_REF+273.15))*1000
      ELSE
C      SEND THE ALLOMETRIC VALUE TO THE OUTPUT FILE
       O2FLUX = 10.**(MR_3*TC)*MR_1*(AMASS*1000)**MR_2 ! REGRESSION-BASED
      ENDIF

      CO2FLUX = JMCO2*(0.082058*(T_REF+273.15)*(TB+273.15)/
     &  (T_REF+273.15))*1000

C     G METABOLIC WATER/H
      GH2OMET(HOUR) = JMH2O*18.01528
      
C     METABOLIC HEAT PRODUCTION (WATTS) - GROWTH OVERHEAD PLUS DISSIPATION POWER (MAINTENANCE, MATURITY MAINTENANCE,
C     MATURATION/REPRO OVERHEADS) PLUS ASSIMILATION OVERHEADS - CORRECT TO 20 DEGREES SO IT CAN BE TEMPERATURE CORRECTED
C     IN MET.F FOR THE NEW GUESSED TB
      DEBQMET(HOUR) = ((1-KAPPA_G)*P_G+P_D+(P_X-P_A-P_A*MU_P*ETA_PA))
     &    /3600/TCORR

      DRYFOOD(HOUR)=-1*JOJX*W_X ! DRY FOOD INTAKE (G)
      FAECES(HOUR)=JOJP*W_P ! FAECES PRODUCTION (G)
      NWASTE(HOUR)=JMNWASTE*W_N ! NITROGENOUS WASTE PRODUCTION (G)
C	  REPRODUCTIVE WET BIOMASS (G)        
      IF(PREGNANT.EQ.1)THEN ! REPRODUCTIVE WET BIOMASS (G)
       WETGONAD(HOUR) = ((CUMREPRO(HOUR)/MU_E)*W_E)/EGGDRYFRAC
     & +((((V_BABY*E_BABY)/MU_E)*W_E)/D_V + V_BABY)*CLUTCHSIZE
      ELSE
       WETGONAD(HOUR) = ((CUMREPRO(HOUR)/MU_E)*W_E)/EGGDRYFRAC
     & +((CUMBATCH(HOUR)/MU_E)*W_E)/EGGDRYFRAC
      ENDIF
      WETSTORAGE(HOUR) = (((V(HOUR)*ED(HOUR))/MU_E)*W_E)/D_V ! RESERVE WET MASS (G)
      WETFOOD(HOUR) = ((ES(HOUR)/MU_E)*W_E)/(1-FOODWATERS(DAYCOUNT)) ! WET FOOD MASS (G)
      WETMASS(HOUR) = V(HOUR)*ANDENS_DEB+WETGONAD(HOUR)+ ! TOTAL WET MASS (G)
     &WETSTORAGE(HOUR)+WETFOOD(HOUR)
      GUTFREEMASS=V(HOUR)*ANDENS_DEB+WETGONAD(HOUR)+
     &WETSTORAGE(HOUR)
      POTFREEMASS=V(HOUR)*ANDENS_DEB+(((V(HOUR)*E_M)/MU_E)*W_E)/D_V ! NON REPRODUCTIVE AND NON FOOD WET MASS
     
C	  STATE OF BABY IF VIVIPAROUS AND PREGNANT     
      V_BABY1(HOUR)=V_BABY
      E_BABY1(HOUR)=E_BABY
      EH_BABY1(HOUR)=EH_BABY

      IF(CONTH.EQ.0)THEN
       IF((VIVIPAROUS.EQ.1).AND.(E_H(HOUR).LE.E_HB))THEN
C       MAKE THE MASS, METABOLIC HEAT AND O2 FLUX THAT OF A FULLY GROWN INDIVIDUAL TO GET THE HEAT BALANCE OF
C       A THERMOREGULATING MOTHER WITH FULL RESERVES
        AMASS=MAXMASS/1000
        P_M = P_MV*V_M
        P_C = (E_M*(VDOT/L_M+K_M*(1+L_T/L_M))*
     &    (1*G)/(1+G))*V_M
        P_J = K_J*E_HP
        P_R = (1.-KAP)*P_C-P_J
        P_D = P_M+P_J+(1-KAP_R)*P_R
        P_A = V_M**(2./3.)*P_AM*F
        P_X = P_A/KAP_X
        JOJX=P_A*ETAO(1,1)+P_D*ETAO(1,2)+P_G*ETAO(1,3)
        JOJV=P_A*ETAO(2,1)+P_D*ETAO(2,2)+P_G*ETAO(2,3)
        JOJE=P_A*ETAO(3,1)+P_D*ETAO(3,2)+P_G*ETAO(3,3)
        JOJP=P_A*ETAO(4,1)+P_D*ETAO(4,2)+P_G*ETAO(4,3)
        JMO2=JOJX*JM_JO(3,1)+JOJV*JM_JO(3,2)+JOJE*JM_JO(3,3)+
     &        JOJP*JM_JO(3,4)
C       MLO2(HOUR)=-1*JMO2/(T_REF/TB/24.4)*1000
        MLO2(HOUR)=(-1*JMO2*(0.082058*(TB+273.15))/
     &    (0.082058*293.15))*24.06*1000
        DEBQMET(HOUR)=(P_D+(P_X-P_A-P_A*MU_P*ETA_PA))/3600/TCORR
       ELSE
        AMASS=WETMASS(HOUR)/1000.
       ENDIF
      ENDIF

987   CONTINUE

C	  RESET IF DEAD
      IF(DEAD.EQ.1)THEN
       ES_PAST=0
       L_W(HOUR)=0
       WETGONAD(HOUR)=0
       WETSTORAGE(HOUR)=0
       WETFOOD(HOUR)=0
       WETMASS(HOUR)=0
       E_H(HOUR)=0
       ED(HOUR)=0
       V(HOUR)=0
       AMASS=((((V_INIT*E_INIT)/MU_E)*W_E)/D_V + V_INIT)/1000
       BREEDVECT(HOUR)=0
      ENDIF

      IF(HOUR.EQ.24)THEN
       IF(COMPLETE.EQ.1)THEN
        COMPLETION=COMPLETION+1
        COMPLETE=0
       ENDIF
      ENDIF

      IF((DEAD.EQ.0).AND.(DVDT.GT.0))THEN
       DEAD=0
      ENDIF

      STAGE_REC(HOUR)=STAGE

      RETURN
      END