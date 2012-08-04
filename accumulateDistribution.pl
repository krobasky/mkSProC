#!/usr/local/bin/perl

$ARGC = $#ARGV + 1;
if($ARGC != 3 && $ARGC != 4 ) {
    print "usage: accumulateDistributions.pl <distribution-filename> <max-score> <bin-size> [reverse-flag]\n";
    print "        reverse-flag = 1 causes scores to be listed in descending order\n";
    print "       e.g.: accumulateDistributions.pl discordant.distribution.tsv 385 1\n";
    print "       e.g.: accumulateDistributions.pl concordant.distribution.tsv 385 1 1\n";
    die;
}


$binSize = $ARGV[2];
open (SC, "<", $ARGV[0]);
$maxScore = round($ARGV[1]/$binSize);
$reverseFlag = 1;
if($ARGC == 4) {
    $reverseFlag = $ARGV[3];
    if($reverseFlag != 0 && $reverseFlag != 1) {
	print "Error: reverse-flag must be 0 or 1, not '$reverseFlag'\n"; die();
    }
}
$maxScore = 99170;
$binSize = 100;


# init tally array
foreach my $score (0..$maxScore) {
    $tallies[$score] = 0;
}

my @lines = <SC>;
chomp for @lines;

# fill-in array and count the total number of scores
$finalTally = 0;
foreach my $line (@lines) {
    ( $score, $tally ) = split("\t", $line);
    $score = round($score/$binSize);
    $finalTally += $tally;
    $tallies[$score] += $tally;
}

$runningTally = 0;
foreach my $score (0..$maxScore) {
    # compute fraction represented by thresholding at this score
    $runningTally += $tallies[$score];
    $cdf[$score] = $runningTally/$finalTally;
}

if($reverseFlag == 0) {$inverseFlag = 0;}
else                  {$inverseFlag = 1;}

foreach my $invScore (0..$maxScore) {

    if($reverseFlag == 1) { $score = $maxScore - $invScore; }
    else {$score = $invScore;}

    if($inverseFlag == 1) { $fraction = 1 - $cdf[$score]; }
    else {$fraction = $cdf[$score]; }

    print "$score\t$fraction\n";

}

sub round {
    return (sprintf "%.0f", $_[0]);
}
