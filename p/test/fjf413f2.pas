program fjf413f2;

var
  Foo : array [(^a) .. (^f)] of array [(^k) .. (^o)] of (^m) .. (^x);

begin
  if (Low (Foo) = (^a)) and (High (Foo) = (^f)) and
     (Low (Foo [(^b)]) = (^k)) and (High (Foo [(^e)]) = (^o)) and
     (Low (Foo [(^c), (^n)]) = (^m)) and (High (Foo [(^d)] [(^m)]) = (^x)) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
