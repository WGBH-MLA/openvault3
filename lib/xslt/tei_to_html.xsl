<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:smil="http://www.w3.org/2001/SMIL20/Language"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="tei smil">
  <xsl:output method="html" encoding="utf-8" indent="yes" />
  <xsl:variable name="persNames" select="//tei:person" />
  <xsl:key name="teiRef" match="//tei:term" use="@xml:id" />

  <xsl:template match="/">
    <div class="transcript">
      <xsl:apply-templates match="tei:body"/>
    </div>
  </xsl:template>

  <xsl:template match="tei:body">
    <div>
      <xsl:apply-templates select="tei:div"></xsl:apply-templates>
      <xsl:text>&#xa;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="tei:div">
    <div>
      <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
      <xsl:variable name="id">#<xsl:value-of select="@xml:id" /></xsl:variable>
      <xsl:apply-templates select="//tei:spanGrp[@type='title']/tei:span[@from=$id]" mode="teiheader"/>
      <xsl:apply-templates mode="teibody"/>
      <xsl:text>&#xa;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="tei:div" mode="teibody">
    <div>
      <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
      <xsl:variable name="id">#<xsl:value-of select="@xml:id" /></xsl:variable>
      <xsl:apply-templates select="//tei:spanGrp[@type='title']/tei:span[@from=$id]" mode="teiheader"/>
      <xsl:apply-templates mode="teibody"/>
      <xsl:text>&#xa;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="tei:spanGrp[@type='title']/tei:span" mode="teiheader">
    <h3><xsl:value-of select="." /></h3>
  </xsl:template>

  <xsl:template match="tei:incident" mode="teibody">
    <div class="incident">
      <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
      <xsl:if test="@smil:begin"><xsl:attribute name="data-timecodebegin"><xsl:value-of select="@smil:begin" /></xsl:attribute></xsl:if>
      <xsl:if test="@smil:end"><xsl:attribute name="data-timecodeend"><xsl:value-of select="@smil:end" /></xsl:attribute></xsl:if>
      <xsl:apply-templates mode="seg" />
    </div>
  </xsl:template>

  <xsl:template match="tei:u[@who]" mode="teibody">
    <div>
      <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
      <xsl:variable name="who" select="substring(@who,2)" />
      <strong>
	<xsl:attribute name="class">speaker <xsl:value-of select="$who" /></xsl:attribute>
        <xsl:choose>
          <xsl:when test="contains($persNames[@xml:id=$who]/tei:persName, ',')">
            <xsl:value-of 
              select="substring-before($persNames[@xml:id=$who]/tei:persName, ',')" />:</xsl:when>
          <xsl:when test="string-length($persNames[@xml:id=$who]/tei:persName) = 0" />
          <xsl:otherwise>
            <xsl:value-of
              select="$persNames[@xml:id=$who]/tei:persName" />:</xsl:otherwise>
        </xsl:choose>
      </strong>
      <xsl:apply-templates mode="teibody" />
      <xsl:text>&#xa;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="tei:seg" mode="teibody">
    <div>
      <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
      <xsl:attribute name="class">para</xsl:attribute>
      <xsl:if test="@smil:begin"><xsl:attribute name="data-timecodebegin"><xsl:value-of select="@smil:begin" /></xsl:attribute></xsl:if>
      <xsl:if test="@smil:end"><xsl:attribute name="data-timecodeend"><xsl:value-of select="@smil:end" /></xsl:attribute></xsl:if>
      <xsl:if test="@smil:begin">
        <span class="play-from-here">
          <xsl:attribute name="data-timecode"><xsl:value-of select="@smil:begin" /></xsl:attribute>
        </span>
      </xsl
      <xsl:apply-templates mode="seg" />
      <xsl:text>&#xa;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="tei:name" mode="seg">
    <xsl:variable name="ref" select="key('teiRef', substring-after(@ref, '#'))"/>
    <xsl:variable name="href" select="$ref/@xhtml:href"/>
    <!--
      Given a list of URLs, this gives the first few from each domain:
        for D in `perl -pne 's{https?://}{};s{/.*}{}' all_urls.txt | sort | uniq `; 
          do grep $D all_urls.txt | head -n3
          echo
        done
        
      authorities.loc.gov is down, and lcsh.info has turned into a German freeware site.
    -->
    <xsl:choose>
      <xsl:when test="contains($href, '//lcsh.info') or contains($href, '//authorities.loc.gov')">
        <xsl:apply-templates mode="seg" />
      </xsl:when>
      <xsl:otherwise>
        <a>
          <xsl:attribute name="href"><xsl:value-of select="$href" /></xsl:attribute>
          <xsl:attribute name="title"><xsl:value-of select="$ref" /></xsl:attribute>
          <xsl:attribute name="target">_blank</xsl:attribute>
          <xsl:apply-templates mode="seg" />
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:date" mode="seg">
    <span>
      <xsl:attribute name="class">tei-date</xsl:attribute>
      <xsl:if test="@when"><xsl:attribute name="title"><xsl:value-of select="@when" /></xsl:attribute></xsl:if>
      <xsl:apply-templates mode="seg" />
    </span>
  </xsl:template>

  <xsl:template match="tei:quote" mode="seg">
    <blockquote>
      <xsl:apply-templates mode="seg" />
    </blockquote>
  </xsl:template>

  <xsl:template match="tei:bibl" mode="seg">
    <span class="tei-bibl"><xsl:apply-templates mode="seg" /></span>
  </xsl:template>

  <xsl:template match="tei:l" mode="seg">
    <span class="tei-l"><xsl:apply-templates mode="seg" /></span>
  </xsl:template>

  <xsl:template match="tei:choice[tei:sic]" mode="seg">
    <xsl:apply-templates mode="seg" select="tei:sic" /> <span class="tei-sic"> [sic]</span>
  </xsl:template>

  <xsl:template match="tei:lb" mode="seg"><br /></xsl:template>
<!--
  <xsl:template match="tei:" mode="seg">
    <xsl:apply-templates mode="seg" />
  </xsl:template>
-->

  <xsl:template match="text()" mode="seg"><xsl:value-of select="." /></xsl:template>

  <xsl:template match="text()" />
</xsl:stylesheet>
