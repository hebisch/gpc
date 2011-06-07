program fjf340d (Output);

{ FLAG --extended-pascal }

procedure foo (var a : array [m .. n : Integer] of Integer);
begin
  writeln ('failed')
end;

var
  a : array [42 .. 45] of Integer;

begin
  a [42] := 666;
  a [43] := 777;
  a [44] := 888;
  a [45] := 999;
  foo (a [43 .. 44]) { WRONG }
end.
