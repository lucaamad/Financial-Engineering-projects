function sigma=spotvol(vol,y,strike,dates,discounts,floating_dates,dt)

% Compute the spot volatility with respect to time and strike, starting
% from the flat volatility

% INPUT:
% vol: matrix of flat volatilities (rows are diffrent times and columns
% different strikes)
% y: years
% strike: strikes
% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% floating_dates: dates of payment of the floating leg
% dt: deltas (Act/360)

% Setting variables
load variables.mat

% Inizialing arrays
sigma=zeros(y(end)*4,length(strike));

% Select the dates of the caplets
dates_float=floating_dates(1:4*y(end));

% Compute discounts in the caplets' dates
disc_float=interpB2(dates,discounts,dates_float);

% Compute forward discounts and forward libor
fwd_disc=disc_float./[1;disc_float(1:end-1)];
libor = (1./fwd_disc-1)./dt;

% The three months caplet doesn't exist and the the first year spot
% volatility is equal to the flat
sigma(1,:)=NaN;
sigma(2,:)=vol(1,:);
sigma(3,:)=vol(1,:);
sigma(4,:)=vol(1,:);

for jj=1:length(strike)
    lastsigma=sigma(4,jj);
    for ii=2:length(y) 

            dt3=yearfrac(dates_float(4*y(ii-1)),dates_float(4*y(ii-1)+1:4*y(ii)),Act365);
            Dt3=yearfrac(dates_float(4*y(ii-1)),dates_float(4*y(ii)),Act365);
            
            % Compute the difference of caps using flat volatilities
            cap1=sum(capletBach(disc_float(1:4*y(ii-1)),dates_float(1:4*y(ii-1)),libor(2:4*y(ii-1)),strike(jj),vol(ii-1,jj),dates(1),dt(2:4*y(ii-1))));
            cap2=sum(capletBach(disc_float(1:4*y(ii)),dates_float(1:4*y(ii)),libor(2:4*y(ii)),strike(jj),vol(ii,jj),dates(1),dt(2:4*y(ii))));
            deltacap=cap2-cap1;

            % Compute spot volatilities imposing the difference of the caps equal 
            fun=@(t) sum(capletBach(disc_float(4*y(ii-1):4*y(ii)),dates_float(4*y(ii-1):4*y(ii)),libor(4*y(ii-1)+1:4*y(ii)),strike(jj),lastsigma+dt3/Dt3*(t-lastsigma),dates(1),dt(4*y(ii-1)+1:4*y(ii))))-deltacap;
            newsigma=fzero(fun,1e-4);
            sigma(4*y(ii-1)+1:4*y(ii),jj)=lastsigma+dt3/Dt3*(newsigma-lastsigma);
            lastsigma=newsigma;        
    end

end

end % function spotvol