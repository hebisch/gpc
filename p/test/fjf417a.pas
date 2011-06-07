program fjf417a;

label $42;  { WRONG }

begin
  WriteLn ('failed');
  Halt;
  $42: goto 42
end.
