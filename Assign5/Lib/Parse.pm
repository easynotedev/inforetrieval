package Lib::Parse;
require 5.006;

use strict;
no warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(parse);
our @EXPORT = qw(parse);

#destroys casings
sub parse
{
    #my @month ("January","February","March","April","May","June","July","August","September","October","November","December");
    my %ANSHASH;
    my $string = shift;
	#e.g. February 4, 2004
	#(January|February|March|April|May|June|July|August|September|October|November|December)
	my @matches = ($string =~ m/((?:January|February)\s\d,\s\d{4})/ig);

    print @matches;
    $ANSHASH{$1} = scalar @matches;
    
    return %ANSHASH;

}

log exp 1;
__END__

=head1 TITLE
Name          : parse.pl
Author        : Antonin Karlo M. Tilaon
Version       : 1
=cut

=pod

=head2 DESCRIPTION
   
      

=pod