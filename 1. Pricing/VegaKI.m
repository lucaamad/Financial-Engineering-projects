function vega = VegaKI(F0,K,KI,B,T,sigma,N,flagNum)

%European barrier option price with closed formula
%
%INPUT
% F0:    forward price
% K:     strike
% KI:    barrier
% B:     discount factor
% T:     time-to-maturity
% sigma: volatility
% flagNum: 1 CRR 2 MonteCarlo 3 closed formula

% Setting central difference step
h=sigma/100;

% Inizializing arrays
l=length(F0);
vega=zeros(1,l);

if flagNum == 1

    for ii=1:l
        % Calculate price for the ii-th forward value with CRR tree, for
        % sigma plus the central diffrence step and sigma minus the central
        % difference step
        priceCRRup=EuropeanOptionKIPrice(F0(ii),K,KI,B,T,sigma+h,2,N);
        priceCRRdown=EuropeanOptionKIPrice(F0(ii),K,KI,B,T,sigma-h,2,N);
        % Calculate derivative wrt sigma with central difference method
        vega(ii)=(priceCRRup-priceCRRdown);
    end

elseif flagNum == 2

    for ii=1:l
        % Calculate price for the ii-th forward value with Monte Carlo 
        % method, for sigma plus the central diffrence step and sigma minus
        % the central difference step
        priceMCup=EuropeanOptionKIPrice(F0(ii),K,KI,B,T,sigma+h,3,N);
        priceMCdown=EuropeanOptionKIPrice(F0(ii),K,KI,B,T,sigma-h,3,N);
        % Calculate derivative wrt sigma with central difference method
        vega(ii)=(priceMCup-priceMCdown);
    end
    
else
    
    % Calculate the vega for every forward value with the closed formula
    d1=log(F0./KI)/(sigma*sqrt(T))+sigma*sqrt(T)/2;
    d2=d1-sigma*sqrt(T);
    vega =2*h* B * (F0.*normpdf(d1).*(-log(F0./KI)/(sigma^2*sqrt(T))+sqrt(T)/2) ...
        -K*normpdf(d2).*(-log(F0./KI)/(sigma^2*sqrt(T))-sqrt(T)/2));

end

