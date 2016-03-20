#!/usr/bin/perl

=pod

=head1 TITLE
Name          : sim.pl
Author        : Antonin Karlo M. Tilaon
Course Info   : COSC 4315.001 - Assignment III
Date          : 3/20/2016
=cut

=pod

=head2 ASSUMPTIONS
       : data files are .txt files
       : location of the query is in a hierarchical file-system
       : Three input items, are necessary for this program to be graded
       : Does not need a stoplist
=cut

=pod

=head1 DESCRIPTION
       : First input/prompt is the location of the data files
       : Second input/prompt is the location of the query document (Q)
       : Third input/prompt is the number of documents the system should return (K)
       : System should find and return the K documents that are the most similar to Q
       : K Documents are to be sorted in order, From most Similar to Least similar
=cut

=pod

=head2 Accreditation
       : Sources online made me aware of Perl function such as 
       : opendir,grep(filename.txt)and save to HASH as key
       : push a string to an array, HANDLES to open directory or file
       : sort array by numeric value using spaceship operator
       : find path using perl's basename function
       : Multidimensional HASH 
       : Perl Maven taught me how to change @INC to find Perl modules
       : in non-standard locations
       : Adding my understanding of the assignment to these functions
       : Allowed me to piece together a working program
       : stackoverflow.com , perldoc.perl.org, perlmonks.org, cpan.org
       : grateful for Gabor Szabo, Author of perlmaven.com 
=cut

use 5.18.0;
use strict;
use warnings;
use File::Basename;
use File::Spec;
#no warnings 'experimental::smartmatch';
#use experimental 'smartmatch';
#use current working directory
use Cwd;
use Cwd 'abs_path';

#The catdir method of the File::Spec module/class can concatenate parts of a file-system path in a platform specific way. 
#Because $0 might contain just the name of the script we first need to ask the currently running perl to calculate the absolute path.
#We do that using the abs_path method of the Cwd module. Once we have the absolute path,  
#we get rid of the last part of the path which is the name of the file We do that by calling the dirname function of File::Basename 
#Then, as before, we use catdir to go one directory up (..) 
#and then descend to the lib directory.
#i.e.
# $path =[EQUAL TO]= C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\perl_project\\script_name
# dirname('$path') =[EQUAL TO]= C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\perl_project
# File::Spec->catdir(dirname('$path'),'..','Lib') =[EQUAL TO]= C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\perl_project\\Lib
my $path;
$path = Cwd::abs_path($0);
#i.e.
#use lib "C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\perl_project\\Lib";
use Lib File::Spec->catdir(dirname('$path'),'..','Lib');

my %INFILEHASH;
my @DOCID;
my $nmeofstoplist='';
my $nameofstoplist='';

#Manipulates Array DOCID, and Hash INFILEHASH
#A specific methods happens to the stoplist file
sub readfiletohash
{
    my $PATH = shift;
    my $filenm = shift;
    #local sub variable - holds the file's body of text
    my @filedy;
    open(my $FIL_HANDLE,"<",$PATH) or die "Unable to open file : $!";
        #Number of lines in a file, not number of words
        while (my $line = <$FIL_HANDLE>){
            #negates new-line char, then push a $line into the array
            chomp($line);
            push @filedy, "$line";
            }#END while
    close $FIL_HANDLE;
    #USED Substitute function .txt(end) -> null to
    #TRIM / ELIMINATES .txt in DOCID's
    $filenm =~ s/.txt$//;
    #USED Sbustitute function to delete whitespace(s/) ->(becomes) null
    $filenm =~ s/\s//;
    #saves the (Array of string / text-body of a file) to the appropriate key in the GlobalHASH
    if($filenm eq $nmeofstoplist)
    {
        $nameofstoplist = $filenm; 
        $nameofstoplist = "@filedy";
    }
    #if an input file
    else
    {
        $INFILEHASH{$filenm} = "@filedy";
        push @DOCID, "$filenm";

    }
}


################################### FUN STARTS HERE ###################################
#shows absolute path
print "script's path : ";
print abs_path($0)."\n\n";



#below is if I would need to convert backslash into forwardslash, # is a delimeter in the substitution function
#$LOCINLES =~ s#\\#\\\\#g;
print "Enter absolute path of data files> ";
chomp(my $LOCDAILE = <STDIN>);
#stoplist filename
my $stplst_filenm = basename($LOCSTIST);
#different to nmeofstoplist,this is for a check in readfile, so stoplist doc does not save to the TOKEN HASH
$nmeofstoplist=$stplst_filenm;
$nmeofstoplist =~ s/.txt$//;
$nmeofstoplist =~ s/\s//;

readfiletohash("$LOCSTIST","$stplst_filenm");
print "\n";
printf "stop words : %s", $nameofstoplist;
print "\n\n";
print "Enter absolute path of input DIRECTORY, location of input files> ";
chomp(my $LOCINLES = <STDIN>);
#negates the new-line char
print "\n";
print "e.i. output file must be an absolute DIRECTORY location";
print "\n";
print "Enter desired location of file output.txt> ";
chomp(my $LOCOUPUT = <STDIN>);

__END__