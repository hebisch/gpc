program confa1(output);
type  ii = integer value 17;
      ivr = record case boolean of
             false : ( f1 : ii);
             true  : (f2 : boolean)
           end;
var v : ivr;

procedure ff(a, b: ivr);
begin
  writeln('OK')
end;

begin
  ff(v, v)
end
.
