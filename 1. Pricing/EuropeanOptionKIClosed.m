function optionPrice = EuropeanOptionKIClosed(F0,K,KI,B,T,sigma)

%European barrier option price with closed formula
%
%INPUT
% F0:    forward price
% K:     strike
% KI:    barrier
% B:     discount factor
% T:     time-to-maturity
% sigma: volatility

d2=log(F0/KI)/(sigma*sqrt(T))-sigma*sqrt(T)/2;
d1=d2+sigma*sqrt(T);
optionPrice = B * (F0*normcdf(d1)-K*normcdf(d2));

end %function EuropeanOptionKIClosed
