defmodule Fitcrm.Tools.Email do
  import Bamboo.Email

  def welcome_email(email) do
    new_email(
      to: email,
      from: "support@fitcrm.com",
      subject: "Welcome to SSMPA!",
      html_body: "<strong>Thanks for joining! the fittest and strongest community</strong>",
      text_body: "Thanks for joining!"
    )
  end

  def password_recovery(email, password) do
    new_email(
      to: email,
      from: "support@fitcrm.com",
      subject: "Password Reset",
      html_body: "<strong>Your password has been reset too: " <> password <> "</strong>",
      text_body: "If this isn't you email us immediately!"
    )
  end
end
