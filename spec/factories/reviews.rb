FactoryBot.define do
  factory :review do
    user
    song
    tempo_rating { 3 }
    fingering_technique_rating { 3 }
    plucking_technique_rating { 3 }
    expression_rating { 3 }
    memorization_rating { 3 }
    summary { "テストレビュー" }
  end
end
