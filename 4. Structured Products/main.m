% runAssignment5
% Group 1, AY2023-2024
clear;
close all;
clc;

% Check if the Parallel Computing Toolbox is installed, and if the GPU
% works
toolboxes={ver().Name};
gpu=ismember('Parallel Computing Toolbox',toolboxes)&&canUseGPU();

%% Settings

formatData='dd-mmm-yyyy'; 
SwapDayCount=6;

%% Read market data
% This fuction works on Windows OS. Pay attention on other OS.
[dates, discounts] = readExcelData2('MktData_CurveBootstrap', formatData);

%% Exercise 1
% Setting the datas
rng(42);
s_spol = 100*1e-4;
X = 0.02;
notional = 100*1e6;
P = 0.95;
weights = [0.5, 0.5];
S0 = [100; 200];
sigma1 = 0.161;
sigma2 = 0.2;
rho = 0.4;
sigma = [sigma1^2, rho*sigma1*sigma2; rho*sigma1*sigma2, sigma2^2];
dividend = [0.025; 0.027];
Nsim = 1e6;

% Monitoring and floater dates
mon_dates=datetime(dates(1),'ConvertFrom','datenum')+calyears(1:4)';
mon_dates=businessdates(mon_dates);
floating_dates=datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:48)';
floating_dates=businessdates(floating_dates);

% Compute payoff of the coupon with Monte Carlo
%[payoff, std_error] = couponMC(dividend,sigma,S0,weights,dates,discounts,mon_dates,P,Nsim);
[payoff, std_error] = couponMC_av(dividend,sigma,S0,weights,dates,discounts,mon_dates,P,Nsim/2);

% Compute Net Present Value of the floater
NPV=NPVfloater(dates,discounts,s_spol,floating_dates);

% Compute discount factor at the end date
B_end = interpB2(dates,discounts,floating_dates(end));

% Compute discounted protection
protection=(1-P)*B_end;

% Compute partecipation value
alfa=(NPV-X+protection)/(payoff*B_end);

% Compute Monte Carlo interval of confidence
confidence_level = 1 - 0.05/2;
df = Nsim - 1;
IC = [alfa - tinv(confidence_level, df)*std_error, alfa + tinv(confidence_level, df)*std_error];

%% Exercise 2
load('cSelect20230131_B.mat');
act365 = 3;
N=10*1e6; % Notional

% Contract and underlying parameters
expiry = datenum(datetime(dates(1),'ConvertFrom','datenum')+calyears(1));
B = interpB2(dates,discounts,expiry);
T = yearfrac(dates(1), expiry, act365);
S0 = cSelect.reference;
F0 = S0*exp(-T*cSelect.dividend)/B; % G&K formula
K = S0; % since the digital is ATM-spot

% The volatility is taken from the surface using interpolation
sigma = interp1(cSelect.strikes, cSelect.surface, K, "spline");

% Black '76 formula for digital options
d1 = log(F0/K)/(sqrt(T)*sigma) + 0.5*sqrt(T)*sigma;
d2 = log(F0/K)/(sqrt(T)*sigma) - 0.5*sqrt(T)*sigma;
price_B = B*normcdf(d2)*N*0.05;

% Closest points to K in the strikes set
x1=find(K>cSelect.strikes);
x1=x1(end);
x2=x1+1;

% Slope impact (with the approximation of the derivative wrt K)
m = (cSelect.surface(x2)-cSelect.surface(x1))/(cSelect.strikes(x2)-cSelect.strikes(x1));

% Vega of a call (Black formula)
vega = B*F0*sqrt(T)*exp(-d1^2/2)/sqrt(2*pi);

% Price with the implied volatility approach
price_impv = price_B - N*0.05*m*vega;


%% Plot of the volatility surface
figure(1)
plot(cSelect.strikes, cSelect.surface, 'LineWidth',2,'Color','#dc143c')
title('S&P500 volatility surface','FontSize', 22)
xlabel('Strikes','FontSize', 22)
ylabel('Volatilities','FontSize', 22)
set(gca, 'FontSize', 16);
grid on

%% Exercise 3
load('cSelect20230131_B.mat');
act365 = 3;

% Contract and underlying parameters
expiry = datenum(datetime(dates(1),'ConvertFrom','datenum')+calyears(1));
B = interpB2(dates,discounts,expiry);
T = yearfrac(dates(1), expiry, act365);
S0 = cSelect.reference;
F0 = S0*exp(-T*cSelect.dividend)/B;

% Model parameters
sigma = 0.2;
eta=3;
volofvol=1;
alpha=1/2;

% Choose parameters for Fast Fourier Transform
M = 14;
parameter=-400;
flag=1;

% Choose parameter for the quadrature
logmoneyness=(-0.25:1e-4:0.25)';
thresold=1e-16;

% Compute the price of a european call using the Lewis formula and
% approximating the integral with a fast Fourier transform
if gpu
    [priceFFT,z]=LewisFFTgpu(B,F0,alpha,eta,sigma,volofvol,T,M,parameter,flag);
else
    [priceFFT,z]=LewisFFT(B,F0,alpha,eta,sigma,volofvol,T,M,parameter,flag);
end

% Compute the price of a european call using the Lewis formula and
% approximating the integral with global adaptive quadrature
[priceQ]=LewisQuad(B,F0,alpha,eta,sigma,volofvol,T,logmoneyness,thresold);

% Compute the price of a european call using Monte Carlo method
Nsim = 1e5;
K=F0*exp(-logmoneyness);
[priceMC, IC] =NIG_MC(Nsim,sigma,volofvol,eta,T,F0,B,K);

% plot FFT, quadrature and Monte Carlo
close (figure(2))
figure(2) 
plot(logmoneyness,priceQ,'LineWidth',2)
hold on
plot(z,priceFFT,'LineWidth',2)
plot(logmoneyness,priceMC,'LineWidth',2)
xlim([-0.25,0.25])
grid on
legend('Quadrature','FFT','Monte Carlo','location','northwest')
set(gca, 'FontSize', 16);
title('Lewis Call, alpha=1/2')
xlabel('logmoneyness')
ylabel('price')

% plot Monte Carlo with confidence interval
figure(3)
plot(logmoneyness,priceMC,'r')
hold on

grid on
set(gca, 'FontSize', 16);
title('Monte Carlo price with confidence interval')
xlabel('logmoneyness')
ylabel('price')
plot(logmoneyness, IC(1,:),'--','Color','b')
plot(logmoneyness, IC(2,:),'--','Color','b')

%% Exercise 3 - version 2
% Model parameters
alpha2=2/3;

% Compute the price of a european call using the Lewis formula and
% approximating the integral with a fast Fourier transform
if gpu
[priceFFT2,z]=LewisFFTgpu(B,F0,alpha2,eta,sigma,volofvol,T,M,parameter,1);
else
[priceFFT2,z]=LewisFFT(B,F0,alpha2,eta,sigma,volofvol,T,M,parameter,1);
end

% Compute the price of a european call using the Lewis formula and
% approximating the integral with global adaptive quadrature
[priceQ2]=LewisQuad(B,F0,alpha2,eta,sigma,volofvol,T,logmoneyness,thresold);

% plot FFT and quadrature
close (figure(4))
figure(4)
plot(logmoneyness,priceQ2,'LineWidth',2)
hold on
plot(z,priceFFT2,'LineWidth',2)
xlim([-0.25,0.25])
title('Lewis Call, alpha=2/3')
xlabel('logmoneyness')
set(gca, 'FontSize', 16);
ylabel('price')
grid on
legend('Quadrature','FFT','location','northwest')

%% Exercise 3 - check NIG moments

% Choose values to check
s1=3;
s2=8;

% Inizialize array
nsim=10.^(s1:s2);
moment1=zeros(s2-s1+1,1);
moment2=zeros(s2-s1+1,1);

% Simulate Inverse Gaussian and compute mean and variance
for s=1:(s2-s1+1)
    G=random('InverseGaussian',1,T/volofvol,nsim(s),1);
    moment1(s)=mean(G);
    moment2(s)=var(G);
end

% Plot theoretical and empirical mean and variance of Inverse Gaussin
% simulations
figure(5)
subplot(1,2,1)
semilogx(nsim,moment1,'LineWidth',2)
xlabel('Simulations')
ylabel('Mean')
grid on
yline(1,'-','Expected Value');

subplot(1,2,2)
semilogx(nsim,moment2,'LineWidth',2)
xlabel('Simulations')
ylabel('Variance')
grid on
yline(volofvol/T,'-','Theoretical variance');

sgtitle('Mean and variance by number of Monte Carlo simulations')

%% Exercise 3 - compute optimal M

% Values to check
n=25;
error=zeros(n,1);
parameter=-500;
thresold=1e-16;

for M=1:n
   % Compute the price of a european call using the Lewis formula and
   % approximating the integral with a fast Fourier transform
   if gpu
   [priceFFT,z]=LewisFFTgpu(B,F0,alpha,eta,sigma,volofvol,T,M,parameter,1);
   else
   [priceFFT,z]=LewisFFT(B,F0,alpha,eta,sigma,volofvol,T,M,parameter,1);
   end
   
   % Select interval of interest (in which check the error)
   if z(1)<-0.25
    z1=find(z<-0.25);
    z1=z1(end);
    priceFFT=priceFFT(z1:end);
   z=z(z1:end);
   end
   if(z(end)>0.25)
   z2=find(z>0.25);
   z2=z2(1);
   priceFFT=priceFFT(1:z2);
   z=z(1:z2);
   end
   
   % Compute the price of a european call using the Lewis formula and
   % approximating the integral with global adaptive quadrature
   [priceQ]=LewisQuad(B,F0,alpha,eta,sigma,volofvol,T,z,thresold);

   % Compute error
   error(M)=max(abs(priceFFT-priceQ));
end

% plot the logarithm of the error, wrto different M
figure(6)
semilogy(1:n,error,'LineWidth',2)
grid on
title('Optimal M')
xlabel('M')
ylabel('Error (log10)')
set(gca, 'FontSize', 16);

%% Exercise 3 - compute otptimal x1 and M

% Values to check
nmax=20;
mmax=18;
mmin=8;
M=mmin:mmax;
parx1=linspace(-1000,-100,nmax)';
error=zeros(mmax-mmin+1,nmax);
thresold=1e-16;

for jj=1:(mmax-mmin+1)
    for ii=1:nmax

        % Compute the price of a european call using the Lewis formula and
        % approximating the integral with a fast Fourier transform
        if gpu
        [priceFFT,z]=LewisFFTgpu(B,F0,alpha,eta,sigma,volofvol,T,M(jj),parx1(ii),1);
        else
        [priceFFT,z]=LewisFFT(B,F0,alpha,eta,sigma,volofvol,T,M(jj),parx1(ii),1);
        end
        
        % Select interval of interest (in which check the error)
        if z(1)<-0.25
            z1=find(z<-0.25);
            z1=z1(end);
            priceFFT=priceFFT(z1:end);
            z=z(z1:end);
        end
        if(z(end)>0.25)
            z2=find(z>0.25);
            z2=z2(1);
            priceFFT=priceFFT(1:z2);
            z=z(1:z2);
        end

        % Compute the price of a european call using the Lewis formula and
        % approximating the integral with global adaptive quadrature
        [priceQ]=LewisQuad(B,F0,alpha,eta,sigma,volofvol,T,z,thresold);
        
        % Compute the error
        error(jj,ii)=max(abs(priceFFT-priceQ));
    end
end
toc

% plot the logarithm of the error, wrto different M and x1
close(figure(7))
figure(7)
surface(parx1,mmin:mmax,log10(error))
colorbar
view(3)
title('Optimal M and x1')
xlabel('x1')
ylabel('M')
zlabel('Error (log10)')
grid on
set(gca, 'FontSize', 16);

%% Computing optimal dz and M

% Values to check
nmax=14;
mmax=22;
mmin=8;
M=mmin:mmax;
nmin=4;
pardz=(1/2).^(nmin:nmax)';
error=zeros(mmax-mmin+1,nmax-nmin+1);
thresold=1e-16;

for jj=1:(mmax-mmin+1)
    for ii=1:nmax-nmin+1
        
        % Compute the price of a european call using the Lewis formula and
        % approximating the integral with a fast Fourier transform
        if gpu
        [priceFFT,z]=LewisFFTgpu(B,F0,alpha,eta,sigma,volofvol,T,M(jj),pardz(ii),2);
        else
        [priceFFT,z]=LewisFFT(B,F0,alpha,eta,sigma,volofvol,T,M(jj),pardz(ii),2);
        end
        
        % Select interval of interest (in which check the error)
        if z(1)<-0.25
            z1=find(z<-0.25);
            z1=z1(end);
            priceFFT=priceFFT(z1:end);
            z=z(z1:end);
        end
        if(z(end)>0.25)
            z2=find(z>0.25);
            z2=z2(1);
            priceFFT=priceFFT(1:z2);
            z=z(1:z2);
        end

        % Compute the price of a european call using the Lewis formula and
        % approximating the integral with global adaptive quadrature
        [priceQ]=LewisQuad(B,F0,alpha,eta,sigma,volofvol,T,z,thresold);
        
        % Compute error
        error(jj,ii)=max(abs(priceFFT-priceQ));
    end
end

% plot the logarithm of the error, wrto different M and dz
close(figure(8))
figure(8)
surface(pardz,mmin:mmax,log10(error))
colorbar
view(3)
title("Optimal M and dz")
xlabel('dz')
ylabel('M')
zlabel('Error (log10)')
grid on
set(gca, 'FontSize', 16);

%% Exercise 4
B = interpB2(dates,discounts,expiry);
T = yearfrac(dates(1), expiry, act365);
S0 = cSelect.reference;
F0 = S0*exp(-T*cSelect.dividend)/B;
alpha = 1/3;
strikes = cSelect.strikes;
surf = cSelect.surface;

% Calibration
[parameters, error, price_mkt] = calibration(strikes, surf, B, T, F0, alpha);

sigma = parameters(1);
eta = parameters(2);
k = parameters(3);
M = 14;

% Calculate the model prices
[priceFFT,x]=LewisFFT(B,F0,alpha,eta,sigma,k,T,M,-400,1);
K = F0*exp(-x);
price_model = interp1(K,priceFFT,strikes);

% Compute the implied volatility of the model 
surface_model = blkimpv(F0, strikes, -log(B)/T, T, price_model);

% Plot of the two volatility surfaces
figure(9)
plot(strikes, surf, 'LineWidth',2,'Color','#40e0d0')
hold on
plot(strikes, surface_model, 'LineWidth',2,'Color','#ee82ee')
title('Market implied volatility VS Model implied volatility','FontSize', 22)
xlabel('Strikes','FontSize', 22)
ylabel('Volatilities','FontSize', 22)
legend('Market', 'Model')
set(gca, 'FontSize', 16);
grid on

% Plot of the prices
surface_model = blkimpv(F0, strikes, -log(B)/T, T, price_model);
figure(10)
plot(strikes, price_mkt, 'LineWidth',2)
hold on
plot(strikes, price_model, 'LineWidth',2)
title('Market prices VS Model prices','FontSize', 22)
xlabel('Strikes','FontSize', 22)
ylabel('Prices','FontSize', 22)
legend('Market', 'Model')
set(gca, 'FontSize', 16);
grid on

% Euclidean distance between the market and model prices
distance = (price_mkt - price_model).^2;
figure(11)
plot(strikes, distance, 'LineWidth',2)
title('Euclidean distance between the market and model prices','FontSize', 22)
xlabel('Strikes','FontSize', 22)
ylabel('Euclidean distance','FontSize', 22)
set(gca, 'FontSize', 16);
grid on
