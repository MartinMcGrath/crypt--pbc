# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 05_boneh_franklin.t,v 1.12 2006/11/14 12:12:54 jettero Exp $

use strict;
use Test;

if( defined $ENV{SKIP_ALL_BUT} ) { unless( $0 =~ m/\Q$ENV{SKIP_ALL_BUT}\E/ ) { plan tests => 1; ok(1); exit 0; } }

plan tests => 1 + 3 + 2 + 1 + 2 + 1;

use Crypt::PBC;

# The data from params.txt was read in from param/d105171-196-185.param, which
# comes with the pbc package which can be generated by the package itself.  The
# rest of this test is from testibe.c in the PBC distribution.

open IN, "params.txt" or die "couldn't open params.txt: $!";

my $pairing = &Crypt::PBC::pairing_init_stream(\*IN); ok( $pairing ); close IN;
my $g       = $pairing->new_G1; ok( $g ); # P in BF
my $zg      = $pairing->new_G1; ok( $zg ); # sP in BF
my $rg      = $pairing->new_G1; ok( $rg ); # H2(g^r) ... in BF, though H1(g^r) here...
my $h       = $pairing->new_G2; ok( $h ); # Q_id = H1(ID) in BF ... Q_id = H2(ID) here
my $zh      = $pairing->new_G2; ok( $zh ); # d_id in BF
my $s       = $pairing->new_GT; ok( $s ); # V and M and h2(g_id^r) and stuff
my $master  = $pairing->new_Zr; ok( $master ); # s in BF
my $r       = $pairing->new_Zr; ok( $r ); # r in BF

$master->random; # generate master secret (s)
$g->random; # g is a publically known value (P)
$zg->pow_zn( $g, $master ); # sP is the master-public key P_pub

$s->random; # just for the debug messages below
$h->random; # just for the debug messages below

# pick random h, which represents what an ID might hash to
# for toy examples, should check that pairing(g, h) != 1
$h->random; # this is the Qi = H1( IDi(params) )
$zh->pow_zn( $h, $master ); # and this is the private key 

## encryption
## first pick random r
$r->random;
$s->pairing_apply( $pairing => $zg, $h ); # s = e_hat(P_pub, Q_id) -- GT=e_hat(G1, G2)
$s->pow_zn( $s, $r );  # s = e_hat(P_pub, Q_id)^r, used to encrypt the message
$rg->pow_zn( $g, $r ); # we transmit g^r along with the encryption

## decyrption
## should equal s
my $other_s = $pairing->new_GT->pairing_apply( $pairing => $rg, $zh ); # s = e_hat(g^r, d_id) -- GT=e_hat(G1, G2)

ok( $s->is_eq( $other_s ) );
