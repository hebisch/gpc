program dave3j (output);

  type
    integer_options = (max_untyp, mxstarts, nfuncmax);
    array_options = packed array [integer_options] of 0 .. 7;

  const
    imn = array_options [max_untyp : 1; mxstarts : 3; nfuncmax : 4];

  var
    lt : Integer value 3;

begin
  case lt of
    imn[mxstarts] : WriteLn ('OK');
    otherwise       WriteLn ('failed')
  end
end.
