defmodule Profitry.Accounts.UserNotifier do
  import Swoosh.Email
  import Phoenix.Component

  alias Profitry.Mailer
  alias Profitry.Accounts.User

  @spec deliver(keyword()) :: {:ok, Swoosh.Email.t()}
  def deliver(opts) do
    email =
      new(
        from: {"Profitry", "accounts@profitry.xyz"},
        to: opts[:to],
        subject: opts[:subject],
        html_body: opts[:html_body],
        text_body: opts[:text_body]
      )

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @spec deliver_update_email_instructions(User.t(), String.t()) :: {:ok, Swoosh.Email.t()}
  def deliver_update_email_instructions(user, url) do
    {html, text} = render_content(&email_update_content/1, %{url: url})

    deliver(
      to: user.email,
      subject: "Confirm your new email on Profitry",
      html_body: html,
      text_body: text
    )
  end

  @spec deliver_login_link(User.t(), String.t()) :: {:ok, Swoosh.Email.t()}
  def deliver_login_link(user, url) do
    {html, text} = render_content(&login_content/1, %{url: url})

    deliver(
      to: user.email,
      subject: "Sign in to Profitry",
      html_body: html,
      text_body: text
    )
  end

  @spec deliver_register_link(User.t(), String.t()) :: {:ok, Swoosh.Email.t()}
  def deliver_register_link(user, url) do
    {html, text} = render_content(&register_content/1, %{url: url})

    deliver(
      to: user.email,
      subject: "Create your account on Profitry",
      html_body: html,
      text_body: text
    )
  end

  defp email_layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <style>
          body {
            font-family: system-ui, sans-serif;
            margin: 3em auto;
            overflow-wrap: break-word;
            word-break: break-all;
            max-width: 1024px;
            padding: 0 1em;
          }
        </style>
      </head>
      <body>
        {render_slot(@inner_block)}
      </body>
    </html>
    """
  end

  def email_update_content(assigns) do
    ~H"""
    <.email_layout>
      <p>Click the link below to confirm this as your new email.</p>

      <a href={@url}>{@url}</a>

      <p>If you didn't request this email, feel free to ignore this.</p>
    </.email_layout>
    """
  end

  def register_content(assigns) do
    ~H"""
    <.email_layout>
      <h1>Hey there!</h1>

      <p>Please use this link to create your account at Profitry:</p>

      <a href={@url}>{@url}</a>

      <p>If you didn't request this email, feel free to ignore this.</p>
    </.email_layout>
    """
  end

  def login_content(assigns) do
    ~H"""
    <.email_layout>
      <h1>Hey there!</h1>

      <p>Please use this link to sign in to Profitry:</p>

      <a href={@url}>{@url}</a>

      <p>If you didn't request this email, feel free to ignore this.</p>
    </.email_layout>
    """
  end

  defp heex_to_html(template) do
    template
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp html_to_text(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("body")
    |> Floki.text(sep: "\n\n")
  end

  defp render_content(content_fn, assigns) do
    template = content_fn.(assigns)
    html = heex_to_html(template)
    text = html_to_text(html)

    {html, text}
  end
end
