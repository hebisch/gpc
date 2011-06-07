program fjf413a;

const
  Foo : array [1 .. 2] of Char = {$W-} ^^ {$W+};

begin
  WriteLn (Foo)
end.
