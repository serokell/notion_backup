defmodule NotionToGDrive.Pandoc do
  def convert(input, template, output_directory) do
    output = Path.join(output_directory, Path.basename(input, ".md")) <> ".docx"

    System.cmd("pandoc", [
      "-f",
      "markdown",
      "-t",
      "docx",
      "--template",
      template,
      "--output",
      output,
      input
    ])

    output
  end
end
