function [h_curve]=hcurve(dirtyprice,cashflow,zero,R)

% Compute the hazard rate at every expiry finding numerically the zero of the function

% INPUT:
% dirtyprice: price on market (include default possibility)
% cf_schedule: matrix with all the bonds in sequence, in the first column
% there are the expiries (in year fractions) and in the second column the
% coupon
% ZC_curve: curve of the zero coupon rates
% R: recovery (as percentage)

% OUTPUT: expiries with h

expiry=unique(cashflow(:,1));
% Compute the discount factors in the dates of interest, interpolating the
% ZC_curve
discounts=exp(-interp1(zero(:,1),zero(:,2),expiry,"spline").*expiry);

% We assume expiries at the end of the year
% We assume h constant between the expiries and we compute them finding
% numerically the zeros of the function got by the equality

B=@(x,y) [discounts(1)*exp(-x/2);discounts(2)*exp(-x);discounts(3)*exp(-x-y/2);discounts(4)*exp(-x-y)];
v=@(x,y) [exp(x/2)-1;exp(x/2)-1;exp(y/2)-1;exp(y/2)-1];
first_two_rows=@(x) x(1:2);

f1=@(h1) cashflow(1:2,2)'*first_two_rows(B(h1,1))+100*R*(first_two_rows(v(h1,1))'*first_two_rows(B(h1,1)))-dirtyprice(1);

h1=fzero(f1,0);

f2=@(h2) cashflow(3:end,2)'*B(h1,h2)+100*R*(v(h1,h2)'*B(h1,h2))-dirtyprice(2);

h2=fzero(f2,0);


% h_curve=[expiries,h];

h_curve=[1,h1;2,h2];