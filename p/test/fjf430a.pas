program fjf430a;

const
  b : Integer = 42;

var
  a : Text;

begin
  {$i-}
  {$local nested-comments,I+,W no-typed-const}
  { A { nested } comment }
  Inc (b);
  {$endlocal}
  { A {non-{nested comment }
  Reset (a);
  {$I+}
  if IOResult = 0
    then WriteLn ('failed')
    else WriteLn ('OK')
end.
