function [vega_CG,vega_caps_CG]=Vega_bucket_CG(buckets,vega,vega_caps,vega_dates)

% Compute the sensitivity of the structured product and of the caps changing
% of one basis point the flat volatilities of every year (divided into coarse
% grained buckets)

% OUTPUT:
% vega_CG: vega coarse grained sensitivities of the structured product
% vega_caps_CG: vega coarse grained sensitivities of the caps

% INPUT:
% buckets: years of coarse grained buckets
% vegas: vega bucket sensitivities of the structured product
% vegas_caps: vega bucket sensitivities of the caps
% vega_dates: dates of the buckets (in years)

% Setting variables
load variables.mat

% Inizialing arrays
nbuckets=length(buckets);
[~,caps_col]=size(vega_caps);
vega_CG=zeros(nbuckets,1);
vega_caps_CG=zeros(nbuckets,caps_col);

% Select dates for first bucket and compute weights
int_dates=(vega_dates>=buckets(1)).*(vega_dates<=buckets(2));
int_dates=(int_dates==1);
weights=interp1(buckets(1:2),[1;0],vega_dates(int_dates),"linear");

% Compute vega of the first coarse grained bucket
vega_CG(1)=sum(weights.*vega(int_dates))+sum(vega(vega_dates<buckets(1)));
vega_caps_CG(1,:)=sum(weights.*vega_caps(int_dates,:))+sum(vega_caps(vega_dates<buckets(1),:));

for ii=2:nbuckets-1

    % Select dates for ii-th bucket and compute weights
    int_dates=(vega_dates>=buckets(ii-1)).*(vega_dates<=buckets(ii+1));
    int_dates=(int_dates==1);
    weights=interp1(buckets(ii-1:ii+1),[0;1;0],vega_dates(int_dates),"linear");
    
    % Compute vega of the ii-th coarse grained bucket
    vega_CG(ii)=sum(weights.*vega(int_dates));
    vega_caps_CG(ii,:)=sum(weights.*vega_caps(int_dates,:));

end

% Select dates for last bucket and compute weights
int_dates=(vega_dates>=buckets(end-1)).*(vega_dates<=buckets(end));
int_dates=(int_dates==1);
weights=interp1(buckets(end-1:end),[0;1],vega_dates(int_dates),"linear");

% Compute vega of the last coarse grained bucket
vega_CG(end)=sum(weights.*vega(int_dates));
vega_caps_CG(end,:)=sum(weights.*vega_caps(int_dates,:));

end % function Vega_bucket_CG