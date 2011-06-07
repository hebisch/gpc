{$W no-object-assignment}

program fjf884x;

type
  a = object
    c: Char;
  end;

  b = object (a)
    d: Char;
  end;

procedure p (t: a);
begin
  WriteLn (t is b)  { WARN }
end;

begin
end.
