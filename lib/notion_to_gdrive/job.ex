alias NotionToGDrive.{Export, Import, Pandoc}

defmodule NotionToGDrive.Job do
  @moduledoc """
    Recurring job that runs Notion -> GDrive pipeline each `interval()`.
  """

  import ConfigMacro
  config :notion_to_gdrive, interval: 1000 * 60 * 30

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def schedule(msec \\ 1) do
    Process.send_after(self(), :tick, msec)
  end

  def init([]) do 
    {:ok, schedule()}
  end

  def handle_info(:tick, old_timer) do
    Process.cancel_timer(old_timer)
    run()
    {:noreply, schedule(interval())}
  end

  def run do
    Export.all_files() |> Pandoc.convert_all() |> Import.upload_files()
  end
end
