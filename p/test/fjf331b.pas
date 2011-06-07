Program fjf331b;

Type
  CharArray = packed array [ 1..6 ] of Char;

Var
  a: LongInt;

begin
  CharArray ( a ):= 'failed';  { WARN }
  writeln ( CharArray ( a ) );  { WARN }
end.
