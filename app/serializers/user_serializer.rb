# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  bio             :string(255)
#  email           :string(255)      not null
#  password_digest :string(255)      not null
#  username        :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class UserSerializer < ApplicationSerializer
  attributes :id, :username, :bio, :email

  def url
    ''
  end
end
