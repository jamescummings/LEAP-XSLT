<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xd tei" version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>First created on:</xd:b> Dec 1, 2014</xd:p>
      <xd:p><xd:b>Author:</xd:b> jamesc</xd:p>
      <xd:p>First attempt at LEAP to HTML conversion</xd:p>
      <xd:p>Updated in Feb/Mar 2015.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output method="xml" indent="yes"/>


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
        <h2>
          <xsl:value-of select="//teiHeader//title[1]"/>
        </h2>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  
  <!-- Don't show -->
  <xsl:template match="teiHeader | facsimile |surface |zone"/>
  
  
  <xsl:template match="TEI">
    <div class="TEI">
      <button id="toggle" title="toSggle" type="button" class="hidden">Toggle Diplomatic/Edited</button>
      <xsl:apply-templates select="text"/>
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
  
  
  
  <xsl:template match="gap[@extent][@unit]|space[@extent][@unit]">
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


  <xsl:template match="pb">
    <hr/>
    <span class="pb-title">Image: <xsl:value-of select="@n"/></span>
  </xsl:template>
  




  <xsl:template match="supplied">
    <span class="supplied">[<xsl:apply-templates select="node()"/>]</span>
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


  




  <!-- 

@place= 
above: shrinking raising 
below shrinking lower
marginleft float
marginright
over-text =  possible to add over previous text? or add in regular text, deleted word next it crossed out.
n
add:

del: strikethrough single line, cancelled is multiple lines? possible?

addSpan/delSpan: same

app/rdg: background highlight with tooltip 

table/row/cell: no borders

list/head/item: not bulleted

hi: double-underline (twice) large, slightly larger

figure/head/figDesc: figure 'illustration' head + figDesc as mouseover


milestone: lines across page
note: placed floated with own linebreaks

seg: type = weather  put out as it is.
subst: vanish
supplied: [supplied text]
term: output text
unclear: cert high/low/medium colour code somehow; fuzzy text? color text progressigvely lighter popup saying unclear

colors in @rend = text rendered those colours
    
    Salute/dateline/opener/closer/trailer/signed/address/addline/ postscript/head/fw/
    
    p=rend=noindent not indented
    
    vertical text
    
    space dimension vertical.  space dim="vertical" unit="lines" extent="5"
    
    -->



  <!-- 
    Elements to have templates for:
    ===ordered by module===
    w
    particDesc
    abbr add addrLine address author bibl biblScope biblStruct cb choice corr date del desc editor expan foreign gap gb gloss graphic head hi imprint item label lb list measure measureGrp milestone monogr name note orig p pb pubPlace publisher q quote ref reg resp respStmt sic term title unclear
    figure figDesc table row cell
    authority availability category catDesc change classDecl edition editionStmt encodingDesc fileDesc funder handNote idno keywords langUsage language licence listChange listPrefixDef notesStmt prefixDef principal profileDesc projectDesc publicationStmt rendition revisionDesc sourceDesc styleDefDecl tagsDecl taxonomy textClass teiHeader titleStmt
    ab anchor link linkGrp seg
    accMat acquisition additional adminInfo altIdentifier collection condition custEvent custodialHist decoDesc decoNote depth dim dimensions foliation handDesc height history institution layout layoutDesc locus locusGrp material msContents msDesc msIdentifier msItem msName objectDesc objectType origDate origPlace origin physDesc provenance recordHist repository scriptDesc seal sealDesc signatures stamp summary support supportDesc surrogates width
    addName affiliation age birth bloc country death education event faith forename geo geogFeat geogName listEvent listOrg listPerson listPlace location nationality occupation offset org orgName persName person place placeName region roleName settlement state surname trait
    
    app rdg
    
    TEI back body closer dateline div front
opener postscript salute signed text trailer
    addSpan damage damageSpan delSpan facsimile fw handNotes handShift listTranspose metamark mod redo restore retrace space subst supplied surface surfaceGrp surplus transpose undo zone



==== element templates grouped by potential output ===

span/class='name()' (formatting to be done in CSS)
w
add
address
date (when in text)
del 
desc
editor
foreign

hi
imprint
label (not in list)
measure measureGrp
name  addName forename geogFeat geogName  orgName persName placeName roleName surname
fw
q quote


tooltip:
term
note
gap
desc gloss (make into tooltip?)
seg
damage 
unclear

bibl-related: monogr addrLine author bibl biblScope date pubPlace publisher title

div-like:
quote (when not in p)
TEI back body
p ab closer dateline div front


link: ref

?h[3-5]
head

listLike:
item 
label (in list) list 

Header/metadata:
    particDesc
    biblStruct (used in Spectral inside msDesc)
    date (when in metadata)
    measure measureGrp (when in metadata)
    name 
    resp respStmt
    authority availability category catDesc change classDecl    
    title
    edition editionStmt encodingDesc fileDesc funder handNote idno keywords langUsage language licence listChange listPrefixDef notesStmt prefixDef principal profileDesc projectDesc publicationStmt rendition revisionDesc sourceDesc styleDefDecl tagsDecl taxonomy textClass teiHeader titleStmt
    accMat acquisition additional adminInfo altIdentifier collection condition custEvent custodialHist decoDesc decoNote depth dim dimensions foliation handDesc height history institution layout layoutDesc locus locusGrp material msContents msDesc msIdentifier msItem msName objectDesc objectType origDate origPlace origin physDesc provenance recordHist repository scriptDesc seal sealDesc signatures stamp summary support supportDesc surrogates width affiliation age birth   
bloc country death education event faith geo listEvent listOrg listPerson listPlace location nationality occupation offset org person place region settlement state  trait
handNotes listTranspose

surface surfaceGrp facsimile zone

alternate: orig abbr choice corr expan reg sic


MilestoneLike: cb gb lb milestone pb
link linkGrp

Other:
graphic figure figDesc
table row cell
anchor
app rdg                           
addSpan damageSpan delSpan handShift metamark mod redo restore retrace space subst supplied surplus transpose undo  
     
 place= above, below, bottom, end, inline, inspace, marginleft, margineright, margintop, marginbottom, top
 rend= above, below, caps, center, dropcap, double-line, double-underline, half-line, indent, italic, large, left, line, no-indent, other, quarter-line, right, sub, sup, 
 small, smallcaps, triple-line, underline, upside-down, vertical, black, blue, brown, gray, green, red
 
    
    
    
    
    -->



</xsl:stylesheet>
