FactoryBot.define do
  factory :storage_file do
    sequence(:name) { |n| "file_#{n}.txt" }
    file_type_storage { :disk }
    association :directory

    trait :without_directory do
      directory { nil }
    end

    trait :root do
     parent { nil }
     to_create { |instance| instance.save! }
    end
  end
end
