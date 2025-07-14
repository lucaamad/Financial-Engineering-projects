function [PV] = PV_risky_bond_Z(Z,cf_schedule, ZC_curve)

% Compute the dirty price with the given Z spread

%INPUT:
% Z: z spread
% cf_schedule: in the first column there are the expiries (in year fractions)
% and in the second column the coupon
% ZC_curve: curve of the zero coupon rates

% Compute the discount factors in the dates of interest, interpolating the
% ZC_curve
discounts=exp(-interp1(ZC_curve(:,1),ZC_curve(:,2),cf_schedule(:,1),"spline").*cf_schedule(:,1));

% Compute the dirty price with the given Z spread
PV=sum(cf_schedule(:,2).*exp((+log(discounts))-cf_schedule(:,1)*Z));

end % function PV_risky_bond_Z