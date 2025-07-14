function [business]=businessdates(dates,country)

% Compute the first b

% INPUT:
% dates: dates to check
% country: selection of hollidays

% The standard is Europe
if nargin<2
    country=1;
end

% Compute the years we are considering
y=unique(year(dates));

% Make year a row vector
if iscolumn(y)
    y=y';
end

% Select convention (so far only Europe)
switch (country)
    case 1 %Europe
    
    % Select dates of New Year's Day, International Workers Day, Christmas
    % (gregorian calendar), Boxing day
    newyear=datetime(y,1,1);
    workers=datetime(y,5,1);
    xmas=datetime(y,12,25);
    s_stephen=datetime(y,12,26);

    % Select dates of easter (by GitHub, Cardillo G. (2007). Easter: an 
    % Easter Day calculator based on the Gauss algorithm).
    easters=datetime(easter(y,verbose=0),'ConvertFrom','datenum');
    
    % Select dates of Good Friday and Easter Monday
    g_friday=easters-caldays(2);
    e_monday=easters+caldays(1);
    
    % Put together hollidays
    holly=[newyear, workers, xmas, s_stephen, g_friday, e_monday];    
end

% Check that the dates are not holidays.
% Function "busdate" checks that the following day is not a holiday, hence
% we apply it to the preceeding days of the vector "date_floating".
business=busdate(dates-1,"follow",holly);
business=datenum(business);

end % function businessdates