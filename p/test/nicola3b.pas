{ FLAG --nested-comments -Wnested-comments }

{$if 1}
{$endif}

program nicola3b;

{$ifndef x}
{$endif}

begin
  WriteLn ('OK')
end.
