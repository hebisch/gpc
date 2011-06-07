Program BO5_17;

Type
  StringPtr = ^String;

Var
  OK: Pointer;

begin
  OK:= @'OK';
  writeln ( StringPtr ( OK )^ );
end.
