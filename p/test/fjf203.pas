{ `-w' so gpc1 won't complain about `--unsigned-bitfields' with `-W' }
{ FLAG --autobuild --gnu-pascal -w --unsigned-bitfields }
{$W+}

program fjf203;
{$L fjf203c.c}
procedure OK; external name 'ok';
begin
  OK
end.
