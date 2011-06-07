program Dimwit2;

procedure p;

  function g: Boolean;
  begin
    g := True
  end;

  function f: Boolean;
  begin
    f := False
  end;

  function f: Boolean;  { WRONG }
  begin
    repeat until g
  end;

begin
end
.
