Program ProcVar2;

Type
  FixString = array [ 1..2 ] of Char;

Var
  OK: Procedure ( Const S: FixString );


Procedure MyOK ( Const S: FixString );

begin { MyOK }
  writeln ( S );
end { MyOK };


begin
  OK:= MyOK;
  OK ( 'OK' );
end.
