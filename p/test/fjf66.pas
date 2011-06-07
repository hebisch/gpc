program fjf66;
type x(a:integer)=record
        a:array[1..a] of integer;  { WRONG }
       end;
begin
  writeln ( 'failed' );
end.
