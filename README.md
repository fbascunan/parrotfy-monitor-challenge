# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Project Conventions & Architecture

- **Usecases**: Business logic is organized in `app/usecases`. Each usecase is a plain Ruby object, e.g., `app/usecases/players/place_bet.rb`.
- **Scaffold**: Use Rails scaffolds for CRUD to keep things simple and maintainable.
- **Vue 3**: Integrated via importmap. Use the `vue-app` id in your views to mount Vue components.
- **Sidekiq**: Used for background jobs. Start with `bundle exec sidekiq`. Redis is required.
- **Whenever**: Used for cron jobs. Edit `config/schedule.rb` and run `whenever --update-crontab` to apply.
- **WebSocket**: Use Action Cable for real-time updates.

## Setup Notes

1. **Install dependencies**
   ```sh
   bundle install
   yarn install # if you add more JS deps
   ```
2. **Database setup**
   ```sh
   rails db:setup
   ```
3. **Start Sidekiq**
   ```sh
   bundle exec sidekiq
   ```
4. **Start Rails server**
   ```sh
   bin/rails server
   ```
5. **Update cron jobs**
   ```sh
   whenever --update-crontab
   ```

## Example: Mounting Vue

Add this to any view:
```erb
<div id="vue-app"></div>
```
