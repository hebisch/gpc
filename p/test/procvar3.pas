Program ProcVar3;


Var
  OK: Procedure ( S: String );
  KO: String ( 30 ) value 'OK';


Procedure MyOK ( S: String );

begin { MyOK }
  writeln ( S );
end { MyOK };


begin
  OK:= MyOK;
  OK ( KO );
end.
