# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 07_BF2.t,v 1.5 2006/11/14 12:12:54 jettero Exp $

use strict;
use Test;

my $bf = 0;
eval {
    use Crypt::CBC;
    use Crypt::Blowfish;

    $bf = 1;
};

plan tests => 3 + $bf;

use Crypt::PBC;

# SETUP

my $curve = &Crypt::PBC::pairing_init_stream(\*DATA);
my $P     = $curve->new_G2->random; # generator in G1 -- even though it's in G2
my $s     = $curve->new_Zr->random; # master secret
my $P_pub = $curve->new_G2->pow_zn( $P, $s ); # master public key

# EXTRACT

my $Q_id = $curve->new_G1->random;
my $d_id = $curve->new_G1->pow_zn( $Q_id, $s );

# ENCRYPT

my $r    = $curve->new_Zr->random;
my $g_id = $curve->new_GT->e_hat( $curve => $Q_id, $P_pub );
my $U    = $curve->new_G2->pow_zn( $P, $r ); # U is the part d_id can use to derive w
my $w    = $curve->new_GT->pow_zn( $g_id, $r ); # w is the part you'd xor(w,M) to get V or xor(w,V) to get M

# DECRYPT
my $w_from_U = $curve->new_GT->e_hat( $curve => $d_id, $U );

ok( $w_from_U->is_eq( $w ) );
ok( $w_from_U->as_bytes, $w->as_bytes ); # binary gook
ok( $w_from_U->as_str,   $w->as_str   ); # hexidecimal

if( $bf ) {
    # If the three comparisons above worked, this is kindof a no-brainer; but,
    # personally, I was confused on how to M^H2(g^r) -- and here it is:

    my $cipher1 = new Crypt::CBC({header=>"randomiv", key=>$w->as_bytes,        cipher=>'Blowfish'});
    my $cipher2 = new Crypt::CBC({header=>"randomiv", key=>$w_from_U->as_bytes, cipher=>'Blowfish'});
    my $message = "Holy smokes, this is secret!!";
    my $encrypt = $cipher1->encrypt($message);
    my $decrypt = $cipher2->decrypt($encrypt);

    warn " using Blowfish for 4th test\n";
    ok( $decrypt, $message );
}

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
