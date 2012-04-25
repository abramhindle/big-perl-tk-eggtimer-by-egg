#!/usr/bin/perl -w
=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Abram Hindle <abram.hindle@softwareprocess.es>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


use POSIX qw(strftime);
use strict;
use Tk;
use Tk::Tiler;

my %minutehash = ();
$minutehash{$_} = "~/scripts/minutes $_" foreach (1..5,10,20,30);
my @modes = ("WORK", "PLAY");
my $mode = $modes[0];
my ($WORK, $PLAY) = @modes;
my @command = @ARGV;
my $main;
my $time = 0; #seconds unix time
my $fired = 1;
my @notfired_options = (
	-background => '#AAFFAA'
);
my @play_notfired_options = (
	-background => '#FFBBAA'
);
my @fired_options = (
	-background => '#FF0000'
);
sub notfired_options {
	if ($mode eq $WORK) {
		return @notfired_options;
	} else {
		return @play_notfired_options;
	}
}
my $title = "Eggtimer (by egg)";
$main = MainWindow->new(-title=>$title,@notfired_options);
my $label = $main->Label(
	-text => "",
	#-font => "-*-terminus-*-r-*-*-32-*-*-*-*-*-*-*",
	-font => "-*-terminus-*-r-*-*-256-*-*-*-*-*-*-*",
);
#$label->pack(-side=>'top');
$label->pack(-anchor=>"center",-fill=>"both");
my $frame = $main->Frame();
my $zerob = $frame->Button(
	-text => "ZERO",
	-command => sub { zero(); update(); }
);
$zerob->pack(-side=>'left');
my $oneb = $frame->Button(
	-text => "1 Minute",
	-command => sub { 
		add(60); 
		update(); 
	}
);
$oneb->pack(-side=>'left');
my $quarter = 5;
my $quarterb = $frame->Button(
	-text => "$quarter Minutes",
	-command => sub { 
		add($quarter*60); 
		update(); 
	}
);
$quarterb->pack(-side=>'left');
my $threequarterb = $frame->Button(
	-text => "45 Minutes",
	-command => sub { 
		add(45*60); 
		update(); 
		update_mode(); }
);
$threequarterb->pack(-side=>'left');
#my $work = $frame->Button(
#	-text => "WORK",
#	-command => sub { 
#		$mode = $WORK;
#		update_widgets( notfired_options() );
#		update_mode();
#	}
#);
#$work->pack(-side=>'left');
#my $play = $frame->Button(
#	-text => "PLAY",
#	-command => sub { 
#		$mode = $PLAY;
#		update_widgets( notfired_options() );
#		update_mode();
#	}
#);


#$play->pack(-side=>'left');
$frame->pack(-side=>'bottom');
$main->repeat(1000, sub { update(); } );
#my @widgets = ($main,$label,$zerob,$frame,$quarterb,$threequarterb,$work,$play);
my @widgets = ($main,$label,$zerob,$frame,$quarterb,$threequarterb);
MainLoop;

sub update_mode {
	if ($mode eq $WORK) {
		system("~/scripts/WORK &"); 
	} elsif ($mode eq $PLAY) {
		system("~/scripts/PLAY &");
	}
}
sub update_widgets {
	my @options = @_;
	foreach (@widgets) {
		$_->configure( @options );
	}
}

sub add {
	my ($add) = @_;
	init_time();
	$time += $_[0];
	$fired = 0;
	update_widgets( notfired_options() );
}
sub zero {
	add(-$time);
	$fired = 1;
}
sub update {
	my $t = time();
	my $diff = $time - $t;
	$diff = ($diff < 0)?0:$diff;
	my $text = sprintf('%02d:%02d'.$/.'%04d seconds',int($diff/60),($diff%60),$diff);
	$label->configure(-text => $text);
	$label->update();
	my $mins = $diff / 60;
	if (exists $minutehash{$mins}) {
		bgrun($minutehash{$mins});
	}
	if ($diff == 0 && $fired == 0) {
		fire();
	}
}
sub fire {
	system("~/scripts/NOT_WORK_OR_PLAY &");
	bgrun(@command);
	$fired = 1;
	foreach (@widgets) {
		$_->configure(@fired_options);
	}
}
sub init_time {
	if ($time == 0 || $time < time()) {
		$time = time();
	}
	return $time;
}
sub bgrun {
	my @ARGS = @_;
	$SIG{CHLD} = "IGNORE";
	my $cid = fork();
	if ($cid == 0) {
		exec(@ARGS);
	}
}
