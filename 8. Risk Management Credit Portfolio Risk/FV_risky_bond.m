function [ FV ] = FV_risky_bond(cf_schedule, Q, ZC_curve, R)

% Compute the present value in one year's time for every possible state in
% one year's time (IG, HY, default)

% INPUT:
% cf_schedule: in the first column there are the expiries (in year fractions)
% and in the second column the coupon
% Q: ratings transiction matrix
% ZC_curve: curve of the zero coupon rates
% R: recovery rate

% Compute the discount factors in the dates of interest, interpolating the
% ZC_curve
discounts=exp(-interp1(ZC_curve(:,1),ZC_curve(:,2),cf_schedule(:,1),"linear").*cf_schedule(:,1));

% Survival probability
P=1-Q(1:end-1,end)';

% Survival probability at six months (by homogeneity in time)
P6=sqrt(P);

% Select dates after one year
check=cf_schedule(:,1)>1;
prob=[1,1; P6; P];
dch=discounts(check);

% Compute net value at one year
FV=(sum(cf_schedule(check,2).*dch.*prob(2:end,:))+100*R*sum((prob(1:end-1,:)-prob(2:end,:)).*dch))/discounts(2);
FV=[FV,100*R]';

end % function FV_risky_bond