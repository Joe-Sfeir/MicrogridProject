function r = as_reference(s)
%AS_REFERENCE  Status-quo version of a scenario: grid + diesel only.
%   Same load, grid, prices and reliability limit as s, with P_pv = E_b = P_b = 0.
%   This is what the microgrid of scenario s is compared to.
r = s;
r.name  = [s.name '_ref'];
r.label = ['Reference for ' s.label];
r.group = 'Reference';
r.side  = '';
r.fix.P_pv = 0;
r.fix.E_b  = 0;
r.fix.P_b  = 0;
end
