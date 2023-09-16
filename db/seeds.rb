# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(name:'test', email:'test@test', password:'testtest', password_confirmation:'testtest')


Calendar.create(name: 'カンパニーA', color: '#2196F3', visibility: true, user_id: 1)
Calendar.create(name: 'カンパニーB', color: '#00BCD4', visibility: true, user_id: 1)
Calendar.create(name: 'カンパニーC', color: '#F48FB1', visibility: true, user_id: 1)
Calendar.create(name: 'カンパニーD', color: '#795548', visibility: true, user_id: 1)
Calendar.create(name: 'カンパニーE', color: '#E91E63', visibility: true, user_id: 1)
Calendar.create(name: 'カンパニーF', color: '#607D8B', visibility: true, user_id: 1)
Calendar.create(name: '会議室', color: '#FFEB3B', visibility: true, user_id: 1)
Calendar.create(name: '社用車', color: '#FFEB3B', visibility: true, user_id: 1)
Calendar.create(name: 'スタジオ', color: '#FFEB3B', visibility: true, user_id: 1)

