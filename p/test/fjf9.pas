Program fjf9;

Type
  StringPtr = ^String;
  String3 = String (3);

Var
  p: ^StringPtr;

begin
  New ( p );
  New ( p^, 3 );
  p^^:= 'OK';
  if SizeOf ( p^^ ) = SizeOf (String3) then
    writeln ( p^^ )
  else
    writeln ( 'failed: ', SizeOf ( p^^ ) );
end.
