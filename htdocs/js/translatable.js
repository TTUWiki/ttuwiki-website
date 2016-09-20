"use strict";

function selectLanguage(ev) {
		if (ev.target.classList.contains('missing'))
				return false;
		var prefix = ev.target.id.replace(/\d+-link$/, '');
		for (var lang = 1; ; lang++) {
				var elemId = prefix + lang;
				var link = document.getElementById(elemId + '-link');
				var div  = document.getElementById(elemId);
				if (link === null)
						break;
				if (link !== ev.target)
						link.classList.remove('selected');
				else
						link.classList.add('selected');
				if (div === null)
						continue;
				if (link !== ev.target)
						div.classList.remove('selected');
				else
						div.classList.add('selected');
		}
		return false;
}

document.addEventListener('DOMContentLoaded', function () {
		all:
		for (var id = 1; true; id++) {
				var firstExistingLink = null;
				var firstExistingDiv = null;
				for (var lang = 1; ; lang++) {
						var elemId = 't-' + id + '-' + lang;
						var link = document.getElementById(elemId + '-link');
						var div  = document.getElementById(elemId);
						if (link === null && div !== null) // without buttons
								continue;
						if (link === null && lang == 1) // no more translations
								break all;
						if (link === null) // last button
								break;
						if (firstExistingDiv === null) {
								firstExistingLink = link
								firstExistingDiv = div;
						}
						link.onclick = selectLanguage;
						if (div === null)
								link.classList.add('missing');
						else if (div.classList.contains('selected')) {
								firstExistingLink = link
								firstExistingDiv = div;
						}
				}
				if (firstExistingDiv !== null) {
						firstExistingDiv.classList.add('selected');
						firstExistingLink.classList.add('selected');
				}
		}
});
