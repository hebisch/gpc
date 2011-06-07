program john2a;

function x : text; { WRONG }
  var i : text;
  begin
  x := i; { WRONG }
  end;

begin
  writeln ('failed')
end.
