program dave3d (output);

  type
    integer_options = (max_untyp, mxstarts, nfuncmax);
    array_options = array [integer_options] of 1 .. 4;

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
