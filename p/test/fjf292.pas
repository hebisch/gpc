program fjf292;

var
  a, b : integer;
  s : string (10);

begin
  s := '2';
  s := '';
  a := 42;
  b := 666;
  val (s, a, b);
  if (a in [0, 42]) and (b = 1) then writeln ('OK') else writeln('failed ', a, ' ', b)
end.
