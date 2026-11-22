function write_outputs(outdir, S)
%WRITE_OUTPUTS  Write the result tables (CSV) and results/README.md.
%
%   write_outputs(outdir, S)     S is the struct built by main.m
%
% Files
%   runs_all.csv                   all reported runs with every KPI and check
%   table_base_vs_reference.csv    base case next to the status quo
%   table_tilt.csv                 base case for each PV tilt
%   table_finance.csv              NPV, IRR, payback and their inputs
%   cashflow_base.csv              yearly cash flow of the base case
%   dispatch_base_hourly.csv       hourly dispatch of the base case
%   input_checks.csv               loaded series vs inputs_summary.md
% and, for the full study,
%   table_sensitivities.csv        one-at-a-time sensitivities
%   table_lpsp_shedding.csv        where the load is shed when LPSP > 0
%   table_export.csv               grid export cases
%   table_diesel_sweep.csv         diesel price sweep
%   table_weather_years.csv        base-case sizes, dispatch for 2014-2023
%   table_crosscheck_prototype.csv comparison with tools/prototype_lp.py
%   tornado_lcoe.csv               data of the tornado chart
%   README.md                      summary of all of the above (write_readme.m)
%
% Every CSV line is built with strjoin: MATLAB's fprintf skips empty
% arguments, which would shift the columns after an empty cell.

full = ~isempty(S.Ksens);
tl   = S.D.load.base.time_local;               % local time stamps of the hours

% ------------------------------------------------------------ all runs
all_runs = [S.Kref, S.Ktilt];
if full
    all_runs = [all_runs, S.Ksens, S.Ksweep, S.Kwx, S.Kwx_fixed];
    for j = 1:numel(S.cross.steps) - 1
        all_runs = [all_runs, S.cross.steps(j).K]; %#ok<AGROW>
    end
end
all_runs = [all_runs, S.Kdeg];
write_runs(fullfile(outdir, 'runs_all.csv'), all_runs, spec_all());

% --------------------------------------------------- base vs reference
sp = spec_all();
sp = sp(6:end - 6, :);                         % numbers only, without solver details
rows = cell(size(sp, 1), 3);
for j = 1:size(sp, 1)
    rows(j, :) = {sp{j, 1}, cell_of(S.Kref, sp(j, :)), cell_of(S.Kbase, sp(j, :))};
end
write_table(fullfile(outdir, 'table_base_vs_reference.csv'), {'quantity', 'reference', 'base_case'}, rows);

write_runs(fullfile(outdir, 'table_tilt.csv'), S.Ktilt, spec_short());

% -------------------------------------------------------- input checks
rows = cell(numel(S.chk), 5);
for j = 1:numel(S.chk)
    rows(j, :) = {strrep(S.chk(j).name, ',', ';'), sprintf('%.10g', S.chk(j).expected), ...
                  sprintf('%.10g', S.chk(j).actual), sprintf('%.3g', S.chk(j).tol), ...
                  sprintf('%d', S.chk(j).pass)};
end
write_table(fullfile(outdir, 'input_checks.csv'), ...
            {'check', 'expected_inputs_summary', 'loaded', 'tolerance', 'pass'}, rows);

% ----------------------------------------------------- hourly dispatch
R = S.Rbase;
fid = fopen(fullfile(outdir, 'dispatch_base_hourly.csv'), 'w');
fprintf(fid, ['hour,time_local,load_kW,critical_kW,grid_available,ski_day,lift_T1_on,pv_available_kW,' ...
              'p_pv_kW,p_cur_kW,p_ch_kW,p_dis_kW,soc_kWh,p_g_kW,p_ex_kW,p_dg_kW,u_dg_kW,ls_c_kW,ls_n_kW\n']);
M = [R.series.L, R.series.Lc, R.series.ug, double(R.series.ski), double(R.series.lift), ...
     R.series.a * R.P_pv, R.p_pv, R.p_cur, R.p_ch, R.p_dis, R.soc, R.p_g, R.p_ex, R.p_dg, R.u_dg, ...
     R.ls_c, R.ls_n];
for t = 1:R.T
    fprintf(fid, '%d,%s', t, tl{t});
    fprintf(fid, ',%.3f', M(t, :));
    fprintf(fid, '\n');
end
fclose(fid);

% -------------------------------------------------------------- finance
write_finance(fullfile(outdir, 'table_finance.csv'), S.fin);
Fb = S.fin(1).F;                               % base case
rows = cell(size(Fb.table));
is_factor = ismember(Fb.columns, {'pv_output_factor', 'discount_factor'});
for r = 1:size(Fb.table, 1)
    for c = 1:size(Fb.table, 2)
        v = Fb.table(r, c);
        if isnan(v)
            rows{r, c} = '';
        elseif c == 1
            rows{r, c} = sprintf('%d', v);
        elseif is_factor(c)
            rows{r, c} = sprintf('%.5f', v);
        else
            rows{r, c} = strip_minus_zero(sprintf('%.0f', v));
        end
    end
end
write_table(fullfile(outdir, 'cashflow_base.csv'), Fb.columns, rows);

if full
    write_runs(fullfile(outdir, 'table_sensitivities.csv'), [S.Kbase, S.Ksens], spec_short());
    write_runs(fullfile(outdir, 'table_weather_years.csv'), [S.Kwx, S.Kwx_fixed], spec_short());

    % ------------------------------------------------ LPSP: where load is shed
    Kl = [S.Kbase, S.Ksens(strcmp({S.Ksens.group}, 'LPSP limit'))];
    hdr = {'name', 'label', 'lpsp_achieved_pct', 'shed_MWh', 'shed_hours', 'largest_shed_kW', ...
           'largest_shed_time_local', 'share_on_ski_days_pct', 'share_dec_mar_pct', ...
           'share_in_worst_7_days_pct', 'worst_7_days_start_local', 'diesel_kW', 'diesel_MWh', ...
           'cost_USD_yr', 'cost_saving_vs_base_USD_yr', 'savings_vs_reference_pct'};
    rows = cell(numel(Kl), numel(hdr));
    for j = 1:numel(Kl)
        k = Kl(j);
        shed = k.E_uns_c + k.E_uns_n;
        rows(j, :) = {k.name, nocomma(k.label), sprintf('%.3f', 100 * k.lpsp), sprintf('%.2f', shed / 1000), ...
            sprintf('%d', k.uns_hours), sprintf('%.1f', k.uns_max_kW), time_of(tl, k.uns_max_hour), ...
            share(k.uns_ski_frac, shed), share(k.uns_winter_frac, shed), share(k.uns_week_frac, shed), ...
            time_of(tl, k.uns_week_start), sprintf('%.1f', k.P_d), sprintf('%.1f', k.E_diesel / 1000), ...
            sprintf('%.0f', k.cost), strip_minus_zero(sprintf('%.0f', S.Kbase.cost - k.cost)), ...
            sprintf('%.1f', 100 * k.savings_frac)};
    end
    write_table(fullfile(outdir, 'table_lpsp_shedding.csv'), hdr, rows);

    % ---------------------------------------------------------- grid export
    Ke = [S.Kbase, S.Ksens(strcmp({S.Ksens.group}, 'Grid export'))];
    hdr = {'name', 'label', 'exported_MWh', 'grid_import_MWh', 'export_credit_USD_yr', ...
           'curtailment_before_pct', 'curtailment_after_pct', 'curtailed_before_MWh', ...
           'curtailed_after_MWh', 'pv_kWp', 'pv_change_kWp', 'bess_kWh', 'bess_change_kWh', ...
           'cost_USD_yr', 'savings_vs_reference_USD_yr', 'savings_vs_reference_pct', 'npv_USD', ...
           'irr_pct', 'payback_discounted_yr'};
    rows = cell(numel(Ke), numel(hdr));
    B = S.Kbase;
    for j = 1:numel(Ke)
        k = Ke(j);
        F = fin_of(S.fin, k.name);
        rows(j, :) = {k.name, nocomma(k.label), sprintf('%.1f', k.E_export / 1000), ...
            sprintf('%.1f', k.E_grid / 1000), strip_minus_zero(sprintf('%.0f', -k.c_export)), ...
            sprintf('%.1f', 100 * B.curt_frac), sprintf('%.1f', 100 * k.curt_frac), ...
            sprintf('%.1f', B.E_curt / 1000), sprintf('%.1f', k.E_curt / 1000), sprintf('%.1f', k.P_pv), ...
            strip_minus_zero(sprintf('%.1f', k.P_pv - B.P_pv)), sprintf('%.1f', k.E_b), ...
            strip_minus_zero(sprintf('%.1f', k.E_b - B.E_b)), sprintf('%.0f', k.cost), ...
            sprintf('%.0f', k.savings), sprintf('%.1f', 100 * k.savings_frac), fnum(F, 'npv', '%.0f', 1), ...
            fnum(F, 'irr', '%.2f', 100), fnum(F, 'payback_disc', '%.2f', 1)};
    end
    write_table(fullfile(outdir, 'table_export.csv'), hdr, rows);

    % --------------------------------------------------- diesel price sweep
    hdr = {'name', 'diesel_price_USD_L', 'pv_kWp', 'bess_kWh', 'bess_kW', 'diesel_kW', 'grid_MWh', ...
           'diesel_MWh', 'fuel_L', 'cost_USD_yr', 'reference_cost_USD_yr', 'savings_USD_yr', ...
           'savings_pct', 'npv_USD', 'irr_pct', 'payback_simple_yr', 'payback_discounted_yr'};
    rows = cell(numel(S.Ksweep), numel(hdr));
    for j = 1:numel(S.Ksweep)
        k = S.Ksweep(j);
        F = fin_of(S.fin, k.name);
        rows(j, :) = {k.name, sprintf('%.2f', S.sweep(j).price_diesel), sprintf('%.1f', k.P_pv), ...
            sprintf('%.1f', k.E_b), sprintf('%.1f', k.P_b), sprintf('%.1f', k.P_d), ...
            sprintf('%.1f', k.E_grid / 1000), sprintf('%.1f', k.E_diesel / 1000), sprintf('%.0f', k.fuel_L), ...
            sprintf('%.0f', k.cost), sprintf('%.0f', k.ref_cost), sprintf('%.0f', k.savings), ...
            sprintf('%.1f', 100 * k.savings_frac), fnum(F, 'npv', '%.0f', 1), fnum(F, 'irr', '%.2f', 100), ...
            fnum(F, 'payback', '%.2f', 1), fnum(F, 'payback_disc', '%.2f', 1)};
    end
    write_table(fullfile(outdir, 'table_diesel_sweep.csv'), hdr, rows);

    % ------------------------------------- cross-check with the Python prototype
    hdr = {'run', 'source', 'pv_kWp', 'bess_kWh', 'cost_USD_yr', 'lcoe_USD_kWh', 'renewable_fraction', ...
           'diesel_MWh'};
    rows = cell(0, numel(hdr));
    for j = 1:numel(S.cross.rows)
        r = S.cross.rows(j);
        rows(end + 1, :) = {nocomma(r.label), 'prototype_lp.py', sprintf('%.0f', r.proto(1)), ...
            sprintf('%.0f', r.proto(2)), sprintf('%.0f', r.proto(3)), sprintf('%.3f', r.proto(4)), ...
            sprintf('%.2f', r.proto(5)), sprintf('%.0f', r.proto(6))}; %#ok<AGROW>
        rows(end + 1, :) = {nocomma(r.label), 'this model with prototype settings', ...
            sprintf('%.1f', r.model(1)), sprintf('%.1f', r.model(2)), sprintf('%.0f', r.model(3)), ...
            sprintf('%.4f', r.model(4)), sprintf('%.4f', r.model(5)), sprintf('%.1f', r.model(6))}; %#ok<AGROW>
    end
    for j = 1:numel(S.cross.steps)
        k = S.cross.steps(j).K;
        rows(end + 1, :) = {sprintf('gap step %d: %s', j, nocomma(S.cross.steps(j).label)), 'this model', ...
            sprintf('%.1f', k.P_pv), sprintf('%.1f', k.E_b), sprintf('%.0f', k.cost), ...
            sprintf('%.4f', k.lcoe), sprintf('%.4f', k.re_frac), sprintf('%.1f', k.E_diesel / 1000)}; %#ok<AGROW>
    end
    write_table(fullfile(outdir, 'table_crosscheck_prototype.csv'), hdr, rows);

    % --------------------------------------------------------- tornado data
    Tn = tornado_data(S.Kbase, S.Ksens, 'lcoe');
    rows = cell(numel(Tn), 6);
    for j = 1:numel(Tn)
        rows(j, :) = {Tn(j).group, sprintf('%.4f', Tn(j).lo), nocomma(Tn(j).lo_label), ...
                      sprintf('%.4f', Tn(j).base), sprintf('%.4f', Tn(j).hi), nocomma(Tn(j).hi_label)};
    end
    write_table(fullfile(outdir, 'tornado_lcoe.csv'), {'group', 'lcoe_low_USD_kWh', 'case_low', ...
                'lcoe_base_USD_kWh', 'lcoe_high_USD_kWh', 'case_high'}, rows);
end

write_readme(fullfile(outdir, 'README.md'), S);
end

% =========================================================================
function sp = spec_all()
% Columns of the run tables: header, KPI field, multiplier, number format.
sp = {
    'name',                        'name',           1,     '%s'
    'category',                    'category',       1,     '%s'
    'group',                       'group',          1,     '%s'
    'label',                       'label',          1,     '%s'
    'solved',                      'ok',             1,     '%d'
    'pv_kWp',                      'P_pv',           1,     '%.1f'
    'bess_kWh',                    'E_b',            1,     '%.1f'
    'bess_kW',                     'P_b',            1,     '%.1f'
    'diesel_kW',                   'P_d',            1,     '%.1f'
    'grid_connection_kW',          'P_gmax',         1,     '%.1f'
    'cost_USD_yr',                 'cost',           1,     '%.0f'
    'lcoe_USD_kWh',                'lcoe',           1,     '%.4f'
    'cost_without_throughput_USD_yr', 'cost_no_deg', 1,     '%.0f'
    'lcoe_without_throughput_USD_kWh','lcoe_no_deg', 1,     '%.4f'
    'reference_cost_USD_yr',       'ref_cost',       1,     '%.0f'
    'savings_USD_yr',              'savings',        1,     '%.0f'
    'savings_pct',                 'savings_frac',   100,   '%.1f'
    'savings_without_throughput_USD_yr', 'savings_no_deg',      1,   '%.0f'
    'savings_without_throughput_pct',    'savings_no_deg_frac', 100, '%.1f'
    'cash_opex_USD_yr',            'opex',           1,     '%.0f'
    'cost_pv_capex_USD_yr',        'c_pv_capex',     1,     '%.0f'
    'cost_pv_om_USD_yr',           'c_pv_om',        1,     '%.0f'
    'cost_bess_capex_USD_yr',      'c_b_capex',      1,     '%.0f'
    'cost_bess_om_USD_yr',         'c_b_om',         1,     '%.0f'
    'cost_bess_throughput_USD_yr', 'c_b_deg',        1,     '%.0f'
    'cost_diesel_capex_USD_yr',    'c_d_capex',      1,     '%.0f'
    'cost_fuel_USD_yr',            'c_fuel',         1,     '%.0f'
    'cost_diesel_om_USD_yr',       'c_dg_om',        1,     '%.0f'
    'cost_grid_USD_yr',            'c_grid',         1,     '%.0f'
    'cost_export_credit_USD_yr',   'c_export',       1,     '%.0f'
    'load_MWh',                    'E_load',         1e-3,  '%.1f'
    'served_MWh',                  'E_served',       1e-3,  '%.1f'
    'pv_available_MWh',            'E_pv_avail',     1e-3,  '%.1f'
    'pv_used_MWh',                 'E_pv_used',      1e-3,  '%.1f'
    'pv_exported_MWh',             'E_export',       1e-3,  '%.1f'
    'pv_curtailed_MWh',            'E_curt',         1e-3,  '%.1f'
    'curtailment_pct',             'curt_frac',      100,   '%.1f'
    'grid_MWh',                    'E_grid',         1e-3,  '%.1f'
    'diesel_MWh',                  'E_diesel',       1e-3,  '%.1f'
    'fuel_L',                      'fuel_L',         1,     '%.0f'
    'bess_discharge_MWh',          'E_dis',          1e-3,  '%.1f'
    'bess_cycles_per_yr',          'cycles',         1,     '%.1f'
    'renewable_fraction_pct',      're_frac',        100,   '%.1f'
    'non_grid_diesel_share_pct',   're_frac_served', 100,   '%.1f'
    'lpsp_pct',                    'lpsp',           100,   '%.3f'
    'unserved_noncritical_kWh',    'E_uns_n',        1,     '%.1f'
    'unserved_critical_kWh',       'E_uns_c',        1,     '%.1f'
    'shedding_hours',              'uns_hours',      1,     '%d'
    'shedding_max_kW',             'uns_max_kW',     1,     '%.1f'
    'shedding_share_ski_days_pct', 'uns_ski_frac',   100,   '%.1f'
    'shedding_share_dec_mar_pct',  'uns_winter_frac',100,   '%.1f'
    'shedding_share_worst_7_days_pct', 'uns_week_frac', 100, '%.1f'
    'co2_t',                       'co2_t',          1,     '%.1f'
    'co2_saved_t',                 'co2_saved_t',    1,     '%.1f'
    'diesel_hours',                'dg_hours',       1,     '%d'
    'diesel_hours_short_1_set',    'dg_short_n1',    1,     '%d'
    'diesel_hours_short_2_sets',   'dg_short_n2',    1,     '%d'
    'diesel_hours_short_3_sets',   'dg_short_n3',    1,     '%d'
    'check_balance_kW',            'chk_balance',    1,     '%.1e'
    'check_soc_kWh',               'chk_soc',        1,     '%.1e'
    'check_simultaneous_kW',       'chk_simul_kW',   1,     '%.1e'
    'check_lift_reserve_kWh',      'chk_reserve',    1,     '%.1e'
    'check_export_limits_kW',      'chk_export',     1,     '%.1e'
    'check_diesel_while_curtail_h','chk_dg_curt_h',  1,     '%d'
    'check_diesel_grid_spare_h',   'chk_dg_grid_h',  1,     '%d'
    'check_diesel_charging_h',     'chk_dg_charge_h',1,     '%d'
    'solve_time_s',                'solve_time',     1,     '%.1f'
    'variables',                   'n_var',          1,     '%d'
    'equalities',                  'n_eq',           1,     '%d'
    'inequalities',                'n_ineq',         1,     '%d'
    'nonzeros',                    'n_nz',           1,     '%d'
    'solver',                      'solver',         1,     '%s'
    };
end

% =========================================================================
function sp = spec_short()
% The columns of the paper tables.
sp = spec_all();
keep = {'name', 'group', 'label', 'pv_kWp', 'bess_kWh', 'bess_kW', 'diesel_kW', 'cost_USD_yr', ...
        'lcoe_USD_kWh', 'cost_without_throughput_USD_yr', 'reference_cost_USD_yr', 'savings_USD_yr', ...
        'savings_pct', 'savings_without_throughput_pct', 'grid_MWh', 'diesel_MWh', 'fuel_L', ...
        'pv_exported_MWh', 'renewable_fraction_pct', 'curtailment_pct', 'lpsp_pct', ...
        'unserved_noncritical_kWh', 'unserved_critical_kWh', 'bess_cycles_per_yr', 'co2_t', 'co2_saved_t'};
sp = sp(ismember(sp(:, 1), keep), :);
end

% =========================================================================
function write_runs(fname, K, sp)
rows = cell(numel(K), size(sp, 1));
for j = 1:numel(K)
    for q = 1:size(sp, 1)
        rows{j, q} = cell_of(K(j), sp(q, :));
    end
end
write_table(fname, sp(:, 1)', rows);
end

% =========================================================================
function write_table(fname, headers, rows)
% CSV file from a header row and a cell matrix of text cells.
fid = fopen(fname, 'w');
fprintf(fid, '%s\n', strjoin(headers, ','));
for j = 1:size(rows, 1)
    fprintf(fid, '%s\n', strjoin(rows(j, :), ','));
end
fclose(fid);
end

% =========================================================================
function str = cell_of(K, sprow)
% One KPI as text.
v = K.(sprow{2});
if ischar(v)
    str = nocomma(v);
elseif isnan(v)
    str = '';
else
    str = strip_minus_zero(sprintf(sprow{4}, double(v) * sprow{3}));
end
end

% =========================================================================
function str = strip_minus_zero(str)
% '-0' and '-0.0' become '0' and '0.0'.
if ~isempty(regexp(str, '^-0(\.0+)?$', 'once')), str = str(2:end); end
end

% =========================================================================
function str = nocomma(str)
str = strrep(str, ',', ';');
end

% =========================================================================
function str = time_of(tl, hour)
% Local time stamp of an hour index ('' if there is none).
if isnan(hour), str = ''; else, str = tl{hour}; end
end

% =========================================================================
function str = share(frac, total)
% Share in percent, empty when nothing was shed.
if total > 0, str = sprintf('%.1f', 100 * frac); else, str = ''; end
end

% =========================================================================
function F = fin_of(fin, name)
% Finance result of a run ([] if it was not computed).
j = find(strcmp({fin.name}, name), 1);
if isempty(j), F = []; else, F = fin(j).F; end
end

% =========================================================================
function str = fnum(F, field, fmt, scale)
% One finance number as text ('' if missing).
if isempty(F) || isnan(F.(field)), str = ''; else, str = sprintf(fmt, F.(field) * scale); end
end

% =========================================================================
function write_finance(fname, fin)
hdr = {'name', 'label', 'pv_kWp', 'bess_kWh', 'capex_pv_USD', 'capex_battery_USD', ...
       'capex_diesel_difference_USD', 'capex_total_USD', 'opex_reference_USD_yr', ...
       'opex_microgrid_year1_USD_yr', 'opex_microgrid_last_year_USD_yr', 'saving_year1_USD_yr', ...
       'saving_last_year_USD_yr', 'battery_replacement_USD', 'salvage_USD', 'npv_USD', 'irr_pct', ...
       'payback_simple_yr', 'payback_discounted_yr', 'npv_low_battery_replacement_USD', ...
       'max_lpsp_later_years_pct', 'max_unserved_critical_later_years_kWh', ...
       'check_npv_no_degradation_replacement_salvage_USD', 'check_annualized_saving_over_crf_USD', ...
       'check_gap_USD', 'gap_pv_life_USD', 'gap_battery_life_USD', 'gap_diesel_life_USD', ...
       'gap_throughput_cost_USD', 'gap_unexplained_USD'};
rows = cell(numel(fin), numel(hdr));
for j = 1:numel(fin)
    F = fin(j).F;  K = fin(j).K;
    label = K.label;
    if ~strcmp(K.group, 'Base'), label = [K.group ': ' K.label]; end
    rows(j, :) = {F.name, nocomma(label), sprintf('%.1f', K.P_pv), sprintf('%.1f', K.E_b), ...
        sprintf('%.0f', F.capex_pv), sprintf('%.0f', F.capex_b), strip_minus_zero(sprintf('%.0f', F.capex_d)), ...
        sprintf('%.0f', F.capex0), sprintf('%.0f', F.opex_ref), sprintf('%.0f', F.opex_mg_first), ...
        sprintf('%.0f', F.opex_mg_last), sprintf('%.0f', F.saving_first), sprintf('%.0f', F.saving_last), ...
        sprintf('%.0f', F.replacement_b), sprintf('%.0f', F.salvage), sprintf('%.0f', F.npv), ...
        fnum(F, 'irr', '%.2f', 100), fnum(F, 'payback', '%.2f', 1), fnum(F, 'payback_disc', '%.2f', 1), ...
        sprintf('%.0f', F.npv_repl_low), sprintf('%.4f', 100 * F.max_lpsp_later), ...
        sprintf('%.1f', F.max_uns_c_later), sprintf('%.0f', F.npv_simple), sprintf('%.0f', F.npv_annualized), ...
        sprintf('%.0f', F.gap), sprintf('%.0f', F.gap_pv), sprintf('%.0f', F.gap_b), ...
        strip_minus_zero(sprintf('%.0f', F.gap_d)), sprintf('%.0f', F.gap_deg), ...
        strip_minus_zero(sprintf('%.0f', F.gap_unexplained))};
end
write_table(fname, hdr, rows);
end
