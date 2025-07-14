function ED=easter(varargin)
%This function computes the Date of Easter, using the Gauss algorithm.
% 
% Syntax: 	EASTER(YEAR,VERBOSE)
%      
%     Inputs:
%           YEAR - Year of interest (default = current year). You can input
%           a vector of years.
%           VERBOSE - You can choose if Matlab displays on video the Easter
%           Date(s) (1) or not (0). (default = 1).
%     Outputs:
%           - Date(s) of Easter
% 
% ED=EASTER(...) will stores Easter dates in Matlab format
% 
% You can find algorithm explanation editing the function. Anyway, the
% explanation can be found at:
% http://www.henk-reints.nl/easter/index.htm?frame=easteralg2.htm
% 
% To cite this file, this would be an appropriate format:
% Cardillo G. (2007). Easter: an Easter Day calculator based on the Gauss
% algorithm.  
% http://www.mathworks.com/matlabcentral/fileexchange/13982
%Input Error handling
p = inputParser;
addOptional(p,'Y',year(now),@(x) validateattributes(x,{'numeric'},{'row','real','finite','integer','nonnan','positive','>',33}))
addOptional(p,'verbose',1,@(x) x==0 || x==1)
parse(p,varargin{:});
Y=p.Results.Y; verbose=logical(p.Results.verbose);
%Now we are going to take the Moon into account. It appears to be so that
%235 lunations (i.e. moon months) are practically equal to 19 tropical
%years (a tropical year is the time between the beginning of spring one
%year and the next year). This means that every 19 years the moon phases
%will occur on the same dates in the year. This regularity was discovered
%by an ancient Greek called Meton and therefore this 19-year cycle is
%called the Metonic cycle (or moon cycle). Because this equality of 235
%lunations and 19 years is not really exact (the difference is
%approximately 2 hours), there is a small shift of about 1 day per 310
%years = ca. 8 days per 25 centuries. The value of M takes care of that
%shift (as far as I know Gauss did not include a calculation of M in his
%algorithm). 
P=floor(Y./100); %P is simply the century index
Q=floor((3.*P+3)./4); %Q takes care of the leap day difference between the Julian and the Gregorian calendar
R=floor((8.*P+13)./25); %R actually handles the shift of the Metonic cycle
M=floor(mod((15+Q-R),30));
%The value of N has to do with the difference in the number of leap days
%between the Gregorian and the Julian calendar. The Julian calendar has a
%leap day every 4 years, whilst the Gregorian calendar excludes the
%100-fold years from being a leap year unless they can be divided by 400.
%This has to do with the actual length of the year, which on the Gregorian
%Calendar is assumed to be 365.2425 days (in reality it currently is
%365.24219 days). Together, B and N handle the Gregorian leap days.
N=floor(mod((4+Q),7));
%M and N values in Julian Calendar
M(Y<=1582)=15;
N(Y<=1582)=6;
%The value of A is simply the offset (from 0 to 18) of the given year within the corresponding Metonic cycle.
A = mod(Y,19);
%The value of C takes care of the fact that a non-leap year is 1 day longer
%that 52 weeks, so for the day of the week every date (including March 21)
%shifts one day per year, as does your own birthday. Only if there is a
%leap day in between then it shifts an extra day, which is handled by B and
%N 
C = mod(Y,7);
%B counts the leap days according to the Julian calendar, i.e. one leap day every 4 years. 
B = mod(Y,4);  
%Now look at D. The number 19 we see here does not
%have the same meaning as the Metonic cycle used to calculate A, but it
%comes frome the following: a so called Moon year of 12 Moon months is a
%bit more than 354 days, so it is 11 days shorter than the Gregorian Solar
%year of 365.2425 days. This means that the moon phases occur 11 days
%earlier every next year and since a Moon month has got 30 days this
%implies that the Moon phases also occur 19 days later, which is the
%meaning of the 19 in the calculation of D. The value of D handles the
%Metonic cycle (using A) and the long term shift thereof (using M) as well
%as the length of the Lunar month (the 19 and the MOD 30). The result
%actually is the number of days (from 0 to 29) to be added to March 21 in
%order to get the date of the first Full Moon in spring (PFM = Paschal Full
%Moon)
D = mod((19 .* A + M),30);
%Instead of E we will first look at E' = (2 x B + 4 x C + N) MOD 7. The
%result is the number of days from March 22 until the next Sunday, i.e. if
%March 22 is a Sunday then E' = 0, if it's a Saturday then E' = 1, etc.
%until E' = 6 if March 22 is a Monday. So March 22 + E' is the first
%Sunday after March 21. This calculation is remarkably clever of Mr.
%Gauss! Both B and C usually increment by 1 every year, so adding 2 x B +
%4 x C means adding 6 days every year. But in modulo 7 arithmetic, 6 is
%the same as -1, so effectively it subtracts 1 from the days left until
%the next Sunday. Since March 22 is a day later the next year, it takes 1
%day less until the next Sunday. And because B never exceeds the value of
%3 and C never becomes larger than 6, the value of E' correctly handles
%the leap days!
%Finally, the first Sunday after this PFM is calculated: 
%We want to find the Sunday after this PFM, so we have to add up to the
%first Sunday on or after PFM + 1. Therefore we start with March 21 + D + 1
%= March 22 + D. In order to find the next Sunday, we do more or less the
%same as we did above with E'. But now we have added D to March 22. This
%means that the day of the week has advanced D MOD 7 days, so using E' to
%find the next Sunday is no longer appropriate. We will have to compensate
%for this extra advance. This is handled by the term 6 x D in the
%calculation of E. Note that adding D + (6 x D) MOD 7 to any date gets you
%back on the same day of the week.  Together, this means that the value of
%E = (2 x B + 4 x C + 6 x D + N) MOD 7 is just the right number that will
%bring you to the first Sunday after March 22 + D, which is Easter Sunday. 
E = mod(((2 .* B) + (4 .* C) + (6 .* D) + N),7);
%All together the Easter date is calculated as F = (22 + D + E) March
%(Em=3) and if F becomes larger than 31 it will of course rollover to April
%(Em=4).  Finally, there is one caveat left: The length of a Moon month is
%not exactly 30 days, but 29.53. This means that for large values of D we
%might find a PFM that is one day late and if that happens to be a Sunday,
%then we will end up with an Easter date that is an entire week overdue.
%Therefore the final correction: if F = 26 or (F = 25 and D = 28 and A >
%10) then F = F - 7 must be applied.  This should be read as:   if the
%result is April 26 (F = 26) then subtract 1 week;   if the result is April
%25 (F = 25) AND the day after PFM is a Monday (E = 6) AND the year is in
%the second half of a Metonic cycle (A > 10) then subtract 1 week. 
F = (22 + D + E);
Em=3.*ones(size(Y));
I=find(F>31);
if isempty(I)==0
    F(I)=F(I)-31;
    Em(I)=4;
    K=find((F(I)==26) | (F(I)==25 & E(I)==6 & A(I)>10));
    if isempty(K)==0
        F(I(K))=F(I(K))-7;
    end
end
%Transform the dates in Matlab format
if nargout
    ED=datenum(Y,Em,F);
end
%If verbose display the dates
if verbose==1
    disp(datestr(datenum(Y,Em,F),1))
end