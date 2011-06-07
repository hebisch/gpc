program dave3m (output);

  type
    integer_options = (max_untyp, mxstarts, nfuncmax);
    array_options = record a : packed array [integer_options] of 1 .. 7 end;

  const
    imn = array_options [a: [max_untyp : 1; mxstarts : 3; nfuncmax : 4]];

  var
    lt : Integer value 3;

begin
  case lt of
    imn.a[mxstarts] : WriteLn ('OK');
    otherwise         WriteLn ('failed')
  end
end.
