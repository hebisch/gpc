{ For strings, discriminants do not have to match for assignment-compatibility }

program fjf1044e;

procedure p (n: Integer);
var
  e: array [1 .. 10] of String (40);
  f: packed array [21 .. 30] of String (n - 2);
  g: String (40);
  h: String (n - 2);
begin
  e[2] := 'abc';
  Pack (e, 1, f);
  f[24] := 'def';
  Unpack (f, e, 1);
  h := 'ghi';
  g := h;
  if (f[22] = 'abc') and (e[4] = 'def') and (g = 'ghi') then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p (43)
end.
