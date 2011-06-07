{ This test reproduced an error connected with `--c-numbers'.
  `--c-numbers' was dropped meanwhile, so the test is quite
  pointless ... }

{ FLAG -Werror }

program fjf360;
begin
  if 0.6 = {.$C+} 0.6 then writeln ('OK') else writeln ('failed')
end.
