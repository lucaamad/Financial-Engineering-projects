function zres=zspread(dirtyprice,cf_schedule,ZC_curve)

% Compute the z spread finding numerically the zero of the function

%INPUT:
% dirtyprice: price on market (include default possibility)
% cf_schedule: in the first column there are the expiries (in year fractions)
% and in the second column the coupon
% ZC_curve: curve of the zero coupon rates

% Compute the discount factors in the dates of interest, interpolating the
% ZC_curve
discounts=exp(-interp1(ZC_curve(:,1),ZC_curve(:,2),cf_schedule(:,1),"spline").*cf_schedule(:,1));

% Compute the z spread finding numerically the zero of the function
f=@(z) sum(cf_schedule(:,2).*exp((log(discounts))-cf_schedule(:,1)*z))-dirtyprice;
zres=fzero(f,0);

end % function zspread