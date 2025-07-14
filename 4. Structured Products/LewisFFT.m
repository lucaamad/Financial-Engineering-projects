function [price,z]=LewisFFT(B,F0,alpha,eta,sigma,volofvol,ttm,M,parameter,flag)

% Compute the price of a european call using the Lewis formula and
% approximating the integral with a fast Fourier transform

% INPUT:
% B: discount at the time to maturity
% F0: price of the forward at time t0
% alpha: choice of distribution
% eta: skew
% sigma: average volatility
% volofvol: volatility of the volatility
% ttm: time to maturity
% M: logarithm in basis 2 pf the number of points for the fast Fourier transform
% parameter: value parameter of fast Fourier transform, can be x1 or dz
% flag = 1 parameter is x1, 2 parameter is dz

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

% Compute parameter of the fast Fourier transform
N=2^M;
switch (flag)
    case 1
        if parameter<0
            x1=parameter;
        else 
            % Check that x1 is negative, if it isn't we use the opposite
            warning('x1 must be negative')
            x1=-parameter;
        end

        dx=-2*x1/(N-1);
        dz=2*pi/(N*dx);
    case 2
        dz=parameter;
        dx=2*pi/(N*dz);
        x1=-(N-1)*dx/2;
end
z1=-(N-1)*dz/2;
x=(x1:dx:-x1)';
z=(z1:dz:-z1)';

% Compute the argoment of the Fourier transform
fj=@(t) phi(-t-1i/2)./(t.^2+1/4)/(2*pi);

% figure(15)
% semilogy(x,abs(fj(x)))
% grid on

% Compute the fast Fourier transform 
fourier=(dx*exp(-1i*x1.*z)).*fft(fj(x).*exp(-1i*z1*dx.*(0:N-1)'));

% Neglect the imaginary part
fourier=real(fourier);

% Compute the price
price=B*F0*(1-exp(-z/2).*fourier);

end % function LewisFFT