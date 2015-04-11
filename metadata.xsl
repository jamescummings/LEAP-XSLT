<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:jc="http://james.blushingbunny.net/ns.html"
  xpath-default-namespace="http://www.loc.gov/mods/v3" exclude-result-prefixes="xs xd tei jc mods" version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Author:</xd:b> James Cummings</xd:p>
      <xd:p>LEAP MODS display</xd:p>
      <xd:p>April 2015.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output method="xml" indent="yes"/>
<!-- 
  Run against a lib_111111_MODS.xml file it expects a liv_111111_TEI.xml file in the same directory.
  -->


  <!-- When not producing full HTML files, this template could be removed. -->
  <xsl:template match="/">
    <html>
      <xsl:comment>This HTML has been generated from an XML original. Do not manually modify this as a source.</xsl:comment>
      <head>
        <meta charset="UTF-8"/>
        <title>
          <xsl:apply-templates select="/mods/titleInfo[1]/title[1]"/>
        </title>
        <!--<link type="text/css" rel="stylesheet" href="http://jamescummings.github.io/LEAP/style.css"/>-->
        <link type="text/css" rel="stylesheet" href="style.css"/>
      </head>
      <body>
        <xsl:apply-templates select="/mods"/>
      </body>
    </html>
  </xsl:template>

  <!-- Main template-->
  <xsl:template match="mods">
    
    <xsl:variable name="publisherID">
      <xsl:value-of select="normalize-space(identifier[@displayLabel='master_id'][1])"/>
    </xsl:variable>
    <xsl:variable name="TEIfilename">
      <xsl:value-of select="concat($publisherID, '_TEI.xml')"/>
    </xsl:variable>
    <xsl:variable name="TEIfile" select="doc($TEIfilename)"/>


    <xsl:variable name="title">
      <xsl:apply-templates select="/mods/titleInfo[1]/title[1]"/>
    </xsl:variable>
    <xsl:variable name="creators">
      <xsl:for-each select="name[@type='personal'][role/roleTerm='creator']">
        <xsl:value-of select="namePart"/><xsl:if test="not(position()=last())"><xsl:text>;  </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="addressees">
      <xsl:for-each select="name[@type='personal'][role/roleTerm='addressee']">
        <xsl:value-of select="namePart"/><xsl:if test="not(position()=last())"><xsl:text>;  </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="datecreated">
      <xsl:value-of select="originInfo/dateCreated[1]"/>
    </xsl:variable>
    <xsl:variable name="placecreated">
      <xsl:value-of select="originInfo/place/placeTerm"/>
    </xsl:variable>
    <xsl:variable name="physicaldetails">
      <xsl:value-of select="physicalDescription/note[contains(@type, 'hysical')]"/>
    </xsl:variable>
    <xsl:variable name="extentpages">
      <xsl:value-of select="physicalDescription/extent[@unit='pages']"/>
    </xsl:variable>
    <xsl:variable name="sizemm">
      <xsl:value-of select="physicalDescription/extent[@unit='mm']"/>
    </xsl:variable>

    <xsl:variable name="genres">
      <xsl:for-each select="genre">
        <xsl:value-of select="."/>
        <xsl:if test="not(position()=last())">
          <xsl:text>,  </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="repository">
      <xsl:for-each select="relatedItem/name[@type='corporate'][role/roleTerm='repository']">
        <xsl:value-of select="namePart"/>, <xsl:value-of select="ancestor::relatedItem[1]/location/shelfLocator"
        /><xsl:if test="not(position()=last())">
          <xsl:text>;  </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="publisher">Livingstone Online. UCLA Digital Library Program, Los Angeles, CA, USA</xsl:variable>
    
    <!-- NEEDS TO BE UPDATED WITH THE CORRECT URL. ASSUMING PRETTY URLS ENDING IN ID NUMBER -->
    
    <xsl:variable name="itemURL">
      <xsl:value-of select="concat('http://www.example.com/files/', $publisherID)"/>
    </xsl:variable>
    <xsl:variable name="cccatno">
      <xsl:value-of select="identifier[contains(@displayLabel, 'Catalog')]"/>
    </xsl:variable>
    <xsl:variable name="copy">
      <xsl:value-of select="identifier[contains(@displayLabel, 'copy')]"/>
    </xsl:variable>
    <xsl:variable name="TEIencoding">
      <xsl:choose>
        <xsl:when test="$TEIfile//tei:titleStmt/tei:respStmt/tei:name">
          <xsl:for-each select="$TEIfile//tei:titleStmt/tei:respStmt/tei:name">
            <xsl:value-of select="."/><xsl:if test="not(position()=last())"><xsl:text>,  </xsl:text></xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$TEIfile//tei:revisionDesc/tei:change/tei:name">
          <xsl:for-each select="$TEIfile//tei:revisionDesc/tei:change/tei:name">
            <xsl:value-of select="."/><xsl:if test="not(position()=last())"><xsl:text>,  </xsl:text></xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>No TEI Metadata Present</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rights">
      <xsl:for-each select="relatedItem/accessCondition">
        <xsl:value-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="otherversions">
      <xsl:for-each select="relatedItem[@type='otherVersion']">
        <xsl:value-of select="identifier"/><xsl:if test="not(position()=last())"><xsl:text>;    </xsl:text></xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="citeCreators">
      <xsl:analyze-string select="$creators" regex="(.*), [0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9];">
        <xsl:matching-substring><xsl:value-of select="regex-group(1)"/>;</xsl:matching-substring>
        <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:variable name="citeTitle" select="$title"/>
    <xsl:variable name="citeRepository" select="$repository"/>
    <xsl:variable name="citePublisher" select="$publisher"/>
    <xsl:variable name="citeURL" select="$itemURL"/>
    <xsl:variable name="cite"><xsl:value-of select="$citeCreators"/>. <xsl:value-of select="$citeTitle"/>. <xsl:value-of select="$citeRepository"/>. 
      <xsl:value-of select="$citePublisher"/>. <xsl:value-of select="$citeURL"/> (accessed: <xsl:value-of select="current-date()"/>).
    </xsl:variable>
    


    <div class="metadataContainer">
      <h2>
        <xsl:copy-of select="$title"/>
      </h2>
      <div class="MODS_metadata">
        <table class="MODS_metadataTable">
          <tr>
            <td class="metadataTableLabel">Cite</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$cite"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Title</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$title"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Creator(s)</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$creators"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Addressee(s)</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$addressees"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Date Created</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$datecreated"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Place Created</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$placecreated"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Physical Details</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$physicaldetails"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Extent (Pages)</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$extentpages"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Size (mm)</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$sizemm"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Genre(s)</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$genres"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Repository, Shelfmark</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$repository"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Publisher Host</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$publisher"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Publisher ID</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$publisherID"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Item URL</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$itemURL"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">C&amp;C Cat No</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$cccatno"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Copy</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$copy"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">TEI Encoding</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$TEIencoding"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Rights</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$rights"/>
            </td>
          </tr>
          <tr>
            <td class="metadataTableLabel">Other Version(s)</td>
            <td class="metadataTableData">
              <xsl:copy-of select="$otherversions"/>
            </td>
          </tr>

        </table>
      </div>
    </div>

  </xsl:template>


</xsl:stylesheet>
