package Lib::Linker;
require 5.006;

use strict;
no warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(linker);
our @EXPORT = qw(linker);

sub linker
{
    my $crsname;
    my $bow = shift;
    #$1 is a capture variable, captures anything on a parenthesis
    #i.e. (\w{4}) will equal to MATH, COSC , MTED
    #e.g COSC 1337/1137
    if($bow =~ /(\w{4})\s\d{4}\//g)
    {
    	print "\n\n";
    	my $crsname = $1;
    	print $crsname;
    	print "\n\n";
    	$bow =~ s/\// $crsname /g;
    }
    #e.g. COSC 3191, 3192, 3193
    elsif($bow =~ /(\w{4})\s\d{4},\s\d{4},\s/g)
    {
    	print "\n\n";
        my $crsname = $1;
        print $crsname;
        print "\n\n";
        $bow =~ s/,/ $crsname/g;
    }
    return $bow;
}

log exp 1;
__END__

=head1 TITLE
Name          : Linker.pm
Author        : Antonin Karlo M. Tilaon
Version       : 1
=cut

=pod

=head2 DESCRIPTION
    :Clarify Links, ambigious lines such as , or and /
    :course name are associated with ambigious course number
    :course number which are preceded by , / and or
=cut

=pod