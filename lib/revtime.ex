defmodule Standops.Revtime do
  use Timex

  @base_url "https://time.revelry.co/api/v1/"
  @user_id 124
  @ifp_project_id 302

  @spec logs_from(integer(), map()) :: {:ok, [map()]} | {:error, any()}
  def logs_from(days_ago \\ 1, params \\ %{project_id: @ifp_project_id}) do
    start_time =
      Timex.local()
      |> Timex.beginning_of_day()
      |> DateTime.add(-days_ago, :day)
      |> Timex.to_datetime("Etc/UTC")

    query =
      Map.merge(
        %{user_id: @user_id, start_time: start_time, end_time: Timex.end_of_day(start_time)},
        params
      )

    case get("time", query) do
      {:ok, %{"entries" => []}} ->
        {:error, :no_entries}

      {:ok, %{"entries" => entries}} ->
        entries
        |> Enum.map(&Map.get(&1, "notes"))
        |> Enum.join(" // ")

      {:ok, %{"errors" => errors}} ->
        {:error, inspect(errors)}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get(String.t(), map()) :: {:ok, map()} | {:error, any()}
  def get(endpoint, query_params) do
    headers = [{"Authorization", "Bearer #{api_key()}"}]

    query_params =
      query_params
      |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, "q[#{k}]", v) end)
      |> URI.encode_query()

    url = @base_url <> endpoint <> "?#{query_params}"

    with {:ok, %{body: body}} <- HTTPoison.get(url, headers) do
      Jason.decode(body)
    end
  end

  defp api_key() do
    Application.get_env(:standops, Standops.Revtime)[:api_key]
  end
end
