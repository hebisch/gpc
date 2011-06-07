program fjf440;

{$define TEST_WEAK_KEYWORD(DIR)
TEST_WEAK_KEYWORD1(DIR)
TEST_WEAK_KEYWORD2(DIR)
}

{$define TEST_WEAK_KEYWORD1(DIR)
procedure DIR##0;
type
  DIR = Integer;
  t = record a: DIR end;
begin
end;

procedure DIR##1;
const DIR = 42;
begin
end;
}

{$define TEST_WEAK_KEYWORD2(DIR)
procedure DIR##2;
const DIR: Integer = 42;
begin
end;

procedure DIR##3;
var DIR: Integer;
begin
end;

procedure DIR##4;
label DIR;
begin
  DIR: goto DIR
end;

procedure DIR##5;
type t = record DIR: Integer end;
begin
end;

procedure DIR##6;

  procedure DIR;
  begin
  end;

begin
end;

procedure DIR##7;
type DIR (n: Integer) = Integer;
begin
end;
}

TEST_WEAK_KEYWORD (absolute)
TEST_WEAK_KEYWORD (abstract)
TEST_WEAK_KEYWORD (all)
TEST_WEAK_KEYWORD (and_then)
TEST_WEAK_KEYWORD (as)
TEST_WEAK_KEYWORD (asm)
TEST_WEAK_KEYWORD (asmname)
TEST_WEAK_KEYWORD (attribute)
TEST_WEAK_KEYWORD (bindable)
TEST_WEAK_KEYWORD (c)
TEST_WEAK_KEYWORD (c_language)
TEST_WEAK_KEYWORD (class)
TEST_WEAK_KEYWORD (constructor)
TEST_WEAK_KEYWORD (destructor)
TEST_WEAK_KEYWORD (except)
TEST_WEAK_KEYWORD (export)
TEST_WEAK_KEYWORD (exports)
TEST_WEAK_KEYWORD (external)
TEST_WEAK_KEYWORD (far)
TEST_WEAK_KEYWORD (finalization)
TEST_WEAK_KEYWORD (finally)
TEST_WEAK_KEYWORD (forward)
TEST_WEAK_KEYWORD (implementation)
TEST_WEAK_KEYWORD (import)
TEST_WEAK_KEYWORD (inherited)
TEST_WEAK_KEYWORD (initialization)
TEST_WEAK_KEYWORD (inline)
TEST_WEAK_KEYWORD (interface)
TEST_WEAK_KEYWORD (interrupt)
TEST_WEAK_KEYWORD (is)
TEST_WEAK_KEYWORD (library)
TEST_WEAK_KEYWORD (module)
TEST_WEAK_KEYWORD (name)
TEST_WEAK_KEYWORD (near)
TEST_WEAK_KEYWORD (object)
TEST_WEAK_KEYWORD (on)
TEST_WEAK_KEYWORD (only)
TEST_WEAK_KEYWORD (or_else)
TEST_WEAK_KEYWORD (otherwise)
TEST_WEAK_KEYWORD (overload)
TEST_WEAK_KEYWORD (override)
TEST_WEAK_KEYWORD (pow)
TEST_WEAK_KEYWORD (private)
TEST_WEAK_KEYWORD (property)
TEST_WEAK_KEYWORD (protected)
TEST_WEAK_KEYWORD (public)
TEST_WEAK_KEYWORD (published)
TEST_WEAK_KEYWORD (qualified)
TEST_WEAK_KEYWORD (raise)
TEST_WEAK_KEYWORD (register)
TEST_WEAK_KEYWORD (reintroduce)
TEST_WEAK_KEYWORD (resident)
TEST_WEAK_KEYWORD (restricted)
TEST_WEAK_KEYWORD (segment)
TEST_WEAK_KEYWORD (shl)
TEST_WEAK_KEYWORD (shr)
TEST_WEAK_KEYWORD (static)
TEST_WEAK_KEYWORD (try)
TEST_WEAK_KEYWORD (unit)
TEST_WEAK_KEYWORD (uses)
TEST_WEAK_KEYWORD (value)
TEST_WEAK_KEYWORD (view)
TEST_WEAK_KEYWORD (virtual)
TEST_WEAK_KEYWORD (volatile)
TEST_WEAK_KEYWORD (xor)

{ no weak keywords, but must still work, of course }
TEST_WEAK_KEYWORD (Foo)
TEST_WEAK_KEYWORD (fjf440)

{ unfortunate restrictrion }
TEST_WEAK_KEYWORD2 (operator)
{$disable-keyword operator}
TEST_WEAK_KEYWORD1 (operator)

begin
  WriteLn ('OK')
end.
