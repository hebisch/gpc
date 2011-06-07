Module mKevin13FOO interface;

Export
  Kevin13F = (twine);
type
  String25 = String(25);
function twine( foobar: CString ): String25;

end. {interface}

Module mKevin13FOO implementation;

function twine( foobar: CString ): String25;
begin
  twine := CString2String ( foobar )
end; {twine}
end.
