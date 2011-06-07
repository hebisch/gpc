{$W-}

program john2f;

type
   r = record
       f1 : integer;
       f2 : text;
       end;

function x : r; { WRONG }
  var i : r;
  begin
  end;

begin
  writeln ('failed')
end.
