function add_variable!(
    container::SingleOptimizationContainer,
    variable_type::T,
    devices::U,
    formulation::AbstractTechnologyFormulation,
    tech_model::String,
) where {
    T <: InvestmentVariableType,
    U <: Union{D, Vector{D}, IS.FlattenIteratorWrapper{D}},
} where {D <: PSIP.Technology}
    #@assert !isempty(devices)
    time_mapping = get_time_mapping(container)
    time_steps = get_investment_time_steps(time_mapping)
    binary = false

    names = [PSIP.get_name(d) for d in devices]
    check_duplicate_names(names, container, variable_type, D)

    variable = add_variable_container!(
        container,
        variable_type,
        D,
        names,
        time_steps,
        meta=tech_model,
    )

    for t in time_steps, d in devices
        name = PSY.get_name(d)
        variable[name, t] = JuMP.@variable(
            get_jump_model(container),
            base_name = "$(T)_$(D)_{$(name), $(t)}",
            binary = binary
        )
        ub = get_variable_upper_bound(variable_type, d, formulation)
        ub !== nothing && JuMP.set_upper_bound(variable[name, t], ub)

        lb = get_variable_lower_bound(variable_type, d, formulation)
        lb !== nothing && JuMP.set_lower_bound(variable[name, t], lb)
    end

    return
end

function add_variable!(
    container::SingleOptimizationContainer,
    variable_type::T,
    devices::U,
    formulation::AbstractTechnologyFormulation,
    tech_model::String,
) where {
    T <: OperationsVariableType,
    U <: Union{D, Vector{D}, IS.FlattenIteratorWrapper{D}},
} where {D <: PSIP.Technology}
    #@assert !isempty(devices)
    time_mapping = get_time_mapping(container)
    time_steps = get_time_steps(time_mapping)
    binary = false

    names = [PSIP.get_name(d) for d in devices]
    check_duplicate_names(names, container, variable_type, D)

    variable = add_variable_container!(
        container,
        variable_type,
        D,
        names,
        time_steps,
        meta=tech_model,
    )

    for t in time_steps, d in devices
        name = PSY.get_name(d)
        variable[name, t] = JuMP.@variable(
            get_jump_model(container),
            base_name = "$(T)_$(D)_{$(name), $(t)}",
            binary = binary
        )
        ub = get_variable_upper_bound(variable_type, d, formulation)
        ub !== nothing && JuMP.set_upper_bound(variable[name, t], ub)

        lb = get_variable_lower_bound(variable_type, d, formulation)
        lb !== nothing && JuMP.set_lower_bound(variable[name, t], lb)
    end

    return
end
