function construct_technologies!(
    container::SingleOptimizationContainer,
    p::PSIP.Portfolio,
    names::Vector{String},
    ::ArgumentConstructStage,
    ::CapitalCostModel,
    technology_model::TechnologyModel{T, B, C, D},
    transport_model::TransportModel{<:AbstractTransportAggregation},
) where {
    T <: PSIP.SupplyTechnology,
    B <: ContinuousInvestment,
    C <: BasicDispatch,
    D <: FeasibilityTechnologyFormulation,
}

    #TODO: Port get_available_component functions from PSY
    #TODO: Review when we start working with larger models
    devices = [PSIP.get_technology(T, p, n) for n in names]
    #PSIP.get_technologies(T, p)

    #convert technology model to string for container metadata
    tech_model = IS.strip_module_name(B)

    # BuildCapacity variable
    # This should break if a name is passed here a second time
    add_variable!(container, BuildCapacity(), devices, B(), tech_model)

    # CumulativeCapacity
    add_expression!(container, CumulativeCapacity(), devices, B(), tech_model)
    return
end

function construct_technologies!(
    container::SingleOptimizationContainer,
    p::PSIP.Portfolio,
    names::Vector{String},
    ::ArgumentConstructStage,
    ::OperationCostModel,
    technology_model::TechnologyModel{T, B, C, D},
    transport_model::TransportModel{<:AbstractTransportAggregation},
) where {
    T <: PSIP.SupplyTechnology,
    B <: ContinuousInvestment,
    C <: BasicDispatch,
    D <: FeasibilityTechnologyFormulation,
}

    #TODO: Port get_available_component functions from PSY
    #devices = PSIP.get_technologies(T, p)
    devices = [PSIP.get_technology(T, p, n) for n in names]

    #convert technology model to string for container metadata
    tech_model = IS.strip_module_name(B)

    #ActivePowerVariable
    add_variable!(container, ActivePowerVariable(), devices, C(), tech_model)

    # EnergyBalance
    add_to_expression!(container, EnergyBalance(), devices, C(), tech_model, transport_model)

    return
end

function construct_technologies!(
    container::SingleOptimizationContainer,
    p::PSIP.Portfolio,
    names::Vector{String},
    ::ArgumentConstructStage,
    ::FeasibilityModel,
    technology_model::TechnologyModel{T, B, C, D},
    transport_model::TransportModel{<:AbstractTransportAggregation},
) where {
    T <: PSIP.SupplyTechnology,
    B <: ContinuousInvestment,
    C <: BasicDispatch,
    D <: FeasibilityTechnologyFormulation,
}

    #TODO: Port get_available_component functions from PSY
    #devices = PSIP.get_technologies(T, p)
    devices = [PSIP.get_technology(T, p, n) for n in names]

    #convert technology model to string for container metadata
    tech_model = IS.strip_module_name(B)

    return
end

function construct_technologies!(
    container::SingleOptimizationContainer,
    p::PSIP.Portfolio,
    names::Vector{String},
    ::ModelConstructStage,
    model::CapitalCostModel,
    technology_model::TechnologyModel{T, B, C, D},
    transport_model::TransportModel{<:AbstractTransportAggregation},
) where {
    T <: PSIP.SupplyTechnology,
    B <: ContinuousInvestment,
    C <: BasicDispatch,
    D <: FeasibilityTechnologyFormulation,
}
    #devices = PSIP.get_technologies(T, p)
    devices = [PSIP.get_technology(T, p, n) for n in names]

    #convert technology model to string for container metadata
    tech_model = IS.strip_module_name(B)

    # Capital Component of objective function
    objective_function!(container, devices, B(), tech_model)
    # Add objective function from container to JuMP model
    update_objective_function!(container)

    # Capacity constraint
    add_constraints!(container, MaximumCumulativeCapacity(), CumulativeCapacity(), devices, tech_model)

    return
end

function construct_technologies!(
    container::SingleOptimizationContainer,
    p::PSIP.Portfolio,
    names::Vector{String},
    ::ModelConstructStage,
    model::OperationCostModel,
    technology_model::TechnologyModel{T, B, C, D},
    transport_model::TransportModel{<:AbstractTransportAggregation},
) where {
    T <: PSIP.SupplyTechnology,
    B <: ContinuousInvestment,
    C <: BasicDispatch,
    D <: FeasibilityTechnologyFormulation,
}
    #devices = PSIP.get_technologies(T, p)
    devices = [PSIP.get_technology(T, p, n) for n in names]

    #convert technology model to string for container metadata
    tech_model = IS.strip_module_name(B)

    # Operations Component of objective function
    objective_function!(container, devices, C(), tech_model)

    # Add objective function from container to JuMP model
    update_objective_function!(container)
    
    # Dispatch constraint
    add_constraints!(
        container,
        ActivePowerLimitsConstraint(),
        ActivePowerVariable(),
        devices,
        tech_model
    )

    return
end

function construct_technologies!(
    container::SingleOptimizationContainer,
    p::PSIP.Portfolio,
    names::Vector{String},
    ::ModelConstructStage,
    model::FeasibilityModel,
    technology_model::TechnologyModel{T, B, C, D},
    transport_model::TransportModel{<:AbstractTransportAggregation},
) where {
    T <: PSIP.SupplyTechnology,
    B <: ContinuousInvestment,
    C <: BasicDispatch,
    D <: FeasibilityTechnologyFormulation,
}
    #devices = PSIP.get_technologies(T, p)
    devices = [PSIP.get_technology(T, p, n) for n in names]

    #convert technology model to string for container metadata
    #tech_model = IS.strip_module_name(typeof(technology_model))
    tech_model = IS.strip_module_name(B)

    return
end

#Added constructor for unit investment problems. Does not do anything yet, purely for testing purposes
function construct_technologies!(
    container::SingleOptimizationContainer,
    p::PSIP.Portfolio,
    names::Vector{String},
    ::ArgumentConstructStage,
    ::CapitalCostModel,
    technology_model::TechnologyModel{T, B, C, D},
    transport_model::TransportModel{<:AbstractTransportAggregation},
) where {
    T <: PSIP.SupplyTechnology,
    B <: IntegerInvestment,
    C <: BasicDispatch,
    D <: FeasibilityTechnologyFormulation,
}

    #TODO: Port get_available_component functions from PSY
    # filter based on technology names passed
    #TODO: Review when we start working with larger models
    devices = [PSIP.get_technology(T, p, n) for n in names]
    #PSIP.get_technologies(T, p)

    #convert technology model to string for container metadata
    tech_model = IS.strip_module_name(B)

    # BuildCapacity variable
    # This should break if a name is passed here a second time
    
    add_variable!(container, BuildCapacity(), devices, B(), tech_model)

    # CumulativeCapacity
    #add_expression!(container, CumulativeCapacity(), devices, B(), technology_model.group_name)
    return
end