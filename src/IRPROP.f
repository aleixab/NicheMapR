C     NICHEMAPR: SOFTWARE FOR BIOPHYSICAL MECHANISTIC NICHE MODELLING

C     COPYRIGHT (C) 2020 MICHAEL R. KEARNEY AND WARREN P. PORTER

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

C     THIS SUBROUTINE COMPUTES PARAMETERS NEEDED FOR COMPUTING CONDUCTION 
C     & INFRARED RADIATION THROUGH THE FUR.

      SUBROUTINE IRPROP(TA,SHAPE_B_MAX,SHAPE_B_REF,SHAPE_B,DHAIRD,DHAIRV
     & ,LHAIRD,LHAIRV,ZFURD,ZFURV,RHOD,RHOV,REFLD,REFLV,MAXPTVEN,
     & ZFURCOMP,KHAIR,RESULTS)

      IMPLICIT NONE

      DOUBLE PRECISION B1ARA,BETARA,DHAIR,DHAIRD,DHAIRV,DHAR,FURTST
      DOUBLE PRECISION GETKFURout,KAIR,KEFARA,KFURCMPRS,KHAIR,LHAIR
      DOUBLE PRECISION LHAIRD,LHAIRV,LHAR,MAXPTVEN,PI,PTVEN,PTVENV
      DOUBLE PRECISION REFL,REFLD,REFLFR,REFLV,RESULTS,RHO,RHOAR
      DOUBLE PRECISION RHOD,RHOV,SHAPE_B,SHAPE_B_MAX,SHAPE_B_REF,TA
      DOUBLE PRECISION ZFUR,ZFURCOMP,ZFURD,ZFURV,ZZFUR

      INTEGER L
      
      DIMENSION KEFARA(3),BETARA(3),B1ARA(3)
      DIMENSION RESULTS(26)
      DIMENSION GETKFURout(3)

C     SPECIFIC PARTS OF THE BODY FOR PROPERTIES:
C     INDEX = AVERAGE, DORSAL/FRONT, VENTRAL/BACK VALUES
C     DHAR = HAIR DIAMETER, LHAR = HAIR/FEATHER LENGTH, RHOAR = HAIR DENSITY, ZFUR = FUR/PLUMAGE DEPTH
C     REFLFR = FUR/FEATHER REFLECTIVITES
      DIMENSION DHAR(3),LHAR(3),RHOAR(3),ZZFUR(3)
      DIMENSION REFLFR(3)

C     ***  STILL TO BE DONE:***
C     SITE SPECIFIC (DSL, VNT) PROPERTIES KEFF,BETA,B1 &
C     APPROPRIATE CHANGES IN FUN

      PI = 3.14159
      
C     CONDUCTIVITY OF HAIR FIBERS
C      KHAIR=0.209 ! MAKE THIS USER-DEFINABLE

C     CONDUCTIVITY OF AIR (FROM SUBROUTINE DRYAIR)
      KAIR=0.02425+(7.038E-5*TA)
      
C	  INITIALISE
      KFURCMPRS=0.
      
C     CHECKING  FOR BARE SKIN
      FURTST = RHOD*DHAIRD*LHAIRD*ZFURD
      
C     WORK OUT PERCENTAGE OF VENTRAL FUR EXPOSED AND USE THIS IN AVERAGE CALCULATIONS
      IF(SHAPE_B_MAX.EQ.SHAPE_B_REF)THEN
C      PTVEN = 0.0
       PTVEN = MAXPTVEN
      ELSE
       PTVEN = (SHAPE_B-SHAPE_B_REF)/(SHAPE_B_MAX-SHAPE_B_REF)*MAXPTVEN
      ENDIF
      
C     COMPUTING AVERAGE VALUES OF PARAMETERS (ALREADY IN SI UNITS)
      RHO = RHOD*(1-PTVEN) + (RHOV*PTVEN)
      DHAIR = (DHAIRD*(1-PTVEN)) + DHAIRV*PTVEN
      LHAIR = (LHAIRD*(1-PTVEN)) + LHAIRV*PTVEN
      ZFUR = (ZFURD*(1-PTVEN)) + ZFURV*PTVEN
      REFL  = (REFLD*(1-PTVEN)) + REFLV*PTVEN

C     NOW PUT THE DATA FROM THE 3 PARTS OF THE ANIMAL INTO THE APPROPRIATE ARRAY
C     INDEX IS AVERAGE (1), DORSAL(2), VENTRAL(3)
C     AVERAGE FUR VALUES OF BODY PART
      DHAR(1) = DHAIR
      LHAR(1) = LHAIR
      RHOAR(1) = RHO
      ZZFUR(1) = ZFUR
      REFLFR(1) = REFL

C     DORSAL VALUES OF BODY PART
      DHAR(2) = DHAIRD
      LHAR(2) = LHAIRD
      RHOAR(2) = RHOD
      ZZFUR(2) = ZFURD
      REFLFR(2) = REFLD

C     VENTRAL FUR VALUES OF BODY PART
C  	  ACCOUNTING FOR PTVEN IN VENTRAL FUR PROPERTIES
      PTVENV = PTVEN*2 ! BECAUSE ANIMAL IS CONSIDERED AS THE AVERAGE OF A WHOLLY DORSAL AND 'WHOLLY' VENTRAL CALC, BUT VENTRAL FUR MAY NOT COVER ALL OF VENTRAL HALF
      DHAR(3) = DHAIRD*(1-PTVENV) + DHAIRV*PTVENV
      LHAR(3) = LHAIRD*(1-PTVENV) + LHAIRV*PTVENV
      RHOAR(3) = RHOD*(1-PTVENV) + (RHOV*PTVENV)
      ZZFUR(3) = ZFURD*(1-PTVENV) + ZFURV*PTVENV
      REFLFR(3) = REFLD*(1-PTVENV) + REFLV*PTVENV

      DO 9, L=1,3
C      INDEX,L,IS THE AVERAGE(1),FRONT(2), BACK(3) OR DORSAL(2), VENTRAL(3) OF THE BODY PART
C      TEST FOR ZERO VALUES
       IF(FURTST.LE.0.000)THEN
        KEFARA(L) = 0.0
        BETARA(L) = 0.0
        B1ARA(L) = 0.0
       ELSE
C       FUR PRESENT
        CALL GETKFUR(RHOAR(L),LHAR(L),ZZFUR(L),DHAR(L),KAIR,KHAIR,
     &   GETKFURout)
        !# output
        KEFARA(L) = GETKFURout(1)
        BETARA(L) = GETKFURout(2)
        B1ARA(L) = GETKFURout(3)
        IF(L.EQ.3)THEN
C        COMPUTE COMPRESSED VENTRAL FUR THERMAL CONDUCTIVITY FOR USE
         CALL GETKFUR(RHOAR(L),LHAR(L),ZFURCOMP,DHAR(L),KAIR,KHAIR,
     &    GETKFURout)
         KFURCMPRS = GETKFURout(1)
        ENDIF
       ENDIF
9     CONTINUE

      RESULTS = (/KEFARA(1),KEFARA(2),
     & KEFARA(3),BETARA(1),BETARA(2),BETARA(3),B1ARA(1),B1ARA(2),
     & B1ARA(3),DHAR(1),DHAR(2),DHAR(3),LHAR(1),LHAR(2),LHAR(3),
     & RHOAR(1),RHOAR(2),RHOAR(3),ZZFUR(1),ZZFUR(2),ZZFUR(3),REFLFR(1),
     & REFLFR(2),REFLFR(3),FURTST,KFURCMPRS/)
      RETURN
      END