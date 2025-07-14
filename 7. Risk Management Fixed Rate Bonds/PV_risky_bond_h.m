function [PV] = PV_risky_bond_h(cf_schedule, h_curve, ZC_curve, R)

% Compute the dirty price with the given h curve

% INPUT:
% cf_schedule: in the first column there are the expiries (in year fractions)
% and in the second column the coupon
% h_curve: in the first column there are the expiries (in year fractions)
% and in the second the h
% ZC_curve: curve of the zero coupon rates
% R: recovery (as percentage)

% Compute the discount factors in the dates of interest, interpolating the
% ZC_curve
discounts=exp(-interp1(ZC_curve(:,1),ZC_curve(:,2),cf_schedule(:,1),"spline").*cf_schedule(:,1));

% Compute the default probabilities of the dates of interest
p=exp(-h_curve(1,2)*min(cf_schedule(:,1),1)-h_curve(2,2)*max(cf_schedule(:,1)-h_curve(1,1),0));
p=[1;p];

% Compute the dirty price with the given h curve
PV=sum(cf_schedule(:,2).*p(2:end).*discounts)+100*R*sum(discounts.*(p(1:end-1)-p(2:end)));

end % function PV_risky_bond_h