function price=tree3(dates_curve,discounts_curve,strike,dates_years,a,sigma,nodes,flag,expiry)

% Compute the price of a Bermudan/European payer swaption using a trinomial
% tree under Hull-White model

% INPUT:
% dates_curve: dates of the IR curve
% discounts_curve: IR curve
% strike: swaption's strike
% dates_years: dates of the years (t0,t1, exercises of the swaption)
% a: Hull-White parameter
% sigma: Hull-White parameter
% nodes: number of nodes
% flag: 0 Bermudan, 1 European
% expiry: dates of exercise of the european

% Standard is Bermudan
if nargin<8
    flag=0;
end

% Setting variables
load variables.mat

% Setting number of nodes to 1 mod 10
if mod(nodes,10)==0
   nodes=nodes+1;
elseif mod(nodes,10)~=1
   nodes=nodes+11-mod(nodes,10);
end

% Number of years
n=length(dates_years)-1;
deltat=n/(nodes-1);

% Dates of check between intrinsic and continuation value
check_bermuda=linspace(1,nodes,n+1)';
years=zeros(1,nodes);
years(check_bermuda)=0:n;

% Compute dt and get discounts interpolating in the selected dates
dt_nodes=deltat*(0:nodes-1)';
discounts_nodes=interpB_dt(dates_curve,discounts_curve,dt_nodes);
discounts_years=interpB2(dates_curve,discounts_curve,dates_years);
discounts_years(1)=1;

% Dates of check between intrinsic and continuation value
if flag
    check_bermuda=[check_bermuda(expiry+1);0];
else
    check_bermuda=check_bermuda(3:end);
end

% Compute tree's parameters
muhat=1-exp(-a*deltat);
sigmahat=sigma*sqrt((1-exp(-2*a*deltat))/(2*a));
dx=sqrt(3)*sigmahat;
lmax=ceil((1-sqrt(2/3))/muhat);
l=(lmax:-1:-lmax)';
l_short=l(2:end-1);
x=l*dx;

% Probabilities of go up, down or remain on the same level in the tree
% in the standard case
puA=(1/3-l_short*muhat+(l_short*muhat).^2)/2;
pmA=2/3-(l_short*muhat).^2;
pdA=(1/3+l_short*muhat+(l_short*muhat).^2)/2;

% Probabilities of go up, down or remain on the same level in the tree
% in the extreme bottom case
puB=(1/3-lmax*muhat+(lmax*muhat)^2)/2;
pmB=-1/3+2*lmax*muhat-(lmax*muhat)^2;
pdB=(7/3-3*lmax*muhat+(lmax*muhat)^2)/2;

% Probabilities of go up, down or remain on the same level in the tree
% in the extreme top case
pdC=(1/3-lmax*muhat+(lmax*muhat)^2)/2;
pmC=-1/3+2*lmax*muhat-(lmax*muhat)^2;
puC=(7/3-3*lmax*muhat+(lmax*muhat)^2)/2;


Tau=deltat*ones(1,nodes-1);
forward=(discounts_nodes(2:end)./discounts_nodes(1:end-1))';
sigma0=sigma/a*(1-exp(-a*Tau));
B=forward.*exp(-x*sigma0/sigma-1/2*(sigma/a)^2*(2/a*(1-exp(-a*Tau)).*(1-exp(-a*dt_nodes(2:end)'))-1/(2*a)*(1-exp(-2*a*Tau)).*(1-exp(-2*a*dt_nodes(2:end)'))));
sigma_star=sigma/a*sqrt(deltat-2*(1-exp(-a*deltat))/a+(1-exp(-2*a*deltat))/(2*a));
dtEU=yearfrac(dates_years(1:end-1),dates_years(2:end),EU30);

% Inizializing arrays
tree=zeros(2*lmax+1,nodes);
tau=ones(1,10);
if iscolumn(dtEU)
    dtEU=dtEU';
end

if iscolumn(tau)
    tau=tau';
end

% Stochastic discount factors going up, down or remaining on the same level
% in the extreme top case
duC=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(muhat*x(1)))*B(1,:);
dmC=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(-dx*exp(-a*deltat)+muhat*x(2)))*B(1,:);
ddC=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(-2*dx*exp(-a*deltat)+muhat*x(3)))*B(1,:);

% Stochastic discount factors going up, down or remaining on the same level
% in the extreme bottom case case
ddB=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(muhat*x(end)))*B(end,:);
dmB=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(dx*exp(-a*deltat)+muhat*x(end-1)))*B(end,:);
duB=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(2*dx*exp(-a*deltat)+muhat*x(end-2)))*B(end,:);

% Stochastic discount factors going up, down or remaining on the same level
% in the standard case
dmA=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(muhat*x(2:end-1))).*B(2:end-1,:);
duA=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(dx*exp(-a*deltat)+muhat*x(1:end-2))).*B(2:end-1,:);
ddA=exp(-1/2*sigma_star^2-sigma_star/sigmahat*(-dx*exp(-a*deltat)+muhat*x(3:end))).*B(2:end-1,:);

% Climb the three
for ii   =  check_bermuda(end-1):-1:1
      
     % Compute the continuation value
     tree(1,ii)=puC*tree(1,ii+1)*duC(ii)+pmC*tree(2,ii+1)*dmC(ii)+pdC*tree(3,ii+1)*ddC(ii);
     tree(end,ii)=puB*tree(end-2,ii+1)*duB(ii)+pmB*tree(end-1,ii+1)*dmB(ii)+pdB*tree(end,ii+1)*ddB(ii);
     tree(2:end-1,ii)=puA.*tree(1:end-2,ii+1).*duA(:,ii)+pmA.*tree(2:end-1,ii+1).*dmA(:,ii)+pdA.*tree(3:end,ii+1).*ddA(:,ii);
      
      
     if ismember(ii,check_bermuda)
       
       % Compute the present value of the swap
       fwd=(discounts_years(years(ii)+2:end)/discounts_years(years(ii)+1))';
       sigma0=sigma/a*(1-exp(-a*cumsum(tau(years(ii)+1:end))));
       int=(sigma/a)^2*(2/a*(1-exp(-a*cumsum(tau(years(ii)+1:end))))*(1-exp(-a*(years(ii))))-1/(2*a)*(1-exp(-2*a*cumsum(tau(years(ii)+1:end))))*(1-exp(-2*a*(years(ii)))));
       discounts=fwd.*exp(-x*sigma0/sigma-1/2*int);
       NPVswap=NPV_swap(dtEU(years(ii)+1:end),discounts,strike);
       
       % Select the max between the intrinsic and continuation value
       tree(:,ii)=max(tree(:,ii),NPVswap);
       
    end

end

% The price is the value in the first node
price=tree(lmax+1,1); 

end % function tree3