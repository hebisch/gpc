program fjf1;

const maxvar=$fff0;

type
  x=integer;
  xarray=array[1..maxvar div sizeof(x)] of x;

begin
  Writeln ('OK')
end.
