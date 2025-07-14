function optionPrice=EuropeanOptionKIPrice(F0,K,KI,B,T,sigma,pricingMode,N)

% European barrier option Price with different pricing methods
%
% INPUT:
% F0:    forward price
% B:     discount factor
% K:     strike
% KI:    barrier
% T:     time-to-maturity
% sigma: volatility
% pricingMode: 1 ClosedFormula, 2 CRR, 3 Monte Carlo
% N:     either number of time steps (knots for CRR tree)
%        or number of simulations in MC   


if (nargin < 7)
 N = 10000; % Default: N
end 


switch (pricingMode)
    case 1  % Closed Formula
        optionPrice = EuropeanOptionKIClosed(F0,K,KI,B,T,sigma);
    case 2  % CRR
        optionPrice = EuropeanOptionKICRR(F0,K,KI,B,T,sigma,N);
    case 3  % Monte Carlo
        optionPrice = EuropeanOptionKIMC(F0,K,KI,B,T,sigma,N);
    otherwise
end
return
end % function EuropeanOptionKIPrice