#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2014.04.14 @ UT Austin
##
## - input:
##   1. ip: the ip that collected the trace (the target client device)
##
## - output:
##
## - e.g.
##   perl tshark_cmd.testbed.pl 2013.07.11.HTC.video.2min 10.0.2.5
##   perl tshark_cmd.testbed.pl 2013.07.11.HTC.web.2min 10.0.2.5
##   perl tshark_cmd.testbed.pl 2013.07.12.iPhone.facebook 10.0.2.4
##   perl tshark_cmd.testbed.pl 2013.07.12.iPhone.fc2video 10.0.2.4
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung_iphone.web_video 10.0.2.7 2013.07.12.iphone.web_video
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung_iphone.web_video 10.0.2.8 2013.07.12.Samsung.web_video
##   perl tshark_cmd.testbed.pl 2013.10.14.iphone.tr4.video 10.0.2.4
##   perl tshark_cmd.testbed.pl 2013.10.14.iphone.tr5.web 10.0.2.4
##   perl tshark_cmd.testbed.pl 2013.10.30.mac.chrome 192.168.0.5
##   perl tshark_cmd.testbed.pl 2013.10.30.mac.youtube 192.168.0.5
##   perl tshark_cmd.testbed.pl 2013.10.30.windows.ie 192.168.0.2
##   perl tshark_cmd.testbed.pl 2013.10.30.windows.youtube 192.168.0.2

##   perl tshark_cmd.testbed.pl 2013.07.11.HTC.iperf.2min 10.0.2.5
##   perl tshark_cmd.testbed.pl 2013.07.11.Samsung.iperf.2min 10.0.2.8
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung.iperf_again 10.0.2.8
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung.iperf_client 10.0.2.8
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung.iperf_dual 10.0.2.8
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung_iphone.fc2video_iperf 10.0.2.8 2013.07.12.Samsung.fc2video_iperf
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung_iphone.fc2video_iperf 10.0.2.4 2013.07.12.iphone.fc2video_iperf
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung_iphone.web_youtube 10.0.2.8 2013.07.12.Samsung.web_youtube
##   perl tshark_cmd.testbed.pl 2013.07.12.Samsung_iphone.web_youtube 10.0.2.7 2013.07.12.iphone.web_youtube
##   perl tshark_cmd.testbed.pl 2013.07.15.Samsung.facebook 10.0.2.8
##   perl tshark_cmd.testbed.pl 2013.07.17.iPhone.iperf_client.intermediate_node_wired 192.168.4.78
##   perl tshark_cmd.testbed.pl 2013.07.17.iPhone.iperf_client.intermediate_node_wireless 10.0.2.4
##   perl tshark_cmd.testbed.pl 2013.10.14.iphone.tr1.iperf 192.168.1.7
##   perl tshark_cmd.testbed.pl 2013.10.14.iphone.tr2.iperf 192.168.1.7
##   perl tshark_cmd.testbed.pl 2013.10.14.iphone.tr3.iperf 10.0.2.4

##   perl tshark_cmd.testbed.pl belch2umass-201201022-1.80 128.119.245.80 x /scratch/cluster/yichao/tethering_detection/data/umass_cellular/pcap/belch
##   perl tshark_cmd.testbed.pl belch2umass-20121015-1.43 128.119.245.43 x /scratch/cluster/yichao/tethering_detection/data/umass_cellular/pcap/belch
##   perl tshark_cmd.testbed.pl belch2umass-20121015-1.57 128.119.245.57 x /scratch/cluster/yichao/tethering_detection/data/umass_cellular/pcap/belch
##   perl tshark_cmd.testbed.pl belch2umass-20121024-1.90 128.119.245.90 x /scratch/cluster/yichao/tethering_detection/data/umass_cellular/pcap/belch

##
##########################################

use strict;
use lib "../utils";

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output


#############
# Constants
#############


#############
# Variables
#############
my $input_dir  = "/scratch/cluster/yichao/tethering_detection/data/testbed/tcp_traces/pcap";
# my $input_dir  = "/scratch/cluster/yichao/tethering_detection/data/umass_cellular/pcap/belch";
my $output_dir = "../processed_data/subtask_parse_testbed/tshark";
my $output_file;

my $ip;
my $filename;

#############
# check input
#############
if(scalar(@ARGV) < 2) {
    print "wrong number of input: ".@ARGV."\n";
    print join("\n", @ARGV)."\n";
    exit;
}
$filename = $ARGV[0];
$ip = $ARGV[1];
if(@ARGV == 3) {
    $output_file = $ARGV[2];
}
elsif(@ARGV == 4) {
    $input_dir = $ARGV[3];
    $output_file = $filename;
}
else {
    $output_file = $filename;
}


if($DEBUG2) {
    print "input:\n";
    print "  device ip: $ip\n";
    print "  input dir: $input_dir\n";
    print "  trace file: $filename\n";
}


#############
# Main starts
#############


## clear output file
if(-e "$output_dir/$output_file.txt") {
    my $cmd = "rm \"$output_dir/$output_file.txt\"";
    `$cmd`;
}
if(-e "$output_dir/$output_file.txt.bz2") {
    my $cmd = "rm \"$output_dir/$output_file.txt.bz2\"";
    `$cmd`;
}


## decompress
# print "  decompress pcap file\n" if($DEBUG2);
# my $cmd = "gunzip \"$input_dir/$filename.gz\"";
# `$cmd`;


## tshark 
print "  run tshark\n" if($DEBUG2);
my $cmd = "tshark -r \"$input_dir/$filename.pcap\" -R \"ip.src == $ip\" -T fields -E separator=\\\| -e frame.number -e frame.time_epoch -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e ip.id -e ip.ttl -e tcp.options.timestamp.tsval -e tcp.options.timestamp.tsecr -e tcp.window_size_scalefactor -e tcp.option_kind -e http.user_agent -e tcp.analysis.bytes_in_flight > \"$output_dir/$output_file.txt\"";

print "    > ".$cmd."\n";
`$cmd`;


## compress pcap file
# print "  compress pcap file\n" if($DEBUG2);
# $cmd = "gzip \"$input_dir/$filename.pcap\"";
# `$cmd`;


## compress output file
print "compress output file\n" if($DEBUG2);
my $cmd = "bzip2 \"$output_dir/$output_file.txt\"";
`$cmd`;


