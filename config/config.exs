use Mix.Config

# GCP service account JSON file with Google Drive API access
# https://cloud.google.com/compute/docs/access/service-accounts
config :goth,
  json: File.read!("config/google-credentials.json")

# https://www.notion.so token cookie
config :notion_to_gdrive, NotionToGDrive.NotionV3,
  token: "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

# Email of the first user to get an invitation to bot-managed GDrive folder
config :notion_to_gdrive, NotionToGDrive.Import,
  root_email: "john.doe@serokell.io"
