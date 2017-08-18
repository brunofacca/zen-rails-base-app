# :nodoc:
class ContactFormsController < ApplicationController
  # This controller does not require authorization or authentication
  include SkipAuthorization
  skip_before_action :authenticate_user!

  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(params[:contact_form])
    @contact_form.request = request
    if @contact_form.deliver
      flash[:success] = t('.success')
      render html: '', layout: true
    else
      render :new
    end
  end
end
