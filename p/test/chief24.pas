program Chief24;
uses chief24u;
begin
  if (strcmp('foo','foo')=0) and
     (strcmp('foo','bar')>0) then writeln('OK') else writeln('Failed')
end.
