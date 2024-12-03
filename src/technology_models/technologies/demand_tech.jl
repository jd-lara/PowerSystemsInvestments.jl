function get_default_time_series_names(::Type{U}) where {U <: PSIP.DemandRequirement}
    return "ops_peak_load"
end

function get_default_attributes(
    ::Type{U},
    ::Type{V},
    ::Type{W},
    ::Type{X},
) where {
    U <: PSIP.DemandRequirement,
    V <: InvestmentTechnologyFormulation,
    W <: OperationsTechnologyFormulation,
    X <: FeasibilityTechnologyFormulation,
}
    return Dict{String, Any}()
end

################### Variables ####################

get_variable_multiplier(::ActivePowerVariable, ::Type{PSIP.DemandRequirement}) = -1.0

################## Expressions ###################

function add_to_expression!(
    container::SingleOptimizationContainer,
    expression_type::T,
    devices::U,
    formulation::BasicDispatch,
    transport_model::TransportModel{V},
    #tech_model::String,
) where {
    T <: EnergyBalance,
    U <: Union{D, Vector{D}, IS.FlattenIteratorWrapper{D}},
    V <: SingleRegionBalanceModel,
} where {D <: PSIP.DemandRequirement}
    #@assert !isempty(devices)
    time_mapping = get_time_mapping(container)
    operational_indexes = get_operational_indexes(time_mapping)
    consecutive_slices = get_consecutive_slices(time_mapping)
    expression = get_expression(container, T(), PSIP.Portfolio)
    time_stamps = get_time_stamps(time_mapping)

    for d in devices
        for op_ix in operational_indexes
            time_slices = consecutive_slices[op_ix]
            time_series = retrieve_ops_time_series(d, op_ix, time_mapping)
            # Load Data is in MW
            ts_data = TimeSeries.values(time_series.data)
            first_tstamp = time_stamps[first(time_slices)]
            first_ts_tstamp = first(TimeSeries.timestamp(time_series.data))
            if first_tstamp != first_ts_tstamp
                @error(
                    "Initial timestamp of timeseries $(IS.get_name(time_series)) of technology $(d.name) does not match with the expected representative day $op_ix"
                )
            end
            for (ix, t) in enumerate(time_slices)
                _add_to_jump_expression!(expression["SingleRegion", t], -1.0 * ts_data[ix])
            end
        end
    end

    return
end

function add_to_expression!(
    container::SingleOptimizationContainer,
    expression_type::T,
    devices::U,
    formulation::BasicDispatch,
    transport_model::TransportModel{V},
    #tech_model::String,
) where {
    T <: EnergyBalance,
    U <: Union{D, Vector{D}, IS.FlattenIteratorWrapper{D}},
    V <: MultiRegionBalanceModel,
} where {D <: PSIP.DemandRequirement}
    #@assert !isempty(devices)
    time_mapping = get_time_mapping(container)
    operational_indexes = get_operational_indexes(time_mapping)
    consecutive_slices = get_consecutive_slices(time_mapping)
    expression = get_expression(container, T(), PSIP.Portfolio)
    time_stamps = get_time_stamps(time_mapping)

    for d in devices
        region = PSIP.get_region(d)
        for op_ix in operational_indexes
            time_slices = consecutive_slices[op_ix]
            time_series = retrieve_ops_time_series(d, op_ix, time_mapping)
            # Load Data is in MW
            ts_data = TimeSeries.values(time_series.data)
            first_tstamp = time_stamps[first(time_slices)]
            first_ts_tstamp = first(TimeSeries.timestamp(time_series.data))
            if first_tstamp != first_ts_tstamp
                @error(
                    "Initial timestamp of timeseries $(IS.get_name(time_series)) of technology $(d.name) does not match with the expected representative day $op_ix"
                )
            end
            for (ix, t) in enumerate(time_slices)
                _add_to_jump_expression!(expression[region, t], -1.0 * ts_data[ix])
            end
        end
    end
    return
end

function add_to_expression!(
    container::SingleOptimizationContainer,
    expression_type::T,
    devices::U,
    formulation::BasicDispatchFeasibility,
    transport_model::TransportModel{V},
    #tech_model::String,
) where {
    T <: FeasibilitySurplus,
    U <: Union{D, Vector{D}, IS.FlattenIteratorWrapper{D}},
    V <: SingleRegionBalanceModel,
} where {D <: PSIP.DemandRequirement}
    #@assert !isempty(devices)
    time_mapping = get_time_mapping(container)
    operational_indexes = get_operational_indexes(time_mapping)
    consecutive_slices = get_consecutive_slices(time_mapping)
    expression = get_expression(container, T(), PSIP.Portfolio)
    time_stamps = get_time_stamps(time_mapping)

    for d in devices
        for op_ix in operational_indexes
            time_slices = consecutive_slices[op_ix]
            time_series = retrieve_ops_time_series(d, op_ix, time_mapping)
            # Load Data is in MW
            ts_data = TimeSeries.values(time_series.data)
            first_tstamp = time_stamps[first(time_slices)]
            first_ts_tstamp = first(TimeSeries.timestamp(time_series.data))
            if first_tstamp != first_ts_tstamp
                @error(
                    "Initial timestamp of timeseries $(IS.get_name(time_series)) of technology $(d.name) does not match with the expected representative day $op_ix"
                )
            end
            for (ix, t) in enumerate(time_slices)
                _add_to_jump_expression!(expression["SingleRegion", t], -1.0 * ts_data[ix])
            end
        end
    end

    return
end

function add_to_expression!(
    container::SingleOptimizationContainer,
    expression_type::T,
    devices::U,
    formulation::BasicDispatchFeasibility,
    transport_model::TransportModel{V},
    #tech_model::String,
) where {
    T <: FeasibilitySurplus,
    U <: Union{D, Vector{D}, IS.FlattenIteratorWrapper{D}},
    V <: MultiRegionBalanceModel,
} where {D <: PSIP.DemandRequirement}
    #@assert !isempty(devices)
    time_mapping = get_time_mapping(container)
    operational_indexes = get_operational_indexes(time_mapping)
    consecutive_slices = get_consecutive_slices(time_mapping)
    expression = get_expression(container, T(), PSIP.Portfolio)
    time_stamps = get_time_stamps(time_mapping)

    for d in devices
        region = PSIP.get_region(d)
        for op_ix in operational_indexes
            time_slices = consecutive_slices[op_ix]
            time_series = retrieve_ops_time_series(d, op_ix, time_mapping)
            # Load Data is in MW
            ts_data = TimeSeries.values(time_series.data)
            first_tstamp = time_stamps[first(time_slices)]
            first_ts_tstamp = first(TimeSeries.timestamp(time_series.data))
            if first_tstamp != first_ts_tstamp
                @error(
                    "Initial timestamp of timeseries $(IS.get_name(time_series)) of technology $(d.name) does not match with the expected representative day $op_ix"
                )
            end
            for (ix, t) in enumerate(time_slices)
                _add_to_jump_expression!(expression[region, t], -1.0 * ts_data[ix])
            end
        end
    end
    return
end
