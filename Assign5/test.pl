my $string = " 11\\09\\1990 ";

if($string =~ m/(\s[0-9]{1}[0-2]?\\\d{2}\\\d{4})/ig) 
{
	print $1;
}
else
{
	print "no match";
}