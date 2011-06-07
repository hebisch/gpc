program fjf417b;

label $42;  { WRONG }

begin
  WriteLn ('failed');
  Halt;
  $42: goto 66
end.
