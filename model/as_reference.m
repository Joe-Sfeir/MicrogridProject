function r = as_reference(s)
%AS_REFERENCE  Status-quo version of a scenario: grid + diesel only.
%   Same load, grid, prices and reliability limit as s, with P_pv = E_b = P_b = 0.
%   This is what the microgrid of scenario s is compared to.
r = s;
r.name  = [s.name '_ref'];
r.label = ['Reference for ' s.label];
r.group = 'Reference';
r.side  = '';
r.fix   = struct('P_pv', 0, 'E_b', 0, 'P_b', 0);
r.cap   = struct();
r.E_res = 0;            % no battery, so no battery reserve for the T1 lift:
                        % today the recovery drive is supplied by the gensets
r.export  = false;      % nothing to export without PV
r.elastic = false;
r.pv_scale = 1;
end
