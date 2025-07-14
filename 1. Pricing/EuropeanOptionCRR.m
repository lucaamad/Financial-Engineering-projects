function optionPrice=EuropeanOptionCRR(F0,K,B,T,sigma,N,flag) 

%European option price with CRR tree
%
%INPUT
% F0:    forward price
% K:     strike
% B:     discount factor
% T:     time-to-maturity
% sigma: volatility
% N:     tree steps
% flag:  1 call, -1 put

% Compute time to maturity zero rate
r=-log(B)/T;   

% Compute u,d,q parameters starting from Black's parameters
delta_t = T/N;
delta_x = sigma*sqrt(delta_t);
u = exp(delta_x);
d = u^-1;
q = (1-d)/(u-d);

% Compute payoffs at maturity
if flag == 1
    value = max(u.^(N:-2:-N) * F0 -K,0);
else
    value = max(K- u.^(N:-2:-N) * F0,0);
end


% "Climb" the tree discounting the values
for ii = 1 : N
        
    value=(q*value(1:N-ii+1) + (1-q) * value(2:N-ii+2))*exp(-r*delta_t);

    value(N-ii+2)=0;
end

optionPrice=value(1);

end % function EuropeanOptionCRR
