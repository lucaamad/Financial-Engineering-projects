function [payoff, std_error] = couponMC(dividend, sigma, S0, weights, dates, discounts, mon_dates, P, Nsim)

% Compute the value of the coupon of the swap using Monte Carlo

% INPUT:
% dividend: column vector of underlyings' dividend yields
% sigma: variance-covariance matrix of the underlyings
% S0: value at t0 of the underlyings' stocks
% weights: column vector of weights of the underlyings
% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% mon_dates: column vector of monitoring dates in datenum format
% P: protection
% Nsim: number of Monte Carlo simulations

% Set the day-count convention
act365 = 3;

% Set the 2 dimensions of the 3-D random matrix we will use later
% (the third dimension is Nsim)
Nstocks = length(S0);
Ndates = length(mon_dates);

% Retreive a diagonal matrix with the two variances
variance = diag(sigma);

% Use Cholesky decomposition
A = chol(sigma)';

% Simulate a 3-D random matrix which represents the Brownian
% Motions related to each stock at each monitoring date for every
% MC simulation
W = pagemtimes(A,randn(Nstocks,Ndates,Nsim));

% Discounts at the monitoring dates
mon_discounts = interpB2(dates,discounts,mon_dates);
mon_discounts = [1; mon_discounts];

% Compute the forward discounts, starting from the bootstrapped discount
% factors, in the monitoring dates
fwd_discounts = mon_discounts(2:end)./mon_discounts(1:end-1);

% Compute the forward zero rates starting from the forward discount factors
dt = yearfrac([dates(1);mon_dates(1:end-1)],mon_dates,act365);
r = - log(fwd_discounts)./dt;

% Compute the drift term of the brownian motions
drift = r'.*ones(Nstocks,1); 
drift = drift-dividend-variance/2;
drift = drift.*(dt');

% The brownian motions should have variance t
W = pagemtimes(W,diag(sqrt(dt)));

% Compute the value of the exponential of the GBM dynamics of the 
% stocks at each time and for each simulation
St = exp(drift+W);

% Compute S(t) foe each simulation
St = pagemtimes(diag(weights),St);
S = sum(sum(St,1),2).*(1/Ndates);

% Transform a 3-D matrix (1,1,Nsim) in a (1,Nsim) vector
S = squeeze(S);

% Compute the payoff
payoff = sum(max(S-P,0))/Nsim;

% Standard error
std_error = std(max(S-P,0))/sqrt(Nsim);

end %function couponMC