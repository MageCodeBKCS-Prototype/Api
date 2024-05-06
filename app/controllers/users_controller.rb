class UsersController < ApplicationController
  def me
    render json: current_user, status: :ok
  end

  def update
    # update_user = User.new(update_params)
    # unless update_user.valid?(:update)
    #   error_object = {}
    #   update_user.errors.messages.each do |msg, desc|
    #     error_object[msg] = desc[0]
    #   end
    #   render json: { errors: error_object }, status: :unprocessable_entity
    #   return
    # end

    user = current_user
    if user.update(update_params)
      render json: { message: 'Success' }, status: :ok
    else
      error_object = {}
      user.errors.messages.each do |msg, desc|
        error_object[msg] = desc[0]
      end
      render json: { errors: error_object }, status: :unprocessable_entity
    end

  end

  def change_password
    update_user = User.new(change_password_params)
    unless update_user.valid?(:change_password)
      error_object = {}
      update_user.errors.messages.each do |msg, desc|
        error_object[msg] = desc[0]
      end
      render json: { errors: error_object }, status: :unprocessable_entity
      return
    end

    user = current_user
    unless user.authenticate(params[:old_password])
      render json: { errors: { old_password: 'Incorrect password' } }, status: :unprocessable_entity
      return
    end

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      render json: { message: 'Success' }, status: :ok
    else
      error_object = {}
      user.errors.messages.each do |msg, desc|
        error_object[msg] = desc[0]
      end
      render json: { errors: error_object }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.permit(:username)
  end

  def change_password_params
    params.permit(:old_password, :password, :password_confirmation)
  end

end
