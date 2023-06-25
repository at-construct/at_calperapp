class TokenService
  class << self
    def issue_by_password!(email, password)
      user = AuthenticationService.authenticate_user_with_password!(email, password)
      issue_token(user)
    end

    private

    def issue_token(id)
      payload = {
        iss: "cal_app",
        sub: @user.id,
        exp: (DateTime.current + 1.days).to_i
      }
      rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))
      JWT.encode(payload, rsa_private, "RS256")
    end

  end
end