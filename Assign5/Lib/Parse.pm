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
    my %ANSHASH;
    my $string = shift;
	#if word has e-m, do no substitute symbol to space
	### TREAT IT AS A SINGLE TERM/WORD ###
	#e.g. e-mail
	my @matches = ($string =~ m/(\w{8}\s\d,\s\d{4})/ig);
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