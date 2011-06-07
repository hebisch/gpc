program fjf35;

procedure pp(procedure proc);
begin
  proc
end;

procedure global(x:String);

  procedure loc;
  begin
    writeln(x)
  end;

begin
  pp(loc)
end;

begin
  global('OK')
end.
