Program Str1CStr;

Procedure Puts ( S: Pointer ); external name 'puts';

begin
  Puts ( String2CString ( 'OK' ) );
end.
