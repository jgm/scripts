#!/usr/bin/perl 
#
# This is a perl implementation of TeXdiff, derived from the original bash
# script created by Robert Maron (robmar@mimuw.edu.pl), available at
# http://www.robmar.net/TexDiff/
#
# it requires the wdiff tools to operate properly.  You may obtain a copy at
#    http://www.robmar.net/TexDiff/wdiff-0.5g.tar.gz
# or 
#    http://www.gnu.org/directory/Text_creation_and_manipulation/Word_processing/wdiff.html
#
# For installation, follow the "Usage" directions given on the TexDiff
# Homepage (reprinted/modified here for convenience):
#
#     * Unpack wdiff sources, then patch it with:
#       patch -d wdiff-0.5g -p1 < patch-wdiff
#     * Compile:
#       cd wdiff-0.5g ; ./configure && make && make install
#     * Copy the script texdiff.pl to /usr/local/bin/
#     * To create sample-diff.tex from sample-old.tex and sample.tex, run:
#       texdiff sample-old.tex sample.tex sample-diff.tex
#     * generate the PDF or PS file using one of the following:
#       dvipdfm sample.tex
#         or
#       dvips sample.tex
#
# $ Version: 0.1;  Date: 7/16/02 $

use strict;

my ($in1,$in2,$out) = @ARGV;

print "tex-word-diff( $in1, $in2 ) > $out\n";

write_temp($in1,'tmp1.'.$$);
write_temp($in2,'tmp2.'.$$);

my $buf = "%%% preamble included from $in2:\n"; 
$buf .= read_preamble($in2);

# print `bash /home/temp/TexDiff/texdiff tmp1 tmp2 tmp3`;
my $cmd_opts = ("--avoid-wraps ".
                "--start-delete=\'\\TLSdel{\' --end-delete=\'}\' ".
                "--start-insert=\'\\TLSins{\' --end-insert=\'}\' ".
                "tmp1.$$ tmp2.$$");
$buf .= `/usr/bin/wdiff $cmd_opts`;
# $buf .= system('wdiff',split(/\s/,$cmd_opts));

# add in the texdiff stuff (included at the end of this script) to the preamble
my $addon;
{local ($/); undef $/; $addon .= <DATA>;}
$buf =~ s/(\\begin\{document\})/$addon$1/;

# make sure that the author-thanks argument is contiguous.
my $tmp = $1 if $buf =~ m/(\\thanks\{.*?\})/s;
$tmp  =~ s/\n\s+/\n/sg;
$buf =~ s/\\thanks\{.*?\}/$tmp/s; 

# ifthenelse fails with TLSins
$buf =~ s/\\TLS(ins|del)\{(\\ifthenelse[\{\}\\\w]+)\}/$2/sg;

# ... as do figures and tables
$buf =~ s/\\TLSdel\{(\\begin\{(figure|table).*)\}//g;
$buf =~ s/\\TLSins\{(\\begin\{(figure|table).*)\}/$1/g;

# ... and the bibliography, graphics, (and most other commands)
foreach my $term ( qw( biblio includegraphics setboolean cite ) ) {
    $buf =~ s/\\TLSdel\{(\{?\\$term.*?)\}?\}\n?//g;
    $buf =~ s/\\TLSins\{(\{?\\$term.*?)\}?\}/$1/g;
}
# comment out any ins/del commands that have comments...
$buf =~ s/(\\TLS(ins|del)\{.*?\%.*?\})/% $1/g;

# swap all new-line commands out of the highlight 
# $buf =~ s!\\TLS(ins|del)\{(.*?)\\\\(.*?)\}!\\TLS$1\{$2$3\} \\\\!sg;

# foreach my $k (sort keys %h) {
#     my %l = %{$h{$k}};
#     print "***\n".$l{'old'}."***\n";
#     print "+++\n".$l{'new'}."+++\n";
# }

# remove any blank lines that are marked as del or ins
$buf =~ s/\\TLS(ins|del)\{\s*\}//g;

### merge multi-line inserts and deletes:
my @a=(0..9,'a'..'z','A'..'Z');
my $newline = map { $a[int rand @a] } (0..16);
while ( $buf =~ s/(\n\\TLSins\{)([^\%\n]*)\}\n\\TLSins\{([^\%])/$1$2$newline        $3/sg ) {}
while ( $buf =~ s/(\n\\TLSdel\{)([^\%\n]*)\}\n\\TLSdel\{([^\%])/$1$2$newline        $3/sg ) {}
$buf =~ s/$newline/\n/g;

if ( open(O,">$out") ) {
    print O $buf; close(O);
} else {
    print STDOUT $buf;
}

unlink('tmp1.'.$$);
unlink('tmp2.'.$$);

sub read_preamble {
    my ($file,$out) = @_;

    open(I,"<$file")  or return("can't open $file: $!\n");
    my $flag = 1;
    my $str;
    while (<I>) {
        $flag = 0 if (m/begin\{document\}/);
        $str .= $_ if $flag;
    }
    close I;

    # the 'doublespace' package doesn't work with the 'color' package, so
    # swap it out with a work-around:
    my $wa = join("\n",' ',
                  '%% texdiff comment:',
                  '%% swapped \'doublespace\' package out with workaround:',
                  '\newcommand{\singlespace}{\linespread{1.0}}',
                  '\newcommand{\doublespace}{\linespread{2.0}}',
                  '\linespread{2.0}',
                  '%% end workaround'
                  );
    $str =~ s/\\usepackage\{doublespace}/$wa/;
return $str;
}

sub write_temp {
    my ($file,$tmp) = @_;

    open(O,">$tmp") or return("can't open $tmp: $!\n");
    open(I,"<$file") or return("can't open $file: $!\n");
    my $flag = 0;
    my $picky_env;
    while (<I>) {
        $flag = 1 if (m/begin\{document\}/);
#         $picky_env = $1 if (m/begin\{(equation|displaymath|eqnarray|figure)/);
#         undef($picky_env) if (m/end\{$picky_env/);
#         $_ =~ s/\%.*$//e ;
#         next if ( ($picky_env) and ( m/^\s+$/) ) ;
        print O if ($flag);
        $flag = 0 if (m/end\{document\}/);
    }
    close I;
    close O;
}


#
# (c) Copyright 2002 by W. Scott Hoge (shoge@ieee.org). 
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#  
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
# You may also obtain a copy at http://www.gnu.org/copyleft/gpl.html
#
# Help support Free Software.  The code is shared in the hopes of
# making the computing world a little better.  If you find it useful,
# consider giving a donation (in code, time, or money) to the Free
# Software or Open Source project of your choice.

__DATA__
%%%% begin: texdiff preamble additions to show changes in compiled latex docs

\RequirePackage[normalem]{ulem}
\RequirePackage{color}

\newcommand\TLSins[1]{
\textcolor{blue}{\uline{#1}}%
}

\newcommand\TLSdel[1]{
\textcolor{red}{\sout{#1}}%
}

%%%% end: texdiff preamble additions
