
    !-------------------------------------------------------------------------------------------------------------
    !
    ! DISCLAIMER
    ! ==========
    !
    ! All of the programming herein is original unless otherwise specified.  Details of contributions to the
    ! programming are given below.
    !
    !
    ! Revisions:
    ! ==========
    !
    !    Date          Programmer          Description of change
    !    ----          ----------          ---------------------
    !    30/11/2018    M. Poschmann        File creation.
    !
    ! Purpose:
    ! ========
    !
    ! Test implementation of reinit data usage.
    !
    !-------------------------------------------------------------------------------------------------------------

program ReinitTestCO

  USE ModuleThermoIO
  USE ModuleThermo
  USE ModuleGEMSolver

  implicit none
  integer :: i
  real(8)    :: start, finish, gibbs

  ! Initialize variables:
  dTemperature            = 3000D0
  dPressure               = 1D0
  dElementMass            = 1D0
  cInputUnitTemperature   = 'K'
  cInputUnitPressure      = 'atm'
  CInputUnitMass          = 'moles'
  cThermoFileName         = DATA_DIRECTORY // 'C-O.dat'

  ! Specify output and debug modes:
  iPrintResultsMode     = 2
  lDebugMode            = .FALSE.

  ! Parse the ChemSage data-file:
  call ParseCSDataFile(cThermoFileName)

  ! Call Thermochimica:
  call Thermochimica

  ! Print first run output
  if (iPrintResultsMode > 0)  call PrintResults

  ! Save reinit data
  call SaveReinitData

  call GibbsEnergyOfReinitData(gibbs)

  ! Call Thermochimica a bunch more for timing
  call cpu_time(start)
  LOOP_time: do i = 1,1
    call ResetThermo
    dTemperature            = 300D0
    dPressure               = 1D0
    dElementMass            = 1D0
    lReinitRequested       = .TRUE.
    call Thermochimica
  end do LOOP_time
  call cpu_time(finish)
  print '("Time = ",f6.3," seconds.")',finish-start

  ! Print second run output
  if (iPrintResultsMode > 0)  call PrintResults

  call GibbsEnergyOfReinitData(gibbs)

  ! Reset Thermochimica:
  call ResetThermo

  ! Call the debugger:
  call ThermoDebug

end program ReinitTestCO
