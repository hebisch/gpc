{ FLAG --autobuild -Wno-uninitialized -O0 }

{ COMPILE-CMD: gmplink.cmp }

{ This program tests if the external declarations in the GMP unit
  are correct, i.e., if all routines can be linked. They're not
  actually called from here. Some tests which actually call the
  routines are in GMPTest. }

program GMPLink;

uses GPC, GMP;

begin
  WriteLn ('OK');
  Halt;

(*
The rest of this file (up to the final `end.') was generated
manually with the following command (where sed is GNU sed):
sed -ne '1,/^\(procedure\|function\)/d;/implementation/,$d;
s/{$ifdef HAVE_GMP4}[^{]*{$endif} *//g;
/\({\|(\*\)\$/{p;n;}
/^\(procedure\|function\)/{
:l0;s/ *external name.*//;/^\([^()]\|([^)]*[)]\)*[:;]/!{N;b l0;};
s,\n[[:space:]]*, ,g;s/[[:space:]]\+/ /g;
s/\<\(protected\|var\)\> *//g;s/; *\.\.\.//;h;
s/ *:[^,;)]*//g;s/; *$//;s/;/,/g;s/$/ end;/;
s/^procedure *//;s/^function/Result :=/;x;
s/(/(var /;/(/!s/:/():/;s/.*(//;s/; *\(.\)/; var \1/g;
s/) *:/; var Result:/;s/)//;s/^/begin /;G;s/\n/ /;p;}' < ../units/gmp.pas
*)

begin ; var Result: Integer; Result := mp_bits_per_limb end;
begin var Dest: mpz_t; mpz_init (Dest) end;
begin var Dest: mpz_t; mpz_clear (Dest) end;
begin var Dest: mpz_t; var NewAlloc: mp_size_t; var Result: Pointer; Result := mpz_realloc (Dest, NewAlloc) end;
begin var Dest: mpz_array_ptr; var ArraySize, FixedNumBits: mp_size_t; mpz_array_init (Dest, ArraySize, FixedNumBits) end;
begin var Dest: mpz_t; var Src: mpz_t; mpz_set (Dest, Src) end;
begin var Dest: mpz_t; var Src: MedCard; mpz_set_ui (Dest, Src) end;
begin var Dest: mpz_t; var Src: MedInt; mpz_set_si (Dest, Src) end;
begin var Dest: mpz_t; var Src: Real; mpz_set_d (Dest, Src) end;
begin var Dest: mpz_t; var Src: mpq_t; mpz_set_q (Dest, Src) end;
begin var Dest: mpz_t; var Src: mpf_t; mpz_set_f (Dest, Src) end;
begin var Dest: mpz_t; var Src: CString; var Base: Integer; var Result: Integer; Result := mpz_set_str (Dest, Src, Base) end;
begin var Dest: mpz_t; var Src: mpz_t; mpz_init_set (Dest, Src) end;
begin var Dest: mpz_t; var Src: MedCard; mpz_init_set_ui (Dest, Src) end;
begin var Dest: mpz_t; var Src: MedInt; mpz_init_set_si (Dest, Src) end;
begin var Dest: mpz_t; var Src: Real; mpz_init_set_d (Dest, Src) end;
begin var Dest: mpz_t; var Src: CString; var Base: Integer; var Result: Integer; Result := mpz_init_set_str (Dest, Src, Base) end;
begin var Src: mpz_t; var Result: MedCard; Result := mpz_get_ui (Src) end;
begin var Src: mpz_t; var Result: MedInt; Result := mpz_get_si (Src) end;
begin var Src: mpz_t; var Result: Real; Result := mpz_get_d (Src) end;
begin var Dest: CString; var Base: Integer; var Src: mpz_t; var Result: CString; Result := mpz_get_str (Dest, Base, Src) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_add (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_add_ui (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_sub (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_sub_ui (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_mul (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_mul_ui (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_mul_2exp (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src: mpz_t; mpz_neg (Dest, Src) end;
begin var Dest: mpz_t; var Src: mpz_t; mpz_abs (Dest, Src) end;
begin var Dest: mpz_t; var Src: MedCard; mpz_fac_ui (Dest, Src) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_tdiv_q (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_tdiv_q_ui (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_tdiv_r (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_tdiv_r_ui (Dest, Src1, Src2) end;
begin var DestQ, DestR: mpz_t; var Src1, Src2: mpz_t; mpz_tdiv_qr (DestQ, DestR, Src1, Src2) end;
begin var DestQ, DestR: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_tdiv_qr_ui (DestQ, DestR, Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_fdiv_q (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_fdiv_q_ui (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_fdiv_r (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_fdiv_r_ui (Dest, Src1, Src2) end;
begin var DestQ, DestR: mpz_t; var Src1, Src2: mpz_t; mpz_fdiv_qr (DestQ, DestR, Src1, Src2) end;
begin var DestQ, DestR: mpz_t; var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_fdiv_qr_ui (DestQ, DestR, Src1, Src2) end;
begin var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_fdiv_ui (Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_cdiv_q (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_cdiv_q_ui (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_cdiv_r (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_cdiv_r_ui (Dest, Src1, Src2) end;
begin var DestQ, DestR: mpz_t; var Src1,Src2: mpz_t; mpz_cdiv_qr (DestQ, DestR, Src1,Src2) end;
begin var DestQ, DestR: mpz_t; var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_cdiv_qr_ui (DestQ, DestR, Src1, Src2) end;
begin var Src1: mpz_t; var Src2:MedCard; var Result: MedCard; Result := mpz_cdiv_ui (Src1, Src2) end;
begin var Dest: mpz_t; var Src1,Src2: mpz_t; mpz_mod (Dest, Src1,Src2) end;
begin var Dest: mpz_t; var Src1,Src2: mpz_t; mpz_divexact (Dest, Src1,Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_tdiv_q_2exp (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_tdiv_r_2exp (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_fdiv_q_2exp (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_fdiv_r_2exp (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Base, Exponent, Modulus: mpz_t; mpz_powm (Dest, Base, Exponent, Modulus) end;
begin var Dest: mpz_t; var Base: mpz_t; var Exponent: MedCard; var Modulus: mpz_t; mpz_powm_ui (Dest, Base, Exponent, Modulus) end;
begin var Dest: mpz_t; var Base: mpz_t; var Exponent: MedCard; mpz_pow_ui (Dest, Base, Exponent) end;
begin var Dest: mpz_t; var Base, Exponent: MedCard; mpz_ui_pow_ui (Dest, Base, Exponent) end;
begin var Dest: mpz_t; var Src: mpz_t; mpz_sqrt (Dest, Src) end;
begin var Dest, DestR: mpz_t; var Src: mpz_t; mpz_sqrtrem (Dest, DestR, Src) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_perfect_square_p (Src) end;
begin var Src: mpz_t; var Repetitions: Integer; var Result: Integer; Result := mpz_probab_prime_p (Src, Repetitions) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_gcd (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_gcd_ui (Dest, Src1, Src2) end;
begin var Dest, DestA, DestB: mpz_t; var SrcA, SrcB: mpz_t; mpz_gcdext (Dest, DestA, DestB, SrcA, SrcB) end;
begin var Dest: mpz_t; var Src, Modulus: mpz_t; var Result: Integer; Result := mpz_invert (Dest, Src, Modulus) end;
begin var Src1, Src2: mpz_t; var Result: Integer; Result := mpz_jacobi (Src1, Src2) end;
begin var Src1, Src2: mpz_t; var Result: Integer; Result := mpz_cmp (Src1, Src2) end;
begin var Src1: mpz_t; var Src2: MedCard; var Result: Integer; Result := mpz_cmp_ui (Src1, Src2) end;
begin var Src1: mpz_t; var Src2: MedInt; var Result: Integer; Result := mpz_cmp_si (Src1, Src2) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_sgn (Src) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_and (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_ior (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src: mpz_t; mpz_com (Dest, Src) end;
begin var Src: mpz_t; var Result: MedCard; Result := mpz_popcount (Src) end;
begin var Src1, Src2: mpz_t; var Result: MedCard; Result := mpz_hamdist (Src1, Src2) end;
begin var Src: mpz_t; var StartingBit: MedCard; var Result: MedCard; Result := mpz_scan0 (Src, StartingBit) end;
begin var Src: mpz_t; var StartingBit: MedCard; var Result: MedCard; Result := mpz_scan1 (Src, StartingBit) end;
begin var Dest: mpz_t; var BitIndex: MedCard; mpz_setbit (Dest, BitIndex) end;
begin var Dest: mpz_t; var BitIndex: MedCard; mpz_clrbit (Dest, BitIndex) end;
begin var Dest: mpz_t; var MaxSize: mp_size_t; mpz_random (Dest, MaxSize) end;
begin var Dest: mpz_t; var MaxSize: mp_size_t; mpz_random2 (Dest, MaxSize) end;
begin var Src: mpz_t; var Base: Integer; var Result: SizeType; Result := mpz_sizeinbase (Src, Base) end;
begin var Dest: mpq_t; mpq_canonicalize (Dest) end;
begin var Dest: mpq_t; mpq_init (Dest) end;
begin var Dest: mpq_t; mpq_clear (Dest) end;
begin var Dest: mpq_t; var Src: mpq_t; mpq_set (Dest, Src) end;
begin var Dest: mpq_t; var Src: mpz_t; mpq_set_z (Dest, Src) end;
begin var Dest: mpq_t; var Nom, Den: MedCard; mpq_set_ui (Dest, Nom, Den) end;
begin var Dest: mpq_t; var Nom: MedInt; var Den: MedCard; mpq_set_si (Dest, Nom, Den) end;
begin var Dest: mpq_t; var Src1, Src2: mpq_t; mpq_add (Dest, Src1, Src2) end;
begin var Dest: mpq_t; var Src1, Src2: mpq_t; mpq_sub (Dest, Src1, Src2) end;
begin var Dest: mpq_t; var Src1, Src2: mpq_t; mpq_mul (Dest, Src1, Src2) end;
begin var Dest: mpq_t; var Src1, Src2: mpq_t; mpq_div (Dest, Src1, Src2) end;
begin var Dest: mpq_t; var Src: mpq_t; mpq_neg (Dest, Src) end;
begin var Dest: mpq_t; var Src: mpq_t; mpq_inv (Dest, Src) end;
begin var Src1, Src2: mpq_t; var Result: Integer; Result := mpq_cmp (Src1, Src2) end;
begin var Src1: mpq_t; var Nom2, Den2: MedCard; var Result: Integer; Result := mpq_cmp_ui (Src1, Nom2, Den2) end;
begin var Src: mpq_t; var Result: Integer; Result := mpq_sgn (Src) end;
begin var Src1, Src2: mpq_t; var Result: Integer; Result := mpq_equal (Src1, Src2) end;
begin var Src: mpq_t; var Result: Real; Result := mpq_get_d (Src) end;
begin var Dest: mpq_t; var Src: mpz_t; mpq_set_num (Dest, Src) end;
begin var Dest: mpq_t; var Src: mpz_t; mpq_set_den (Dest, Src) end;
begin var Dest: mpz_t; var Src: mpq_t; mpq_get_num (Dest, Src) end;
begin var Dest: mpz_t; var Src: mpq_t; mpq_get_den (Dest, Src) end;
begin var Precision: MedCard; mpf_set_default_prec (Precision) end;
begin var Dest: mpf_t; mpf_init (Dest) end;
begin var Dest: mpf_t; var Precision: MedCard; mpf_init2 (Dest, Precision) end;
begin var Dest: mpf_t; mpf_clear (Dest) end;
begin var Dest: mpf_t; var Precision: MedCard; mpf_set_prec (Dest, Precision) end;
begin var Src: mpf_t; var Result: MedCard; Result := mpf_get_prec (Src) end;
begin var Dest: mpf_t; var Precision: MedCard; mpf_set_prec_raw (Dest, Precision) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_set (Dest, Src) end;
begin var Dest: mpf_t; var Src: MedCard; mpf_set_ui (Dest, Src) end;
begin var Dest: mpf_t; var Src: MedInt; mpf_set_si (Dest, Src) end;
begin var Dest: mpf_t; var Src: Real; mpf_set_d (Dest, Src) end;
begin var Dest: mpf_t; var Src: mpz_t; mpf_set_z (Dest, Src) end;
begin var Dest: mpf_t; var Src: mpq_t; mpf_set_q (Dest, Src) end;
begin var Dest: mpf_t; var Src: CString; var Base: Integer; var Result: Integer; Result := mpf_set_str (Dest, Src, Base) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_init_set (Dest, Src) end;
begin var Dest: mpf_t; var Src: MedCard; mpf_init_set_ui (Dest, Src) end;
begin var Dest: mpf_t; var Src: MedInt; mpf_init_set_si (Dest, Src) end;
begin var Dest: mpf_t; var Src: Real; mpf_init_set_d (Dest, Src) end;
begin var Dest: mpf_t; var Src: CString; var Base: Integer; var Result: Integer; Result := mpf_init_set_str (Dest, Src, Base) end;
begin var Src: mpf_t; var Result: Real; Result := mpf_get_d (Src) end;
begin var Dest: CString; var Exponent: mp_exp_t; var Base: Integer; var NumberOfDigits: SizeType; var Src: mpf_t; var Result: CString; Result := mpf_get_str (Dest, Exponent, Base, NumberOfDigits, Src) end;
begin var Dest: mpf_t; var Src1, Src2: mpf_t; mpf_add (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1: mpf_t; var Src2: MedCard; mpf_add_ui (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1, Src2: mpf_t; mpf_sub (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1: MedCard; var Src2: mpf_t; mpf_ui_sub (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1: mpf_t; var Src2: MedCard; mpf_sub_ui (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1, Src2: mpf_t; mpf_mul (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1: mpf_t; var Src2: MedCard; mpf_mul_ui (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1, Src2: mpf_t; mpf_div (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1: MedCard; var Src2: mpf_t; mpf_ui_div (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1: mpf_t; var Src2: MedCard; mpf_div_ui (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_sqrt (Dest, Src) end;
begin var Dest: mpf_t; var Src: MedCard; mpf_sqrt_ui (Dest, Src) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_neg (Dest, Src) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_abs (Dest, Src) end;
begin var Dest: mpf_t; var Src1: mpf_t; var Src2: MedCard; mpf_mul_2exp (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src1: mpf_t; var Src2: MedCard; mpf_div_2exp (Dest, Src1, Src2) end;
begin var Src1, Src2: mpf_t; var Result: Integer; Result := mpf_cmp (Src1, Src2) end;
begin var Src1: mpf_t; var Src2: MedInt; var Result: Integer; Result := mpf_cmp_si (Src1, Src2) end;
begin var Src1: mpf_t; var Src2: MedCard; var Result: Integer; Result := mpf_cmp_ui (Src1, Src2) end;
begin var Src1, Src2: mpf_t; var NumberOfBits: MedCard; var Result: Integer; Result := mpf_eq (Src1, Src2, NumberOfBits) end;
begin var Dest: mpf_t; var Src1, Src2: mpf_t; mpf_reldiff (Dest, Src1, Src2) end;
begin var Src: mpf_t; var Result: Integer; Result := mpf_sgn (Src) end;
begin var Dest: mpf_t; var MaxSize: mp_size_t; var MaxExp: mp_exp_t; mpf_random2 (Dest, MaxSize, MaxExp) end;
{$if False}  { @@ commented out because they use C file pointers }
begin var Dest: mpz_t; var Src: CFilePtr; var Base: Integer; var Result: SizeType; Result := mpz_inp_str (Dest, Src, Base) end;
begin var Dest: mpz_t; var Src: CFilePtr; var Result: SizeType ; Result := mpz_inp_raw (Dest, Src) end;
begin var Dest: CFilePtr; var Base: Integer; var Src: mpz_t; var Result: SizeType; Result := mpz_out_str (Dest, Base, Src) end;
begin var Dest: CFilePtr; var Src: mpz_t; var Result: SizeType ; Result := mpz_out_raw (Dest, Src) end;
begin var Dest: CFilePtr; var Base: Integer; var NumberOfDigits: SizeType; var Src: mpf_t; var Result: SizeType; Result := mpf_out_str (Dest, Base, NumberOfDigits, Src) end;
begin var Dest: mpf_t; var Src: CFilePtr; var Base: Integer; var Result: SizeType; Result := mpf_inp_str (Dest, Src, Base) end;
{$endif}
begin var State: gmp_randstate_t; var Alg: gmp_randalg_t; gmp_randinit (State, Alg) end;
begin var State: gmp_randstate_t; var a: mpz_t; var c: MedCard; var m: mpz_t; gmp_randinit_lc (State, a, c, m) end;
begin var State: gmp_randstate_t; var a: mpz_t; var c: MedCard; var M2Exp: MedCard; gmp_randinit_lc_2exp (State, a, c, M2Exp) end;
begin var State: gmp_randstate_t; var Seed: mpz_t; gmp_randseed (State, Seed) end;
begin var State: gmp_randstate_t; var Seed: MedCard; gmp_randseed_ui (State, Seed) end;
begin var State: gmp_randstate_t; gmp_randclear (State) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_addmul_ui (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1: mpz_t; var Src2: MedCard; mpz_bin_ui (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src1, Src2: MedCard; mpz_bin_uiui (Dest, Src1, Src2) end;
begin var Src1, Src2: mpz_t; var Result: Integer; Result := mpz_cmpabs (Src1, Src2) end;
begin var Src1: mpz_t; var Src2: MedCard; var Result: Integer; Result := mpz_cmpabs_ui (Src1, Src2) end;
begin var Src: mpz_t; mpz_dump (Src) end;
begin var Dest: mpz_t; var Src: MedCard; mpz_fib_ui (Dest, Src) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_fits_sint_p (Src) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_fits_slong_p (Src) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_fits_sshort_p (Src) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_fits_uint_p (Src) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_fits_ulong_p (Src) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_fits_ushort_p (Src) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_lcm (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src: mpz_t; mpz_nextprime (Dest, Src) end;
begin var Src: mpz_t; var Result: Integer; Result := mpz_perfect_power_p (Src) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; var Result: MedCard; Result := mpz_remove (Dest, Src1, Src2) end;
begin var Dest: mpz_t; var Src: mpz_t; var n: MedCard; var Result: Integer; Result := mpz_root (Dest, Src, n) end;
begin var ROP: mpz_t; var State: gmp_randstate_t; var n: MedCard; mpz_rrandomb (ROP, State, n) end;
begin var v1, v2: mpz_t; mpz_swap (v1, v2) end;
begin var Src1: mpz_t; var Src2: MedCard; var Result: MedCard; Result := mpz_tdiv_ui (Src1, Src2) end;
begin var Src1: mpz_t; var Src2: MedCard; var Result: Integer; Result := mpz_tstbit (Src1, Src2) end;
begin var ROP: mpz_t; var State: gmp_randstate_t; var n: MedCard; mpz_urandomb (ROP, State, n) end;
begin var ROP: mpz_t; var State: gmp_randstate_t; var n: mpz_t; mpz_urandomm (ROP, State, n) end;
begin var Dest: mpz_t; var Src1, Src2: mpz_t; mpz_xor (Dest, Src1, Src2) end;
begin var Dest: mpq_t; var Src: Real; mpq_set_d (Dest, Src) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_ceil (Dest, Src) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_floor (Dest, Src) end;
begin var Dest: mpf_t; var Src1: mpf_t; var Src2: MedCard; mpf_pow_ui (Dest, Src1, Src2) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_trunc (Dest, Src) end;
begin var ROP: mpf_t; var State: gmp_randstate_t; var n: MedCard; mpf_urandomb (ROP, State, n) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_exp (Dest, Src) end;
begin var Dest: mpf_t; var Src: mpf_t; mpf_ln (Dest, Src) end;
begin var Dest: mpf_t; var Src1, Src2: mpf_t; mpf_pow (Dest, Src1, Src2) end;
begin var c: mpf_t; var x: mpf_t; mpf_arctan (c, x) end;
begin var c: mpf_t; mpf_pi (c) end;

end.
