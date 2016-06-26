<?php

  $xmluri = 'http://www.opengis.net/def/crs/EPSG/0/';
//  $xmluri = 'http://www.opengis.net/def/crs/EPSG/0/4326';
  $xsluri = './epsg-to-rdf.xsl';

  $xml = new DOMDocument;
  $xml->load($xmluri); 

  $xsl = new DOMDocument;
  $xsl->load($xsluri);

  $proc = new XSLTProcessor();
  $proc->importStyleSheet($xsl);

  $rdf = $proc->transformToXML($xml);

  header('Content-type: application/xml');
  echo $rdf;

//  file_put_contents('epsg.rdf', $rdf);

?>
