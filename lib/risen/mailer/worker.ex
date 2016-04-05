defmodule Risen.MailerWorker do
  use Toniq.Worker
  use Mailgun.Client,
      domain: Application.get_env(:risen, :mailgun_domain),
      key: Application.get_env(:risen, :mailgun_key)

  def perform(opts \\ []) do
    send_email(opts)
  end
end
