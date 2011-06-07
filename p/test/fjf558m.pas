program fjf558m;

label 2;

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
2:
  WriteLn
{$W-}end. {test}
