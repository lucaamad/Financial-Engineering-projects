function B=discountfactors(dates,zRates)

% Compute the discounts, starting from zero rates

% INPUT

% dates: dates (the first date is t0)
% zRates: zero rates (it doesn't contain the zero rates in t0 because it's
%           defined)

% Act/365 for zero rates
dt=yearfrac(dates(1),dates(2:end),3);
B=exp(-dt.*zRates/100);

end % function discountfactors