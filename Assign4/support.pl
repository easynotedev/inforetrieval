=pod
my $word = "non-algebraic-we";
$word =~ s/-/ /g;
print $word;

print log exp 1;

#!/usr/bin/perl
use strict;
use warnings;
 
use Data::Dumper qw(Dumper);
 
my %grades;
$grades{"Foo Bar"}{Mathematics}   = 97;
$grades{"Foo Bar"}{Literature}    = 67;
$grades{"Peti Bar"}{Literature}   = 88;
$grades{"Peti Bar"}{Mathematics}  = 82;
$grades{"Peti Bar"}{Art}          = 99;
 
print Dumper \%grades;
print "----------------\n";
 
foreach my $name (sort keys %grades) {
    foreach my $subject (keys %{ $grades{$name} }) {
        print "$name, $subject: $grades{$name}{$subject}\n";
    }
}


$grades{"Foo Bar"}{Art}{drawing}   = 34;
$grades{"Foo Bar"}{Art}{theory}    = 47;
$grades{"Foo Bar"}{Art}{sculpture}  = 68;
print Dumper \%grades;
print "----------------\n";

$grades{"Foo Bar"}{Programming}[0]  = 90;
$grades{"Foo Bar"}{Programming}[1]  = 91;
$grades{"Foo Bar"}{Programming}[2]  = 92;
print Dumper \%grades;
print "----------------\n";

=cut

use Data::Dumper qw(Dumper);
 
my $str = 'MATH2330';
my $stchar = substr($str,0,4);
my $stvchar  =substr($str,4,7);

my $gting = $stchar." ".$stvchar;
print Dumper $gting;
