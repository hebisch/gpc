program fjf990;

var
  a: packed array [1 .. 1] of Integer = (42);
  m, n: Integer = 0;

function f: Integer;
begin
  Inc (m);
  f := 1
end;

function g: Integer;
begin
  Inc (n);
  g := 1
end;

begin
  Inc (a[f]);
  and (a[g], 15);
  if (m = 1) and (n = 1) and (a[1] = 11) then WriteLn ('OK') else WriteLn ('failed')
end.
