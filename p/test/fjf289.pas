program fjf289;

type
  o = object
    function f : pointer;
  end;

function o.f : pointer;
begin
  f := nil
end;

procedure p (s : string);
begin
  writeln ('failed')
end;

var v : o;

begin
  p (v.f) { WRONG }
end.
