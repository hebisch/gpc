Program ProcVar1;

Var
  OK: Procedure;


Procedure MyOK;

begin { MyOK }
  writeln ( 'OK' );
end { MyOK };


begin
  OK:= MyOK;
  OK;
end.
