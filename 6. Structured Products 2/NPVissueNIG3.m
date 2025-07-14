function [NPVa,NPVb,IC]=NPVissueNIG3(dates,discounts,Nsim,spol,coupon,sigma,eta,volofvol,strike,S0,div,payment_dates,X)

% Compute the Net Present Value of the three years structured issue with 
% the Monte Carlo method

% INPUT:
% dates: dates of IR curve
% discounts: IR curve
% Nsim: number of Monte Carlo simulations
% spol: spread over libor
% coupon: array of the coupons
% sigma: average volatility
% volofvol: volatility of the volatility
% eta: skew
% strike: strike
% F0: forward
% div: dividend
% payment_dates: dates of payment of the coupons
% X: upfront

% Settings variables
load variables.mat

% Default is X=0
if nargin<13
    X=0;
end

% Compute the discounts on the coupon payment dates
payment_discounts=interpB2(dates,discounts,payment_dates);
payment_dt=yearfrac(dates(1),payment_dates,EU30);

% Compute the year fractions between the payment dates 
dt=yearfrac([dates(1);payment_dates(1:end-1)],payment_dates,EU30);

% Compute the reset dates and the relative discounts
reset_date=daysb4(payment_dates(1:end-1),2);
B=interpB2(dates,discounts,reset_date);
B(2:end)=B(2:end)./B(1:end-1);
ttm=yearfrac([dates(1);reset_date(1:end-1)],reset_date,Act365);

% Compute the forward at reset date
F0 = S0*exp(-ttm(1)*div)/B(1);

l=length(payment_dates);
NPVa_wip=zeros(l,1);
NPVb_wip=zeros(l,1);

swap_dates=businessdates(datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:24)');
NPVa_wip(1)=NPVfloater(dates,discounts,spol,swap_dates);
NPVa_wip(2)=NPVa_wip(1);
NPVa_wip(3)=NPVa_wip(2);

swap_dates=businessdates(datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:36)');
NPVa_wip(4)=NPVfloater(dates,discounts,spol,swap_dates);

% NPVb for the four cases (stated in report)
NPVb_wip(1)=dt(1)*coupon(1)*payment_discounts(1)+dt(2)*coupon(2)*payment_discounts(2);
NPVb_wip(2)=dt(1)*coupon(1)*payment_discounts(1);
NPVb_wip(3)=dt(2)*coupon(2)*payment_discounts(2);
NPVb_wip(4)=dt(3)*coupon(3)*payment_discounts(3);

% Simulation of the underlying at reset dates
S=NIG_sim2(Nsim,sigma,volofvol,eta,ttm,F0,B,div);

% Check that the underlying is below the strike at reset dates
check=S<strike;

% Matrix of the simulations, one column for each case
P=zeros(Nsim,length(NPVb_wip));
P(:,1)=(check(:,1).*check(:,2));    %% 1 1
P(:,2)=(check(:,1).*~check(:,2));   %% 1 0
P(:,3)=(~check(:,1).*check(:,2));   %% 0 1
P(:,4)=(~check(:,1).*~check(:,2));  %% 0 0

NPVa_sim=P*NPVa_wip;
NPVb_sim=X+P*NPVb_wip;

NPVa=mean(NPVa_sim);
NPVb=mean(NPVb_sim);

% Confidence interval
[~,~,IC]=normfit(NPVa_sim-NPVb_sim);

end