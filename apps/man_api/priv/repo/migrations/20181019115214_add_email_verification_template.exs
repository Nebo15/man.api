defmodule Man.Repo.Migrations.AddEmailVerificationTemplate do
  use Ecto.Migration
  alias Man.Repo
  alias Man.Templates.Template
  import Ecto.Changeset

  def locale_changeset(%Man.Templates.Template.Locale{} = locale, attrs) do
    cast(locale, attrs, ~w(code params)a)
  end

  def change do
    result =
      case Repo.get_by(Template, %{:title => "Email verification"}) do
        nil -> %Template{}
        template -> template
      end

    result
    |> cast(
      %{
        "title" => "Email verification",
        "description" => nil,
        "syntax" => "mustache",
        "locales" => [
          %{
            "code" => "uk_UA",
            "params" => %{
              "Hello" => "Вітаємо!",
              "thanks" => "Дякуємо за те, що ви з нами!",
              "eHealth" => "Електронна система охорони здоров'я eHealth",
              "ENDPOINT" => Confex.fetch_env!(:man_api, :auth_host),
              "endpoint" => Confex.fetch_env!(:man_api, :auth_host),
              "Copyright" => "Всі права захищено",
              "greetings" => "Ласкаво просимо до аккаунту E-Health.",
              "emailVerify" => "Будь ласка, підтвердіть вашу електронну адресу перейшовши за посилання нижче:",
              "IgnoreLetter" => "Якщо ви не створювали користувача, просто проігноруйте цей лист.",
              "allRightsReserved" => "Всі права захищено"
            }
          }
        ],
        "body" => """
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml" style="margin: 0; padding: 0; height: 100%;"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><meta name="description" content=""></head><body style="margin: 0; padding: 0; height: 100%; color: #515151; font: 400 16px Roboto, Arial, sans-serif; line-height: 22px; -webkit-text-size-adjust: none; background-color: #f8f7f6;"><div style="font-size:0"></div><table class="main" cellpadding="0" cellspacing="0" border="0" width="100%" style="border-collapse: collapse; border-spacing: 0; height: 100%; width: 100%;"><tr><td class="content" valign="top" align="center" style="padding: 32px;"><table cellpadding="0" cellspacing="0" border="0" width="100%" style="border-collapse: collapse; border-spacing: 0; width: 100%; max-width: 957px; min-width: 200px;"><tr><td align="center" class="header" style="padding-bottom: 25px;"><table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse; border-spacing: 0;"><tr><td class="head-space" style="width: 33%"></td><td style="width: 33%" align="center"><a class="logo" href="#" style="color: #2892f0; text-decoration: none; font-weight: 700; outline: none; display: block; margin: 0 20px;"><img height="50px" src="https://auth-dev.ehealth.world/images/logo.png" alt="eHealth logo"></a></td><td style="max-width: 33%; white-space: nowrap;" align="right"><b></b></td></tr></table></td></tr><tr><td valign="middle" align="left" class="body" style="padding: 70px; background-color: #fff;"><div><p style="margin: 0 0 20px 0; padding: 0;"><p style="margin: 0 0 20px 0; padding: 0;">{{l10n.Hello}}</p><p style="margin: 0 0 20px 0; padding: 0;">{{l10n.greetings}}</p><p style="margin: 0 0 20px 0; padding: 0;">{{l10n.emailVerify}}</p><a href="{{l10n.endpoint}}/sign-up/continue?token={{verification_code}}" style="color: #2892f0; text-decoration: none; font-weight: 700; outline: none;">{{l10n.endpoint}}</a></p><br></div><p style="margin: 0 0 20px 0; padding: 0;">{{l10n.IgnoreLetter}}</p></td></tr><tr><td valign="middle" align="left" class="body" style="padding: 70px; background-color: #fff;"><div>{{l10n.thanks}}<br>{{l10n.eHealth}}<br><small>{{l10n.Copyright}}</small></div></td></tr><tr><td align="center" class="footer" style="opacity: 0.5; font-size: 12px; line-height: 14px; padding-top: 60px;"><p style="margin: 0 0 20px 0; padding: 0;">© 2018 {{l10n.Copyright}}</p></td></tr></table></td></tr></table></body></html>
        """
      },
      ~w(id title description syntax body)a
    )
    |> cast_embed(:locales, with: &locale_changeset/2)
    |> Repo.insert_or_update!()
  end
end
