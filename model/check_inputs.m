function chk = check_inputs(D)
%CHECK_INPUTS  Compare the loaded series with inputs/inputs_summary.md.
%
%   chk = check_inputs(D)
%
% The expected values are read from inputs_summary.md itself (annual load
% energy and peak, PV yield per tilt and per weather year, grid hours), so
% the check stays valid when the inputs are regenerated. The summary rounds
% to 0.1 MWh, 0.1 kW, 1 kWh/kWp and 1 h; the tolerance is half of that.
%
%   chk   struct array with fields name, expected, actual, tol, pass
% An error is raised if any check fails.

txt   = fileread(fullfile(D.input_dir, 'inputs_summary.md'));
lines = regexp(txt, '[^\r\n]+', 'match');
chk = struct('name', {}, 'expected', {}, 'actual', {}, 'tol', {}, 'pass', {});

% ---- load: "| name | x MWh / y kW | x MWh / y kW | x MWh / y kW |" (low, base, high)
cases = {'low', 'base', 'high'};
rows  = {'chalets', 'chalets_kW'; 'club_total', 'club_total_kW'; ...
         'critical', 'critical_kW'; 'total (club + chalets)', 'total_kW'};
for r = 1:size(rows, 1)
    ln  = find_line(lines, ['| ' rows{r, 1} ' |'], ['| **' rows{r, 1} '** |']);
    tok = regexp(ln, '([\d.]+) MWh / ([\d.]+) kW', 'tokens');
    assert(numel(tok) == 3, 'check_inputs:parse', 'Cannot read the "%s" row.', rows{r, 1});
    for j = 1:3
        v = D.load.(cases{j}).(rows{r, 2});
        chk = add(chk, sprintf('load %s: %s energy (MWh)', cases{j}, rows{r, 1}), ...
                  str2double(tok{j}{1}), sum(v) * D.par.time.dt_h / 1000, 0.051);
        chk = add(chk, sprintf('load %s: %s peak (kW)', cases{j}, rows{r, 1}), ...
                  str2double(tok{j}{2}), max(v), 0.051);
    end
end

% ---- PV: "| tilt | base | base with snow | low | ..." in kWh/kWp
tilts = D.par.pv.base_tilt_deg_candidates(:)';
for tilt = tilts
    v = row_numbers(find_line(lines, sprintf('| %d | ', tilt)));
    chk = add(chk, sprintf('PV base_t%d (kWh/kWp)', tilt),      v(2), sum(D.pv.(sprintf('base_t%d', tilt))), 0.51);
    chk = add(chk, sprintf('PV base_t%d_snow (kWh/kWp)', tilt), v(3), sum(D.pv.(sprintf('base_t%d_snow', tilt))), 0.51);
    chk = add(chk, sprintf('PV low_t%d (kWh/kWp)', tilt),       v(4), sum(D.pv.(sprintf('low_t%d', tilt))), 0.51);
end
v = row_numbers(find_line(lines, '| 40 (ERA5, high) |'));
chk = add(chk, 'PV high_t40 (kWh/kWp)',      v(2), sum(D.pv.high_t40), 0.51);
chk = add(chk, 'PV high_t40_snow (kWh/kWp)', v(3), sum(D.pv.high_t40_snow), 0.51);

% ---- multi-year PV: "| year | t30 | t40 | t50 | t60 | ..."
names = fieldnames(D.pvmy);
years = [];
for j = 1:numel(names)
    y = sscanf(names{j}, 'y%d_t');
    if ~isempty(y), years(end + 1) = y; end %#ok<AGROW>
end
years = unique(years);
for y = years
    v = row_numbers(find_line(lines, sprintf('| %d | ', y)));
    for j = 1:numel(tilts)
        col = sprintf('y%d_t%d', y, tilts(j));
        chk = add(chk, ['PV ' col ' (kWh/kWp)'], v(1 + j), sum(D.pvmy.(col)), 0.51);
    end
end

% ---- grid: "- `u_base_feeder`: 2960 h/yr (8.1 h/day)"
names = fieldnames(D.grid);
for j = 1:numel(names)
    if strncmp(names{j}, 'u_', 2)
        ln  = find_line(lines, ['- `' names{j} '`:']);
        tok = regexp(ln, ':\s*(\d+) h/yr', 'tokens', 'once');
        chk = add(chk, ['grid ' names{j} ' (h/yr)'], str2double(tok{1}), sum(D.grid.(names{j})), 0.5);
    end
end

bad = find(~[chk.pass]);
for j = bad
    fprintf(2, 'INPUT CHECK FAILED  %s: expected %.3f, got %.3f\n', chk(j).name, chk(j).expected, chk(j).actual);
end
assert(isempty(bad), 'check_inputs:mismatch', ...
       '%d loaded series do not match inputs_summary.md.', numel(bad));
end

% =========================================================================
function chk = add(chk, name, expected, actual, tol)
chk(end + 1) = struct('name', name, 'expected', expected, 'actual', actual, ...
                      'tol', tol, 'pass', abs(actual - expected) <= tol);
end

% =========================================================================
function ln = find_line(lines, varargin)
% First line that starts with one of the given prefixes.
ln = '';
for j = 1:numel(lines)
    for p = 1:numel(varargin)
        if strncmp(lines{j}, varargin{p}, numel(varargin{p}))
            ln = lines{j};
            return
        end
    end
end
error('check_inputs:parse', 'Row "%s" not found in inputs_summary.md.', varargin{1});
end

% =========================================================================
function v = row_numbers(ln)
% Numbers in the cells of a markdown table row (first cell included).
cells = strtrim(strsplit(ln, '|'));
cells = cells(2:end - 1);
v = nan(1, numel(cells));
for j = 1:numel(cells)
    tok = regexp(cells{j}, '^-?[\d.]+', 'match', 'once');
    if ~isempty(tok), v(j) = str2double(tok); end
end
end
