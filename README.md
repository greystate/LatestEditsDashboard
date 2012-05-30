# Latest Edits Dashboard

This is a simple dashboard for the Developer section, which shows you the latest edited content & media, specifically:

## Content

* Pages created today
* Pages updated today
* Pages created yesterday
* Pages updated yesterday

It shows the latest 10 entries in descending order - a node that was created *and* updated on the same day (very common) will only show in the "created" section, so it doesn't also take another node's spot in the "updated" section.

Each node displayed will show the DocumentType's alias and the Name of the node, e.g.:

	1. Textpage: Our battle tactics revealed
	2. BlogPost: Crywolf interviewed
	etc.

It puts an "Edit" link right next to each node, so you can jump immediately to the editing page for it. If you're using the XMLDump package, there's also an "XML" link that opens the page in XMLDump for you.

## Media

* Media uploaded today
* Media uploaded yesterday

Umbraco's default thumbnail will be shown for the lateset 16 items, each wrapped in a link so you can go directly to the specific item in the Media section.

**Note:** *The XSLT will auto-detect the presence of uComponents' Media XSLT Extensions - if you haven't installed those, look for the variable `mediaFolderId` in the XSLT - replace the zero with the id of the Media folder you want to "monitor":*

```xslt
<xsl:variable name="mediaFolderId" select="0" />
```

If you know of a smart way to circumvent this (e.g., providing a dropdown of folders?), please let me know.

## Customization

The best part is: It's just a standard XSLT Macro (yes, XSLT) that you can edit to your heart's extent.

Have to see more than 10 entries per section? Change the `itemsToShow` variable, hit "Save" - and there you have it.
Need to filter out some DocumentTypes? Change the `nodes` variable. Etc.

## Upgrade info

Usually you can just upload the new XSLT file (grab it from the `dist` folder on [GitHub](https://github.com/greystate/LatestEditsDashboard/tree/master/dist)), otherwise you should uninstall the old version first, then install the new version.

## Revision History

* v1.1: Add latest Media uploads from specific folder
* v1.0.2: Added proper icon; refactored code
* v1.0: Initial release

/Chriztian Steinmeier, May 2012

Thanks:

* [Lee Kelleher](http:/twitter.com/leekelleher)
* [Douglas Robar](http://twitter.com/drobar)
* [Dan Brendstrup](http://twitter.com/bewildergeist)
* [Sebastiaan Janssen](http://twitter.com/cultiv)