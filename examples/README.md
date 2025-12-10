# event-network/examples

## amp-events.json

Transformed from TEI/XML source using the listEvent-to-json.xsl stylesheet.

**Source:** https://raw.githubusercontent.com/Auden-Musulin-Papers/amp-entities/main/out/amp-index-events.xml

**Command (from this directory):**
```bash
java -jar /usr/share/java/Saxon-HE.jar -xsl:../xslt/listEvent-to-json.xsl -s:https://raw.githubusercontent.com/Auden-Musulin-Papers/amp-entities/main/out/amp-index-events.xml -o:amp-events.json
```