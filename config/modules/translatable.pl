# Copyright (C) 2015 Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

AddModuleDescription('translatable.pl', 'Translatable Sections Extension');

our ($q, $bol, @MyRules, %RuleOrder, $HtmlHeaders, $CurrentLanguage, $OpenPageName);
our %TranslatableShortLangs = ('en' => 'ENG', 'ee' => 'EST', 'ru' => 'RUS');
our @TranslatableLangs = ('ENG', 'EST', 'RUS');
our %TranslatableLangs = ('ENG' => 1, 'EST' => 2, 'RUS' => 3);

push(@MyRules, \&TranslatableWikiRule);
$RuleOrder{\&TranslatableWikiRule} = -70; # before ordered lists
$HtmlHeaders .= '<script type="text/javascript" src="/js/translatable.js"></script>';

my $InTranslation = '';
my $TranslationWithButtons = '';
my $TranslationId = 1;

sub TranslatableWikiButtons {
  my @links;
  for (@TranslatableLangs) {
    my $link = 't-' . $TranslationId . '-' . $TranslatableLangs{$_};
    my $id = $link . '-link';
    push @links, $q->a({-id => $id, -href => '#', -class => 'translation'}, $_); # -href => '#' . $link}, $_);
  }
  return $q->div({-class => 'translation_buttons'}, join '', @links); # TODO
}

sub TranslatableWikiRule {
  if ($bol && m/\G( \# LANG_END \s*\n+ )/cgsx) {
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    print TranslatableClose();
    Clean(AddHtmlEnvironment('p'));
    return '';
  }
  if (InElement('li') && m/\G( [ \t]*\n+[ \t]* \# (?: LANG(_NO_BUTTONS)? \s+ )? (\w+) \s*(\n+|$) )/cgsx
      or $bol         && m/\G(                 \# (?: LANG(_NO_BUTTONS)? \s+ )? (\w+) \s*(\n+|$) )/cgsx) {
    my $buttons = $2 ? '' : 1;
    my $lang = $TranslatableLangs{$3};
    my $curLanguage = $CurrentLanguage || 'en';
    $curLanguage = 'en' unless exists $TranslatableShortLangs{$CurrentLanguage};

    Clean(CloseHtmlEnvironments());
    Dirty($1);
    if (not $InTranslation) {
      $InTranslation = 1;
      $TranslationWithButtons = $buttons;
      print TranslatableWikiButtons() if $TranslationWithButtons;
      print $q->start_div({class => 'translation'});
    } else {
      print $q->end_div();
    }
    my $selected = $3 eq $TranslatableShortLangs{$curLanguage};
    #$selected = ''; # TODO we can't do that unless everything is dirty
    my $class = 'lang ' . $lang . ($selected ? ' selected' : '');
    print $q->start_div({id => 't-' . $TranslationId . '-' . $lang, class => $class});
    Clean(AddHtmlEnvironment('p'));
    return '';
  }
  if (m/\G( \[\[ lang: ([a-z]+) (?: \s+ (.*?) )? \]\] )/cgx) {
    my @params = ();
    push @params, 'id=' . GetId();
    #push @params, 'id=' . GetParam('id') if GetParam('id');
    push @params, 'action=' . GetParam('action') if GetParam('action');
    push @params, "interface=$2";
    Dirty($1);
    print ScriptLink(join(';', @params), $3 || $2);
    return '';
  }
  return;
}

sub TranslatableClose {
  if ($InTranslation) {
    $InTranslation = '';
    $TranslationId++;
    return $q->end_div() . $q->end_div();
  }
  return '';
}

*OldTranslatableWikiCreoleHeadingRule = \&CreoleHeadingRule;
*CreoleHeadingRule = \&NewTranslatableWikiCreoleHeadingRule;
@MyRules = map { $_ == \&OldTranslatableWikiCreoleHeadingRule ? \&XNewTranslatableWikiCreoleHeadingRule : $_ } @MyRules;

push(@MyRules, \&NewTranslatableWikiCreoleHeadingRule);
$RuleOrder{\&XNewTranslatableWikiCreoleHeadingRule} = 1;

# Copied from creole.pl
our ($CreoleHeaderHtmlTag, $CreoleHeaderHtmlTagAttr);

sub NewTranslatableWikiCreoleHeadingRule {
  #return;
  if ($bol and m/\G( (?:\s*\n)* (=+) \s*   ([^\/\n]*?) \s*\/\s* ([^\/\n]*?) \s*\/\s* ([^\/\n]*?)   \s*=*[ \t]*(?:\n|$) )/cgx) {
    my $header_depth = length($2);
    #my $text = $3;
    ($CreoleHeaderHtmlTag, $CreoleHeaderHtmlTagAttr) = $header_depth <= 6
	? ('h'.$header_depth, '')
	: ('h6', qq{class="h$header_depth"}); # TODO these vars are not required
    Clean(CloseHtmlEnvironments() . TranslatableClose()
	  . AddHtmlEnvironment($CreoleHeaderHtmlTag, $CreoleHeaderHtmlTagAttr));
    Dirty($1);

    #my @translations = split(m|\s*/\s*|, $text);
    #if (@translations == 3) {
    my @translations = ($3, $4, $5);
      my $curLanguage = $CurrentLanguage || 'en';
      $curLanguage = 'en' unless exists $TranslatableShortLangs{$CurrentLanguage};
      my $id = $TranslatableLangs{$TranslatableShortLangs{$curLanguage}};
      print(@translations[$id - 1]);
    #}
    Clean(CloseHtmlEnvironment($CreoleHeaderHtmlTag, '^'.$CreoleHeaderHtmlTagAttr.'$')
    . AddHtmlEnvironment('p'));
    $CreoleHeaderHtmlTag = $CreoleHeaderHtmlTagAttr = '';
    return '';
  }
  return;
}

sub XNewTranslatableWikiCreoleHeadingRule {
  #return;
  # header opening: = to ====== for h1 to h6
  #
  # header opening and closing have been partitioned into two separate
  # conditional matches rather than congealed into one conditional match. Why?
  # Because, in so doing, we permit application of other markup rules,
  # elsewhere, to header text. This, in turn, permits insertion and
  # interpretation of complex markup in header text; e.g.,
  # == //This Is a **Level-2** Header %%Having Complex Markup%%.// ==
  if ($bol and m~\G(\s*\n)*(=+)[ \t]*~cg) {
    my $header_depth = length($2);
    ($CreoleHeaderHtmlTag, $CreoleHeaderHtmlTagAttr) = $header_depth <= 6
      ? ('h'.$header_depth, '')
      : ('h6', qq{class="h$header_depth"});
    return CloseHtmlEnvironments() . TranslatableClose() # CHANGED
      . AddHtmlEnvironment($CreoleHeaderHtmlTag, $CreoleHeaderHtmlTagAttr);
  }
  # header closing: = to ======, newline, or EOF
  #
  # Note: partitioning this from the heading opening conditional, above,
  # typically causes Oddmuse to insert an extraneous space at the end of
  # header tags. This is non-dangerous, fortunately; and changes nothing.
  elsif ($CreoleHeaderHtmlTag and m~\G[ \t]*=*[ \t]*(\n|$)~cg) {
    my $header_html =
      CloseHtmlEnvironment($CreoleHeaderHtmlTag, '^'.$CreoleHeaderHtmlTagAttr.'$')
       .AddHtmlEnvironment('p');
    $CreoleHeaderHtmlTag = $CreoleHeaderHtmlTagAttr = '';
    return $header_html;
  }

  return;
}


*OldTranslatableWikiApplyRules = \&ApplyRules;
*ApplyRules = \&NewTranslatableWikiApplyRules;

sub NewTranslatableWikiApplyRules {
  OldTranslatableWikiApplyRules(@_);

  Clean(TranslatableClose());
  FinishFragment();
  our ($FS, @Blocks, @Flags);
  return (join($FS, @Blocks), join($FS, @Flags)); # TODO we are doing it *again*!
}

#*OldTranslatableWikiPrintCache = \&PrintCache;
#*PrintCache = \&NewTranslatableWikiPrintCache;

#sub NewTranslatableWikiPrintCache {
#	OldTranslatableWikiPrintCache(@_);
#	print TranslatableClose();
#}

#*OldTranslatableWikiPrintWikiToHTML = \&PrintWikiToHTML;
#*PrintWikiToHTML = \&NewTranslatableWikiPrintWikiToHTML;

#sub NewTranslatableWikiPrintWikiToHTML {
#	OldTranslatableWikiPrintWikiToHTML(@_);
#	print TranslatableClose();
#}
