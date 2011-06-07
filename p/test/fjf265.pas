program fjf265;

procedure foo (s : CString);
begin
  {$x+}
  writeln (s);
  {$x-}
end;

var
  a : ^string = @'OK';

begin
  foo (a^)
end.
