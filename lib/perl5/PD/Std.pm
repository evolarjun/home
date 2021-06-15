package PD::Std;
use strict;
use warnings;
use Exporter;
use Carp qw(carp croak);
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(biosampleregex uniq in revcomp);
# use lib '/home/aprasad/lib/perl5';
# use GTB::File qw(Open);

our ($VERSION) = (q$Revision: 1.7 $ =~ /(\d+)/);

=head1 NAME

PD::Std standard library for Pathogen Detection project for scripts by Arjun Prasad

=head1 SYNOPSIS

    use PD::Std;
    my $str = 'SAMN03269424.SRR1791294.depth.gz';
    my @biosamples = biosampleregex($str);
    my @unique = uniq(@array);

=head1 DESCRIPTION

Standard library functions:
biosampleregex - get all substrings that look like a biosample

=head1 METHODS

=head2 biosampleregex

1. In array context it will return all biosamples in all argument strings;
2. In scalar context with arguments it will return the number of biosamples in all argument strings;
3. In scalar context without arguments it will return a regex that matches biosamples;

  Usage: my @biosamples = biosampleregex($string1, $string2);
         my ($biosample) = biosampleregex($string);
         my $biosampleregex = biosampleregex();

=cut

our $bsregex = qr#SAM[END][A0-9]\d{6,10}#;

sub biosampleregex {
    my @str = @_;
    my @samples;
    for my $str (@str) {
        push @samples, $1 while ($str =~ m/($bsregex)/g);
    }
    if (wantarray() or @_ > 0) {
        return @samples;
    } else {
        return $bsregex;
    }
}

=head2 uniq

  Usage: my @unique = uniq(@redundant);

=cut

sub uniq { 
    my %h = map { $_ => 1 } @_;
    return keys %h;
};

=head2 in

Is the first argument in any of the other arguments

  Usage: if (in('element', @array)) { ... # element is in array }

=cut

sub in {
    my $element = shift @_;
    my @list = @_;
    foreach (@list) {
        if ($element eq $_) {
            return 1;
        }
    }
    return 0;
}

=head2 revcomp

Reverse complement a DNA sequence.

    Usage: $revcomp = revcomp('ATGGTGCTGTAA');

treats U like T, so to revcomp RNA do:

    $revcomp = revcomp("AUGGUGCUGUAA");
    $revcomp =~ tr/Tt/Uu/;
    
=cut

sub revcomp {
    my $seq = shift;
    $seq =~ tr/ACTGUactgu/TGACAtgaca/;
    return(reverse($seq));
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
reliability of the software and data, the National Library of Medicine
(NLM) and the U.S. Government does not and cannot warrant the
performance or results that may be obtained by using this software or data.
NHGRI and the U.S. Government disclaims all warranties as to performance,
merchantability or fitness for any particular purpose. 

In any work or product derived from this material, proper attribution of the
authors as the source of the software or data should be made, using "NCBI
Pathogen Detection Project" as the citation. 

=cut

1;
