# Data Transform Examples

This folder contains scripts for converting between data formats.

## ConvertTo-CsvFromJson.ps1

Convert JSON to CSV.

```powershell
.\ConvertTo-CsvFromJson.ps1 -InputFile "C:\Data\users.json" -OutputFile "C:\Data\users.csv"
```

**Example Input (users.json):**
```json
[
  {"name": "John", "email": "john@example.com"},
  {"name": "Jane", "email": "jane@example.com"}
]
```

**Example Output (users.csv):**
```
name,email
John,john@example.com
Jane,jane@example.com
```

## ConvertTo-JsonFromCsv.ps1

Convert CSV to JSON.

```powershell
.\ConvertTo-JsonFromCsv.ps1 -InputFile "C:\Data\users.csv" -OutputFile "C:\Data\users.json"
```

**Example Input (users.csv):**
```
name,email
John,john@example.com
Jane,jane@example.com
```

**Example Output (users.json):**
```json
[
  {
    "name": "John",
    "email": "john@example.com"
  },
  {
    "name": "Jane",
    "email": "jane@example.com"
  }
]
```

## ConvertTo-XmlFromCsv.ps1

Convert CSV to XML.

```powershell
.\ConvertTo-XmlFromCsv.ps1 -InputFile "C:\Data\users.csv" -OutputFile "C:\Data\users.xml"
```

**Example Output (users.xml):**
```xml
<?xml version="1.0" encoding="utf-8"?>
<Objects>
  <Object>
    <name>John</name>
    <email>john@example.com</email>
  </Object>
  <Object>
    <name>Jane</name>
    <email>jane@example.com</email>
  </Object>
</Objects>
```

## ConvertTo-CsvFromXml.ps1

Convert XML to CSV.

```powershell
.\ConvertTo-CsvFromXml.ps1 -InputFile "C:\Data\users.xml" -OutputFile "C:\Data\users.csv"
```

## ConvertTo-JsonFromXml.ps1

Convert XML to JSON.

```powershell
.\ConvertTo-JsonFromXml.ps1 -InputFile "C:\Data\users.xml" -OutputFile "C:\Data\users.json"
```

## ConvertTo-XmlFromJson.ps1

Convert JSON to XML.

```powershell
.\ConvertTo-XmlFromJson.ps1 -InputFile "C:\Data\users.json" -OutputFile "C:\Data\users.xml"
```
