{$W no-absolute}

program foo;
label 1;
procedure bar;
begin
  goto 1
end;

begin

{ `begin'/`end' inserted as we don't allow `goto' across a variable declaration anymore.
  -- Frank, 20050312 }
begin var x : integer absolute 0; end;

1:
WriteLn ('OK')
end
.
