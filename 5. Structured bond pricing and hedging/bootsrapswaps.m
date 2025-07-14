function [datesSwaps,B_swaps]=bootsrapswaps(datesSwaps,rates,dates,discounts)

% Compute dates and discounts of swaps for IR curve

%INPUT:
%datesSwaps: expiries of the swaps
%rates: matrix with bid rates of futures in first column and ask in the second
%dates: dates of the IR curve
%discounts: IR curve

% Setting variables
load variables.mat

% We keep the dates from the last date before the last future's expiry
z=find(datesSwaps>dates(end));
z=[z(1)-1;z];
datesSwaps=datesSwaps(z);

% Compute mid rates
mid=(rates(z,1)+rates(z,2))/2;
% Spline interpolating nan values
nan_idx=isnan(mid);
dt=yearfrac(dates(1),datesSwaps(~nan_idx),Act365);
dtquery=yearfrac(dates(1),datesSwaps,Act365);
mid=interp1(dt,mid(~nan_idx),dtquery,'spline');

% Inizialize array
l=length(datesSwaps);
B_swaps=zeros(l,1);

% Compute the discount of the first swap interpulating in the curve
B_swaps(1)=interpB2(dates,discounts,datesSwaps(1));
dates_aux=[dates(1);datesSwaps];

% Compute all swaps discounts, yearfrac 30/360 EU
for ii=2:l
    B_swaps(ii)=(1-mid(ii)*sum(yearfrac(dates_aux(1:ii-1),dates_aux(2:ii),EU30).*B_swaps(1:ii-1)))/(1+yearfrac(datesSwaps(ii-1),datesSwaps(ii),EU30)*mid(ii));
end

end % function bootsrapswaps