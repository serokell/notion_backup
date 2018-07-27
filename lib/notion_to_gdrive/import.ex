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
    Enum.find(response.files, fn f -> f.name == folder_name() end) || create_folder(conn)
  end

  def create_root_permissions(conn, file) do
    metadata = %Permission{emailAddress: root_email(), role: "writer", type: "user"}
    {:ok, response} = Permissions.drive_permissions_create(conn, file.id, body: metadata)
    response
  end

  def ensure_root_permissions(conn, file) do
    {:ok, response} = Permissions.drive_permissions_list(conn, file.id)

    Enum.find(response.permissions, fn f -> f.emailAddress == root_email() end) ||
      create_root_permissions(conn, file)
  end

  def create_file(conn, path, folder) do
    metadata = %File{name: Path.basename(path), parents: [folder.id]}
    {:ok, response} = Files.drive_files_create_simple(conn, "multipart", metadata, path)
    response
  end

  def upload_file(conn, path, folder) do
    {:ok, response} = Files.drive_files_list(conn)

    if file = Enum.find(response.files, fn f -> f.name == Path.basename(path) end) do
      {:ok, response} = Files.drive_files_update_simple(conn, file.id, "multipart", %File{}, path)
      response
    else
      create_file(conn, path, folder)
    end
  end

  def upload_files(conn \\ connect(), paths) do
    folder = ensure_folder(conn)
    ensure_root_permissions(conn, folder)

    for path <- paths, do: upload_file(conn, path, folder)
  end

  def reset(conn \\ connect()) do
    {:ok, response} = Files.drive_files_list(conn)

    for %{id: file_id} <- response.files do
      Files.drive_files_delete(conn, file_id)
    end

    Files.drive_files_empty_trash(conn)
  end
end
