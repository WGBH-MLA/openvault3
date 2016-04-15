<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:smil="http://www.w3.org/2001/SMIL20/Language"
  exclude-result-prefixes="tei smil xsl">
  <xsl:variable name="persNames" select="//tei:person" />
  <xsl:key name="teiRef" match="//tei:term" use="@xml:id" />

  <!-- Construct a simpler XML representation which we can walk with Nokogiri. -->
  
  <xsl:template match="/">
    <transcript><xsl:apply-templates match="tei:body"/></transcript>
  </xsl:template>

  <xsl:template match="tei:body">
      <xsl:apply-templates select="tei:div"></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="tei:div">
      <xsl:apply-templates mode="teibody"/>
  </xsl:template>

  <xsl:template match="tei:div" mode="teibody">
      <xsl:apply-templates mode="teibody"/>
  </xsl:template>

  <xsl:template match="tei:seg" mode="teibody">
    <segment>
      <begin><xsl:value-of select="@smil:begin" /></begin>
      <end><xsl:value-of select="@smil:end" /></end>
      <speaker>
        <xsl:variable name="who" select="substring(../@who,2)" />
        <xsl:choose>
          <xsl:when test="contains($persNames[@xml:id=$who]/tei:persName, ',')">
            <xsl:value-of 
              select="substring-before($persNames[@xml:id=$who]/tei:persName, ',')" />:</xsl:when>
          <xsl:when test="string-length($persNames[@xml:id=$who]/tei:persName) = 0" />
          <xsl:otherwise>
            <xsl:value-of
              select="$persNames[@xml:id=$who]/tei:persName" /></xsl:otherwise>
        </xsl:choose>
      </speaker>
      <text><xsl:apply-templates mode="seg" /></text>
    </segment>
  </xsl:template>

  <xsl:template match="tei:name" mode="seg">
    <xsl:apply-templates mode="seg" />
  </xsl:template>

  <xsl:template match="tei:date" mode="seg">
    <xsl:apply-templates mode="seg" />
  </xsl:template>

  <xsl:template match="tei:quote" mode="seg">
    <xsl:apply-templates mode="seg" />
  </xsl:template>

  <xsl:template match="tei:bibl" mode="seg">
    <xsl:apply-templates mode="seg" />
  </xsl:template>

  <xsl:template match="tei:l" mode="seg">
    <xsl:apply-templates mode="seg" />
  </xsl:template>

  <xsl:template match="tei:choice[tei:sic]" mode="seg">
    <xsl:apply-templates mode="seg" select="tei:sic" />[sic]
  </xsl:template>

  <xsl:template match="text()" mode="seg"><xsl:value-of select="." /></xsl:template>

  <xsl:template match="text()" />
</xsl:stylesheet>

