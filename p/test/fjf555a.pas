{ WRONG now, Frank 20030415 }

program fjf555a;

var
  a: array [Boolean] of Pointer;
  i: Integer = 42;

label
  f, t;

begin
  a[False] := &&f;
  a[True] := &&t;
  goto (a[i = 42]);
  WriteLn ('failed 1');
  Halt;
f:WriteLn ('failed 2');
  Halt;
t:WriteLn ('OK');
end.
