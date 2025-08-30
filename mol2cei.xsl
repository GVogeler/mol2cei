<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:cei="http://www.monasterium.net/NS/cei" >
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="filename" select="tokenize(base-uri(),'[/\\]')[last()]"/>
    <xsl:variable name="id" select="replace($filename, '(.*?)\.xml', '$1')"/>

    <!-- 
    Preliminary analysis of TEI xML export from data in https://manus.iccu.sbn.it/memo
    author: Georg Vogeler (University of Graz, Departement of Digital Humanities)
    -->
    
    <xsl:template match="/">
            <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="TEI">
        <cei:cei xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.monasterium.net/NS/cei https://www.monasterium.net/mom/resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/xsd/cei"
            xmlns:cei="http://www.monasterium.net/NS/cei">
            <cei:teiHeader>
                <cei:fileDesc>
                    <cei:titleStmt>
                        <cei:title><xsl:value-of select="teiHeader/fileDesc/titleStmt/title"/></cei:title>
                    </cei:titleStmt>
                    <cei:sourceDesc>
                        <cei:p></cei:p>
                    </cei:sourceDesc>
                </cei:fileDesc>
            </cei:teiHeader>
            <cei:text type="charter">
                <cei:front>
                    <cei:sourceDesc><cei:sourceDescRegest>
                        <xsl:apply-templates select="/TEI/teiHeader" mode="sourceDescRegest"/>
                    </cei:sourceDescRegest></cei:sourceDesc>
                </cei:front>
                <cei:body>
                    <cei:idno>MOL <xsl:value-of select="$id"/></cei:idno>
                    <cei:chDesc>
                        <cei:abstract><!-- FixMe: currently not included in the TEI XML export --></cei:abstract>
                        <cei:issued>
                            <xsl:apply-templates select="teiHeader/fileDesc/sourceDesc/msDesc/history/summary/list/item[roleName='luogo']"/>
                            <xsl:apply-templates select="teiHeader/fileDesc/sourceDesc/msDesc/history/origin/origDate"></xsl:apply-templates>
                        </cei:issued>
                        <!-- Archival description -->
                        <xsl:apply-templates select="teiHeader/fileDesc/sourceDesc/msDesc"/>
                         <cei:diplomaticAnalysis>
                             <xsl:apply-templates select="teiHeader/fileDesc/sourceDesc/msDesc/additional/listBibl"/>
                             <xsl:apply-templates select="teiHeader/fileDesc/sourceDesc/msDesc/physDesc/handDesc"></xsl:apply-templates>
                         </cei:diplomaticAnalysis>
                        <xsl:apply-templates select="teiHeader/profileDesc/langUsage/language"></xsl:apply-templates>
                    </cei:chDesc>
                </cei:body>
                <cei:back>
                    <xsl:apply-templates select="standOff"/>
                </cei:back>
            </cei:text>
        </cei:cei>
    </xsl:template>
    
    <!-- diplomatic analysis -->
    <xsl:template match="profileDesc/langUsage/language">
        <!-- FixMe: add iso-code identifier to lang_MOM in Schema (key="{@ident}") -->
        <xsl:if test="not(preceding-sibling::language=current())"><cei:lang_MOM><xsl:value-of select="."/></cei:lang_MOM></xsl:if>
    </xsl:template>
    <xsl:template match="listBibl[listBibl]">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="listBibl/listBibl[@type='stampa']">
        <cei:listBiblEdition>
            <xsl:apply-templates/>
        </cei:listBiblEdition>
    </xsl:template>
    <xsl:template match="bibl">
        <cei:bibl>
            <xsl:apply-templates/>
        </cei:bibl>
    </xsl:template>
    
    <!-- Indices -->
    <xsl:template match="standOff">
        
    </xsl:template>
    
    <!-- data source description -->
    <xsl:template match="teiHeader" mode="sourceDescRegest">
        <cei:bibl>
            <xsl:apply-templates select="fileDesc/titleStmt" mode="#current"/>
        <xsl:apply-templates select="fileDes/editionStmt" mode="#current"/></cei:bibl>
    </xsl:template>
    <xsl:template match="revisionDesc[@status='Pubblicata']" mode="sourceDescRegest">
        <xsl:apply-templates select="./additional/adminInfo/recordHist/change[@when=max(/additional/adminInfo/recordHist/change/@when)]" mode="#current"/>
    </xsl:template>
    <xsl:template match="change" mode="sourceDescRegest">
        <cei:date><xsl:value-of select="@when"/></cei:date>
    </xsl:template>
    <xsl:template match="titleStmt/title" mode="sourceDescRegest">
        <cei:title><xsl:value-of select="."/></cei:title>
    </xsl:template>
    <xsl:template match="principal" mode="sourceDescRegest">
        <!-- FixMe: tei:principal übernehmen? -->
    </xsl:template>
    <xsl:template match="respStmt" mode="sourceDescRegest">
        <!-- FixMe: respStmt in CEI übernehmen! -->
        <cei:author>
            <xsl:apply-templates select="name" mode="#current"/>
            <xsl:apply-templates select="resp" mode="#current"/>
        </cei:author>
    </xsl:template>
    <xsl:template match="respStmt/resp" mode="sourceDescRegest">
        <!-- FixMe: tei:resp in CEI übernbehmen --><xsl:text>(</xsl:text><xsl:value-of select="."/><xsl:text></xsl:text></xsl:template>
    <xsl:template match="respStmt/name"  mode="sourceDescRegest" >
        <cei:persName><xsl:value-of select="."/></cei:persName>
    </xsl:template>
    <xsl:template match="note" mode="sourceDescRegest">
        <cei:note><xsl:value-of select="."/></cei:note>
    </xsl:template>
    
    <!-- Archival description -->
    <xsl:template match="msDesc">

            <cei:witnessOrig>
                <cei:traditioForm>orig.</cei:traditioForm>
                <xsl:apply-templates select="graphic"/>
                <cei:archIdentifier>
                    <cei:arch>
                        <xsl:apply-templates select="msIdentifier/*[not(self::idno[@type='segnatura'])][not(self::collection)][not(self::altIdentifier)]"/></cei:arch>
                    <xsl:apply-templates select="msIdentifier/collection"/>
                    <xsl:apply-templates select="msIdentifier/idno[@type='segnatura']"/>
                    <xsl:apply-templates select="msIdentifier/altIdentifier"></xsl:apply-templates>
                    <cei:ref target="https://manus.iccu.sbn.it/risultati-ricerca-manoscritti/-/manus-search/detail/{$id}">Charter on the homepage of the archive</cei:ref>
                </cei:archIdentifier>
                <xsl:apply-templates select="/TEI/facsimile//graphic"/>
                <xsl:apply-templates select="physDesc"/>
                <cei:auth><!-- ToDo: Identify where authentication features are included in the MOL export -->
                <xsl:apply-templates select="physDesc/sealDesc"/></cei:auth>
            </cei:witnessOrig>
    </xsl:template>
    <xsl:template match="msIdentifier/altIdentifier">
        <cei:altIdentifier type="{@type}">
            <xsl:value-of select="."/>
        </cei:altIdentifier>
    </xsl:template>
    <xsl:template match="msIdentifier/idno[@type='segnatura']">
        <cei:idno><xsl:value-of select="."/></cei:idno>
    </xsl:template>
    <xsl:template match="msIdentifier/settlement">
        <xsl:value-of select="."/>
        <xsl:text>, </xsl:text>
    </xsl:template>
    <xsl:template match="msIdentifier/institution">
        <xsl:value-of select="."/>
        <xsl:text>, </xsl:text>
    </xsl:template>
    <xsl:template match="msIdentifier/collection">
        <cei:archFond><xsl:value-of select="."/></cei:archFond>
    </xsl:template>
    <!-- Physical Description -->
    <xsl:template match="physDesc">
        <cei:physicalDesc>
            <xsl:apply-templates select="objectDesc/supportDesc"/>
        </cei:physicalDesc>
    </xsl:template>
    <xsl:template match="supportDesc">
        <cei:material><xsl:apply-templates/></cei:material>
    </xsl:template>
    
    <xsl:template match="history/summary/list/item[roleName='luogo']">
        <xsl:variable name="placeRef" select="current()/name/substring-after(@ref,'#')"/>
        <xsl:variable name="place" select="//place[@xml:id=$placeRef]"/>
        <cei:placeName>
            <xsl:if test="$place/placeName/@key">
                <xsl:attribute name="key" select="$place/placeName/@key"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$place!=''">
                    <xsl:value-of select="$place/placeName/string-join(*, ', ')"/>
                </xsl:when>
            </xsl:choose>
        </cei:placeName>
    </xsl:template>
    <xsl:template match="origin/origDate">
        <xsl:variable name="dateMOM">
            <xsl:variable name="whenTokens" select="@when/tokenize(.,'-')"/>
            <xsl:for-each select="$whenTokens">
                <xsl:choose>
                    <xsl:when test="position()>1">
                        <xsl:if test="string-length(.)=1">
                            <xsl:text>0</xsl:text>
                        </xsl:if>
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="replace(.,'^0+(\d+)','$1')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="count($whenTokens)=1">
                    <xsl:text>9999</xsl:text>
                </xsl:when>
                <xsl:when test="count($whenTokens)=2">
                    <xsl:text>99</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <cei:date value="{$dateMOM}"><xsl:value-of select="@when"/></cei:date>
    </xsl:template>
    <xsl:template match="handDesc">
        <cei:scriptDesc>
            <xsl:apply-templates select="summary/state[@type='paleografico-codicologico']"/>
            <xsl:apply-templates select="summary/desc[1]"/>
        </cei:scriptDesc>
    </xsl:template>
    <xsl:template match="handDesc/summary/desc">
        <cei:scribe><xsl:value-of select="."/></cei:scribe>
    </xsl:template>
    <xsl:template match="handDesc/summary/state[@type='paleografico-codicologico']">
        <cei:script><xsl:value-of select="desc/normalize-space()"/></cei:script>
    </xsl:template>
    <xsl:template match="sealDesc">
        <cei:sealDesc>
            <xsl:if test="normalize-space()!=''"><xsl:apply-templates/></xsl:if>
        </cei:sealDesc>
    </xsl:template>
    
    <!-- Images -->
    <xsl:template match="graphic">
        <xsl:variable name="url">
            <!-- @url = manifest => https://manus.iccu.sbn.it/o/manus-api/mirador/?manifest={@url}&amp; für Mirador -->
        </xsl:variable>
        <cei:figure>
            <cei:graphic url="https://manus.iccu.sbn.it/o/manus-api/mirador/?manifest={@url}&amp;"/>
        </cei:figure></xsl:template>
    <xsl:template match="msIdentifier/country|msIdentifier/region|msIdentifier|repository"/>
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>


</xsl:stylesheet>
