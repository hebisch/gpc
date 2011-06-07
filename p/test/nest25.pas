{ FLAG --nested-comments -Wnested-comments }

Program Nest25;

{$W-} { This is a { nested } comment. } {$W+}
begin
{$W-} (* So is (* this *) one. *) {$W+}
  writeln ( 'OK' );
end.
