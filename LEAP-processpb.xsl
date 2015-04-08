<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:jc="http://james.blushingbunny.net/ns.html"
xpath-default-namespace="http://www.tei-c.org/ns/1.0"
 exclude-result-prefixes="jc"
version="2.0">
<!--

Derived from 
https://github.com/TEIC/Stylesheets/blob/master/tools/processpb.xsl

Licensed CC+SA 3.0
    Take an arbitrary TEI file and move page breaks (<pb>) up in the
    hierarchy, splitting containers as needed, until <pb>s are at the
    same level as <div>. Wrap the resulting pages on <page> element.
-->
  <xsl:output indent="yes"/>


  <xsl:template match="processing-instruction()"/>

<xsl:template match="/">
  <xsl:comment>This file has been modified from its original by 
    https://github.com/jamescummings/LEAP-XSLT/blob/master/LEAP-processpb.xsl 
  with added 'page' elements in a non-TEI namespace. This file will no longer 
  validate against the LEAP schema and is for display purposes only.  
    
  </xsl:comment><xsl:text>

  </xsl:text>
  <xsl:apply-templates/>
</xsl:template>
  
  <xsl:template match="teiHeader">
    <xsl:copy-of select="."/>
  </xsl:template>


  <xsl:template match="TEI|teiCorpus|group|text">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|comment()|text()"/>
    </xsl:copy>
  </xsl:template>
  
    
  
  

  <xsl:template match="text/body|text/back|text/front">
      <xsl:variable name="pages">
	<xsl:copy>
	  <xsl:apply-templates select="@*"/>
	  <xsl:apply-templates
	      select="*|comment()|text()"/>
	</xsl:copy>
      </xsl:variable>
      <xsl:for-each select="$pages">
	<xsl:apply-templates  mode="pass2"/>
      </xsl:for-each>
  </xsl:template>


 <!-- first (recursive) pass. look for <pb> elements and group on them -->
  <xsl:template match="comment()|@*|text()">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:call-template name="checkpb">
      <xsl:with-param name="eName" select="local-name()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="pb">
    <pb>
      <xsl:copy-of select="@*"/>
    </pb>
  </xsl:template>

  <xsl:template name="checkpb">
    <xsl:param name="eName"/>
    <xsl:choose>
      <xsl:when test="not(.//pb)">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pass">
	  <xsl:call-template name="groupbypb">
	    <xsl:with-param name="Name" select="$eName"/>
	  </xsl:call-template>
        </xsl:variable>
	<xsl:for-each select="$pass">
	  <xsl:apply-templates/>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="groupbypb">
    <xsl:param name="Name"/>
    <xsl:for-each-group select="node()" group-starting-with="pb">
      <xsl:choose>
        <xsl:when test="self::pb">
          <xsl:copy-of select="."/>
          <xsl:element name="{$Name}">
	    <xsl:attribute name="rend">CONTINUED</xsl:attribute>
            <xsl:apply-templates select="current-group() except ."/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="{$Name}">
            <xsl:for-each select="..">
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates select="current-group()"/>
            </xsl:for-each>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <!-- second pass. group by <pb> (now all at top level) and wrap groups
       in <page> -->
  <xsl:template match="*" mode="pass2">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|comment()|text()" mode="pass2"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()|@*|text()" mode="pass2">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="*[pb]" mode="pass2" >
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:for-each-group select="*" group-starting-with="pb">
        <xsl:choose>
          <xsl:when test="self::pb">
            <page xmlns="http://james.blushingbunny.net/ns.html"> 
              <xsl:copy-of select="@*"/>
              <xsl:copy-of select="current-group() except ."/>
            </page>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="current-group()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
