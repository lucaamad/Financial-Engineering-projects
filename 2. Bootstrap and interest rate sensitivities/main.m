% runAssignment2
% Group 1, AY2023-2024
% Computes Euribor 3m bootstrap with a single-curve model

clear all;
close all;
clc;

%% Settings
formatData='dd/mm/yyyy'; 

%% Read market data
% This fuction works on Windows OS. Pay attention on other OS.
[datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap', formatData);


%% Bootstrap
% dates includes SettlementDate as first date
[dates, discounts]=bootstrap(datesSet, ratesSet);

%% Write IR curve on excel

if isfile('MktData_CurveBootstrap.xls')
    Date=datestr(dates);
    DF=discounts;
    curve=table(Date,DF);
    writetable(curve,'MktData_CurveBootstrap.xls','FileType','spreadsheet','Sheet',1,'Range','L10:M70');
end

%% Compute Zero Rates
zeros=zeroRates(dates,discounts);

%% Plot Results
% Convert date to numeric format to extended format
datesext=datetime(dates,'ConvertFrom','datenum');

% Plot IR curve, comparing zeros (right axis) and discount rates (left axis)
figure(1)
yyaxis left;
plot(datesext,discounts,'-pentagram','LineWidth',2,'Color','#27AE60','Markersize',5,'MarkerEdgeColor','#145A32')
grid on
ax=gca;
title('IR curve')
ylabel('Discount factors')
xlabel('Dates')
ax.YColor = '#27AE60';
ax.FontSize=15;
yyaxis right;
plot(datesext,zeros,'-hexagram','LineWidth',2,'Color','#FF7514','Markersize',5,'MarkerEdgeColor','#B03A2E')
grid on
ylabel('Zero Rates [%]')
ax.YColor = '#FF7514';

%% Sensitivities

% In order to compute DV01, all the rates are increased by 1bp (0.01%) and
% the IR curve is recomputed
ratesSet_mod.depos=ratesSet.depos+1e-4;
ratesSet_mod.futures=ratesSet.futures+1e-4;
ratesSet_mod.swaps=ratesSet.swaps+1e-4;
[~,discounts_DV01]=bootstrap(datesSet,ratesSet_mod);

% The portfolio is composed only by one single swap, a 6y plain vanilla
% IR swap vs Euribor 3m with a fixed rate 2.8173%
fixedLegPaymentDates=datesSet.swaps(1:6);

fixedRate=0.028173;
[DV01, BPV, DV01_z] = sensSwap(datesSet, fixedLegPaymentDates, fixedRate, dates, discounts, discounts_DV01);

fprintf('The dollar value of 1 basis point for a 6y plain vanilla IR swap\n vs Euribor 3m with a fixed rate of 2.8173 is %f 1e-4\n\n',DV01*1e4);
fprintf('The basis point value for a 6y plain vanilla IR swap vs Euribor\n 3m with a fixed rate of 2.8173 is %f 1e-4\n\n',BPV*1e4);
fprintf('The dollar value of 1 basis point on zero rates for a 6y plain\n vanilla IR swap vs Euribor 3m with a fixed rate of 2.8173 is %f 1e-4\n\n',DV01_z*1e4);
%% Duration
% Compute the Macaulaty duration
duration=sensCouponBond(datesSet,fixedLegPaymentDates,fixedRate,dates,discounts);

fprintf('The Macaulay duration of a 6y IB coupon bond with a fixed rate of 2.8173 is %f\n\n',duration)