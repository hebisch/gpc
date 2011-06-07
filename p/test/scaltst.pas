program test(output);

var
i :integer;
j :boolean;
t :real;

begin
i := 1;
t := i;
writeln({$if False} Real(i) -- not allowed anymore Frank, 20030317 {$else} t {$endif}:6:2);
j := TRUE;
writeln(false);
writeln(j);
end.
