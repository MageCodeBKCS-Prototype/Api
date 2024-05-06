class AuthController < ApplicationController
  skip_before_action :authorized, only: %i[login register]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record

  def register
    user = User.new(register_params)
    if user.save
      @token = encode_token({ user_id: user.id, exp: Time.now.to_i + 12_000 })
      render json: {
        user: UserSerializer.new(user),
        token: @token
      }, status: :created
    else
      error_object = {}
      user.errors.messages.each do |msg, desc|
        error_object[msg] = desc[0]
      end
      render json: { errors: error_object }, status: :unauthorized
      # render json: { error: user.errors.messages.map { |msg, desc| "#{msg} #{desc[0]}" }.join(',') }, status: :unauthorized
    end
  end

  def login
    test_user = User.new(login_params)
    unless test_user.valid?(:login)
      error_object = {}
      test_user.errors.messages.each do |msg, desc|
        error_object[msg] = desc[0]
      end
      render json: { errors: error_object }, status: :unauthorized
      return
    end

    @user = User.find_by!(email: login_params[:email])
    if @user.authenticate(login_params[:password])
      @token = encode_token({ user_id: @user.id, exp: Time.now.to_i + 12000 })
      render json: {
        user: UserSerializer.new(@user),
        token: @token
      }, status: :accepted
    else
      render json: { errors: 'Mật khẩu hoặc tên đăng nhập không chính xác' }, status: :unauthorized
    end

  end

  private

  def register_params
    params.permit(:username, :email, :password, :password_confirmation)
  end

  def login_params
    params.permit(:email, :password)
  end

  def handle_record_not_found(e)
    render json: { errors: "Mật khẩu hoặc tên đăng nhập không chính xác" }, status: :unauthorized
  end

  def handle_invalid_record(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
end
