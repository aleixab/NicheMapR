      SUBROUTINE ADJREC

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
C
C     ONLY VARIABLES USED IN A SUBROUTINE ARE DECLARED
C     THIS NON EXECUTABLE BLOCK IS USED TO
C     INITIALIZE ALL DATA FOR THE PROGRAM.  THE DATA ARE OVERWRITTEN
C     IF DATA ARE READ IN BY PROGRAM MAIN.

C     SUBROUTINE TO COMPUTE THE CONFIGURATION FACTOR BETWEEN
C     ADJACENT RECTANGLES WITH ANGLE, ANGLE, BETWEEN THEM.
C     CONFIGURATION FIGURE 2, CHAPTER 7., 'ANIMAL LANDSCAPES' BY PORTER

      IMPLICIT NONE

      DOUBLE PRECISION A,ATAN1,B,C,X,Y,Z,PI,ANGLE,F,LOG1,LOG2,LOG3,P,P1
      DOUBLE PRECISION P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,PALPHA,PA
      DOUBLE PRECISION PB,PC,PD,PP3,P5A,P5B,STARTV,ENDV,S,SQRT1

      EXTERNAL FUNC

      COMMON/INTGL/X,ANGLE
      COMMON/RECTNGL/A,B,C,F

      PI=3.14159265

C     WIDTH OF BODY = A
C     LENGTH OF BODY & WING (PARALLEL TO LONG AXIS OF BODY) = B
C     WIDTH OF WING (FROM JUNCTION W BODY TO WING TIP) = C
      X=A/B
      Y=C/B
      Z=X**2.+Y**2.-2.*X*Y*COS(ANGLE)

C     CALCULATE F12 PARTS OF THE EQUATION FIRST
      P=SIN(2.*ANGLE)/4.
      P1=X*Y*SIN(ANGLE)
      P2=((PI/2.)-ANGLE)*(X**2.+Y**2.)
      PP3=(X-Y*COS(ANGLE))/(Y*SIN(ANGLE))
      P3=Y**2.* ATAN(PP3)
      P4=X**2.*ATAN((Y-X*COS(ANGLE))/(X*SIN(ANGLE)))
      PALPHA=-P*(P1+P2+P3+P4)

C     A TRIG EQUIVALENCE: SIN**2(ANGLE) = (0.5*(1.-COS(2*ANGLE)))
C     A TRIG EQUIVALENCE: COS**2(ANGLE) = (0.5*(1.+COS(2*ANGLE)))
      P5A=(2./(0.5*(1.-COS(2*ANGLE)))-1.0)
      LOG1=((1.+X**2.)*(1.+Y**2.))/(1.+Z)
      P5B=LOG(LOG1)
      P5=P5A*P5B
      LOG2=(Y**2.*(1.+Z))/((1.+Y**2.)*Z)
      P6=Y**2.*LOG(LOG2)
      LOG3=(X**2*(1.+X**2.)**COS(2.*ANGLE))/
     &(Z*(1.+Z)**COS(2*ANGLE))
      P7=X**2.*LOG(LOG3)
      P8=((0.5*(1.-COS(2*ANGLE)))/4.)* (P5 + P6 + P7)
      P9=Y*ATAN(1./Y)
      P10=X*ATAN(1./X)
      P11=Z**0.5*ATAN(1./Z**0.5)
      PA=(SIN(ANGLE)*SIN(2.*ANGLE))/2.
      SQRT1=1.+X**2.*(0.5*(1.-COS(2.*ANGLE)))
      PB=X*SQRT(SQRT1)
      PC=ATAN((X*COS(ANGLE))/SQRT(SQRT1))
      ATAN1=(Y-X*COS(ANGLE))/SQRT(SQRT1)
      PD=ATAN(ATAN1)
      P12=PA*PB*(PC+PD)

C     SETTING UP NUMERICAL INTEGRATOR, QROMB, FROM NUMERICAL RECIPES
C     STARTING & ENDING VALUES FOR THE INTEGRATION = STARTV,ENDV
C     INTEGRAL = S. IT COMES FROM SUB. TRAPZD
C     FUNC = FUNCTION TO INTEGRATE
      STARTV=0.0
      ENDV=Y
      CALL QROMB(FUNC,STARTV,ENDV,S)
      P13=COS(ANGLE)*S
      F=(1./(PI*Y))*(PALPHA+P8+P9+P10-P11+P12+P13)
      RETURN
      END