### Operations Formulations ###

struct BasicDispatch <: OperationsTechnologyFormulation end
struct ThermalNoDispatch <: OperationsTechnologyFormulation end
struct RenewableNoDispatch <: OperationsTechnologyFormulation end

"""
Infinite capacity approximation of network flow to represent entire system with a single node.
"""
struct SingleRegionPowerModel <: PM.AbstractActivePowerModel end
