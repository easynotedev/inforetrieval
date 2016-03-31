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

#use current working directory
use Cwd;
use Cwd 'abs_path';
#debugging tool, makes it easier to print ARRAY & HASH
use Data::Dumper;
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
use Lib::Round;

################################### READ FILE SUB ###################################
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
    #if QUERY FILE
    if($filenm eq $notxtquery)
    {
        $querynm = $filenm; 
        $query = "@filedy";
    }
    #if a DATA FILE
    #saves the (Array of string / text-body of a file) to the appropriate key in the GlobalHASH
    else
    {
        $INFILEHASH{$filenm} = "@filedy";
    }
}


################################### FUN STARTS HERE ###################################
#shows absolute path
print "script's path -> ";
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

#NUMBER OF DOCUMENT VECTOR, N-value
my $DOCNO=0;
print "\nPARSING DATAFILES..  \n";
foreach my $file_name (@DOCTXTID)
{
    $DOCNO++;
    #on each access of a **.txt file, do below
    readfileto("$LOCDATFIL/$file_name",$file_name);
}#END foreach


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
print "\n";
print $query;

####INIT PORTER STEMMER###
initialiseporter();
####INIT PORTER STEMMER###

################################### QUERY TERM ITERATION ###################################
#FREQ HASH OF QUERY DOC terms
my %QUERIASH;
my @arrayquerycatcher =();
my @words = split / /, $query;
foreach my $word (@words)
{
    my $maybewords = mistemming($word);
    if(defined $maybewords)
    { 
        #for each word, in GROUP OF WORDS (this iterates if word is hypenated)
        my @maybewords = split / /, $maybewords;
        foreach my $word (@maybewords)
        {      
            my $tf=0;
            my $idf=0;
            #USE PORTER STEMMER to CONVERT the TERM into a TOKEN
            #TOKENS are NORMALIZED terms
            my $qtok = stem(lc $word);
            #TERM FREQUENCY OF QUERYTERM
            $QUERIASH{$qtok}{"tf"}++;
            push @arrayquerycatcher, "$qtok";  
        }
     }
}

print "\n";
print "\n";
print "Number of similar documents to display> ";
chomp(my $K = <STDIN>);
printf "K is: %s",$K;

################################### DATAFILE CONTENT ITERATION ###################################

print "\n\nCreating TOKENS..  \n";
my %UNSTMWORDHASH;
#A HASH to control the increment of tokens in the documents
my %FLAGGED;
##################### INITIALIZATION ######################
#initialized flag to defined value foreach TOKEN
foreach my $dataf (keys %INFILEHASH)
{
    my @bodyofword = split / /, $INFILEHASH{$dataf};
    foreach my $word(@bodyofword)
    {
        $UNSTMWORDHASH{lc $word}=defined;
        my $maybewords = mistemming($word);
        #my prlmodule will do nothing if $maybewords is UNDEFINED, refer to perldoc Mistemming.pm
        if(defined $maybewords)
        { 
            my @maybewords = split / /, $maybewords;
            foreach my $word (@maybewords)
            { 
                my $tok = stem(lc $word);
                #DEFINED EACH TOKEN KEY for FLAGGING
                #needed to stop TOKEN FREQUENCY FROM INCREMENTING
                $FLAGGED{$tok}=defined;
            }
        }
    }
}

##################### TOKENIZATION ######################
#THE FOLLOWING loops has the same dimensions as above
#HASH FOR STEMMED DATAFILE content, keys will be DATAID
my %STMDOCHASH;
#HASH for storing token values
my %TOKENHASH;
#Token frequency buffer of each Data file
#HASH WHICH WILL DETERMINE THE VALUE OF A FREQUENCY, which is CORRELATED to a TOKEN and DATA FILE
my %TRMFREQASH;
#HASH FOR TERMS IN A DATAFILE
my %TOTNURMS;
my @arraylinecatcher =();
my @arraybowcatcher=();

foreach my $dataf (keys %INFILEHASH)
{
	#text-body-buffer value return to null;
	@arraybowcatcher=();
	#PARSE content of a DATAFILE
	my @bodyofword = split / /, $INFILEHASH{$dataf};
	#counter for terms in a document/how many terms in a Document?
    my $ctr=0;
    foreach my $word(@bodyofword)
    {
        #text-line-buffer value return to null;
        @arraylinecatcher =();
        #TOTNURMS HASH counter
        $ctr++;
        
        #perldoc Mistemming.pm
        my $maybewords = mistemming($word);
        #my prlmodule will do nothing if $maybewords is UNDEFINED, refer to perldoc Mistemming.pm
        if(defined $maybewords)
        { 
	        #for each word, in GROUP OF WORDS (this iterates if word is hypenated)
	        my @maybewords = split / /, $maybewords;
	        foreach my $word (@maybewords)
	        {      
		       #STORE THE TOTAL NO. of TERMS for each DOCUMENT in a HASH;counts HYPENATED words as a single-term
               $TOTNURMS{$dataf}=$ctr;
		       #USE PORTER STEMMER to CONVERT the TERM into a TOKEN
	           #TOKENS are NORMALIZED terms
	           my $tok = stem(lc $word);
               if(defined $FLAGGED{$tok} && $FLAGGED{$tok} ne $dataf)
               {
	               #DOCUMENT FREQUENCY   
	               $TOKENHASH{$tok}++; 
	               #DOCUMENT FREQUENCY OF QUERY TERMS
	               #if query term is the same us current TOKEN, increment value
	               my ($qtok) = grep {$tok eq $_} keys %QUERIASH;
	               if(defined $qtok)
	               {
	                   $QUERIASH{$qtok}{"df"}++;
	               }
	               elsif(undef $qtok)
                   {
                       $QUERIASH{$qtok}{"df"}=0;
                   }
	               $FLAGGED{$tok}=$dataf;
               }
	           #TERM FREQUENCY   
	           $TRMFREQASH{$dataf}{$tok}++; 
		       push @arraylinecatcher, "$tok";  
	        }
	        push @arraybowcatcher,"@arraylinecatcher";
	   }#END IF word defined
    }#END for each word in body of word
    $STMDOCHASH{$dataf} = "@arraybowcatcher";
}#END for each datafile

########## DEBUGGING TOOLS FOR DATAFILE ITERATION #############
#print Dumper\%TOTNURMS;
#print Dumper\%QUERIASH;
open (my $outfile, ">", "output.txt") or die "Can't open a output file : $!";
print $outfile Dumper\%TOKENHASH;
print $outfile "\n";
print $outfile Dumper\%TRMFREQASH;
close($outfile);
#print Dumper\%STMDOCHASH;

################################### TERM FREQUENCIES ITERATION ###################################
my %QUETFIDF;
#Term Frequency of each Document, to get the euclidean length
my %TFVAL;
#Euclidean Normalized tf values for data files
my %EUCLILEN;
my %SIMPROD;

print "\nComputing IMPROVED COSINE SIM SCORES..";
foreach my $qtok (keys %QUERIASH)
{
    if(defined $QUERIASH{$qtok}{"df"})
    {
    	$QUETFIDF{$qtok} = $QUERIASH{$qtok}{"tf"} * log ($DOCNO / $QUERIASH{$qtok}{"df"});
    }
    else
    {
        $QUETFIDF{$qtok} = 0;
    }
    foreach my $dataf (keys %INFILEHASH)
    {
        if(defined $TRMFREQASH{$dataf}{$qtok})
        {
            #Component of EUCLIDEAN LENGTH, SUMMATION of tf Squared for a datafile
            $TFVAL{$dataf} += $TRMFREQASH{$dataf}{$qtok} * $TRMFREQASH{$dataf}{$qtok};
            #EUC. NORMALIZED LENGTH = term frequency / EUCLIDEAN LENGTH
            $EUCLILEN{$dataf}{$qtok} = $TRMFREQASH{$dataf}{$qtok} / sqrt $TFVAL{$dataf}; 
        }
        else
        {
            $EUCLILEN{$dataf}{$qtok} = 0;
        }
        my $termproduct = $QUETFIDF{$qtok} * $EUCLILEN{$dataf}{$qtok};
        #NET SCORE OF A TERM PRODUCT FOR A DATAFILE
        $SIMPROD{$dataf} += $termproduct;
    }
}

########## DEBUGGING TOOLS TERM FREQ ITERATION #############
print "\n";
#print Dumper\%TFVAL;
#print Dumper\%EUCLILEN;
#print Dumper\%SIMPROD;

print "\n";
printf "Showing Most Relevant Documents of degree %s :",$K;
print "\n";
print "DATA FILE ID\t\tSCORES";
print "\n";
#SORT THE VALUES
#USED PERL's SPACE OPERATOR to sort the array float
#Here $a and $b, the place-holder variables of sort will always hold 
#two keys returned by the keys function 
#and we compare the respective values using the spaceship operator.
#since (sort keys %hash) is a list, we can just take a list slice: by adding [0..$K-1]
foreach my $dataf ((reverse sort { $SIMPROD{$a} <=> $SIMPROD{$b} } keys %SIMPROD)[0..$K-1])
{
  
  print $dataf;
  print "\t\t";
  print nearest(.0001,$SIMPROD{$dataf});
  print "\n";
}
print "\n";
system("pause");

__END__
=pod
=head2 ASSUMPTIONS
       : data files are .txt files
       : location of the query is in a hierarchical file-system
       : Three input items, are necessary for this program to be graded  
=cut

=pod
=head2 SPECIFICS
       : HYPHENATED words are treated as group of words
       : Store TOKEN value correlated to a document, into a HASH %TOKENHASH
       : Store No. of terms for each Data file in a HASH %TOTNURMS
       : Store Term Frequency matrix of datafiles in a HASH %FREQHASH
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