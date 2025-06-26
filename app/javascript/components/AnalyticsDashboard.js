import LoadingSpinner from './LoadingSpinner.js'

export default {
  name: 'AnalyticsDashboard',
  components: {
    LoadingSpinner
  },
  data() {
    return {
      loading: false,
      refreshing: false,
      stats: {
        totalRounds: 0,
        activePlayers: 0,
        totalBets: 0,
        totalVolume: 0
      },
      lastUpdate: null,
      error: null
    }
  },
  mounted() {
    this.loadStats()
    this.startAutoRefresh()
  },
  beforeUnmount() {
    this.stopAutoRefresh()
  },
  methods: {
    async loadStats() {
      this.loading = true
      this.error = null
      
      try {
        const response = await fetch('/analytics/dashboard.json')
        if (!response.ok) throw new Error('Failed to load analytics')
        
        const data = await response.json()
        this.stats = {
          totalRounds: data.total_rounds || 0,
          activePlayers: data.active_players || 0,
          totalBets: data.total_bets || 0,
          totalVolume: data.total_volume || 0
        }
        this.lastUpdate = new Date()
      } catch (error) {
        console.error('Analytics loading error:', error)
        this.error = 'Failed to load analytics data'
      } finally {
        this.loading = false
      }
    },
    
    async refreshStats() {
      this.refreshing = true
      await this.loadStats()
      this.refreshing = false
    },
    
    startAutoRefresh() {
      this.refreshInterval = setInterval(() => {
        this.refreshStats()
      }, 30000) // Refresh every 30 seconds
    },
    
    stopAutoRefresh() {
      if (this.refreshInterval) {
        clearInterval(this.refreshInterval)
      }
    },
    
    formatCurrency(amount) {
      return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      }).format(amount)
    },
    
    formatTime(date) {
      return new Intl.DateTimeFormat('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      }).format(date)
    }
  },
  template: `
    <div class="bg-white rounded-lg shadow p-6">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-semibold text-gray-900">Real-time Analytics</h2>
        <div class="flex items-center space-x-2">
          <button 
            @click="refreshStats" 
            :disabled="refreshing"
            class="inline-flex items-center px-3 py-1 border border-transparent text-sm font-medium rounded-md text-blue-700 bg-blue-100 hover:bg-blue-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <svg v-if="refreshing" class="animate-spin -ml-1 mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <svg v-else class="-ml-1 mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
            </svg>
            Refresh
          </button>
          <div v-if="lastUpdate" class="text-xs text-gray-500">
            Last update: {{ formatTime(lastUpdate) }}
          </div>
        </div>
      </div>
      
      <div v-if="loading && !refreshing" class="py-8">
        <LoadingSpinner size="large" text="Loading analytics..." />
      </div>
      
      <div v-else-if="error" class="py-8 text-center">
        <div class="text-red-600 mb-2">
          <svg class="mx-auto h-12 w-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
          </svg>
        </div>
        <p class="text-gray-600">{{ error }}</p>
        <button @click="loadStats" class="mt-4 text-blue-600 hover:text-blue-800">Try again</button>
      </div>
      
      <div v-else class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="bg-blue-50 rounded-lg p-4">
          <div class="flex items-center">
            <div class="p-2 rounded-full bg-blue-100">
              <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-blue-600">Total Rounds</p>
              <p class="text-2xl font-semibold text-blue-900">{{ stats.totalRounds }}</p>
            </div>
          </div>
        </div>
        
        <div class="bg-green-50 rounded-lg p-4">
          <div class="flex items-center">
            <div class="p-2 rounded-full bg-green-100">
              <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-green-600">Active Players</p>
              <p class="text-2xl font-semibold text-green-900">{{ stats.activePlayers }}</p>
            </div>
          </div>
        </div>
        
        <div class="bg-yellow-50 rounded-lg p-4">
          <div class="flex items-center">
            <div class="p-2 rounded-full bg-yellow-100">
              <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-yellow-600">Total Bets</p>
              <p class="text-2xl font-semibold text-yellow-900">{{ stats.totalBets }}</p>
            </div>
          </div>
        </div>
        
        <div class="bg-purple-50 rounded-lg p-4">
          <div class="flex items-center">
            <div class="p-2 rounded-full bg-purple-100">
              <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"></path>
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm font-medium text-purple-600">Total Volume</p>
              <p class="text-2xl font-semibold text-purple-900">{{ formatCurrency(stats.totalVolume) }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  `
} 