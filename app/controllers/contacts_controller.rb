class ContactsController < ApplicationController
  def create
    service = Contacts::FormSubmissionService.new(
      name: params[:name],
      email: params[:email],
      content: params[:content]
    )

    if service.call
      flash[:notice] = t("contacts.create.success")
      redirect_to root_path
    else
      flash[:alert] = t("contacts.create.failure")
      redirect_to contact_path
    end
  end
end
