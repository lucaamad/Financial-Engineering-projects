function [vegas,vega_caps]=Vega_bucket(dates,discounts,strike,y,vol,K,s_spol_A,s_spol_B,caplet1,X,ttmcaps,Kcaps,caps,floating_dates,dt360,NPV0)

% Compute the sensitivity of the structured product changing of one basis
% point the flat volatilities of every year (one by one)

% OUTPUT:
% vegas: vega bucket sensitivities of the structured product
% vegas_caps: vega bucket sensitivities of the caps

% INPUT:
% dates: dates of the IR curve (starting from t0)
% discounts: IR curve
% strike: strikes (table of flat volatitilies)
% y: years
% vol: flat volatilities
% K: strikes (caplets of structured product)
% s_spol_A: spread of part A
% s_spol_B: spread of part B
% caplet1: percentage of (extra) caplet at three months
% X: price (paid by part B)
% floating_dates: dates of payment of the floating leg
% dt360: deltas (Act/360)
% NPV0: Net Present Value of the structured product

% If NPV0 is omitted, let's consider it zero
if nargin<16
    NPV0=0;
end

% Inizialize array
l=length(y);
vegas=zeros(l,1);
ncaps=length(ttmcaps);
vega_caps=zeros(l,ncaps);

for ii=1:l
    
    fprintf("--- Years: %d ---\n",y(ii))
    
    % Increase flat volatilities
    vol(ii,:)=vol(ii,:)+1e-4;

    % Compute new spot volatilities
    spot_vol=spotvol(vol,y,strike,dates,discounts,floating_dates,dt360);
    
    % Compute NPV with new IR curve and new spot volatilities
    [NPVa,NPVb]=NPVstructure(dates,discounts,spot_vol,strike,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt360,X);
    vegas(ii)=NPVa-NPVb-NPV0;

    for jj=1:ncaps
        % dates_float=datetime(dates(1),'ConvertFrom','datenum')+calmonths(3:3:ttmcaps(jj)*12)';
        % dates_float=businessdates(dates_float);
        dates_float=floating_dates(1:ttmcaps(jj)*4);
        dt=dt360(1:ttmcaps(jj)*4);
        disc_float=interpB2(dates,discounts,dates_float);

        fwd_disc=disc_float./[1;disc_float(1:end-1)];
        % dt = yearfrac([dates(1);dates_float(1:end-1)],dates_float,Act360);
        libor = (1./fwd_disc-1)./dt;

        sigma2=interp1(strike,spot_vol(2:ttmcaps(jj)*4,:)',Kcaps(jj),'spline')';

        % Compute the sensitivity of the cap
        vega_caps(ii,jj)=sum(capletBach(disc_float(1:ttmcaps(jj)*4),dates_float(1:ttmcaps(jj)*4),libor(2:end),Kcaps(jj),sigma2,dates(1),dt(2:ttmcaps(jj)*4)))-caps(jj);
    end

    % Decrease flat volatilities
    vol(ii,:)=vol(ii,:)-1e-4;
end

end % function Vega_bucket