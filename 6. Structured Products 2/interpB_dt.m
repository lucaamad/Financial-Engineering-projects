function [discounts] = interpB_dt(dates,discounts,dt_query)

% Compute the discount factors of a vector of dates, interpolating the zero rates or
% flat extrapolating if the query date is after all the dates

% INPUT:

% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% dt_query: interval between the starting date and each date

load variables.mat

% Compute zero rates
zrates=zeroRates(dates,discounts);

dt=yearfrac(dates(1),dates,Act365);

% 
zeta=interp1(dt,zrates,dt_query,'linear',zrates(end));  %Interpolate

% Convert to discount factors
% discounts=discountfactors([dates(1);query],zeta);

discounts=exp(-dt_query.*zeta/100);

check=isnan(discounts);
discounts(check)=1;

end % function interpB_dt