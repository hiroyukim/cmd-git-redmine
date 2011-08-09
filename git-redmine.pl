#!/usr/bin/env perl
# see 
# git clone git://github.com/coiled-coil/git-redmine.git
# http://www.redmine.org/projects/redmine/wiki/Rest_Issues
# http://www.redmine.org/projects/redmine/wiki/Rest_Issues#Creating-an-issue
use strict;
use warnings;
use LWP::UserAgent;
use Getopt::Long;
use URI;
use URI::Escape;
use JSON::XS;
use Text::ASCIITable;
use Encode;

my $API_KEY = do {

    open( my $popen, "git config redmine.apiKey|") or die $!;
    my $row = <$popen>;
    chomp $row;

    unless( $row ) {
        print "Please configure Redmine API key using:\n";
        print " git config --global redmine.apiKey '<your api key>'\n";
        exit();
    }

    close($popen);

    Encode::decode('utf8',$row);
};

my $PROJECT_URL = do {

    open( my $popen, "git config redmine.projectUrl|") or die $!;
    my $row = <$popen>;
    chomp $row;

    unless( $row ) {
        print "Please configure Redmine URL of the project using:\n";
        print " git config redmine.projectUrl '<project url>'\n";
        exit();
    }

    close($popen);

    Encode::decode('utf8',$row);
};

sub get_issue {
    my ($uri,$id) = @_;

    my $issues_uri = URI->new;
    $issues_uri->scheme($uri->scheme);
    $issues_uri->host($uri->host);
    $issues_uri->path('issues.json');
    $issues_uri->query_form(
        key       => $API_KEY,
    );

    my $url = $issues_uri->as_string;

    my $ua  = LWP::UserAgent->new(agent => 'git-redmine.pl');
    my $res =$ua->get( $url );

    unless( $res->is_success ) {
        die $res->status_line . ' ' . $url;
    }

    my $content = $res->decoded_content;

    return JSON::XS->new->utf8(0)->decode($content);
}

sub run {
    my (@argv) = @_;

    Getopt::Long::GetOptions(
        '--man'          => \my $man,
        '--done-ratio=i' => \my $done_ratio,
        '--status=i'     => \my $status,
    ) or pod2usage(2);
    Getopt::Long::Configure("bundling");
    pod2usage(2) if $man;

    my $uri = URI->new($PROJECT_URL);
}

run(@ARGV) && exit();

__END__

Useage:

    git-redmine.pl [--done-ratio=i] [--status=i]
