package GTB::FASTQiterator;
use strict;
use warnings;
# Very quick-n-dirty with little error checking. 
# There are some obvious possible optimizations to increase speed and/or
# it could be rewritten to use pchines' Iter.pm

use Carp qw(carp croak);
use Exporter;
use GTB::File qw(Open);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(Qstr2Qval QualOffset);

our ($VERSION) = (q$Revision: 1.1 $ =~ /(\d+)/);

our $QUAL_OFFSET = 33; # standard "sanger style" fastq offset

=head1 NAME

GTB::FASTQiterator - read FASTQ file one entry at a time

=head1 SYNOPSIS

    use GTB::FASTQiterator;
    my $fq = GTB::FASTQiterator->new('filename.fq');
    my($defline1, $seq, $defline2, $qual);
    while (($defline, $seq, $defline2, $qual) = $fq->getEntry() and defined($defline)) {
        ... # do stuff
    }
    # or, if you don't care about quality values
    while (($defline, $seq) = $fq->getEntry() and defined($defline)) {
        ...
    }

=head1 DESCRIPTION

Simple FASTQ parser when you don't want to load everything into memory, just
returns a FASTQ entry at a time.

NOTE: Assumes 4 lines per each fastq entry. Does not handle entries with
wrapping lines.

=head1 METHODS

=head2 new

Create a new FASTQiterator object.

  Usage: my $fq = GTB::FASTQiterator->new('filename.fq');
 Return: FASTQiterator object

Note: You can pass '-' as a filename to read from STDIN.

=cut

sub new {
    ref (my $class = shift) and croak "Constructor only, class name needed for new()";
    my $filename = shift; # filename can be '-' for standard in
    # assume stdin if !$filename, but warn
    if(!$filename) {
        carp('Empty filename passed to FASTQiterator->new() assumed to be STDIN');
        $filename = '-';
    }

    my $self = {};
    $self->{filename} = $filename;
    $self->{fh}       = Open($filename);

    bless($self, $class);
    return $self;
}

=head2 getEntry

Grab a FASTQ entry

  Usage: ($defline, $sequence, $defline2, $qual) = $fq->getEntry();
 Return: Defline with the leading @', but no trailing carriage return
         Sequence with any whitespace removed
         Second defline, including the leading +, but no trailing carriage return
         Qual string, with any whitespace removed.

         On EOF or read error returns undef

=cut

sub getEntry {
    #use autodie;
    my $self = shift;
    my $fh   = $self->{fh};

    my @lines = ('','','','');
    for my $line_no (0..3) {
        return undef unless defined($_ = <$fh>);
        while (/^\s*$/) { 
            return undef unless defined($_ = <$fh>);
        } # skip any blank lines.
        chomp;
        $lines[$line_no] = $_;
    }
    return undef if (! defined($lines[0]));
    if ($lines[0] !~ /^@/) {
        croak "Error reading line ", ($. - 3), ", expecting defline starting with '\@'";
    }
    if ($lines[2] !~ /^\+/) {
        croak "Error reading line ", ($. - 1), ", expecting 2nd defline starting with '+'";
    }
    $lines[1] =~ tr/\t //d;
    $lines[3] =~ tr/\t //d;
    return @lines;
}

=head2 reset

Reset the file pointer to the beginning of the file so we can make another pass.
Basically does what you would mean if you said seek($fq, 0, 0) (which doesn't work).

  Usage: $fq->reset()
 Return: 1 if successful, 0 otherwise

=cut

sub reset {
    my $self = shift;
    seek($self->{fh}, 0, 0);
}

=head2 Qstr2Qval

Convert a quality string to an array of ints of quality values

  Usage: @qvals = Qstr2Qval($qual_str);
 Return: array of quality values

Defaults to using qual value offset of 33 (Sanger style), but that can be
changed with FASTQiterator::QualOffset(<offset>);

=cut

sub Qstr2Qval {
    my $self = shift;

    if (! wantarray()) { 
        carp "Qstr2Qval called in scalar context, it's not designed to be used that way";
    }
    return map { ord($_) - $self->QUAL_OFFSET } split("", $_[0]);
}

# qual offset for Qstr2Qval
sub QualOffset {
    my $self = shift;
    my $val  = shift;
    if (defined($val)) {
        croak("Positive int required") unless ($val =~ /^\d+$/); 
        $QUAL_OFFSET = $val;
    }
    return $QUAL_OFFSET;
}

=head1 BLAME

Written by Arjun Prasad

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

1; # module loaded successfully
