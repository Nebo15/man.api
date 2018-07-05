defmodule Man.Repo.Migrations.UpdateCredentialsRecoveryRequestTemplate do
  use Ecto.Migration

  def change do
    execute("""
    UPDATE templates SET body = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" style="margin: 0; padding: 0; height: 100%;">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="{{l10n.WelcomeHint}}">





    </head>
    <body style="margin: 0; padding: 0; height: 100%; color: #515151; font: 400 16px Roboto, Arial, sans-serif; line-height: 22px; -webkit-text-size-adjust: none; background-color: #f8f7f6;">
    <div style="font-size:0">{{l10n.WelcomeHint}}</div>
    <table class="main" cellpadding="0" cellspacing="0" border="0" width="100%" style="border-collapse: collapse; border-spacing: 0; height: 100%; width: 100%;">
        <tr>
            <td class="content" valign="top" align="center" style="padding: 32px;">
                <table cellpadding="0" cellspacing="0" border="0" width="100%" style="border-collapse: collapse; border-spacing: 0; width: 100%; max-width: 957px; min-width: 200px;">
                    <tr>
                        <td align="center" class="header" style="padding-bottom: 25px;">
                            <table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-collapse: collapse; border-spacing: 0;">
                                <tr>
                                    <td class="head-space" style="width: 33%"></td>
                                    <td style="width: 33%" align="center">
                                    <a class="logo" href="#" style="color: #2892f0; text-decoration: none; font-weight: 700; outline: none; display: block; margin: 0 20px;">
                                        <img height="50px" src="{{l10n.ENDPOINT}}/images/logo.png" alt="eHealth logo">
                                    </a>
                                </td>
                                    <td style="max-width: 33%; white-space: nowrap;" align="right">
                                        <b>{{date}}</b>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td valign="middle" align="left" class="body" style="padding: 70px; background-color: #fff;">
                            <div>
                                <p style="margin: 0 0 20px 0; padding: 0;">
                                    {{l10n.PasswordRecovery}}
                                    <a href="{{l10n.ENDPOINT}}/reset/{{credentials_recovery_request_id}}?client_id={{client_id}}&redirect_uri={{redirect_uri}}" style="color: #2892f0; text-decoration: none; font-weight: 700; outline: none;">{{l10n.ENDPOINT}}/reset/{{credentials_recovery_request_id}}</a>
                                </p>
                                <br>
                            </div>
                            <p style="margin: 0 0 20px 0; padding: 0;">
                                {{l10n.IgnoreLetter}}
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td valign="middle" align="left" class="body" style="padding: 70px; background-color: #fff;">
                            <div>
                                {{l10n.thanks}}<br>
                                {{l10n.eHealth}}<br>
                                <small>{{l10n.allRightsReserved}}</small>
                            </div>
                        </td>
                    </tr>
                    <tr><td align="center" class="footer" style="opacity: 0.5; font-size: 12px; line-height: 14px; padding-top: 60px;"><p style="margin: 0 0 20px 0; padding: 0;">© 2017 {{l10n.Copyright}}</p></td></tr>
                </table>
            </td>
        </tr>
    </table>
    </body>
    </html>
    ' WHERE title = 'Credentials recovery request';
    """)
  end
end
