function [datesCDS, survProbs, intensities] = bootstrapCDS(datesDF, discounts, datesCDS, spreadsCDS, flag, recovery)

% Compute the survival probabilities and the intensities in the intervals
% between the dates of payment of the spread

% INPUT:
% datesDF: dates of the IR curve (starting from t0)
% discounts: IR curve
% datesCDS: dates of payment of the spread
% spreadsCDS: spread
% flag: 1 (approx), 2 (exact) or 3 (JT)
% recovery: recovery rate

% Compute the discounts in the dates of payment of the spread interpolating
% the curve
discountsCDS = interpB2(datesDF,discounts,datesCDS);

% Compute the yearfraction between each date and the following in 30/360 (because
% it's a swap)
dt=yearfrac([datesDF(1);datesCDS(1:end-1)],datesCDS,6);

% Compute the yearfraction between t0 and each date in act/365 (because tau
% is in act/365)
dtexp=yearfrac([datesDF(1);datesCDS(1:end-1)],datesCDS,3);

switch(flag)

    % 1. approximation (no accrual)
    case 1

        % Inizialize arrays
        l=length(datesCDS);
        survProbs=zeros(l,1);
        survProbs=[1;survProbs];
        intensities=zeros(l,1);

        % Compute survival probabilities and intensities
        survProbs(2)=((1-recovery)*discountsCDS(1))/((1-recovery)*discountsCDS(1)+spreadsCDS(1)*discountsCDS(1)*dt(1));
        intensities(1)=-log(survProbs(2))/dtexp(1);

        for ii=2:l
            survProbs(ii+1)=((1-recovery)*(discountsCDS(ii)*survProbs(ii)+sum(discountsCDS(1:ii-1).*(survProbs(1:ii-1)-survProbs(2:ii))))-spreadsCDS(ii)*(sum(dt(1:ii-1).*discountsCDS(1:ii-1).*survProbs(2:ii))))...
                /(discountsCDS(ii)*(1-recovery)+discountsCDS(ii)*dt(ii)*spreadsCDS(ii));

            intensities(ii)=(-log(survProbs(ii+1))-sum(dt(1:ii-1).*intensities(1:ii-1)))/dtexp(ii);
        end

        % 2. exact (considering the accrual)
    case 2

        % Inizialize arrays
        l=length(datesCDS);
        survProbs=zeros(l,1);
        survProbs=[1;survProbs];
        intensities=zeros(l,1);

        % Compute survival probabilities and intensities
        f=@(p) (1-recovery)*discountsCDS(1)*(1-p)-spreadsCDS(1)*(discountsCDS(1)*dt(1)*p+dt(1)/2*discountsCDS(1)*(1-p));
        survProbs(2)=fzero(f,0);
        intensities(1)=-log(survProbs(2))/dtexp(1);

        for ii=2:l

            f=@(p) (1-recovery)*(sum(discountsCDS(1:ii-1).*(survProbs(1:ii-1)-survProbs(2:ii)))+discountsCDS(ii)*(survProbs(ii)-p))...
                -spreadsCDS(ii)*(sum(dt(1:ii-1).*discountsCDS(1:ii-1).*survProbs(2:ii))+dt(ii)*discountsCDS(ii)*p...
                +(sum(dt(1:ii-1).*discountsCDS(1:ii-1).*(survProbs(1:ii-1)-survProbs(2:ii)))+dt(ii)*discountsCDS(ii)*(survProbs(ii)-p))/2);
            survProbs(ii+1)=fzero(f,0);
            intensities(ii)=(-log(survProbs(ii+1))-sum(dt(1:ii-1).*intensities(1:ii-1)))/dtexp(ii);
        end
        % 3. Jarrow - Turnbull
    case 3
        
        % Compute survival probabilities and intensities
        intensities=spreadsCDS/(1-recovery);
        survProbs=exp(-intensities.*dtexp);

    otherwise
        return
end     %function boostrapCDS
