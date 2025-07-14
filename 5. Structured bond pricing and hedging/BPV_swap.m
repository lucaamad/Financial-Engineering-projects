function BPV=BPV_swap(dates,discounts,payment_dates)

% Compute the Delta of a Swap, i.e. its BPV (expressed in bp)

% INPUT:
% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% payment_dates: dates in which are payed the floating legs

% Setting variables
load variables.mat

% Interpolating, compute discounts at the date of payment of floating legs
payment_discounts=interpB2(dates,discounts,payment_dates);

% Compute compute the year fraction between each date in Act/360
dt=yearfrac([dates(1);payment_dates(1:end-1)],payment_dates,Act360);

% Compute the Net Present Value
BPV=sum(payment_discounts.*dt);

end % function BPV_swap