#!/usr/bin/perl

#!/usr/bin/perl

use Data::Dumper;

my @files = @ARGV;

my $d;
my %contigs;

foreach $f (@files) {
	
	my @titles;
	open(IN, $f);
	while(<IN>) {
		chomp();
		@titles = split(/\t/);
		last;
	}

	my $idx = 0;
	foreach $t (@titles) {
		$d->{titles}->{$f}->{$idx} = $t;
		$idx++;
	}

	while(<IN>) {
		chomp();
		my($cn,$cl,$tad,$dep,$v) = split(/\t/);
		$contigs{$cn}++;
		#print "Setting $cn length to $cl\n";
		$d->{$cn}->{length} = $cl;
		$d->{$cn}->{tad}   += $tad;
		$d->{$cn}->{$f}->{depth} = $dep;
		$d->{$cn}->{$f}->{var}   = $v;
	}

	close IN;

}

#print Dumper($d);
#exit;

# print out titles

print "contigName\tcontigLen\ttotalAvgDepth";
foreach $f (@files) {
	print "\t", $d->{titles}->{$f}->{3}, "\t", $d->{titles}->{$f}->{4};
}
print "\n";

foreach $cn (keys %contigs) {
	#print "Processing $cn\n";
	print $cn, "\t", $d->{$cn}->{length}, "\t", $d->{$cn}->{tad};

	foreach $f (@files) {
		if (exists $d->{$cn}->{$f}) {
			print "\t", $d->{$cn}->{$f}->{depth}, "\t", $d->{$cn}->{$f}->{var};
		} else {
			print "\t0.0\t0.0";
		}
	}
	print "\n";
}


