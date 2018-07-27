alias NotionToGDrive.NotionV3

defmodule NotionToGDrive.Export do
  import ConfigMacro
  config :notion_to_gdrive, delay: 1000 * 10

  require Logger

  def all_urls do
    block_uuids = NotionV3.load_user_content()["recordMap"]["block"] |> Map.keys()

    task_uuids = for block_uuid <- block_uuids, do: NotionV3.schedule_export(block_uuid)

    Process.sleep(delay())

    for result <- NotionV3.receive_export(task_uuids)["results"] do
      if result["error"] do
        Logger.warn(result["error"])
      end

      result["result"]["exportURL"]
    end
  end

  def fetch(url) do
    path = Briefly.create!()
    File.write!(path, HTTPoison.get!(url).body)
    path
  end

  def extract_zip(path) do
    {:ok, paths} = :zip.extract(String.to_charlist(path), cwd: Briefly.create!(directory: true))

    paths
  end

  def all_files do
    Enum.map(all_urls(), fn url -> extract_zip(fetch(url)) end) |> Enum.concat()
  end
end
