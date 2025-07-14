function [F] = NIG_sim(Nsim,sigma,k,eta,ttm,F0)

% Compute the value of the forward underlying considering a Normal Inverse
% Gaussian model and a Monte Carlo method

% INPUT:
% Nsim: number of Monte Carlo simultions
% sigma: average volatility
% volofvol: volatility of the volatility
% eta: skew
% ttm: time to maturity
% F0: price of the forward at time t0

% Compute value of the Laplace transform
LapExp=@(w) ttm/k*(1-sqrt(1+2*k*w*sigma^2));

% Simulate random components
g=randn(Nsim,1);
G=random('InverseGaussian',1,ttm/k,Nsim,1);

% Compute stock value
sim=sqrt(ttm)*sigma*sqrt(G).*g-(1/2+eta)*ttm*sigma^2*G-LapExp(eta);

% Compute value
F = F0*exp(sim);

end % function NIG_sim