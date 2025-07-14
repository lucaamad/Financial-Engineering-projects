function [dates, discounts] = readExcelData2( filename, formatData)
% Reads data from excel
%  It reads bid/ask prices and relevant dates
%  All input rates are in % units
%
% INPUTS:
%  filename: excel file name where data are stored
%  formatData: data format in Excel
% 
% OUTPUTS:
%  dates: bootstrap dates
%  rates: discounts

%% Dates from Excel

% %Settlement date
% [~, settlement] = xlsread(filename, 1, 'E8');
% %Date conversion
% dates.settlement = datenum(settlement, formatData);
% 
% %Dates relative to depos
% [~, date_depositi] = xlsread(filename, 1, 'D11:D18');
% dates.depos = datenum(date_depositi, formatData);
% 
% %Dates relative to futures: calc start & end
% [~, date_futures_read] = xlsread(filename, 1, 'Q12:R20');
% numberFutures = size(date_futures_read,1);
% 
% dates.futures=ones(numberFutures,2);
% dates.futures(:,1) = datenum(date_futures_read(:,1), formatData);
% dates.futures(:,2) = datenum(date_futures_read(:,2), formatData);
% 
% %Date relative to swaps: expiry dates
% [~, date_swaps] = xlsread(filename, 1, 'D39:D88');
% dates.swaps = datenum(date_swaps, formatData);

% Bootstrap dates
[~, dates] = xlsread(filename, 1, 'L11:L70');
dates = datenum(dates, formatData);

%% Rates from Excel (Bids & Asks)

% %Depos
% tassi_depositi = xlsread(filename, 1, 'E11:F18');
% rates.depos = tassi_depositi / 100;
% 
% %Futures
% tassi_futures = xlsread(filename, 1, 'E28:F36');
% %Rates from futures
% tassi_futures = 100 - tassi_futures;
% rates.futures = tassi_futures / 100;
% 
% %Swaps
% tassi_swaps = xlsread(filename, 1, 'E39:F88');
% rates.swaps = tassi_swaps / 100;

% Discounts
discounts = xlsread(filename, 1, 'M11:M70');

end % readExcelData