Program CharsB;

Type
  Y = packed array [ ^A..^B ] of Char;

Const
  OK: Y = 'ab';

begin
  OK [ ^B ]:= 'X';  { WARN }
  WriteLn ('failed')
end.
