program fjf71;
type t(a:integer)=array[1..a] of integer;

procedure p(var v:t);
begin
 writeln(v.x)  { WRONG }
end;

begin
  writeln ( 'failed' );
end.
