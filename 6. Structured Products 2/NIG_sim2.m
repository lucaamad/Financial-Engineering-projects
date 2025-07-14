function [F] = NIG_sim2(Nsim,sigma,k,eta,ttm,F0,B,div)

% Compute the value of the underlying forward at two years considering a 
% Normal Inverse Gaussian model and a Monte Carlo method (with path
% dependence)

% INPUT:
% Nsim: number of Monte Carlo simultions
% sigma: average volatility
% volofvol: volatility of the volatility
% eta: skew
% ttm: time to maturity
% F0: price of the forward at time t0

% Simulate random components

if iscolumn(ttm)
    ttm=ttm';
end
if iscolumn(B)
    B=B';
end
y=length(ttm);

g=randn(Nsim,y);

G=zeros(Nsim,y);

for ii=1:y
    G(:,ii)=random('InverseGaussian',1,ttm(ii)/k,Nsim,1);
end

% Compute stock value
sim=sqrt(ttm)*sigma.*sqrt(G).*g-(1/2+eta)*ttm*sigma^2.*G-ttm/k*(1-sqrt(1+2*k*eta*sigma^2));

% Compute value
F=zeros(Nsim,y);
F(:,1) = F0*exp(sim(:,1));
    for ii = 2:y
        F(:,ii)=F(:,ii-1).*exp(sim(:,ii))/B(ii)*exp(-div*ttm(ii));
    end

end % function NIG_sim2