function [NPVa,NPVb,NPVa_sim,NPVb_sim]=NPVissue(dates,discounts,Nsim,spol,coupon,fin_coupon,sigma,eta,volofvol,strike,S0,div,payment_dates,flag,X)

% Compute the Net Present Value of the structured issue with the closed
% formula (quadrature of the integral) or with Monte Carlo method

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

% Setting variables
load variables.mat

% Standard upfront is 0
if nargin<15
    X=0;
end

% Standard is closed formula
if nargin<14
    flag=1;
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
NPVb_nostop=dt(end)*fin_coupon*payment_discounts(end);


switch flag
    
    case 1 % closed formula
    alpha=1/2;
    LapExp=@(w) ttm/volofvol*(1-alpha)/alpha*(1-(1+(w*volofvol*sigma^2)/(1-alpha)).^alpha);
    tol=1e-16;
    phi= @(t) exp(-1i*t*LapExp(eta)).*exp(LapExp((t.^2+(1i)*(1+2*eta)*t)/2));
    k=log(F0/strike);
    f=@(x) real(exp(1i*k*x).*phi(x)./(1i*x));
    % Compute the probability of no stop
    p=1/2+1/pi*integral(f,0,Inf,"AbsTol",tol,"RelTol",tol);
    % Total discounted paymnents of party A
    NPVa=p*NPVa_nostop+(1-p)*NPVa_stop;
    % Total discounted paymnents of party B
    NPVb=X+p*NPVb_nostop+(1-p)*NPVb_stop;
    NPVa_sim=0;
    NPVb_sim=0;
    
    case 2 % Monte Carlo
    % Simulate S
    S=NIG_sim(Nsim,sigma,volofvol,eta,ttm,F0);
    OTM=(S<strike);
    NPVa_sim=OTM*NPVa_stop+(1-OTM)*NPVa_nostop;
    NPVb_sim=X+OTM*NPVb_stop+(1-OTM)*NPVb_nostop;
    % Total discounted payments of party A
    NPVa=mean(NPVa_sim);
    % Total discounted payments of party B
    NPVb=mean(NPVb_sim);

    case 3 % Monte Carlo antithetic variables
    [S,S_av] = NIG_sim_av(Nsim/2,sigma,volofvol,eta,ttm,F0);
    OTM=(S<strike);
    NPVa_sim=OTM*NPVa_stop+(1-OTM)*NPVa_nostop;
    NPVb_sim=X+OTM*NPVb_stop+(1-OTM)*NPVb_nostop;

    OTM_av=(S_av<strike);
    NPVa_sim_av=OTM_av*NPVa_stop+(1-OTM_av)*NPVa_nostop;
    NPVb_sim_av=X+OTM_av*NPVb_stop+(1-OTM_av)*NPVb_nostop;
    
    NPVa=mean((NPVa_sim+NPVa_sim_av)/2);
    NPVb=mean((NPVb_sim+NPVb_sim_av)/2);

    NPVa_sim=(NPVa_sim+NPVa_sim_av)/2;
    NPVb_sim=(NPVb_sim+NPVb_sim_av)/2;

    otherwise 
        error('undefined flag')

end

end % function NPVissue