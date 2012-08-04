#!/usr/local/bin/perl

$ARGC = $#ARGV + 1;
if($ARGC != 3 ) {
    print "usage: binTallies.pl <distribution-filename> <max-score> <bin-size> \n";
    print "       e.g.: binTallies.pl discordant.distribution.tsv 260 20\n";
    die;
}

open (SC, "<", $ARGV[0]);
$binScoreRange = $ARGV[2];
$finalEndScore = $ARGV[1];

$startScore = 0;

$binTally = 0;
$currBinStartScore = $startScore;
$currBinEndScore = $currBinStartScore + $binScoreRange;
$binNumber = 0;
$currScore = -1;
print "Start-score(rge=$binScoreRange)\tEnd-score(end=$finalEndScore)\tTally\n";
while (<SC>) {
    $lastScore = $currScore;
    ($currScore, $tally) = split("\t");
    chomp($tally);
    if($currScore > $finalEndScore || ($currBinStartScore <= $currScore && $currScore < $currBinEndScore) ) {
	if($currScore > $finalEndScore  && $lastScore < $finalEndScore) {
	    # The second to last bin doesn't fall on a boundary, so output the total here:
	    print "$currBinStartScore\t$currBinEndScore\t$binTally\n";
	    # start a new bin
	    $currBinStartScore = $finalEndScore;
	    $binTally = $tally;
	    $binNumber++;
	} else {
	    # The current score is still within the current bin (or its inthe final bin)
	    # just add tally to current bin
	    $binTally += $tally;
	}
    } elsif($currScore >= $currBinEndScore) {
	# output bin total:
	print "$currBinStartScore\t$currBinEndScore\t$binTally\n";
	# start a new bin
	$currBinStartScore = $currBinEndScore;
	$currBinEndScore += $binScoreRange;
	$binTally = $tally;
	$binNumber++;
    } else {
	print "Error!\n"; die(); # Should never get here!
    }
#    print "bin=$binNumber: score,tally=($currScore,$tally) binTally=$binTally\n"; #xxx
}

# output last bin (>300) total:
print "$currBinStartScore\t$currScore\t$binTally\n";
