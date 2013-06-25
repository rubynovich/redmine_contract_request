module ContractRequestsHelper
  def contract_type_for_select
    t(:contract_type, :scope => :contract_requiest)
  end

  def contract_subject_for_select
    t(:contract_subject, :scope => :contract_requiest)
  end

  def contract_organization_for_select
    t(:contract_organization, :scope => :contract_requiest)
  end

  def contract_settlement_procedure_for_select
    t(:contract_settlement_procedure, :scope => :contract_requiest)
  end

  def project_id_for_select
    Project.where("#{Project.table_name}.id IN (SELECT #{ContractRequest.table_name}.project_id FROM #{ContractRequest.table_name})").all(:order => :name)
  end

  def author_id_for_select
    User.where("#{User.table_name}.id IN (SELECT #{ContractRequest.table_name}.author_id FROM #{ContractRequest.table_name})").all(:order => [:lastname, :firstname])
  end

  def status_id_for_select
    IssueStatus.all(:order => :position)
  end

  def priority_id_for_select
    IssuePriority.all(:order => :position)
  end

  def contact_id_for_select(project)
    Contact.where("#{Contact.table_name}.id IN (SELECT #{ContractRequest.table_name}.contact_id FROM #{ContractRequest.table_name})").all
  end

  def time_periods
    %w{yesterday last_week this_week last_month this_month last_year this_year}
  end

  def contract_price(item)
    price = item.contract_price
    if price[/^\d+$/]
      ActionController::Base.helpers.number_to_currency(price,
          :unit => '',
          :separator => '.',
          :delimiter => ' ',
          :precision => 2)
    else
      price
    end
  end
end
