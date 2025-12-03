<?xml version="1.0" encoding="UTF-8"?>
<!--
    listEvent-to-json.xsl
    
    Transforms TEI/XML event data into JSON format (suitable for use with
    the affiliation-builder Python package).
    
    Transformation Rules:
    1. Flatten TEI list* wrapper elements (listPerson, listPlace, etc.) to arrays
    2. Group repeated sibling TEI elements (e.g., org) into arrays
    
    Input: TEI/XML document containing tei:listEvent with tei:event element(s)
    Output: JSON structure compatible with Python affiliation-builder
    
    XSLT Version: 3.0
    Processor: Saxon-HE 9.9+ or other XSLT 3.0 compliant processor
    
    Author: Timo Frühwirth
    License: MIT
-->
<!--
    Namespaces:
        tei: TEI namespace for processing input data
        map: XSLT 3.0 JSON object construction
        array: XSLT 3.0 JSON array construction
-->
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    exclude-result-prefixes="tei map array">
    
    <!-- 
        Output method="text" is defensive choice over method="json":
        method="text" with explicit serialize() function is more transparent,
        easier to debug, and might work more reliably across Saxon versions.
    -->
    <xsl:output method="text" encoding="UTF-8"/>
    
    <!-- Remove whitespace-only text nodes and whitespace between elements -->
    <xsl:strip-space elements="*"/>
    
    <!-- ================================================================== -->
    <!-- Root template: entry point -->
    <!-- ================================================================== -->
    
    <!-- Create and serialize JSON object -->
    <xsl:template match="/">
        <xsl:variable name="json-map" as="map(*)">
            <!-- Find listEvent element and call template to process it -->
            <xsl:apply-templates select="//tei:listEvent[not(ancestor::tei:listEvent)]"/>
        </xsl:variable>
        <xsl:value-of select="serialize($json-map, map{'method':'json', 'indent':true()})"/>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- listEvent template: create top-level JSON object structure -->
    <!-- ================================================================== -->
    
    <!-- Match listEvent element, return JSON object -->
    <xsl:template match="tei:listEvent" as="map(*)">
        <!-- Create variable to hold sequence of objects -->
        <xsl:variable name="events" as="map(*)*">
            <!-- Loop through event elements -->
            <xsl:for-each select="tei:event">
                <!-- Convert each event to JSON object -->
                <xsl:call-template name="element-to-map">
                    <xsl:with-param name="element" select="."/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:map>
            <!-- Wrap event objects in JSON array -->
            <xsl:map-entry key="'listEvent'" select="array{$events}"/>
        </xsl:map>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- element-to-map template: convert TEI/XML element to JSON object -->
    <!-- ================================================================== -->
    
    <!-- Return JSON object -->
    <xsl:template name="element-to-map" as="map(*)">
        <!-- Pass XML element as required paramater -->
        <xsl:param name="element" as="element()" required="yes"/>
        
        <!-- Process TEI attributes as JSON object -->
        <xsl:variable name="attributes-map" as="map(*)">
            <xsl:map>
                <!-- Loop through attributes -->
                <xsl:for-each select="$element/@*">
                    <!-- Create key-value pairs for each -->
                    <xsl:map-entry key="name()" select="string(.)"/>
                </xsl:for-each>
            </xsl:map>
        </xsl:variable>
        
        <!-- Process child elements as JSON object -->
        <xsl:variable name="children-map" as="map(*)">
            <xsl:map>
                <!-- Loop through groups of child elements, grouped by element name (without namespace prefix) -->
                <xsl:for-each-group select="$element/*" group-by="local-name()">
                    <!-- Store child-element name and number of child elements of same name -->
                    <xsl:variable name="element-name" select="current-grouping-key()"/>
                    <xsl:variable name="group-count" select="count(current-group())"/>
                    
                    <xsl:choose>
                        <!-- ================================================== -->
                        <!-- Rule 1: flatten list* wrapper elements -->
                        <!-- ================================================== -->
                        <!-- Match element group whose name starts with list* -->
                        <xsl:when test="starts-with($element-name, 'list')">
                            <!-- Create items variable to hold values returned by process-element template -->
                            <xsl:variable name="items" as="item()*">
                                <!-- Loop through list* elements (usually only 1) -->
                                <xsl:for-each select="current-group()">
                                    <xsl:variable name="list-elem" select="."/>
                                    <!-- Loop through child elements of of list* -->
                                    <xsl:for-each select="$list-elem/*">
                                        <!-- Call process-element template -->
                                        <xsl:call-template name="process-element">
                                            <xsl:with-param name="element" select="."/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:for-each>
                            </xsl:variable>
                            <!-- Create array of child elements with list* element group name as key -->
                            <xsl:map-entry key="$element-name" select="array{$items}"/>
                        </xsl:when>
                        
                        <!-- ================================================== -->
                        <!-- Rule 2: group repeated sibling elements -->
                        <!-- ================================================== -->
                        <xsl:when test="$group-count > 1">
                            <xsl:variable name="items" as="item()*">
                                <!-- Loop through each element (always more than 1) -->
                                <xsl:for-each select="current-group()">
                                    <xsl:call-template name="process-element">
                                        <xsl:with-param name="element" select="."/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:map-entry key="$element-name" select="array{$items}"/>
                        </xsl:when>
                        
                        <!-- ================================================== -->
                        <!-- Fallback: handle single element outside array -->
                        <!-- ================================================== -->
                        <!-- Element group name starts not with list* and group has only one element -->
                        <xsl:otherwise>
                            <xsl:variable name="value" as="item()">
                                <xsl:call-template name="process-element">
                                    <!-- Get first (and only) element from sequence -->
                                    <xsl:with-param name="element" select="current-group()[1]"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <!-- Add key-value (string or object) pair to children-map -->
                            <xsl:map-entry key="$element-name" select="$value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
                
                <!-- ================================================== -->
                <!-- Capture text content if present -->
                <!-- ================================================== -->
                <!-- Pass to variable cleaned up concatenated text nodes of current element -->
                <xsl:variable name="text-content" select="normalize-space(string-join($element/text(), ' '))"/>
                <xsl:if test="$text-content != ''">
                    <!-- Add key-value pair for text content to JSON object -->
                    <xsl:map-entry key="'#text'" select="$text-content"/>
                </xsl:if>
            </xsl:map>
        </xsl:variable>
        
        <!-- Return merged sequence of attributes and children maps -->
        <xsl:sequence select="map:merge(($attributes-map, $children-map))"/>
    </xsl:template>
    
    <!-- ================================================================== -->
    <!-- process-element template: process according to child element type -->
    <!-- ================================================================== -->
    
    <xsl:template name="process-element" as="item()">
        <!-- Pass XML element as required paramater -->
        <xsl:param name="element" as="element()" required="yes"/>
        
        <xsl:choose>
            <!-- Element with no child elements, no attributes, and no empty text content -->
            <xsl:when test="not($element/*) and not($element/@*) and normalize-space($element) != ''">
                <!-- Return element text content as string with cleaned up whitespace -->
                <xsl:sequence select="normalize-space($element)"/>
            </xsl:when>
            
            <!-- Element with no child elements, no attributes, and empty text content -->
            <xsl:when test="not($element/*) and not($element/@*) and normalize-space($element) = ''">
                <!-- Return empty string -->
                <xsl:sequence select="''"/>
            </xsl:when>
            
            <!-- Element with attributes and/or child elements (with or without text content) -->
            <xsl:otherwise>
                <!-- Convert into JSON object recursively -->
                <xsl:call-template name="element-to-map">
                    <xsl:with-param name="element" select="$element"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>