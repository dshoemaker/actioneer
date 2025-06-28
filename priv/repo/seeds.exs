# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Actioneer.Repo.insert!(%Actioneer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Actioneer.Repo
alias Actioneer.Accounts.User
alias Actioneer.Events.Event

# Create test users
creator_user = Repo.insert!(%User{
  email: "creator@actioneer.com",
  name: "Alex Creator",
  role: :creator,
  city: "San Francisco",
  state: "CA",
  zip_code: "94103",
  bio: "Passionate about organizing community events and creating positive change!",
  hashed_password: Bcrypt.hash_pwd_salt("password123"),
  confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
})

participant_user = Repo.insert!(%User{
  email: "participant@actioneer.com", 
  name: "Jamie Participant",
  role: :participant,
  city: "Oakland",
  state: "CA", 
  zip_code: "94607",
  bio: "Love participating in community activities and making new friends!",
  hashed_password: Bcrypt.hash_pwd_salt("password123"),
  confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
})

both_user = Repo.insert!(%User{
  email: "both@actioneer.com",
  name: "Taylor Community",
  role: :both,
  city: "Berkeley", 
  state: "CA",
  zip_code: "94704",
  bio: "I create events and love participating in others' initiatives too!",
  hashed_password: Bcrypt.hash_pwd_salt("password123"),
  confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
})

# Create some sample events
upcoming_cleanup = Repo.insert!(%Event{
  title: "Golden Gate Park Cleanup",
  description: "Join us for a community cleanup of Golden Gate Park! We'll provide gloves, trash bags, and refreshments. Help us keep our beautiful park clean and green for everyone to enjoy.",
  address: "Golden Gate Park, San Francisco, CA",
  latitude: 37.7694,
  longitude: -122.4862,
  date_time: DateTime.utc_now() |> DateTime.add(7, :day) |> DateTime.truncate(:second),
  category: :environment,
  max_participants: 25,
  status: :published,
  creator_id: creator_user.id
})

cultural_festival = Repo.insert!(%Event{
  title: "Neighborhood Cultural Festival Planning",
  description: "Help us organize our annual cultural festival! We need volunteers for planning, vendor coordination, and day-of logistics. Great opportunity to learn event planning skills while celebrating our diverse community.",
  address: "Community Center, Oakland, CA", 
  latitude: 37.8044,
  longitude: -122.2712,
  date_time: DateTime.utc_now() |> DateTime.add(14, :day) |> DateTime.truncate(:second),
  category: :culture,
  max_participants: 15,
  status: :published,
  creator_id: both_user.id
})

voter_registration = Repo.insert!(%Event{
  title: "Voter Registration Drive",
  description: "Help register voters in our community! We'll provide training on the registration process and all materials needed. Perfect for first-time volunteers - we'll teach you everything you need to know.",
  address: "Berkeley Community Library, Berkeley, CA",
  latitude: 37.8715,
  longitude: -122.2730,
  date_time: DateTime.utc_now() |> DateTime.add(21, :day) |> DateTime.truncate(:second),
  category: :voting,
  max_participants: 10,
  status: :published,
  creator_id: both_user.id
})

food_drive = Repo.insert!(%Event{
  title: "Community Food Drive Collection",
  description: "Organizing a food drive to help local families in need. We need volunteers to help collect, sort, and distribute food donations. All ages welcome - bring the whole family!",
  address: "Various locations in San Francisco",
  latitude: 37.7749,
  longitude: -122.4194,
  date_time: DateTime.utc_now() |> DateTime.add(10, :day) |> DateTime.truncate(:second), 
  category: :community,
  max_participants: 30,
  status: :published,
  creator_id: creator_user.id
})

# Add some participants to events using raw SQL
Repo.query!("""
  INSERT INTO event_participants (event_id, user_id, status, inserted_at, updated_at)
  VALUES ($1, $2, 'joined', NOW(), NOW())
  ON CONFLICT (event_id, user_id) DO NOTHING
""", [upcoming_cleanup.id, participant_user.id])

Repo.query!("""
  INSERT INTO event_participants (event_id, user_id, status, inserted_at, updated_at) 
  VALUES ($1, $2, 'joined', NOW(), NOW())
  ON CONFLICT (event_id, user_id) DO NOTHING
""", [cultural_festival.id, participant_user.id])

IO.puts("""

✅ Database seeded successfully!

Test users created:
📧 creator@actioneer.com (password: password123) - Creator role
📧 participant@actioneer.com (password: password123) - Participant role  
📧 both@actioneer.com (password: password123) - Both creator & participant

Sample events created:
🌱 Golden Gate Park Cleanup
🎭 Neighborhood Cultural Festival Planning
🗳️  Voter Registration Drive
🍽️  Community Food Drive Collection

You can now log in and test the application!
""")
