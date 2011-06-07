Program Str2CStr;

Procedure Puts ( S: Pointer ); external name 'puts';

Var
  E: String ( 2 ) = 'OK';

begin
  Puts ( String2CString ( E ) );
end.
