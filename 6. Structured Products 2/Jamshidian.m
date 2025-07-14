function price=Jamshidian(dates,discounts,expiry,maturity,strike,a,sigma)

% Compute the price of a European swaption using the Jamshidian closed
% formula

% INPUT:
% dates: dates of the IR curve
% discounts: IR curve
% expiry: date of exercise of the swaption
% maturity: maturity of the swap
% strike: swaption's strike
% a: parameter of Hull-White
% sigma: paratmeter of Hull-White

% Setting variables
load variables.mat

% Distance between t0 and the expiry of the swaption
Talfa=yearfrac(dates(1),expiry,Act365);

% T_i: coupon dates between T_alpha and T_omega (once a year), including
% T_omega
y=year(maturity)-year(expiry);
coupon_dates=datetime(expiry,"ConvertFrom","datenum")+calyears(1:y)';
coupon_dates=businessdates(coupon_dates);
deltai=yearfrac([expiry;coupon_dates(1:end-1)],coupon_dates,EU30);

% Discount factors at coupon dates
discountsi=interpB2(dates,discounts,coupon_dates);
% Discount factors at expiry
discountalfa=interpB2(dates,discounts,expiry);

% Coupons
c=strike*deltai;
c(end)=1+c(end);

% Forward discounts at coupon dates
forward=discountsi/discountalfa;

% Value of the integral in the exponential of Lemma 2 HJM
int=(sigma/a)^2*((1-exp(-a*cumsum(deltai))).*(1-exp(-a*Talfa))*2/a...
    -1/(2*a)*(1-exp(-2*a*cumsum(deltai))).*(1-exp(-2*a*Talfa)));

% sigma(0,T_i), where sigma (0,t) is the deterministic volatility of the
% Hull-White model
sigma0=sigma/a*(1-exp(-a*cumsum(deltai)));

% Computation of the strikes K_i 
f=@(x) sum(c.*forward.*exp(-x*sigma0/sigma-1/2*int))-1;
xstar=fzero(f,0);
ki=forward.*exp(-xstar*sigma0/sigma-1/2*int);

% Computation of the volatility inside the call on zcb formula
theta=cumsum(deltai);
v_squared=1/Talfa*(sigma/a)^2*(1-exp(-a*theta)).^2*1/(2*a)*(1-exp(-2*a*Talfa));
v=sqrt(v_squared);

d1=log(forward./ki)./(v*sqrt(Talfa))+1/2*v*sqrt(Talfa);
d2=log(forward./ki)./(v*sqrt(Talfa))-1/2*v*sqrt(Talfa);

% Call on coupon bond (Jamshidian)
coupon_call=discountalfa*sum(c.*(forward.*normcdf(d1)-ki.*normcdf(d2)));

% Put (Swaption) price with put-call parity
price=coupon_call-discountalfa*(sum(c.*forward)-1);

end % function Jamshidian