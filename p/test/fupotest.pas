program zap(output);

type
    proc_ptr = ^ procedure (i: integer);

var
    pvar : proc_ptr;

procedure write_int(i: integer);
begin
  if i = 12345 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end;

begin
  { PVAR points to function WRITE_IT }
  pvar := @write_int;

  { Dereferencing a function pointer calls the function }
  pvar^(12345);
end.
