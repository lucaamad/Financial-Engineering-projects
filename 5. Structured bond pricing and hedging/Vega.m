function vega=Vega(dates,discounts,strike,y,vol,K,s_spol_A,s_spol_B,caplet1,X,floating_dates,dt,NPV0)

% Compute the sensitivity of the structured product changing of one basis
% point the flat volatilities (all togheter)

% INPUT:
% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% strike: strikes (table of flat volatitilies)
% y: years
% vol: flat volatilities
% K: strikes (caplets of structured product)
% s_spol_A: spread of part A
% s_spol_B: spread of part B
% caplet1: percentage of (extra) caplet at three months
% X: price (paid by part B)
% floating_dates: dates of payment of the floating leg
% dt: deltas (Act/360)
% NPV0: Net Present Value of the structured product

% If NPV0 is omitted, let's consider it zero
if nargin<13
    NPV0=0;
end

% Increase flat volatilities
vol=vol+1e-4;

% Compute new spot volatilities
spot_vol=spotvol(vol,y,strike,dates,discounts,floating_dates,dt);

% Compute NPV with new spot volatilities
[NPVa,NPVb]=NPVstructure(dates,discounts,spot_vol,strike,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt,X);
vega=NPVa-NPVb-NPV0;

end % function Vega