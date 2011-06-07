program subset_problem(input,output);

const setlimit = 4;

type
subset = set of 0..255;

var
seta, setb: subset;

function recursive_setprint(set1: subset):subset;
var
i           : 0 .. setlimit + 1;
found       : boolean;

begin
  if set1 <> [] then
    begin
    i:= 0;
    found := false;
    while ((i <= setlimit) and (not found)) do
      begin
      if i in set1 then
        begin
        writeln('first element: ',i);
        found := true;
        recursive_setprint := recursive_setprint(set1 - [i]);
        end;
      i := i + 1;
      end
    end
end;

begin
  seta := [0..setlimit];
  setb :=  recursive_setprint(seta);
end.
