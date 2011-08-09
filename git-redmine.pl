#!/usr/bin/env perl
# see 
# git clone git://github.com/coiled-coil/git-redmine.git
# http://yumewaza.yumemi.co.jp/2011/08/git-redmine-integration-using-rest-api-python.html
use strict;
use warnings;
use LWP::UserAgent;
use Getopt::Long;
use URI;
use URI::Escape;
use JSON::Syck;
use Text::ASCIITable;

my $API_KEY = do {

    open( my $popen, "git config redmine.apiKey|") or $!;
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

    open( my $popen, "git config redmine.projectUrl|") or $!;
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

    my $url = sprintf("http://%s/%s/issues/%d.json?key=%s",
        $uri->host,
        $uri->path,
        $id,
        $API_KEY,
    );

    my $ua  = LWP::UserAgent->new(agent => 'git-redmine.pl');
    my $res =$ua->get( $url );

    unless( $res->is_success ) {
        die $res->status_line;
    }

    my $content = $res->decoded_content;

    local $YAML::Syck::ImplicitUnicode = 1;

    return JSON::Syck::Load($content);
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
