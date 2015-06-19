<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
   xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:jc="http://james.blushingbunny.net/ns.html"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="jc tei xsl"
  version="2.0">

<!-- Parameter determines if output is wrapped in a bit of HTML or not. -->
  <xsl:param name="htmlWrapper">false</xsl:param>
  
  <!-- Derived from 
  https://github.com/TEIC/Stylesheets/blob/master/tools/processpb.xsl
  Licensed CC 3.0
  Transcription transformational content is copyright James Cummings, but
  also licensed CC 3.0 
  -->



<!-- Root Template -->
  <xsl:template match="/">
    <xsl:variable name="pagedTEI">
    <xsl:apply-templates mode="paging"/>
    </xsl:variable>
    <xsl:apply-templates select="$pagedTEI//jc:page" mode="transcription"/>
  </xsl:template>
  
  
  
  
  <!--  
    PAGING TEMPLATES: Everything in this section is to do with paging the source 
    TEI file and breaking it into pages.  All templates here use the 'paging' mode 
    as the default (and pass2 when going through looking for page breaks).
    
    Take an arbitrary TEI file and move page breaks (<pb>) up in the
    hierarchy, splitting containers as needed, until <pb>s are at the
    same level as <div>. Wrap the resulting pages on <page> element.
  -->
  
  <xsl:template match="teiHeader" mode="paging">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  
  <xsl:template match="TEI|teiCorpus|group|text" mode="paging">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="paging"/>
      <xsl:apply-templates select="*|comment()|text()" mode="paging"/>
    </xsl:copy>
  </xsl:template>
  
  
  
  
  <xsl:template match="processing-instruction()" mode="paging"/>
  
  
  
  
  <xsl:template match="text/body|text/back|text/front" mode="paging">
    <xsl:variable name="pages">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="paging"/>
        <xsl:apply-templates
          select="*|comment()|text()" mode="paging"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:for-each select="$pages">
      <xsl:apply-templates  mode="pass2"/>
    </xsl:for-each>
  </xsl:template>
  
  
  <!-- first (recursive) pass. look for <pb> elements and group on them -->
  <xsl:template match="comment()|@*|text()" mode="paging">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="*" mode="paging">
    <xsl:call-template name="checkpb" >
      <xsl:with-param name="eName" select="local-name()"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="pb" mode="paging">
    <tei:pb>
      <xsl:copy-of select="@*"/>
    </tei:pb>
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
          <xsl:apply-templates mode="paging"/>
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
            <xsl:apply-templates select="current-group() except ." mode="paging"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="{$Name}">
            <xsl:for-each select="..">
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates select="current-group()" mode="paging"/>
            </xsl:for-each>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <!-- second pass. group by <pb> (now all at top level) and wrap groups
       in <page>; copy-all -->
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
      <xsl:apply-templates select="@*" mode="paging"/>
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
  
  
  
  
  
  
  
  
  
  <!-- 
    TRANSCRIPTION TEMPLATES: Everything in this section has to do with creating the 
    HTML output. By default most things have their element names and @rend values and 
    such stuck into the output and so you get span class="hi bold" from <hi rend="bold">
  -->
  
  
  <xsl:template match="jc:page" mode="transcription">
    <xsl:choose>
      <xsl:when test="$htmlWrapper='true'">
        <xsl:result-document href="{concat(@facs, '.html')}">
        <html>
          <xsl:text>
           </xsl:text>
          <xsl:comment>This HTML has been generated from an XML original. Do not manually modify this as a source.</xsl:comment>
          <head>
            <meta charset="UTF-8"/>
            <title>
              <xsl:value-of select="//teiHeader//title[1]"/>
            </title>
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
            <div id="{@facs}">
            <xsl:apply-templates mode="transcription"/>
            </div>
          </body>
        </html>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:result-document href="{concat(@facs, '.html')}">
          <xsl:text>
           </xsl:text>
        <xsl:comment>This HTML Fragment has been generated from an XML original. Do not manually modify this as a source.</xsl:comment>
          <div id="{@facs}">
            <xsl:apply-templates mode="transcription"/>
          </div>
        </xsl:result-document>
      </xsl:otherwise>
      </xsl:choose>
 </xsl:template>
  


<!-- Ignore these (though in this version we shouldn't have to worry about them anyway -->
<xsl:template match="teiHeader | facsimile |surface |zone"/>
  
<!-- Just pass that through. -->  
<xsl:template match="TEI" mode="transcription"><xsl:apply-templates/></xsl:template>
  
  <!-- general match -->
  <xsl:template match="*" priority="-10"  mode="transcription">
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
      <xsl:value-of select="name()"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:for-each select="@*">
        <xsl:sort/>
        <xsl:value-of select="concat(name(),': ', ., '; ')"/>
      </xsl:for-each>
    </xsl:variable>
    <span>
      <xsl:if test="not(normalize-space($class)='')">
        <xsl:attribute name="class">
          <xsl:value-of select="$class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="not(normalize-space($title)='')">
        <xsl:attribute name="title">
          <xsl:value-of select="$title"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates  mode="transcription"/>
    </span>
  </xsl:template>

  <!-- make rend class -->
  <xsl:template match="*/@rend" priority="-1"  mode="transcription">
    <xsl:attribute name="class">
      <xsl:value-of select="concat(parent::node()/name(), ' ')"/>
      <xsl:value-of select="translate(., '-', '')"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="front|back|body|div|text"  mode="transcription">
    <div class="{concat(name(), ' ', translate(@rend, '-', ''))}">
      <xsl:apply-templates mode="transcription" />
    </div>
  </xsl:template>


  <xsl:template match="p|ab"  mode="transcription">
    <p class="{concat(name(), ' ', translate(@rend, '-', ''))}">
      <xsl:apply-templates mode="transcription"/>
    </p>
  </xsl:template>


  <!-- exclude those inside notes -->
  <xsl:template match="lb[not(ancestor::note)]"  mode="transcription">
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

  <xsl:template match="choice"  mode="transcription">
    <span class="choice">
      <xsl:apply-templates  mode="transcription"/>
    </span>
  </xsl:template>
  
  <xsl:template match="choice/abbr"  mode="transcription">
    <span class="abbr diplomatic">
      <xsl:if test="../expan">
        <xsl:attribute name="title">expan: <xsl:value-of select="../expan"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates  mode="transcription"/>
    </span>
  </xsl:template>
  <xsl:template match="choice/expan"  mode="transcription">
    <span class="abbr edited hidden">
      <xsl:if test="../abbr">
        <xsl:attribute name="title">expan: <xsl:value-of select="."/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="../abbr[1]/node()"  mode="transcription"/>
    </span>
  </xsl:template>
  <xsl:template match="choice/orig"  mode="transcription">
    <span class="orig diplomatic">
      <xsl:if test="../reg">
        <xsl:attribute name="title">reg: <xsl:value-of select="../reg"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates  mode="transcription"/>
    </span>
  </xsl:template>
  <xsl:template match="choice/reg"  mode="transcription">
    <span class="reg edited hidden">
      <xsl:if test="../orig">
        <xsl:attribute name="title">orig: <xsl:value-of select="../orig"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="../orig/node()"  mode="transcription"/>
    </span>
  </xsl:template>
  <xsl:template match="choice/sic"  mode="transcription">
    <span class="sic diplomatic ">
      <xsl:if test="../corr">
        <xsl:attribute name="title">corr: <xsl:value-of select="../corr"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates  mode="transcription"/>
    </span>
  </xsl:template>
  <xsl:template match="choice/corr"  mode="transcription">
    <span class="corr edited hidden">
      <xsl:if test="../sic">
        <xsl:attribute name="title">sic: <xsl:value-of select="../sic"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates  mode="transcription"/>
    </span>
  </xsl:template>



<!-- app: show first rdg -->
  <xsl:template match="app"  mode="transcription">
  <span class="app">
    <xsl:attribute name="title">
      <xsl:for-each select="rdg">
        <xsl:value-of select="concat(name(),': ', ., '; ')"/>
      </xsl:for-each>
    </xsl:attribute>
    <xsl:apply-templates select="rdg[1]"  mode="transcription"/>
  </span>
</xsl:template>
  


  <xsl:template match="del[@type='cancelled']"  mode="transcription">
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
      <xsl:apply-templates  mode="transcription"/>
    </span>
  </xsl:template>
  
  
 
    
  <!-- foreign should be italiced in edited view -->
  <xsl:template match="foreign" xml:space="preserve"  mode="transcription"><span class="foreign diplomatic"><xsl:if test="@xml:lang"><xsl:attribute name="title"><xsl:value-of select="concat('lang: ', @xml:lang)"/></xsl:attribute></xsl:if><xsl:apply-templates mode="transcription"/></span><span class="foreign foreignItalic edited hidden" style="font-style:italic;"><xsl:if test="@xml:lang"><xsl:attribute name="title"><xsl:value-of select="concat('lang: ', @xml:lang)"/></xsl:attribute></xsl:if><xsl:apply-templates  mode="transcription"/></span></xsl:template>

  <xsl:template match="figure"  mode="transcription">
    <span class="figure" title="{concat(head, ';  ', figDesc)}">[Illustration] <xsl:apply-templates  mode="transcription"/></span>
  </xsl:template>
  <xsl:template match="figure/head|figure/figDesc"  mode="transcription"/>
  
  
  
  <xsl:template match="gap[@extent][@unit]|space[@extent][@unit]" priority="10"  mode="transcription">
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
  
  <xsl:template match="space[@extent][@unit][@dim='vertical']" priority="1"  mode="transcription">
        <span class="space vertical verticalSpace"><xsl:attribute name="title"><xsl:for-each select="@*">
            <xsl:sort/>
            <xsl:value-of select="concat(name(),': ', ., '; ')"/>
          </xsl:for-each></xsl:attribute>
          <xsl:for-each select="1 to @extent"><br class="verticalSpace"/></xsl:for-each>
        </span>
  </xsl:template>
  
  
  
  
  
  <!-- do not show graphic -->
  <xsl:template match="graphic"  mode="transcription"/>
    
  
  
  <xsl:template match="head"  mode="transcription">
    <xsl:variable name="num" select="count(ancestor::*)"/>
    <xsl:element name="{concat('h', $num)}">
      <xsl:apply-templates select="@*|node()"  mode="transcription"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="figure/head"  mode="transcription">
    <span class="figHead">
      <xsl:apply-templates  mode="transcription"/>
    </span>
  </xsl:template>
  
  <xsl:template match="list"  mode="transcription">
    <ul><xsl:apply-templates  mode="transcription"/></ul>
  </xsl:template>
  
  <xsl:template match="list/item"  mode="transcription">
    <li><xsl:apply-templates  mode="transcription"/></li>
  </xsl:template>


  <xsl:template match="milestone"  mode="transcription">
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


<!--<xsl:template match="jc:page">
<div class="page">
  <hr/>
  <span class="pb-title">Image: <xsl:value-of select="@n"/></span>
<xsl:apply-templates/>  
  </div>
</xsl:template>
-->  

<!-- Shouldn't fire in this version. -->
  <xsl:template match="pb"  mode="transcription">
    <hr/>
    <span class="pb-title">Image: <xsl:value-of select="@n"/></span>
  </xsl:template>
  
  

  <xsl:template match="supplied"  mode="transcription">
    <span class="supplied edited hidden"><xsl:if test="@*">
      <xsl:attribute name="title">
        <xsl:value-of select="concat(name(), ':  ')"/>
        <xsl:for-each select="@*">
          <xsl:sort/>
          <xsl:value-of select="concat(name(),': ', ., '; ')"/>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:if>
      [<xsl:apply-templates select="node()"  mode="transcription"/>]</span>
  </xsl:template>
  
  


  <xsl:template match="table" mode="transcription">
    <table>
      <xsl:apply-templates select="@*|node()"  mode="transcription"/>
    </table>
  </xsl:template>
  <xsl:template match="row" mode="transcription">
    <tr>
      <xsl:apply-templates select="@*|node()" mode="transcription"/>
    </tr>
  </xsl:template>
<xsl:template match="cell" mode="transcription">
    <td>
      <xsl:apply-templates select="@*|node()" mode="transcription"/>
    </td>
  </xsl:template>


<xsl:template match="term[@type]" priority="1" mode="transcription">
 <span class="term" title="{@type}"><xsl:apply-templates mode="transcription"/></span> 
</xsl:template>
  


  <xsl:template match="unclear" mode="transcription">
    <span class="unclear"><xsl:if test="@*">
      <xsl:attribute name="title">
        <xsl:value-of select="concat(name(), ':  ')"/>
        <xsl:for-each select="@*">
          <xsl:sort/>
          <xsl:value-of select="concat(name(),': ', ., '; ')"/>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="transcription"/></span>
  </xsl:template>
  

  
  
  
  

</xsl:stylesheet>
