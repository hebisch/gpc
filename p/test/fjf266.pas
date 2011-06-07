program fjf266;
{$define foo}
{$if defined(foo)}
begin
  writeln ('OK')
end.
{$endif}
