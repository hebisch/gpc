program dave3c (output);

  type
    integer_options = (max_untyp, mxstarts, nfuncmax);
    array_options = array [integer_options] of char;

  const
    imn = array_options [max_untyp : 'q' otherwise 'r'];

  var
    lt : char value 'r';

begin
  case lt of
    imn[mxstarts] : WriteLn ('OK');
    otherwise       WriteLn ('failed')
  end
end.
