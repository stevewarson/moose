# Pressure pulse in 1D with 2 phases, 2components - transient

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 10
  xmin = 0
  xmax = 100
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [./ppwater]
    initial_condition = 2e6
  [../]
  [./sgas]
    initial_condition = 0.3
  [../]
[]

[AuxVariables]
  [./massfrac_ph0_sp0]
    initial_condition = 1
  [../]
  [./massfrac_ph1_sp0]
    initial_condition = 0
  [../]
  [./ppgas]
    family = MONOMIAL
    order = FIRST
  [../]
[]

[Kernels]
  [./mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = ppwater
  [../]
  [./flux0]
    type = PorousFlowAdvectiveFlux
    variable = ppwater
    fluid_component = 0
  [../]
  [./mass1]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = sgas
  [../]
  [./flux1]
    type = PorousFlowAdvectiveFlux
    variable = sgas
    fluid_component = 1
  [../]
[]

[AuxKernels]
  [./ppgas]
    type = PorousFlowPropertyAux
    property = pressure
    phase = 1
    variable = ppgas
  [../]
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'ppwater sgas'
    number_fluid_phases = 2
    number_fluid_components = 2
  [../]
  [./pc]
    type = PorousFlowCapillaryPressureVG
    m = 0.5
    alpha = 1e-4
    sat_lr = 0.3
    pc_max = 1e9
    log_extension = true
  [../]
[]

[Modules]
  [./FluidProperties]
    [./simple_fluid0]
      type = SimpleFluidProperties
      bulk_modulus = 2e9
      density0 = 1000
      thermal_expansion = 0
      viscosity = 1e-3
    [../]
    [./simple_fluid1]
      type = SimpleFluidProperties
      bulk_modulus = 2e7
      density0 = 1
      thermal_expansion = 0
      viscosity = 1e-5
    [../]
  [../]
[]

[Materials]
  [./temperature]
    type = PorousFlowTemperature
  [../]
  [./temperature_nodal]
    type = PorousFlowTemperature
    at_nodes = true
  [../]
  [./ppss_qp]
    type = PorousFlow2PhasePS
    phase0_porepressure = ppwater
    phase1_saturation = sgas
    capillary_pressure = pc
  [../]
  [./ppss]
    type = PorousFlow2PhasePS
    at_nodes = true
    phase0_porepressure = ppwater
    phase1_saturation = sgas
    capillary_pressure = pc
  [../]
  [./massfrac]
    type = PorousFlowMassFraction
    at_nodes = true
    mass_fraction_vars = 'massfrac_ph0_sp0 massfrac_ph1_sp0'
  [../]
  [./simple_fluid0]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid0
    phase = 0
    at_nodes = true
  [../]
  [./simple_fluid0_qp]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid0
    phase = 0
  [../]
  [./simple_fluid1]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid1
    phase = 1
    at_nodes = true
  [../]
  [./simple_fluid1_qp]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid1
    phase = 1
  [../]
  [./porosity]
    type = PorousFlowPorosityConst
    at_nodes = true
    porosity = 0.1
  [../]
  [./permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1e-15 0 0 0 1e-15 0 0 0 1e-15'
  [../]
  [./relperm_water]
    type = PorousFlowRelativePermeabilityCorey
    at_nodes = true
    n = 1
    phase = 0
  [../]
  [./relperm_gas]
    type = PorousFlowRelativePermeabilityCorey
    at_nodes = true
    n = 1
    phase = 1
  [../]
[]

[BCs]
  [./leftwater]
    type = DirichletBC
    boundary = left
    value = 3e6
    variable = ppwater
  [../]
  [./rightwater]
    type = DirichletBC
    boundary = right
    value = 2e6
    variable = ppwater
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it'
    petsc_options_value = 'bcgs bjacobi 1E-15 1E-20 10000'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = Newton
  dt = 1e3
  end_time = 1e4
[]

[VectorPostprocessors]
  [./pp]
    type = LineValueSampler
    execute_on = timestep_end
    sort_by = x
    variable = 'ppwater ppgas'
    start_point = '0 0 0'
    end_point = '100 0 0'
    num_points = 11
  [../]
[]

[Outputs]
  file_base = pressure_pulse_1d_2phasePSVG2
  print_linear_residuals = false
  csv = true
  execute_on = final
[]
