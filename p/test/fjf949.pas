program fjf949;

var
  a: array [Byte] of String (2);

begin
  a[0] := 'O';
  a[255] := 'K';
  WriteLn (a[0], a[255])
end.
