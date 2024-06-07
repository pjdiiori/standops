[artifact_id, refine_prompt] = System.argv()

IO.puts("\nRefining your standup...")

{:ok, %{response: %{"artifact" => %{"content" => content}}}} =
  ProdopsEx.Artifact.refine_artifact(%{
    artifact_id: artifact_id,
    artifact_slug: "standup",
    refine_prompt: refine_prompt
  })

port = Port.open({:spawn, "pbcopy"}, [:binary])
send(port, {self(), {:command, content}})
send(port, {self(), :close})

IO.puts("\n")
IO.puts(content)
IO.puts("\n")
IO.puts("Copied artifact to clipboard")
