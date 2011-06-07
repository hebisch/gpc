program fjf599c;

type
  t (a: Integer) = array [1 .. a] of Char;

procedure p (s: t);
begin
  WriteLn (s)
end;

var
  v: ^procedure (s: t) = @p;
  a: t (2) = 'OK';

begin
  v^ (a)
end.
