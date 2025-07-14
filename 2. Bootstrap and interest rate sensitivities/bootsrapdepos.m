function [dates,discounts]=bootsrapdepos(dates,rates,t0)

% Compute dates and discounts of deposits for IR curve

% INPUT
% dates: expiry dates of the deposits
% rates: matrix with bid rates of deposits in first column and ask in 
%        the second
% t0: settlemnt date of the curve

% Compute mid rates
mid=(rates(:,1)+rates(:,2))/2;

% Compute intervals of time, act/360
dt=yearfrac(t0,dates,2);

% Compute the discounts
discounts=1./(1+dt.*mid);

end % function bootstrapdepos