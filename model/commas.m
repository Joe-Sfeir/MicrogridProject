function str = commas(x)
%COMMAS  Integer as text with thousands separators: commas(1234567) = '1,234,567'.
x = round(x);
str = regexprep(sprintf('%.0f', abs(x)), '(\d)(?=(\d{3})+$)', '$1,');
if x < 0, str = ['-' str]; end
end
