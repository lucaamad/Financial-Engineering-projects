function [NPVa,NPVb]=NPVissueBlack_digital(dates,discounts,spol,coupon,fin_coupon,strike,S0,div,sigma,payment_dates,m,X)

% Compute the Net Present Value of the structured issue with the Black
% formula considering the digital risk

% INPUT:
% dates: dates of IR curve
% discounts: IR curve
% Nsim: number of Monte Carlo simulations
% spol: spread over libor
% coupon: first year coupon
% fin_coupon: last year coupon
% sigma: average volatility
% volofvol: volatility of the volatility
% eta: skew
% strike: strike
% S0: stock
% div: dividend
% payment_dates: dates of payment of the coupons
% flag: 1 closed, 2 Monte Carlo, 3 Monte Carlo AV
% X: upfront

load variables.mat

% Standard upfront is 0
if nargin<12
    X=0;
end

% Compute the discounts on the coupon payment dates
payment_discounts=interpB2(dates,discounts,payment_dates);
payment_dt=yearfrac(dates(1),payment_dates,EU30);

% Compute the reset dates and the relative discounts
reset_date=daysb4(payment_dates(1),2);
B=interpB2(dates,discounts,reset_date);


ttm=yearfrac(dates(1),reset_date,Act365);
F0 = S0*exp(-ttm*div)/B;

% Compute the year fractions between the payment dates 
dt=yearfrac([dates(1);payment_dates(1:end-1)],payment_dates,EU30);

% Compute a vector with the payment dates in case of Early redemption
% clause applies
stop_dates=datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:payment_dt(1)*12)';
stop_dates=businessdates(stop_dates);

% Compute a vector with the payment dates in case of Early redemption
% clause does not apply
nostop_dates=datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:payment_dt(end)*12)';
nostop_dates=businessdates(nostop_dates);

% Discounted payments of party A in both cases
NPVa_stop=NPVfloater(dates,discounts,spol,stop_dates);
NPVa_nostop=NPVfloater(dates,discounts,spol,nostop_dates);

% Discounted payments of party B in both cases
NPVb_stop=dt(1)*coupon*payment_discounts(1);
NPVb_nostop=dt(2)*fin_coupon*payment_discounts(end);

d1=log(F0/strike)/(sqrt(ttm)*sigma)+0.5*sqrt(ttm)*sigma;
d2=log(F0/strike)/(sqrt(ttm)*sigma)-0.5*sqrt(ttm)*sigma;

% Vega of a call (Black formula) - not discounted
vega = F0*sqrt(ttm)*exp(-d1^2/2)/sqrt(2*pi);

% Compute the probability of no stop
p=normcdf(d2)-m*vega;

% Total discounted paymnents of party A
NPVa=p*NPVa_nostop+(1-p)*NPVa_stop;

% Total discounted paymnents of party B
NPVb=X+p*NPVb_nostop+(1-p)*NPVb_stop;

end % function NPVissueBlack_digital