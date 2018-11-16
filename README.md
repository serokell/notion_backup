![Logo](logo.svg)

# NotionToGDrive

NotionToGDrive is a daemon that regularly renders all Notion data to PDFs put
in a read-only Google Drive folder. On initial startup, that folder is shared
with "root user", who can then authorize other users with access.

Contains the only known reverse-engineered Notion V3 API client, which, despite
being internal, is a proper REST API.

Pandoc is used to convert Markdown to PDF.
