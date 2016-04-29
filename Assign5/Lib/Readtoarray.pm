package Lib::Readtoarray;
#require 5.006;

use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(readtoarray);
our @EXPORT = qw(readtoarray);

our(@filedy);

sub readtoarray
{
	
	my $line;
    my $FILOC = shift;
	open(my $FIL_HANDLE,"<",$FILOC) or die "Unable to open file : $!";
	        while (my $line = <$FIL_HANDLE>){
	            #negates new-line char, then push a $line into the array
	            chomp($line);
	            push @filedy, "$line";
	            }#END while         
	close $FIL_HANDLE;
	return @filedy;
}

log exp 1;
__END__

=head1 TITLE
Name          : Readtoarray.pm
Author        : Antonin Karlo M. Tilaon
Version       : 1
=cut
