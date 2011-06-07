{$W no-underscore}

program fjf825a;

type
  t = object
    procedure _foo;
  end;

procedure t._foo;
begin
  WriteLn ('OK')
end;

procedure T__foo (var Self: t); attribute (name = 'Baz');
begin
  WriteLn ('failed')
end;

var
  v: t;

begin
  v._foo
end.
