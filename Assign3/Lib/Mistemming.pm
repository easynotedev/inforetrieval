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
    }
    for (my $i=0; $i < 3 ; $i++){
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
    
#initialze the stoplist instead of an input file
my @stoplist = ("the","be","to","and","a","in","that","have","it","for","not","on","with","do","at","from");

#used perl's smartmatching (~~, if matches an element in stoplist 
#consider stop word irrelevant
#program only checks lowercased strings/word
if(lc $bow ~~ @stoplist){return undef}
     
#DO NOTHING-S
elsif(lc $bow ~~ "&"){return undef}
elsif(lc $bow ~~ "("){return undef}
elsif(lc $bow ~~ "["){return undef}
elsif(lc $bow ~~ "+"){return undef}
elsif(lc $bow ~~ "-"){return undef}
elsif(lc $bow ~~ ""){return undef}
elsif(lc $bow ~~ " "){return undef}
#END of DO NOTHING-S    
             
return $bow;
}

66;
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
=cut

=pod