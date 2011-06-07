program fjf334;

const
  s = "foo\nbar\nbaz\n";

var
  f : file;
  b : array [1 .. 100] of char;
  r : integer;

begin
  reset (f, '-', 1);
  r := 0;
  if not eof (f) then
    begin
      blockread (f, b, sizeof (b), r);
      if (r = length (s)) and (b [1 .. r] = s) then
        begin
          writeln ('OK');
          halt
        end
    end;
  writeln ('failed: ', b [1 .. r])
end.
