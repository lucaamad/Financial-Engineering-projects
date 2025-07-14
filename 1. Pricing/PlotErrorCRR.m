function [M,errCRR]=PlotErrorCRR(F0,K,B,TTM,sigma)

% Compute the error of the CRR tree price of a European call option, 
% varying the number of steps from 2^1 to 2^10

% INPUT:
% F0:    forward price
% B:     discount factor
% K:     strike
% TTM:     time-to-maturity
% sigma: volatility

% Compute price with closed formula
exact=EuropeanOptionPrice(F0,K,B,TTM,sigma,1);

% Inizialize array
errCRR=zeros(1,10);

% Array of number of steps
M=2.^(1:10);

for m=1:10
    % Compute the CRR tree price
    value=EuropeanOptionPrice(F0,K,B,TTM,sigma,2,M(m));
    
    % Compute the error as absolute value of the difference between the
    % Black formula price and the CRR tree price
    errCRR(m)=abs(exact-value);
    
end

end % function PlotErrorCRR
