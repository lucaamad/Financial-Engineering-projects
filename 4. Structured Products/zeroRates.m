function zRates = zeroRates(dates, discounts)

% Compute the zero rates, starting from discounts

% INPUT
% dates: dates (the first date is t0)
% discounts: discounts
% Act/365 for zero rates


dt=yearfrac(dates(1),dates,3);

zRates=-log(discounts)./dt*100;

end % function zRates
