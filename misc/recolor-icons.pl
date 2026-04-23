#!/usr/bin/perl -i
# Breach Protocol icon recolor — apply to an already-Papirus-ish icon theme
# Usage:
#   cp -rL ~/.local/share/icons/Papirus ~/.local/share/icons/BreachProtocol-Icons
#   find ~/.local/share/icons/BreachProtocol-Icons -name '*.svg' -type f -print0 | \
#       xargs -0 -n 200 -P $(nproc) perl -i recolor-icons.pl
#   gtk-update-icon-cache -f ~/.local/share/icons/BreachProtocol-Icons
#   gsettings set org.gnome.desktop.interface icon-theme 'BreachProtocol-Icons'

use strict;
use warnings;

my %map = (
    '#FFFFFF'=>'#CFEA65', '#F9F9F9'=>'#C8E35F', '#FAFAFA'=>'#C8E35F',
    '#E4E4E4'=>'#939A4B', '#DFDFDF'=>'#8F9548', '#D2D2D2'=>'#858B44',
    '#CCCCCC'=>'#80864A', '#C0C0C0'=>'#7A8040', '#B7B7B7'=>'#767C3A',
    '#B4B4B4'=>'#737932',
    '#A0A0A4'=>'#666C30', '#9A9A9A'=>'#61662C', '#8E8E8E'=>'#5A6028',
    '#898989'=>'#565B26', '#848484'=>'#545820', '#808080'=>'#50541E',
    '#5D5D5D'=>'#3B3E1A', '#595959'=>'#383C18', '#525252'=>'#343818',
    '#4F4F4F'=>'#333618', '#4D4D4D'=>'#303314', '#444444'=>'#2B2E14',
    '#3F3F3F'=>'#272A10', '#333333'=>'#20220E', '#323232'=>'#1F210D',
    '#2F2F2F'=>'#1E1F0D',
    '#000000'=>'#110F05',
);

my %imap;
for my $k (keys %map) { $imap{lc $k}=$map{$k}; $imap{uc $k}=$map{$k}; }

while (<>) {
    # First pass: HSL hue-based classification for any color
    s/#([0-9a-fA-F]{6})/classify($1)/ge;
    # Second pass: remap specific results
    s/(#[0-9a-fA-F]{6})/exists $imap{$1} ? $imap{$1} : $1/ge;
    print;
}

sub classify {
    my $hex = shift;
    my ($r,$g,$b) = map { hex($_)/255 } ($hex =~ /(..)(..)(..)/);
    my $max = ($r>=$g&&$r>=$b)?$r:(($g>=$b)?$g:$b);
    my $min = ($r<=$g&&$r<=$b)?$r:(($g<=$b)?$g:$b);
    my $l = ($max+$min)/2;
    my ($s,$h) = (0,0);
    if ($max!=$min) {
        my $d = $max-$min;
        $s = $l>0.5 ? $d/(2-$max-$min) : $d/($max+$min);
        if ($max==$r)    { $h = ($g-$b)/$d + ($g<$b?6:0); }
        elsif ($max==$g) { $h = ($b-$r)/$d + 2; }
        else             { $h = ($r-$g)/$d + 4; }
        $h *= 60;
    }
    return "#$hex" if $s < 0.15;
    if ($h < 20 || $h > 340) { return $l<0.3 ? '#8A9500' : '#F5FF2A'; }
    elsif ($h < 160)         { return $l<0.25 ? '#7a8a3a' : '#CFEA65'; }
    else                     { return $l<0.25 ? '#1a5a60' : '#35BBC4'; }
}
