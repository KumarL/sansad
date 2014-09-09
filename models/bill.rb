class Bill
  include Api::Model
  publicly :queryable, :searchable

# title, status (pending, passed, pending, drafted, etc.)
# ministry, introduced_on, ls_passed, rs_passed (dates, if the status is passed)
# ls_status, rs_status, introduced_by, bill_summary, bill_text
  basic_fields :bill_id, :title, :status, :ministry,
    :introduced_by, :introduced_on, :ls_status, :rs_status,
    :com_ref, :com_rep, :last_action_at, :last_action, :summary, :text, :url

  search_fields :title, :status, :ministry,
    :introduced_by, :last_action_at, :summary

  search_profile :title_summary_recency,
    fields: [:title, :summary],
    functions: [
      {
        filter: {
          exists: {
            field: :introduced_on
          }
        },
        gauss: {
          introduced_on: {
            scale: '365d'
          }
        }
      }
    ]

  cite_key :bill_id



  include Mongoid::Document
  include Mongoid::Timestamps

  index bill_id: 1
  index title: 1
  index status: 1
  index ministry: 1
  index introduced_by: 1
  index last_action_at: 1
  index summary: 1

  # support an orderly ordering of recent bills
  index introduced_on: 1
  index citation_ids: 1
end
