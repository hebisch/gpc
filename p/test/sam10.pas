program foo2;

type
  r1 = 0 .. 255;

  t1 = packed record { has to be packed }
    case integer of
        1: (f1: r1);
      end;

var
  v1: t1;

procedure foo1;
begin
v1.f1 := 127;
v1.f1 := 128;
v1.f1 := 255;
writeln('OK')
end;

begin
    foo1;
end.
