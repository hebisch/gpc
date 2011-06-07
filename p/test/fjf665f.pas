{ FLAG --no-assertions }

{$assertions}

program fjf665f;

begin
  Assert (ParamCount >= 0);
  WriteLn ('OK')
end.
