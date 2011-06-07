program fjf98; { WRONG }
type a(b:integer)=array[1..b] of integer;
begin
 writeln('Failed ',sizeof(a))
end.
