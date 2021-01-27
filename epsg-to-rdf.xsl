<?xml version="1.0" encoding="UTF-8"?>

<!--

  Copyright 2016-2021 EUROPEAN UNION
  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by
  the European Commission - subsequent versions of the EUPL (the "Licence");
  You may not use this work except in compliance with the Licence.
  You may obtain a copy of the Licence at:

  https://joinup.ec.europa.eu/collection/eupl

  Unless required by applicable law or agreed to in writing, software
  distributed under the Licence is distributed on an "AS IS" basis,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the Licence for the specific language governing permissions and
  limitations under the Licence.

  Authors:      European Commission, Joint Research Centre (JRC)
                Andrea Perego (https://github.com/andrea-perego)

  Contributors: ISA GeoDCAT-AP Working Group (https://github.com/SEMICeu/geodcat-ap) 

  This work was supported by the EU Interoperability Solutions for
  European Public Administrations Programme (http://ec.europa.eu/isa)
  through Action 1.17: Re-usable INSPIRE Reference Platform
  (http://ec.europa.eu/isa/actions/01-trusted-information-exchange/1-17action_en.htm).

-->

<!--

  PURPOSE AND USAGE

  This XSLT is a proof of concept for the RDF representation of the OGC EPSG
  register of coordinate reference systems, extending the RDF mappings for
  reference systems defined in the geospatial profile of DCAT-AP (GeoDCAT-AP), 
  available on Joinup, the collaboration platform of the EU ISA Programme:

    https://joinup.ec.europa.eu/node/139283/

  As such, this XSLT must be considered as unstable, and can be updated any
  time based on the revisions to the GeoDCAT-AP specifications and
  related work in the framework of INSPIRE and the EU ISA Programme.

-->

<xsl:transform
    xmlns:cnt    = "http://www.w3.org/2011/content#"
    xmlns:dc     = "http://purl.org/dc/elements/1.1/"
    xmlns:dct    = "http://purl.org/dc/terms/"
    xmlns:dctype = "http://purl.org/dc/dcmitype/"
    xmlns:epsg   = "urn:x-ogp:spec:schema-xsd:EPSG:1.0:dataset"
    xmlns:crs-nts = "http://www.opengis.net/crs-nts/1.0"
    xmlns:owl    = "http://www.w3.org/2002/07/owl#"
    xmlns:rdf    = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs   = "http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos   = "http://www.w3.org/2004/02/skos/core#"
    xmlns:xsl    = "http://www.w3.org/1999/XSL/Transform"
    xmlns:earl   = "http://www.w3.org/ns/earl#"
    xmlns:dcat   = "http://www.w3.org/ns/dcat#"
    xmlns:foaf   = "http://xmlns.com/foaf/0.1/"
    xmlns:wdrs   = "http://www.w3.org/2007/05/powder-s#"
    xmlns:prov   = "http://www.w3.org/ns/prov#"
    xmlns:vcard  = "http://www.w3.org/2006/vcard/ns#"
    xmlns:adms   = "http://www.w3.org/ns/adms#"
    xmlns:gsp    = "http://www.opengis.net/ont/geosparql#"
    xmlns:locn   = "http://www.w3.org/ns/locn#"
    xmlns:gmd    = "http://www.isotc211.org/2005/gmd"
    xmlns:gmx    = "http://www.isotc211.org/2005/gmx"
    xmlns:gco    = "http://www.isotc211.org/2005/gco"
    xmlns:srv    = "http://www.isotc211.org/2005/srv"
    xmlns:xsi    = "http://www.w3.org/2001/XMLSchema-instance"
    xmlns:gml    = "http://www.opengis.net/gml/3.2"
    xmlns:xlink  = "http://www.w3.org/1999/xlink"
    xmlns:igp    = "http://inspire.ec.europa.eu/schemas/geoportal/1.0"
    xmlns:i      = "http://inspire.ec.europa.eu/schemas/common/1.0"
    xmlns:schema = "http://schema.org/"
    exclude-result-prefixes="cnt dctype epsg crs-nts xsl earl dcat foaf wdrs prov vcard adms gsp gmd gmx gco srv xsi gml xlink igp i schema"
    version="1.0">

  <xsl:output 
    method="xml"
    indent="yes"
    encoding="utf-8"
    cdata-section-elements="locn:geometry dcat:bbox" />

<!--

  Global variables
  ================

-->

<!-- Variables $core and $extended. -->
<!--

  These variables are meant to be placeholders for the IDs used for the core and extended profiles of GeoDCAT-AP.

-->

  <xsl:param name="epsg-register-uri">http://www.opengis.net/def/crs/EPSG/0</xsl:param>


<!-- Variables to be used to convert strings into lower/uppercase by using the translate() function. -->

  <xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<!-- URIs and URNs for spatial reference system registers. -->

  <xsl:param name="EpsgSrsBaseUri">http://www.opengis.net/def/crs/EPSG/0/</xsl:param>
  <xsl:param name="EpsgSrsBaseUrn">urn:ogc:def:crs:EPSG</xsl:param>
  <xsl:param name="OgcSrsBaseUri">http://www.opengis.net/def/crs/OGC/</xsl:param>
  <xsl:param name="OgcSrsBaseUrn">urn:ogc:def:crs:OGC</xsl:param>

<!-- URI and URN for CRS84. -->

  <xsl:param name="Crs84Uri" select="concat($OgcSrsBaseUri,'1.3/CRS84')"/>
  <xsl:param name="Crs84Urn" select="concat($OgcSrsBaseUrn,':1.3:CRS84')"/>

<!-- URI and URN for ETRS89. -->

  <xsl:param name="Etrs89Uri" select="concat($EpsgSrsBaseUri,'4258')"/>
  <xsl:param name="Etrs89Urn" select="concat($EpsgSrsBaseUrn,'::4258')"/>

<!-- URI and URN of the spatial reference system (SRS) used in the bounding box.
     The default SRS is CRS84. If a different SRS is used, also parameter
     $SrsAxisOrder must be specified. -->

<!-- The SRS URI is used in the WKT and GML encodings of the bounding box. -->
  <xsl:param name="SrsUri" select="$Crs84Uri"/>
<!-- The SRS URN is used in the GeoJSON encoding of the bounding box. -->
  <xsl:param name="SrsUrn" select="$Crs84Urn"/>

<!-- Axis order for the reference SRS:
     - "LonLat": longitude / latitude
     - "LatLon": latitude / longitude.
     The axis order must be specified only if the reference SRS is different from CRS84.
     If the reference SRS is CRS84, this parameter is ignored. -->

  <xsl:param name="SrsAxisOrder">LonLat</xsl:param>

<!-- Namespaces -->

  <xsl:param name="xsd">http://www.w3.org/2001/XMLSchema#</xsl:param>
  <xsl:param name="dct">http://purl.org/dc/terms/</xsl:param>
  <xsl:param name="dctype">http://purl.org/dc/dcmitype/</xsl:param>
  <xsl:param name="skos">http://www.w3.org/2004/02/skos/core#</xsl:param>
<!-- Currently not used.
  <xsl:param name="timeUri">http://placetime.com/</xsl:param>
  <xsl:param name="timeInstantUri" select="concat($timeUri,'instant/gregorian/')"/>
  <xsl:param name="timeIntervalUri" select="concat($timeUri,'interval/gregorian/')"/>
-->
  <xsl:param name="dcat">http://www.w3.org/ns/dcat#</xsl:param>
  <xsl:param name="gsp">http://www.opengis.net/ont/geosparql#</xsl:param>
  <xsl:param name="op">http://publications.europa.eu/resource/authority/</xsl:param>
  <xsl:param name="opcountry" select="concat($op,'country/')"/>
  <xsl:param name="oplang" select="concat($op,'language/')"/>
  <xsl:param name="opcb" select="concat($op,'corporate-body/')"/>
  <xsl:param name="opfq" select="concat($op,'frequency/')"/>
  <xsl:param name="cldFrequency">http://purl.org/cld/freq/</xsl:param>
<!-- This is used as the datatype for the GeoJSON-based encoding of the bounding box. -->
  <xsl:param name="geojsonMediaTypeUri">https://www.iana.org/assignments/media-types/application/vnd.geo+json</xsl:param>

<!-- INSPIRE code list URIs -->

  <xsl:param name="INSPIRECodelistUri">http://inspire.ec.europa.eu/metadata-codelist/</xsl:param>
  <xsl:param name="SpatialDataServiceCategoryCodelistUri" select="concat($INSPIRECodelistUri,'SpatialDataServiceCategory')"/>
  <xsl:param name="DegreeOfConformityCodelistUri" select="concat($INSPIRECodelistUri,'DegreeOfConformity')"/>
  <xsl:param name="ResourceTypeCodelistUri" select="concat($INSPIRECodelistUri,'ResourceType')"/>
  <xsl:param name="ResponsiblePartyRoleCodelistUri" select="concat($INSPIRECodelistUri,'ResponsiblePartyRole')"/>
  <xsl:param name="SpatialDataServiceTypeCodelistUri" select="concat($INSPIRECodelistUri,'SpatialDataServiceType')"/>
  <xsl:param name="TopicCategoryCodelistUri" select="concat($INSPIRECodelistUri,'TopicCategory')"/>

<!-- INSPIRE code list URIs (not yet supported; the URI pattern is tentative) -->

  <xsl:param name="SpatialRepresentationTypeCodelistUri" select="concat($INSPIRECodelistUri,'SpatialRepresentationTypeCode')"/>
  <xsl:param name="MaintenanceFrequencyCodelistUri" select="concat($INSPIRECodelistUri,'MaintenanceFrequencyCode')"/>

<!-- INSPIRE glossary URI -->

  <xsl:param name="inspire-glossary-uri">http://inspire.ec.europa.eu/glossary/</xsl:param>

<!--

  Master template
  ===============

 -->

  <xsl:template match="/">
    <rdf:RDF>
      <xsl:apply-templates select="crs-nts:identifiers"/>
      <xsl:apply-templates select="gml:GeodeticCRS|gml:VerticalCRS|gml:ProjectedCRS|gml:DerivedCRS|gml:CompoundCRS|gml:EngineeringCRS|gml:ImageCRS|gml:TemporalCRS"/>
    </rdf:RDF>
  </xsl:template>

<!-- Reference system register -->

  <xsl:template match="crs-nts:identifiers">
    <skos:ConceptScheme rdf:about="{$epsg-register-uri}">
      <skos:prefLabel xml:lang="en">OGC EPSG Coordinate Reference System Register</skos:prefLabel>
      <rdfs:label xml:lang="en">OGC EPSG Coordinate Reference System Register</rdfs:label>
      <dct:title xml:lang="en">OGC EPSG Coordinate Reference System Register</dct:title>
      <dct:source rdf:resource="https://www.epsg-registry.org/"/>
      <dct:publisher rdf:resource="http://www.opengeospatial.org/"/>
      <xsl:for-each select="crs-nts:identifier">
        <skos:hasTopConcept rdf:resource="{.}"/>
      </xsl:for-each>
    </skos:ConceptScheme>
  </xsl:template>

<!-- Reference systems -->

  <xsl:template match="gml:GeodeticCRS|gml:VerticalCRS|gml:ProjectedCRS|gml:DerivedCRS|gml:CompoundCRS|gml:EngineeringCRS|gml:ImageCRS|gml:TemporalCRS">
    <xsl:param name="uri" select="gml:identifier"/>
    <xsl:param name="urn" select="concat($EpsgSrsBaseUrn,'::',substring-after($uri,$EpsgSrsBaseUri))"/>
    <rdf:Description rdf:about="{$uri}">
      <rdf:type rdf:resource="{$skos}Concept"/>
      <rdf:type rdf:resource="{$dct}Standard"/>
      <xsl:choose>
        <xsl:when test="name() = 'gml:TemporalCRS'">
          <dct:type rdf:resource="{$inspire-glossary-uri}TemporalReferenceSystem"/>
        </xsl:when>
        <xsl:otherwise>
          <dct:type rdf:resource="{$inspire-glossary-uri}SpatialReferenceSystem"/>
        </xsl:otherwise>
      </xsl:choose>
      <dct:identifier rdf:datatype="{$xsd}anyURI"><xsl:value-of select="$uri"/></dct:identifier>
      <owl:sameAs rdf:resource="{$urn}"/>
      <skos:inScheme rdf:resource="{$epsg-register-uri}"/>
      <skos:topConceptOf rdf:resource="{$epsg-register-uri}"/>
      <skos:prefLabel xml:lang="en"><xsl:value-of select="gml:name"/></skos:prefLabel>
      <rdfs:label xml:lang="en"><xsl:value-of select="gml:name"/></rdfs:label>
      <dct:title xml:lang="en"><xsl:value-of select="gml:name"/></dct:title>
      <skos:scopeNote xml:lang="en"><xsl:value-of select="gml:scope"/></skos:scopeNote>
      <xsl:if test="gml:remarks">
        <rdfs:comment xml:lang="en"><xsl:value-of select="gml:remarks"/></rdfs:comment>
      </xsl:if>
      <dc:type xml:lang="en"><xsl:value-of select="gml:metaDataProperty/epsg:CommonMetaData/epsg:type"/></dc:type>
      <dc:source xml:lang="en"><xsl:value-of select="gml:metaDataProperty/epsg:CommonMetaData/epsg:informationSource"/></dc:source>
      <dct:modified rdf:datatype="{$xsd}dateTime"><xsl:value-of select="gml:metaDataProperty/epsg:CommonMetaData/epsg:revisionDate"/></dct:modified>
      <owl:deprecated rdf:datatype="{$xsd}boolean"><xsl:value-of select="gml:metaDataProperty/epsg:CommonMetaData/epsg:isDeprecated"/></owl:deprecated>
      <xsl:apply-templates select="gml:metaDataProperty/epsg:CommonMetaData/epsg:changes/*"/>
      <xsl:for-each select="epsg:AreaOfUse">
        <dct:spatial>
          <dct:Location>
            <rdfs:label xml:lang="en"><xsl:value-of select="gmd:description/*"/></rdfs:label>
            <xsl:apply-templates select="gmd:geographicElement/gmd:EX_GeographicBoundingBox"/>
          </dct:Location>
        </dct:spatial> 
      </xsl:for-each>
    </rdf:Description>
  </xsl:template>

<!-- Change requests -->

  <xsl:template match="gml:metaDataProperty/epsg:CommonMetaData/epsg:changes/*">
    <xsl:choose>
      <xsl:when test="name() = 'epsg:ChangeRequest'">
        <xsl:variable name="id" select="@gml:id"/>
        <skos:changeNote rdf:resource="{concat('http://www.opengis.net/def/change-request/EPSG/0/',substring($id,9))}"/>
      </xsl:when>
      <xsl:when test="@xlink:href">
        <skos:changeNote rdf:resource="{@xlink:href}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
<!-- Bounding box -->  
  
  <xsl:template name="GeographicBoundingBox" match="gmd:geographicElement/gmd:EX_GeographicBoundingBox">
    <xsl:param name="north" select="gmd:northBoundLatitude/gco:Decimal"/>
    <xsl:param name="east"  select="gmd:eastBoundLongitude/gco:Decimal"/>
    <xsl:param name="south" select="gmd:southBoundLatitude/gco:Decimal"/>
    <xsl:param name="west"  select="gmd:westBoundLongitude/gco:Decimal"/>

<!-- Bbox as a dct:Box -->
<!-- Need to check whether this is correct - in particular, the "projection" parameter -->
<!--
    <xsl:param name="DCTBox">northlimit=<xsl:value-of select="$north"/>; eastlimit=<xsl:value-of select="$east"/>; southlimit=<xsl:value-of select="$south"/>; westlimit=<xsl:value-of select="$west"/>; projection=EPSG:<xsl:value-of select="$srid"/></xsl:param>
-->

<!-- Bbox as GML (GeoSPARQL) -->

    <xsl:param name="GMLLiteral">
      <xsl:choose>
        <xsl:when test="$SrsUri = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84'">&lt;gml:Envelope srsName="<xsl:value-of select="$SrsUri"/>"&gt;&lt;gml:lowerCorner&gt;<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>&lt;/gml:lowerCorner&gt;&lt;gml:upperCorner&gt;<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>&lt;/gml:upperCorner&gt;&lt;/gml:Envelope&gt;</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LonLat'">&lt;gml:Envelope srsName="<xsl:value-of select="$SrsUri"/>"&gt;&lt;gml:lowerCorner&gt;<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>&lt;/gml:lowerCorner&gt;&lt;gml:upperCorner&gt;<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>&lt;/gml:upperCorner&gt;&lt;/gml:Envelope&gt;</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LatLon'">&lt;gml:Envelope srsName="<xsl:value-of select="$SrsUri"/>"&gt;&lt;gml:lowerCorner&gt;<xsl:value-of select="$south"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>&lt;/gml:lowerCorner&gt;&lt;gml:upperCorner&gt;<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$east"/>&lt;/gml:upperCorner&gt;&lt;/gml:Envelope&gt;</xsl:when>
      </xsl:choose>
    </xsl:param>

<!-- Bbox as WKT (GeoSPARQL) -->

    <xsl:param name="WKTLiteral">
      <xsl:choose>
        <xsl:when test="$SrsUri = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84'">POLYGON((<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>))</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LonLat'">&lt;<xsl:value-of select="$SrsUri"/>&gt; POLYGON((<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>))</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LatLon'">&lt;<xsl:value-of select="$SrsUri"/>&gt; POLYGON((<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>,<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$east"/>,<xsl:value-of select="$south"/><xsl:text> </xsl:text><xsl:value-of select="$east"/>,<xsl:value-of select="$south"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>,<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>))</xsl:when>
        </xsl:choose>
    </xsl:param>

<!-- Bbox as GeoJSON -->

    <xsl:param name="GeoJSONLiteral">{"type":"Polygon","crs":{"type":"name","properties":{"name":"<xsl:value-of select="$SrsUrn"/>"}},"coordinates":[[[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>],[<xsl:value-of select="$east"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>],[<xsl:value-of select="$east"/><xsl:text>,</xsl:text><xsl:value-of select="$south"/>],[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$south"/>],[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>]]]}</xsl:param>

<!-- Recommended geometry encodings -->
<!--
    <locn:geometry rdf:datatype="{$gsp}wktLiteral"><xsl:value-of select="$WKTLiteral"/></locn:geometry>
    <locn:geometry rdf:datatype="{$gsp}gmlLiteral"><xsl:value-of select="$GMLLiteral"/></locn:geometry>
-->
    <dcat:bbox rdf:datatype="{$gsp}wktLiteral"><xsl:value-of select="$WKTLiteral"/></dcat:bbox>
    <dcat:bbox rdf:datatype="{$gsp}gmlLiteral"><xsl:value-of select="$GMLLiteral"/></dcat:bbox>
<!-- Additional geometry encodings -->
<!--
    <locn:geometry rdf:datatype="{$geojsonMediaTypeUri}"><xsl:value-of select="$GeoJSONLiteral"/></locn:geometry>
-->
    <dcat:bbox rdf:datatype="{$gsp}geoJSONLiteral"><xsl:value-of select="$GeoJSONLiteral"/></dcat:bbox>
<!--
      <locn:geometry rdf:datatype="{$dct}Box"><xsl:value-of select="$DCTBox"/></locn:geometry>
-->
  </xsl:template>
  

</xsl:transform>
