# frozen_string_literal: true

require 'clonk'
sso = Clonk::Connection.new(
  base_url: 'http://sso:8080',
  realm_id: 'master',
  username: 'user',
  password: 'password',
  client_id: 'admin-cli'
)
sso.realm = sso.create_realm(realm: 'client-assured')
users = []
%i[acc1admin acc1usr1 acc1usr2 acc2admin acc2usr1].each do |username|
  user = sso.create_user(username: username)
  users << user
  sso.set_password_for(user: user, password: 'Password123')
end