% Assignment_1
% Group 1, AA2023-2024

clear
close all
clc


%% Pricing parameters
S0=1;           % Underlying price
K=1;            % Strike price
r=0.03;         % Time to maurity zero rate
TTM=1/4;        % Time to maturity
sigma=0.22;     % Volatility
flag=1;         % Flag:  1 call, -1 put
d=0.06;         % Dividend yield
%% Quantity of interest

B=exp(-r*TTM); % Discount factor

%% Pricing 
F0=S0*exp(-d*TTM)/B;     % Forward in G&K Model
M=100;                   % Steps in CRR and Monte Carlo simulations
optionPrice=zeros(3,1);  % Array with call price, computated with different methods

for pricingMode = 1:3    % 1 ClosedFormula, 2 CRR, 3 Monte Carlo
    optionPrice(pricingMode) = EuropeanOptionPrice(F0,K,B,TTM,sigma,pricingMode,M,flag);
end

fprintf('The European Call price, by Black Formula is %f\n\n',optionPrice(1));
fprintf('The European Call price, by CRR tree is %f\n\n',optionPrice(2));
fprintf('The European Call price, by Monte Carlo method is %f\n\n',optionPrice(3));

%% Errors Rescaling 

% Plot Errors for CRR varing number of steps
[MCRR,errCRR]=PlotErrorCRR(F0,K,B,TTM,sigma);

% Plot Errors for MC varing number of simulations 
[MMC,stdEstim]=PlotErrorMC(F0,K,B,TTM,sigma); 

figure(1) 

% plot CRR error and compare with 1/M, M is the length of the step
subplot(1,2,1) 
loglog(MCRR,errCRR,MCRR,1./MCRR,'linewidth',2)
grid on
legend('CRR','1/M')
title('CRR')
xlabel('M')
ylabel('CRR error')

% plot Monte Carlo error and compare with 1/sqrt(M), M is the length of the step
subplot(1,2,2) 
loglog(MMC,stdEstim,MMC,1./sqrt(MMC),'linewidth',2)
grid on
legend('Monte Carlo','1/sqrt(M)')
title('Monte Carlo')
xlabel('M')
ylabel('MC error')

%% European barrier option

KI=1.3;          % European Barrier

% Compute the price of the European barrier call with the closed formula
optionPrice = EuropeanOptionKIPrice(F0,K,KI,B,TTM,sigma,1);
fprintf('The European barrier Call price, by closed formula is %f\n\n',optionPrice);

% Compute the price of the European barrier call with the CRR tree and 1e3 steps
optionPrice = EuropeanOptionKIPrice(F0,K,KI,B,TTM,sigma,2,1e3);
fprintf('The European barrier Call price, by CRR tree is %f\n\n',optionPrice);

% Compute the price of the European barrier call with the Monte Carlo
% method and 1e5 simulations
optionPrice = EuropeanOptionKIPrice(F0,K,KI,B,TTM,sigma,3,1e5);
fprintf('The European barrier Call price, by Monte Carlo method is %f\n\n',optionPrice);

%% European barrier option vega
S00=0.7:0.01:1.5; % Array of Underlying prices
F00=S00*exp(-d*TTM)/B;  % Array of Forward

% Compute the Vega with the closed formula for every value of the forward
vegaex = VegaKI(F00,K,KI,B,TTM,sigma,M,3);

% Compute the Vega with the central difference of the CRR tree price for
% every value of the forward
vegaCRR = VegaKI(F00,K,KI,B,TTM,sigma,1e3,1);

% Compute the Vega with the central difference of the Monte Carlo price for
% every value of the forward
vegaMC = VegaKI(F00,K,KI,B,TTM,sigma,1e5,2);

% Plot the three Vega with respect to underlying prices
figure (3)
plot(S00,vegaex,S00,vegaCRR,S00,vegaMC,'linewidth',2)
legend('Closed formula','CRR','Monte Carlo')
grid on
title('Vega')
xlabel('Underlying')
ylabel('Currency')

%% Antithetic

% Plot Errors for MC varing number of simulations and using antithetic
% variables technique

[MMCav,stdEstimav]=PlotErrorMCav(F0,K,B,TTM,sigma); 

% Plot Monte Carlo with antithetic variables error and compare with Monte 
% Carlo error and 1/sqrt(M), M is the length of the step
figure(4)
loglog(MMCav,stdEstimav,MMC,stdEstim,MMC,1./sqrt(MMC),'linewidth',2)
grid on
legend('Monte Carlo with antithetic variables error','Monte Carlo error','1/sqrt(M)')
title('Monte Carlo with antithetic variables vs Monte Carlo')
xlabel('M')
ylabel('error')

%% Bermudan

% Compute the price of the Bermudan call with the CRR tree and 1e2 steps
optionPrice=BermudanOptionCRR(F0,K,B,TTM,sigma,1e3,1,d);
fprintf('The Bermudan Call price, by CRR tree is %f\n\n',optionPrice);

%% Bermudan variation

dy = 0:0.0001:0.06; % Array of dividend yield
flag=1; % 1 call -1 put


% Inizializing arrays
prices = zeros(length(dy),1);
EUprices = prices;

for ii=1:length(dy)
    
    % Compute Bermudan CRR tree, European CRR tree and European black
    % formula prices for every dividend yield
    F0=S0*exp(-dy(ii)*TTM)/B; 
    prices(ii)=BermudanOptionCRR(F0,K,B,TTM,sigma,1e3,flag,dy(ii));
    EUprices(ii) = EuropeanOptionPrice(F0,K,B,TTM,sigma,1,1e2,flag);

end

% Plot the three prices wrt the dividen yield
figure(5)
plot(dy,prices,dy,EUprices,'linewidth',2)
legend('Bermudan option','EU option')
grid on
xlabel('Dividend yields')
ylabel('Price')


