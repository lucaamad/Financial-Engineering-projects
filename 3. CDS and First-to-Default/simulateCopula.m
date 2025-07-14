function [u]=simulateCopula(mu,A)

% Simulate two gaussian copulas

%INPUT:
% mu: mean of the gaussian copula
% A: cholensky decomposition of the correlation matrix

% Simulate two standard normal
y=randn(2,1);

% Trasform the standard normal in the copula
x=mu+A'*y;

% Get the u from the copula
u=normcdf(x);

end % function simulateCopula