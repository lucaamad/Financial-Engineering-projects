function price=LewisQuad(B,F0,alpha,eta,sigma,volofvol,ttm,logmoneyness,threshold)

% Compute the price of a European call using the Lewis formula and
% approximating the integral with a numeric method

% INPUT:
% B: discount at the time to maturity
% F0: price of the forward at time t0
% alpha: choice of distribution
% eta: skew
% sigma: average volatility
% volofvol: volatility of the volatility
% ttm: time to maturity
% logmoneyness: value of logmoneyness in which compute the price
% threshold: absolute/relative errore for the Matlab function integral

% Compute value of the Laplace transform in the different case of alpha
% (alpha ==0 is actually the limit for alpha which goes to zero)
if alpha>0 && alpha<1
    LapExp=@(w) ttm/volofvol*(1-alpha)/alpha*(1-(1+(w*volofvol*sigma^2)/(1-alpha)).^alpha);
elseif alpha==1
    LapExp=0;
elseif alpha==0
    LapExp=@(w) -ttm/volofvol*log(1+volofvol*w*sigma^2);
else
    disp('Alpha must be between 0 and 1')
    return
end

% Computing the characteristic function
phi= @(t) exp(-1i*t*LapExp(eta)).*exp(LapExp((t.^2+(1i)*(1+2*eta)*t)/2));


l=length(logmoneyness);
quad=zeros(l,1);
for ii=1:l    
    integrand=@(t) 1/(2*pi)*exp(-1i*t*logmoneyness(ii)).*phi(-t-1i/2)./(t.^2+1/4);
    quad(ii)=integral(integrand,-Inf,Inf,"AbsTol",threshold,"RelTol",threshold);
end

% Compute the price
price=B*F0*(1-exp(-logmoneyness/2).*quad);

end % function LewisQuad