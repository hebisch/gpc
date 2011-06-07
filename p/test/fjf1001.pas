{ Automatic string -> CString conversion, followed by explicit CString -> string
  conversion. Unfortunately, they do not cancel out since CStrings are
  terminated by #0. I'm completely sure we should guarantee this, but otherwise
  it would seem strange, compared to explicit assignment to a CString variable
  followed by CString2String ... -- Frank }

program fjf1001;

var
  s: String (10) = 'OK'#0'XXX';

begin
  WriteLn (CString2String (s))
end.
