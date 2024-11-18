@testset "Build and solve" begin
    p_5bus, op_days = test_data()

    weights = [365 * 5, 365 * 5]

    capital = DiscountedCashFlow(
        0.07,
        Year(2025),
        [
            (Date(Month(1), Year(2030)), Date(Month(12), Year(2034))),
            (Date(Month(1), Year(2035)), Date(Month(12), Year(2039))),
        ],
    )
    operations = PSIN.OperationalRepresentativeDays(op_days, weights)
    feasibility = RepresentativePeriods(Vector{Vector{Dates}}())

    template = InvestmentModelTemplate(
        capital,
        operations,
        RepresentativePeriods(Vector{Vector{Dates}}()),
        TransportModel(MultiRegionBalanceModel, use_slacks=false),
    )

    demand_model = PSIN.TechnologyModel(
        PSIP.DemandRequirement{PSY.PowerLoad},
        PSIN.StaticLoadInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    vre_model = PSIN.TechnologyModel(
        PSIP.SupplyTechnology{PSY.RenewableDispatch},
        PSIN.ContinuousInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    thermal_modelA = PSIN.TechnologyModel(
        PSIP.SupplyTechnology{PSY.ThermalStandard},
        PSIN.ContinuousInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    thermal_modelB = PSIN.TechnologyModel(
        PSIP.SupplyTechnology{PSY.ThermalStandard},
        PSIN.IntegerInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    ac_model = PSIN.TechnologyModel(
        PSIP.ACTransportTechnology{PSY.ACBranch},
        PSIN.ContinuousInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    m = InvestmentModel(
        template,
        PSIN.SingleInstanceSolve,
        p_5bus;
        optimizer=HiGHS.Optimizer,
        portfolio_to_file=false,
        store_variable_names=true,
    )

    tech_models = template.technology_models
    tech_models[thermal_modelA] = ["cheap_thermal", "expensive_thermal"]
    tech_models[vre_model] = ["wind"]
    tech_models[demand_model] = ["demand1", "demand2"]

    branch_models = template.branch_models
    branch_models[ac_model] = ["test_branch"]

    build!(m; output_dir=mktempdir(; cleanup=true))
    # TODO: Fix Storing results
    # @test solve!(m) == PSINV.RunStatus.SUCCESSFULLY_FINALIZED

    JuMP.optimize!(m.internal.container.JuMPmodel)
    obj = JuMP.objective_value(m.internal.container.JuMPmodel)#IS.get_objective_value(res) not working for some reason?
    @test isapprox(obj, 9.58e9; atol=1e8)

    for var in all_variables(m.internal.container.JuMPmodel)
        println("Variable name: ", name(var), ", Optimized value: ", value(var))
    end

    #=
    vars = res.variable_values
    @test PSINV.VariableKey(ActivePowerVariable, PSIP.SupplyTechnology{ThermalStandard}) in
          keys(vars)
    @test PSINV.VariableKey(
        ActivePowerVariable,
        PSIP.SupplyTechnology{RenewableDispatch},
    ) in keys(vars)
    # Note that a lot of the read variable functions and stuff from IS don't work for investment variables because they are trying to use the operations timesteps
    #@test size(IS.Optimization.read_variable(res, PSINV.VariableKey(BuildCapacity, PSIP.SupplyTechnology{ThermalStandard}))) == (2, 2)
    #@test size(IS.Optimization.read_variable(res, PSINV.VariableKey(BuildCapacity, PSIP.SupplyTechnology{RenewableDispatch}))) == (2, 1)
    # Extra column for datetime
    @test size(
        IS.Optimization.read_variable(
            res,
            PSINV.VariableKey(ActivePowerVariable, PSIP.SupplyTechnology{ThermalStandard}),
        ),
    ) == (48, 3)
    @test size(
        IS.Optimization.read_variable(
            res,
            PSINV.VariableKey(
                ActivePowerVariable,
                PSIP.SupplyTechnology{RenewableDispatch},
            ),
        ),
    ) == (48, 2)
    #@test size(IS.Optimization.read_expression(res, PSINV.VariableKey(CumulativeCapacity, PSIP.SupplyTechnology{RenewableDispatch}))) == (2, 2)
    =#
end

@testset "Test OptimizationProblemResults interfaces" begin
    p_5bus, op_days = test_data()

    weights = [365 * 5, 365 * 5]

    capital = DiscountedCashFlow(
        0.07,
        Year(2025),
        [
            (Date(Month(1), Year(2030)), Date(Month(12), Year(2034))),
            (Date(Month(1), Year(2035)), Date(Month(12), Year(2039))),
        ],
    )
    operations = PSIN.OperationalRepresentativeDays(op_days, weights)
    feasibility = RepresentativePeriods(Vector{Vector{Dates}}())

    template = InvestmentModelTemplate(
        capital,
        operations,
        RepresentativePeriods(Vector{Vector{Dates}}()),
        TransportModel(MultiRegionBalanceModel, use_slacks=false),
    )

    demand_model = PSIN.TechnologyModel(
        PSIP.DemandRequirement{PSY.PowerLoad},
        PSIN.StaticLoadInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    vre_model = PSIN.TechnologyModel(
        PSIP.SupplyTechnology{PSY.RenewableDispatch},
        PSIN.ContinuousInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    thermal_modelA = PSIN.TechnologyModel(
        PSIP.SupplyTechnology{PSY.ThermalStandard},
        PSIN.ContinuousInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    thermal_modelB = PSIN.TechnologyModel(
        PSIP.SupplyTechnology{PSY.ThermalStandard},
        PSIN.IntegerInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    ac_model = PSIN.TechnologyModel(
        PSIP.ACTransportTechnology{PSY.ACBranch},
        PSIN.ContinuousInvestment,
        PSIN.BasicDispatch,
        PSIN.BasicDispatchFeasibility,
    )

    m = InvestmentModel(
        template,
        PSIN.SingleInstanceSolve,
        p_5bus;
        optimizer=HiGHS.Optimizer,
        portfolio_to_file=false,
        store_variable_names=true,
    )

    tech_models = template.technology_models
    tech_models[thermal_modelA] = ["cheap_thermal", "expensive_thermal"]
    tech_models[vre_model] = ["wind"]
    tech_models[demand_model] = ["demand1", "demand2"]

    branch_models = template.branch_models
    branch_models[ac_model] = ["test_branch"]

    build!(m; output_dir=mktempdir(; cleanup=true))

    # TODO: Fix Results Store!!!
    #=
    res = OptimizationProblemResults(m)
    @test length(IS.Optimization.list_variable_names(res)) == 4
    @test length(IS.Optimization.list_dual_names(res)) == 0
    #@test get_model_base_power(res) == 100.0
    @test isa(IS.Optimization.get_objective_value(res), Float64)
    @test isa(res.variable_values, Dict{PSINV.VariableKey, DataFrames.DataFrame})
    #@test isa(IS.Optimization.read_variables(res), Dict{String, DataFrames.DataFrame})
    @test isa(IS.Optimization.get_total_cost(res), Float64)
    @test isa(IS.Optimization.get_optimizer_stats(res), DataFrames.DataFrame)
    @test isa(res.dual_values, Dict{PSINV.ConstraintKey, DataFrames.DataFrame})
    @test isa(IS.Optimization.read_duals(res), Dict{String, DataFrames.DataFrame})
    #@test isa(PSINV.get_resolution(res), Dates.TimePeriod)
    @test isa(IS.Optimization.get_source_data(res), PSIP.Portfolio)
    @test length(PSINV.get_timestamps(res)) == 48
    =#
end
