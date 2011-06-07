program fjf601d;

procedure p (var f: File);
const OK: array [1 .. 2] of Char = 'OK';
begin
  BlockWrite (f, OK, 2)
end;

var
  v: procedure (var f: File) = p;
  f: File;

begin
  Rewrite (f, '', 1);
  v^ (f);
  WriteLn
end.
