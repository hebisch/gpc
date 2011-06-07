{ Lexer problem }

program fjf528b;

var
  a: array [Boolean] of String (6) = ('Failed', 'OK');
  r: Real = 3;

begin
  {$W-}
  WriteLn (a (.r > 2..))
end.
