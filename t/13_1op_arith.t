# vi:fdm=marker fdl=0 syntax=perl:

use strict;
use Test;

if( defined $ENV{SKIP_ALL_BUT} ) { unless( $0 =~ m/\Q$ENV{SKIP_ALL_BUT}\E/ ) { plan tests => 1; ok(1); exit 0; } }

use Crypt::PBC;

open IN, "params.txt" or die "couldn't open params: $!";
my $curve = &Crypt::PBC::pairing_init_stream(\*IN); close IN;

my @lhs = ( $curve->new_G1, $curve->new_G2, $curve->new_GT, $curve->new_Zr );
my @rhs = ( $curve->new_G1, $curve->new_G2, $curve->new_GT, $curve->new_Zr );

my $epochs = 3;

plan tests => ( ((int @lhs) * 5 * $epochs) );

for my $i ( 1 .. $epochs ) {
    for my $i ( 0 .. $#lhs ) {

        $rhs[$i]->random;

        $lhs[$i]->set( $rhs[$i] )->square;           my $sc = $lhs[$i]->clone( $curve );
        $lhs[$i]->set( $rhs[$i] )->double;           my $dc = $lhs[$i]->clone( $curve );
        $lhs[$i]->set( $rhs[$i] )->halve;            my $hc = $lhs[$i]->clone( $curve );
        $lhs[$i]->set( $rhs[$i] ); $lhs[$i]->neg;    my $nc = $lhs[$i]->clone( $curve );
        $lhs[$i]->set( $rhs[$i] ); $lhs[$i]->invert; my $ic = $lhs[$i]->clone( $curve );

        $lhs[$i]->square( $rhs[$i] ); ok( $lhs[$i]->is_eq( $sc ) );
        $lhs[$i]->double( $rhs[$i] ); ok( $lhs[$i]->is_eq( $dc ) );
        $lhs[$i]->halve(  $rhs[$i] ); ok( $lhs[$i]->is_eq( $hc ) );
        $lhs[$i]->neg(    $rhs[$i] ); ok( $lhs[$i]->is_eq( $nc ) );
        $lhs[$i]->invert( $rhs[$i] ); ok( $lhs[$i]->is_eq( $ic ) );
    }
}