// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "vue"

import { createApp } from "vue"
import LoadingSpinner from "./components/LoadingSpinner.js"
import AnalyticsDashboard from "./components/AnalyticsDashboard.js"

document.addEventListener("DOMContentLoaded", () => {
  // Analytics Dashboard
  const analyticsEl = document.getElementById("analytics-dashboard")
  if (analyticsEl) {
    createApp(AnalyticsDashboard).mount(analyticsEl)
  }
  
  // Vue App (legacy)
  const vueEl = document.getElementById("vue-app")
  if (vueEl) {
    createApp({
      components: {
        LoadingSpinner
      },
      data() {
        return { 
          message: "Hello from Vue 3!",
          loading: false
        }
      },
      methods: {
        async simulateLoading() {
          this.loading = true
          await new Promise(resolve => setTimeout(resolve, 2000))
          this.loading = false
        }
      },
      template: `
        <div class='p-4 bg-green-100 rounded'>
          <div v-if="loading">
            <LoadingSpinner text="Processing..." />
          </div>
          <div v-else>
            <p>{{ message }}</p>
            <button @click="simulateLoading" class="mt-2 px-3 py-1 bg-blue-500 text-white rounded">
              Test Loading
            </button>
          </div>
        </div>
      `
    }).mount(vueEl)
  }
})

// Import ActionCable channels
import "./channels"
