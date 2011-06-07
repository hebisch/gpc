program fjf205;
{$define A(X) X}
{$define B(X) A(X)}
{$define C(X) A(#75)}
{$define D A(#42)}
begin
  if D=#42 then writeln(B(#79) C(foobar)) else writeln('Failed')
end.
