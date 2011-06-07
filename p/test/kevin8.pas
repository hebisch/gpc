program test(output);
var
      digits : set of '0'..'9' value ['0'..'9'];
begin
      if '0' in digits then
        writeln ( 'OK' )
      else
        writeln ( 'failed' );
end.
