### Investment Constraints ###
struct MaximumCumulativeCapacity <: ISOPT.ConstraintType end

### Operations Constraints ###

struct SupplyDemandBalance <: ISOPT.ConstraintType end
struct ActivePowerVariableLimitsConstraint <: ISOPT.ConstraintType end
