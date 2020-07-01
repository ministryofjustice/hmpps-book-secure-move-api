class PersonEscortRecord < VersionedModel
  enum states: {
    not_started: 'not_started',
    in_progress: 'in_progress',
    completed: 'completed',
    confirmed: 'confirmed',
  }

  validates :state, presence: true, inclusion: { in: states }
  has_many :framework_responses
  belongs_to :framework
end
