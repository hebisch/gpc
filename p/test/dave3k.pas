program dave3k (output);

  type
    array_options = array [1..3] of 1 .. 7;

  const
    imn = array_options [1 : 1; 2 : 3; 3 : 4];
    mxstarts = 2;

  var
    lt : Integer value 3;

begin
  case lt of
    imn[mxstarts] : WriteLn ('OK');
    otherwise       WriteLn ('failed')
  end
end.
