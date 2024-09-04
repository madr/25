defmodule Mse25.Directus do
  def get_item() do
    :tbw
  end

  def get_list() do
    get("/pages")
  end

  defp get(resource) do
    [base_url: base_url, token: token] = Application.fetch_env!(:mse25, :directus)
    req = Req.new(base_url: base_url <> "/items")
    Req.get!(req, url: resource, auth: {:bearer, token})
  end
end
