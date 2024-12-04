class UserMailer < ApplicationMailer
    default from: 'Naxodka'
    def confirmation_email(user, confirmation_code)
        @user = user
        @confirmation_code = confirmation_code
        mail(to: @user.email, subject: 'Подтверждение регистрации')
      end
end
