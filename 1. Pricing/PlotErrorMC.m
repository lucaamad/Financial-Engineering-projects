function [M,stdEstim]=PlotErrorMC(F0,K,B,TTM,sigma)

% Compute the error of the Monte Carlo price of a European call option, 
% varying the number of simulations from 2^1 to 2^20

% INPUT:
% F0:    forward price
% B:     discount factor
% K:     strike
% TTM:     time-to-maturity
% sigma: volatility

% Inizialize array
stdEstim=zeros(1,20);

% Array of number of simulations
M=2.^(1:20);

for m=1:20

    % Compute the standard error i.e. the ratio of standard deviation and
    % the square root of the number of simulation
    g=randn(M(m),1);
    stdEstim(m)=std(B*max(F0*exp(-(sigma^2)/2*TTM+sigma*sqrt(TTM)*g)-K,0))/sqrt(M(m));
    
end

end % function PlotErrorMC