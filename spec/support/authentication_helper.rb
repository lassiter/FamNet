
module AuthenticationHelper
  def login_auth(member)
    @member = member
    post '/v1/auth/sign_in', params: { "email": "#{@member.email}", "password": "password" }
    return {
            'Uid' => response.headers['Uid'],
            'Access-Token' => response.headers['Access-Token'],
            'Client' => response.headers['Client'],
    }
  end
end