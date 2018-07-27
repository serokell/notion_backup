defmodule NotionToGDrive.NotionV3 do
  import ConfigMacro
  config :notion_to_gdrive, [:token]

  @base_url "https://www.notion.so/api/v3"

  def request(endpoint, payload \\ %{}) do
    headers = %{
      "content-type" => "application/json",
      "cookie" => "token=" <> token()
    }

    HTTPoison.post!(@base_url <> endpoint, Poison.encode!(payload), headers).body
    |> Poison.decode!()
  end

  def schedule_export(block_uuid) do
    task_uuid = UUID.uuid4()

    request("/enqueueTask", %{
      "task" => %{
        "id" => task_uuid,
        "eventName" => "exportBlock",
        "data" => %{
          "blockId" => block_uuid,
          "recursive" => true,
          "timeZone" => "Europe/Moscow"
        }
      }
    })

    task_uuid
  end

  def receive_export(task_uuids) do
    request("/getTaskResults", %{"taskIds" => task_uuids})
  end

  def load_user_content do
    request("/loadUserContent")
  end
end
