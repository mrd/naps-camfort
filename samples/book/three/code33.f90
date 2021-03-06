!!!!!!!!!!!!!!!!!!!!!!!!!!!   Program 3.3   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                                                       !
! Please Note:                                                          !
!                                                                       !
! (1) This computer program is written by Tao Pang in conjunction with  !
!     his book, "An Introduction to Computational Physics," published   !
!     by Cambridge University Press in 1997.                            !
!                                                                       !
! (2) No warranties, express or implied, are made for this program.     !
!                                                                       !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
PROGRAM SHOOTING
!
! Program for the boundary value problem with the shooting
! method.  The Runge-Kutta and secant methods are used.
! Copyright (c) Tao Pang 1997.
!
  IMPLICIT NONE
  INTEGER, PARAMETER :: N=101,M=5
  REAL :: DK11,DK21,DK12,DK22,DK13,DK23,DK14,DK24
  REAL :: DL,XL,XU,H,D,YL,YU,X0,DX,X1,X2,F0,F1
  REAL :: X ! added by DAO
  INTEGER :: I ! added by DAO
  REAL :: Y1,Y2,G1,G1F,G2,G2F
  REAL, DIMENSION (2,N) :: Y
!
! Initialization of the problem
!
  DL = 1.0E-06
  XL = 0.0
  XU = 1.0
  H  = (XU-XL)/(N-1)
  D  = 0.1
  YL = 0.0
  YU = 1.0
  X0 = (YU-YL)/(XU-XL)
  DX = 0.01
  X1 = X0+DX
!
! The secant search for the root
!
  Y(1,1) = YL
  DO WHILE (ABS(D).GT.DL)
!
!C The!Runge-Kutta calculation of the first trial solution
!
    Y(2,1) = X0
    DO I = 1, N-1
      X  = XL+H*I
      Y1 = Y(1,I)
      Y2 = Y(2,I)
      DK11 = H*G1F(Y1,Y2,X)
      DK21 = H*G2F(Y1,Y2,X)
      DK12 = H*G1F((Y1+DK11/2.0),(Y2+DK21/2.0),(X+H/2.0))
      DK22 = H*G2F((Y1+DK11/2.0),(Y2+DK21/2.0),(X+H/2.0))
      DK13 = H*G1F((Y1+DK12/2.0),(Y2+DK22/2.0),(X+H/2.0))
      DK23 = H*G2F((Y1+DK12/2.0),(Y2+DK22/2.0),(X+H/2.0))
      DK14 = H*G1F((Y1+DK13),(Y2+DK23),(X+H))
      DK24 = H*G2F((Y1+DK13),(Y2+DK23),(X+H))
      Y(1,I+1) = Y(1,I)+(DK11+2.0*(DK12+DK13)+DK14)/6.0
      Y(2,I+1) = Y(2,I)+(DK21+2.0*(DK22+DK23)+DK24)/6.0
    END DO
    F0 = Y(1,N)-1.0
!
! Runge-Kutta calculation of the second trial solution
!
    Y(2,1) = X1
    DO I = 1, N-1
      X  = XL+H*I
      Y1 = Y(1,I)
      Y2 = Y(2,I)
      DK11 = H*G1(Y1,Y2,X)
      DK21 = H*G2(Y1,Y2,X)
      DK12 = H*G1((Y1+DK11/2.0),(Y2+DK21/2.0),(X+H/2.0))
      DK22 = H*G2((Y1+DK11/2.0),(Y2+DK21/2.0),(X+H/2.0))
      DK13 = H*G1((Y1+DK12/2.0),(Y2+DK22/2.0),(X+H/2.0))
      DK23 = H*G2((Y1+DK12/2.0),(Y2+DK22/2.0),(X+H/2.0))
      DK14 = H*G1((Y1+DK13),(Y2+DK23),(X+H))
      DK24 = H*G2((Y1+DK13),(Y2+DK23),(X+H))
      Y(1,I+1) = Y(1,I)+(DK11+2.0*(DK12+DK13)+DK14)/6.0
      Y(2,I+1) = Y(2,I)+(DK21+2.0*(DK22+DK23)+DK24)/6.0
    END DO
    F1 = Y(1,N)-1.0
!
    D  = F1-F0
    X2 = X1-F1*(X1-X0)/D
    X0 = X1
    X1 = X2
  END DO
  WRITE (6,"(2F16.8)") (H*(I-1), Y(1,I),I=1,N,M)
END
!
FUNCTION G1F (Y1,Y2,T) RESULT (G1)
  IMPLICIT NONE
  REAL :: Y1,Y2,T,G1
!
   G1 = Y2
END FUNCTION G1F
!
FUNCTION G2F (Y1,Y2,T) RESULT (G2)
  IMPLICIT NONE
  REAL :: PI,Y1,Y2,T,G2
!
  PI = 4.0*ATAN(1.0)
  G2 =-PI*PI*(Y1+1.0)/4.0
END FUNCTION G2F
