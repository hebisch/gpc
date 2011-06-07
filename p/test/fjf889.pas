program fjf889;

procedure Foo (const Buf; Size: SizeType);
var
  Buffer: array [1 .. Size] of Char absolute Buf;
begin
  WriteLn (Copy (Buffer, 2, 2))
end;

var
  a: array [1 .. 4] of Char = 'POKI';

begin
  Foo (a, 4)
end.
