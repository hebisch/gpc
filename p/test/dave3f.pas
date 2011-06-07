program dave3f (output);

  type
    record_options = record
      a, b, c: Integer
    end;

  const
    imn = record_options [a : 1; b : 3; c : 4];

  var
    lt : Integer value 3;

begin
  case lt of
    imn.b   : WriteLn ('OK');
    otherwise WriteLn ('failed')
  end
end.
