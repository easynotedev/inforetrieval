package Lib::Porterstemmer;
require 5.006;

use strict;
no warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(stem initialiseporter);
our @EXPORT = qw(stem initialiseporter);


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

"Mi amor";