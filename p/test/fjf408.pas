{ Should the Pascal preprocessor split arguments within brackets
  (like in C, as tested here), or not (then a pair of parentheses
  can be removed)? -- Frank }

program fjf408;

{$define FOO(x) x}

var
  a : array [1 .. 1, 1 .. 1] of Char;

begin
  a [1, 1] := 'O';
  WriteLn (FOO ((a [1, 1])), 'K')
end.
