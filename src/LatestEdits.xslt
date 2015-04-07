<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY GetRootNode "umb:GetXmlNodeByXPath('/root')">
	<!ENTITY mediaFolderId "0">
	<!ENTITY GetMediaFolder "umb:GetMedia($mediaFolderId, true())">
	<!ENTITY GetMediaByXPath "ucom:GetMediaByXPath">
	
	<!ENTITY CreatedToday "starts-with(@createDate, $today)">
	<!ENTITY UpdatedToday "starts-with(@updateDate, $today)">
	<!ENTITY CreatedYesterday "starts-with(@createDate, $yesterday)">
	<!ENTITY UpdatedYesterday "starts-with(@updateDate, $yesterday)">
	
	<!ENTITY DocumentNode "*[@isDoc] | node">
	<!ENTITY AllDocumentNodes "$absoluteRoot//*[@isDoc] | $absoluteRoot//node">
	<!ENTITY DocumentTypeAlias "concat(name(self::*[not(self::node)]), self::node/@nodeTypeAlias)">
]>
<?umbraco-package ?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umb="urn:umbraco.library"
	xmlns:ucom="urn:ucomponents.media"
	xmlns:make="urn:schemas-microsoft-com:xslt"
	exclude-result-prefixes="umb ucom make"
>

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

	<xsl:param name="currentPage" />
	
	<!--
		Because we're running in a Dashboard, currentPage is AWOL, so we do some other hexerei instead.
	-->
	<xsl:variable name="absoluteRoot" select="&GetRootNode;" />

	<!-- Check for uComponents availability -->
	<xsl:variable name="uComponentsAvailable" select="function-available('&GetMediaByXPath;')" />

	<!-- Using Umbraco 7+? -->
	<xsl:variable name="isUmbraco7" select="function-available('umb:JsonToXml')" />

	<!-- If you don't have uComponents (or haven't activated the Media XSLT extensions), you need to put a Media Folder id in here: -->
	<xsl:variable name="mediaFolderId" select="0" />
	<xsl:variable name="mediaRootProxy">
		<xsl:choose>
			<xsl:when test="$uComponentsAvailable">
				<xsl:copy-of select="&GetMediaByXPath;('/')" />
			</xsl:when>
			<xsl:when test="$mediaFolderId &gt; 0">
				<xsl:copy-of select="&GetMediaFolder;" />
			</xsl:when>
			<xsl:otherwise>
				<message>(Media not configured yet)</message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="mediaRoot" select="make:node-set($mediaRootProxy)" />
	
	<!-- Do the date stuff -->
	<xsl:variable name="today" select="substring-before(umb:CurrentDate(), 'T')" />
	<xsl:variable name="yesterday" select="substring-before(umb:DateAdd($today, 'd', -1), 'T')" />

	<!-- Grab all nodes, so we're only "double-dashing" this once -->
	<xsl:variable name="nodes" select="&AllDocumentNodes;" />

	<!-- Grab the Media too -->
	<xsl:variable name="media" select="$mediaRoot//*[umbracoFile]" />
	
	<!-- Check if XMLDump is active (if you're using XMLDump v0.9.3+ you need to manually set this to true())-->
	<xsl:variable name="hasXMLDump" select="boolean($nodes[xmldumpAllowedIPs])" />

	<!-- Select ourselves some Content nodes -->
	<xsl:variable name="nodesCreatedToday" select="$nodes[&CreatedToday;]" />
	<xsl:variable name="nodesUpdatedToday" select="$nodes[not(&CreatedToday;)][&UpdatedToday;]" />

	<xsl:variable name="nodesCreatedYesterday" select="$nodes[&CreatedYesterday;]" />
	<xsl:variable name="nodesUpdatedYesterday" select="$nodes[not(&CreatedYesterday;)][&UpdatedYesterday;]" />
	
	<!-- ... and then the Media nodes -->
	<xsl:variable name="mediaCreatedToday" select="$media[&CreatedToday;]" />	
	<xsl:variable name="mediaUpdatedToday" select="$media[not(&CreatedToday;)][&UpdatedToday;]" />
	
	<xsl:variable name="mediaCreatedYesterday" select="$media[&CreatedYesterday;]" />
	<xsl:variable name="mediaUpdatedYesterday" select="$media[not(&CreatedYesterday;)][&UpdatedYesterday;]" />

	<!-- How much do we need to show at most? -->
	<xsl:variable name="itemsToShow" select="10" />
	<xsl:variable name="mediaItemsToShow" select="16" />

	<!-- Now let's do this -->
	<xsl:template match="/">
		<!-- I know - not the best thing to do :-) -->
		<style type="text/css">
			a.latesteditsmedia { border: 1px solid #999; float: left; width: 120px; height: 120px; display: block; text-align: center; margin: 0 5px 5px 0; background: #eee; -webkit-box-shadow: 0 1px 2px rgba(0,0,0,0.3); -mox-box-shadow: 0 1px 2px rgba(0,0,0,0.3); box-shadow: 0 1px 2px rgba(0,0,0,0.3); }
			.latesteditsmedia img { margin: 8px; border: 1px solid #ccc; }
			<xsl:if test="$isUmbraco7">
				<xsl:text>.dashboardWrapper a { text-decoration: underline; }</xsl:text>
			</xsl:if>
		</style>
		<div class="dashboardWrapper" style="width:48%;float:left;">
			<xsl:if test="not($isUmbraco7)">
				<h2>Latest edits</h2>
				<img src="/usercontrols/Vokseverk/LatestEditsDashboard/LatestEditsIcon_32x32.png" alt="Latest Edits Icon" class="dashboardIcon" />
			</xsl:if>
				
			<xsl:call-template name="outputSection">
				<xsl:with-param name="nodes" select="$nodesCreatedToday" />
				<xsl:with-param name="action" select="'created'" />
				<xsl:with-param name="when" select="'today'" />	
			</xsl:call-template>

			<xsl:call-template name="outputSection">
				<xsl:with-param name="nodes" select="$nodesUpdatedToday" />
				<xsl:with-param name="action" select="'updated'" />
				<xsl:with-param name="when" select="'today'" />	
			</xsl:call-template>

			<xsl:call-template name="outputSection">
				<xsl:with-param name="nodes" select="$nodesCreatedYesterday" />
				<xsl:with-param name="action" select="'created'" />
				<xsl:with-param name="when" select="'yesterday'" />	
			</xsl:call-template>

			<xsl:call-template name="outputSection">
				<xsl:with-param name="nodes" select="$nodesUpdatedYesterday" />
				<xsl:with-param name="action" select="'updated'" />
				<xsl:with-param name="when" select="'yesterday'" />	
			</xsl:call-template>
		</div>
		
		<div class="dashboardWrapper" style="width:48%;float:right;">
			<xsl:if test="not($isUmbraco7)">
				<h2 style="padding-left:0">New media uploads</h2>
			</xsl:if>
			
			<xsl:if test="$mediaRoot[message]">
				<p style="color:#900">
					<xsl:value-of select="$mediaRoot/message" />
				</p>
			</xsl:if>
			
			<xsl:call-template name="outputMediaSection">
				<xsl:with-param name="nodes" select="$mediaCreatedToday" />
				<xsl:with-param name="action" select="'created'" />
				<xsl:with-param name="when" select="'today'" />
			</xsl:call-template>
			
			<xsl:call-template name="outputMediaSection">
				<xsl:with-param name="nodes" select="$mediaCreatedYesterday" />
				<xsl:with-param name="action" select="'created'" />
				<xsl:with-param name="when" select="'yesterday'" />
			</xsl:call-template>
		</div>
	</xsl:template>
	
	<!-- The main output template for each chunk of nodes -->
	<xsl:template name="outputSection">
		<xsl:param name="nodes" select="/.." /><!-- Default to an empty set -->
		<xsl:param name="action" select="'created'" />
		<xsl:param name="when" select="'today'" />
		
		<h3>
			<xsl:value-of select="concat('Pages ', $action, ' ', $when, ':')" />
		</h3>
		<div>
			<xsl:if test="not($isUmbraco7)"><xsl:attribute name="class">propertypane</xsl:attribute></xsl:if>
			<ol>
				<xsl:apply-templates select="$nodes">
					<xsl:sort select="@updateDate[$action = 'updated']" data-type="text" order="descending" />
					<xsl:sort select="@createDate[$action = 'created']" data-type="text" order="descending" />
				</xsl:apply-templates>
				<xsl:if test="not($nodes)"><xsl:call-template name="noNodes" /></xsl:if>
			</ol>
		</div>
	</xsl:template>
	
	<xsl:template name="outputMediaSection">
		<xsl:param name="nodes" select="/.." />
		<xsl:param name="action" select="'created'" />
		<xsl:param name="when" select="'today'" />
		
		<h3 style="text-transform:capitalize;clear:both;">
			<xsl:value-of select="$when" />
		</h3>
		<div style="padding-bottom:20px;">
			<xsl:apply-templates select="$nodes" mode="media">
				<xsl:sort select="@updateDate[$action = 'updated']" data-type="text" order="descending" />
				<xsl:sort select="@createDate[$action = 'created']" data-type="text" order="descending" />
			</xsl:apply-templates>
			<xsl:if test="not($nodes)"><p>(none)</p></xsl:if>
		</div>
	</xsl:template>
	
	<!-- This is the output template for each item -->
	<xsl:template match="&DocumentNode;">
		<xsl:if test="position() &lt;= $itemsToShow">
			<li>
				<span style="color:#999;"><xsl:value-of select="&DocumentTypeAlias;" /></span>
				<xsl:text>: </xsl:text>
				<span><xsl:value-of select="concat(@nodeName, ' ')" /></span>
				<xsl:apply-templates select="." mode="editLink" />
				<xsl:apply-templates select="." mode="xmldumpLink" />
			</li>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="media">
		<xsl:variable name="file" select="umbracoFile" />
		<!-- Get the default Umbraco thumbnail -->
		<xsl:variable name="thumbnail" select="concat(substring-before(translate($file, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), concat('.', umbracoExtension)), '_thumb.jpg')" />
		<xsl:if test="position() &lt;= $mediaItemsToShow">
			<a class="latesteditsmedia" href="/umbraco/editMedia.aspx?id={@id}" title="{@nodeName} (Click to edit)">
				<xsl:if test="$isUmbraco7">
					<xsl:attribute name="href"><xsl:value-of select="concat('/umbraco/#/media/media/edit/', @id)" /></xsl:attribute>
					<xsl:attribute name="target">_top</xsl:attribute>
				</xsl:if>
				<img src="{$thumbnail}" alt="{@nodeName}" width="100">
					<xsl:if test="$isUmbraco7">
						<xsl:attribute name="src">
							<xsl:value-of select="umb:JsonToXml($file)/src" />
							<xsl:text>?width=200&amp;height=200&amp;mode=crop</xsl:text>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="not(contains('jpg jpeg gif png tiff JPG JPEG GIF PNG TIFF', umbracoExtension))">
						<xsl:attribute name="src">http://placehold.it/100x100&amp;text=<xsl:value-of select="umbracoExtension" /></xsl:attribute>
					</xsl:if>
					<xsl:if test="umbracoWidth &lt; umbracoHeight">
						<xsl:attribute name="width" />
						<xsl:attribute name="height">100</xsl:attribute>
					</xsl:if>
				</img>
			</a>
		</xsl:if>
	</xsl:template>
	
	<!-- Output if no nodes were created/updated -->
	<xsl:template name="noNodes">
		<li style="list-style-type:square;">(none)</li>
	</xsl:template>

	<xsl:template match="&DocumentNode;" mode="editLink">
		<a href="/umbraco/editContent.aspx?id={@id}" title="Click to edit...">
			<xsl:if test="$isUmbraco7">
				<xsl:attribute name="href"><xsl:value-of select="concat('/umbraco/#/content/content/edit/', @id)" /></xsl:attribute>
				<xsl:attribute name="target">_top</xsl:attribute>
			</xsl:if>
			<xsl:text>Edit</xsl:text>
		</a>
	</xsl:template>
		
	<xsl:template match="&DocumentNode;" mode="xmldumpLink">
		<xsl:if test="$hasXMLDump">
			<xsl:text> | </xsl:text>
			<a href="/xmldump?id={@id}" target="_blank" title="View XMLDump...">XML</a>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
