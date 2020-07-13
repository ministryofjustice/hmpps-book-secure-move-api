class PersonEscortRecord < VersionedModel
  enum states: {
    in_progress: 'in_progress',
    completed: 'completed',
    confirmed: 'confirmed',
  }

  validates :state, presence: true, inclusion: { in: states }
  has_many :framework_responses, dependent: :destroy
  belongs_to :framework
  belongs_to :profile
end
