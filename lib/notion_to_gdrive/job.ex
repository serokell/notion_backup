alias NotionToGDrive.{Export, Import, Pandoc}

defmodule NotionToGDrive.Job do
  def run do
    markdown_files = Export.all_files()

    docx_directory = Briefly.create!(directory: true)

    docx_files =
      for markdown_file <- markdown_files,
          do: Pandoc.convert(markdown_file, "reference.docx", docx_directory)

    Import.add_files(docx_files)
  end
end
