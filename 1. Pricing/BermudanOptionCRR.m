function optionPrice=BermudanOptionCRR(F0,K,B,T,sigma,N,flag,dividend) 

%Bermudan option price with CRR tree
%
%INPUT
% F0:    forward price
% K:     strike
% B:     discount factor
% T:     time-to-maturity
% sigma: volatility
% N:     tree steps
% flag:  1 call, -1 put
% dividend: dividend yield

% Adjusting N on the basis of the time to maturity to have a knot in every
% moment you could exercise
months=T*12; 
if mod(N,months)~=0
    N=N+months-mod(N,months);
end

% Compute time to maturity zero rate
r=-log(B)/T;

% Select the knot where you can exercise i.e. every month
N_m=N/months;
exercise = N_m+1:N_m:N;

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

% "Climb" the tree
for ii = 1 : N

    % Check if it's an exercise knot
    if ismember(ii,exercise)
        if flag==1 % Compute intrinsic value exploiting G&K's formula
            iv=max(F0*u.^(N-ii+1:-2:-(N-ii+1))./exp((r-dividend)*(T-delta_t*(ii-1)))-K,0);
        else
            iv=max(K-F0*u.^(N-ii+1:-2:-(N-ii+1))./exp((r-dividend)*(T-delta_t*(ii-1))),0);
        end

        % Compute continuation value and compare with intrinsic value
        value=(q*value(1:N-ii+1) + (1-q) * value(2:N-ii+2))*exp(-r*delta_t);
        value(1:N-ii+1)=max(value(1:N-ii+1),iv(1:N-ii+1));

    else    % Compute continuation value if it isn't an exercise knot
        value=(q*value(1:N-ii+1) + (1-q) * value(2:N-ii+2))*exp(-r*delta_t);
    end

    value(N-ii+2)=0;
end

optionPrice=value(1);

end % function BermudanOptionCRR
