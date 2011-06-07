Program fjf22;

{$borland-pascal}

Var
  OK: Procedure;

Procedure WriteOK;

begin { WriteOK }
  writeln ( 'OK' );
end { WriteOK };

begin
  @OK:= @WriteOK;
  OK;
end.
