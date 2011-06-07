module fjf818m interface;

export fjf818m = all;

type
  t = object
    procedure p;
  end;

end.

module fjf818m implementation;

procedure t.p;
begin
  WriteLn ('OK')
end;

end.
