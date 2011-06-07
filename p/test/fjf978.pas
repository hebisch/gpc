program fjf978;

var
  a: array ['A' .. 'E'] of String (255) = ('', 'O', '', 'K', '');

procedure p (var a: String);
begin
  Write (a)
end;

var
  ch: Char;

begin
  ch := 'B';
  p (a[ch]);
  ch := 'D';
  p (a[ch]);
  WriteLn
end.
