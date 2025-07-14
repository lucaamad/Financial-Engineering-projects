function [price,IC] = NIG_MC(Nsim,sigma,volofvol,eta,ttm,F0,B,K)

% Compute the price of a european call considering a Normal Inverse
% Gaussian model and a Monte Carlo method

% INPUT:
% Nsim: number of Monte Carlo simultions
% sigma: average volatility
% volofvol: volatility of the volatility
% eta: skew
% ttm: time to maturity
% F0: price of the forward at time t0
% B: discount at the time to maturity
% K: strikes

% Compute value of the Laplace transform
LapExp=@(w) ttm/volofvol*(1-sqrt(1+2*volofvol*w*sigma^2));

% Simulate random components
g=randn(Nsim,1);
G=random('InverseGaussian',1,ttm/volofvol,Nsim,1);

% Compute stock value
sim=sqrt(ttm)*sigma*sqrt(G).*g-(1/2+eta)*ttm*sigma^2*G-LapExp(eta);

% Compute payoff
l = length(K);
mat_sim = repmat(sim, 1, l);
mat_K = repmat(K, 1, Nsim)';
payoff = max(F0*exp(mat_sim) - mat_K,0);

% Compute Monte Carlo price and confidence interval
[price, ~, IC] = normfit(B*payoff);

end % function NIG_MC