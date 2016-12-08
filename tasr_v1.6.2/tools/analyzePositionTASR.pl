#!/usr/bin/perl

#   RLW, October 2010/march 2011
#   LICENSE
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.

#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.


use strict;
use Data::Dumper;

if($#ARGV<2){
   die "Usage: $0 <tasr base name> <target file> <required base buffer up/downstream base under scrutiny>\n";
}

my $rf = $ARGV[0] . ".readposition";
my $tf = $ARGV[0] . ".contigs";
my $buffer = $ARGV[2];
my $coord = 0;

my $flag=0;
my $seed = "";
my $track;
my($ct_fwd,$ct_rev,$ct_tot)=(0,0,0,);
my @base;
my $tigseq="";

my $of=$ARGV[1];
open(IN,$of);
my $head="";
my $t;
while(<IN>){
   chomp;
   if(/^\>(\S+)/){
      $head = $1;
   }else{
      $t->{$head}{'seq'}=$_;
      my @a=split(//,$_);
      my $ct=0;
      foreach my $b (@a){
         $ct++;
         $t->{$head}{'coord'} = $ct if($b=~/[acgt]/);
#         print "$head .. $t->{$head}{'coord'}\n";
      }
   }
}
close IN;




open(TIG,$tf) || die "Can't open $tf for reading -- fatal.\n";
my $head ="";

while(<TIG>){
   chomp;
   if(/^\>(\w+)/){
      $head = $1;
   }else{
      $t->{$head}{'tig'} = $_;
   }
}
close TIG;


###FIRST PASS
my $head="";
open(IN,$rf) || die "Can't open $rf for reading -- fatal.\n";
while(<IN>){
   chomp;
   if(/^\>(\w+)/){
      $head=$1;
   }else{
      if(defined $t->{$head}{'coord'}){
        my @a=split(/\,/);
        if($a[1] < $a[2] && $head eq $a[0]){
           my $coord = $a[1] + $t->{$head}{'coord'} - 1;
           $t->{$head}{'adjcoord'} = $coord;
           #print "$head .. $t->{$head}{'adjcoord'} $_\n";

        #}elsif($a[2] > $a[1] && $head eq $a[0]){
        #   $coord = $a[2] + $t->{$head}{'coord'} - 1;
        }
      }
   }
}
close IN;

my $mem="";
###SECOND PASS
my $head= "";
my $prevhead = "";
open(IN,$rf) || die "Can't open $rf for reading -- fatal.\n";
while(<IN>){
   chomp;
   if(/^\>(\w+)/){
     $head=$1; 
     if($prevhead ne "" && defined $t->{$prevhead}{'seq'}){
        my $tenup = substr($t->{$prevhead}{'tig'},$t->{$prevhead}{'adjcoord'}-($buffer+1),$buffer);
        my $tendown = substr($t->{$prevhead}{'tig'},$t->{$prevhead}{'adjcoord'},$buffer);
        my @base = split(//,$t->{$prevhead}{'tig'});
        print "There are $ct_tot reads overlapping the base [$tenup $base[$t->{$prevhead}{'adjcoord'}-1] $tendown] at position $t->{$prevhead}{'adjcoord'} with a $buffer nt base buffer upstream/downstream ($ct_fwd on plus and $ct_rev on reverse) on $prevhead.\nDETAILS:\n";
        print Dumper($track);
        ($ct_fwd,$ct_rev,$ct_tot)=(0,0,0);
        $track={};
     }
     $prevhead = $head;
   }else{
      if(defined $t->{$head}){
         my @a=split(/\,/);
         if($a[0] ne $head && $a[1]<$a[2] && ($t->{$head}{'adjcoord'} >=($a[1]+$buffer) && $t->{$head}{'adjcoord'}<=($a[2]-$buffer ))  ){
            $track->{'fwd'}{$a[0]}{'start'}=$a[1];
            $track->{'fwd'}{$a[0]}{'end'}=$a[2];
            $ct_fwd++;
            $ct_tot++;
         }elsif($a[0] ne $head && $a[1]>$a[2] && ($t->{$head}{'adjcoord'} >=($a[2]+$buffer) && $t->{$head}{'adjcoord'}<=($a[1]-$buffer) )){
            $track->{'rev'}{$a[0]}{'start'}=$a[2];
            $track->{'rev'}{$a[0]}{'end'}=$a[1];
            $ct_rev++;
            $ct_tot++;
         }
      }
   }
}
close IN;

if($prevhead ne "" && defined $t->{$prevhead}{'seq'}){
   my $tenup = substr($t->{$prevhead}{'tig'},$t->{$prevhead}{'adjcoord'}-($buffer+1),$buffer);
   my $tendown = substr($t->{$prevhead}{'tig'},$t->{$prevhead}{'adjcoord'},$buffer);
   my @base = split(//,$t->{$prevhead}{'tig'});
   print "There are $ct_tot reads overlapping the base [$tenup $base[$t->{$prevhead}{'adjcoord'}-1] $tendown] at position $t->{$prevhead}{'adjcoord'} with a $buffer nt base buffer upstream/downstream ($ct_fwd on plus and $ct_rev on reverse) on $prevhead.\nDETAILS:\n";
   print Dumper($track);
}
 
exit;
