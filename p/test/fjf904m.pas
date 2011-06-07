program fjf904m;
procedure bar;
begin
end;
var baz : procedure;
begin
  baz := bar;
  CompilerAssert (true, baz); { WRONG }
end
.
