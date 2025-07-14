function [NPVa,NPVb]=NPVswap(dates,discounts,ttm,floating_dates)

% Compute Net Present Value of a swap

% INPUT:
% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% ttm: times to maturity
% floating dates: date of payment of the floating leg

% Setting variables
load variables.mat

% Select the dates of payment of the floating leg and of the fix leg
fix_dates=floating_dates(4:4:4*ttm);
floating_dates=floating_dates(1:4*ttm);

% Compute the discount in the fixed dates interpolating
discounts_x=interpB2(dates,discounts,fix_dates);

% Compute year fraction in European 30/360 convention
dt_fix=yearfrac([dates(1);fix_dates(1:end-1)],fix_dates,EU30);

% Compute the discount in the floating dates interpolating
discounts_f=interpB2(dates,discounts,floating_dates);

% Compute NPV of floating leg and fixed leg
NPVa = 1-discounts_f(end); % floating leg
NPVb = sum(discounts_x.*dt_fix); % fixed leg

end % function NPVswap