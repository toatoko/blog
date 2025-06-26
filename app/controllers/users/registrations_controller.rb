# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  def update
    # Check if this is specifically an address-only update
    # (when user submits only address form, not the main user form)
    if params[:address].present? && params[:user].blank?
      # Address-only update
      @user = current_user
      @address = current_user.address || current_user.build_address
      if @address.update(address_params)
        redirect_to root_path, notice: "Address updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    else
      # Regular user profile update - let Devise handle it
      super
    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:email,
                                                              :avatar,
                                                              :password,
                                                              :password_confirmation,
                                                              :current_password,
                                                              :first_name,
                                                              :last_name,
                                                              {address: %i[street city state zip country]} ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    # super(resource)

    after_signup_path("set_name")
  end
# The path used after sign up for inactive accounts.
# def after_inactive_sign_up_path_for(resource)
# super(resource)
# end

private
  def address_params
    params.require(:address).permit(:id, :street, :city, :state, :zip, :country)
  end
end