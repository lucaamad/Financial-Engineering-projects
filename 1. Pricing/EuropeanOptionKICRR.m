function optionPrice = EuropeanOptionKICRR(F0,K,KI,B,T,sigma,N)

%European barrier option price with CRR tree
%
%INPUT
% F0:    forward price
% K:     strike
% KI:    barrier
% B:     discount factor
% T:     time-to-maturity
% sigma: volatility
% N:     tree steps

% Compute time to maturity zero rate
r=-log(B)/T;

% Compute u,d,q parameters starting from Black's parameters
delta_t = T/N;
delta_x = sigma*sqrt(delta_t);
u = exp(delta_x);
d = u^-1;
q = (1-d)/(u-d);

% Compute payoffs at maturity
value = F0 * u.^(N:-2:-N);
value = (value-K).*(value>KI);


% "Climb" the tree discounting the values
for ii = 1 : N
    value=(q*value(1:N-ii+1) + (1-q) * value(2:N-ii+2))*exp(-r*delta_t);
   
    value(N-ii+2)=0;
end

optionPrice=value(1);

end % function EuropeanOptionKICRR
