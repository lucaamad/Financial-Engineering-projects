function [discounts] = interpB2(dates,discounts,query)

% Compute the discount factors of a vector of dates, interpolating the zero rates or
% flat extrapolating if the query date is after all the dates

% INPUT:
% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% query: dates of which find the discounts

% Compute zero rates
zrates=zeroRates(dates,discounts);

% Interpolate
zeta=interp1(dates,zrates,query,'linear',zrates(end));

% Convert to discoun factors
discounts=discountfactors([dates(1);query],zeta);

end % function interpB2