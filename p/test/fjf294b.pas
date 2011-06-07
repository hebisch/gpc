program fjf294b;

uses fjf294u;

var v : array [1..1] of t = ((42, -23498));

begin
  if v [1, false] = 42 then writeln ('OK') else writeln ('failed')
end.
