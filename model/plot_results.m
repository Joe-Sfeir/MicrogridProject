function plot_results(outdir, S)
%PLOT_RESULTS  Figures of the base case and of the sensitivities (PNG).
%
%   plot_results(outdir, S)      S is the struct built by main.m
%
%   fig_dispatch_winter_week.png   week of the highest-load ski weekend
%   fig_dispatch_summer_week.png   week of the highest-load summer weekend
%   fig_soc_year.png               battery state of charge over the year
%   fig_monthly_energy.png         monthly energy balance
%   fig_cashflow.png               yearly and cumulative discounted cash flow
%   fig_npv_vs_rate.png            NPV against the discount rate, IRR marked
%   fig_diesel_sweep.png           diesel price sweep (full study only)
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
plot_cashflow(fullfile(outdir, 'fig_cashflow.png'), S.fin(1).F);
plot_npv_rate(fullfile(outdir, 'fig_npv_vs_rate.png'), S.fin(1).F);
if ~isempty(S.Ksens)
    plot_diesel_sweep(fullfile(outdir, 'fig_diesel_sweep.png'), S);
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
w_win = week_window(day, nday, sat(j));

is_sum = ismember(mon(sat), [6 7 8]);
[~, j] = max(Ewe .* is_sum);
w_sum = week_window(day, nday, sat(j));
end

function w = week_window(day, nday, d_sat)
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
[supply, cols, names] = supply_stack(R, w, c);
pv_av  = R.series.a(w) * R.P_pv;
hb = bar(x, supply, 1, 'stacked');
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
lg = legend([hb(:)', hc, hl, hp], [names, {'Battery charging', 'Load', 'PV available'}], ...
            'Orientation', 'horizontal', 'Box', 'off');
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

function [supply, cols, names] = supply_stack(R, w, c)
% Columns of the supply stack for the hours w: PV used on site, battery
% discharge, grid, diesel, and unserved load only if the run sheds any.
supply = [R.p_pv(w) - R.p_ex(w), R.p_dis(w), R.p_g(w), R.p_dg(w)];
cols   = {c.pv, c.batt, c.grid, c.diesel};
names  = {'PV used', 'Battery discharge', 'Grid', 'Diesel'};
if any(R.ls_c + R.ls_n > 1e-6)
    supply = [supply, R.ls_c(w) + R.ls_n(w)];
    cols{end + 1}  = c.uns;
    names{end + 1} = 'Unserved load';
end
end

% =========================================================================
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
[hourly, cols, names] = supply_stack(R, (1:R.T)', c);
supply = zeros(12, size(hourly, 2));
for j = 1:size(hourly, 2), supply(:, j) = sm(hourly(:, j)); end
charge = sm(R.p_ch);
load_m = sm(R.series.L);

fig = new_figure(9, 4.6);
ax = axes('Position', [0.09 0.20 0.89 0.70]);
hb = bar(1:12, supply, 0.62, 'stacked');
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
lg = legend([hb(:)', hc, hl], [names, {'Battery charging', 'Load'}], ...
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
pad = 0.30 * (xmax - xmin);                              % room for the labels at the bar ends
pad_left = 0.48 * (xmax - xmin);
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
        'YTickLabel', fliplr({Tn.group}), 'YLim', [0.4 n + 0.6], 'XLim', [xmin - pad_left, xmax + pad], ...
        'XGrid', 'on', 'YGrid', 'off', 'GridLineStyle', '-');
try %#ok<TRYNC>
    set(ax, 'GridColor', c.rule, 'GridAlpha', 1);
end
xlabel('LCOE ($/kWh); blue: below the base case, orange: above');
title(sprintf('Sensitivity of the LCOE, one change at a time (base case %.3f $/kWh)', base), ...
      'FontWeight', 'bold', 'Color', c.ink);
save_figure(fig, fname);
end

% =========================================================================
function plot_cashflow(fname, F)
% Discounted cash flow of each year (bars) and its running total (line),
% both in thousand $ on one axis.
c = colours();
yr  = F.years(:);
dcf = F.disc(:) / 1000;                                  % discounted cash flow
cum = F.cum_disc(:) / 1000;                              % cumulative discounted

fig = new_figure(9, 4.4);
ax = axes('Position', [0.10 0.14 0.87 0.74]);
hb = bar(yr, dcf, 0.6);
set(hb, 'FaceColor', c.charge, 'EdgeColor', 'none');
hold on
plot([-0.6 yr(end) + 0.6], [0 0], '-', 'Color', c.ink2, 'LineWidth', 0.6);
hl = plot(yr, cum, '-o', 'Color', c.grid, 'LineWidth', 1.6, 'MarkerSize', 3.5, 'MarkerFaceColor', c.grid);
hold off
style_axes(ax);
set(ax, 'XLim', [-0.8 yr(end) + 0.8], 'XTick', 0:5:yr(end));
span = max(cum) - min(cum);
if ~isnan(F.payback_disc)
    hold on
    plot(F.payback_disc, 0, 'o', 'Color', c.diesel, 'MarkerSize', 5.5, 'MarkerFaceColor', c.diesel);
    hold off
    text(F.payback_disc + 0.35, -0.05 * span, sprintf('discounted payback %.1f yr', F.payback_disc), ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'Color', c.ink2, 'FontSize', 8);
end
text(yr(end), cum(end) + 0.04 * span, sprintf('NPV %s $', commas(F.npv)), 'HorizontalAlignment', 'right', ...
     'VerticalAlignment', 'bottom', 'Color', c.ink, 'FontSize', 9, 'FontWeight', 'bold');
xlabel('Project year');
ylabel('Thousand $ (2026 prices)');
title(sprintf('Base case cash flow against the reference, discounted at %.2f%%', 100 * F.rate), ...
      'FontWeight', 'bold', 'Color', c.ink);
lg = legend([hb, hl], {'Discounted cash flow of the year', 'Cumulative discounted cash flow'}, ...
            'Location', 'southeast', 'Box', 'off');
set(lg, 'FontSize', 8);
save_figure(fig, fname);
end

% =========================================================================
function plot_npv_rate(fname, F)
% NPV against the discount rate: the cash flows are fixed, only the rate
% changes. Markers at the rates of parameters.json, the IRR where NPV = 0.
c = colours();
rmax = max(F.curve_rate);
if ~isnan(F.irr), rmax = max(rmax, 1.15 * F.irr); end
r = linspace(0, rmax, 200);
v = zeros(size(r));
for j = 1:numel(r)
    v(j) = sum(F.cf ./ (1 + r(j)) .^ (0:numel(F.cf) - 1));
end

fig = new_figure(9, 4.2);
ax = axes('Position', [0.10 0.15 0.87 0.73]);
plot(100 * [0 rmax], [0 0], '-', 'Color', c.ink2, 'LineWidth', 0.6);
hold on
plot(100 * r, v / 1000, '-', 'Color', c.grid, 'LineWidth', 1.6);
plot(100 * F.curve_rate, F.curve_npv / 1000, 'o', 'Color', c.grid, 'MarkerSize', 4.5, 'MarkerFaceColor', c.grid);
span = max(v) / 1000;
jb = find(abs(F.curve_rate - F.rate) < 1e-9, 1);
if ~isempty(jb)
    text(100 * F.rate + 0.25, F.curve_npv(jb) / 1000 + 0.03 * span, ...
         sprintf('base rate %.2f%%: NPV %s $', 100 * F.rate, commas(F.npv)), 'Color', c.ink, 'FontSize', 8.5);
end
if ~isnan(F.irr)
    plot(100 * F.irr, 0, 'o', 'Color', c.diesel, 'MarkerSize', 6.5, 'MarkerFaceColor', c.diesel);
    text(100 * F.irr, 0.06 * span, sprintf('IRR %.1f%%', 100 * F.irr), 'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'bottom', 'Color', c.ink, 'FontSize', 9, 'FontWeight', 'bold');
end
hold off
style_axes(ax);
set(ax, 'XLim', [0 100 * rmax], 'YLim', [min(-0.08 * span, 1.6 * min(v) / 1000), 1.08 * span]);
xlabel('Real discount rate (%)');
ylabel('NPV (thousand $, 2026 prices)');
title(sprintf('Base case: NPV over %d years against the discount rate', F.horizon), ...
      'FontWeight', 'bold', 'Color', c.ink);
save_figure(fig, fname);
end

% =========================================================================
function plot_diesel_sweep(fname, S)
% Four small panels against the diesel price: yearly saving, NPV, PV size
% and battery size. Vertical lines: break-even of own diesel against EDL
% energy (slope of the fuel curve only, and with the no-load term).
c = colours();
s = S.base;
x = [S.sweep.price_diesel];
K = S.Ksweep;
npv = nan(size(x));
for j = 1:numel(K)
    q = find(strcmp({S.fin.name}, K(j).name), 1);
    if ~isempty(q), npv(j) = S.fin(q).F.npv; end
end
be_b  = S.D.par.diesel.breakeven_vs_edl_per_L;
be_ab = (s.c_grid - s.om_dg) / (s.fuel_a + s.fuel_b);
dp    = S.D.par.diesel.price_per_L;

panels = {[K.savings] / 1000, 'Saving against the reference (thousand $/yr)', c.grid
          npv / 1000,         sprintf('NPV over %d years (thousand $)', S.fin(1).F.horizon), c.grid
          [K.P_pv],           'PV size (kWp)',                                c.pv
          [K.E_b],            'Battery size (kWh)',                           c.batt};
pos = {[0.08 0.57 0.40 0.33], [0.575 0.57 0.40 0.33], [0.08 0.10 0.40 0.33], [0.575 0.10 0.40 0.33]};

fig = new_figure(9, 6.4);
for q = 1:4
    ax = axes('Position', pos{q});
    y = panels{q, 1};
    ylo = min(0, 1.08 * min(y));  yhi = 1.12 * max(y);
    % observed price range, break-even lines, base price
    patch([dp(1) dp(3) dp(3) dp(1)], [ylo ylo yhi yhi], [0.955 0.953 0.94], 'EdgeColor', 'none');
    hold on
    plot(be_b  * [1 1], [ylo yhi], '-', 'Color', c.muted, 'LineWidth', 0.7);
    plot(be_ab * [1 1], [ylo yhi], '-', 'Color', c.muted, 'LineWidth', 0.7);
    plot(x, y, '-o', 'Color', panels{q, 3}, 'LineWidth', 1.6, 'MarkerSize', 4, 'MarkerFaceColor', panels{q, 3});
    jb = find(abs(x - s.price_diesel) < 1e-9, 1);
    if ~isempty(jb)
        plot(x(jb), y(jb), 'o', 'Color', c.ink, 'MarkerSize', 6.5, 'LineWidth', 1.1);
    end
    hold off
    style_axes(ax);
    set(ax, 'XLim', [min(x) - 0.05, max(x) + 0.05], 'YLim', [ylo yhi], 'XTick', x);
    title(panels{q, 2}, 'FontWeight', 'bold', 'Color', c.ink, 'FontSize', 9);
    if q >= 3, xlabel('Diesel price ($/L)'); end
    if q == 1
        text(be_ab - 0.012, ylo + 0.05 * (yhi - ylo), sprintf('%.2f', be_ab), 'HorizontalAlignment', 'right', ...
             'Color', c.ink2, 'FontSize', 7.5);
        text(be_b + 0.012, ylo + 0.05 * (yhi - ylo), sprintf('%.2f  break-even vs EDL', be_b), ...
             'HorizontalAlignment', 'left', 'Color', c.ink2, 'FontSize', 7.5);
    end
    if q == 2
        text(be_b + 0.03, ylo + 0.04 * (yhi - ylo), {'shaded: observed', sprintf('2023-2026, %.2f-%.2f', dp(1), dp(3))}, ...
             'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'Color', c.ink2, 'FontSize', 7.5);
    end
end
save_figure(fig, fname);
end
