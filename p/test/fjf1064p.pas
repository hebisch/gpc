module fjf1064p;

export fjf1064p = (a);

Operator = (a, b: TimeStamp) = c: Boolean;

const
  a = 42;

end;

Operator = (a, b: TimeStamp) = c: Boolean;
begin
  c := a.Hour = b.Hour
end;

var
  d, e: TimeStamp Value [Hour: 23];

to begin do
  if not (d = e) then WriteLn ('failed');

end.
