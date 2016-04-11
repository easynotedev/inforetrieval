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
    if($bow =~ /(\w{4})\s\d{4}\//)
    {
    	my $crsname = $1;
    	$bow =~ s/\// $crsname /g;
    }
    #becomes COSC 1337 COSC 1137:
    #e.g MATH 1314, 1324
    if($bow =~ /(\w{4})\s\d{4},\s\d{4}/)
    {
        my $crsname = $1;
        $bow =~ s/,/ $crsname/g;
    }
    #becomes MATH 1314 MATH 1324:
    #e.g. COSC 3191, 3192, 3193
    if($bow =~ /(\w{4})\s\d{4},\s\d{4},\s/)
    {
    	my $crsname = $1;
        $bow =~ s/,/ $crsname/g;
    }
    #becomes COSC 3191 COSC 3192 COSC 3193
    #e.g. MATH 1324 or 2330
    if($bow =~ /(\w{4})\s\d{4}\sor\s\d{4}/)
    {
         my $crsname = $1;
        $bow =~ s/\sor\s/\s$crsname\s/g;
    }
    #e.g. MATH 1314, 1324 or 2330
    if($bow =~ /(\w{4})\s\d{4},\s\d{4}\sor\s\d{4}/)
    {
        my $crsname = $1;
        $bow =~ s/\sor\s/\s$crsname\s/g;
    }
    #e.g COSC 5330, 5340, 5350, and 5360
    if($bow =~ /(\w{4})\s\d{4},\s\d{4},\s\d{4},\sand\s\d{4}/)
    {
        my $crsname = $1;
        $bow =~ s/\sand\s/\s$crsname\s/g;
    }
    #e.g. MTED 5199-5399
    if($bow =~ /(\w{4})\s\d{4}-\d{4}:/)
    {
        my $crsname = $1;
        $bow =~ s/-/ $crsname /g;
    }
    #e.g COSC 4199 - 4399:
    if($bow =~ /(\w{4})\s\d{4}\s-\s\d{4}:/)
    {
        my $crsname = $1;
        $bow =~ s/-/$crsname/g;
    }
    #e.g. MATH 5390 & 5391:
    if($bow =~ /(\w{4})\s\d{4}\s&\s\d{4}:/)
    {
        my $crsname = $1;
        $bow =~ s/&/$crsname/g;
    }
    #becomes MATH 5390 MATH 5391:

    #deletes all word that are not of regex syntax /w/w/w/w/s/d/d/d/d
    $bow =~ s/the|be|to|of|and|a|in|it|for|not|on|do|at//g;
    $bow =~ s/\w{5,99}/ /g;
        $bow =~ s/(\s\s)/ /g;
    $bow =~ s/\w{5,99}/ /g;
        $bow =~ s/(\s\s)/ /g;
    $bow =~ s/\w{5,99}/ /g;
        $bow =~ s/(\s\s)/ /g;
    $bow =~ s/\w{5,99}/ /g;
        $bow =~ s/(\s\s)/ /g;
    $bow =~ s/,|:|\.//g;
    
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
    :used substitutition s/<regex>/<expression>/g to match the above
    :and change it too the expression
    :deletes all word that are not of regex /w/w/w/w/s/d/d/d/d
=cut

=pod