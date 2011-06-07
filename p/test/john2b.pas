program john2b;

type
   r = record
       f1 : integer;
       f2 : text;
       end;

function x : r; { WRONG }
  var i : r;
  begin
  x := i; { WRONG }
  end;

begin
  writeln ('failed')
end.
