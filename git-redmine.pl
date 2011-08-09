#!/usr/bin/env perl
# see 
# git clone git://github.com/coiled-coil/git-redmine.git
# http://yumewaza.yumemi.co.jp/2011/08/git-redmine-integration-using-rest-api-python.html
use strict;
use warnings;
use LWP::UserAgent;
use Getopt::Long;
use File::Temp qw/tempfile tempdir/;
use URI;
use URI::Escape;
use File::HomeDir;
use Path::Class;
use JSON::Syck;
use Text::ASCIITable;

my $GIT_CONFIG = do {
    my $fh = file(File::HomeDir->my_home,'.gitconfig')->openr;

    my $data = {};
    my $title;
    for my $row ( <$fh> ) {
        chomp $row;

        if( $row =~ /^\[(.+)\]$/ ) {
            $title = $1;
        }
        elsif( $row =~ /^[\s\t]+(.*?)\s*=\s*(.+)$/ ) {
            $data->{$title}->{$1} = $2;
        }
    }

    $data;
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
