Program OPath;

{$L pipesc.c}  { Automatically found in                            }
               { <prefix>/lib/gcc-lib/<platform>/<version>/units/. }

procedure Foo; external name '_p_CPipe';

begin
  if ParamStr (1) = 'blah' then Foo;
  WriteLn ('OK')
end.
