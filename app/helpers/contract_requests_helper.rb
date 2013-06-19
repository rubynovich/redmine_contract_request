module ContractRequestsHelper
  def contract_type_for_select
    t(:contract_type, :scope => :contract_requiest)
  end

  def contract_organization_for_select
    t(:contract_organization, :scope => :contract_requiest)
  end

  def contract_settlement_procedure_for_select
    t(:contract_settlement_procedure, :scope => :contract_requiest)
  end

  def contract_price(item)
    ActionController::Base.helpers.number_to_currency(item.contract_price,
        :unit => '',
        :separator => '.',
        :delimiter => ' ',
        :precision => 2)
  end
end
