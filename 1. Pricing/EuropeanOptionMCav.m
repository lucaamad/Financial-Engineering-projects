function optionPrice = EuropeanOptionMCav(F0,K,B,T,sigma,N,flag)

% European option price with Monte Carlo with antithetic variables
% technique

% INPUT:
% F0:    forward price
% B:     discount factor
% K:     strike
% T:     time-to-maturity
% sigma: volatility
% N:     number of MonteCarlo simulations  
% flag:  1 call, -1 put

g=randn(N/2,1);

if flag==1
    f1=B*sum(max(F0*exp(-(sigma^2)/2*T+sigma*sqrt(T)*g)-K,0))/N;
    f2=B*sum(max(F0*exp(-(sigma^2)/2*T+sigma*sqrt(T)*-g)-K,0))/N;
    optionPrice=(f1+f2)/2;
else
    f1=B*sum(K-max(F0*exp(-(sigma^2)/2*T+sigma*sqrt(T)*g),0))/N;
    f2=B*sum(K-max(F0*exp(-(sigma^2)/2*T+sigma*sqrt(T)*-g),0))/N;
    optionPrice=(f1+f2)/2;
end

end %function EuropeanOptionMCav