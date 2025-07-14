function [params, error, price_mkt] = calibration(strikes, surf, B, T, F0, alpha)

% Calibrate a NMVM model parameters considering SP500 volatility surface

% INPUT:
% strikes: set of the strikes of the surface
% surf: set of the volatilities of the surface
% B: discount at the time to maturity
% T: time to maturity
% F0: price of the forward at time t0
% alpha: choice of distribution

% OUTPUT:
% params: vector of the parameters, where
% - params(1): sigma, average volatility
% - params(2): eta, skew
% - params(3): k, volatility of the volatility
% error: MSE of difference between model and market prices

% From the volatility surface compute the prices using Black model
d1 = log(F0./strikes)./(sqrt(T)*surf) + 0.5*sqrt(T)*surf;
d2 = log(F0./strikes)./(sqrt(T)*surf) - 0.5*sqrt(T)*surf;
price_mkt = B*(F0*normcdf(d1) - strikes.*normcdf(d2));

% Find the set of parameters that minimizes the loss function (MSE) and
% respects the nonlinear constraint eta > -(1-alpha)/(k*sigma^2)
x0 = [0.15; 2; 1];
LB = [0; -10; 0];
UB = [10; 10; 10];
[params, error] = lsqnonlin(@(params) fun(params, F0, B, T, alpha, price_mkt, strikes),...
    x0, LB, UB, [], [], [], [], @nonlcon);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dp = fun(params, F0, B, T, alpha, price_mkt, strikes)

% Compute 
%            f(params) = price_model(params) - price_market 
% for all the strikes

% Compute the model prices using FFT
[price_lewis, x]=LewisFFT(B,F0,alpha,params(2),params(1),params(3),T,14,-400,1);

% Compute the logmoneyness from the strikes
K = F0*exp(-x);

% Extract the prices regarding the set of strikes
price_model = interp1(K,price_lewis,strikes);

% Calculate the difference between model prices and market prices
dp = price_model - price_mkt;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [c,ceq] = nonlcon(x)

% Impose the nonlinear constraint 
%                  eta > -(1-alpha)/(k*sigma^2)
% where x(1): sigma, x(2): eta, x(3): k and alpha = 1/3

c = - (x(1).^2.*x(2).*x(3) + 1 - 1/3);     % Compute nonlinear inequalities at x
ceq = [];   % Compute nonlinear equalities at x
end