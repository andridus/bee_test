defmodule BeeTest.Repo do
  use Ecto.Repo,
    otp_app: :bee_test,
    adapter: Ecto.Adapters.Postgres
end
