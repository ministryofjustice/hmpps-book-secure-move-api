class PersonEscortRecord < VersionedModel
  enum states: {
    in_progress: 'in_progress',
    completed: 'completed',
    confirmed: 'confirmed',
  }

  validates :state, presence: true, inclusion: { in: states }
  has_many :framework_responses, dependent: :destroy

  belongs_to :framework
  has_many :framework_questions, through: :framework
  belongs_to :profile
  validates :profile, uniqueness: true
end
