function [delta,dates_delta,delta_swaps,delta_caps]=Delta_bucket(datesSet,ratesSet,strike,spot_vol,K,s_spol_A,s_spol_B,caplet1,X,ttmswaps,ttmcaps,Kcaps,caps,floating_dates,dt360,NPV0)

% Compute the sensitivity of the structured product, of the swaps and of the
% caps changing of one basis point the rate of every instrument used to 
% compute the IR curve (one by one)

% OUTPUT:
% delta: delta bucket sensitivities of the structured product
% dates_delta: dates of the buckets
% delta_swaps: delta bucket sensitivities of the swaps
% delta_caps: delta bucket sensitivities of the caps

% INPUT:
% datesSet: struct of dates
%   datesSet.depos: expiry dates of the deposits
%   datesSet.futures: matrix with settlement dates of the futures in the
%       first column and expiry dates of the futures in the second column
%   datesSet.swaps: expiry dates of the swaps
%   datesSet.settlemnt: settlement date
% ratesSet: struct of rates
%   ratesSet.depos: bid and ask rates of deposits
%   ratesSet.futures: bid and ask rates of futures at expiry date
%   ratesSet.swaps: bid and ask rates of swaps
% strike: strikes (table of flat volatitilies)
% spot_vol: spot volatilities
% K: strikes (caplets of structured product)
% s_spol_A: spread of part A
% s_spol_B: spread of part B
% caplet1: percentage of (extra) caplet at three months
% X: price (paid by part B)
% ttmswaps: expiries of the swaps
% ttmcaps: expiries of the caps
% Kcaps: strikes (caps)
% caps: Net Present value of the caps
% floating_dates: dates of payement of the floating leg
% dt360: delta (Act/360)
% NPV0: Net Present Value structured product

% If NPV0 is omitted, let's consider it zero
if nargin<16
    NPV0=0;
end

% Compute spread of the swaps
S = (ratesSet.swaps(ttmswaps,1)+ratesSet.swaps(ttmswaps,2))/2;

% Take deposits date until the settlement date of the first future and the very
% next
z=find(datesSet.futures(1,1)<=datesSet.depos);
numdepos=z(1);

% Take the first seven futures
numfutures=7;

% Take the non NaN swaps
idx=find(~isnan(ratesSet.swaps(:,1)));
numswaps=length(idx);

% Compute number of swaps and caps by length of time to maturity
nswap=length(ttmswaps);
ncap=length(ttmcaps);

% Inizializing arrays
delta=zeros(numdepos+numswaps+numfutures-1,1);
dates_delta=zeros(numdepos+numswaps+numfutures-1,1);
delta_swaps=zeros(numdepos+numswaps+numfutures-1,nswap);
delta_caps=zeros(numdepos+numswaps+numfutures-1,ncap);

% Depos
for ii=1:numdepos
    
    fprintf("--- Deposit %d ---\n",ii)
    
    % Increase rates
    ratesSet.depos(ii,:)=ratesSet.depos(ii,:)+1e-4;
    
    % Compute new IR curve
    [dates, discounts]=bootstrap(datesSet, ratesSet);
       
    % Compute NPV with new IR curve
    [NPVa,NPVb]=NPVstructure(dates,discounts,spot_vol,strike,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt360,X);
    dates_delta(ii)=datesSet.depos(ii);
    delta(ii)=NPVa-NPVb-NPV0;
    
    % Compute swaps NPV with new IR curve
    for jj=1:nswap
        [NPVa,NPVb]=NPVswap(dates,discounts,ttmswaps(jj),floating_dates);
        delta_swaps(ii,jj)=NPVa-S(jj)*NPVb; % da decidere se payer o receiver
    end
    
    % Compute caps NPV with new IR curve
    for jj=1:ncap
      
        dates_float=floating_dates(1:ttmcaps(jj)*4);
        dt=dt360(1:ttmcaps(jj)*4);
        disc_float=interpB2(dates,discounts,dates_float);
        fwd_disc=disc_float./[1;disc_float(1:end-1)];
        libor = (1./fwd_disc-1)./dt;
        sigma2=interp1(strike,spot_vol(2:ttmcaps(jj)*4,:)',Kcaps(jj),'spline')';
        delta_caps(ii,jj)=sum(capletBach(disc_float(1:ttmcaps(jj)*4),dates_float(1:ttmcaps(jj)*4),libor(2:end),Kcaps(jj),sigma2,dates(1),dt(2:ttmcaps(jj)*4)))-caps(jj);
    end

    % Decrease rates
    ratesSet.depos(ii,:)=ratesSet.depos(ii,:)-1e-4;

end

% Futures
for ii=1:numfutures
    
    fprintf("--- Futures %d ---\n",ii)
    
    % Increase rate
    ratesSet.futures(ii,:)=ratesSet.futures(ii,:)+1e-4;

    % Compute new IR curve
    [dates, discounts]=bootstrap(datesSet, ratesSet);

    % Compute NPV with new IR curve
    [NPVa,NPVb]=NPVstructure(dates,discounts,spot_vol,strike,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt360,X);
    delta(ii+numdepos)=NPVa-NPVb-NPV0;
    dates_delta(ii+numdepos)=datesSet.futures(ii,2);
    
    % Compute swaps NPV with new IR curve
    for jj=1:nswap
        [NPVa,NPVb]=NPVswap(dates,discounts,ttmswaps(jj),floating_dates);
        delta_swaps(ii+numdepos,jj)=NPVa-S(jj)*NPVb; % da decidere se payer o receiver
    end
    
    % Compute caps NPV with new IR curve
    for jj=1:ncap
       
        dates_float=floating_dates(1:ttmcaps(jj)*4);
        dt=dt360(1:ttmcaps(jj)*4);
        disc_float=interpB2(dates,discounts,dates_float);
        fwd_disc=disc_float./[1;disc_float(1:end-1)];
        libor = (1./fwd_disc-1)./dt;
        sigma2=interp1(strike,spot_vol(2:ttmcaps(jj)*4,:)',Kcaps(jj),'spline')';
        delta_caps(ii+numdepos,jj)=sum(capletBach(disc_float(1:ttmcaps(jj)*4),dates_float(1:ttmcaps(jj)*4),libor(2:end),Kcaps(jj),sigma2,dates(1),dt(2:ttmcaps(jj)*4)))-caps(jj);
    end

    % Decrease rates
    ratesSet.futures(ii,:)=ratesSet.futures(ii,:)-1e-4;

end

% Swaps
for ii=2:numswaps
    
    fprintf("--- Swaps %d ---\n",ii)
    
    % Increase rates
    ratesSet.swaps(idx(ii),:)=ratesSet.swaps(idx(ii),:)+1e-4;
    
    % Compute new IR curve
    [dates, discounts]=bootstrap(datesSet, ratesSet);

    % Compute NPV with new IR curve and new spot volatilities
    [NPVa,NPVb]=NPVstructure(dates,discounts,spot_vol,strike,K,s_spol_A,s_spol_B,caplet1,floating_dates,dt360,X);
    delta(ii+numdepos+numfutures-1)=NPVa-NPVb-NPV0;
    dates_delta(ii+numdepos+numfutures-1)=datesSet.swaps(idx(ii));
    
    % Compute swaps NPV with new IR curve
    for jj=1:nswap
        [NPVa,NPVb]=NPVswap(dates,discounts,ttmswaps(jj),floating_dates);
        delta_swaps(ii+numdepos+numfutures-1,jj)=NPVa-S(jj)*NPVb; % da decidere se payer o receiver
    end
    
    % Compute caps NPV with new IR curve
    for jj=1:ncap
       
        dates_float=floating_dates(1:ttmcaps(jj)*4);
        dt=dt360(1:ttmcaps(jj)*4);
        disc_float=interpB2(dates,discounts,dates_float);
        fwd_disc=disc_float./[1;disc_float(1:end-1)];
        libor = (1./fwd_disc-1)./dt;
        sigma2=interp1(strike,spot_vol(2:ttmcaps(jj)*4,:)',Kcaps(jj),'spline')';
        delta_caps(ii+numdepos+numfutures-1,jj)=sum(capletBach(disc_float(1:ttmcaps(jj)*4),dates_float(1:ttmcaps(jj)*4),libor(2:end),Kcaps(jj),sigma2,dates(1),dt(2:ttmcaps(jj)*4)))-caps(jj);
    end

    % Decrease rates
    ratesSet.swaps(idx(ii),:)=ratesSet.swaps(idx(ii),:)-1e-4;

end

end % function Delta_bucket