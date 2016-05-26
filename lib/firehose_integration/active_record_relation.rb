class ActiveRecord::Relation
  def update_all_with_kinesis(params)
    self.update_all params
    FirehoseIntegration::KinesisSingleObjectJob.perform_later(ancestors.first.to_s, self.pluck(:id))
  end
end
