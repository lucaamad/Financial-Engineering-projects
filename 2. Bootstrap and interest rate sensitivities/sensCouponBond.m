function MacD = sensCouponBond(setDate, couponPaymentDates, fixedRate, dates, discounts)

% Compute the Macaulay duration of and IB coupon bond with fixed coupon

% INPUT
% setDate: struct of the dates
% couponPaymentDates: dates of the payment of the coupon
% fixedRate: coupons
% dates: dates of the IR curve
% discounts: IR curve

% Inizialize array
l=length(couponPaymentDates);
discountcoupondates=zeros(l,1);

% Compute the discount factors for every date of the coupon
for ii=1:l
    discountcoupondates(ii)=interpB(dates,discounts,couponPaymentDates(ii));
end

% Compute the duration
MacD = (fixedRate*sum(discountcoupondates.*yearfrac(dates(1),couponPaymentDates,6))+discountcoupondates(end)*yearfrac(dates(1),couponPaymentDates(end),6))/...
   (fixedRate*sum(discountcoupondates)+discountcoupondates(end));

end % function sensCouponBond