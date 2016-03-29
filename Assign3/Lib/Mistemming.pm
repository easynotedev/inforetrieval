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
    for (my $i=0; $i < 3 ; $i++){
        #STEMMING start part of the string such as ) or ; or & or [
        my $stchar = substr($bow,0,1);
        if($stchar eq '('){
            my $wob=(reverse($bow));
            $bow=chop($wob);
        }
        elsif($stchar eq '['){
            my $wob=(reverse($bow));
            $bow=chop($wob);
        }
        elsif($stchar eq '{'){
            my $wob=(reverse($bow));
            $bow=chop($wob);
        }
        elsif($stchar eq '"'){
            my $wob=(reverse($bow));
            $bow=chop($wob);
        }
        elsif($stchar eq '+'){
            my $wob=(reverse($bow));
            $bow=chop($wob);
        }
        elsif($stchar eq '-'){
            my $wob=(reverse($bow));
            $bow=chop($wob);
        }
        elsif($stchar eq '&'){
            my $wob=(reverse($bow));
            $bow=chop($wob);
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
    
#if word has e-m, do no substitute symbol e.g. e-mail
if($bow =~ /(e-m){1}/){}
elsif($bow =~ /(c-){1}/){}
else
{
	#SUBSTITUTION
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
if(lc $bow ~~ @stoplist){return undef}
     
#DO NOTHING-S / THEN RETURN UNDEF
elsif(lc $bow eq "&"){return undef}
elsif(lc $bow eq "("){return undef}
elsif(lc $bow eq "["){return undef}
elsif(lc $bow eq "+"){return undef}
elsif(lc $bow eq "-"){return undef}
elsif(lc $bow eq ""){return undef}
elsif(lc $bow eq " "){return undef}
elsif(lc $bow eq "'"){return undef}
elsif(lc $bow eq "'s"){return undef}
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
        : Main will not accomodate if this returned UNDEFINED
        : Substitute single-qoutes to NULL
        : Stoplist is initialize inside the script,
        : Used Perl's smartmatch ~~ to determine if a word a stop word
=cut

=pod