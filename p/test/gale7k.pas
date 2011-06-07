{$object-pascal}
program gale7k (output);

type
  t = class 
     boolean : boolean { WRONG }
    end;

begin
writeln('FAIL');
end.

