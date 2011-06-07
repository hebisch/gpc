program fjf172;
type t=(foo,bar);
const c:array[t] of String(1)=('O','K');
begin
  writeln(c[foo],c[bar])
end.
