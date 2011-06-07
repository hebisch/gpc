{$extended-pascal}
program gale7l (output);
type rt = 0..255;
type
  t = record
      rt : rt  {WRONG}
    end;

begin
writeln('FAIL');
end.

