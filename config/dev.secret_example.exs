import Config

config :prodops_ex, api_key: "prodops api key here"

config :standops, Standops.Revtime,
  api_key: "RevTime API key here",
  user_id: "your Revtime user_id here",
  project_id: "Revtime project_id here"

config :standops,
  project_name: "Prodops project name here",
  prompt_template_name: "Prodops prompt template name here"
