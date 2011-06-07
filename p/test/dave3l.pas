program dave3l (output);

  type
    integer_options = (max_untyp, mxstarts, nfuncmax);
    array_options = array [1..2] of packed array [integer_options] of 1 .. 7;

  const
    imn = array_options [1 :[max_untyp : 1; mxstarts : 3; nfuncmax : 4];
                         2 :[ otherwise 5]];

  var
    lt : Integer value 3;

begin
  case lt of
    imn[1][mxstarts] : WriteLn ('OK');
    otherwise          WriteLn ('failed')
  end
end.
