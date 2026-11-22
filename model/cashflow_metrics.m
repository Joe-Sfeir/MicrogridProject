function M = cashflow_metrics(cf, rate)
%CASHFLOW_METRICS  NPV, IRR and payback of a yearly cash-flow series.
%
%   M = cashflow_metrics(cf, rate)
%
%   cf     cash flows, cf(1) is year 0 (the investment, negative), cf(t+1)
%          is the cash flow at the end of year t
%   rate   discount rate per year (fraction)
%
%   M.npv           net present value, sum_t cf(t) / (1 + rate)^t
%   M.irr           internal rate of return: the rate at which the NPV is 0
%                   (NaN if the NPV does not change sign)
%   M.payback       simple payback in years: when the cumulative cash flow
%                   first reaches 0, interpolated within the year (NaN if never)
%   M.payback_disc  the same for the discounted cash flow
%   M.disc, M.cum, M.cum_disc   discounted, cumulative and cumulative
%                   discounted cash flows, one value per year

cf = cf(:)';
t  = 0:numel(cf) - 1;
M.disc     = cf ./ (1 + rate) .^ t;
M.npv      = sum(M.disc);
M.cum      = cumsum(cf);
M.cum_disc = cumsum(M.disc);
M.irr      = irr_of(cf);
M.payback      = payback_of(cf);
M.payback_disc = payback_of(M.disc);
end

% =========================================================================
function v = npv_at(cf, r)
v = sum(cf ./ (1 + r) .^ (0:numel(cf) - 1));
end

% =========================================================================
function r = irr_of(cf)
% Bisection on the NPV. For an investment followed by net savings the NPV
% falls as the rate rises, so the root is unique.
if npv_at(cf, 0) > 0
    lo = 0;  hi = 0.1;
    while npv_at(cf, hi) > 0 && hi < 100
        lo = hi;  hi = 2 * hi;
    end
else
    lo = -0.99;  hi = 0;
end
flo = npv_at(cf, lo);  fhi = npv_at(cf, hi);
if ~(flo > 0 && fhi <= 0)
    r = NaN;                                   % no sign change: no IRR
    return
end
for it = 1:200
    r = (lo + hi) / 2;
    if npv_at(cf, r) > 0, lo = r; else, hi = r; end
    if hi - lo < 1e-10, break; end
end
r = (lo + hi) / 2;
end

% =========================================================================
function y = payback_of(c)
% Year in which the cumulative sum first reaches zero.
cum = cumsum(c);
y = NaN;
if cum(1) >= 0, y = 0; return; end
j = find(cum(2:end) >= 0, 1) + 1;
if ~isempty(j)
    y = (j - 2) + (-cum(j - 1)) / c(j);
end
end
