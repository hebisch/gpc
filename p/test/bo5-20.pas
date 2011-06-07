Program BO5_20;

{$x+}

Procedure Foo ( Bar: CString );

begin { Foo }
  writeln ( Bar );
end { Foo };

Function Bar: Pointer;

Var
  OK: CString = @'OK';

begin { Bar }
  Bar:= OK;
end { Bar };

begin
  Foo ( Bar );
end.
