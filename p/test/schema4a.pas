Program Test;

Type
  b ( a: Integer ) = array [ a..-1 ] of Integer;

Var
  c: b (42);  { WRONG (crashes no more with gcc-2.8.0:-) }

begin
  writeln ( 'failed' );
end.
