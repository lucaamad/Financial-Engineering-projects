function [DV01, BPV, DV01_z] = sensSwap(setDate, fixedLegPaymentDates, fixedRate, dates, discounts, discounts_DV01)

% Compute the dollar value of 1 basis point, the basis point value and the
% dollar value of 1 basis point on zero rates of  plain vanilla IR swap vs
% Euribor 3m

% INPUT
% setDate: struct of the dates
% fixedLegPaymentDates: dates of the payment of the fixed coupons
% fixedRate: coupons
% dates: dates of the IR curve
% discounts: IR curve
% discounts_DV01: modified IR curve

% Compute intervals of time, 30/360 EU
dt=yearfrac([dates(1);fixedLegPaymentDates(1:end-1)],fixedLegPaymentDates,6);

% Compute shifted zero rates
y_shifted=zeroRates(dates, discounts)+1e-2;

% Inizialize arrays
B=zeros(length(fixedLegPaymentDates),1);
B_shifted=B;
B_shifted_z=B;

% Compute the discounts at the dates of payment of fixed coupons in three cases
for ii=1:length(fixedLegPaymentDates)
    % Original curve
    B(ii)=interpB(dates,discounts,fixedLegPaymentDates(ii));
    % Curve with shifted quoted rates
    B_shifted(ii)=interpB(dates,discounts_DV01,fixedLegPaymentDates(ii));
    % Shifted zero rate curve
    B_shifted_z(ii)=interpB(dates,[1;discountfactors(dates,y_shifted(2:end))],fixedLegPaymentDates(ii));
end

% Compute basis point values for original and shifted curves
BPV=sum(B.*dt);
BPV_shifted=sum(B_shifted.*dt);
BPV_shifted_z=sum(B_shifted_z.*dt);

% Compute net present values for original and shifted curves
NPV=fixedRate*BPV-1+B(end);
NPV_shifted=fixedRate*BPV_shifted-1+B_shifted(end);
NPV_shifted_z=fixedRate*BPV_shifted_z-1+B_shifted_z(end);

% Compute  outputs
DV01=abs(NPV_shifted-NPV);
BPV=BPV*1e-4;
DV01_z=abs(NPV_shifted_z-NPV);

end % function sensSwap