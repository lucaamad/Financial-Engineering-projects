function [expiries,Bexpiries]=bootstrapfutures(settles,expiries,rates,dates,discounts)

% Compute dates and discounts of futures for IR curve

%INPUT:
%settles: futures' settlement dates
%expiries: futures' expiry dates
%rates: matrix with bid rates of futures in first column and ask in the second
%dates: dates of the IR curve
%discounts: IR curve


% Compute mid rates
mid=(rates(:,1)+rates(:,2))/2;

% Compute intervals of time, act/360
dt=yearfrac(settles,expiries,2);

% Compute forward discounts
Bfwd=1./(1+dt.*mid);

% Inizializing the arrays
Bsettles=zeros(7,1);
Bexpiries=Bsettles;

% The first settlement date's discount is the last discount in the curve
Bsettles(1)=discounts(end);

% If the current future's settlement date is after the previous future's
% expiry date (for the first case) we have to find the next future's settlement
% date's discount interpolating/extrapolating with the current future's 
% settlement and expiry date; otherwise we use the expiries of previous and 
% current futures [flag]
flag=1;

for ii=1:length(settles)-1
      
      % Compute the expiry's discount with forward discount
      Bexpiries(ii)=Bsettles(ii)*Bfwd(ii);      
      
      % If the next future's settlement date is after the current future's
      % expiry date, we have to extrapolate
      if settles(ii+1)>expiries(ii)
          if flag==1  % see [flag]
            Bsettles(ii+1)=interpB([dates(1);settles(ii);expiries(ii)],[1;Bsettles(ii);Bexpiries(ii)],settles(ii+1));
          else % see [flag]
            Bsettles(ii+1)=interpB([dates(1);expiries(ii-1:ii)],[1;Bexpiries(ii-1:ii)],settles(ii+1));
          end
          flag=1; % see [flag]

      %If the next future's settlement date is the current future's
      % expiry date, we have already the discount factor
      elseif settles(ii+1)==expiries(ii)
            Bsettles(ii+1)=Bexpiries(ii);
      
      %If the next future's settlement date is before the current future's
      % expiry date, we have interpolate
      else   
         if flag==1 % see [flag]
            Bsettles(ii+1)=interpB([dates(1);settles(ii);expiries(ii)],[1;Bsettles(ii);Bexpiries(ii)],settles(ii+1));
         else % see [flag]
             % datetime(expiries(ii-1:ii),'ConvertFrom','datenum')
             Bsettles(ii+1)=interpB([dates(1);expiries(ii-1:ii)],[1;Bexpiries(ii-1:ii)],settles(ii+1));
         end
         flag=0; % see [flag]
      end
       
end

% Compute the expiry's discount with forward discount
Bexpiries(end)=Bsettles(end)*Bfwd(end);

end % function bootsrapfutures