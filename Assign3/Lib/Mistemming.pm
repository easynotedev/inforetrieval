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
return $bow;
}

66;