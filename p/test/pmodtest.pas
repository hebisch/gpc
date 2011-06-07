module ModTest1  {$if False} interface {$endif};

export
  PModTest = (i);

var
  i: integer;
end;
end.

{$if False}

module ModTest1 implementation;

{ BUG: Do Modules containing only variables need Implementation?
  They do if they're `interface' modules, otherwise they don't,
  according to EP. That's the `$if False' part now.
  Frank, 20030419 }

{ BUG: The GPI file should tell the linker about the .o file.
  It does, Frank }

end.
{$endif}
