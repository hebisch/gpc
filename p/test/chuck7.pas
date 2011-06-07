program Chuck7 (Output);

var
  f: Text;
  i: Integer;
  s: String (100);

begin
          rewrite(f);
          write(f, '     ');
          writeln (f);
          write(f, ' ' : 5);
          writeln (f);
          i := 5; write(f, ' ' : i);
          writeln (f);
          reset (f);
          for i := 1 to 3 do
            begin
              readln (f, s);
              if (Length (s) <> 5) or not EQ (s, '     ') then
                begin
                  writeln ('failed ', i);
                  halt
                end
            end;
          writeln ('OK')
end.
