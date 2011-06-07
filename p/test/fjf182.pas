program fjf182;

procedure OK ( Str : String );
Begin
  writeln (Str)
End;

procedure OK2 ( Const Str : String );
Begin
   OK ( Str );
End;

Begin
  OK2('OK')
End.
