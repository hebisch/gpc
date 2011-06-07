module fjf667m interface;

export
  fjf667m = all;

procedure p (s: String);

end.

module fjf667m implementation;

procedure q (s: String);
begin
  WriteLn (s)
end;

procedure p (s: String);
begin
  q (s)
end;

end.
