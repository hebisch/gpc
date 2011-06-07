Program BO5_17a;

Type
  StringPtr = ^String;

Var
  OK: Pointer = @'OK';

begin
  writeln ( StringPtr ( OK )^ );
end.
