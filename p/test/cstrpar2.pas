Program CStrPar2;

Var
  S: String ( 42 );

Procedure puts ( C: CString ); external name 'puts';

begin
  S:= 'xxfailed';
  S:= 'OK';
  puts ( S );
end.
