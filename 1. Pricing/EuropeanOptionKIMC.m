function optionPrice = EuropeanOptionKIMC(F0,K,KI,B,T,sigma,N)

%European barrier option price with Monte Carlo method
%
%INPUT
% F0:    forward price
% K:     strike
% KI:    barrier
% B:     discount factor
% T:     time-to-maturity
% sigma: volatility
% N:     Monte Carlo simulations


% Monte Carlo simulations of the underlying
g=randn(N,1);
under=F0*exp(-(sigma^2)/2*T+sigma*sqrt(T)*g);

% Compute option price
optionPrice = B * sum((under-K).*(under>KI))/N;

end % function EuropeanOptionKIMC