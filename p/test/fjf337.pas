program fjf337;

{$W-}

type
  t1 = object
  protected
    bar : integer;
  end;

  t2 = object
    procedure foo;
  protected
    bar : integer;
  end;

procedure t2.foo;
begin
end;

begin
  writeln ('OK')
end.
