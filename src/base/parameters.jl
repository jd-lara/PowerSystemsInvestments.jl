abstract type ParameterAttributes end

struct NoAttributes end

struct TimeSeriesAttributes{T <: PSY.TimeSeriesData} <: ParameterAttributes
    name::String
    multiplier_id::Base.RefValue{Int}
    component_name_to_ts_uuid::Dict{String, String}
end

function TimeSeriesAttributes(
    ::Type{T},
    name::String,
    multiplier_id::Int=1,
    component_name_to_ts_uuid=Dict{String, String}(),
) where {T <: PSY.TimeSeriesData}
    return TimeSeriesAttributes{T}(
        name,
        Base.RefValue{Int}(multiplier_id),
        component_name_to_ts_uuid,
    )
end

get_time_series_type(::TimeSeriesAttributes{T}) where {T <: PSY.TimeSeriesData} = T
get_time_series_name(attr::TimeSeriesAttributes) = attr.name
get_time_series_multiplier_id(attr::TimeSeriesAttributes) = attr.multiplier_id[]
function set_time_series_multiplier_id!(attr::TimeSeriesAttributes, val::Int)
    attr.multiplier_id[] = val
    return
end

function add_component_name!(attr::TimeSeriesAttributes, name::String, uuid::String)
    if haskey(attr.component_name_to_ts_uuid, name)
        throw(ArgumentError("$name is already stored"))
    end

    attr.component_name_to_ts_uuid[name] = uuid
    return
end

_get_ts_uuid(attr::TimeSeriesAttributes, name) = attr.component_name_to_ts_uuid[name]

struct VariableValueAttributes{T <: OptimizationContainerKey} <: ParameterAttributes
    attribute_key::T
    affected_keys::Set
end

function VariableValueAttributes(key::T) where {T <: OptimizationContainerKey}
    return VariableValueAttributes{T}(key, Set())
end

get_attribute_key(attr::VariableValueAttributes) = attr.attribute_key

struct CostFunctionAttributes{T} <: ParameterAttributes
    variable_type::Type
end

get_variable_type(attr::CostFunctionAttributes) = attr.variable_type

struct ParameterContainer{T <: AbstractArray, U <: AbstractArray}
    attributes::ParameterAttributes
    parameter_array::T
    multiplier_array::U
end

function ParameterContainer(parameter_array, multiplier_array)
    return ParameterContainer(NoAttributes(), parameter_array, multiplier_array)
end

function calculate_parameter_values(container::ParameterContainer)
    return calculate_parameter_values(
        container.attributes,
        container.parameter_array,
        container.multiplier_array,
    )
end

function calculate_parameter_values(
    attributes::ParameterAttributes,
    param_array::DenseAxisArray,
    multiplier_array::DenseAxisArray,
)
    return get_parameter_values(attributes, param_array, multiplier_array) .*
           multiplier_array
end

function calculate_parameter_values(
    ::ParameterAttributes,
    param_array::SparseAxisArray,
    multiplier_array::SparseAxisArray,
)
    p_array = jump_value.(to_matrix(param_array))
    m_array = to_matrix(multiplier_array)
    return p_array .* m_array
end

function get_parameter_column_refs(container::ParameterContainer, column::AbstractString)
    return get_parameter_column_refs(
        container.attributes,
        container.parameter_array,
        column,
    )
end

function get_parameter_column_refs(::ParameterAttributes, param_array, column)
    return param_array
end

function get_parameter_column_refs(
    attributes::TimeSeriesAttributes{T},
    param_array::DenseAxisArray,
    column,
) where {T <: PSY.TimeSeriesData}
    return param_array[_get_ts_uuid(attributes, column), axes(param_array)[2:end]...]
end

function get_parameter_column_values(container::ParameterContainer, column::AbstractString)
    return jump_value.(get_parameter_column_refs(container, column))
end

function get_parameter_values(container::ParameterContainer)
    return get_parameter_values(
        container.attributes,
        container.parameter_array,
        container.multiplier_array,
    )
end

# TODO: SparseAxisArray versions of these functions

function get_parameter_values(
    ::ParameterAttributes,
    param_array::DenseAxisArray,
    multiplier_array::DenseAxisArray,
)
    return jump_value.(param_array)
end

function get_parameter_values(
    attributes::TimeSeriesAttributes{T},
    param_array::DenseAxisArray,
    multiplier_array::DenseAxisArray,
) where {T <: PSY.TimeSeriesData}
    exploded_param_array = DenseAxisArray{Float64}(undef, axes(multiplier_array)...)
    for name in axes(multiplier_array)[1]
        param_col = param_array[_get_ts_uuid(attributes, name), axes(param_array)[2:end]...]
        device_axes = axes(multiplier_array)[2:end]
        exploded_param_array[name, device_axes...] = jump_value.(param_col)
    end

    return exploded_param_array
end

get_parameter_array(c::ParameterContainer) = c.parameter_array
get_multiplier_array(c::ParameterContainer) = c.multiplier_array
get_attributes(c::ParameterContainer) = c.attributes
Base.length(c::ParameterContainer) = length(c.parameter_array)
Base.size(c::ParameterContainer) = size(c.parameter_array)

function get_column_names(key::ParameterKey, c::ParameterContainer)
    return get_column_names(key, get_multiplier_array(c))
end

function _set_parameter!(
    array::AbstractArray{Float64},
    ::JuMP.Model,
    value::Float64,
    ixs::Tuple,
)
    array[ixs...] = value
    return
end

function _set_parameter!(
    array::AbstractArray{T},
    ::JuMP.Model,
    value::T,
    ixs::Tuple,
) where {T <: IS.FunctionData}
    array[ixs...] = value
    return
end

function _set_parameter!(
    array::AbstractArray{JuMP.VariableRef},
    model::JuMP.Model,
    value::Float64,
    ixs::Tuple,
)
    array[ixs...] = add_jump_parameter(model, value)
    return
end

function _set_parameter!(
    array::SparseAxisArray{Union{Nothing, JuMP.VariableRef}},
    model::JuMP.Model,
    value::Float64,
    ixs::Tuple,
)
    array[ixs...] = add_jump_parameter(model, value)
    return
end

function set_multiplier!(container::ParameterContainer, multiplier::Float64, ixs...)
    get_multiplier_array(container)[ixs...] = multiplier
    return
end

function set_parameter!(
    container::ParameterContainer,
    jump_model::JuMP.Model,
    parameter::Float64,
    ixs...,
)
    param_array = get_parameter_array(container)
    _set_parameter!(param_array, jump_model, parameter, ixs)
    return
end

function set_parameter!(
    container::ParameterContainer,
    jump_model::JuMP.Model,
    parameter::IS.FunctionData,
    ixs...,
)
    param_array = get_parameter_array(container)
    _set_parameter!(param_array, jump_model, parameter, ixs)
    return
end
