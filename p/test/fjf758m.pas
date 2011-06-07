{$extended-pascal}

module fjf758m interface;

export fjf758m = (bar);

procedure bar;

end.

module fjf758m implementation;

procedure foo; forward;  { WRONG }

var
  a: Integer;

procedure foo;
begin
end;

procedure bar;
begin
end;

end.
