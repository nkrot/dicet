
FactoryGirl.define do
  factory :word do
    text       "mouse"
    typo        false
    comment    "an animal or a device"
    created_at "2013-08-14 08:40:42"
    updated_at "2013-08-14 08:40:42"
  end
end


FactoryGirl.define do
  factory :user do
    login      "luser"
    email      "luser@ihs.com"
    created_at "2013-08-15 18:40:42"
    updated_at "2013-08-15 18:40:42"
  end
end
