{$extended-pascal}
program gale7b (output);

type
  t = record
    b : boolean;
    boolean : integer; { WRONG }
    end;

begin
writeln('FAIL');
end.

