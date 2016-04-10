
use strict;
use warnings;
use Data::Dumper qw(Dumper);

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

my $infhash_keys = qr/${\ join('|', map quotemeta, keys %INFILEHASH) }/;

 
my $str = 'MATH2330';
my $stchar = substr($str,0,4);
my $stvchar  =substr($str,4,7);

my $gting = $stchar." ".$stvchar;
print Dumper $gting;

foreach my $inptfl (sort { $PGERNKSCRE{$IT}{$a} <=> $PGERNKSCRE{$IT}{$b} } keys %PGERNKSCRE)
{
    print $outfile "\n";
    print $outfile $inptfl;
    print $outfile "\t";
    print $outfile $PGERNKSCRE{$IT}{$inptfl};
}
=cut

my %exampleHashTwo = ();

$exampleHashTwo{1}{"One"}{value} = 10;
$exampleHashTwo{2}{"Two"}{value} = 20;
$exampleHashTwo{2}{"TwoB"}{value} = 5;
$exampleHashTwo{3}{"Three"}{value} = 0;
$exampleHashTwo{4}{"Two"}{value} = 15;
$exampleHashTwo{1}{"One"}{nvalue} = 10;
$exampleHashTwo{2}{"Two"}{nvalue} = 20;
$exampleHashTwo{2}{"TwoB"}{nvalue} = 5;
$exampleHashTwo{3}{"Three"}{nvalue} = 0;
$exampleHashTwo{4}{"Two"}{nvalue} = 15;

for my $keypair (
        sort { $exampleHashTwo{$b->[0]}{$b->[1]}{value} <=> $exampleHashTwo{$a->[0]}{$a->[1]}{value} }
        map { my $intKey=$_; map [$intKey, $_], keys %{$exampleHashTwo{$intKey}} } keys %exampleHashTwo
    ) {
    printf( "{%d} - {%5s} => %d\n", $keypair->[0], $keypair->[1], $exampleHashTwo{$keypair->[0]}{$keypair->[1]}{value} );
}

print "\n";

my %PGERNKSCRE = ();
my $IT = 0;

$PGERNKSCRE{44}{"COSC 117"} = 1/142;
$PGERNKSCRE{44}{"COSC 118"} = 1/142;
$PGERNKSCRE{44}{"MATH 334"} = 5;
$PGERNKSCRE{44}{"MATH 430"} = 0;
$PGERNKSCRE{44}{"MATH 249"} = 15;
$PGERNKSCRE{$IT}{"COSC 1137"} = 1/142;
$PGERNKSCRE{$IT}{"COSC 1138"} = 1/142;
$PGERNKSCRE{$IT}{"MATH 3314"} = 10;
$PGERNKSCRE{$IT}{"MATH 4350"} = 0;
$PGERNKSCRE{$IT}{"MATH 2419"} = 9;

=pod
foreach my $inptfl (
        sort { $PGERNKSCRE{$IT}{$b->[1]} <=> $PGERNKSCRE{$IT}{$a->[1]} }
        map { my $iterateKey=$_;
        map [$iterateKey, $_], keys %{$PGERNKSCRE{$iterateKey}} } 
        keys %PGERNKSCRE
                   ) 
{
    printf "\n%9s\t %10.8f", $inptfl->[1], $PGERNKSCRE{$IT}{$inptfl->[1]};
}


for my $it ( sort { keys %{$PGERNKSCRE{$a}} <=> keys %{$PGERNKSCRE{$b}} } keys %PGERNKSCRE)
{
	print "\n";
	print $it;
	#USED SMARTMATCH to make a KEY correspond into a VALUE
    # my (@doc) = grep {$score == $TFIDFSCORES{$_}} keys %TFIDFSCORES;
    for my $val ( sort values %{ $PGERNKSCRE{$it} } ) 
    {
         print "\t";
         print $val;
    }
	
} 
=cut

my @positioned = reverse sort { $PGERNKSCRE{$IT}->{$a} <=> $PGERNKSCRE{$IT}->{$b} }  keys %{$PGERNKSCRE{$IT}} ;
 
foreach my $k (@positioned) {
     print "\n";
     print $k;
     print "\t";
      print $PGERNKSCRE{$IT}{$k};
     
}

=cut
 for my $doc (sort keys %{ $PGERNKSCRE{$IT} } ) 
    {
         #my ($doc) = grep {$val == $PGERNKSCRE{$IT}{$_}} keys %{ $PGERNKSCRE{$IT} };
         print "\n";
         print $doc;
         print "\t";
        # print $val;
    }
=pod