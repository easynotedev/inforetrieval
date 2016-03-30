package Lib::Mistemming;
require 5.006;

use strict;
no warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(mistemming);
our @EXPORT = qw(mistemming);

#destroys casings
sub mistemming
{
    my $bow = shift;
    $bow = lc $bow;
    for (my $i=0; $i < 3 ; $i++){
        #STEMMING start part of the string such as ( or ; or & or [
        my $stchar = substr($bow,0,1);
        if($stchar eq '('){
            my $wob=(reverse($bow));
            chop($wob);
            $bow = reverse($wob);
        }
        elsif($stchar eq '['){
            my $wob=(reverse($bow));
            chop($wob);
            $bow = reverse($wob);
        }
        elsif($stchar eq '{'){
            my $wob=(reverse($bow));
            chop($wob);
            $bow = reverse($wob);
        }
        elsif($stchar eq '"'){
           my $wob=(reverse($bow));
            chop($wob);
            $bow = reverse($wob);
        }
        elsif($stchar eq '+'){
            my $wob=(reverse($bow));
            chop($wob);
            $bow = reverse($wob);
        }
        elsif($stchar eq '-'){
            my $wob=(reverse($bow));
            chop($wob);
            $bow = reverse($wob);
        }
        elsif($stchar eq '&'){
            my $wob=(reverse($bow));
            chop($wob);
            $bow = reverse($wob);
        }

        #STEMMING end part of the string such as ) or ; or & or [
        my $lchar = substr($bow, -1);
        if($lchar eq '.'){
            chop($bow);
        }
        elsif($lchar eq ':'){
            chop($bow);
        }
        elsif($lchar eq ','){
            chop($bow);
        }
        elsif($lchar eq '"'){
            chop($bow);
        }
        elsif($lchar eq ']'){
            chop($bow);
        }
        elsif($lchar eq '}'){
            chop($bow);
        }
        elsif($lchar eq ')'){
            chop($bow);
        }
        elsif($lchar eq ';'){
            chop($bow);
        }
        elsif($lchar eq '/'){
            chop($bow);
        }
    }#END for
    
#if word has e-m, do no substitute symbol to space
### TREAT IT AS A SINGLE TERM/WORD ###
#e.g. e-mail
if($bow =~ /(e-mai){1}/){return $bow}
#e.g. minimum grade
elsif($bow =~ /(a-|b-|c-){1}/){return $bow}
#e.g 2016-03-20 DATE STAMP
elsif($bow =~ /(\d\d\d\d-\d\d-\d\d){1}/){return $bow}
#e.g 12-01-2016 DATE
elsif($bow =~ /(\d\d\-\d\d-\d\d\d\d){1}/){return $bow}
#e.g. 16:34:40 TIME STAMP
elsif($bow =~ /(\d\d:\d\d:\d\d){1}/){return $bow}
#e.g. 12-14 CATALOG YEAR
elsif($bow =~ /(\d\d-\d\d){1}/){return $bow}
#e.g. 3-2, 3-0 these are Common term, usually means something
elsif($bow =~ /(\d-\d){1}/){return $bow}
else
{
	### #SUBSTITUTION ### 
    #HYPHEN, back-slash, etc are substituted to spaces
	$bow =~ s/-/ /g;
	$bow =~ s/\// /g;
	$bow =~ s/:/ /g;
	$bow =~ s/\\/ /g;
	$bow =~ s/=/ /g;
	
	#single-qoutes, are substituted to emptyspace
	$bow =~ s/'//g;
}
#initialze the stoplist instead of an input file
my @stoplist = ("the","be","to","of","and","a","in","that","have","it","for","not","on","with","do","at","from","this");

#used perl's smartmatching (~~, if matches an element in stoplist 
#consider stop word irrelevant
#program only checks lowercased strings/word
if( $bow ~~ @stoplist){return undef}
     
#DO NOTHING-S / THEN RETURN UNDEF
elsif( $bow eq "&"){return undef}
elsif( $bow eq "("){return undef}
elsif( $bow eq "["){return undef}
elsif( $bow eq "+"){return undef}
elsif( $bow eq "-"){return undef}
elsif( $bow eq ""){return undef}
elsif( $bow eq " "){return undef}
elsif( $bow eq "'"){return undef}
elsif( $bow eq "'s"){return undef}
#END of DO NOTHING-S    

return $bow;
}

log exp 1;
__END__

=head1 TITLE
Name          : sim.pl
Author        : Antonin Karlo M. Tilaon
Version       : 1
=cut

=pod

=head2 DESCRIPTION
        : Deletes word casings.
        : Deletes from the left, aswell as the right.
        : e.g. string = {[(shell)]}  shell = mistemming(string)
        : It also ignores a word that is a symbol [, +, -, 
        : and single white-space
        : Substitute HYPHENS, conjunction symbols to spaces,
        : This will pass a two word e.i. non-positive becomes non positive
        : Main will treat this different
        : Main will not accomodate if this returns UNDEFINED
        : Treat some words, with distinct permutation of character 
        : as a single word. e.i. 2016-10-23 returns the same
        : Substitute single qoutes as emptyspace
        : Stoplist is initialize inside the script,
        : Used Perl's smartmatch ~~ to determine if a word a stop word
=cut

=pod