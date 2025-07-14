function [tau] = findTau(u,dates,intensities)

% Compute the default time as yearfraction from t0 in act/365

%INPUT:
% u: random realization of P(0,tau)
% dates: t0 in the first position and dates of payment of the fixed leg
% intensities: hazard rates

% Compute the yearfraction between each date and the following in act/365 (because
% it's used in an exponential)
dt=yearfrac(dates(1:end-1),dates(2:end),3);

% Compute the yearfraction between each date and t0 in act/365 (because it's used 
% in an exponential)
dtstart=yearfrac(dates(1),dates(2:end),3);

% Assume tau is between t0 and t1 and compute tau in such case, next
% verify if the tau found is adequate (i.e. it's in that interval) if yes return it, if no go on with
% the interval (t1,t2]
tau=-log(u)/intensities(1);
if tau<dtstart(1)&&tau>0
    return
end

% Assume tau is between t(ii-1) and t(ii) and compute tau in such case, next
% verify if the tau found is adequate (i.e. it's in that interval) if yes return it, if no go on with
% the following interval
for ii=2:length(intensities)
    tau=-(sum(intensities(1:ii-1).*dt(1:ii-1))+log(u)-intensities(ii)*dtstart(ii-1))/intensities(ii);
    if tau<=dtstart(ii)&&tau>dtstart(ii-1)
        return
    end
end
    
% If the default happens after the expiry of the contract, the contract
% won't work so we don't care about the tau value and we set it to 5
tau=dtstart(end)+1;
   
end %function findTau