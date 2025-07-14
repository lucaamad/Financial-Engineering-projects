function [R] = R_IRB(PD)

% Compute correlation with IRB formula in the case of large corporate

% INPUT:
% PD: probability of default

% Fix parameters
Rmin=0.12;
Rmax=0.24;
k=50;

% Apply IRB formula
R=(Rmin*(1-exp(-k*PD))+Rmax*exp(-k*PD))/(1-exp(-k));

end %function R_IRB