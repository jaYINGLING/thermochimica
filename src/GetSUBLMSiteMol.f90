
!-------------------------------------------------------------------------------
!
!> \file    GetSUBLMSiteMol.f90
!> \brief   Get the output mole amount of a particular constituent on a
!>          particular sublattice of a particular phase.
!> \author  M.H.A. Piro
!> \date    June 10, 2016
!
!
! Revisions:
! ==========
!
!   Date            Programmer          Description of change
!   ----            ----------          ---------------------
!   11/10/2016      S.Simunovic         Original code
!
!
! Purpose:
! ========
!
!> \details The purpose of this subroutine is to get specific thermodynamic
!! output from an equilibrium calculation.  This particular subroutine gets
!! the  mole amount of a particular constituent on a partiuclar sublattice
!! of a SUBLM phase.  The following is required on input: the name
!! of the phase, the sublattice index and the constituent index. On output,
!! this subroutine will return a double corresponding to that constituent's
!! mole amount.
!!
!! This subroutine will check to make sure that the solution phase is stable,
!! that the sublattice index is correct, and if the constituent index is
!! correct.
!
!
! Pertinent variables:
! ====================
!
!> \param[in]     cSolnOut              A character string represnting the solution
!!                                       phase name.
!> \param[in]     iSublatticeOut        An integer scalar representing the
!!                                       sublattice index.
!> \param[in]     iConstituentOut        An integer scalar representing the
!!                                       constituent index.
!> \param[out]    dSiteMolOut           A double real scalar representing the
!!                                       mole amount of said constituent.
!> \param[out]    INFO                  An integer scalar indicating a successful
!!                                       exit (== 0) or an error (/= 0).
!!
!
!-------------------------------------------------------------------------------


subroutine GetSUBLMSiteMol(cSolnOut, iSublatticeOut, iConstituentOut, dSiteMolOut, INFO)

    USE ModuleThermo
    USE ModuleThermoIO

    implicit none

    integer,       intent(out)   :: INFO
    integer                      :: i, j, k, iph
    integer                      :: iSublatticeOut, iConstituentOut
    real(8),       intent(out)   :: dSiteMolOut
    real(8)                      :: dSiteFractionOut, dStoichCoefOut, dSolnMolOut
    character(*),  intent(in)    :: cSolnOut
    character(15)                :: cTemp
    cTemp = cSolnOut(1:min(15,len(cSolnOut)))


    ! Initialize variables:
    INFO             = 0
    dSiteMolOut      = 0D0

    ! Only proceed if Thermochimica solved successfully:
    if (INFOThermo == 0) then

        ! Remove trailing blanks:
        ! cSolnOut    = TRIM(cSolnOut)
        cTemp    = TRIM(cTemp)

        ! Loop through stable soluton phases to find the one corresponding to the
        ! solution phase being requested:
        j = 0

        LOOP_SOLN: do i = 1, nSolnPhases
           ! Get the absolute solution phase index:
           iph = nElements - i + 1
           k = -iAssemblage(iph)

           ! if (cSolnOut == cSolnPhaseName(k)) then
           if (cTemp == cSolnPhaseName(k)) then
              ! Solution phase found.  Record integer index and exit loop.
              j = k

              ! Verify that this solution phase has the correct
              ! phase type:
              if (cSolnPhaseType(j) == 'SUBLM') then
                 ! Do nothing.
              else
                 j = 0
              end if

              exit LOOP_SOLN

           end if
        end do LOOP_SOLN

        ! Check to make sure that the solution phase was found:
        IF_SOLN: if (j /= 0) then
            ! Charged phase ID:
            k  = iPhaseSublattice(j)
            i  = nSublatticePhase(k)

            ! Make sure that the sublattice index requested is within the range
            ! of the actual phase:
            if ((iSublatticeOut > i).OR.(iSublatticeOut < 1)) then
               INFO = 2
               return
            end if

            ! Return the site fration of this constituent:
            dSiteFractionOut = dSiteFraction(k,iSublatticeOut,iConstituentOut)
            dStoichCoefOut   = dStoichSublattice(k,iSublatticeOut)
            dSolnMolOut      = dMolesPhase(iph)
            dSiteMolOut      = dSiteFractionOut * dStoichCoefOut * dSolnMolOut
        else
            ! This solution phase was not found.  Report an error:
            INFO = 1
        end if IF_SOLN

    else
        ! Record an error with INFO if INFOThermo /= 0.
        INFO = -1
    end if

    return

end subroutine GetSUBLMSiteMol
