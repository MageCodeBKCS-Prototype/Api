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
class User < ApplicationRecord
  attr_accessor :old_password

  validates :username,
            presence: { message: 'Tên đăng nhập không được để trống', on: %i[create update] },
            length: { maximum: 50, message: 'Tên đăng nhập không quá 50 kí tự', on: %i[create update] }

  validates :email,
            presence: { message: 'Email không được để trống', on: %i[create login] },
            uniqueness: { message: 'Email đã tồn tại', on: :create },
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: %i[create login], message: 'Định dạng email không hợp lệ' }

  validates :password,
            presence: { on: %i[create login change_password], message: 'Mật khẩu không được để trống' }

  validates :password_confirmation,
            presence: { on: %i[create change_password], message: 'Mật khẩu xác nhận không được để trống' }

  validates :old_password,
            presence: { on: :change_password, message: 'Mật khẩu cũ không được để trống' }

  has_secure_password

end
