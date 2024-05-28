alias Standops.Revtime

[days_ago, today] = System.argv()

logs = days_ago |> String.to_integer() |> Revtime.logs_from()
IO.puts("fetched logs from Revtime")

project_id =
  case ProdopsEx.Project.list() do
    {:ok, %{response: %{"projects" => projects}}} ->
      projects
      |> Enum.find(&(Map.get(&1, "name") == "In Field Pro"))
      |> Map.get("id")

    {:error, error} ->
      throw("Prodops Error: Error fetching project id: #{inspect(error)}")
  end

prompt_template_id =
  case ProdopsEx.PromptTemplate.list("standup") do
    {:ok, %{response: %{"prompt_templates" => prompt_templates}}} ->
      prompt_templates
      |> Enum.find(&(Map.get(&1, "name") == "Yesterday, Today, Blockers Standup Post"))
      |> Map.get("id")

    {:error, error} ->
      throw("Prodops Error: Error fetching prompt template: #{inspect(error)}")
  end

IO.puts("creating Prodops Artifact...")

{:ok, %{response: %{"artifact" => %{"content" => content}}}} =
  ProdopsEx.Artifact.create(%{
    prompt_template_id: prompt_template_id,
    artifact_slug: "standup",
    project_id: project_id,
    inputs: [
      %{name: "Time Logs", value: logs},
      %{name: "Today", value: today}
    ]
  })

# Copy artifact content to os clipboard
port = Port.open({:spawn, "pbcopy"}, [:binary])
send(port, {self(), {:command, content}})
send(port, {self(), :close})

IO.puts("Copied artifact to clipboard")
IO.puts(content)
