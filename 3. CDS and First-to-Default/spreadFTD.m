function [spread,IC]=spreadFTD(mu,A,dates,intensities1,intensities2,Nsim,recovery,discounts,datesB,discountsB)

% Compute the Monte Carlo price and confidence interval

%INPUT:
% mu: mean of the gaussian copula
% A: Cholensky decomposition fo the sigma matrix
% dates: t0 in the first position and dates of payment of the fixed leg
% intensities1: hazard rates of the first firm
% intensities2: hazard rates of the second firm
% Nsim: number of Monte Carlo simulations
% recovery: array with the recovery rates of the two firms
% discounts: discount factors of the dates of payment of the fixed leg

% Inizialize array
contingent=zeros(Nsim,1);
fee=zeros(Nsim,1);

% Compute the yearfraction between each date and the following in 30/360 (because
% it's a swap)
dt=yearfrac(dates(1:end-1),dates(2:end),6);

% Compute the yearfraction between t0 and each date in act/365 (because tau
% is in act/365)
dtstart=yearfrac(dates(1),dates(2:end),3);

rng(123);

for ii=1:Nsim
    % Simulate the Gaussian copula
    u=simulateCopula(mu,A);
  
    % Find the times of default and the first time to default
    tau1 = findTau(u(1),dates,intensities1);
    tau2 = findTau(u(2),dates,intensities2);
    [tau,failed]=min([tau1,tau2]);
    
    % If the smaller time to default is bigger than the maturity of the
    % first to default, if I am the buyer of the contract I pay the fee leg
    % until maturity without earning the loss given default
    if tau>dtstart(end)
        
        check=tau>dtstart;
        dtch=dt(check);
        discountsch=discounts(check);
        fee(ii)=sum(discountsch.*dtch);
        
    % if the smaller time to default is within the first fee leg payment date of the
    % contract, if I am the buyer of the contract I pay the accrual and I
    % receive the contingent leg at time to default 
    elseif tau<=dtstart(1)
        
        discount_tau=interpB2(datesB,discountsB,datesB(1)+tau*365);
        fee(ii)=tau*discount_tau;
        contingent(ii)=discount_tau*(1-recovery(failed));
   
    % If time to default is between two fee leg payment dates, if I buy the
    % contract I pay the spread until the last fee leg payment date before
    % time to default, I pay the accrual and I receive the contingent leg
    % at time to default
    else
        check=tau>dtstart;
        dtch=dt(check);
        dtstartch=dtstart(check);
        discountsch=discounts(check);
        discount_tau=interpB2(datesB,discountsB,datesB(1)+tau*365);
        fee(ii)=sum(discountsch.*dtch)+discount_tau*(tau-dtch(end));
        contingent(ii)=(1-recovery(failed))*discount_tau;
    end
    
end

% Monte Carlo value
spread=sum(contingent)/sum(fee);

% Computation of confidence interval
cmean=mean(contingent);
fmean=mean(fee);
sigmac=var(contingent)/Nsim;
sigmaf=var(fee)/Nsim;
covariance=cov(contingent,fee)/Nsim;
covariance=covariance(1,2);

alpha=0.05;
t=tinv(1-alpha/2,Nsim-1);

lowlim=((cmean*fmean-t^2*covariance)-sqrt((cmean*fmean-t^2*covariance)^2-(cmean^2-t^2*sigmac)*(fmean^2-t^2*sigmaf)))/(fmean^2-t^2*sigmaf);
uplim=((cmean*fmean-t^2*covariance)+sqrt((cmean*fmean-t^2*covariance)^2-(cmean^2-t^2*sigmac)*(fmean^2-t^2*sigmaf)))/(fmean^2-t^2*sigmaf);

% Confidence interval
IC=[lowlim;uplim];

end