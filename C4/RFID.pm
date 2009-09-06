package C4::RFID;

# Copyright 2008-2009 TTLLP software.coop
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#
# These are helper functions for reading and writing RFID tags like
# http://64.233.183.104/search?q=cache:0CdhriqgCJIJ:www.bs.dk/standards/RFID%2520Data%2520Model%2520for%2520Libraries.pdf

use vars qw($VERSION);
$VERSION='0.02';

use Digest::CRC qw(crcccitt_hex);
use C4::Context;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(ReadBarcode WriteBarcode CheckinBarcode CheckoutBarcode MakeTag ParseTag);

BEGIN {
    if (C4::Context->preference('RFIDEnabled') eq 'TRF7960-SSL') {
        require RFID::TRF7960::Reader::SSL;
    }
# This may go OO later to support multiple reader types
}

# This has various assumptions hardcoded in from our
# first application.  Sorry.

sub ReadBarcode {
    my ($checkedin) = @_;
    my $reader = RFID::TRF7960::Reader::SSL->new(
        PeerAddr=> $ENV{'REMOTE_ADDR'}.':9443',
        Timeout=>5
    );
    my @tags = $reader->readtags();
    if ($checkedin == 1) {
        while ((@tags) && (scalar($tags[0]->get('afi')) ne '9E')) {
            shift(@tags);
        }
    }
    if (@tags) {
        $tags[0]->get('length');
        my $tagdata = ParseTag(scalar($tags[0]->get('data')));
        return $tagdata->{barcode};
    } else {
        return 0;
    }
}

sub WriteBarcode {
    my ($barcode) = @_;
    my $reader = RFID::TRF7960::Reader::SSL->new(
        PeerAddr=> $ENV{'REMOTE_ADDR'}.':9443',
        Timeout=>5
    );
    my @tags = $reader->readtags();
    # overwrite the first and only tag we see...
    if (scalar(@tags) == 1) {
        $tags[0]->get('length');
        $reader->writetag($tags[0],'9E','00',MakeTag(barcode=>$barcode));
        return 1;
    } else {
        return 0;
    }
}

sub ischeckedin {
    my ($barcode) = @_;
    my $tagdata;
    my $reader = RFID::TRF7960::Reader::SSL->new(
        PeerAddr=> $ENV{'REMOTE_ADDR'}.':9443',
        Timeout=>5
    );
    my @tags = $reader->readtags();
    foreach my $tag (@tags) {
        $tag->get('length');
        $tagdata = ParseTag(scalar($tag->get('data')));
        if ($tagdata->{barcode} eq $barcode) {
            return (scalar($tag->get('afi')) eq '9E');
        }
    }
    return -1;
}

sub CheckinBarcode {
    my ($barcode) = @_;
    my $tagdata;
    my $reader = RFID::TRF7960::Reader::SSL->new(
        PeerAddr=> $ENV{'REMOTE_ADDR'}.':9443',
        Timeout=>5
    );
    my @tags = $reader->readtags();
    foreach my $tag (@tags) {
        if ($barcode) {
            $tag->get('length');
            $tagdata = ParseTag(scalar($tag->get('data')));
            if ($tagdata->{barcode} eq $barcode) {
                $reader->writeafi($tag,'9E');
            }
        } else {
            $reader->writeafi($tag,'9E');
        }
    }
    return 1;
}

sub CheckoutBarcode {
    my ($barcode) = @_;
    my $tagdata;
    my $reader = RFID::TRF7960::Reader::SSL->new(
        PeerAddr=> $ENV{'REMOTE_ADDR'}.':9443',
        Timeout=>5
    );
    my @tags = $reader->readtags();
    foreach my $tag (@tags) {
        if ($barcode) {
            $tag->get('length');
            $tagdata = ParseTag(scalar($tag->get('data')));
            if ($tagdata->{barcode} eq $barcode) {
                $reader->writeafi($tag,'9D');
            }
        } else {
            $reader->writeafi($tag,'9D');
        }
    }
    return 1;
}

sub MakeTag {
    my %p = @_;
    my $start =
        chr((($p{version}||1)<<4)+($p{status}||1))
        .chr($p{parts}||1)
        .chr($p{ordinal}||1)
        .$p{barcode}.("\0"x(16-length($p{barcode})));
    my $end =
        ($p{country}||'GB')
        .($p{library}||"\cb12345678");
    return($start
        .pack('H*',crcccitt_hex($start.$end."\0\0"))
        .$end);    
}

sub ParseTag {
    my $data = shift;
    my $barcode = substr($data,3,16);
    $barcode =~ s/\0+$//;
    return {
        'version'=>(ord(substr($data,0,1))>>4),
        'status'=>(ord(substr($data,0,1))&15),
        'parts'=>ord(substr($data,1,1)),
        'ordinal'=>ord(substr($data,2,1)),
        'barcode'=>$barcode,
        'country'=>substr($data,21,2),
        'library'=>substr($data,23,9),
    };
}

1;
