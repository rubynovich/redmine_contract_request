class ContractRequestsController < ApplicationController
  unloadable

  before_filter :find_object, :only => [:edit, :update, :show, :destroy]
  before_filter :find_project, :only => [:index, :new]
  before_filter :new_object, :only => [:index, :new, :create]

  def index
#    sort_init 'created_on', 'desc'
#    sort_update %w(name company_name department_name boss_name position_type_name employment_type_name require_education_name created_on)

    @limit = per_page_option

    @scope = object_class_name.
      where(nil) # FIXME
#      like_field(params[:name], :name).
#      eql_field(params[:company_name], :company_name).
#      time_period(params[:time_period_created_on], :created_on)

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
    if @object.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => :show, :id => @object.id
    else
      render :action => :new
    end
  end

  def update
    if @object.update_attributes(params[object_sym])
      flash[:notice] = l(:notice_successful_update)
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
      @project = Project.find(params[:project_id]) if params[:project_id].present?
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
