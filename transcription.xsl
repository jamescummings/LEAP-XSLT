<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:jc="http://james.blushingbunny.net/ns.html"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xd tei jc" version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Author:</xd:b> James Cummings</xd:p>
      <xd:p>First attempt at LEAP to HTML conversion</xd:p>
      <xd:p>Updated in Feb/Mar 2015.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output method="xml" indent="yes"/>

<!-- Incoming parameters -->
<xsl:param name="page" select="'0001'"/>
<xsl:param name="paged" select="'true'"/>

<!-- transform these to global variables in case I need to use them anywhere -->
<xsl:variable name="pagenumber" select="$page"/>  
<xsl:variable name="isPaged" select="$paged"/>  

  <!-- When not producing full HTML files, this template could be removed but javascript and CSS will need to be copied to correct location. -->
  <xsl:template match="/">
    <html>
      <xsl:comment>This HTML has been generated from an XML original. Do not manually modify this as a source.</xsl:comment>
      <head>
        <meta charset="UTF-8"/>
        <title>
          <xsl:value-of select="//teiHeader//title[1]"/>
        </title>
        <!--<link type="text/css" rel="stylesheet" href="http://jamescummings.github.io/LEAP/style.css"/>-->
        <link type="text/css" rel="stylesheet" href="style.css"/>
        <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js" type="text/javascript"><xsl:comment> ... </xsl:comment></script>
        <script type="text/javascript">
          
          $(document).ready(function(){
          $('button#toggle').removeClass("hidden");
          $('button#toggle').click(function(){
          $('.diplomatic').toggleClass("hidden");
          $('.edited').toggleClass("hidden");
          });
          });
          
        </script>
  </head>
  <body>
      <xsl:apply-templates select="TEI"/>
  </body>
    </html>
  </xsl:template>
  
  <!-- Don't show -->
  <xsl:template match="teiHeader | facsimile |surface |zone"/>
  
  
  <xsl:template match="TEI">
      <div class="transcription"><button id="toggle" title="toggle" type="button" class="hidden">Toggle Diplomatic/Edited</button>
      <h2>
        <xsl:value-of select="//teiHeader//title[1]"/>
      </h2>
      <div class="TEI">
        <xsl:comment><xsl:value-of select="$isPaged"/></xsl:comment>
    <xsl:choose>
      <xsl:when test="$isPaged='true' and //jc:page[@n=$pagenumber]"><xsl:apply-templates select="//jc:page[@n=$pagenumber]"/></xsl:when>
      <xsl:when test="$isPaged='false'"><xsl:apply-templates select="text"/></xsl:when>
      <xsl:when test="//jc:page[@n=$pagenumber]"><xsl:apply-templates select="//jc:page[@n=$pagenumber]"/></xsl:when>
      <xsl:otherwise><xsl:apply-templates select="text"/></xsl:otherwise>
    </xsl:choose>
      </div>
      </div>
  </xsl:template>
  
  <!-- general match -->
  <xsl:template match="*" priority="-10">
    <xsl:variable name="class">
      <xsl:if test="@rend">
        <xsl:value-of select="translate(@rend, '-', '')"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:if test="@place">
        <xsl:value-of select="translate(@place, '-', '')"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:if test="@type">
        <xsl:value-of select="translate(@type, '-', '')"/>
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:for-each select="@*">
        <xsl:sort/>
        <xsl:value-of select="concat(name(),': ', ., '; ')"/>
      </xsl:for-each>
    </xsl:variable>
    <span>
      <xsl:if test="$class/text()">
        <xsl:attribute name="class">
          <xsl:value-of select="$class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$title/text()">
        <xsl:attribute name="title">
          <xsl:value-of select="$title"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- make rend class -->
  <xsl:template match="*/@rend" priority="-1">
    <xsl:attribute name="class">
      <xsl:value-of select="concat(parent::node()/name(), ' ')"/>
      <xsl:value-of select="translate(., '-', '')"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="front|back|body|div|text">
    <div class="{concat(name(), ' ', translate(@rend, '-', ''))}">
      <xsl:apply-templates />
    </div>
  </xsl:template>


  <xsl:template match="p|ab">
    <p class="{concat(name(), ' ', translate(@rend, '-', ''))}">
      <xsl:apply-templates/>
    </p>
  </xsl:template>


  <!-- exclude those inside notes -->
  <xsl:template match="lb[not(ancestor::note)]">
    <br/>
    <xsl:variable name="num">
      <xsl:number level="any" from="pb"/>
    </xsl:variable>
    <xsl:if test="number($num) mod 5 =0">
      <span class="linenumber">
        <xsl:value-of select="$num"/>
      </span>
    </xsl:if>
  </xsl:template>

  <!--
    <xsl:template match="*[not(@type)][not(@reason)][not(@unit)][not(@extent)]" priority="-1"><span class="{name()}"><xsl:apply-templates select="@*|node()"/></span></xsl:template>
  -->

  <xsl:template match="choice">
    <span class="choice">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="choice/abbr">
    <span class="abbr diplomatic">
      <xsl:if test="../expan">
        <xsl:attribute name="title">expan: <xsl:value-of select="../expan"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="choice/expan">
    <span class="abbr edited hidden">
      <xsl:if test="../abbr">
        <xsl:attribute name="title">expan: <xsl:value-of select="."/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="../abbr[1]/node()"/>
    </span>
  </xsl:template>
  <xsl:template match="choice/orig">
    <span class="orig diplomatic">
      <xsl:if test="../reg">
        <xsl:attribute name="title">reg: <xsl:value-of select="../reg"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="choice/reg">
    <span class="reg edited hidden">
      <xsl:if test="../orig">
        <xsl:attribute name="title">orig: <xsl:value-of select="../orig"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="../orig/node()"/>
    </span>
  </xsl:template>
  <xsl:template match="choice/sic">
    <span class="sic diplomatic ">
      <xsl:if test="../corr">
        <xsl:attribute name="title">corr: <xsl:value-of select="../corr"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <xsl:template match="choice/corr">
    <span class="corr edited hidden">
      <xsl:if test="../sic">
        <xsl:attribute name="title">sic: <xsl:value-of select="../sic"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>



<!-- app: show first rdg -->
<xsl:template match="app">
  <span class="app">
    <xsl:attribute name="title">
      <xsl:for-each select="rdg">
        <xsl:value-of select="concat(name(),': ', ., '; ')"/>
      </xsl:for-each>
    </xsl:attribute>
    <xsl:apply-templates select="rdg[1]"/>
  </span>
</xsl:template>
  


  <xsl:template match="del[@type='cancelled']">
    <span class="del cancelled">
      <xsl:if test="@*">
        <xsl:attribute name="title">
          <xsl:value-of select="concat(name(), ':  ')"/>
          <xsl:for-each select="@*">
            <xsl:sort/>
            <xsl:value-of select="concat(name(),': ', ., '; ')"/>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  
 
    
  <!-- foreign should be italiced in edited view -->
  <xsl:template match="foreign" xml:space="preserve"><span class="foreign diplomatic"><xsl:if test="@xml:lang"><xsl:attribute name="title"><xsl:value-of select="concat('lang: ', @xml:lang)"/></xsl:attribute></xsl:if><xsl:apply-templates/></span><span class="foreign foreignItalic edited hidden" style="font-style:italic;"><xsl:if test="@xml:lang"><xsl:attribute name="title"><xsl:value-of select="concat('lang: ', @xml:lang)"/></xsl:attribute></xsl:if><xsl:apply-templates/></span></xsl:template>

  <xsl:template match="figure">
    <span class="figure" title="{concat(head, ';  ', figDesc)}">[Illustration] <xsl:apply-templates/></span>
  </xsl:template>
  <xsl:template match="figure/head|figure/figDesc"/>
  
  
  
  <xsl:template match="gap[@extent][@unit]|space[@extent][@unit]" priority="10">
    <xsl:choose>
      <xsl:when test="@unit='chars'">
        <span class="space" title="{concat(name(), ':  ',@extent, ' ', @unit, ' ', @agent)}">
          [<xsl:for-each select="1 to @extent">&#x00A0;</xsl:for-each>]
        </span>
      </xsl:when>
      <xsl:when test="@unit='words'">
        <span class="space" title="{concat(name(), ':  ',@extent, ' ', @unit, ' ', @agent)}">
          [<xsl:for-each select="1 to @extent">&#x00A0;&#x00A0;&#x00A0;&#x00A0;&#x00A0;&#x00A0;</xsl:for-each>]
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="space" title="{concat(name(), ':  ', @extent, ' ', @unit, ' ', @agent)}">
          [<xsl:for-each select="1 to @extent">&#x00A0;&#x00A0;&#x00A0;&#x00A0;&#x00A0;&#x00A0;</xsl:for-each>]
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="space[@extent][@unit][@dim='vertical']" priority="1">
        <span class="space vertical verticalSpace"><xsl:attribute name="title"><xsl:for-each select="@*">
            <xsl:sort/>
            <xsl:value-of select="concat(name(),': ', ., '; ')"/>
          </xsl:for-each></xsl:attribute>
          <xsl:for-each select="1 to @extent"><br class="verticalSpace"/></xsl:for-each>
        </span>
  </xsl:template>
  
  
  
  
  
  <!-- do not show graphic -->
  <xsl:template match="graphic"/>
    
  
  
  <xsl:template match="head">
    <xsl:variable name="num" select="count(ancestor::*)"/>
    <xsl:element name="{concat('h', $num)}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="figure/head">
    <span class="figHead">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="list">
    <ul><xsl:apply-templates/></ul>
  </xsl:template>
  
  <xsl:template match="list/item">
    <li><xsl:apply-templates/></li>
  </xsl:template>




  <xsl:template match="milestone">
    <hr class="{concat(name(), ' ', translate(@rend, '-', ''))}">
      <xsl:if test="@*">
        <xsl:attribute name="title">
          <xsl:value-of select="concat(name(), ':  ')"/>
          <xsl:for-each select="@*">
            <xsl:sort/>
            <xsl:value-of select="concat(name(),': ', ., '; ')"/>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:if>
    </hr>
  </xsl:template>


<xsl:template match="jc:page">
<div class="page">
  <hr/>
  <span class="pb-title">Image: <xsl:value-of select="@n"/></span>
<xsl:apply-templates/>  
  </div>
</xsl:template>
  
  <xsl:template match="pb">
    <hr/>
    <span class="pb-title">Image: <xsl:value-of select="@n"/></span>
  </xsl:template>
  
  

  <xsl:template match="supplied">
    <span class="supplied edited hidden"><xsl:if test="@*">
      <xsl:attribute name="title">
        <xsl:value-of select="concat(name(), ':  ')"/>
        <xsl:for-each select="@*">
          <xsl:sort/>
          <xsl:value-of select="concat(name(),': ', ., '; ')"/>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:if>
      [<xsl:apply-templates select="node()"/>]</span>
  </xsl:template>
  
  


  <xsl:template match="table">
    <table>
      <xsl:apply-templates select="@*|node()"/>
    </table>
  </xsl:template>
  <xsl:template match="row">
    <tr>
      <xsl:apply-templates select="@*|node()"/>
    </tr>
  </xsl:template>
<xsl:template match="cell">
    <td>
      <xsl:apply-templates select="@*|node()"/>
    </td>
  </xsl:template>


<xsl:template match="term[@type]" priority="1">
 <span class="term" title="{@type}"><xsl:apply-templates/></span> 
</xsl:template>
  


  <xsl:template match="unclear">
    <span class="unclear"><xsl:if test="@*">
      <xsl:attribute name="title">
        <xsl:value-of select="concat(name(), ':  ')"/>
        <xsl:for-each select="@*">
          <xsl:sort/>
          <xsl:value-of select="concat(name(),': ', ., '; ')"/>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()"/></span>
  </xsl:template>
  

</xsl:stylesheet>
