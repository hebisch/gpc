{ Fails on sparc-sun-solaris2 with gcc-2.95.x (GCC bug) }

program fjf558p;

procedure foo;

label 1;

procedure outer;
label 1;
   procedure inner;
   begin {inner}
      Write ('O');
      goto 1
   end; {inner}

begin {outer}
  inner;
1:
  Write ('K');
end; {outer}

begin {test}
  outer;
1:
  WriteLn
{$local W-}end;{$endlocal} {test}

begin
  foo
end.
