%runAssignment6Group1
% Group 1, AY2023-2024
clear;
close all;
clc;

%% Settings2

formatData='dd/mm/yyyy'; 
load variables.mat

%% Read excel and compute dates
[datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap_20-2-24', formatData);

if ~isfield(datesSet,'swaps')
    datesSet.swaps=datetime(datesSet.settlement,'ConvertFrom','datenum')+calyears(1:50)';
end

datesSet.swaps=businessdates(datesSet.swaps);

%% Exercise 1

% Compute IR curve
[dates, discounts]=bootstrap(datesSet, ratesSet);

% Select date of payment of floating leg and computing deltas (Act/360)
floating_dates = datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:180)';
floating_dates = businessdates(floating_dates);
dt360=yearfrac([dates(1);floating_dates(1:end-1)],floating_dates,Act360);

% Setting the datas
s_spol_A = 0.02;
s_spol_B = 0.011;
N = 50*10e6;
caplet1=0.03;
K=[0.032;0.035;0.04];

% Load flat volatilities, strike and years from file, clean the data
volfile="Caps_vol_20-2-24.xlsx";
vol=readmatrix(volfile,"FileType","spreadsheet","Range",'F2:R17');
strike=readmatrix(volfile,"FileType","spreadsheet","Range","F1:R1");
vol(2,:)=[];
vol=vol/1e4;
strike=strike/100;
times=readtable(volfile,"FileType","spreadsheet","Range","B2:B14","ReadVariableNames",false);
times(2,:)=[];
times=table2array(times);
pattern='\d+';
times=cellfun(@(x) str2double(regexp(x, pattern, 'match')), times);

% Compute spot volatilities, starting from the flat ones
spot_vol=spotvol(vol,times,strike,dates,discounts,floating_dates,dt360);

% Compute NPV of both part A and B (excluding the X)
[NPVa,NPVb]=NPVstructure(dates,discounts,spot_vol,strike,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt360);

% Compute the X which make the NPV zero
X=NPVa-NPVb;

%% Plot the spot volatilities

[x,y]=meshgrid(strike,datetime(floating_dates,'ConvertFrom','datenum'));
figure(1)
surf(x,y,spot_vol)
title('Spot Volatilities')
xlabel('Strike')
ylabel('Dates of payment of floating leg')
grid on
colorbar
set(gca, 'FontSize', 12);

%% Plot the flat volatilities

[xx,yy]=meshgrid(strike,times);
figure(7)
surf(xx,yy,vol(1:12,:))
title('Flat Volatilities')
xlabel('Strike')
ylabel('Years')
grid on
colorbar
set(gca, 'FontSize', 12);

%% Delta bucket sensitivities

% Setting datas
ttmswaps=[2;5;10;15];
ttmcaps=[5;15];
Kcaps=(ratesSet.swaps(ttmcaps,1)+ratesSet.swaps(ttmcaps,2))/2;
caps=zeros(length(ttmcaps),1);

% Compute caps Net Present Value
for jj=1:length(ttmcaps)
    dates_float=floating_dates(1:4*ttmcaps(jj));
    dt=dt360(1:4*ttmcaps(jj));
    disc_float=interpB2(dates,discounts,dates_float);
    fwd_disc=disc_float./[1;disc_float(1:end-1)];
    libor = (1./fwd_disc-1)./dt;
    sigma=interp1(strike,spot_vol(2:ttmcaps(jj)*4,:)',Kcaps(jj),'spline')';
    caps(jj)=sum(capletBach(disc_float(1:ttmcaps(jj)*4),dates_float(1:ttmcaps(jj)*4),libor(2:end),Kcaps(jj),sigma,dates(1),dt360(2:ttmcaps(jj)*4)));
end

% Compute delta bucket sensitivities
[delta,delta_dates,delta_swaps,delta_caps]=Delta_bucket(datesSet,ratesSet,strike,spot_vol,K,s_spol_A,s_spol_B,caplet1,X,ttmswaps,ttmcaps,Kcaps,caps,floating_dates,dt360);

%% Plot of delta bucket
figure(2)
bar((1:4),delta(1:4))
grid on
xlabel('Deposits')
ylabel("Delta")
set(gca, 'FontSize', 16);
figure(3)
bar((1:7),delta(5:11))
grid on
xlabel('Futures')
ylabel('Delta')
set(gca, 'FontSize', 16);
figure(4)
bar((2:18),delta(12:end))
grid on
xlabel("Swaps")
ylabel("Delta")
set(gca, 'FontSize', 16);
figure(6)
bar(log10(abs(delta)))
grid on
xlabel("Buckets")
ylabel("Log10(|Delta|)")
set(gca, 'FontSize', 16);

%% Total vega

vega=Vega(dates,discounts,strike,times,vol,K,s_spol_A,s_spol_B,caplet1,X,floating_dates,dt360);

%% Vega bucket

[vegas_sp,vegas_caps]=Vega_bucket(dates,discounts,strike,times,vol,K,s_spol_A,s_spol_B,caplet1,X,ttmcaps,Kcaps,caps,floating_dates,dt360);

%% Plot of vega bucket
figure(5)
subplot(1,2,1)
bar(times,vegas_sp)
grid on
ylabel("Vega")
set(gca, 'FontSize', 16);
xlabel('years')

subplot(1,2,2)
bar(times,log10(abs(vegas_sp)))
grid on
ylabel("Log10(|vega|)")
set(gca, 'FontSize', 16);
xlabel('years')
%% Course grained sensitivities and hedging

% Setting datas
notional_sp=50*1e6;
buckets=[2;5;10;15];

% Compute sensitivity of structured prdoduct and of swaps in each bucket
[delta_CG_sp, delta_CG_swaps, ~] = Delta_CG(buckets,dates(1),delta,delta_dates,delta_swaps,delta_caps);

% Hedge the portfolio
notional_swaps=delta_CG_swaps\(-notional_sp*delta_CG_sp);

%% Hedging vega

% Setting datas
ttm=5;
atm_strike=(ratesSet.swaps(ttm,1)+ratesSet.swaps(ttm,2))/2;

% Select dates of payemnt of the floating leg
dates_float=floating_dates(1:4*ttm);

% Compute the discount in the floating dates interpolating
disc_float=interpB2(dates,discounts,dates_float);

% Compute forward discount and forward libor
fwd_disc=disc_float./[1;disc_float(1:end-1)];
libor = (1./fwd_disc-1)./dt360(1:4*ttm);

% Get volatilities of requested strike interpolating
sigma=interp1(strike,spot_vol(2:ttm*4,:)',atm_strike,'spline')';

% Increase flat volatilities
vol2=vol+1e-4;

% Compute spot volatilities
spot_vol2=spotvol(vol2,times,strike,dates,discounts,floating_dates,dt360);

% Get volatilities of requested strike interpolating
sigma2=interp1(strike,spot_vol2(2:ttm*4,:)',atm_strike,'spline')';

% Compute value of the cap
cap=sum(capletBach(disc_float(1:ttm*4),dates_float(1:ttm*4),libor(2:end),atm_strike,sigma,dates(1),dt(2:4*ttm)));

% Compute vega of the cap
vega_cap=sum(capletBach(disc_float(1:ttm*4),dates_float(1:ttm*4),libor(2:end),atm_strike,sigma2,dates(1),dt(2:4*ttm)))-cap;

% Hedge the vega
notional_cap=-notional_sp*vega/vega_cap;

% Once the portfolio is vega hedged, we add a swap to make it also delta hedged
% Compute delta of structured bond, cap and swap
[tDelta_sp,tDelta_cap,tDelta_swap]=tDelta(datesSet,ratesSet,strike,times,vol,atm_strike,ttm,dates_float,cap,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt360,X);

% Hedge the delta
notional_sw5y=-(notional_sp*tDelta_sp+notional_cap*tDelta_cap)/tDelta_swap;

%% Course grained vega

% Setting datas
buckets_v=[5;15];
K=[0.032;0.035;0.04];
K2=(ratesSet.swaps(buckets_v,1)+ratesSet.swaps(buckets_v,2))/2;
caps=zeros(length(buckets_v),1);

% Compute caps Net Present Value
for jj=1:length(buckets_v)
    dates_float=floating_dates(1:buckets_v(jj)*4);
    disc_float=interpB2(dates,discounts,dates_float);
    fwd_disc=disc_float./[1;disc_float(1:end-1)];
    libor = (1./fwd_disc-1)./dt360(1:4*buckets_v(jj));
    sigma=interp1(strike,spot_vol(2:buckets_v(jj)*4,:)',K2(jj),'spline')';
    caps(jj)=sum(capletBach(disc_float(1:buckets_v(jj)*4),dates_float(1:buckets_v(jj)*4),libor(2:end),K2(jj),sigma,dates(1),dt(2:buckets_v(jj)*4)));
end

sigma=interp1(strike,spot_vol(2:ttm*4,:)',K,'spline')';

% Compute coarse grained bucket vega of structured product and of caps
[vega_CG_sp,vega_CG_caps]=Vega_bucket_CG(buckets_v,vegas_sp,vegas_caps,times);

% Hedge the vega
notional_caps=vega_CG_caps\(-notional_sp*vega_CG_sp);

% Compute coarse grained bucket delta of structured product, of caps and of
% swaps
[delta_CG_sp2,delta_CG_swaps2,delta_CG_caps2]=Delta_CG(buckets_v,dates(1),delta,delta_dates,delta_swaps(:,[2,4]),delta_caps);

% Hedge the delta
notional_sw=-delta_CG_swaps2\(notional_sp*delta_CG_sp2+delta_CG_caps2*notional_caps);

%% Write IR curve on excel

if isfile('MktData_CurveBootstrap_20-2-24.xls')
    Date=datestr(dates);
    DF=discounts;
    curve=table(Date,DF);
    writetable(curve,'MktData_CurveBootstrap_20-2-24.xls','FileType','spreadsheet','Sheet',1,'Range','L10:M71');
    Swap=datestr(datesSet.swaps);
    dates_swap=table(Swap);
    writetable(dates_swap,'MktData_CurveBootstrap_20-2-24.xls','FileType','spreadsheet','Sheet',1,'Range','D38:D88');
    disp('Printed on Excel')
end
