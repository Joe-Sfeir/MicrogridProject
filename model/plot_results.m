function plot_results(outdir, S)
%PLOT_RESULTS  Figures of the base case and of the sensitivities (PNG).
%
%   plot_results(outdir, S)      S is the struct built by main.m
%
%   fig_dispatch_winter_week.png   week of the highest-load ski weekend
%   fig_dispatch_summer_week.png   week of the highest-load summer weekend
%   fig_soc_year.png               battery state of charge over the year
%   fig_monthly_energy.png         monthly energy balance
%   fig_tornado_lcoe.png           sensitivity of the LCOE (full study only)
%
% One colour per source in every figure: PV yellow, battery green, grid
% blue, diesel orange, unserved load violet; the load is a black line.

R = S.Rbase;
D = S.D;

[w_win, w_sum] = pick_weeks(D, R);
plot_dispatch(fullfile(outdir, 'fig_dispatch_winter_week.png'), D, R, w_win, ...
              'Base case dispatch, week of the highest-load ski weekend');
plot_dispatch(fullfile(outdir, 'fig_dispatch_summer_week.png'), D, R, w_sum, ...
              'Base case dispatch, summer week');
plot_soc_year(fullfile(outdir, 'fig_soc_year.png'), D, R);
plot_monthly(fullfile(outdir, 'fig_monthly_energy.png'), D, R);
if ~isempty(S.Ksens)
    plot_tornado(fullfile(outdir, 'fig_tornado_lcoe.png'), S);
end
end

% =========================================================================
function c = colours()
c.pv      = [237 161   0] / 255;
c.batt    = [ 27 175 122] / 255;
c.charge  = [150 214 190] / 255;     % lighter tint of the battery colour
c.grid    = [ 42 120 214] / 255;
c.diesel  = [235 104  52] / 255;
c.uns     = [ 98  80 214] / 255;
c.ink     = [ 11  11  11] / 255;
c.ink2    = [ 82  81  78] / 255;
c.muted   = [137 135 129] / 255;
c.rule    = [225 224 217] / 255;
end

% =========================================================================
function [w_win, w_sum] = pick_weeks(D, R)
% Hour indices of two 7-day windows (Thursday to Wednesday, local time)
% around the weekend with the highest load: one among the ski weekends,
% one in June to August.
day  = floor(D.t_local) - floor(D.t_local(1)) + 1;       % local day number
nday = max(day);
Eday = accumarray(day, R.series.L, [nday 1]);            % kWh per local day
dow  = weekday(floor(D.t_local(1)) + (0:nday - 1)');     % 1 = Sunday ... 7 = Saturday
mon  = accumarray(day, D.month, [nday 1], @max);
ski  = accumarray(day, D.ski,   [nday 1], @max);
sat  = find(dow == 7 & (1:nday)' < nday);
Ewe  = Eday(sat) + Eday(sat + 1);

is_ski = ski(sat) > 0 | ski(sat + 1) > 0;
[~, j] = max(Ewe .* is_ski);
w_win = window(day, nday, sat(j));

is_sum = ismember(mon(sat), [6 7 8]);
[~, j] = max(Ewe .* is_sum);
w_sum = window(day, nday, sat(j));
end

function w = window(day, nday, d_sat)
d1 = d_sat - 2;                                          % Thursday
d1 = min(max(d1, 1), nday - 6);
w  = find(day >= d1 & day <= d1 + 6);
end

% =========================================================================
function fig = new_figure(width_in, height_in)
fig = figure('Visible', 'off', 'Color', 'w', 'PaperUnits', 'inches', ...
             'PaperPosition', [0 0 width_in height_in], 'PaperSize', [width_in height_in]);
try %#ok<TRYNC>
    set(fig, 'Units', 'inches', 'Position', [0.5 0.5 width_in height_in]);
end
set(fig, 'DefaultAxesFontSize', 9, 'DefaultTextFontSize', 9);
end

function style_axes(ax)
c = colours();
set(ax, 'Box', 'off', 'TickDir', 'out', 'XColor', c.ink2, 'YColor', c.ink2, 'Layer', 'top', ...
        'YGrid', 'on', 'XGrid', 'off', 'GridLineStyle', '-');
try %#ok<TRYNC>
    set(ax, 'GridColor', c.rule, 'GridAlpha', 1);
end
end

function save_figure(fig, fname)
print(fig, fname, '-dpng', '-r200');
close(fig);
fprintf('  wrote %s\n', fname);
end

% =========================================================================
function plot_dispatch(fname, D, R, w, ttl)
% Stacked hourly supply (bars), battery charging below zero, load as a line;
% grid availability and battery state of charge in separate panels below.
c = colours();
n = numel(w);
x = (1:n)' - 0.5;                                        % hour centres
% local midnights (day separators) and local noons (day labels)
h0  = round((D.t_local(w(1)) - floor(D.t_local(w(1)))) * 24);       % local hour of the first bar
mid = (0:8)' * 24 - h0;
mid = mid(mid > 0 & mid < n);
noon = (0:7)' * 24 - h0 + 12;
noon = noon(noon > 6 & noon < n - 6);
xl = cell(size(noon));
for j = 1:numel(noon)
    xl{j} = datestr(D.t_local(w(1)) + noon(j) / 24, 'ddd dd mmm');
end

fig = new_figure(9, 6.2);
pos1 = [0.09 0.46 0.89 0.46];
pos2 = [0.09 0.335 0.89 0.035];
pos3 = [0.09 0.09 0.89 0.20];

% ---- power
ax1 = axes('Position', pos1);
supply = [R.p_pv(w), R.p_dis(w), R.p_g(w), R.p_dg(w), R.ls_c(w) + R.ls_n(w)];
pv_av  = R.series.a(w) * R.P_pv;
hb = bar(x, supply, 1, 'stacked');
cols = {c.pv, c.batt, c.grid, c.diesel, c.uns};
for j = 1:numel(hb), set(hb(j), 'FaceColor', cols{j}, 'EdgeColor', 'none'); end
hold on
hc = bar(x, -R.p_ch(w), 1);
set(hc, 'FaceColor', c.charge, 'EdgeColor', 'none');
ylo = -100 * ceil(max(R.p_ch(w)) / 100);
yhi =  100 * ceil(max([sum(supply, 2); pv_av]) / 100);
for j = 1:numel(mid)
    plot(mid(j) * [1 1], [ylo yhi], '-', 'Color', c.rule, 'LineWidth', 0.5);
end
[xs, ys] = steps(pv_av);
hp = plot(xs, ys, '-', 'Color', c.ink2, 'LineWidth', 0.7);
[xs, ys] = steps(R.series.L(w));
hl = plot(xs, ys, '-', 'Color', c.ink, 'LineWidth', 1.4);
hold off
style_axes(ax1);
set(ax1, 'XLim', [0 n], 'YLim', [ylo yhi], 'XTick', noon, 'XTickLabel', []);
ylabel('Power (kW)');
title(ttl, 'FontWeight', 'bold', 'Color', c.ink);
lg = legend([hb(1), hb(2), hb(3), hb(4), hb(5), hc, hl, hp], ...
       {'PV used', 'Battery discharge', 'Grid', 'Diesel', 'Unserved load', 'Battery charging', ...
        'Load', 'PV available'}, 'Orientation', 'horizontal', 'Box', 'off');
set(lg, 'Units', 'normalized', 'Position', [0.09 0.385 0.89 0.04]);
set(ax1, 'Position', pos1);

% ---- grid availability
ax2 = axes('Position', pos2);
hg = bar(x, R.series.ug(w), 1);
set(hg, 'FaceColor', c.grid, 'EdgeColor', 'none');
set(ax2, 'XLim', [0 n], 'YLim', [0 1], 'XTick', [], 'YTick', [], 'Box', 'off', ...
         'XColor', c.rule, 'YColor', c.rule);
ylabel('Grid on', 'Rotation', 0, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', ...
       'Color', c.ink2);

% ---- state of charge (energy at the start of each hour)
ax3 = axes('Position', pos3);
hold on
for j = 1:numel(mid)
    plot(mid(j) * [1 1], [0 100], '-', 'Color', c.rule, 'LineWidth', 0.5);
end
if R.E_b > 0
    plot((0:n - 1)', 100 * R.soc(w) / R.E_b, '-', 'Color', c.batt, 'LineWidth', 1.6);
end
hold off
style_axes(ax3);
set(ax3, 'XLim', [0 n], 'YLim', [0 100], 'YTick', 0:25:100, 'XTick', noon, 'XTickLabel', xl);
ylabel('Battery SOC (%)');
xlabel('Local time (labels at noon, lines at midnight)');

save_figure(fig, fname);
end

function [xs, ys] = steps(y)
% Stair coordinates for hourly averages: value y(t) holds from t-1 to t.
n  = numel(y);
xs = reshape([0:n - 1; 1:n], [], 1);
ys = reshape([y(:)'; y(:)'], [], 1);
end

% =========================================================================
function plot_soc_year(fname, D, R)
% Daily range (band) and daily mean (line) of the state of charge.
c = colours();
day  = floor(D.t_local) - floor(D.t_local(1)) + 1;
nday = max(day);
soc  = 100 * R.soc / max(R.E_b, eps);
lo = accumarray(day, soc, [nday 1], @min);
hi = accumarray(day, soc, [nday 1], @max);
mu = accumarray(day, soc, [nday 1], @mean);
d  = (1:nday)';

fig = new_figure(9, 3.6);
ax = axes('Position', [0.09 0.16 0.89 0.72]);
patch([d; flipud(d)], [lo; flipud(hi)], c.charge, 'EdgeColor', 'none');
hold on
plot(d, mu, '-', 'Color', c.batt * 0.75, 'LineWidth', 1.4);
plot([1 nday], 100 * R.s.soc_min * [1 1], '-', 'Color', c.muted, 'LineWidth', 0.6);
hold off
text(nday, 100 * R.s.soc_min - 1.5, sprintf('SOC_{min} = %g%%', 100 * R.s.soc_min), ...
     'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Color', c.ink2);
style_axes(ax);
[mt, ml] = month_ticks(D, day);
set(ax, 'XLim', [1 nday], 'YLim', [0 100], 'YTick', 0:25:100, 'XTick', mt, 'XTickLabel', ml);
ylabel('State of charge (% of E_b)');
title(sprintf('Battery state of charge, base case (%.0f kWh): daily range (band) and daily mean (line)', ...
      R.E_b), 'FontWeight', 'bold', 'Color', c.ink);
save_figure(fig, fname);
end

function [mt, ml] = month_ticks(D, day)
names = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
mt = zeros(1, 12);
for m = 1:12
    mt(m) = min(day(D.month == m));                      % first local day of the month
end
ml = names;
end

% =========================================================================
function plot_monthly(fname, D, R)
% Monthly energy: supply stacked above zero, battery charging below, load line.
c = colours();
dt = R.s.dt;
sm = @(v) accumarray(D.month, v * dt, [12 1]) / 1000;    % MWh per month
supply = [sm(R.p_pv), sm(R.p_dis), sm(R.p_g), sm(R.p_dg), sm(R.ls_c + R.ls_n)];
charge = sm(R.p_ch);
load_m = sm(R.series.L);

fig = new_figure(9, 4.6);
ax = axes('Position', [0.09 0.20 0.89 0.70]);
hb = bar(1:12, supply, 0.62, 'stacked');
cols = {c.pv, c.batt, c.grid, c.diesel, c.uns};
for j = 1:numel(hb), set(hb(j), 'FaceColor', cols{j}, 'EdgeColor', 'none'); end
hold on
hc = bar(1:12, -charge, 0.62);
set(hc, 'FaceColor', c.charge, 'EdgeColor', 'none');
hl = plot(1:12, load_m, '-o', 'Color', c.ink, 'LineWidth', 1.4, 'MarkerSize', 4, 'MarkerFaceColor', c.ink);
hold off
style_axes(ax);
set(ax, 'XLim', [0.4 12.6], 'XTick', 1:12, 'XTickLabel', ...
    {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'});
ylabel('Energy (MWh per month)');
title('Monthly energy balance, base case', 'FontWeight', 'bold', 'Color', c.ink);
lg = legend([hb(1), hb(2), hb(3), hb(4), hb(5), hc, hl], ...
       {'PV used', 'Battery discharge', 'Grid', 'Diesel', 'Unserved load', 'Battery charging', 'Load'}, ...
       'Orientation', 'horizontal', 'Box', 'off');
set(lg, 'Units', 'normalized', 'Position', [0.09 0.03 0.89 0.06]);
set(ax, 'Position', [0.09 0.20 0.89 0.70]);
save_figure(fig, fname);
end

% =========================================================================
function plot_tornado(fname, S)
% LCOE range of each sensitivity group around the base case.
c  = colours();
Tn = tornado_data(S.Kbase, S.Ksens, 'lcoe');
n  = numel(Tn);
base = S.Kbase.lcoe;
h  = 0.32;                                               % half bar height

fig = new_figure(9, 0.36 * n + 1.5);
ax = axes('Position', [0.22 0.13 0.74 0.78]);
hold on
xmin = min([Tn.lo]);  xmax = max([Tn.hi]);
pad = 0.30 * (xmax - xmin);
for j = 1:n
    y = n - j + 1;
    if Tn(j).lo < base
        patch([Tn(j).lo base base Tn(j).lo], [y - h, y - h, y + h, y + h], c.grid, 'EdgeColor', 'none');
        text(Tn(j).lo - 0.012 * (xmax - xmin), y, sprintf('%s  %.3f', Tn(j).lo_label, Tn(j).lo), ...
             'HorizontalAlignment', 'right', 'Color', c.ink2, 'FontSize', 8);
    end
    if Tn(j).hi > base
        patch([base Tn(j).hi Tn(j).hi base], [y - h, y - h, y + h, y + h], c.diesel, 'EdgeColor', 'none');
        text(Tn(j).hi + 0.012 * (xmax - xmin), y, sprintf('%.3f  %s', Tn(j).hi, Tn(j).hi_label), ...
             'HorizontalAlignment', 'left', 'Color', c.ink2, 'FontSize', 8);
    end
end
plot([base base], [0.4 n + 0.6], '-', 'Color', c.ink, 'LineWidth', 1);
hold off
set(ax, 'Box', 'off', 'TickDir', 'out', 'XColor', c.ink2, 'YColor', c.ink2, 'YTick', 1:n, ...
        'YTickLabel', fliplr({Tn.group}), 'YLim', [0.4 n + 0.6], 'XLim', [xmin - pad, xmax + pad], ...
        'XGrid', 'on', 'YGrid', 'off', 'GridLineStyle', '-');
try %#ok<TRYNC>
    set(ax, 'GridColor', c.rule, 'GridAlpha', 1);
end
xlabel('LCOE ($/kWh); blue: below the base case, orange: above');
title(sprintf('Sensitivity of the LCOE, one change at a time (base case %.3f $/kWh)', base), ...
      'FontWeight', 'bold', 'Color', c.ink);
save_figure(fig, fname);
end
