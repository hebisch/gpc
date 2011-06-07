Program fjf16;

var
  x:record
    case d:integer of
      1:(a:cardinal);
      2:(a:integer)    { WRONG }
    end;

begin
  x.d:=2;
  x.a:=-1;
  x.d:=1;
  if x.a = -1 then
    writeln ( 'failed' );
end.
