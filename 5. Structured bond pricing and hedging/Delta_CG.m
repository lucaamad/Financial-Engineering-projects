function [delta_CG,delta_swaps_CG,delta_caps_CG]=Delta_CG(buckets,settlement,delta,delta_dates,delta_swaps,delta_caps)%,ratesSet)

% Compute the sensitivity of the structured product, of the swaps and of the
% caps changing of one basis point the rate of every instrument used to 
% compute the IR curve (divided into coarse grained buckets)

% OUTPUT:
% delta_CG: delta coarse grained sensitivities of the structured product
% delta_swaps_CG: delta coarse grained sensitivities of the swaps
% delta_caps_CG: delta coarse grained sensitivities of the caps

% INPUT:
% buckets: years of coarse grained buckets
% settlement: settlement date
% delta: delta bucket sensitivities of the structured product
% dates_delta: dates of the buckets
% delta_swaps: delta bucket sensitivities of the swaps
% delta_caps: delta bucket sensitivities of the caps

% Inizialing arrays
[~,swaps_col]=size(delta_swaps);
[~,caps_col]=size(delta_caps);
nbuckets=length(buckets);
delta_CG=zeros(nbuckets,1);
delta_swaps_CG=zeros(nbuckets,swaps_col);
delta_caps_CG=zeros(nbuckets,caps_col);

% Compute dates of coarse grained buckets (by years)
datesbuckets=datetime(settlement,'ConvertFrom','datenum')+calyears(buckets)';
datesbuckets=businessdates(datesbuckets);

% Select dates for first bucket and compute weights
int_dates=(delta_dates>=datesbuckets(1)).*(delta_dates<=datesbuckets(2));
int_dates=(int_dates==1);
weights=interp1(datesbuckets(1:2),[1;0],delta_dates(int_dates),"linear");

% Compute delta of the first coarse grained bucket
delta_CG(1)=sum(weights.*delta(int_dates))+sum(delta(delta_dates<datesbuckets(1)));
delta_swaps_CG(1,:)=sum(weights.*delta_swaps(int_dates,:))+sum(delta_swaps(delta_dates<datesbuckets(1),:));
delta_caps_CG(1,:)=sum(weights.*delta_caps(int_dates,:))+sum(delta_caps(delta_dates<datesbuckets(1),:));

for ii=2:nbuckets-1
    
    % Select dates for ii-th bucket and compute weights
    int_dates=(delta_dates>=datesbuckets(ii-1)).*(delta_dates<=datesbuckets(ii+1));
    int_dates=(int_dates==1);
    weights=interp1(datesbuckets(ii-1:ii+1),[0;1;0],delta_dates(int_dates),"linear");
    
    % Compute delta of the ii-th coarse grained bucket
    delta_CG(ii)=sum(weights.*delta(int_dates));
    delta_swaps_CG(ii,:)=sum(weights.*delta_swaps(int_dates,:));
    delta_caps_CG(ii,:)=sum(weights.*delta_caps(int_dates,:));
 
end

% Select dates for last bucket and compute weights
int_dates=(delta_dates>=datesbuckets(end-1)).*(delta_dates<=datesbuckets(end));
int_dates=(int_dates==1);
weights=interp1(datesbuckets(end-1:end),[0;1],delta_dates(int_dates),"linear");

% Compute delta of the last coarse grained bucket
delta_CG(end)=sum(weights.*delta(int_dates));
delta_swaps_CG(end,:)=sum(weights.*delta_swaps(int_dates,:));
delta_caps_CG(end,:)=sum(weights.*delta_caps(int_dates,:));

end % function Delta_CG