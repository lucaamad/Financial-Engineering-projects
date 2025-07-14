function dates=daysb4(dates,number)

% Goes number business days before dates

% INPUT:
% dates: dates
% number: number of business days to go back

for ii=1:number
    dates=businessdates(dates-1,'previous');
end
    
end % function daysB4