{ WRONG now, Frank 20030415 }

program fjf555b;

var
  a: array [Boolean] of Pointer;
  i: Integer = 17;

label
  f, t;

begin
  a[False] := &&f;
  a[True] := &&t;
  goto (a[i = 42]);
  WriteLn ('failed 1');
  Halt;
f:WriteLn ('OK');
  Halt;
t:WriteLn ('failed 2');
end.
