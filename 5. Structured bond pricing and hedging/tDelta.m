function [tDelta_sp,tDelta_cap,tDelta_swap]=tDelta(datesSet,ratesSet,strike,y,vol,cap_strike,ttm,dates_float,cap,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt,X,NPV0)

% Compute the sensitivity of one cap and of one swap changing of one basis 
% point the rate of every instrument used to compute the IR  curve (all togheter)

% INPUT:
% datesSet: struct of dates
%   datesSet.depos: expiry dates of the deposits
%   datesSet.futures: matrix with settlement dates of the futures in the
%       first column and expiry dates of the futures in the second column
%   datesSet.swaps: expiry dates of the swaps
%   datesSet.settlemnt: settlement date
% ratesSet: struct of rates
%   ratesSet.depos: bid and ask rates of deposits
%   ratesSet.futures: bid and ask rates of futures at expiry date
%   ratesSet.swaps: bid and ask rates of swaps
% strike: strikes (table of flat volatitilies)
% y: years
% vol: flat volatilities
% K: strikes (caplets of structured product)
% ttm: expiry of the cap
% dates_float: dates of payment of the floating leg of the swap
% cap: Net Present Value of the cap
% K: strikes (caplets of structured product)
% s_spol_A: spread of part A
% s_spol_B: spread of part B
% caplet1: percentage of (extra) caplet at three months
% floating_dates: dates of payement of the floating leg
% dt360: delta (Act/360)
% X: price (paid by part B)
% NPV0: Net Present Value structured product

% If cap is omitted, let's consider it zero
if nargin<17
    NPV0=0;
end

% Setting variables
load variables.mat

% Compute mid rates of the swaps of the expiry date
S_swap=(ratesSet.swaps(ttm,1)+ratesSet.swaps(ttm,2))/2;

% Increase rates
ratesSet.depos(:,:)=ratesSet.depos(:,:)+1e-4;
ratesSet.futures(:,:)=ratesSet.futures(:,:)+1e-4;
ratesSet.swaps(:,:)=ratesSet.swaps(:,:)+1e-4;

% Compute new IR curve
[dates, discounts]=bootstrap(datesSet, ratesSet);

% Compute spot volatilities with new IR curve
spot_vol=spotvol(vol,y,strike,dates,discounts,floating_dates,dt);

% Compute the structured product sensitivity
[NPVa,NPVb]=NPVstructure(dates,discounts,spot_vol,strike,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt,X);
tDelta_sp=NPVb-NPVa-NPV0;

% Compute the swap sensitivity
[NPVa,NPVb]=NPVswap(dates,discounts,ttm,floating_dates);
tDelta_swap=NPVa-S_swap*NPVb;

% Compute the discount in the floating dates interpolating
disc_float=interpB2(dates,discounts,dates_float);

% Compute forward discount and forward libor
fwd_disc=disc_float./[1;disc_float(1:end-1)];
libor = (1./fwd_disc-1)./dt(1:4*ttm);

% Get volatilities of requested strike interpolating
sigma=interp1(strike,spot_vol(2:ttm*4,:)',cap_strike,'spline')';

% Compute the cap sensitivity
cap2=sum(capletBach(disc_float(1:ttm*4),dates_float(1:ttm*4),libor(2:end),cap_strike,sigma,dates(1),dt(2:ttm*4)));
tDelta_cap=cap2-cap;

end % function tDelta