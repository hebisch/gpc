program fjf163;
var
  a:Boolean;
  f:file;
begin
  WriteLn('Failed');
  Halt;
  BlockRead(f,a,0,a) {WRONG}
end.
