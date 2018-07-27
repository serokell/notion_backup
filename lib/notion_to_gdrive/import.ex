alias GoogleApi.Drive.V3.Api.Files
alias GoogleApi.Drive.V3.Api.Permissions
alias GoogleApi.Drive.V3.Connection
alias GoogleApi.Drive.V3.Model.File
alias GoogleApi.Drive.V3.Model.Permission

defmodule NotionToGDrive.Import do
  import ConfigMacro
  config :notion_to_gdrive, folder_name: "Notion Export"
  config :notion_to_gdrive, [:root_email]

  def connect do
    {:ok, %{token: token}} = Goth.Token.for_scope("https://www.googleapis.com/auth/drive")
    Connection.new(token)
  end

  def create_folder(conn) do
    metadata = %File{name: folder_name(), mimeType: "application/vnd.google-apps.folder"}

    {:ok, response} =
      Files.drive_files_create_simple(conn, "multipart", metadata, Briefly.create!())

    response
  end

  def ensure_folder(conn) do
    {:ok, response} = Files.drive_files_list(conn)
    Enum.find(response.files, create_folder(conn), fn f -> f.name == folder_name() end)
  end

  def create_root_permissions(conn, file) do
    metadata = %Permission{emailAddress: root_email(), role: "reader", type: "user"}
    {:ok, response} =
      Permissions.drive_permissions_create(conn, file.id, body: metadata)

    response
  end

  def ensure_root_permissions(conn, file) do
    {:ok, response} = Permissions.drive_permissions_list(conn, file.id)

    Enum.find(response.permissions, create_root_permissions(conn, file), fn f ->
      f.emailAddress == root_email()
    end)
  end

  def add_files(conn \\ connect(), paths) do
    folder = ensure_folder(conn)
    ensure_root_permissions(conn, folder)

    for path <- paths do
      metadata = %File{name: Path.basename(path)}

      {:ok, _response} =
        Files.drive_files_create_simple(conn, "multipart", metadata, path)
    end
  end
end
