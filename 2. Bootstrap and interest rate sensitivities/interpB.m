function B=interpB(dates,discounts,query)

% Compute the discount factor of a date, interpolating the zero rates or
% extrapolating if the query date is after all the dates

% INPUT:

% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% query: date of which find the discount

%extrapolate
if query>dates(end)
    d=[dates(1);dates(end-1:end)];
    % Compute zero rates, extrapolate, return to discounts
    zr=zeroRates(d,[1;discounts(end-1:end)]);
    B=discountfactors([dates(1);query],interp1(dates(end-1:end),zr(2:end),query,'nearest','extrap'));
    

%assign
elseif ismember(query,dates) 
    B=discounts(dates==query);

%interpolate
else
    z=find(query>dates);
    z=z(end); % index of the first date before query
    d=[dates(1);dates(z:z+1)];
    % Compute zero rates, interpolate, return to discounts
    zr=zeroRates(d,[1;discounts(z:z+1)]);
    B=discountfactors([dates(1);query],interp1(dates(z:z+1),zr(2:end),query));
    
end

end %function interpB