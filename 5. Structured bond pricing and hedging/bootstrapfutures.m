function [expiries,Bexpiries]=bootstrapfutures(settles,expiries,rates,dates,discounts)

% Compute dates and discounts of futures for IR curve

%INPUT:
%settles: futures' settlement dates
%expiries: futures' expiry dates
%rates: matrix with bid rates of futures in first column and ask in the second
%dates: dates of the IR curve
%discounts: IR curve

% Setting variables
if exist('variables.mat', 'file')
    load variables.mat
else
    error("The variables file doesn't exist")
end

% Compute mid rates
mid=(rates(:,1)+rates(:,2))/2;

% Compute intervals of time, act/360
dt=yearfrac(settles,expiries,Act360);

% Compute forward discounts
Bfwd=1./(1+dt.*mid);

% Inizializing the arrays
Bsettles=zeros(7,1);
Bexpiries=Bsettles;

% The first settlement date's discount is obtained interpolating the curve
Bsettles(1)=interpB2(dates,discounts,settles(1));

for ii=1:length(settles)-1
      
      % Compute the expiry's discount with forward discount
      Bexpiries(ii)=Bsettles(ii)*Bfwd(ii);

      % Compute the settle's discount interpolating
      Bsettles(ii+1)=interpB2([dates;expiries(1:ii)],[discounts;Bexpiries(1:ii)],settles(ii+1));
       
end

% Compute the expiry's discount with forward discount
Bexpiries(end)=Bsettles(end)*Bfwd(end);

end % function bootsrapfutures