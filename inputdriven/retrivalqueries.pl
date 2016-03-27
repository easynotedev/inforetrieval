#!/usr/bin/perl

#============================================================================
# Name        	: invertedindex.pl
# Author      	: Antonin Karlo M. Tilaon
# Course Info 	: COSC 4315.001 - Assignment I
# Date		: 2/14/2016
# Description 	: Creates INVERTED INDEX from a text files and a single 
#		: stop list, both coming from directory location given by
#		: the user.
#		: Outputs the INVERTED INDEX to the specified location
#		: given by the user
# Accreditation : Sources online made me aware of Perl function such as 
#		: opendir,grep(filename.txt)and save to HASH as key
#		: push a string to an array, HANDLES to open directory or file
#		: sort array by numeric value using spaceship operator
#		: find path using perl's basename function
#		: and my Man Porter Stemmer :D
# 		: Adding my understanding of the assignment to these functions
#		: Allowed me to piece together a working program
#		: stackoverflow.com , perldoc.perl.org (5.14.2), perlmonks.org
#		: grateful for Gabor Szabo, Author of perlmaven.com 
#		: http://tartarus.org/martin/PorterStemmer/perl.txt
#============================================================================

#OUR LAB computers are at least ver 5.18
use 5.18.0;
use strict;
use warnings;
use File::Basename;
use integer;
#no warnings 'experimental::smartmatch';
use experimental 'smartmatch';

#use current working directory
use Cwd;
#shows absolute path
use Cwd 'abs_path';
#GlobalHASH - filenames are used as keys, text-content of each files are associated appropriately
my %INFILEHASH = ();
my %TOKENHASH = ();
my %DOCHASH = () ;
my @DOCHA;

#stoplist verifier,so stoplist could be any file
#string to check stoplist name
my $nmeofstoplist="";
#below will be in the stoplist vector
my $nameofstoplist="";
#above is USED in stemming;

#open a file specified in the path, and save it into the Global hash
#1st shift is the FILE LOCATION
#2nd shift is the FILE NAME
sub readfile
{
	my $PATH = shift;
	my $filenm = shift;
	#local sub variable - holds the file's body of text
	my @filedy;
	open(my $FIL_HANDLE,"<",$PATH) or die "Unable to open file : $!";
		while (my $line = <$FIL_HANDLE>){
			#negates new-line char, then push a $line into the array
			chomp($line);
			push @filedy, "$line";
			}#END while
	close $FIL_HANDLE;
	#USED Substitute function .txt(end) -> null to
	#ELIMINATES .txt in DOCID's
	$filenm =~ s/.txt$//;
	#USED Sbustitute function to delete whitespace(s/) ->(becomes) null
	$filenm =~ s/\s//;
	#saves the (Array of string / text-body of a file) to the appropriate key in the GlobalHASH
	if($filenm eq "$nmeofstoplist")
	{
		$nameofstoplist = $filenm;
		$nameofstoplist = "@filedy";
	}
	else
	{
		$DOCHASH{$filenm} = "@filedy";
		push @DOCHA, "$filenm";
	}
}#END sub=readfile

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

################################### START OF PORTER STEMMER's SUBS ###################################

my %step2list;
my %step3list;
my ($c, $v, $C, $V, $mgr0, $meq1, $mgr1, $_v);


sub stem
{  my ($stem, $suffix, $firstch);
   my $w = shift;
   if (length($w) < 3) { return $w; } # length at least 3
   # now map initial y to Y so that the patterns never treat it as vowel:
   $w =~ /^./; $firstch = $&;
   if ($firstch =~ /^y/) { $w = ucfirst $w; }

   # Step 1a
   if ($w =~ /(ss|i)es$/) { $w=$`.$1; }
   elsif ($w =~ /([^s])s$/) { $w=$`.$1; }
   # Step 1b
   if ($w =~ /eed$/) { if ($` =~ /$mgr0/o) { chop($w); } }
   elsif ($w =~ /(ed|ing)$/)
   {  $stem = $`;
      if ($stem =~ /$_v/o)
      {  $w = $stem;
         if ($w =~ /(at|bl|iz)$/) { $w .= "e"; }
         elsif ($w =~ /([^aeiouylsz])\1$/) { chop($w); }
         elsif ($w =~ /^${C}${v}[^aeiouwxy]$/o) { $w .= "e"; }
      }
   }
   # Step 1c
   if ($w =~ /y$/) { $stem = $`; if ($stem =~ /$_v/o) { $w = $stem."i"; } }

   # Step 2
   if ($w =~ /(ational|tional|enci|anci|izer|bli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti|logi)$/)
   { $stem = $`; $suffix = $1;
     if ($stem =~ /$mgr0/o) { $w = $stem . $step2list{$suffix}; }
   }

   # Step 3

   if ($w =~ /(icate|ative|alize|iciti|ical|ful|ness)$/)
   { $stem = $`; $suffix = $1;
     if ($stem =~ /$mgr0/o) { $w = $stem . $step3list{$suffix}; }
   }

   # Step 4

   if ($w =~ /(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|ou|ism|ate|iti|ous|ive|ize)$/)
   { $stem = $`; if ($stem =~ /$mgr1/o) { $w = $stem; } }
   elsif ($w =~ /(s|t)(ion)$/)
   { $stem = $` . $1; if ($stem =~ /$mgr1/o) { $w = $stem; } }


   #  Step 5

   if ($w =~ /e$/)
   { $stem = $`;
     if ($stem =~ /$mgr1/o or
         ($stem =~ /$meq1/o and not $stem =~ /^${C}${v}[^aeiouwxy]$/o))
        { $w = $stem; }
   }
   if ($w =~ /ll$/ and $w =~ /$mgr1/o) { chop($w); }

   # and turn initial Y back to y
   if ($firstch =~ /^y/) { $w = lcfirst $w; }
   return $w;
}

sub initialiseporter {

   %step2list =
   ( 'ational'=>'ate', 'tional'=>'tion', 'enci'=>'ence', 'anci'=>'ance', 'izer'=>'ize', 'bli'=>'ble',
     'alli'=>'al', 'entli'=>'ent', 'eli'=>'e', 'ousli'=>'ous', 'ization'=>'ize', 'ation'=>'ate',
     'ator'=>'ate', 'alism'=>'al', 'iveness'=>'ive', 'fulness'=>'ful', 'ousness'=>'ous', 'aliti'=>'al',
     'iviti'=>'ive', 'biliti'=>'ble', 'logi'=>'log');

   %step3list =
   ('icate'=>'ic', 'ative'=>'', 'alize'=>'al', 'iciti'=>'ic', 'ical'=>'ic', 'ful'=>'', 'ness'=>'');


   $c =    "[^aeiou]";          # consonant
   $v =    "[aeiouy]";          # vowel
   $C =    "${c}[^aeiouy]*";    # consonant sequence
   $V =    "${v}[aeiou]*";      # vowel sequence

   $mgr0 = "^(${C})?${V}${C}";               # [C]VC... is m>0
   $meq1 = "^(${C})?${V}${C}(${V})?" . '$';  # [C]VC[V] is m=1
   $mgr1 = "^(${C})?${V}${C}${V}${C}";       # [C]VCVC... is m>1
   $_v   = "^(${C})?${v}";                   # vowel in stem

}

################################### END OF PORTER STEMMER's SUBS ###################################

################################### FUN STARTS HERE ###################################

#shows absolute path
print "script's path : ";
print abs_path($0)."\n\n";

#below is if I would need to convert backslash into forwardslash, # is a delimeter in the substitution function
#$LOCINLES =~ s#\\#\\\\#g;
print "Enter absolute path of stop list file> ";
chomp(my $LOCSTIST = <STDIN>);
#stoplist filename
my $stplst_filenm = basename($LOCSTIST);

#different to nmeofstoplist,this is for a check in readfile, so stoplist doc does not save to the TOKEN HASH
$nmeofstoplist=$stplst_filenm;
$nmeofstoplist =~ s/.txt$//;
$nmeofstoplist =~ s/\s//;

readfile("$LOCSTIST","$stplst_filenm");
print "\n";
printf "stop words : %s", $nameofstoplist;
print "\n\n";

print "Enter absolute path of input text files> ";
chomp(my $LOCINLES = <STDIN>);
#negates the new-line char
print "\n";
print "e.i. output file must be an absolute directory location";
print "\n";
print "Enter desired location of file output.txt> ";
chomp(my $LOCOUPUT = <STDIN>);


print "\nProcessing ..  \n";
#Although Unix's Forward-slash constrasts Win's Back-slash superficially, 
#looks aside, perl knows that it could associate them together as they are one and the same
#Open location of input directory
#opendir my $DIR_HANDLE,"$LOCINLES" or die "Unable to open directory : $!";
opendir my $DIR_HANDLE,"$LOCINLES" or die "Unable to open directory : $!";

#Open location of input directory
#Access all **.txt files from DIR/location and put each into GLOBALHASH INFILE as KEYS
	# (^assert position at start of the string)(.+ matches any character (except newline))
	# Quantifier: + Between one and unlimited times, as many times as possible, 
	# txt matches the characters txt literally (case sensitive) (assert position at end of the string$)
%INFILEHASH = grep(/^.+.txt$/,readdir($DIR_HANDLE));

closedir $DIR_HANDLE;
#Array which will contain file-name, will be the Document ID of the Inverted Index
my @DOCID = %INFILEHASH;

foreach my $file_name (@DOCID)
{
	#on each access of a **.txt file, do below
    readfile("$LOCINLES/$file_name",$file_name);
	
}#END foreach

################################### READ A QUERY ###################################

print "\n";
print "Enter a query> ";
chomp(my $QUERY = <STDIN>);

print "$QUERY";
print "\n";
################################### CREATE TOKENS FROM DOCUMENT FILES USING HASH ###################################

#In this case using HASH is convenient since the INVERTED INDEX require unique tokens, although with frequencies

#INIT PORTER STEMMER
initialiseporter();
#FOR EACH DOCUMENT
foreach my $file_name (@DOCHA){
	my @bodyofword = split / /, $DOCHASH{"$file_name"};
	my @stoplist = split / /, $nameofstoplist;
	
	foreach my $bow (@bodyofword){
		#check last character in string if (, . : ")
		# 3 times so string))) or string;;; vanishes
		
		$bow=mistemming($bow);
		
		#used perl's smartmatching (~~, if bdwd matches an element in stopword 
		#consider bdwd irrelevant
		#program only checks lowercased strings/word
		if(lc $bow ~~ @stoplist){
		}#END if
		#if any match do not put into Token Data Structure 
		
            elsif(lc $bow ~~ "&"){}
            elsif(lc $bow ~~ "("){}
            elsif(lc $bow ~~ "+"){}
            elsif(lc $bow ~~ "-"){}
            elsif(lc $bow ~~ ""){}
            elsif(lc $bow ~~ " "){}
            
		else{
			my $word = stem(lc $bow);
			#INITIALIZE ALL TOKEN VALUE
			$TOKENHASH{$word} = defined;
			
		}#END else
	}#END foreach - Body of Text
}#END foreach - DOCID


################################### LET THERE BE FREQUENCIES ###################################

my @arraytxtcatcher=();
my @arraylinecatcher =();
#A HASH to control the increment of tokens in the documents
my %FLAGGED=();
#initialized flag to null foreach TOKEN
foreach my $k (keys %TOKENHASH)
{
	$FLAGGED{$k}=defined;
}
# Token frequency buffer of each Document ID
#HASH WHICH WILL DETERMINE THE VALUE OF A FREQUENCY, which is CORRELATED to a TOKEN and DOCID
#This one does not need initialization, initialization happens below (set to 1)
my %FREQASH=();


#FOR EACH DOCUMENT
foreach my $doc (@DOCHA){
	#still in this DOC
	my @stoplist = split / /, $nameofstoplist;
	#FOR EACH TEXT BODY IN EVERY DOCUMENT
	foreach my $txt ($DOCHASH{$doc}){
		#text-body-buffer value return to null;
		@arraytxtcatcher=();
	
		my @linearray = split/ /, $txt;
		#FOR EACH WORD IN TEXT BODY --- STEM
		foreach my $inword (@linearray){
			#text-line-buffer value return to null;
			@arraylinecatcher =();
		
			$inword=mistemming($inword);
			
			#START OF ANOTHER IF-ELSE with the SAME DEGREE AS ABOVE
			#used perl's smartmatching (~~, if bdwd matches a element in stopword irrelevant
			#function only checks lowercased strings/word
			if(lc $inword ~~ @stoplist){
				#word is irrelevant if smart match finds it compatible
			}#END if
			#DO NOTHING-S 
			
			elsif(lc $inword ~~ "&"){}
			elsif(lc $inword ~~ "("){}
			elsif(lc $inword ~~ "+"){}
			elsif(lc $inword ~~ "-"){}
			elsif(lc $inword ~~ ""){}
			elsif(lc $inword ~~ " "){}
			
			#if INFILE WORD / a word in a document did not match the above
			else{
				#ALL OF THESE IS HAPPENING WHILE PARSING BODY-OF-TEXT in each DOCID
				
				##***stem a word belonging to a key in a DOCUMENT HASH***##
				my $stinword = stem(lc $inword);
				
					#IF & ELSIF DETERMINES FREQUENCY OF TOKEN IN THE DOCUMENTS
					
					#pair freq-value to its appropriate key
					#IF NOT ON THE SAME DOCID,increment Frequency
					if(defined $FLAGGED{$stinword} && $FLAGGED{$stinword} ne $doc){
						#INCREMENT VALUE OF A TOKEN's FREQUENCY, this is checked upon all documents 
						#this assumes that all of tokens are inside of STEMMED DOCUMENTS
						$TOKENHASH{$stinword}++;
						
						#ADD a one to this vector
						#this value is supposedly 1
						$FREQASH{"$stinword$doc"}++;
						#but when traced showed otherwise
						#it seems to work fine
						
						
						#SET value of $FLAGGED{$TOKEN} to DOCID
						#means TOKEN already appeared in current DOCID
						$FLAGGED{$stinword}=$doc;
					
					}
					elsif(exists$FREQASH{"$stinword$doc"} && $FLAGGED{$stinword} eq $doc)
					{
						#if another instance of the token appeared in a document
						$FREQASH{"$stinword$doc"}++;
						
						
					}
				
				push @arraylinecatcher, "$stinword";	
			}#END else
		#put a line coming from the buffer into a, text-body buffer
		push @arraytxtcatcher,"@arraylinecatcher";

		}#END of PARSING-BODY-OF-TEXT for a DOCID
		
	}#END of foreach THE TEXT-BODY of a Document
	
	#save body-of-text to a particular key inside the DOCUMENT HASH
	$DOCHASH{$doc} = "@arraytxtcatcher";
	
}#END foreach (@DOCID)



################################### 6th DAY ###################################

print "\nEnd of Process ..  \n";

################################### SORTING & OUTPUTTING THE PROGRAM ###################################

my %QUANTIFIER;
my $freqinadoc;
my @freqk=();

foreach my $tok (sort keys %TOKENHASH) 
{
	my @freqk=();
	foreach my $doc (@DOCHA)
	{
		my @frek=();
		if($FREQASH{"$tok$doc"})
		{
			$freqinadoc = $FREQASH{"$tok$doc"};
			push @frek, $freqinadoc;
			
		}
			push @freqk, "@frek";
	}
	$QUANTIFIER{$tok}="@freqk";
}#END foreach TOKEN


chdir ($LOCOUPUT) or die "Unable to open directory : $!";

open (my $outfile, ">", "output.txt") or die "Can't open a output file : $!";

print "\nWriting in information in output.txt ..\n";
my %BUPFREQASH=();

#FOR EACH TOKEN MADE
foreach my $tok (sort keys %TOKENHASH) 
{
	printf $outfile "%s --> %s\t\t\t", $tok, $TOKENHASH{$tok};
	
	#FETCH the frequency values for a token, and save it to array freqsi
	my @freqsi = "$QUANTIFIER{$tok}";
	#NOT entirely sure how my $QUANTIFER{$tok}, ended up having spaces in between values
	#it certainly made added few lines to my codes, saves all HASH value to @array
	my @frequencyofatokenperdocid = split / /, "@freqsi";
			
	#FOR EACH ARRAY OF FREQUENCY ASSIGNED TO A TOKEN
	#THE WHOLE REASON I WANT TO PUT THE FREQUENCY INTO AN ARRAY
	#we are currently inside a line of output corresponding to a token
	foreach my $freqotpd (reverse sort @frequencyofatokenperdocid )
	{
		my $flag = 0;
		#TO Assign the appropriate DOCID
		foreach my $doc (@DOCHA)
		{
			#PRINT TO OUTFILE IF
			#FREQUENCY HASH key-value is EQUAL to current FREQUENCY value in SORTION, AND if Flag is false
			if(defined $FREQASH{"$tok$doc"} && $FREQASH{"$tok$doc"} eq $freqotpd && $flag == 0)
			{
				#PRINTING TO OUTFILE
				printf $outfile " %s ",$doc;
				printf $outfile "[%s]",$freqotpd;
				#since this is printing to a output file, puts a threshold to the number of time it is outputted
				$flag = 1;
				#SAVES the key-pair values of FREQUENCY HASH, since it is due for deletion
				#I reckon it might be valuable for assignment 2
				$BUPFREQASH{"$tok$doc"}=$FREQASH{"$tok$doc"};
				#deletes the element in FREQUENCY HASH, so another occurence of the SAME frequency value
				#could be assigned to a different DOCID
				delete $FREQASH{"$tok$doc"};
			}
			
		}
	}
	print $outfile "\n";
}#END foreach TOKEN

print "\nFinish writing on output.txt ..\n";

close($outfile);
my $cwd = getcwd();
chdir($cwd);

################################### END OF ASSIGNMENT1 ###################################