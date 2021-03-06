# Purpose and usage

This XSLT is a proof of concept for the RDF representation of the [OGC EPSG register of coordinate reference systems](http://www.opengis.net/def/crs/EPSG/0/), extending the RDF mappings for reference systems defined in GeoDCAT-AP, the geospatial profile of [DCAT-AP](https://joinup.ec.europa.eu/node/63567/) available on Joinup, the collaboration platform of the [EU ISA² Programme](https://ec.europa.eu/isa2/):

https://joinup.ec.europa.eu/solution/geodcat-ap

As such, this XSLT must be considered as unstable, and can be updated any time based on the revisions to the GeoDCAT-AP specifications and related work in the framework of the EU ISA² Programme.

Comments and inquiries should be sent via the [issue tracker](https://github.com/SEMICeu/epsg-to-rdf/issues).

# Content

* [`epsg-to-rdf.xsl`](./epsg-to-rdf.xsl): The code of the XSLT.
* [`examples/`](./examples/): Folder containing examples of the RDF representation generated by the XSLT.
* [`LICENCE.md`](./LICENCE.md): The XSLT's licence.
* [`README.md`](./README.md): This document.

# Implemented mappings

- The OGC EPSG register is typed as a `skos:ConceptScheme`, with each CRS linked via the `skos:hasTopConcept` property.
- Each CRS is typed both as a `skos:Concept` and a `dct:Standard`, with `skos:inScheme` and `skos:topConceptOf` properties pointing to the OGC EPSG register. The fact that the entry is about a CRS is specified by using property `dct:type`, which takes as value the URI from the INSPIRE Glossary for spatial reference systems.

|XPath|RDF property path|
|----|----|
|`gml:identifier`|`dct:identifier` + `skos:notation`|
|`gml:name`|`dct:title` + `skos:prefLabel`|
|`gml:remarks`|`rdfs:comment`|
|`gml:scope`|`skos:scopeNote`|
|`gml:metaDataProperty` / `epsg:CommonMetaData` / `epsg:alias` / `epsg:remarks`|`rdfs:comment`|
|`gml:metaDataProperty` / `epsg:CommonMetaData` / `epsg:changes` / `*`|`skos:changeNote`|
|`gml:metaDataProperty` / `epsg:CommonMetaData` / `epsg:informationSource`|`dc:source`|
|`gml:metaDataProperty` / `epsg:CommonMetaData` / `epsg:isDeprecated`|`owl:deprecated`|
|`gml:metaDataProperty` / `epsg:CommonMetaData` / `epsg:revisionDate`|`dct:modified`|
|`gml:metaDataProperty` / `epsg:CommonMetaData` / `epsg:type`|`dc:type`|
|`gml:metaDataProperty` / `epsg:CommonMetaData` / `epsg:Usage` / `gml:extent`|`dct:spatial`|
|`gml:metaDataProperty` / `epsg:CommonMetaData` / `epsg:Usage` / `gml:scope`|`skos:scopeNote`|
|`epsg:AreaOfUse` / `gmd:description`|`dct:spatial` / `rdfs:label`|
|`epsg:AreaOfUse` / `gmd:geographicElement` / `gmd:EX_GeographicBoundingBox`|`dct:spatial` / `dcat:bbox`|
|`gml:metaDataProperty` / `epsg:CRSMetaData` / `epsg:projectionConversion`|`prov:qualifiedDerivation` / `prov:hadActivity` / `prov:qualifiedAssociation` / `prov:hadPlan`|
|`gml:metaDataProperty` / `epsg:CRSMetaData` / `epsg:sourceGeographicCRS`|`prov:wasDerivedFrom`|
|`gml:conversion`|`prov:qualifiedDerivation` / `prov:hadActivity` / `prov:qualifiedAssociation` / `prov:hadPlan`|
|`gml:baseCRS` , `gml:baseGeodeticCRS` , `gml:baseGeographicCRS`|`prov:wasDerivedFrom`|
|`gml:ellipsoidalCS`, ... , `gml:geodeticDatum` , ... |`dct:relation`|

#  Credits
  
This work was originally supported by the [EU Interoperability Solutions for European Public Administrations Programme (ISA)](http://ec.europa.eu/isa) through [Action 1.17: Re-usable INSPIRE Reference Platform (ARe3NA)](http://ec.europa.eu/isa/actions/01-trusted-information-exchange/1-17action_en.htm). 
