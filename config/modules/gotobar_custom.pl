# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/gotobar.pl">gotobar.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Gotobar_Extension">Gotobar Extension</a></p>';

use vars qw($GotobarName);

# Include this page on every page:

$GotobarName = 'GotoBar';

# do this later so that the user can customize $GotobarName
push(@MyInitVariables, \&GotobarInit);

sub GotobarInit {
    $GotobarName = FreeToNormal($GotobarName); # spaces to underscores
    $AdminPages{$GotobarName} = 1;
    if ($IndexHash{$GotobarName}) {
        OpenPage($GotobarName);
        return if $DeletedPage && $Page{text} =~ /^\s*$DeletedPage\b/o;
        # Don't use @UserGotoBarPages because this messes up the order of
        # links for unsuspecting users.
        @UserGotoBarPages = ();
        $UserGotoBar = '';
        my $count = 0;
        $UserGotoBar = ToString(sub { ApplyRules($Page{text}, 1, 1) });
    }
}
