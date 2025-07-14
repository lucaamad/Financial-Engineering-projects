function optionPrice = EuropeanOptionMC(F0,K,B,T,sigma,N,flag)

% European option price with Monte Carlo method

% INPUT:
% F0:    forward price
% B:     discount factor
% K:     strike
% T:     time-to-maturity
% sigma: volatility
% N:     number of Monte Carlo simulations  
% flag:  1 call, -1 put

g=randn(N,1);

if flag==1
    optionPrice=B*sum(max(F0*exp(-(sigma^2)/2*T+sigma*sqrt(T)*g)-K,0))/N;
else
    optionPrice=B*sum(K-max(F0*exp(-(sigma^2)/2*T+sigma*sqrt(T)*g),0))/N;
end

end %function EuropeanOptionMC