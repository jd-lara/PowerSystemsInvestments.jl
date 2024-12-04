function add_constraints!(
    container::SingleOptimizationContainer,
    ::Type{T},
    port::U,
) where {T<:SingleRegionBalanceConstraint,U<:PSIP.Portfolio}
    time_mapping = get_time_mapping(container)
    time_steps = get_operational_time_steps(time_mapping)
    expressions = get_expression(container, EnergyBalance(), U)
    constraint = add_constraints_container!(container, T(), U, time_steps)
    for t in time_steps
        constraint[t] =
            JuMP.@constraint(get_jump_model(container), expressions["SingleRegion", t] == 0)
    end

    return
end

function add_constraints!(
    container::SingleOptimizationContainer,
    ::Type{T},
    port::U,
) where {T<:SingleRegionBalanceFeasibilityConstraint,U<:PSIP.Portfolio}
    time_mapping = get_time_mapping(container)
    time_steps = get_feasibility_time_steps(time_mapping)
    expressions = get_expression(container, CapacitySurplus(), U)
    constraint = add_constraints_container!(container, T(), U, time_steps)
    for t in time_steps
        constraint[t] =
            JuMP.@constraint(get_jump_model(container), expressions["SingleRegion", t] >= 0)
    end

    return
end
