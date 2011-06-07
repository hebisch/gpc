program fjf73;

procedure p;
var v: record a: Integer end;
begin
  asm ("" : "=r" (v.a))
end;

begin
  writeln ('OK')
end.

(*

Equivalent C code:

void p (void)
{
  struct foo { int a; } v;
  asm ("" : "=r" (v.a));
}

int main (void)
{
  puts ("OK");
}

*)
