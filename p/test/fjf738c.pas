program fjf738c;
type t = record
           a: Integer;
           b: Text
         end;
var f:file of t; (* WRONG - illegal component type *)
begin
  writeln('failed')
end.
