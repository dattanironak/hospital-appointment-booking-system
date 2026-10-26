module Admin
  class DoctorsController < BaseController
    def index
      @doctors = User.doctor.order(:name)
    end

    def new
      @doctor = User.new
    end

    def create
      @doctor = User.new(doctor_params.merge(role: :doctor))
      if @doctor.save
        redirect_to admin_doctors_path, notice: "Doctor account created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @doctor = User.doctor.find(params[:id])
    end

    def update
      @doctor = User.doctor.find(params[:id])
      attrs = update_params
      @doctor.password = attrs.delete(:password) if attrs[:password].present?

      if @doctor.update(attrs)
        redirect_to admin_doctors_path, notice: "Doctor account updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def doctor_params
      params.require(:user).permit(:name, :email, :specialty, :password)
    end

    def update_params
      params.require(:user).permit(:name, :specialty, :active, :password).to_h.symbolize_keys
    end
  end
end
