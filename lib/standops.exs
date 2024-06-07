# A script to fetch logs from Revtime, send them to Prodops, and return a standup artifact.

# Takes 2 command-line arguments:
#  - `days_ago`: the number of days in the past from which to fetch logs from Revtime
#  - `today`: what you plan to do today
#
# Example:
#
#   mix run lib/standops.exs 4 "do some work"

alias Standops.Revtime

[days_ago, today] = System.argv()
project_name = Application.get_env(:standops, :project_name)
prompt_template_name = Application.get_env(:standops, :prompt_template_name)

logs = days_ago |> String.to_integer() |> Revtime.logs_from()
IO.puts("fetched logs from Revtime")

project_id =
  case ProdopsEx.Project.list() do
    {:ok, %{response: %{"projects" => projects}}} ->
      projects
      |> Enum.find(&(Map.get(&1, "name") == project_name))
      |> Map.get("id")

    {:error, error} ->
      throw("Prodops Error: Error fetching project id: #{inspect(error)}")
  end

prompt_template_id =
  case ProdopsEx.PromptTemplate.list("standup") do
    {:ok, %{response: %{"prompt_templates" => prompt_templates}}} ->
      prompt_templates
      |> Enum.find(&(Map.get(&1, "name") == prompt_template_name))
      |> Map.get("id")

    {:error, error} ->
      throw("Prodops Error: Error fetching prompt template: #{inspect(error)}")
  end

IO.puts("creating Prodops Artifact...")

{:ok, %{response: %{"artifact" => %{"content" => content, "id" => artifact_id}}}} =
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

IO.puts(content)
IO.puts("\n")
IO.puts("Copied artifact to clipboard")
IO.puts("\n")
IO.puts("Artifact ID: #{artifact_id}")
