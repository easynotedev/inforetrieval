#!/usr/bin/perl

=pod

=head1 TITLE
Name          : invertedindex.pl
Author        : Antonin Karlo M. Tilaon
Course Info   : COSC 4315.001 - Assignment II
Date          : 3/6/2016
=cut

=pod

=head2 ASSUMPTIONS
       : inputs documents and stoplist are .txt files
=cut

=pod

=head2 DESCRIPTION
       : Handles input's to direct input and output paths
       : Prompts the user for a query term. And determine relevance
       : Tolerant Retrieval is present in 1-Term Prompt
       : base on their TF-IDF score
       : Outputs the resulting document list into console
       : Sorted in Decreasing Order
=cut

=pod

=head2 Accreditation
       : Sources online made me aware of Perl function such as 
       : opendir,grep(filename.txt)and save to HASH as key
       : push a string to an array, HANDLES to open directory or file
       : sort array by numeric value using spaceship operator
       : find path using perl's basename function
       : Multidimensional HASH
       : my Man Porter Stemmer (:D)
       : and the Soundex Algorithm which perl conveniently have
       : Adding my understanding of the assignment to these functions
       : Allowed me to piece together a working program
       : stackoverflow.com , perldoc.perl.org, perlmonks.org, cpan.org
       : grateful for Gabor Szabo, Author of perlmaven.com 
       : also I copied BaiGang's implementation of levenshtein distance algo
       : as well as implementing the Soundex algorithm
       : http://tartarus.org/martin/PorterStemmer/perl.txt
       : https://gist.github.com/BaiGang/1321793
=cut

#OUR LAB computers are at least ver 5.18, ACTIVE STATE PERL

use 5.18.0;
use strict;
use warnings;
use File::Basename;
#So i can use catdir function
use File::Spec;
#no warnings 'experimental::smartmatch';
use experimental 'smartmatch';
#use current working directory
use Cwd 'abs_path';
use Cwd;


#The catdir method of the File::Spec module/class can concatenate parts of a file-system path in a platform specific way. 
#Because $0 might contain just the name of the script we first need to ask the currently running perl to calculate the absolute path. 
#We do that using the abs_path method of the Cwd module. Once we have the absolute path, 
#we get rid of the last part of the path which is the name of the file We do that by calling the dirname function of File::Basename 
#Then, as before, we use catdir to go one directory up (..) 
#and then descend to the lib directory.
#i.e.
#use Lib "C:\\Users\\tuffasspc\\Documents\\perl SCRIPTS\\INFOREVASSGN2\\chugsalong\\Lib";

#edit distance minimum function
use List::Util qw(min);
use Soundex;


#GlobalHASH - filenames are used as keys, text-content of each files are associated appropriately
my %INFILEHASH = ();
#STORAGE FOR ALL WORDS IN THE DOCUMENTS
my %UNSTMWORDHASH = ();
#STORAGE FOR STEMMED BODYofWORD(or lines of ) to be compared to tokens
my %STMDOCHASH = ();
my %TOKENHASH = ();
#TOTAL NUMBER of TERMS in a document
my %TOTNURMS= ();
#TRIMMED ID's, without .txt
my @DOCID;
#string to check stoplist name
my $nmeofstoplist="";
#below will be in the stoplist vector
my $nameofstoplist="";
#above is USED in stemming


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
}#END sub=readfile


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

################################### EDIT-DISTANCE SUB / ALGO ###################################

sub edist {

   my ($str1, $str2) = @_;
   my ($len1, $len2) = (length $str1, length $str2);

   if ($len1 == 0) {
       return $len2;
   }
   if ($len2 == 0) {
       return $len1;
   }

   my %mat;

   for (my $i = 0; $i <= $len1; ++$i) {
       $mat{0}{$i} = $i;
       $mat{1}{$i} = 0;
   }

   my @ar1 = split //, $str1;
   my @ar2 = split //, $str2;

   for (my $j = 1; $j <= $len2; ++$j) {
       my $p = $j % 2;
       my $q = ($j + 1) % 2;
       $mat{$p}{0} = $j;
       for (my $i = 1; $i <= $len1; ++$i) {
           my $cost = 0;
           if ($ar1[$i-1] ne $ar2[$j-1]) {
               $cost = 1;
           }
           $mat{$p}{$i} = min($cost + $mat{$q}{$i-1},
               $mat{$p}{$i-1} + 1, $mat{$q}{$i} + 1);
       }
   }

   return $mat{$len2%2}{$len1};
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
print "Enter absolute path of input DIRECTORY, location of input files> ";
chomp(my $LOCINLES = <STDIN>);
#negates the new-line char
print "\n";
print "e.i. output file must be an absolute DIRECTORY location";
print "\n";
print "Enter desired location of file output.txt> ";
chomp(my $LOCOUPUT = <STDIN>);


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
my @DOCTXTID= grep(/^.+.txt$/,readdir($DIR_HANDLE));

closedir $DIR_HANDLE;


#NUMBER OF DOCUMENT VECTOR
my $docno=0;
foreach my $file_name (@DOCTXTID){
    $docno++;
    #on each access of a **.txt file, do below
    readfile("$LOCINLES/$file_name",$file_name);
    
}#END foreach

################################### CREATE TOKENS FROM DOCUMENT FILES USING HASH ###################################
print "\nProcessing ..  \n";
#In this case using HASH is convenient since the INVERTED INDEX require unique tokens, although with frequencies

#INIT PORTER STEMMER
initialiseporter();


my @stoplist = split / /, $nameofstoplist;
#FOR EACH DOCUMENT
foreach my $file_name (@DOCID){
    
    my @bodyofword = split / /, $INFILEHASH{"$file_name"};
   
    #counter for terms in a document
    my $ctr=0;
   
    foreach my $bow (@bodyofword){
        $ctr++;
        #check last character in string if (, . : ")
        # 3 times so string))) or string;;; vanishes
        
        $bow=mistemming($bow);
        
        #used perl's smartmatching (~~, if bdwd matches an element in stopword 
        #consider bdwd irrelevant
        #program only checks lowercased strings/word
        if(lc $bow ~~ @stoplist){
        }#END if
        #DO NOTHING-S
        
        elsif(lc $bow ~~ "&"){}
        elsif(lc $bow ~~ "("){}
        elsif(lc $bow ~~ "["){}
        elsif(lc $bow ~~ "+"){}
        elsif(lc $bow ~~ "-"){}
        elsif(lc $bow ~~ ""){}
        elsif(lc $bow ~~ " "){}
            
            
        else{
            #ASSIGNED TO UNSTEMMED HASH
            $UNSTMWORDHASH{lc $bow}=defined;
            #USE PORTER STEMMER
            my $word = stem(lc $bow);
            #INITIALIZE ALL TOKEN VALUE
            $TOKENHASH{$word} = defined;
            
        }#END else
    }#END foreach - Body of Text
    $TOTNURMS{$file_name}=$ctr;
}#END foreach - DOCID


################################### LET THERE BE FREQUENCIES ###################################

my @arraytxtcatcher=();
my @arraylinecatcher =();
#A HASH to control the increment of tokens in the documents
my %FLAGGED=();
#initialized flag to defined value foreach TOKEN
foreach my $k (keys %TOKENHASH)
{
    $FLAGGED{$k}=defined;
}
# Token frequency buffer of each Document ID
#HASH WHICH WILL DETERMINE THE VALUE OF A FREQUENCY, which is CORRELATED to a TOKEN and DOCID
#This one does not need initialization, initialization happens below (FREQASH..++)
my %FREQASH=();

@stoplist = split / /, $nameofstoplist;
#FOR EACH DOCUMENT
foreach my $doc (keys %INFILEHASH){

    #still in this DOC
    #FOR EACH TEXT BODY IN EVERY DOCUMENT
    foreach my $txt ($INFILEHASH{$doc}){
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
            elsif(lc $inword ~~ "["){}
            elsif(lc $inword ~~ "+"){}
            elsif(lc $inword ~~ "-"){}
            elsif(lc $inword ~~ ""){}
            elsif(lc $inword ~~ " "){}
            
            
            #if INFILE WORD / a word in a document did not match the above
            #THIS IS WHERE the word is stored to a HASH
            else
            {
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
                        #but bugs shows up if set to 1
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
    $STMDOCHASH{$doc} = "@arraytxtcatcher";
    
}#END foreach (@DOCID)



################################### 6th DAY ###################################

print "\nEnd of Process ..  \n";

################################### SORTING & OUTPUTTING THE PROGRAM ###################################

print "\nWriting inverted index into output.txt ..\n";
print "Please wait ..\n";
my %QUANTIFIER;
my $freqinadoc;
my @freqk=();

foreach my $tok (sort keys %TOKENHASH) 
{
    my @freqk=();
    foreach my $doc (%STMDOCHASH)
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
open (my $outfile, ">", "output.txt") or die "Can't open an output file : $!";

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
        foreach my $doc (keys %STMDOCHASH)
        {
            #PRINT TO OUTFILE IF
            #FREQUENCY HASH key-value is EQUAL to current FREQUENCY value in SORTION, AND if Flag is false
            if(defined $FREQASH{"$tok$doc"} 
            && $FREQASH{"$tok$doc"} eq $freqotpd 
            && $flag == 0)
            {
                #PRINTING TO OUTFILE
                printf $outfile " %s ",$doc;
                printf $outfile "[%s]",$freqotpd;
                #since this is printing to a output file, puts a threshold to the number of time it is outputted
                $flag = 1;
                #SAVES the key-pair values of FREQUENCY HASH, since it is due for deletion
                #I reckon it might be valuable for assignment 2
                $BUPFREQASH{$tok}{$doc}=$FREQASH{"$tok$doc"};
                #deletes the element in FREQUENCY HASH, so another occurence of the SAME frequency value
                #could be assigned to a different DOCID
                delete $FREQASH{"$tok$doc"};
            }
            
        }
    }
    print $outfile "\n";
}#END foreach TOKEN

print "\nFinish writing inverted index in output.txt ..\n\n";
close($outfile);
my $cwd = getcwd();
chdir($cwd);

################################### START OF ASSIGNMENT2 ###################################

################################### READ A QUERY ###################################
my %EDITSAVER = ();
#use for prompting
my @keycheck =();
my $QUERY;
my $S_QUERY;
my $itisokay;
my $yes="yes";
do{
	#keep doing if Edit distance HASH is empty
	do {
		print "Type a single-term query> ";
		chomp(my $QUERY = <STDIN>);
		$QUERY = lc $QUERY;
		#create a soundex code
		#IMPLEMENTATION OF TOLERANT RETRIEVAL
		my $S_QUERY = soundex($QUERY);
		
		print "\n";
		print "Checking my Query Indexes .. ";
		print "\n";
		
		#TO BE ABLE TO SORT THE LIST OF WORD where a USER can pick
		
		foreach my $term (sort keys %UNSTMWORDHASH)
		{
		    my $S_term = soundex($term);
		    #match the codes of query and term/token 
		    #if a match add to EDIT DISTANCE HASH 
		    if(defined $S_term 
		    && $S_QUERY eq $S_term)
		    {
		        $EDITSAVER{$term} = edist($QUERY,$term);
		    }
		}
		if(!%EDITSAVER)
		{
			print "No Close Match, Try Again..";
			print "\n\n";
		}
	#while HASH is empty
	}while(!%EDITSAVER);
	
	print "\n";
	print "List of available queries with E-dist : ";
	print "\n";
	
	foreach my $val (sort values %EDITSAVER)
	{
	
	    my ($key) = grep { $EDITSAVER{$_} == $val} keys %EDITSAVER;
	    print $key;
	    delete $EDITSAVER{$key};
	    print "\t";
	    print $val;
	    print "\n";
	    push @keycheck , $key;
	}
	
    print "\n";
    print "Does the list have what you want? < Yes/No > ";
    chomp($itisokay = <STDIN>);
    $itisokay = lc $itisokay;
    
#without user's yes it will keep asking for a new query    
}while($itisokay ne "yes");	


do{
	print "\n";
	print "Enter the exact Query from the list above : ";
	chomp($QUERY = <STDIN>);
	$QUERY = lc $QUERY;
}
#while no database query, matches the entered query (SOUNDEX code is checked)
while( !grep(/^$QUERY$/,@keycheck));
################################### DISPLAY RELEVANCY ###################################

print "\n";
print "Showing Relevant Documents in decreasing order : Query = $QUERY";
print "\n";
print "DOCID\tFrequency of Related Terms\tScores";
print "\n";

$QUERY = stem($QUERY);

################################### ASSGN TF-IDF Scores to $TOKEN-$DOCID relation ###################################
my @scoretallier=();
%QUANTIFIER = ();
my %TFIDFSCORES =();

foreach my $tok (sort keys %TOKENHASH) 
{
    #START IN EACH TOKEN
    foreach my $doc (keys %STMDOCHASH) 
    {
        #WHILE INSIDE A TOKEN, GO-IN EACH DOCID
        #print "\n";
        #print $tok;
        #print " : ";
        #print $doc;
        if( defined $BUPFREQASH{$tok}{$doc} 
        &&  $TOTNURMS{$doc} != 0
        &&  defined $docno
        &&  $TOKENHASH{$tok} != 0 )
        {
            #INTIALIZE to zero for each DOCID
            my $tf=0;
            my $idf=0;
            # TERM FREQUENCY
            #number of times term appears in a document / total number of terms in document
            $tf = $BUPFREQASH{$tok}{$doc} / $TOTNURMS{$doc};
            #total number of documents / number of documents with term=$tok
            $idf = log ($docno/$TOKENHASH{$tok});
            
            $TFIDFSCORES{$tok}{$doc} = $tf * $idf;
         #   print "\t";
         #  print $TFIDFSCORES{"$tok$doc"};
         #   print "\n";
        }  
        #GOING OUT OF A DOCID
    }
    #END IN EACH TOKEN
}

foreach my $doc (keys %STMDOCHASH)
{
    #FOR EACH DOCID 
    
    if(defined $TFIDFSCORES{$QUERY}{$doc})
    {
        push @scoretallier, $TFIDFSCORES{$QUERY}{$doc};
        $QUANTIFIER{$doc} = $TFIDFSCORES{$QUERY}{$doc};
    }
    #END OF A DOCID
}



#SORT THE VALUES
#USED PERL's SPACE OPERATOR to sort the array float
foreach my $score (reverse sort {$a <=> $b} values %QUANTIFIER)
{
   #USED SMARTMATCH to make a KEY correspond into a VALUE
    # my (@doc) = grep {$score == $TFIDFSCORES{$_}} keys %TFIDFSCORES;
    my ($doc) = grep {$score == $QUANTIFIER{$_}} keys %QUANTIFIER;
    print $doc;
    print ".txt";
    print "\t";
    print $BUPFREQASH{$QUERY}{$doc};
    print "\t";
    print $score;
    print "\n";
}

system("pause");