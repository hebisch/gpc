{ FLAG -Werror }

{ Gives a superfluous warning on machines with strict alignment }
{ requirements, such as Sparc. }

program fjf286;
type
  p1 = ^t1;
  t1 = object
  end;

  p2 = ^t2;
  t2 = object (t1)
    foo : LongInt;
    procedure m;
  end;

procedure t2.m;
begin
  if (AlignOf (t1) = AlignOf (t2)) and (AlignOf (t2) >= AlignOf (LongInt)) then writeln ('OK') else writeln ('failed')
end;

var
  v : t2;
  p : p1;

begin
  p := @v;
  p2 (p)^.m
end.
