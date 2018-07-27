defmodule NotionToGDrive.Pandoc do
  import ConfigMacro
  config :notion_to_gdrive, template: "reference.docx"

  def convert(input, output_directory) do
    output = Path.join(output_directory, Path.basename(input, ".md")) <> ".docx"

    System.cmd("pandoc", [
      "-f",
      "markdown",
      "-t",
      "docx",
      "--reference-doc",
      template(),
      "--output",
      output,
      input
    ])

    output
  end

  def convert_all(input_files) do
    output_directory = Briefly.create!(directory: true)

    for input_file <- input_files,
        do: convert(input_file, output_directory)
  end
end
