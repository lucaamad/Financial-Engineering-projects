% runAssignment2
% Group 1, AY2023-2024


clear;
close all;
clc;

%% Settings
rng();
formatData='dd-mmm-yyyy'; 
SwapDayCount=6;

%% Read market data
% This fuction works on Windows OS. Pay attention on other OS.
[dates, discounts] = readExcelData2('MktData_CurveBootstrap', formatData);


%% Exercise 1

% Insert datas
dirtyprice=1.01;
coupon_rate=0.039;
cf_schedule=[datenum('19-Feb-2009',formatData),coupon_rate;datenum('19-Feb-2010',formatData),coupon_rate;datenum('21-Feb-2011',formatData),coupon_rate];

% Compute asset swap spread over Euribor 3m
sasw=assetswapspread(dirtyprice,cf_schedule,discounts,dates,SwapDayCount);

fprintf('The Asset Swap Spread Over Euribor 3m is %.4f BP\n', sasw*1e4);

%% Exercise 2

% Insert data and compute the missing value interpolating with a spline
old_cds_ISP=[datenum('19-Feb-2009',formatData),0.0029;datenum('19-Feb-2010',formatData),0.0032;datenum('21-Feb-2011',formatData),0.0035;...
    datenum('20-Feb-2012',formatData),0.0039; datenum('19-Feb-2013',formatData),0.0040;datenum('19-Feb-2015',formatData),0.0041];
six_year_spread=spline(old_cds_ISP(:,1),old_cds_ISP(:,2),datenum('19-Feb-2014',formatData));
cds_ISP=[old_cds_ISP(1:5,:);datenum('19-Feb-2014',formatData),six_year_spread;old_cds_ISP(6,:)];
recovery_ISP=0.40;

% Compute survival probabilities and intensities of Intesa San Paolo, with
% approximation method
flag=1;
[datesCDS_ISP, survProbs_ISP_apx, intensities_ISP_apx]=bootstrapCDS(dates, discounts, cds_ISP(:,1), cds_ISP(:,2), flag, recovery_ISP);

% Compute survival probabilities and intensities of Intesa San Paolo, with
% exact method (adding the accrual)
flag=2;
[datesCDS_ISP, survProbs_ISP_ex, intensities_ISP_ex]=bootstrapCDS(dates, discounts, cds_ISP(:,1), cds_ISP(:,2), flag, recovery_ISP);

% Compute survival probabilities and intensities of Intesa San Paolo, with
% Jarrow & Turnbull method
flag=3;
[datesCDS_ISP, survProbs_ISP_jt, intensities_ISP_jt]=bootstrapCDS(dates, discounts, cds_ISP(:,1), cds_ISP(:,2), flag, recovery_ISP);


% Mean Square Error between the approximated and the exact result
mse=sum((intensities_ISP_apx-intensities_ISP_ex).^2)/length(intensities_ISP_ex);

% Compute the means of Jarrow & Turnbull to verify they are similar to
% intesities computed with other methods
int4=zeros(7,1);
for ii=1:7
    int4(ii)=sum(intensities_ISP_ex(1:ii))/ii;
end

% Conversion of the dates into the format 'dd-mm-yyyy'
dates_plot=datetime(datesCDS_ISP,'ConvertFrom','datenum');
dates_plot=[dates_plot;'19-feb-2016'];

% Plot of the intensities computed by using the CDS spreads (without
% accrual)
figure(1)
stairs(dates_plot,[intensities_ISP_apx;intensities_ISP_apx(end)],'LineWidth',2)
grid on
title('Intensities')
xlabel('Time')
ylabel('Intensity (bps)')
axis padded
hold on

% Plot of the intensities computed by using the CDS spreads (without
% accrual)
stairs(dates_plot,[intensities_ISP_ex;intensities_ISP_ex(end)],'LineWidth',2)
grid on
xlabel('Time')
ylabel('Intensity (bps)')
axis padded
hold on
legend('No accrual','Accrual')

%% Exercise 3

% Insert data and compute the missing value interpolating with a spline
recovery_UCG=0.45;
old_cds_UCG=[datenum('19-Feb-2009',formatData),0.0034;datenum('19-Feb-2010',formatData),0.0039;datenum('21-Feb-2011',formatData),0.0045;...
    datenum('20-Feb-2012',formatData),0.0046; datenum('19-Feb-2013',formatData),0.0047;datenum('19-Feb-2015',formatData),0.0047];
six_year_spread=spline(old_cds_UCG(:,1),old_cds_UCG(:,2),datenum('19-Feb-2014',formatData));
cds_UCG=[old_cds_UCG(1:5,:);datenum('19-Feb-2014',formatData),six_year_spread;old_cds_UCG(6,:)];

% Compute survival probabilities and intensities of Unicredit, with
% exact method (adding the accrual)
[datesCDS_UCG, survProbs_UCG, intensities_UCG]=bootstrapCDS(dates, discounts, cds_UCG(:,1), cds_UCG(:,2), 2, recovery_UCG);

% Insert data
rho=0.2;
mu=[0;0];
sigma=[1,rho;rho,1];
A=chol(sigma);
Nsim=10000;
recovery=[recovery_ISP;recovery_UCG];

% Compute the discounts at the dates of payment of the credit default swap
discountsFTD=interpB2(dates,discounts,datesCDS_ISP(1:4));

% Compute the spread
[spread,IC]=spreadFTD(mu,A,[dates(1);datesCDS_ISP(1:4)],intensities_ISP_ex(1:4),intensities_UCG(1:4),Nsim,recovery,discountsFTD,dates,discounts);

fprintf('The First to Default spread is %.4f BP, with a confidence interval of [%.4f,%.4f]\n', spread*1e4,IC(1)*1e4,IC(2)*1e4);

%% Changing the correlation

% Set the correlations
rho=-0.99:0.1:0.99;

% Inizializing array
spreads=zeros(length(rho),1);
lowlim=zeros(length(rho),1);
uplim=zeros(length(rho),1);

for ii=1:length(rho)
    sigma=[1,rho(ii);rho(ii),1];
    A=chol(sigma);
    [spreads(ii),IC]=spreadFTD(mu,A,[dates(1);datesCDS_ISP(1:4)],intensities_ISP_ex(1:4),intensities_UCG(1:4),Nsim,recovery,discountsFTD,dates,discounts);  
    lowlim(ii)=IC(1);
    uplim(ii)=IC(2);
end

% Plot the result
figure(2)
plot(rho,spreads,'LineWidth',2,'Color','b')
hold on
plot(rho,lowlim,'LineWidth',2,'LineStyle','--','Color','r')
plot(rho,uplim,'LineWidth',2,'LineStyle','--','Color','r')
title('Spread First to Default')
xlabel('Correlation')
ylabel('Spread')
grid on
legend('Spread','Lower Bound','Upper Bound')

x_fill = [rho'; flipud(rho')]; 
y_fill = [lowlim; flipud(uplim)];
fill(x_fill, y_fill,'y', 'FaceAlpha', 0.3);




