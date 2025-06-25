# 🎰 Parrotfy Casino Monitor

A sophisticated Ruby on Rails 8 application that simulates a dynamic casino environment with **AI-powered players** making realistic betting decisions influenced by weather conditions in Santiago, Chile.

## ✨ Features

- **🤖 OpenAI-Powered AI**: Advanced player psychology with emotional intelligence
- **🌤️ Weather Integration**: Real-time Santiago weather affecting betting behavior
- **⏰ Automated Rounds**: Roulette rounds every 3 minutes with AI decisions
- **👥 Player Management**: Admin interface for managing casino players
- **📊 Analytics Dashboard**: Real-time AI behavior analysis and insights
- **🔔 Real-Time Updates**: Live WebSocket updates for round results
- **🎨 Modern UI**: Beautiful interface with Tailwind CSS and Vue.js

## 🚀 Live Demo

**[Deployed on Render]** - Coming soon!

## 🏗️ Architecture

- **Rails 8** - Latest Rails with modern conventions
- **OpenAI GPT-4o-mini** - Advanced AI for realistic player behavior
- **PostgreSQL** - Production database
- **Redis + Sidekiq** - Background job processing
- **Action Cable** - Real-time WebSocket updates
- **Tailwind CSS** - Modern styling
- **Vue 3** - Frontend interactivity
- **Tomorrow.io** - Weather API integration

## 🎯 AI Features

### **Emotional Intelligence**
- Tracks player emotions: confident, frustrated, desperate, cautious, excited
- Analyzes risk tolerance based on performance and balance
- Provides human-like reasoning for betting decisions
- Confidence scoring (0-100%) for each decision

### **Weather Impact**
- **Normal Weather**: Players bet 8-15% of balance
- **Hot Weather (>23°C)**: Conservative betting (3-7%)
- Real-time Santiago weather integration
- Weather affects player mood and decisions

### **Smart Betting Logic**
- **Low Balance (≤$1,000)**: Players go "All In"
- **Zero Balance**: No betting
- **AI Modifiers**: Bet amounts adjusted by performance and emotions
- **Pattern Recognition**: AI learns from player history

## 🎲 Roulette Rules

- **Green**: 2% probability (15x payout)
- **Red**: 49% probability (2x payout)  
- **Black**: 49% probability (2x payout)
- **Default Balance**: $10,000 per player
- **Daily Reset**: All players receive $10,000 at midnight

## 🛠️ Local Development

### Prerequisites
- Ruby 3.3+
- PostgreSQL
- Redis
- Node.js/Yarn

### Quick Start

1. **Clone and setup**
   ```bash
   git clone <repository-url>
   cd parrotfy-monitor-challenge
   bundle install
   yarn install
   ```

2. **Environment setup**
   ```bash
   # Create .env file
   cp .env.example .env
   # Add your API keys to .env
   ```

3. **Database setup**
   ```bash
   rails db:create db:migrate db:seed
   ```

4. **Start services**
   ```bash
   # Terminal 1: Rails server
   bin/rails server
   
   # Terminal 2: Sidekiq
   bundle exec sidekiq
   
   # Terminal 3: Redis (if needed)
   redis-server
   ```

5. **Visit the app**
   - Main dashboard: http://localhost:3000
   - Players: http://localhost:3000/players
   - Analytics: http://localhost:3000/analytics/dashboard

## 🔧 Environment Variables

Create a `.env` file with:

```env
# Required for AI features
OPENAI_API_KEY=your_openai_api_key_here

# Required for weather integration
WEATHER_API_KEY=your_tomorrow_io_api_key_here

# Optional: Customize settings
RAILS_ENV=development
```

### Getting API Keys

- **OpenAI**: [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
- **Tomorrow.io**: [tomorrow.io/weather-api](https://www.tomorrow.io/weather-api/) (free tier available)

## 🚀 Production Deployment (Render)

### 1. Connect Repository
- Connect your GitHub repository to Render
- Create a new **Web Service**

### 2. Configure Build Settings
```
Build Command: bundle install && yarn install
Start Command: bundle exec rails server -p $PORT -e production
```

### 3. Set Environment Variables
```
OPENAI_API_KEY=your_openai_api_key
WEATHER_API_KEY=your_tomorrow_io_api_key
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key
```

### 4. Add Redis Add-on
- Add **Redis** add-on from Render marketplace
- Environment variable `REDIS_URL` will be auto-configured

### 5. Deploy!
- Render will automatically deploy your application
- Monitor the build logs for any issues

## 📱 Usage

### **Main Dashboard** (`/`)
- View all roulette rounds with player bets
- Latest round shows detailed AI analysis
- Previous rounds are collapsed for clean view

### **Player Management** (`/players`)
- Create and manage player accounts
- View player statistics and betting history
- Admin interface for balance adjustments

### **Analytics** (`/analytics/dashboard`)
- Real-time AI behavior analysis
- Emotional state tracking
- Performance trends and insights
- Weather impact visualization

## 🧪 Testing

```bash
# Run all tests
bin/rails test

# Run specific test suites
bin/rails test test/models/
bin/rails test test/controllers/
```

## 📁 Project Structure

```
app/
├── controllers/          # Rails controllers
├── models/              # Player, Round, Bet models
├── usecases/            # Business logic
│   ├── ai/              # OpenAI integration
│   ├── players/         # Player management
│   ├── rounds/          # Roulette logic
│   └── weather/         # Weather service
├── views/               # ERB templates
└── javascript/          # Vue.js components
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is part of the Parrotfy Challenge assignment.

## 🆘 Support

For issues or questions:
- Check the logs in Render dashboard
- Verify environment variables are set correctly
- Ensure API keys are valid and have sufficient credits

---

**🎰 Ready to experience AI-powered casino simulation!**
