program fjf618;

type
  t = array [1 .. 10] of Integer;

procedure p (const a: t);
begin
end;

var
  v: ^procedure (var a: t);

begin
  v := @p;  { WRONG }
  WriteLn ('failed')
end.
