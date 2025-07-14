function [NPVa,NPVb]=NPVstructure(dates,discounts,spot_vol,strike,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt,X)

% Compute the NPV of both parts of the structured instrument

% INPUT:
% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% spot_vol: matrix of spot volatilities
% strike: strikes
% s_spol_A: spread of part A
% s_spol_B: spread of part B
% caplet1: percentage of (extra) caplet at three months
% X: price (paid by part B)
% floating dates: dates of payment of the floatin leg
% dt: deltas (Act/360)

% If X is omitted, let's consider it zero (we use the function to compute it)
if nargin<11
    X=0;
end

% Setting variables
load variables.mat

% Divide dates in the sets of the three caps
dates1=floating_dates(1:20);
dates2=floating_dates(20:40);
dates3=floating_dates(40:60);

% Compute discounts
discounts1=interpB2(dates,discounts,dates1);
discounts2=interpB2(dates,discounts,dates2);
discounts3=interpB2(dates,discounts,dates3);

% Compute forward disocunt
fwd_disc1=discounts1./[1;discounts1(1:end-1)];
fwd_disc2=discounts2./[1;discounts2(1:end-1)];
fwd_disc3=discounts3./[1;discounts3(1:end-1)];

% Compute forward libor
libor1 = (1./fwd_disc1-1)./dt(1:20);
libor2 = (1./fwd_disc2-1)./dt(20:40);
libor3 = (1./fwd_disc3-1)./dt(40:60);

% Get volatilities of requested strike interpolating
sigma1=interp1(strike,spot_vol(2:20,:)',K(1),'spline')';
sigma2=interp1(strike,spot_vol(21:40,:)',K(2),'spline')';
sigma3=interp1(strike,spot_vol(41:60,:)',K(3),'spline')';

% Compute the NPV of the spread paid by part B
NPV2=NPVspread(dates,discounts,s_spol_B,floating_dates(2:end));

% Compute the discounted value of the three months (extra) caplet
disc_caplet1=(caplet1-s_spol_B)*discounts1(1)*dt(1);

% Compute the discounted value of the three months libor
first_libor=libor1(1)*discounts1(1)*dt(1);

% Compute the discounted value of the three caps
cap1=sum(capletBach(discounts1,dates1,libor1(2:end),K(1),sigma1,dates(1),dt(2:20)));
cap2=sum(capletBach(discounts2,dates2,libor2(2:end),K(2),sigma2,dates(1),dt(21:40)));
cap3=sum(capletBach(discounts3,dates3,libor3(2:end),K(3),sigma3,dates(1),dt(41:60)));

% Compute NPV for part A and for part B
NPVa = NPVspread(dates,discounts,s_spol_A,floating_dates)+first_libor;
NPVb = X+NPV2+disc_caplet1-cap1-cap2-cap3;

end % function NPVstructure