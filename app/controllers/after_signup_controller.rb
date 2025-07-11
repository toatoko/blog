class AfterSignupController < ApplicationController
  include Wicked::Wizard
  steps(*User.form_steps)
  def show
    @user = current_user
    case step
    when "sign_up"
      skip_step if @user.persisted?
    when "set_address"
        @address = @user.address || @user.build_address
    when "find_users"
          @users = User.includes(:address)
    end

    render_wizard
  end
  def update
    @user = current_user

    case step
    when "set_name"
      if @user.update(onboarding_params(step))
        render_wizard @user
      else
          render_wizard @user, status: :unprocessable_entity
      end
    when "set_address"
      @address = @user.address || @user.build_address
      address_params = onboarding_params(step).except(:form_step)
      if @address.update(address_params)
        render_wizard @user
      else
          render_wizard @user, status: :unprocessable_entity
      end
    end
  end
  private
  def finish_wizard_path
    root_path
  end
  def onboarding_params(step = "sign_up")
    permitted_attributes = case step
    when "set_name"
      required_parameters = :user
      %i[first_name last_name]
    when "set_address"
      required_parameters = :address
      %i[street city state zip country]
    end
    params.require(required_parameters).permit(:id, permitted_attributes).merge(form_step: step)
  end
end
