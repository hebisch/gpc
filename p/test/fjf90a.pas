program fjf90a;

procedure y; begin end;

const a:^procedure=@y;

begin
  if a=@y then writeln('OK') else writeln('Failed')
end.
