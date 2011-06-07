{ BUG: Adress to jump to in __builtin_longjmp is stored in
  a local variable while stack is unwound.
  Fixed with gcc >= 2.95. Kept in todo/ meanwhile ... }

{ FLAG -O0 }

program fjf479;

label 0;

procedure f;
var z : real = 0;
begin
  if z = 0 then goto 0;
  WriteLn ('failed 1');
  Halt
end;

begin
  f;
  WriteLn ('failed 2');
  Halt;
0:WriteLn ('OK')
end.
