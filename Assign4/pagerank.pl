#!/usr/bin/perl

=pod

=head1 TITLE
Name          : pagerank.pl
Author        : Antonin Karlo M. Tilaon
Course Info   : COSC 4315.001 - Assignment IV
Date          : 4/7/2016
=cut

=pod

=head1 DESCRIPTION
       : Compute and output the link probability matrix formed by the documents
       : inputs the teleport probability alpha
       : along with the number of desired iterations
       : Display the page rank of each document using the input teleport probability
       : Documents should be displayed in sorted (decreasing) order
       : Based on the computed popularity.
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

#debugging tool, makes it easier to print ARRAY & HASH
use Data::Dumper;

################################### SOL READ FILE SUB ###################################
#Read file and put to HASH or
#if file is query save as query file
#Manipulates Array DOCID, and Hash INFILEHASH
#DOCID is the key of INFILEHASH, without the suffix .txt
my %INFILEHASH;
#A specific methods happens to the query file
my $querynm ='';
my $query = ();
my $notxtquery='';

sub readfileto
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
    #USED Substitute function to delete whitespace(s/) ->(becomes) null
    $filenm =~ s/\s//;
    #if a DATA FILE
    #saves the (Array of string / text-body of a file) to the appropriate key in the GlobalHASH
    $INFILEHASH{$filenm} = "@filedy";
    
}
################################### EOL READ FILE SUB ###################################
###################################   SOL FUN STARTS  ###################################
#shows absolute path
print "script's path -> ";
print abs_path($0)."\n\n";

#negates the new-line char
print "Enter absolute path of input files> ";
chomp(my $LOCINTFIL = <STDIN>);

#Although Unix's Forward-slash constrasts Win's Back-slash superficially, 
#looks aside, perl knows that it could associate them together as they are one and the same
#Open location of input directory
opendir my $DIR_HANDLE,"$LOCINTFIL" or die "Unable to open directory : $!";
#Open location of input directory
#Access all **.txt files from DIR/location and put each into GLOBALHASH INFILE as KEYS
    # (^assert position at start of the string)(.+ matches any character (except newline))
    # Quantifier: + Between one and unlimited times, as many times as possible, 
    # txt matches the characters txt literally (case sensitive) (assert position at end of the string$)
my @DOCTXTID= grep(/^.+.txt$/,readdir($DIR_HANDLE));
closedir $DIR_HANDLE;

#NUMBER OF DOCUMENT VECTOR, N-value
my $DOCNO=0;
print "\nPARSING INPUT FILES..  \n";
foreach my $file_name (@DOCTXTID)
{
    $DOCNO++;
    #on each access of a **.txt file, do below
    readfileto("$LOCINTFIL/$file_name",$file_name);
}#END foreach

print "\n";
print "Enter absolute path of output.txt file> ";
chomp(my $LOCOUTFIL = <STDIN>);
#output filename
my $otpt_flnm = basename($LOCOUTFIL);

print "\n";
print "Enter Teleport Probability> ";
chomp(my $TELEPROB = <STDIN>);

print "\n";
print "Enter Number of iterations> ";
chomp(my $ITERATE = <STDIN>);

###################################  SOL OUTPUTTING  ###################################
chdir ($LOCOUTFIL) or die "Unable to open directory : $!";
open (my $outfile, ">", "output.txt") or die "Can't open the output file : $!";
print "\nFinish writing page rank scores in output.txt ..\n\n";
close($outfile);
my $cwd = getcwd();
chdir($cwd);
###################################  EOL OUTPUTTING  ###################################
print "\n";
system("pause");
__END__
=pod
=head2 ASSUMPTIONS
       : data files are .txt files
       : location of the query is in a hierarchical file-system
       : Four input items, are necessary for this program to be graded  
       : 1. Directory containing input files
       : 2. Location of the output file
       : 3. Teleport probability
       : 4. Number of iterations
=cut

=pod
=head2 SPECIFICS
       : 
=cut

=pod
=head2 Accreditation
       : 
=cut