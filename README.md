# Parrotfy Casino Monitor

A Ruby on Rails 8 application that simulates a dynamic group of people playing roulette, with **OpenAI-powered realistic betting behavior** influenced by weather conditions in Santiago, Chile.

## Features

- **OpenAI-Powered AI**: Advanced player psychology analysis using GPT-4 for realistic human-like decisions
- **Emotional Intelligence**: AI tracks emotional states (confident, frustrated, desperate, cautious, excited)
- **Player Management**: Create, update, and manage players with default $10,000 balance
- **Automated Roulette**: Rounds run every 3 minutes automatically
- **Weather-Based Betting**: Players bet more conservatively when hot weather (>23°C) is forecast
- **Real-Time Updates**: WebSocket integration for live round updates
- **Background Processing**: Sidekiq for automated round execution
- **Modern UI**: Tailwind CSS with Vue.js integration
- **Analytics Dashboard**: AI behavior analysis with emotional states and reasoning

## AI Integration

The application features sophisticated **OpenAI-powered AI** that analyzes player behavior with human-like psychology:

### **Advanced Psychology Analysis**
- **Emotional State Tracking**: Confident, frustrated, desperate, cautious, excited, neutral
- **Risk Tolerance Assessment**: Conservative, aggressive, desperate, balanced based on performance
- **Pattern Recognition**: Color switching, bet amount trends, win/loss streaks
- **Human Psychology**: Loss aversion, hot hand fallacy, gambler's fallacy

### **Realistic Decision Making**
- **Context-Aware Decisions**: Considers balance, recent performance, weather, and emotional state
- **Natural Language Reasoning**: AI provides human-like explanations for betting decisions
- **Confidence Scoring**: Each decision includes confidence level (0-100%)
- **Emotional Intelligence**: AI understands and responds to player emotions

### **Smart Features**
- **Personality Profiling**: AI builds detailed player profiles over time
- **Weather Impact**: Considers how weather affects player mood and decisions
- **Pattern Breaking**: AI avoids predictable behavior patterns
- **Fallback Systems**: Graceful degradation when OpenAI is unavailable

## Architecture

- **Rails 8**: Latest Rails version with modern conventions
- **OpenAI GPT-4**: Advanced AI for realistic player behavior
- **Usecases**: Business logic organized in `app/usecases/` for clean separation
- **AI Engine**: `AI::OpenAIBehaviorAnalyzer` for intelligent decision making
- **Sidekiq**: Background job processing for automated rounds
- **Action Cable**: WebSocket support for real-time updates
- **Vue 3**: Frontend interactivity via importmap
- **Tailwind CSS**: Modern styling framework
- **Tomorrow.io**: Weather API integration

## Setup

### Prerequisites

- Ruby 3.3+
- PostgreSQL
- Redis (for Sidekiq)
- Node.js/Yarn (for JavaScript dependencies)
- OpenAI API key

### Installation

1. **Clone and install dependencies**
   ```sh
   git clone <repository-url>
   cd parrotfy-monitor-challenge
   bundle install
   yarn install
   ```

2. **Environment setup**
   ```sh
   # Create .env file with your API keys
   echo "WEATHER_API_KEY=your_tomorrow_io_api_key_here" > .env
   echo "OPENAI_API_KEY=your_openai_api_key_here" >> .env
   ```

3. **Database setup**
   ```sh
   rails db:create db:migrate db:seed
   ```

4. **Start services**
   ```sh
   # Terminal 1: Rails server
   bin/rails server
   
   # Terminal 2: Sidekiq (requires Redis)
   bundle exec sidekiq
   
   # Terminal 3: Redis (if not running)
   redis-server
   ```

5. **Setup cron jobs** (optional, for production)
   ```sh
   whenever --update-crontab
   ```

### Environment Variables

Create a `.env` file with:
```
WEATHER_API_KEY=your_tomorrow_io_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
```

Get API keys from:
- [Tomorrow.io](https://www.tomorrow.io/weather-api/) (free tier available)
- [OpenAI](https://platform.openai.com/api-keys) (requires account)

## Usage

### Main Features

- **Rounds Index** (`/`): View all past roulette rounds with player bets
- **Players** (`/players`): Manage player accounts and balances
- **Analytics Dashboard** (`/analytics/dashboard`): OpenAI-powered AI behavior analysis
- **Sidekiq Dashboard** (`/sidekiq`): Monitor background jobs (development only)

### AI Behavior Analysis

The analytics dashboard shows:
- **Emotional States**: Real-time emotional tracking (confident, frustrated, etc.)
- **Risk Tolerance**: How conservative/aggressive each player is
- **AI Reasoning**: Natural language explanations for betting decisions
- **Confidence Levels**: AI confidence in each decision (0-100%)
- **Performance Trends**: Hot/cold streaks and win rates
- **Weather Impact**: How weather affects betting patterns
- **Player Statistics**: Detailed performance metrics

### Automated Features

- **Roulette Rounds**: Run every 3 minutes automatically with OpenAI-powered decisions
- **Weather Integration**: Checks Santiago weather via Tomorrow.io API
- **Daily Reset**: All players receive $10,000 daily at midnight
- **Real-Time Updates**: Live round results via WebSocket

### Betting Logic

- **Normal Conditions**: Players bet 8-15% of their balance (AI modified)
- **Hot Weather (>23°C)**: Players bet conservatively (3-7%)
- **Low Balance (≤$1,000)**: Players go "All In"
- **Zero Balance**: Players don't bet
- **AI Modifiers**: Bet amounts adjusted by performance, emotions, and risk tolerance
- **Emotional Intelligence**: AI considers player emotional state in decisions

### Roulette Probabilities

- **Green**: 2% (15x payout)
- **Red**: 49% (2x payout)
- **Black**: 49% (2x payout)

## Development

### Project Structure

```
app/
├── controllers/          # Rails controllers
├── models/              # ActiveRecord models
├── usecases/            # Business logic
│   ├── players/         # Player-related usecases
│   ├── rounds/          # Round-related usecases
│   ├── weather/         # Weather service (Tomorrow.io)
│   └── ai/              # AI behavior analysis
│       ├── player_behavior_analyzer.rb      # Basic AI
│       └── openai_behavior_analyzer.rb      # OpenAI-powered AI
├── views/               # ERB templates
└── javascript/          # Vue.js components
```

### Key Usecases

- `Players::PlaceBet`: Handles individual player betting with OpenAI integration
- `Rounds::PlayRouletteRound`: Manages complete round execution
- `Weather::SantiagoService`: Tomorrow.io weather API integration
- `AI::OpenAIBehaviorAnalyzer`: Advanced AI with emotional intelligence

### Testing

```sh
# Run tests
bin/rails test

# Run specific test files
bin/rails test test/models/player_test.rb
```

## Deployment

### Render (Recommended)

1. Connect your GitHub repository to Render
2. Create a new Web Service
3. Set environment variables:
   - `WEATHER_API_KEY`
   - `OPENAI_API_KEY`
   - `REDIS_URL` (Render provides this)
4. Deploy!

### Manual Deployment

1. Set up PostgreSQL and Redis on your server
2. Configure environment variables
3. Run migrations and seed data
4. Start Rails server and Sidekiq
5. Set up cron jobs with `whenever --update-crontab`

## Contributing

1. Follow Rails conventions
2. Use usecases for business logic
3. Add tests for new features
4. Keep the architecture clean and simple

## License

This project is part of the Parrotfy assignment.
