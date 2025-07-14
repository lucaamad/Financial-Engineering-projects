function price=capletBach(discounts,dates,libor,K,sigma,settlement,dt)

% Compute the price of caplets using the Bachelier formula

% INPUT:
% discounts: discounts B(t0,ti+1)
% dates: dates of payment of Libor
% libor: forward libor rate
% K: strike
% sigma: volatility
% settlement: settlement date
% dt: deltas (Act/360)

% Setting variables
load variables.mat

% Compute time to maturity
ttm = yearfrac(settlement,dates(1:end-1),Act365);

% Compute the price of caplets using the Bachelier formula
d=(libor-K)./(sigma.*sqrt(ttm));
price=dt.*discounts(2:end).*((libor-K).*normcdf(d)+sigma.*sqrt(ttm).*exp(-d.^2/2)/sqrt(2*pi));
 
end % function capletBach