function Tn = tornado_data(Kbase, Ksens, metric)
%TORNADO_DATA  Range of one result across each group of sensitivities.
%
%   Tn = tornado_data(Kbase, Ksens, 'lcoe')
%
% One row per sensitivity group (Load, Irradiance, Grid supply, ...): the
% lowest and highest value of the metric among the cases of the group and
% the base case, with the label of the case that gives each end. Rows are
% sorted by the width of the range, widest first.
%
%   Tn(j).group, .lo, .hi, .lo_label, .hi_label, .base, .span

if nargin < 3, metric = 'lcoe'; end
base = Kbase.(metric);
Tn = struct('group', {}, 'lo', {}, 'hi', {}, 'lo_label', {}, 'hi_label', {}, 'base', {}, 'span', {});
groups = {};
for j = 1:numel(Ksens)
    if Ksens(j).ok && ~any(strcmp(groups, Ksens(j).group))
        groups{end + 1} = Ksens(j).group; %#ok<AGROW>
    end
end
for g = 1:numel(groups)
    m = Ksens(strcmp({Ksens.group}, groups{g}) & [Ksens.ok]);
    v = [m.(metric)];
    [lo, jl] = min(v);
    [hi, jh] = max(v);
    r = struct('group', groups{g}, 'lo', min(lo, base), 'hi', max(hi, base), ...
               'lo_label', '', 'hi_label', '', 'base', base, 'span', 0);
    if lo < base, r.lo_label = m(jl).label; end
    if hi > base, r.hi_label = m(jh).label; end
    r.span = r.hi - r.lo;
    Tn(end + 1) = r; %#ok<AGROW>
end
[~, order] = sort([Tn.span], 'descend');
Tn = Tn(order);
end
