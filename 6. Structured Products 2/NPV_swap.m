function NPV = NPV_swap(dt,discounts,spread)

% Compute the net present value of a swap

% INPUT:
% dt: fractions of year
% discounts: yearly discount
% spread: fixed leg

NPV=1-discounts(:,end)-sum(spread*dt.*discounts,2);
end % function NPV_swap