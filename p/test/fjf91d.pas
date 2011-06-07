program fjf91d (Output); { correct according to EP }

type
  str5 = string [5];

var
  s : string [5] value 'OK';

procedure p(var s : str5);
begin
  writeln(s)
end;

begin
  p(s)
end.
