program fjf236;

{$undef UNDEF}
{$if 0}
{$error 0}
{$elif defined(UNDEF)}
{$error UNDEF}
{$endif}

begin
  writeln ('OK')
end.
