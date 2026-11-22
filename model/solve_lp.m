function [x, fval, exitflag, info] = solve_lp(f, A, b, Aeq, beq, lb, ub)
%SOLVE_LP  Solve the LP  min f'x  s.t.  A x <= b,  Aeq x = beq,  lb <= x <= ub.
%
%   MATLAB:      linprog (Optimization Toolbox). From R2024a its default
%                algorithm is the HiGHS dual simplex.
%   GNU Octave:  has no linprog. Large problems go to HiGHS through
%                highs_bridge.py (needs python3 with scipy); small ones, or
%                all of them if python is missing, go to the built-in glpk.
%
%   exitflag = 1 means an optimal solution was found (as in linprog).
%   info     = struct with fields solver, message, iterations, time (s).

info = struct('solver', '', 'message', '', 'iterations', NaN, 'time', NaN);
t0 = tic;

if exist('OCTAVE_VERSION', 'builtin') == 0
    % ---------------- MATLAB ----------------
    % linprog's default ConstraintTolerance is 1e-4, looser than the 1e-6 kW
    % asked of the power balance: tighten it. If this release does not
    % accept the value, solve with the defaults.
    opts0 = optimoptions('linprog', 'Display', 'none');
    try
        opts = optimoptions(opts0, 'ConstraintTolerance', 1e-8);
        [x, fval, exitflag, out] = linprog(f, A, b, Aeq, beq, lb, ub, opts);
    catch
        [x, fval, exitflag, out] = linprog(f, A, b, Aeq, beq, lb, ub, opts0);
    end
    info.solver = 'MATLAB linprog';
    if isfield(out, 'algorithm'),  info.solver = ['MATLAB linprog (' out.algorithm ')']; end
    if isfield(out, 'iterations'), info.iterations = out.iterations; end
    if isfield(out, 'message'),    info.message = first_line(out.message); end
elseif numel(f) > 5000 && have_highs_bridge()
    % ---------------- Octave, HiGHS ----------------
    [x, fval, exitflag, info] = highs_via_python(f, A, b, Aeq, beq, lb, ub, info);
else
    % ---------------- Octave, glpk ----------------
    ctype = [repmat('U', 1, size(A, 1)), repmat('S', 1, size(Aeq, 1))];
    vtype = repmat('C', 1, numel(f));
    param.msglev = 0;
    [x, fval, errnum, extra] = glpk(f, [A; Aeq], [b; beq], lb, ub, ctype, vtype, 1, param);
    if errnum == 0 && extra.status == 5      % 5 = optimal
        exitflag = 1;
    else
        exitflag = -2;  x = [];  fval = [];
    end
    info.solver = 'GNU Octave glpk';
    info.message = sprintf('glpk errnum %d, status %d', errnum, extra.status);
end

info.time = toc(t0);
end

% -------------------------------------------------------------------------
function s = first_line(msg)
msg = strtrim(char(msg));
parts = regexp(msg, '[^\r\n]+', 'match', 'once');
if isempty(parts), s = ''; else, s = parts; end
end

% -------------------------------------------------------------------------
function tf = have_highs_bridge()
% True if python3 with scipy can be called (checked once per session).
persistent ok
if isempty(ok)
    [st, ~] = system('python3 -c "import scipy.optimize, scipy.io"');
    ok = (st == 0);
    if ~ok
        warning('solve_lp:noHighs', ['python3 with scipy not found: falling back to glpk, ', ...
                'which is very slow for the 8760-hour problem.']);
    end
end
tf = ok;
end

% -------------------------------------------------------------------------
function [x, fval, exitflag, info] = highs_via_python(f, A, b, Aeq, beq, lb, ub, info)
base = tempname();
fin  = [base '_in.mat'];
fout = [base '_out.mat'];
save('-v7', fin, 'f', 'A', 'b', 'Aeq', 'beq', 'lb', 'ub');
py = fullfile(fileparts(mfilename('fullpath')), 'highs_bridge.py');
[st, txt] = system(sprintf('python3 "%s" "%s" "%s"', py, fin, fout));
if st ~= 0 || ~exist(fout, 'file')
    if exist(fin, 'file'), delete(fin); end
    error('solve_lp:bridge', 'highs_bridge.py failed:\n%s', txt);
end
o = load(fout);
delete(fin);  delete(fout);
info.solver = 'HiGHS dual simplex (scipy, called from GNU Octave)';
info.message = strtrim(char(o.message));
info.iterations = o.nit;
if o.status == 0
    exitflag = 1;  x = o.x(:);  fval = o.fval;
else
    exitflag = -2; x = [];      fval = [];
end
end
