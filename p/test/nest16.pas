{ FLAG --nested-comments }

Program Nest16;

{$define FOO({x{y}z}A{x{y}z}) Write { This is a { nested \
  multiline } comment in a Pascal directive } ({q{w}e}A{a{s}d})
  }
{$undef BAR { This is a { nested \
  multiline } comment in a Pascal directive }     }

begin
{$ifdef FOO { This is a { nested \
  multiline } comment in a Pascal ifdef }  }
  FOO({1{2}3}'O'{4{5}6});
{$else { This is a { nested \
  multiline } comment in a Pascal else }}
  WriteLn ('failed');
{$endif { This is a { nested \
  multiline } comment in a Pascal endif } }
{$ifdef BAR { This is a { nested \
  multiline } comment in a Pascal ifdef } }
  WriteLn ('failed');
{$else { This is a { nested \
  multiline } comment in a Pascal else } }
  WriteLn ('K')
{$endif { This is a { nested \
  multiline } comment in a Pascal endif }}
end.
