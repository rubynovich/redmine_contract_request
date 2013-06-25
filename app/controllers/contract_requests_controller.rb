class ContractRequestsController < ApplicationController
  unloadable

  before_filter :find_object, :only => [:edit, :update, :show, :destroy]
  before_filter :find_project, :only => [:index, :new, :create, :update]
  before_filter :get_project, :only => [:edit, :update, :show]
  before_filter :new_object, :only => [:index, :new, :create]

  helper :journals
  helper :issues
  helper :attachments
  include AttachmentsHelper

  def index
    @limit = per_page_option

    @scope = object_class_name.
      issue_status(params[:status_id]).
      issue_priority(params[:priority_id]).
      like_field(params[:contract_time], :contract_time).
      like_field(params[:contract_price], :contract_price).
      eql_field(params[:contract_subject], :contract_subject).
      eql_field(params[:company_type], :company_type).
      eql_field(params[:company_organization], :company_organization).
      eql_field(params[:company_settlement_procedure], :company_settlement_procedure).
      eql_field(params[:contact_id], :contact_id).
      eql_field(@project.try(:id), :project_id).
      eql_field(params[:author_id], :author_id).
      time_period(params[:time_period_created_on], :created_on)

    @count = @scope.count

    @pages = begin
      Paginator.new @count, @limit, params[:page]
    rescue
      Paginator.new self, @count, @limit, params[:page]
    end
    @offset ||= begin
      @pages.offset
    rescue
      @pages.current.offset
    end

    @collection = @scope.
      limit(@limit).
      offset(@offset).
#      order(sort_clause).
      all
  end

  def create
    @object.author_id = User.current.id
    @object.project = @project
    @object.save_attachments(params[:attachments])
    if @object.save
      flash[:notice] = l(:notice_successful_create)
      render_attachment_warning_if_needed(@object)
      redirect_to :action => :show, :id => @object.id
    else
      render :action => :new
    end
  end

  def update
    @object.save_attachments(params[:attachments])
    if @object.update_attributes(params[object_sym])
      flash[:notice] = l(:notice_successful_update)
      render_attachment_warning_if_needed(@object)
      redirect_to :action => :show, :id => @object.id
    else
      render :action => :edit
    end
  end

  def destroy
    flash[:notice] = l(:notice_successful_delete) if @object.destroy
    redirect_to :action => :index
  end

  def show
    if @issue = @object.issue
      @journals = get_journals
    end
  end

  private
    def object_class_name
      ContractRequest
    end

    def object_sym
      :contract_request
    end

    def find_object
      @object = object_class_name.find(params[:id])
    end

    def find_project
      begin
        @project = Project.find(params[:project_id])
      rescue
        render_403
      end
    end

    def get_project
      begin
        @project = (@object || find_object).project
      rescue
        render_403
      end
    end

    def new_object
      @object = object_class_name.new(params[object_sym])
    end

    def get_journals
      journals = @issue.journals.includes(:user, :details).reorder("#{Journal.table_name}.id ASC").all
      journals.each_with_index {|j,i| j.indice = i+1}
      journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
      journals.reverse! if User.current.wants_comments_in_reverse_order?
      journals
    end

    def require_staff_request_manager
      (render_403; return false) unless User.current.staff_request_manager?
    end
end
