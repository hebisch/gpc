Program Str3CStr;

Procedure Puts ( S: Pointer ); external name 'puts';

Var
  E: array [ 0..2 ] of Char = 'OK'#0;

begin
  Puts ( String2CString ( E ) );
end.
