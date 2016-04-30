package Lib::Parse;
require 5.006;

use strict;
no warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(parse);
our @EXPORT = qw(parse);

#destroys casings
sub parse
{
    my %ANSHASH;
    my $string = shift;

	# ?: in (?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) returns the whole REGEX pattern rather than returning only the Month e.g.
	# without the ?: Apr 9, 2023 will only return Apr, because a match was already found.
	# with a ?: the operation will keep going to match the whole expression it will return Apr 9, 2023 as expected
	# the Match expression has insides expression to match any dates
	# it also has an outer parathesis to consolidate all of the inside parathesis, these are divided by | ORS
	# ILLUSTRATION
	
	# match -> m/ ( (first inside exp) | (second inside exp) | (third ..) | .. ) /ig <- match any cases and global
	
	# used \s <- Match whitespace character
	#	   \d <- Match a digit
	#      \d{4} <- Match 4 consecutive digits
	# Below are the Collection of inside expressions
	# first inside expression matches e.g. Apr 9, 2023
	# second inside expression matches e.g. Jul 25, 2007
	# third inside expression matches e.g. April 24, 1854
	# fourth inside expression matches e.g. February 4, 2004
	# Creating spaces inside the regular expression will create errors
	
	while($string =~ m/(((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d,\s\d{4})|((?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{2},\s\d{4})|((?:January|February|March|April|May|June|July|August|September|October|November|December)\s\d{2},\s\d{4})|((?:January|February|March|April|May|June|July|August|September|October|November|December)\s\d,\s\d{4}))/ig) 
	{
		# $1 is the embodiment of the matched expression
		# $1 because the key 
		# value of a key is it's Frequency
		$ANSHASH{$1}+=1;
	}
	
    return %ANSHASH;
}

log exp 1;
__END__

=head1 TITLE
Name          : parse.pl
Author        : Antonin Karlo M. Tilaon
Version       : 1
=cut

=pod

=head2 DESCRIPTION
		: Use a single while loop to efficiently parse the text file
		: The while loop finds any matching regex pattern
		: m/( ( (?:Jan|Feb|..)\s..) | (?:January|February|..) | (Matches this Pattern) | () )/ig 
   		: m -> matches, i -> disregard cases, g -> global match
=pod