function [NPVa,NPVb]=NPVissue3(dates,discounts,spol,coupon,sigma,eta,volofvol,strike,F0,div,payment_dates,X)

% INPUT:
% dates: dates of IR curve
% discounts: IR curve
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

load variables.mat

if nargin<13
    X=0;
end

payment_discounts=interpB2(dates,discounts,payment_dates);
payment_dt=yearfrac(dates(1),payment_dates,EU30);

reset_date=daysb4(payment_dates(1:end-1),2);
B=interpB2(dates,discounts,reset_date);
ttm=yearfrac(dates(1),reset_date,Act365);
alpha=1/2;

l=length(payment_dates);
NPVa_wip=zeros(1,l);
NPVb_wip=zeros(1,l);
p=zeros(l-1,1);
% swap_dates=zeros(floor(payment_dt(end)*4),l);

for ii=1:l
    % swap_dates(1:floor(4*payment_dt(ii)),ii)=businessdates(datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:payment_dt(ii)*12)');
    swap_dates=businessdates(datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:payment_dt(ii)*12)');
    NPVa_wip(ii)=NPVfloater(dates,discounts,spol,swap_dates);
    NPVb_wip(ii)=coupon(ii)*payment_discounts(ii);
end

for jj=1:l-1
    LapExp=@(w) ttm(jj)/volofvol*(1-alpha)/alpha*(1-(1+(w*volofvol*sigma^2)/(1-alpha)).^alpha);
    tol=1e-16;
    phi= @(t) exp(-1i*t*LapExp(eta)).*exp(LapExp((t.^2+(1i)*(1+2*eta)*t)/2));
    S = F0/B(jj) * exp(-div*ttm(jj));
    k=log(S/strike)+(-div)*ttm(jj)-log(B(jj));
    f=@(x) real(exp(1i*k*x).*phi(x)./(1i*x));
    p(jj)=1/2+1/pi*integral(f,0,Inf,"AbsTol",tol,"RelTol",tol);
end
    
    prob=[1;cumprod(p)].*[(1-p);1];
    


    NPVa=NPVa_wip*prob;
    NPVb=X+NPVb_wip*prob;

end