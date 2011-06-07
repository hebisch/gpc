{ Why should this work? Being able to refer to any variable
  declared anywhere with a simple `external' (without `name'
  etc.) is not compatible with being able to use the same
  identifier in different modules. I think we want the latter.

  20020926: I've added the `name' now (both in the module and
  here), with which this test works. I think that's all that can be
  expected.

  Frank }

Program Sam5;

Var
  s: String ( 2 ); external name 'foo';

{$L sam5m.pas}

begin
  writeln ( s );
end.
