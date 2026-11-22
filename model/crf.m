function f = crf(i, n)
%CRF  Capital recovery factor: CRF(i, n) = i (1+i)^n / ((1+i)^n - 1).
%   i  real discount rate (fraction per year), n  lifetime in years.
f = i .* (1 + i).^n ./ ((1 + i).^n - 1);
end
