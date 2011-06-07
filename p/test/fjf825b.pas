program fjf825b;

type
  t = object
    procedure _foo;  { WRONG (unresolved forward) }
  end;

procedure T__foo;
begin
end;

begin
end.
