<?xml version="1.0" encoding="UTF-8"?>
<!--
    listEvent-to-json.xsl
    
    Transforms TEI/XML event data into JSON format suitable for use with
    the affiliation-builder Python package.
    
    Input: TEI/XML document containing tei:listEvent with tei:event elements
    Output: JSON structure compatible with Python affiliation-builder
    
    XSLT Version: 3.0
    Processor: Saxon-HE 9.9+ or other XSLT 3.0 compliant processor
    
    Author: Timo Frühwirth
    License: MIT
-->
<!--
    Namespaces:
        tei: TEI namespace for input document
        xs: XML Schema for type casting
        map/array: XSLT 3.0 JSON construction
-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    exclude-result-prefixes="tei xs map array">
    
    <!-- 
        Output method="text" is defensive choice over method="json":
        method="text" with explicit serialize() function is more transparent,
        easier to debug, and might work more reliably across Saxon versions.
    -->
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- Root template -->
    <xsl:template match="/">
        <!-- Transformation logic will go here -->
    </xsl:template>
    
</xsl:stylesheet>