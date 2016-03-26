#!/usr/bin/perl

=pod

=head1 TITLE
Name          : sim.pl
Author        : Antonin Karlo M. Tilaon
Course Info   : COSC 4315.001 - Assignment III
Date          : 3/20/2016
=cut

=pod

=head1 DESCRIPTION
       : First input/prompt is the location of the data files
       : Second input/prompt is the location of the query document (Q)
       : Third input/prompt is the number of documents the system should return (K)
       : System should find and return the K documents that are the most similar to Q
       : K Documents are to be sorted in order, From most Similar to Least similar
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
#debugging tool, makes it easier to print ARRAY & HASH
use Data::Dumper;
#use experimental 'smartmatch';
no warnings 'experimental::smartmatch';

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

use Lib::Mistemming;
use Lib::Porterstemmer;

#initialze the stoplist instead of an input file
my @stoplist = ("the","be","to","and","a","in","that","have","it","for","not","on","with","do","at","from");

#Read file and put to HASH or
#if file is query save as query file
#Manipulates Array DOCID, and Hash INFILEHASH
my %INFILEHASH;
my @DATAID;
#A specific methods happens to the query file
my $query='';
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
    #if QUERY FILE
    if($filenm eq $notxtquery)
    {
        $query = $filenm; 
        $query = "@filedy";
    }
    #if an input file
    #saves the (Array of string / text-body of a file) to the appropriate key in the GlobalHASH
    else
    {
        $INFILEHASH{$filenm} = "@filedy";
        push @DATAID, "$filenm";
    }
}


################################### FUN STARTS HERE ###################################
#shows absolute path
print "script's path : ";
print abs_path($0)."\n\n";

#negates the new-line char
print "Enter absolute path of data files> ";
chomp(my $LOCDATFIL = <STDIN>);

#Although Unix's Forward-slash constrasts Win's Back-slash superficially, 
#looks aside, perl knows that it could associate them together as they are one and the same
#Open location of input directory
#opendir my $DIR_HANDLE,"$LOCINLES" or die "Unable to open directory : $!";
opendir my $DIR_HANDLE,"$LOCDATFIL" or die "Unable to open directory : $!";
#Open location of input directory
#Access all **.txt files from DIR/location and put each into GLOBALHASH INFILE as KEYS
    # (^assert position at start of the string)(.+ matches any character (except newline))
    # Quantifier: + Between one and unlimited times, as many times as possible, 
    # txt matches the characters txt literally (case sensitive) (assert position at end of the string$)
my @DOCTXTID= grep(/^.+.txt$/,readdir($DIR_HANDLE));

closedir $DIR_HANDLE;

#NUMBER OF DOCUMENT VECTOR
my $docno=0;
foreach my $file_name (@DOCTXTID)
{
    $docno++;
    #on each access of a **.txt file, do below
    readfileto("$LOCDATFIL/$file_name",$file_name);
}#END foreach

#INIT PORTER STEMMER
initialiseporter();
#HASH FOR TOKEN
my %TOKENHASH;
#HASH FOR TERMS IN A DATAFILE
my %TOTNURMS;

foreach my $file_name (@DATAID)
{
	my @bodyofword = split / /, $INFILEHASH{$file_name};
	#counter for terms in a document/how many terms in a Document?
    my $ctr=0;
    foreach my $word(@bodyofword)
    {
        #TOTNURMS HASH counter
        $ctr++;
        #perldoc Mistemming.pm
        $word=mistemming($word);
        #used perl's smartmatching (~~, if matches an element in stoplist 
        #consider stop word irrelevant
        #program only checks lowercased strings/word
        if(lc $word ~~ @stoplist){}
        
        #DO NOTHING-S
        elsif(lc $word ~~ "&"){}
        elsif(lc $word ~~ "("){}
        elsif(lc $word ~~ "["){}
        elsif(lc $word ~~ "+"){}
        elsif(lc $word ~~ "-"){}
        elsif(lc $word ~~ ""){}
        elsif(lc $word ~~ " "){}
        #END of DO NOTHING-S    
            
        else
        {
            #USE PORTER STEMMER to CONVERT the TERM into a TOKEN
            #TOKENS are NORMALIZED terms
            my $word = stem(lc $word);
            #Use TOKEN as key of a HASH, and INITIALIZE its value to defined
            $TOKENHASH{$word} = defined; 
        }
    #STORE THE TOTAL NO. of TERMS for each DOCUMENT in a HASH;these are unstemmed and unnormalized
    $TOTNURMS{$file_name}=$ctr;
    }
}

#print Dumper\%TOTNURMS;
#print Dumper\%TOKENHASH;

print "\n";
print "Enter absolute path of Query document> ";
chomp(my $LOCQUEFIL = <STDIN>);
#stoplist filename
my $query_filenm = basename($LOCQUEFIL);
#different to nmeofstoplist,this is for a check in readfile, so stoplist doc does not save to the TOKEN HASH
$notxtquery = $query_filenm;
$notxtquery =~ s/.txt$//;
$notxtquery =~ s/\s//;  

readfileto($LOCQUEFIL, $query_filenm);
print $query;

print "\n";
print "Number of similar documents to display> ";
chomp(my $K = <STDIN>);
printf "K is: %s",$K;

################################### CREATE TOKENS FROM DOCUMENT FILES USING HASH ###################################
print "\nProcessing ..  \n";
#In this case using HASH is convenient since the INVERTED INDEX require unique tokens, although with frequencies


print "\n";
system("pause");

__END__
=pod
=head2 ASSUMPTIONS
       : data files are .txt files
       : location of the query is in a hierarchical file-system
       : Three input items, are necessary for this program to be graded
       : Stoplist is initialize inside the script
=cut

=pod
=head2 Accreditation
       : Sources online made me aware of Perl function such as 
       : opendir,grep(filename.txt)and save to HASH as key
       : push a string to an array, HANDLES to open directory or file
       : sort array by numeric value using spaceship operator
       : find path using perl's basename function
       : Multidimensional HASH
       : Perl's Smartmatch operator
       : Perl Maven taught me how to change @INC to find Perl modules
       : in non-standard locations
       : Adding my understanding of the assignment to these functions
       : Allowed me to piece together a working program
       : stackoverflow.com , perldoc.perl.org, perlmonks.org, cpan.org
       : grateful for Gabor Szabo, Author of perlmaven.com 
=cut