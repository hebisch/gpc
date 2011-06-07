program fjf215;
{$setlimit=131072}
type
  int17 = integer attribute (Size = 17);
var
  a:set of shortint;
  b:set of int17;
begin
  if (bitsizeof(a) = 1 shl bitsizeof(shortint)) and
     (bitsizeof(b) = 131072)
    then writeln ('OK')
    else writeln ('Failed: ', bitsizeof(a), ' ', bitsizeof(b))
end.
