<?xml version="1.0"?>
<?umbraco-package "Latest Edits Dashboard (v1.1.1)"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:umb="urn:umbraco.library" xmlns:ucom="urn:ucomponents.media" xmlns:make="urn:schemas-microsoft-com:xslt" version="1.0" exclude-result-prefixes="umb ucom make">

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>

	<xsl:param name="currentPage"/>
	
	<!--
		Because we're running in a Dashboard, currentPage is AWOL, so we do some other hexerei instead.
	-->
	<xsl:variable name="absoluteRoot" select="umb:GetXmlNodeByXPath('/root')"/>

	<!-- Check for uComponents availability -->
	<xsl:variable name="uComponentsAvailable" select="function-available('ucom:GetMediaByXPath')"/>

	<!-- If you don't have uComponents (or haven't activated the Media XSLT extensions), you need to put a Media Folder id in here: -->
	<xsl:variable name="mediaFolderId" select="0"/>
	<xsl:variable name="mediaRootProxy">
		<xsl:choose>
			<xsl:when test="$uComponentsAvailable">
				<xsl:copy-of select="ucom:GetMediaByXPath('/')"/>
			</xsl:when>
			<xsl:when test="$mediaFolderId &gt; 0">
				<xsl:copy-of select="umb:GetMedia($mediaFolderId, true())"/>
			</xsl:when>
			<xsl:otherwise>
				<message>(Not configured yet)</message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="mediaRoot" select="make:node-set($mediaRootProxy)"/>
	
	<!-- Do the date stuff -->
	<xsl:variable name="today" select="substring-before(umb:CurrentDate(), 'T')"/>
	<xsl:variable name="yesterday" select="substring-before(umb:DateAdd($today, 'd', -1), 'T')"/>

	<!-- Grab all nodes, so we're only "double-dashing" this once -->
	<xsl:variable name="nodes" select="$absoluteRoot//*[@isDoc]"/>

	<!-- Grab the Media too -->
	<xsl:variable name="media" select="$mediaRoot//*[umbracoFile]"/>
	
	<!-- Check if XMLDump is active -->
	<xsl:variable name="hasXMLDump" select="boolean($nodes[xmldumpAllowedIPs])"/>

	<!-- Select ourselves some Content nodes -->
	<xsl:variable name="nodesCreatedToday" select="$nodes[starts-with(@createDate, $today)]"/>
	<xsl:variable name="nodesUpdatedToday" select="$nodes[not(starts-with(@createDate, $today))][starts-with(@updateDate, $today)]"/>

	<xsl:variable name="nodesCreatedYesterday" select="$nodes[starts-with(@createDate, $yesterday)]"/>
	<xsl:variable name="nodesUpdatedYesterday" select="$nodes[not(starts-with(@createDate, $yesterday))][starts-with(@updateDate, $yesterday)]"/>
	
	<!-- ... and then the Media nodes -->
	<xsl:variable name="mediaCreatedToday" select="$media[starts-with(@createDate, $today)]"/>	
	<xsl:variable name="mediaUpdatedToday" select="$media[not(starts-with(@createDate, $today))][starts-with(@updateDate, $today)]"/>
	
	<xsl:variable name="mediaCreatedYesterday" select="$media[starts-with(@createDate, $yesterday)]"/>
	<xsl:variable name="mediaUpdatedYesterday" select="$media[not(starts-with(@createDate, $yesterday))][starts-with(@updateDate, $yesterday)]"/>

	<!-- How much do we need to show at most? -->
	<xsl:variable name="itemsToShow" select="10"/>
	<xsl:variable name="mediaItemsToShow" select="16"/>

	<!-- Now let's do this -->
	<xsl:template match="/">
		
		<div class="dashboardWrapper" style="width:48%;float:left;">
			<h2>Latest edits</h2>
			<img src="/usercontrols/Vokseverk/LatestEditsDashboard/LatestEditsIcon_32x32.png" alt="Latest Edits Icon" class="dashboardIcon"/>
				
			<xsl:call-template name="outputSection">
				<xsl:with-param name="nodes" select="$nodesCreatedToday"/>
				<xsl:with-param name="action" select="'created'"/>
				<xsl:with-param name="when" select="'today'"/>	
			</xsl:call-template>

			<xsl:call-template name="outputSection">
				<xsl:with-param name="nodes" select="$nodesUpdatedToday"/>
				<xsl:with-param name="action" select="'updated'"/>
				<xsl:with-param name="when" select="'today'"/>	
			</xsl:call-template>

			<xsl:call-template name="outputSection">
				<xsl:with-param name="nodes" select="$nodesCreatedYesterday"/>
				<xsl:with-param name="action" select="'created'"/>
				<xsl:with-param name="when" select="'yesterday'"/>	
			</xsl:call-template>

			<xsl:call-template name="outputSection">
				<xsl:with-param name="nodes" select="$nodesUpdatedYesterday"/>
				<xsl:with-param name="action" select="'updated'"/>
				<xsl:with-param name="when" select="'yesterday'"/>	
			</xsl:call-template>
		</div>
		
		<div class="dashboardWrapper" style="width:48%;float:right;">
			<h2 style="padding-left:0">New media uploads</h2>
			
			<xsl:if test="$mediaRoot[message]">
				<p style="color:#900">
					<xsl:value-of select="$mediaRoot/message"/>
				</p>
			</xsl:if>
			
			<xsl:call-template name="outputMediaSection">
				<xsl:with-param name="nodes" select="$mediaCreatedToday"/>
				<xsl:with-param name="action" select="'created'"/>
				<xsl:with-param name="when" select="'today'"/>
			</xsl:call-template>
			
			<xsl:call-template name="outputMediaSection">
				<xsl:with-param name="nodes" select="$mediaCreatedYesterday"/>
				<xsl:with-param name="action" select="'created'"/>
				<xsl:with-param name="when" select="'yesterday'"/>
			</xsl:call-template>
		</div>
	</xsl:template>
	
	<!-- The main output template for each chunk of nodes -->
	<xsl:template name="outputSection">
		<xsl:param name="nodes" select="/.."/><!-- Default to an empty set -->
		<xsl:param name="action" select="'created'"/>
		<xsl:param name="when" select="'today'"/>
		
		<h3>
			<xsl:value-of select="concat('Pages ', $action, ' ', $when, ':')"/>
		</h3>
		<div class="propertypane">
			<ol>
				<xsl:apply-templates select="$nodes">
					<xsl:sort select="@updateDate[$action = 'updated']" data-type="text" order="descending"/>
					<xsl:sort select="@createDate[$action = 'created']" data-type="text" order="descending"/>
				</xsl:apply-templates>
				<xsl:if test="not($nodes)"><xsl:call-template name="noNodes"/></xsl:if>
			</ol>
		</div>
	</xsl:template>
	
	<xsl:template name="outputMediaSection">
		<xsl:param name="nodes" select="/.."/>
		<xsl:param name="action" select="'created'"/>
		<xsl:param name="when" select="'today'"/>
		
		<h3 style="text-transform:capitalize;clear:both;">
			<xsl:value-of select="$when"/>
		</h3>
		<div style="padding-bottom:20px;">
			<xsl:apply-templates select="$nodes" mode="media">
				<xsl:sort select="@updateDate[$action = 'updated']" data-type="text" order="descending"/>
				<xsl:sort select="@createDate[$action = 'created']" data-type="text" order="descending"/>
			</xsl:apply-templates>
			<xsl:if test="not($nodes)"><p>(none)</p></xsl:if>
		</div>
	</xsl:template>
	
	<!-- This is the output template for each item -->
	<xsl:template match="*[@isDoc]">
		<xsl:if test="position() &lt;= $itemsToShow">
			<li>
				<span style="color:#999;"><xsl:value-of select="name()"/></span>
				<xsl:text>: </xsl:text>
				<span><xsl:value-of select="concat(@nodeName, ' ')"/></span>
				<xsl:apply-templates select="." mode="editLink"/>
				<xsl:apply-templates select="." mode="xmldumpLink"/>
			</li>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="media">
		<xsl:variable name="file" select="umbracoFile"/>
		<!-- Get the default Umbraco thumbnail -->
		<xsl:variable name="thumbnail" select="concat(substring-before($file, concat('.', umbracoExtension)), '_thumb.jpg')"/>
		<xsl:if test="position() &lt;= $mediaItemsToShow">
			<a href="/umbraco/editMedia.aspx?id={@id}" title="{@nodeName} (Click to edit)" style="float:left; width:100px; display:block; margin:0 5px 5px 0;">
				<img style="-webkit-box-shadow:0 1px 2px rgba(0,0,0,0.3);-mox-box-shadow:0 1px 2px rgba(0,0,0,0.3);box-shadow:0 1px 2px rgba(0,0,0,0.3);" src="{$thumbnail}" alt="{@nodeName}" width="100"/>
			</a>
		</xsl:if>
	</xsl:template>
	
	<!-- Output if no nodes were created/updated -->
	<xsl:template name="noNodes">
		<li style="list-style-type:square;">(none)</li>
	</xsl:template>

	<xsl:template match="*[@isDoc]" mode="editLink">
		<a href="/umbraco/editContent.aspx?id={@id}" title="Click to edit...">Edit</a>
	</xsl:template>
		
	<xsl:template match="*[@isDoc]" mode="xmldumpLink">
		<xsl:if test="$hasXMLDump">
			<xsl:text> | </xsl:text>
			<a href="/xmldump?id={@id}" target="_blank" title="View XMLDump...">XML</a>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
