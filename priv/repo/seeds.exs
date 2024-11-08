# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Skool.Repo.insert!(%Skool.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Seeds.Helpers do
  def date_today do
    DateTime.utc_now()
    |> DateTime.shift_zone!("America/Denver", Tz.TimeZoneDatabase)
    |> DateTime.to_date()
  end
end

zach =
  Skool.Repo.insert!(%Skool.Accounts.User{
    first_name: "Zach",
    last_name: "Taylor",
    hashed_password: Bcrypt.hash_pwd_salt("password"),
    email: "zach@example.com"
  })

Skool.Repo.insert!(%Skool.Accounts.User{
  first_name: "Maddie",
  last_name: "Taylor",
  hashed_password: Bcrypt.hash_pwd_salt("password"),
  email: "maddie@example.com"
})

Skool.Repo.insert!(%Skool.Accounts.User{
  first_name: "Megan",
  last_name: "North",
  hashed_password: Bcrypt.hash_pwd_salt("password"),
  email: "megan@example.com"
})

Skool.Repo.insert!(%Skool.Accounts.User{
  first_name: "Russell",
  last_name: "North",
  hashed_password: Bcrypt.hash_pwd_salt("password"),
  email: "russell@example.com"
})

spirituality_course =
  Skool.Repo.insert!(%Skool.Courses.Course{
    name: "Discovering Spirituality",
    description:
      "In this course, I want to understand what spiritual practices are most meaningful to me and bring me peace. I think being in tune with my spiritual self is key to happiness and fulfillment.",
    created_by_id: zach.id,
    start_date: Seeds.Helpers.date_today(),
    end_date: Seeds.Helpers.date_today() |> Date.shift(month: 3, day: -1)
  })

Skool.Repo.insert!(%Skool.Courses.Assignment{
  title: "Journaling",
  kind: :recurring,
  grade_weight: 0.25,
  start_date: Seeds.Helpers.date_today(),
  end_date: Seeds.Helpers.date_today() |> Date.shift(month: 3),
  repeats_every: 1,
  repeats_every_unit: :day,
  course_id: spirituality_course.id
})

Skool.Repo.insert!(%Skool.Courses.Assignment{
  title: "Meditation",
  kind: :recurring,
  grade_weight: 0.25,
  start_date: Seeds.Helpers.date_today(),
  end_date: Seeds.Helpers.date_today() |> Date.shift(month: 3),
  repeats_every: 1,
  repeats_every_unit: :day,
  course_id: spirituality_course.id
})

Skool.Repo.insert!(%Skool.Courses.Assignment{
  title: "Reflection",
  description:
    "Reflect on your spiritual journey through writing. What have you learned? What do you want to learn now?",
  kind: :task,
  grade_weight: 0.25,
  due_date: Seeds.Helpers.date_today() |> Date.shift(month: 3),
  course_id: spirituality_course.id
})

reading_assignment =
  Skool.Repo.insert!(%Skool.Courses.Assignment{
    title: "Reading",
    kind: :checklist,
    grade_weight: 0.25,
    due_date: Seeds.Helpers.date_today() |> Date.shift(month: 3),
    course_id: spirituality_course.id
  })

Skool.Repo.insert!(%Skool.Courses.ChecklistItem{
  title: "Tao Te Ching",
  description:
    "I'm interested in eastern philosophy, and this is one of the most famous eastern philosophy books.",
  grade_weight: 0.333333,
  due_date: Seeds.Helpers.date_today() |> Date.shift(month: 1),
  assignment_id: reading_assignment.id
})

Skool.Repo.insert!(%Skool.Courses.ChecklistItem{
  title: "The Creative Act",
  description: "Creativity and spirituality are closely linked.",
  grade_weight: 0.333333,
  due_date: Seeds.Helpers.date_today() |> Date.shift(month: 2),
  assignment_id: reading_assignment.id
})

Skool.Repo.insert!(%Skool.Courses.ChecklistItem{
  title: "A Court of Mist and Fury",
  description:
    "Fiction can be spiritual too. The hero's journey is a spiritual journey. Notice that as you read. Notice how the character changes through the story, how they deal with adversity, and how it makes them better.",
  grade_weight: 0.333333,
  due_date: Seeds.Helpers.date_today() |> Date.shift(month: 3),
  assignment_id: reading_assignment.id
})
