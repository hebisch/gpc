program Goto8;

var
  i : Integer = 2;

label
  foo;

begin
  var c : array [1 .. i] of Char;
  c [1] := 'O';
  c [i] := 'K';
  goto foo;
  WriteLn ('failed');
  Halt;
foo:
  WriteLn (c)
end.
