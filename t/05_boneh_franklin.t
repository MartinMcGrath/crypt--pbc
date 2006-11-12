# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 05_boneh_franklin.t,v 1.9 2006/11/12 20:13:32 jettero Exp $

use strict;
use Test;

plan tests => 1 + 3 + 2 + 1 + 2 + 1;

use Crypt::PBC;

# The data from DATA was read in from param/d105171-196-185.param, which comes
# with the pbc package which can be generated by the package itself.  The rest
# of this test is from testibe.c in the PBC distribution.

my $pairing = &Crypt::PBC::pairing_init_stream(\*DATA); ok( $pairing );
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

&Crypt::PBC::element_print( "\n[G1] g=\%B\n", $g );
&Crypt::PBC::element_print( "\n[G2] h=\%B\n", $h );
&Crypt::PBC::element_print( "\n[GT] s=\%B\n", $s );
&Crypt::PBC::element_print( "\n[Zr] master=\%B\n\n", $master );

print "[G1]      g->as_str: ",      $g->as_str, "\n";
print "[G2]      h->as_str: ",      $h->as_str, "\n";
print "[GT]      s->as_str: ",      $s->as_str, "\n";
print "[Zr] master->as_str: ", $master->as_str, "\n";

# pick random h, which represents what an ID might hash to
# for toy examples, should check that pairing(g, h) != 1
$h->random; # this is the Qi = H1( IDi(params) )
$zh->pow_zn( $h, $master ); # and this is the private key 

## encryption
## first pick random r
$r->random;
$s->pairing_apply( $pairing => $zg, $h ); # s = e_hat(P_pub, Q_id)
$s->pow_zn( $s, $r );  # s = e_hat(P_pub, Q_id)^r, used to encrypt the message
$rg->pow_zn( $g, $r ); # we transmit g^r along with the encryption
my $s1 = $s->as_str;

## decyrption
## should equal s
$s->pairing_apply( $pairing => $rg, $zh ); # s = e_hat(g^r, d_id)
my $s2 = $s->as_str;

ok( $s1, $s2 );

__DATA__
type d
q 90144054120102937439179516551801119443207521965651508326977
n 90144054120102937439179516552101359437412329625948146453801
h 3523
r 25587298927080027658012919827448583433838299638361665187
a 53241464724463691897001131065853762954208272388634868483573
b 5446291776274815451607581859968802155069674270539409546723
k 6
nk 536565217356706344663314419655601558604376922027564701618757289270614360593294739461568130362279778081437146273088457636627768012396592169059882662689261645948113285006858612654825829457395553891546397990662355454563776046265747800873542312230073566643975827908869710713161941935371830987701273239900997531501272405727670675418703842862606824000125008640
hk 819546557806423450339849940898193664969813698879192227897917671302330185914203886301113045602626676261586588840857293388779160133822229389038218318388504449595493650939257095992443062327856033482709266319687677297858891026083277228064475554560
coeff0 43907136006531280293838495445857758305366399383908394927288
coeff1 21720089592072695009765372832780685887129370300993349347738
coeff2 11773373318911376280677890769414834592007872486079550520860
nqr 4468071665857441743453009416233415235254714637554162977327
