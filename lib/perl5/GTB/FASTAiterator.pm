package GTB::FASTAiterator;
use strict;
use warnings;
# Very quick-n-dirty with little error checking. 
# There are some obvious possible optimizations to increase speed and/or
# it could be rewritten to use pchines' Iter.pm

use Carp qw(carp croak);
use GTB::File qw(Open);

our ($VERSION) = (q$Revision: 1 $ =~ /(\d+)/);

=head1 NAME

GTB::FASTAiterator - read FASTA file one entry at a time

=head1 SYNOPSIS

    use GTB::FASTAiterator;
    my $fa = GTB::FASTAiterator->new('filename.fa');
    my($defline, $seq);
    while (($defline, $seq) = $fa->getEntry() and defined($defline)) {
        ... # do stuff
    }

You can also use $fa->getSeqQual if there's a qual file present with the name
of the fasta file with a .qual appended. 

DO NOT MIX CALLS TO getSeqQual WITH CALLS TO getEntry!!! You will get off
register and your quality values will not match up with your sequences.

=head1 DESCRIPTION

Simple FASTA parser when you don't want to load everything into memory, just
returns a FASTA entry at a time.

=head1 METHODS

=head2 new

Create a new FASTAiterator object.

  Usage: my $fa = GTB::FASTAiterator->new('filename.fa');
 Return: FASTAiterator object

Note: You can pass '-' as a filename to read from STDIN.

=cut

sub new {
    ref (my $class = shift) and croak "Constructor only, class name needed for new()";
    my $filename = shift; # filename can be '-' for standard in
    # assume stdin if !$filename, but warn
    if(!$filename) {
        carp('Empty filename passed to FASTAiterator->new() assumed to be STDIN');
        $filename = '-';
    }

    my $self = {};

    # allow iterating through fasta.qual files also
    if ( $filename ne '-') {
        if (-e "$filename.qual") {
            $self->{qualfh} = Open("$filename.qual");
        } elsif (-e "$filename.qual.gz") {
            $self->{qualfh} = Open("$filename.qual.gz");
        } else {
            $self->{qualfh} = undef;
        }
    } else {
        $self->{qualfh} = undef; # avoid warnings
    }

    $self->{filename} = $filename;
    $self->{fh}       = Open($filename);

    bless($self, $class);
    return $self;
}

=head2 getEntry

Grab a FASTA entry

  Usage: ($defline, $sequence) = $fa->getEntry();
 Return: Defline with the leading '>', but no trailing carriage return
         Sequence with any whitespace removed
         On EOF or read error returns undef

=cut

sub getEntry {
    my $self = shift;
    my $fh   = $self->{fh};

    if (! exists($self->{next_defline})) { # this is the first entry
        if (eof($fh)) {
            croak "FASTAiterator.pm error reading FASTA: $self->{filename} appears to be empty";
        }
        $_ = <$fh>;
        if ($_ !~ /^>/) {
            croak "FASTAiterator.pm error reading line $. of $self->{filename}, format doesn't appear to be correct.";
        }
        chomp;
        $self->{next_defline} = $_;
    }

    my $defline = $self->{next_defline};
    $self->{next_defline} = undef;
    my $seq;
    my $line;
    while ($line = <$fh>) {
        if ($line =~ /^>/) {
            chomp($line);
            $self->{next_defline} = $line;
            last;
        } else {
            $line =~ tr/ \t\n//d;
            $seq .= $line;
        }
    }
    if (! defined($defline)) {
        return undef;
    } else {
        return ($defline, $seq);
    }
}

=head2 getSeqQual

Grab a FASTA entry plus quality values from a .qual file

The quality file must be named as the FASTA file with .qual appended

  Usage: ($defline, $sequence, $qual_defline, $ra_qual) 
                = $fa->getSeqQual();
 Return: Defline with the leading '>', but no trailing carriage return
         Sequence with any whitespace removed
         Qual defline (leading '>', but no \n)
         Reference to array of ints for quality values
         On EOF or read error returns undef

=cut

sub getSeqQual {
    my $self = shift;

    if (! defined($self->{qualfh})) {
        croak("Qual file ($self->{filename}.qual) not found, could not return quality values");
    }
    my ($fa_def, $seq, $qual_def, $ra_quals);
    eval { ($fa_def, $seq) = $self->getEntry(); };
        croak ($@) if ($@);
    my $fa_line = $.; # save in case of error
    eval { ($qual_def, $ra_quals) = $self->getQualEntry(); };
        croak ($@) if ($@);
    if (scalar(@$ra_quals) != length($seq)) {
        warn "Error, length of sequence and qual values don't agree at line $fa_line of $self->{filename} and line $. of $self->{filename}.fa";
    }
    return ($fa_def, $seq, $qual_def, $ra_quals);
}

=head2 getQualEntry

Just grab a qual entry, should not be called on its own or you will get
off_register in the qual file. Should really only be called by getSeqQual()

  Usage: ($defline, $ra_qual) = $fa->getSeqQual();
 Return: Defline with the leading '>', but no trailing carriage return
         Reference to array of ints for quality values
         On EOF or read error returns undef

=cut

sub getQualEntry {
    my $self = shift;
    my $fh   = $self->{qualfh};
    croak "No qual file" if (! defined($fh));


    if (! exists($self->{next_qual_defline})) { # this is the first entry
        $_ = <$fh>;
        if ($_ !~ /^>/) {
            croak "Error reading line $., format doesn't appear to be correct.";
        }
        chomp;
        $self->{next_qual_defline} = $_;
    }

    my $defline = $self->{next_qual_defline};
    my @quals;
    $self->{next_qual_defline} = undef;
    my $line;
    while ($line = <$fh>) {
        if ($line =~ /^>/) {
            chomp($line);
            $self->{next_qual_defline} = $line;
            last;
        } else {
            push @quals, map {$_+0} split(/\s+/, $line);
        }
    }
    if (! defined($defline)) {
        return undef;
    } else {
        return ($defline, \@quals);
    }
}

=head1 BLAME

Written by Arjun Prasad

=head1 TODO

I really should add in a way to keep seq and qual entries in sync no matter what
and/or make it so getEntry keeps track and returns qual values if they're around. 

Add a -qual option to new() to force the reading of FASTA + Qual files (die earlier)

=head1 LEGAL

This software is "United States Government Work" under the terms of
the United States Copyright Act.  It was written as part of the authors'
official duties for the United States Government and thus cannot be
copyrighted.  This software is freely available to the public for
use without a copyright notice.  Restrictions cannot be placed on its present
or future use. 

Although all reasonable efforts have been taken to ensure the accuracy and
reliability of the software and data, the National Human Genome Research
Institute (NHGRI) and the U.S. Government does not and cannot warrant the
performance or results that may be obtained by using this software or data.
NHGRI and the U.S. Government disclaims all warranties as to performance,
merchantability or fitness for any particular purpose. 

In any work or product derived from this material, proper attribution of the
authors as the source of the software or data should be made, using "NHGRI
Genome Technology Branch" as the citation. 

=cut

1;
