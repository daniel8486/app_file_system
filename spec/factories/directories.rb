FactoryBot.define do
  factory :directory do
    sequence(:name) { |n| "directory_#{n}" }
    parent { nil }

    trait :with_parent do
      association :parent, factory: :directory
    end

    trait :root do
     parent { nil }
     to_create { |instance| instance.save! }
    end
  end
end
