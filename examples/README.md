# event-network/examples

## json

The [`amp-events.json` file](https://github.com/timofruehwirth/event-network/blob/main/examples/json/amp-events.json) contains affiliation data that have been transformed from a TEI-XML-encoded dataset by means of the [`listEvent-to-json.xsl` stylesheet](https://github.com/timofruehwirth/event-network/blob/main/xslt/listEvent-to-json.xsl). The [source TEI `<listEvent>` data](https://github.com/Auden-Musulin-Papers/amp-entities/blob/main/out/amp-index-events.xml) come from the [Auden Musulin Papers](https://www.oeaw.ac.at/acdh/research/literary-studies/research/authors-editions/auden-musulin-papers) project that has resulted in a [digital edition](https://amp.acdh.oeaw.ac.at/) of the correspondence between British-American poet W. H. Auden and Welsh-Austrian writer Stella Musulin during Auden's Austrian period 1957-1973.

Command (from `examples/`):
```bash
java -jar /usr/share/java/Saxon-HE.jar -xsl:../xslt/listEvent-to-json.xsl -s:https://raw.githubusercontent.com/Auden-Musulin-Papers/amp-entities/main/out/amp-index-events.xml -o:json/amp-events.json
```

## notebooks

The [`amp-affiliation-network.ipynb` Jupyter Notebook](https://github.com/timofruehwirth/event-network/blob/main/examples/notebooks/amp-affiliation-network.ipynb) makes use of the [`affiliation-builder` Python utility](https://pypi.org/project/affiliation-builder/) for creating affiliation networks from JSON affiliation data. Run on the [`amp-events.json` dataset](https://github.com/timofruehwirth/event-network/blob/main/examples/json/amp-events.json) described above, the Notebook serves two purposes: demonstrating the utility in a real-world use case, and tentatively outlining a potential approach to studying British-American poet W. H. Auden's biographical environment during his Austrian years 1957-1973 with the help of network analysis.