function sasw=assetswapspread(dirtyprice,cf_schedule,discounts,dates,SwapDayCount)

% Compute the Asset Swap Spread Over 3m Euribor

% INPUT:
% dirtyprice: 3y bond price for an issuer YY
% cf_schedule:  table of cash flows of corporate bonds
%               Column #1: cash flow date (year frac)
%               Column #2: cash flow amount
% discounts: IR curve
% dates: dates of the IR curve (starting from t0)
% SwapDayCount: year fraction convention for the fixed leg dates

% Compute the yearfraction between each fixed leg payment date and the following 
% one (t0 included)
dt_fixed=yearfrac([dates(1);cf_schedule(1:end-1,1)],cf_schedule(:,1),SwapDayCount);

% Find the Euribor payment dates by increasing iteratively the settlement date by 3
% months, up to the maturity
date_floating=(datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:36))';

% Set the holidays: New Year's Day, Good Friday, Easter Monday, First of
% May, Christmas Day, Boxing Day
holly=['21/03/2008';'24/03/2008';'01/05/2008';'25/12/2008';'26/12/2008';'01/01/2009';...
    '10/04/2009';'13/04/2009';'01/05/2009';'25/12/2009';'26/12/2009';'01/01/2010';...
    '02/04/2010';'05/04/2010';'01/05/2010';'25/12/2010';'26/12/2010';'01/01/2011'];
formatData='dd/MM/yyyy';
holly=datetime(holly,'InputFormat',formatData);

% Check that the floating leg payment dates are not holidays.
% Function "busdate" checks that the following day is not a holiday, hence
% we apply it to the preceeding days of the vector "date_floating".
date_floating=busdate(date_floating-1,"follow",holly);
date_floating=datenum(date_floating);

% Compute the delta between each floating leg payment date and the following 
% one (t0 included)
dt_floating=yearfrac([dates(1);date_floating(1:end-1)],date_floating,2);

% Find the discounts at the fixed leg payment dates
B_fixed = interpB2(dates,discounts,cf_schedule(:,1));

% C(t0): price of an interbank bond which has the same coupon of the corporate
% bond 
price=sum(cf_schedule(:,2).*B_fixed.*dt_fixed)+B_fixed(end);

% Find the discounts at the floating leg payment dates
B_floating = interpB2(dates,discounts,date_floating);

% Basis Point Value for the floating leg
BPV=sum(B_floating.*dt_floating);

% Asset Swap Spread such that the the Asset Swap is at par
sasw=(price-dirtyprice)/BPV;




