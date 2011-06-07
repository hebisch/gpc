program dave3i (output);

  type
    set_options = packed set of 1 .. 10;

  const
    imn = set_options [1, 3 .. 4];

  var
    lt : Boolean value True;

begin
  case lt of
    3 in imn: WriteLn ('OK');
    otherwise WriteLn ('failed')
  end
end.
