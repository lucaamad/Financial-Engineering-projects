function [dates, discounts]=bootstrap(datesSet, ratesSet)

% IR curve with bootsrap on deposits, first seven futures and swaps

% INPUT
% datesSet: struct of dates
%   datesSet.depos: expiry dates of the deposits
%   datesSet.futures: matrix with settlement dates of the futures in the
%       first column and expiry dates of the futures in the second column
%   datesSet.swaps: expiry dates of the swaps
%   datesSet.settlemnt: settlement date
% ratesSet: struct of rates
%   ratesSet.depos: bid and ask rates of deposits
%   ratesSet.futures: bid and ask rates of futures at expiry date
%   ratesSet.swaps: bid and ask rates of swaps

% OUTPUT
% dates and rates of the IR curve (to plot)

% settlement date
dates=datesSet.settlement;
discounts=1;

% settlement date of the first future
fut1=datesSet.futures(1,1); 

% For the IR curve we use deposits rates until the first future
z=find(fut1<=datesSet.depos);
z=z(1);

% Compute dates and discounts of deposits and add them to IR curve
[dates_depos,discounts_depos]=bootsrapdepos(datesSet.depos(1:z),ratesSet.depos(1:z,:),dates(1));
dates=[dates;dates_depos];
discounts=[discounts;discounts_depos];

% Compute dates and discounts of first seven futures and add them to IR curve
[dates_futures,discounts_futures]=bootstrapfutures(datesSet.futures(1:7,1),datesSet.futures(1:7,2),ratesSet.futures(1:7,:),dates,discounts);
dates=[dates;dates_futures];
discounts=[discounts;discounts_futures];

% Compute dates and discounts of swaps after the first seven futures and add 
% them to IR curve
[dates_swaps,discounts_swaps]=bootsrapswaps(datesSet.swaps,ratesSet.swaps,dates,discounts);
dates=[dates;dates_swaps(2:end)];
discounts=[discounts;discounts_swaps(2:end)];

end %function boostrap