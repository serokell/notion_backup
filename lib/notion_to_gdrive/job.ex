alias NotionToGDrive.{Export, Import, Pandoc}

defmodule NotionToGDrive.Job do
  def run do
    Export.all_files() |> Pandoc.convert_all() |> Import.upload_files()
  end
end
