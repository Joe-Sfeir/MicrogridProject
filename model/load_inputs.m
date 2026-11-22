function D = load_inputs(input_dir)
%LOAD_INPUTS  Read the hourly series and parameters.json into one struct.
%
%   D = load_inputs()             reads <repository>/inputs
%   D = load_inputs(input_dir)    reads the given folder
%
%   D.par     parameters.json as a struct (arrays are [low; base; high])
%   D.load    D.load.low, D.load.base, D.load.high: one field per CSV column
%   D.pv      pv_per_kWp.csv, one field per column (kW per kWp)
%   D.pvmy    pv_per_kWp_multiyear.csv, one field per column (y2014_t30, ...)
%   D.grid    grid_availability.csv, one field per column (0/1)
%   D.T       number of hours (8760)
%   D.month   month of each hour in local time (1..12)
%   D.t_local local time of each hour as a serial date number
%   D.wd      1 on weekends and holidays, D.ski = 1 on ski days
%
% No number is typed in here: everything comes from the files in inputs/.

if nargin < 1 || isempty(input_dir)
    input_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'inputs');
end
D = struct();
D.input_dir = input_dir;
D.par = jsondecode(fileread(fullfile(input_dir, 'parameters.json')));

cases = {'low', 'base', 'high'};
for j = 1:numel(cases)
    D.load.(cases{j}) = read_csv(fullfile(input_dir, ['load_' cases{j} '.csv']));
end
D.pv   = read_csv(fullfile(input_dir, 'pv_per_kWp.csv'));
D.pvmy = read_csv(fullfile(input_dir, 'pv_per_kWp_multiyear.csv'));
D.grid = read_csv(fullfile(input_dir, 'grid_availability.csv'));

% Common time index: all files must have the same hours in the same order
D.T = numel(D.load.base.hour);
assert(D.T == D.par.time.hours, 'load_inputs:hours', ...
       'Expected %d hourly rows, found %d.', D.par.time.hours, D.T);
files = {D.load.low, D.load.high, D.pv, D.pvmy, D.grid};
for j = 1:numel(files)
    assert(isequal(files{j}.hour, D.load.base.hour) && ...
           isequal(files{j}.time_utc, D.load.base.time_utc), 'load_inputs:index', ...
           'The input files do not share the same time index.');
end
D.month   = D.load.base.month;
D.t_local = parse_time(D.load.base.time_local);
D.wd      = D.load.base.weekend_or_holiday;
D.ski     = D.load.base.ski_day;
end

% =========================================================================
function S = read_csv(fname)
% Read a comma-separated file with one header row. Numeric columns become
% double column vectors, text columns (time stamps) cell arrays of char.
fid = fopen(fname, 'r');
assert(fid > 0, 'load_inputs:file', 'Cannot open %s', fname);
closer = onCleanup(@() fclose(fid));
header = strsplit(strtrim(fgetl(fid)), ',');
pos    = ftell(fid);
first  = strsplit(strtrim(fgetl(fid)), ',');
fseek(fid, pos, 'bof');
is_num = ~isnan(str2double(first));
fmt = '';
for j = 1:numel(header)
    if is_num(j), fmt = [fmt '%f']; else, fmt = [fmt '%s']; end %#ok<AGROW>
end
C = textscan(fid, fmt, 'Delimiter', ',');
S = struct();
for j = 1:numel(header)
    S.(header{j}) = C{j};
end
n = numel(C{1});
for j = 2:numel(C)
    assert(numel(C{j}) == n, 'load_inputs:ragged', 'Column %s of %s is incomplete.', header{j}, fname);
end
end

% =========================================================================
function dn = parse_time(c)
% 'yyyy-mm-dd HH:MM' strings -> serial date numbers.
v = sscanf(sprintf('%s;', c{:}), '%d-%d-%d %d:%d;');
v = reshape(v, 5, []).';
dn = datenum(v(:, 1), v(:, 2), v(:, 3), v(:, 4), v(:, 5), 0);
end
