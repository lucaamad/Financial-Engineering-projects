%runAssignment6Group1
% Group 1, AY2023-2024
clear;
close all;
clc;

%% Settings
rng(42)
formatData='dd-mmm-yyyy'; 
load variables.mat
load cSelect20230131_B.mat

%% Read market data
% This fuction works on Windows OS. Pay attention on other OS.
[dates, discounts] = readExcelData2('MktData_CurveBootstrap', formatData);

%% NIG calibration
% Contract and underlying parameters
expiry = datenum(datetime(dates(1),'ConvertFrom','datenum')+calyears(1));
B = interpB2(dates,discounts,expiry);
alpha = 1/2;
T = yearfrac(dates(1), expiry, Act365);
S0 = cSelect.reference;
F0 = S0*exp(-T*cSelect.dividend)/B;
strikes = cSelect.strikes;
surf = cSelect.surface;

% NIG parameters calibration
[parameters, error, ~] = calibration(strikes, surf, B, T, F0, alpha);
sigma = parameters(1);
eta = parameters(2);
k = parameters(3);

%% Pricing upfront - NIG
% Contract parameters
spol=0.013;
coupon=0.06;
fin_coupon=0.02;
strike=3200;
payment_dates=datetime(dates(1),'ConvertFrom','datenum')+calyears(1:2)';
payment_dates=businessdates(payment_dates);
Nsim=1e6;

% Upfront computed with the exact formula (Lewis)
tic
[NPVa,NPVb,~,~]=NPVissue(dates,discounts,Nsim,spol,coupon,fin_coupon,sigma,eta,k,strike,S0,cSelect.dividend,payment_dates);
toc
X_lewis=NPVa-NPVb;

% Upfront computed with Monte Carlo
tic
[NPVa,NPVb,NPVa_sim,NPVb_sim]=NPVissue(dates,discounts,Nsim,spol,coupon,fin_coupon,sigma,eta,k,strike,S0,cSelect.dividend,payment_dates,2);
toc
X_MC=NPVa-NPVb;
% Confidence interval (95%)
[~,~,IC_MC]=normfit(NPVa_sim-NPVb_sim);

% Upfront computed with Monte Carlo - Antithetic Variables
tic
[NPVa,NPVb,NPVa_sim,NPVb_sim]=NPVissue(dates,discounts,Nsim,spol,coupon,fin_coupon,sigma,eta,k,strike,S0,cSelect.dividend,payment_dates,3);
toc
X_MC_av=NPVa-NPVb;
% Confidence interval (95%)
[~,~,IC_MC_av]=normfit(NPVa_sim-NPVb_sim);


%% Pricing upfront - Black
% Implied volatility 
imp_sigma = interp1(cSelect.strikes, cSelect.surface, strike, "spline");

% Upfront
[NPVa_k,NPVb_k]=NPVissueBlack(dates,discounts,spol,coupon,fin_coupon,strike,S0,cSelect.dividend,imp_sigma,payment_dates);
X_black=NPVa_k-NPVb_k;

%% Pricing upfront - Black error
% Closest points to strike in the strikes set
x1=find(strike>cSelect.strikes);
x1=x1(end);
x2=x1+1;

% Slope impact (with the approximation of the derivative wrt the strike)
m = (cSelect.surface(x2)-cSelect.surface(x1))/(cSelect.strikes(x2)-cSelect.strikes(x1));

% Upfront considering the digital risk
[NPVa_k,NPVb_k]=NPVissueBlack_digital(dates,discounts,spol,coupon,fin_coupon,strike,S0,cSelect.dividend,imp_sigma,payment_dates,m);
X_black_digital=NPVa_k-NPVb_k;

%% Pricing upfront with 3 years expiry - NIG
coupon=[0.06;0.06;0.02];
payment_dates=datetime(dates(1),'ConvertFrom','datenum')+calyears(1:3)';
payment_dates=businessdates(payment_dates);

% Upfront with Monte Carlo
[NPVa_three,NPVb_three,IC_MC_three]=NPVissueNIG3(dates,discounts,Nsim,spol,coupon,sigma,eta,k,strike,S0,cSelect.dividend,payment_dates);
X_three=NPVa_three-NPVb_three;

%% Tree
% Hull-White parameters
a=0.11;
sigma=0.008; 

strike=0.05;
dates_years=datetime(dates(1),'ConvertFrom','datenum')+calyears(0:10)';
dates_years=businessdates(dates_years);
nodes=1e3;

% Price of the Bermudan Swaption
bermudan=tree3(dates,discounts,strike,dates_years,a,sigma,nodes);

%% Plot of the Bermudan price varying the number of nodes
bermudan_price=zeros(9,1);
for ii=1:12
    nodes=2^(ii+2);
    bermudan_price(ii)=tree3(dates,discounts,strike,dates_years,a,sigma,nodes);
end
figure(3)
plot(3:14,(bermudan_price),"LineWidth",2)
hold on
plot(2:14,bermudan_price(end)*ones(13,1),'k','LineStyle','--','Linewidth',2)
grid on
set(gca,'FontSize',16)
xlabel('Nodes (log2)')
title('Bermudan Price')
hold off


%% Jamshidian
% Hull-White parameters
a=0.11;
sigma=0.008; 

% Expiry (T_alpha) for the whole set of co-terminal European swaptions
expiries=datetime(dates(1),'ConvertFrom','datenum')+calyears(2:9)';
expiries=businessdates(expiries);

% Maturity (T_omega)
maturity=datetime(dates(1),'ConvertFrom','datenum')+calyears(10);
maturity=businessdates(maturity);

% Price of the European Swaptions exploiting the Jamshidian formula
Jam=zeros(8,1);
for ii=1:8
    Jam(ii)=Jamshidian(dates,discounts,expiries(ii),maturity,strike,a,sigma);
end
%% Check tree
% Computation of the error between the tree price and the exact price
error=zeros(12,1);
EU_price=zeros(8,1);
for jj=1:12
    for ii=1:8
    EU_price(ii)=tree3(dates,discounts,strike,dates_years,a,sigma,2^(jj+2),1,ii+1);
    end
    % L1 distance
    error(jj)=sum(abs(Jam-EU_price));
end

%% Plot of the error
figure(4)
semilogy(3:14,error,3:14,2.^-(3:14),"linewidth",2)
grid on
set(gca,"FontSize",24)
title("L1 error between tree and Jamshidian")
legend("L1 error","1/n")

%% Compute lower and upper bound for the price of the Bermudan Swaption
lower_bound=max(Jam);
upper_bound=sum(Jam);
