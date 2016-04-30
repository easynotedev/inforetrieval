#!/usr/bin/perl

=pod

=head1 TITLE
Name          : quesanswsyst.pl
Author        : Antonin Karlo M. Tilaon
Course Info   : COSC 4315.001 - Assignment V
Date          : 4/7/2016
=cut

=pod

=head1 DESCRIPTION
       : Needs perl 5.18.0 <=
       : Implement several steps of a quest-ans system
       : A user will submit a query in the form of 
       : a natural language question to Google
       : and create a text file from results on the page.
       : Program will produce the asnwer by prompting
       : for the name of the text file and reading it.
       : Identify the tokens which represent the expected answer type
       : Your program will identify each date in the text file 
       : (token strings that match the abovepattern).    
       : It should then display the top three dates 
       : that appear the most frequently (in descending order).
=cut

use 5.18.0;
use strict;
use warnings;
#use experimental 'smartmatch';
no warnings 'experimental::smartmatch';
use File::Basename;
use File::Spec;
#use current working directory
use Cwd;
use Cwd 'abs_path';
#The catdir method of the File::Spec module/class can concatenate parts of a file-system path in a platform specific way. 
#Because $0 might contain just the name of the script we first need to ask the currently running perl to calculate the absolute path.
#We do that using the abs_path method of the Cwd module. Once we have the absolute path,  
#we get rid of the last part of the path which is the name of the file We do that by calling the dirname function of File::Basename 
#Then, as before, we use catdir to go one directory up (..) 
#and then descend to the lib directory, i.e.
# $path =[EQUAL TO]= C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\perl_project\\script_name
# dirname('$path') =[EQUAL TO]= C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\perl_project
# File::Spec->catdir(dirname('$path'),'..','Lib') =[EQUAL TO]= C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\perl_project\\Lib
my $path;
$path = Cwd::abs_path($0);
#i.e.
#use lib "C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\perl_project\\Lib";
use Lib File::Spec->catdir(dirname('$path'),'..','Lib');
use Lib::Readtoarray;
use Lib::Parse;
#debugging tool, makes it easier to print ARRAY & HASH
use Data::Dumper;

###################################   SOL FUN STARTS  ###################################
my %ANSHASH;
print "\n";
#shows absolute path
print "script's path -> ";
print abs_path($0)."\n\n";

#negates the new-line char
print "Enter absolute path of input files> ";
chomp(my $LOCINTFIL = <STDIN>);
my @inptdy = readtoarray($LOCINTFIL);
print "\n";
print "\n"; 
print "Input-File -> Text Body:";
print "\n";
print "\n"; 
print "\t"; 
print @inptdy;
my $line = "@inptdy";
print "\n"; 
my %ANSHASHMAIN = parse($line);

#print Dumper \%ANSHASHMAIN;
print "\n";
print "Showing Top Three dates :";
print "\n";
print " No. Date\t\tFrequency";

my $ctr;
foreach my $date ((reverse sort { $ANSHASHMAIN{$a} <=> $ANSHASHMAIN{$b} } keys %ANSHASHMAIN)[0..2])
{
     printf "\n";
     printf "%3d. ",++$ctr;
     printf $date;
     printf "\t";
     printf "%s",$ANSHASHMAIN{$date};
}
print "\n";
####################################   EOL FUN ENDS  ####################################

print "\n";
system("pause");
__END__
=pod
=head2 SPECIFICS
       : Works on dates only
=cut