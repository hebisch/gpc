{ Changed from an interface-only module to a "simple" module.

  The former never really worked, anyway. It would compile, but
  calling `BugDemo' in berend1a.pas would cause a runtime error
  because the file is never initialized.

  AFAICS, it's not easy to support both separate interface and
  implementation modules and interface-only modules, in particular
  concerning initializers (like here). With some changes in the
  compiler and support from the make system it might be possible
  (let the compiler create an initializer for the interface
  variables when compiling the interface, and another one (the
  regular one) for all variables (or only for the implementation
  variables and calling the former one) when compiling an
  implementation; then let the make system deteremine whether there
  is an implementation "somewhere" and if not tell the compiler to
  create a wrapper that maps the interface-initializer to the
  regular initializer).

  All in all, that's quite tricky. It's easier to just let the user
  specify that there is no implementation -- e.g., by writing a
  simple module, as is done here now.

  Frank, 20030330 }

module ber1n { interface -- removed, Frank };

export
  ber1n = (myfile);

var
  myfile :  bindable text;

end;  { inserted, Frank }

end.
