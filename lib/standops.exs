@doc """
A script to fetch logs from Revtime, send them to Prodops, and return a standup artifact.

Takes 2 command-line arguments:
 - `days_ago`: the number of days in the past to fetch logs from Revtime
 - `today`: what you plan to do today
"""

alias Standops.Revtime

[days_ago, today] = System.argv()

logs = days_ago |> String.to_integer() |> Revtime.logs_from()
IO.puts("fetched logs from Revtime")

project_id =
  case ProdopsEx.Project.list() do
    {:ok, %{response: %{"projects" => projects}}} ->
      projects
      |> Enum.find(&(Map.get(&1, "name") == Application.get_env(:standops, :project_name)))
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
