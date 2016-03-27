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
use 5.14.2;
use strict;
use warnings;
use File::Basename;
use experimental 'smartmatch';

#use current working directory
use Cwd;
#shows absolute path
use Cwd 'abs_path';
#GlobalHASH - filenames are used as keys, text-content of each files are associated appropriately
my %INFILEHASH = ();
my %TOKENHASH = ();

#open a file specified in the path, and save it into the Global hash
#1st shift is the FILE LOCATION
#2nd shift is the FILE NAME
sub readfile{
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
	#saves the (Array of string / text-body of a file) to the appropriate key in the GlobalHASH
	$INFILEHASH{"$filenm"} = "@filedy";
}#END sub=readfile

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

#shows absolute path
print "script's path : ";
print abs_path($0)."\n\n";
print "Enter location of input text files> ";
chomp(my $LOCINLES = <STDIN>);
#negates the new-line char
#below is if I would need to convert backslash into forwardslash, # is a delimeter in the substitution function
#$LOCINLES =~ s#\\#\\\\#g;
print "Enter location of stop list> ";
chomp(my $LOCSTIST = <STDIN>);
#stoplist filename
my $stplst_filenm = basename($LOCSTIST);
print "Enter desired location of output> ";
chomp(my $LOCOUPUT = <STDIN>);

##readfile($LOCSTIST, $stplst_filenm);
	#local sub variable - holds the file's body of text
	
#Although Unix's Forward-slash constrasts Win's Back-slash superficially, 
#looks aside, perl knows that it could associate them together as they are one and the same
#Open location of input directory
opendir my $DIR_HANDLE,"$LOCINLES" or die "Unable to open directory : $!";

#Access all **.txt files from DIR/location and put each into GLOBALHASH INFILE as KEYS
	# (^assert position at start of the string)(.+ matches any character (except newline))
	# Quantifier: + Between one and unlimited times, as many times as possible, 
	# txt matches the characters txt literally (case sensitive) (assert position at end of the string$)
%INFILEHASH = grep(/^.+.txt$/,readdir($DIR_HANDLE));
closedir $DIR_HANDLE;
#Array which will contain file-name, will be the Document ID of the Inverted Index
my @DOCID = %INFILEHASH;

readfile("$LOCSTIST","$stplst_filenm");
print $INFILEHASH{"$stplst_filenm"}."\n\n";
foreach my $file_name (@DOCID){
	#on each access of a **.txt file, do below
	#print $file_name."\n";
	readfile("$LOCINLES/$file_name",$file_name);
	#print $INFILEHASH{$file_name}."\n\n";
}#END foreach


#INIT VALUES IN PORTER STEMMER#
initialiseporter();
foreach my $file_name (@DOCID){
	my @bodyofword = split / /, $INFILEHASH{"$file_name"};
	#make an ARRAY for the stop words
	my @stoplist = split / /, $INFILEHASH{"$stplst_filenm"};
	#print $file_name."\n";
	foreach my $bow (@bodyofword){
		#STEMMING end part of the string such as ))) or ;;; or :;: or :;) 
		#check last character in string if (, . : " ) )
		# 3 times so string))) or string;;; in those string vanishes
		
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
		
		#print " --> $bow\t";
		#uses Perl's SMARTMATCHING (~~), if bdwd matches a element in stopword it is irrelevant
		#program only checks lowercased strings/word
		if(lc $bow ~~ @stoplist){
			#print "IRRELEVANT STRING $bow\n";
		}#END if
		elsif(lc $bow ~~ ""){}
		elsif(lc $bow ~~ " "){}
		else{
			#if nothing else matched in the stoplist
			#print "RELEVANT $bow ---> Stemmed : ";
			my $word = stem(lc $bow);
			#print $word;
			$TOKENHASH{$word} = "";
			#print "\n";
		}#END else

	}#END foreach - Body of Text
}#END foreach - DOCID

################################### STEM INFILEHASH PER WORD ###################################

my @arraytxtcatcher=();
my @arraylinecatcher =();
my @tokens = %TOKENHASH;
my $unduplicater = 0;

#FOR EACH DOCUMENT
foreach my $doc (@DOCID){
	my @stoplist = split / /, $INFILEHASH{"$stplst_filenm"};
	
	#FOR EACH TEXT BODY IN EVERY DOCUMENT
	foreach my $txt ($INFILEHASH{"$doc"}){	
		$unduplicater = 0;
		#text-body-buffer value return to null;
		@arraytxtcatcher=();
		#split the text-body into individual word
		my @linearray = split / /, $txt;
		#FOR EACH WORD IN TEXT BODY --- STEM
		foreach my $inword (@linearray){
			#text-line-buffer value return to null;
			@arraylinecatcher =();
			#I will probably make a sub of my for-loop but ran out of time
			for (my $i=0; $i < 3 ; $i++){
				#STEMMING start part of the string such as ) or ; or & or [
				my $stchar = substr($inword,0,1);
				if($stchar eq '('){
					my $wob=(reverse($inword));
					$inword=chop($wob);
				}
				elsif($stchar eq '['){
					my $wob=(reverse($inword));
					$inword=chop($wob);
				}
				elsif($stchar eq '{'){
					my $wob=(reverse($inword));
					$inword=chop($wob);
				}
				elsif($stchar eq '"'){
					my $wob=(reverse($inword));
					$inword=chop($wob);
				}
				elsif($stchar eq '+'){
					my $wob=(reverse($inword));
					$inword=chop($wob);
				}
				elsif($stchar eq '-'){
					my $wob=(reverse($inword));
					$inword=chop($wob);
				}
				elsif($stchar eq '&'){
					my $wob=(reverse($inword));
					$inword=chop($wob);
				}
			}#END forx3
			for (my $i=0; $i < 3 ; $i++){
				my $lchar = substr($inword, -1);
				if($lchar eq '.'){
					chop($inword);
				}
				elsif($lchar eq ':'){
					chop($inword);
				}
				elsif($lchar eq ','){
					chop($inword);
				}
				elsif($lchar eq '"'){
					chop($inword);
				}
				elsif($lchar eq ']'){
					chop($inword);
				}
				elsif($lchar eq '}'){
					chop($inword);
				}
				elsif($lchar eq ')'){
					chop($inword);
				}
				elsif($lchar eq ';'){
					chop($inword);
				}
				elsif($lchar eq '/'){
					chop($inword);
				}
			}#END 3xfor-loop
			
			#AGAIN PERL's SMARTMATCHING function is pivotal in this program
			#program only checks lowercased strings/word
			if(lc $inword ~~ @stoplist){
				#word is irrelevant if smart match finds it compatible
			}#END if
			elsif(lc $inword ~~ ""){}
			elsif(lc $inword ~~ " "){}
			else{
				#stem a word belonging to a key in a INHASH
				my $stinword = stem(lc $inword);
				if(defined $TOKENHASH{$stinword}){
					#print "$stinword\n";
					if($unduplicater==1)
					{
						#DO NOTHING;
					}
					else
					{
						$unduplicater = 1;
						$TOKENHASH{$stinword}++;
					}
				}
				#put it on a line buffer
				push @arraylinecatcher, "$stinword";	
			}#END else
		#put a line coming from the buffer into a, text-body buffer
		push @arraytxtcatcher,"@arraylinecatcher";
		}#END foreach linearray
	}#END foreach my $line 
	#save body-of-text to a particular key inside the INFILEHASH
	$INFILEHASH{$doc} = "@arraytxtcatcher";
}#END foreach (@DOCID)

#debugging
#foreach my $docid (%INFILEHASH){
#	print $INFILEHASH{$docid};
#	print "\n";
#	}#END foreach INFILE

################################### END OF INFILE STEMMING ###################################

################################### OUTPUTTING THE PROGRAM ###################################

chdir ("$LOCOUPUT") or die "Unable to open directory : $!";
open (my $outfile, ">", "output.txt") or die "Can't open a output file : $!";

my %FREQASH=();
# Token frequency buffer of each Document ID
my @freks=();
my @txtbooty=();
my $frq=0;
foreach my $tok (sort keys %TOKENHASH) 
{
	printf $outfile "%s --> %s\t\t\t", $tok, $TOKENHASH{$tok};
	printf "%s --> %s\t\t\t", $tok, $TOKENHASH{$tok};
	#@freks=();
	foreach my $docid (@DOCID)
	{
		@freks=();
		$frq =0;
		foreach my $txtbod ($INFILEHASH{$docid})
		{
			my @txtbooty = split / /,$txtbod;
			foreach my $word (@txtbooty)
			{
				if($word eq $tok)
				{
					$frq++;
				}
			}
		}
		print $outfile "/s/";
		if($frq!=0) # Means no match with the current token
		{
			#array buffer to save frequency of a DOCID
			#push @freks,$frq;
			print $outfile "$docid";
			#sort using SPACESHIP OPERATOR for the whole freq value for an instance of Document
			#print $outfile " --> $frq ";
			push @freks, $frq;
			
			
			foreach my $freqv (sort { $a <=> $b } @freks)
			{
				print $outfile " ";
				print $outfile $freqv;
				print $outfile "\t";
			}
		}
	}
	print "\n";
	print $outfile "\n";
}#END foreach TOKEN

close($outfile);
my $cwd = getcwd();
chdir($cwd);

################################### END OF ASSIGNMENT1 ###################################