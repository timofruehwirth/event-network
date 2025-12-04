# event-network/xslt

## listEvent-to-json.xsl

An XSLT 3.0 stylesheet that transforms TEI/XML `<listEvent>` data into JSON format compatible with the [affiliation-builder](https://pypi.org/project/affiliation-builder/) Python package for affiliation network analysis.

### Purpose

This stylesheet serves as an interface between scholarly digital editing and network analysis. It supports generating bipartite affiliation networks through the `affiliation-builder` package from the co-affiliation information (such as of human and institutional participants) encoded in TEI/XML event data.

### Input

The stylesheet expects a TEI/XML document containing a `<listEvent>` element with one or more `<event>` children. Events typically contain affiliated entities (persons, organizations, places) in either:

- **`list*` type wrapper elements** (such as `<listPerson>`, `<listOrg>`, `<listPlace>`)[^1]
- **direct child elements** (such as `<person>`, `<org>`, `<placeName>`, etc.)

Example:

```xml
<listEvent>
    <event xml:id="evt_001">
        <label>Encoding Cultures – joint MEC and TEI Conference 2023</label>
        <listPerson>
            <person xml:id="p_001">
                <persName>Alice Smith</persName>
                <idno type="GND">118540238</idno>
            </person>
            <person xml:id="p_002">
                <persName>Bob Jones</persName>
                <idno type="VIAF">24602065</idno>
            </person>
        </listPerson>
        <org xml:id="org_001">Paderborn University</org>
        <org xml:id="org_002">Text Encoding Initiative</org>
        <org xml:id="org_003">Music Encoding Initiative</org>
    </event>
</listEvent>
```

[^1]: `<listOrg>` is not currently permitted as a child of `<event>` in the TEI Guidelines. See the [Text Encoding Initiative Consortium's issue #2827](https://github.com/TEIC/TEI/issues/2827) for discussion of its potential inclusion.

### Output

The stylesheet produces JSON structured for direct use with `affiliation-builder`.

Example:

```json
{
    "listEvent": [
        {
            "xml:id": "evt_001",
            "label": "Encoding Cultures – joint MEC and TEI Conference 2023",
            "listPerson": [
                {
                    "xml:id": "p_001",
                    "persName": "Alice Smith",
                    "idno": {"type": "GND", "#text": "118540238"}
                },
                {
                    "xml:id": "p_002",
                    "persName": "Bob Jones",
                    "idno": {"type": "VIAF", "#text": "24602065"}
                }
            ],
            "org": [
                {"xml:id": "org_001", "#text": "Paderborn University"},
                {"xml:id": "org_002", "#text": "Text Encoding Initiative"},
                {"xml:id": "org_003", "#text": "Music Encoding Initiative"}
            ]
        }
    ]
}
```

### Transformation Rules

The stylesheet preserves the original key TEI structure while applying targeted transformation rules for `affiliation-builder` compatibility:

1. **Flattening**: `list*` type wrapper elements become JSON arrays containing their child elements directly, without preserving the child elements' names.

2. **Grouping:** Repeated sibling elements are automatically grouped into arrays.

3. **Attribute preservation:** All TEI/XML attributes are preserved as JSON keys.

4. **Text content:** For elements with both attributes and text content, a `#text` key stores the text value.

### Usage

Run the transformation either:
- through a transformation scenario in your XML editor (such as Oxygen XML Editor)
- through a command-line XSLT processor (such as Saxon-HE)

### Requirements

XSLT 3.0 processor (such as Saxon-HE 9.9+). Oxygen XML Editor includes Saxon by default. For command-line usage, Saxon-HE 9.9+ is freely available.

### Limitations

- **Information loss in mixed content:** In elements containing both text and child elements, text is captured, but positional relationships are lost.
- **Name collision:** If an attribute and child element share the same name, the child element value overwrites the attribute value.
- **`listEvent` metadata loss:**  Child elements of `<listEvent>` outside `<event>` (such as `<head>` and `<desc>`) are not included in the output.

These limitations are not expected to affect the stylesheet's capacity to prepare TEI-compliant event data for further processing with the `affiliation-builder` package.

### License

MIT
